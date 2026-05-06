use anyhow::{Context, Result};
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

/// Global search results cache
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
    let search_future = async {
        Command::new("yt-dlp")
            .arg(url)
            .arg("--flat-playlist")
            .arg("--dump-json")
            .arg("--playlist-end")
            .arg(limit.to_string())
            .arg("--no-warnings")
            .arg("--quiet")
            .arg("--socket-timeout")
            .arg("20")
            .output()
    };

    let output = match timeout(Duration::from_secs(20), search_future).await {
        Ok(Ok(output)) => output,
        Ok(Err(e)) => {
            eprintln!("⚠️  URL search failed: {}", e);
            return Ok(Vec::new());
        }
        Err(_) => {
            eprintln!("⚠️  URL search timed out after 20 seconds");
            return Ok(Vec::new());
        }
    };

    if !output.status.success() {
        return Ok(Vec::new());
    }

    parse_search_results(&output.stdout)
}

/// Broader search with more results
async fn search_videos_broad(query: &str, limit: u32) -> Result<Vec<SearchResult>> {
    let search_query = format!("ytsearch{}:{}", limit * 3, query);

    let search_future = async {
        Command::new("yt-dlp")
            .arg(&search_query)
            .arg("--dump-json")
            .arg("--no-playlist")
            .arg("--skip-download")
            .arg("--no-warnings")
            .arg("--quiet")
            .arg("--socket-timeout")
            .arg("20")
            .output()
    };

    let output = match timeout(Duration::from_secs(20), search_future).await {
        Ok(Ok(output)) => output,
        Ok(Err(e)) => {
            eprintln!("⚠️  Broad search failed: {}", e);
            return Ok(Vec::new());
        }
        Err(_) => {
            eprintln!("⚠️  Broad search timed out after 20 seconds");
            return Ok(Vec::new());
        }
    };

    if !output.status.success() {
        return Ok(Vec::new());
    }

    let mut results = parse_search_results(&output.stdout)?;
    results.truncate(limit as usize);
    Ok(results)
}

/// Internal video search
async fn search_videos_internal(query: &str, limit: u32) -> Result<Vec<SearchResult>> {
    let search_query = format!("ytsearch{}:{}", limit, query);

    let search_future = async {
        Command::new("yt-dlp")
            .arg(&search_query)
            .arg("--dump-json")
            .arg("--no-playlist")
            .arg("--skip-download")
            .arg("--no-warnings")
            .arg("--quiet")
            .arg("--no-call-home")
            .arg("--socket-timeout")
            .arg("20")
            .arg("--extractor-retries")
            .arg("3")
            .output()
    };

    let output = match timeout(Duration::from_secs(20), search_future).await {
        Ok(Ok(output)) => output,
        Ok(Err(e)) => {
            anyhow::bail!("Failed to execute yt-dlp: {}", e);
        }
        Err(_) => {
            anyhow::bail!("yt-dlp search timed out after 20 seconds - network may be slow or yt-dlp not responding");
        }
    };

    if !output.status.success() {
        let error = String::from_utf8_lossy(&output.stderr);
        anyhow::bail!("yt-dlp search failed: {}", error);
    }

    parse_search_results(&output.stdout)
}

/// Search for videos from a specific channel
async fn search_channel_videos(channel_name: &str, limit: u32) -> Result<Vec<SearchResult>> {
    // Try multiple search strategies for channels

    // Strategy 1: Search for channel directly
    let channel_search = format!("ytsearch{}:{} channel videos", limit, channel_name);

    let search_future = async {
        Command::new("yt-dlp")
            .arg(&channel_search)
            .arg("--dump-json")
            .arg("--no-playlist")
            .arg("--skip-download")
            .arg("--no-warnings")
            .arg("--quiet")
            .arg("--socket-timeout")
            .arg("20")
            .output()
    };

    let output = match timeout(Duration::from_secs(20), search_future).await {
        Ok(Ok(output)) => output,
        Ok(Err(e)) => {
            eprintln!("⚠️  Channel search failed: {}", e);
            return Ok(Vec::new());
        }
        Err(_) => {
            eprintln!("⚠️  Channel search timed out after 20 seconds");
            return Ok(Vec::new());
        }
    };

    if !output.status.success() {
        return Ok(Vec::new());
    }

    let mut results = parse_search_results(&output.stdout)?;

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

    let info_future = async {
        Command::new("yt-dlp")
            .arg(&url)
            .arg("--dump-json")
            .arg("--no-playlist")
            .arg("--skip-download")
            .arg("--no-warnings")
            .arg("--quiet")
            .arg("--socket-timeout")
            .arg("10")
            .output()
    };

    let output = match timeout(Duration::from_secs(20), info_future).await {
        Ok(Ok(output)) => output,
        Ok(Err(e)) => {
            anyhow::bail!("Failed to execute yt-dlp: {}", e);
        }
        Err(_) => {
            anyhow::bail!("yt-dlp timed out after 20 seconds - unable to fetch video info");
        }
    };

    if !output.status.success() {
        let error = String::from_utf8_lossy(&output.stderr);
        anyhow::bail!("yt-dlp failed: {}", error);
    }

    let stdout = String::from_utf8_lossy(&output.stdout);
    let json: serde_json::Value = serde_json::from_str(&stdout)?;

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

    let stream_future = async {
        Command::new("yt-dlp")
            .arg(&url)
            .arg("-f")
            .arg(format)
            .arg("-g")
            .arg("--no-warnings")
            .arg("--quiet")
            .arg("--socket-timeout")
            .arg("10")
            .output()
    };

    let output = match timeout(Duration::from_secs(20), stream_future).await {
        Ok(Ok(output)) => output,
        Ok(Err(e)) => {
            anyhow::bail!("Failed to execute yt-dlp: {}", e);
        }
        Err(_) => {
            anyhow::bail!("yt-dlp timed out after 20 seconds - unable to fetch stream URL");
        }
    };

    if !output.status.success() {
        let error = String::from_utf8_lossy(&output.stderr);
        anyhow::bail!("yt-dlp failed: {}", error);
    }

    let stream_url = String::from_utf8_lossy(&output.stdout).trim().to_string();

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
        "bestaudio"
    } else {
        match quality {
            "1080p" => "bestvideo[height<=1080]+bestaudio/best[height<=1080]",
            "720p" => "bestvideo[height<=720]+bestaudio/best[height<=720]",
            "480p" => "bestvideo[height<=480]+bestaudio/best[height<=480]",
            _ => "best",
        }
    };

    let download_future = async {
        Command::new("yt-dlp")
            .arg(&url)
            .arg("-f")
            .arg(format)
            .arg("-o")
            .arg(output_path)
            .output()
    };

    let output = match timeout(Duration::from_secs(120), download_future).await {
        Ok(Ok(output)) => output,
        Ok(Err(e)) => {
            anyhow::bail!("Failed to execute yt-dlp: {}", e);
        }
        Err(_) => {
            anyhow::bail!("yt-dlp timed out after 120 seconds - download taking too long");
        }
    };

    if !output.status.success() {
        let error = String::from_utf8_lossy(&output.stderr);
        anyhow::bail!("Download failed: {}", error);
    }

    Ok(output_path.to_string())
}
