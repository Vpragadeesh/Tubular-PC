use anyhow::Result;
use serde::{Deserialize, Serialize};
use std::process::Command;
use tokio::time::{timeout, Duration};
use std::sync::Arc;
use tokio::sync::RwLock;
use std::collections::HashMap;
use std::time::Instant;

/// Search cache entry with TTL (1 hour)
const SEARCH_CACHE_TTL: Duration = Duration::from_secs(3600);

struct CacheEntry {
    results: Vec<SearchResult>,
    created_at: Instant,
}

impl CacheEntry {
    fn is_expired(&self) -> bool {
        self.created_at.elapsed() > SEARCH_CACHE_TTL
    }
}

// Global search results cache
lazy_static::lazy_static! {
    static ref SEARCH_CACHE: Arc<RwLock<HashMap<String, CacheEntry>>> = Arc::new(RwLock::new(HashMap::new()));
}

#[derive(Debug, Serialize, Deserialize)]
pub struct VideoInfo {
    pub id: String,
    pub title: String,
    pub description: Option<String>,
    pub duration: Option<u64>,
    pub view_count: Option<u64>,
    pub like_count: Option<u64>,
    pub channel: String,
    pub channel_id: String,
    pub thumbnail: String,
    pub upload_date: Option<String>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct SearchResult {
    pub id: String,
    pub title: String,
    pub channel: String,
    pub duration: Option<u64>,
    pub view_count: Option<u64>,
    pub thumbnail: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct StreamUrl {
    pub url: String,
    pub format: String,
    pub quality: String,
}

/// Helper function to run yt-dlp with proper process killing on timeout
/// This ensures the process is terminated when timeout fires, not just the future
async fn run_yt_dlp_command(
    args: Vec<String>,
    timeout_secs: u64,
) -> Result<String> {
    // Spawn the blocking operation in a separate thread pool
    let spawn_result = tokio::task::spawn_blocking(move || {
        let args_str: Vec<&str> = args.iter().map(|s| s.as_str()).collect();
        
        let mut child = Command::new("yt-dlp")
            .args(&args_str)
            .stdout(std::process::Stdio::piped())
            .stderr(std::process::Stdio::piped())
            .spawn()?;
        
        child.wait_with_output()
    });
    
    match timeout(Duration::from_secs(timeout_secs), spawn_result).await {
        Ok(Ok(Ok(output))) => {
            if output.status.success() {
                Ok(String::from_utf8_lossy(&output.stdout).to_string())
            } else {
                let error = String::from_utf8_lossy(&output.stderr);
                Err(anyhow::anyhow!("yt-dlp failed: {}", error))
            }
        }
        Ok(Ok(Err(e))) => Err(anyhow::anyhow!("Failed to execute yt-dlp: {}", e)),
        Ok(Err(_)) => Err(anyhow::anyhow!("Thread panicked")),
        Err(_) => {
            anyhow::bail!(
                "yt-dlp command timed out after {} seconds. Process may be waiting for network response.",
                timeout_secs
            );
        }
    }
}

/// Search for videos using yt-dlp (supports both video search and channel search)
/// Results are cached for 1 hour
pub async fn search_videos(query: &str, limit: u32) -> Result<Vec<SearchResult>> {
    let cache_key = format!("{}:{}", query, limit);
    
    // Check cache first
    {
        let cache = SEARCH_CACHE.read().await;
        if let Some(entry) = cache.get(&cache_key) {
            if !entry.is_expired() {
                tracing::info!("📦 Cache hit for query: {}", query);
                return Ok(entry.results.clone());
            }
        }
    }
    
    // Cache miss or expired - fetch fresh results
    tracing::info!("🔍 Cache miss for query: {}, fetching fresh results", query);
    
    // Strategy 1: Try direct channel URL if it looks like a URL
    if query.starts_with("http") || query.starts_with("www.") || query.contains("youtube.com") || query.contains("youtu.be") {
        if let Ok(channel_results) = search_from_url(query, limit).await {
            if !channel_results.is_empty() {
                // Cache the results
                let mut cache = SEARCH_CACHE.write().await;
                cache.insert(cache_key, CacheEntry {
                    results: channel_results.clone(),
                    created_at: Instant::now(),
                });
                return Ok(channel_results);
            }
        }
    }

    // Strategy 2: Try regular video search
    let mut results = search_videos_internal(query, limit).await?;

    // Strategy 3: If we got very few results, also try channel search
    if results.len() < 5 {
        if let Ok(channel_results) = search_channel_videos(query, limit).await {
            for channel_result in channel_results {
                if !results.iter().any(|r| r.id == channel_result.id) {
                    results.push(channel_result);
                }
            }
        }
    }

    // Strategy 4: If still no results, try broader search
    if results.is_empty() {
        if let Ok(broad_results) = search_videos_broad(query, limit).await {
            results = broad_results;
        }
    }

    // Cache the results before returning
    {
        let mut cache = SEARCH_CACHE.write().await;
        cache.insert(cache_key, CacheEntry {
            results: results.clone(),
            created_at: Instant::now(),
        });
    }

    Ok(results)
}

/// Warmup yt-dlp by running a simple search to cache the YouTube extractor
/// This eliminates the ~10-30 second cold start delay on first search
pub async fn warmup() -> Result<()> {
    tracing::info!("🚀 Warming up yt-dlp...");
    
    match timeout(Duration::from_secs(60), search_videos_internal("rust", 1)).await {
        Ok(Ok(_)) => {
            tracing::info!("✅ yt-dlp warmup complete");
            Ok(())
        }
        Ok(Err(e)) => {
            tracing::warn!("⚠️  yt-dlp warmup search failed: {}", e);
            // Don't fail the app startup, just log the warning
            Ok(())
        }
        Err(_) => {
            tracing::warn!("⚠️  yt-dlp warmup timed out after 60 seconds");
            // Don't fail the app startup, just log the warning
            Ok(())
        }
    }
}

/// Clear search cache (useful for testing)
pub async fn clear_search_cache() {
    let mut cache = SEARCH_CACHE.write().await;
    cache.clear();
    tracing::info!("🗑️  Search cache cleared");
}


async fn search_from_url(url: &str, limit: u32) -> Result<Vec<SearchResult>> {
    let limit_str = limit.to_string();
    let args = vec![
        url.to_string(),
        "--flat-playlist".to_string(),
        "--dump-json".to_string(),
        "--playlist-end".to_string(),
        limit_str,
        "--no-warnings".to_string(),
        "--quiet".to_string(),
        "--socket-timeout".to_string(),
        "20".to_string(),
    ];

    match run_yt_dlp_command(args, 20).await {
        Ok(output) => parse_search_results(output.as_bytes()),
        Err(e) => {
            tracing::warn!("⚠️  URL search failed: {}", e);
            Ok(Vec::new())
        }
    }
}

/// Broader search with more results
async fn search_videos_broad(query: &str, limit: u32) -> Result<Vec<SearchResult>> {
    let search_query = format!("ytsearch{}:{}", limit * 3, query);

    let args = vec![
        search_query,
        "--dump-json".to_string(),
        "--no-playlist".to_string(),
        "--skip-download".to_string(),
        "--no-warnings".to_string(),
        "--quiet".to_string(),
        "--socket-timeout".to_string(),
        "20".to_string(),
    ];

    match run_yt_dlp_command(args, 20).await {
        Ok(output) => {
            let mut results = parse_search_results(output.as_bytes())?;
            results.truncate(limit as usize);
            Ok(results)
        }
        Err(e) => {
            tracing::warn!("⚠️  Broad search failed: {}", e);
            Ok(Vec::new())
        }
    }
}

/// Internal video search
async fn search_videos_internal(query: &str, limit: u32) -> Result<Vec<SearchResult>> {
    let search_query = format!("ytsearch{}:{}", limit, query);

    let args = vec![
        search_query,
        "--dump-json".to_string(),
        "--no-playlist".to_string(),
        "--skip-download".to_string(),
        "--no-warnings".to_string(),
        "--quiet".to_string(),
        "--no-call-home".to_string(),
        "--socket-timeout".to_string(),
        "20".to_string(),
        "--extractor-retries".to_string(),
        "3".to_string(),
    ];

    let output = run_yt_dlp_command(args, 30).await?;
    parse_search_results(output.as_bytes())
}

/// Search for videos from a specific channel
async fn search_channel_videos(channel_name: &str, limit: u32) -> Result<Vec<SearchResult>> {
    // Try multiple search strategies for channels

    // Strategy 1: Search for channel directly
    let channel_search = format!("ytsearch{}:{} channel videos", limit, channel_name);

    let args = vec![
        channel_search,
        "--dump-json".to_string(),
        "--no-playlist".to_string(),
        "--skip-download".to_string(),
        "--no-warnings".to_string(),
        "--quiet".to_string(),
        "--socket-timeout".to_string(),
        "20".to_string(),
    ];

    match run_yt_dlp_command(args, 20).await {
        Ok(output) => {
            let mut results = parse_search_results(output.as_bytes())?;

            // Filter to only include videos from channels matching the query
            let query_lower = channel_name.to_lowercase();
            results.retain(|r| {
                let channel_lower = r.channel.to_lowercase();
                // Match if channel name contains query or query contains channel name
                channel_lower.contains(&query_lower) || query_lower.contains(&channel_lower)
            });

            // Limit results
            results.truncate(limit as usize);

            Ok(results)
        }
        Err(e) => {
            tracing::warn!("⚠️  Channel search failed: {}", e);
            Ok(Vec::new())
        }
    }
}

/// Parse yt-dlp JSON output into SearchResult vector
fn parse_search_results(stdout: &[u8]) -> Result<Vec<SearchResult>> {
    let stdout = String::from_utf8_lossy(stdout);
    let mut results = Vec::new();

    for line in stdout.lines() {
        if line.trim().is_empty() {
            continue;
        }

        if let Ok(json) = serde_json::from_str::<serde_json::Value>(line) {
            results.push(SearchResult {
                id: json["id"].as_str().unwrap_or("").to_string(),
                title: json["title"].as_str().unwrap_or("Unknown").to_string(),
                channel: json["uploader"]
                    .as_str()
                    .or(json["channel"].as_str())
                    .or(json["uploader_id"].as_str())
                    .unwrap_or("Unknown")
                    .to_string(),
                duration: json["duration"].as_u64(),
                view_count: json["view_count"].as_u64(),
                thumbnail: json["thumbnail"]
                    .as_str()
                    .or(json["thumbnails"].as_array().and_then(|arr| {
                        arr.last().and_then(|t| t["url"].as_str())
                    }))
                    .unwrap_or("")
                    .to_string(),
            });
        }
    }

    Ok(results)
}

/// Get detailed video information
pub async fn get_video_info(video_id: &str) -> Result<VideoInfo> {
    let url = format!("https://www.youtube.com/watch?v={}", video_id);

    let args = vec![
        url,
        "--dump-json".to_string(),
        "--no-playlist".to_string(),
        "--skip-download".to_string(),
        "--no-warnings".to_string(),
        "--quiet".to_string(),
        "--socket-timeout".to_string(),
        "10".to_string(),
    ];

    let output = run_yt_dlp_command(args, 20).await?;
    let json: serde_json::Value = serde_json::from_str(&output)?;

    Ok(VideoInfo {
        id: json["id"].as_str().unwrap_or("").to_string(),
        title: json["title"].as_str().unwrap_or("Unknown").to_string(),
        description: json["description"].as_str().map(|s| s.to_string()),
        duration: json["duration"].as_u64(),
        view_count: json["view_count"].as_u64(),
        like_count: json["like_count"].as_u64(),
        channel: json["uploader"].as_str().or(json["channel"].as_str()).unwrap_or("Unknown").to_string(),
        channel_id: json["uploader_id"].as_str().or(json["channel_id"].as_str()).unwrap_or("").to_string(),
        thumbnail: json["thumbnail"].as_str().unwrap_or("").to_string(),
        upload_date: json["upload_date"].as_str().map(|s| s.to_string()),
    })
}

/// Get stream URL for video playback
pub async fn get_stream_url(video_id: &str, quality: &str) -> Result<StreamUrl> {
    let url = format!("https://www.youtube.com/watch?v={}", video_id);

    let format = match quality {
        "1080p" => "bestvideo[height<=1080]+bestaudio/best[height<=1080]",
        "720p" => "bestvideo[height<=720]+bestaudio/best[height<=720]",
        "480p" => "bestvideo[height<=480]+bestaudio/best[height<=480]",
        "audio" => "bestaudio",
        _ => "best",
    };

    let args = vec![
        url,
        "-f".to_string(),
        format.to_string(),
        "-g".to_string(),
        "--no-warnings".to_string(),
        "--quiet".to_string(),
        "--socket-timeout".to_string(),
        "10".to_string(),
    ];

    let output = run_yt_dlp_command(args, 25).await?;
    let stream_url = output.trim().to_string();

    if stream_url.is_empty() {
        anyhow::bail!("yt-dlp returned empty stream URL");
    }

    Ok(StreamUrl {
        url: stream_url,
        format: format.to_string(),
        quality: quality.to_string(),
    })
}

/// Download video to specified path
pub async fn download_video(
    video_id: &str,
    output_path: &str,
    quality: &str,
    audio_only: bool,
) -> Result<String> {
    let url = format!("https://www.youtube.com/watch?v={}", video_id);

    let format = if audio_only {
        "bestaudio".to_string()
    } else {
        match quality {
            "1080p" => "bestvideo[height<=1080]+bestaudio/best[height<=1080]".to_string(),
            "720p" => "bestvideo[height<=720]+bestaudio/best[height<=720]".to_string(),
            "480p" => "bestvideo[height<=480]+bestaudio/best[height<=480]".to_string(),
            _ => "best".to_string(),
        }
    };

    let args = vec![
        url,
        "-f".to_string(),
        format,
        "-o".to_string(),
        output_path.to_string(),
    ];

    let _ = run_yt_dlp_command(args, 300).await?;
    Ok(output_path.to_string())
}
