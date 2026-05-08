use anyhow::Result;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::env;
use std::path::Path;
use std::sync::Arc;
use std::time::Instant;
use tokio::sync::RwLock;
use tokio::time::Duration;

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

/// Search for videos using rusty_ytdl
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
    
    let results = search_videos_internal(query, limit).await?;

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

/// Warmup function
pub async fn warmup() -> Result<()> {
    tracing::info!("✅ rusty_ytdl ready");
    Ok(())
}

/// Clear search cache
pub async fn clear_search_cache() {
    let mut cache = SEARCH_CACHE.write().await;
    cache.clear();
    tracing::info!("🗑️  Search cache cleared");
}

/// Internal video search using rusty_ytdl
async fn search_videos_internal(query: &str, limit: u32) -> Result<Vec<SearchResult>> {
    use rusty_ytdl::search::{YouTube, SearchOptions, SearchType};
    
    tracing::info!("🔎 Searching YouTube for: {} (limit: {})", query, limit);
    
    let youtube = YouTube::new().map_err(|e| anyhow::anyhow!("Failed to create YouTube client: {:?}", e))?;
    
    let search_options = SearchOptions {
        limit: limit as u64,
        search_type: SearchType::Video,
        safe_search: false,
    };

    let results = youtube
        .search(query, Some(&search_options))
        .await
        .map_err(|e| anyhow::anyhow!("Search failed: {:?}", e))?;

    let mut search_results = Vec::new();
    
    for item in results.iter().take(limit as usize) {
        // rusty_ytdl SearchResult has different fields
        match item {
            rusty_ytdl::search::SearchResult::Video(video) => {
                search_results.push(SearchResult {
                    id: video.id.clone(),
                    title: video.title.clone(),
                    channel: video.channel.name.clone(),
                    duration: Some(video.duration),
                    view_count: Some(video.views),
                    thumbnail: video.thumbnails.first()
                        .map(|t| t.url.clone())
                        .unwrap_or_default(),
                });
            }
            _ => continue, // Skip non-video results
        }
    }

    tracing::info!("✅ Found {} results", search_results.len());
    Ok(search_results)
}

/// Get detailed video information
pub async fn get_video_info(video_id: &str) -> Result<VideoInfo> {
    use rusty_ytdl::{Video, VideoOptions};
    
    tracing::info!("📹 Fetching video info for: {}", video_id);
    
    let url = format!("https://www.youtube.com/watch?v={}", video_id);
    
    let video = Video::new_with_options(&url, VideoOptions::default())
        .map_err(|e| anyhow::anyhow!("Failed to create video: {:?}", e))?;

    let info = video.get_info().await
        .map_err(|e| anyhow::anyhow!("Failed to get video info: {:?}", e))?;

    let details = &info.video_details;
    
    Ok(VideoInfo {
        id: details.video_id.clone(),
        title: details.title.clone(),
        description: Some(details.description.clone()),
        duration: details.length_seconds.parse::<u64>().ok(),
        view_count: details.view_count.parse::<u64>().ok(),
        like_count: None,
        channel: details.author.as_ref().map(|a| a.name.clone()).unwrap_or_else(|| "Unknown".to_string()),
        channel_id: details.channel_id.clone(),
        thumbnail: details.thumbnails.first()
            .map(|t| t.url.clone())
            .unwrap_or_default(),
        upload_date: Some(details.publish_date.clone()),
    })
}

/// Get stream URL with automatic fallback (yt-dlp -> Invidious -> rusty_ytdl)
pub async fn get_stream_url(video_id: &str, quality: &str) -> Result<StreamUrl> {
    tracing::info!("🎬 Getting stream URL for: {} (quality: {})", video_id, quality);

    match try_stream_url_sources(video_id, quality).await {
        Ok(stream) => Ok(stream),
        Err(primary_error) => {
            if quality != "best" {
                tracing::warn!(
                    "⚠️  Requested quality '{}' failed for {}. Retrying with 'best'.",
                    quality,
                    video_id
                );

                match try_stream_url_sources(video_id, "best").await {
                    Ok(stream) => {
                        tracing::info!(
                            "✅ Fallback to 'best' quality succeeded for {} (requested '{}')",
                            video_id,
                            quality
                        );
                        Ok(stream)
                    }
                    Err(fallback_error) => Err(anyhow::anyhow!(
                        "Failed to get stream URL (requested '{}': {}; fallback 'best': {})",
                        quality,
                        primary_error,
                        fallback_error
                    )),
                }
            } else {
                Err(primary_error)
            }
        }
    }
}

async fn try_stream_url_sources(video_id: &str, quality: &str) -> Result<StreamUrl> {
    // Try yt-dlp command first (best at bypassing YouTube restrictions)
    let yt_dlp_error = match get_stream_url_ytdlp_command(video_id, quality).await {
        Ok(stream) => {
            tracing::info!("✅ Got stream URL from yt-dlp command");
            return Ok(stream);
        }
        Err(e) => {
            tracing::warn!("⚠️  yt-dlp command failed: {}", e);
            e
        }
    };

    // Try Invidious second
    let invidious_error = match get_stream_url_invidious(video_id, quality).await {
        Ok(url) => {
            tracing::info!("✅ Got stream URL from Invidious");
            return Ok(StreamUrl {
                url,
                format: "video/mp4".to_string(),
                quality: quality.to_string(),
            });
        }
        Err(e) => {
            tracing::warn!("⚠️  Invidious failed: {}", e);
            e
        }
    };

    // Last resort: try rusty_ytdl
    match get_stream_url_rusty_ytdl(video_id, quality).await {
        Ok(stream) => {
            tracing::info!("✅ Got stream URL from rusty_ytdl fallback");
            Ok(stream)
        }
        Err(rusty_ytdl_error) => {
            tracing::error!(
                "❌ All methods failed (yt-dlp, Invidious, rusty_ytdl): yt-dlp={}, invidious={}, rusty_ytdl={}",
                yt_dlp_error,
                invidious_error,
                rusty_ytdl_error
            );
            Err(anyhow::anyhow!(
                "Failed to get stream URL from all sources (yt-dlp: {}; invidious: {}; rusty_ytdl: {})",
                yt_dlp_error,
                invidious_error,
                rusty_ytdl_error
            ))
        }
    }
}

/// Get stream URL using Invidious (secondary method)
async fn get_stream_url_invidious(video_id: &str, quality: &str) -> Result<String> {
    use crate::invidious;
    invidious::get_stream_url(video_id, quality).await
}

fn ytdlp_format_selector(quality: &str) -> &'static str {
    match quality {
        "audio" => "bestaudio[ext=m4a]/bestaudio",
        "1080p" => "best[height<=1080][vcodec!=none][acodec!=none]/best[height<=1080]/best",
        "720p" => "best[height<=720][vcodec!=none][acodec!=none]/best[height<=720]/best",
        "480p" => "best[height<=480][vcodec!=none][acodec!=none]/best[height<=480]/best",
        _ => "best[vcodec!=none][acodec!=none]/best",
    }
}

fn ytdlp_user_agent() -> Option<String> {
    env::var("TUBULAR_YTDLP_USER_AGENT")
        .ok()
        .map(|value| value.trim().to_string())
        .filter(|value| !value.is_empty())
}

fn ytdlp_cookies_path() -> Option<String> {
    let path = env::var("TUBULAR_YTDLP_COOKIES")
        .ok()
        .map(|value| value.trim().to_string())
        .filter(|value| !value.is_empty())?;

    if Path::new(&path).exists() {
        Some(path)
    } else {
        tracing::warn!("⚠️  TUBULAR_YTDLP_COOKIES path does not exist: {}", path);
        None
    }
}

fn ytdlp_auth_hint(stderr: &str, cookies_path: Option<&str>) -> Option<&'static str> {
    let lowered = stderr.to_lowercase();
    if lowered.contains("sign in")
        || lowered.contains("confirm you're not a bot")
        || lowered.contains("cookies")
        || lowered.contains("account required")
    {
        return if cookies_path.is_some() {
            Some("cookies were supplied but yt-dlp still failed; re-export cookies or update yt-dlp")
        } else {
            Some("set TUBULAR_YTDLP_COOKIES to a browser cookies.txt export for restricted videos")
        };
    }

    if lowered.contains("http error 429") || lowered.contains("too many requests") {
        return Some("rate limited by YouTube; try again later or use cookies")
    }

    None
}

fn parse_stream_url_from_ytdlp_stdout(stdout: &str) -> Option<String> {
    stdout
        .lines()
        .map(str::trim)
        .find(|line| line.starts_with("http://") || line.starts_with("https://"))
        .map(ToString::to_string)
}

/// Get stream URL using yt-dlp command (primary method)
async fn get_stream_url_ytdlp_command(video_id: &str, quality: &str) -> Result<StreamUrl> {
    use tokio::process::Command;
    
    let url = format!("https://www.youtube.com/watch?v={}", video_id);
    let format_selector = ytdlp_format_selector(quality);
    let cookies_path = ytdlp_cookies_path();
    let user_agent = ytdlp_user_agent();
    
    tracing::info!("🎬 Running yt-dlp command for: {}", video_id);

    let mut attempts: Vec<(&str, Vec<&str>)> = vec![
        ("default", Vec::new()),
        (
            "android client",
            vec!["--extractor-args", "youtube:player_client=android"],
        ),
    ];

    if cookies_path.is_none() {
        attempts.push(("firefox cookies", vec!["--cookies-from-browser", "firefox"]));
        attempts.push(("chrome cookies", vec!["--cookies-from-browser", "chrome"]));
    }

    let mut last_error = None;

    for (attempt_name, extra_args) in attempts {
        let mut cmd = Command::new("yt-dlp");
        cmd.arg("--no-warnings")
            .arg("--no-playlist")
            .arg("--get-url")
            .arg("-f")
            .arg(format_selector);

        if let Some(ref ua) = user_agent {
            cmd.arg("--user-agent").arg(ua);
        }

        if let Some(ref cookies) = cookies_path {
            cmd.arg("--cookies").arg(cookies);
        }

        for arg in extra_args {
            cmd.arg(arg);
        }

        cmd.arg(&url);

        let output = match cmd.output().await {
            Ok(output) => output,
            Err(e) => {
                let err = anyhow::anyhow!("{} attempt failed to execute yt-dlp: {}", attempt_name, e);
                tracing::warn!("⚠️  {}", err);
                last_error = Some(err);
                continue;
            }
        };

        if !output.status.success() {
            let stderr = String::from_utf8_lossy(&output.stderr).trim().to_string();
            let mut details = if stderr.is_empty() {
                "no stderr output".to_string()
            } else {
                stderr
            };

            if let Some(hint) = ytdlp_auth_hint(&details, cookies_path.as_deref()) {
                details = format!("{} | hint: {}", details, hint);
            }

            let err = anyhow::anyhow!(
                "{} attempt failed (status {}): {}",
                attempt_name,
                output.status,
                details
            );
            tracing::warn!("⚠️  {}", err);
            last_error = Some(err);
            continue;
        }

        let stdout = String::from_utf8_lossy(&output.stdout);
        let stream_url = match parse_stream_url_from_ytdlp_stdout(&stdout) {
            Some(url) => url,
            None => {
                let err = anyhow::anyhow!("{} attempt returned no stream URL", attempt_name);
                tracing::warn!("⚠️  {}", err);
                last_error = Some(err);
                continue;
            }
        };

        tracing::info!(
            "✅ Got stream URL from yt-dlp ({}, url length: {})",
            attempt_name,
            stream_url.len()
        );

        return Ok(StreamUrl {
            url: stream_url,
            format: if quality == "audio" {
                "audio/mp4".to_string()
            } else {
                "video/mp4".to_string()
            },
            quality: quality.to_string(),
        });
    }

    Err(last_error.unwrap_or_else(|| anyhow::anyhow!("all yt-dlp attempts failed")))
}

/// Get stream URL using rusty_ytdl (fallback)
async fn get_stream_url_rusty_ytdl(video_id: &str, quality: &str) -> Result<StreamUrl> {
    use rusty_ytdl::{Video, VideoOptions};
    
    tracing::info!("🎬 Getting stream URL for: {} (quality: {})", video_id, quality);
    
    let url = format!("https://www.youtube.com/watch?v={}", video_id);
    
    let video = Video::new_with_options(&url, VideoOptions::default())
        .map_err(|e| anyhow::anyhow!("Failed to create video: {:?}", e))?;

    let info = video.get_info().await
        .map_err(|e| anyhow::anyhow!("Failed to get video info: {:?}", e))?;

    // Find best format based on quality
    // For streaming, prioritize formats with both video and audio
    let format = match quality {
        "audio" => {
            // Get best audio-only format
            info.formats.iter()
                .filter(|f| f.has_audio && !f.has_video)
                .max_by_key(|f| f.audio_bitrate.unwrap_or(0))
        }
        "1080p" => {
            // Try combined format first (video+audio), then video-only
            info.formats.iter()
                .filter(|f| f.has_video && f.has_audio && f.height.unwrap_or(0) <= 1080 && f.height.unwrap_or(0) >= 720)
                .max_by_key(|f| f.height.unwrap_or(0))
                .or_else(|| {
                    info.formats.iter()
                        .filter(|f| f.has_video && f.height.unwrap_or(0) <= 1080)
                        .max_by_key(|f| f.height.unwrap_or(0))
                })
        }
        "720p" => {
            info.formats.iter()
                .filter(|f| f.has_video && f.has_audio && f.height.unwrap_or(0) <= 720 && f.height.unwrap_or(0) >= 480)
                .max_by_key(|f| f.height.unwrap_or(0))
                .or_else(|| {
                    info.formats.iter()
                        .filter(|f| f.has_video && f.height.unwrap_or(0) <= 720)
                        .max_by_key(|f| f.height.unwrap_or(0))
                })
        }
        "480p" => {
            info.formats.iter()
                .filter(|f| f.has_video && f.has_audio && f.height.unwrap_or(0) <= 480 && f.height.unwrap_or(0) >= 360)
                .max_by_key(|f| f.height.unwrap_or(0))
                .or_else(|| {
                    info.formats.iter()
                        .filter(|f| f.has_video && f.height.unwrap_or(0) <= 480)
                        .max_by_key(|f| f.height.unwrap_or(0))
                })
        }
        _ => {
            // Get best combined format (video + audio)
            info.formats.iter()
                .filter(|f| f.has_video && f.has_audio)
                .max_by_key(|f| (f.height.unwrap_or(0), f.bitrate))
                .or_else(|| {
                    // Fallback to any video format
                    info.formats.iter()
                        .filter(|f| f.has_video)
                        .max_by_key(|f| f.height.unwrap_or(0))
                })
        }
    };

    let format = format.ok_or_else(|| anyhow::anyhow!("No suitable format found"))?;

    if format.url.is_empty() {
        return Err(anyhow::anyhow!("Format URL is empty"));
    }

    tracing::info!("✅ Found format: height={:?}, has_audio={}, has_video={}, url_len={}", 
        format.height, format.has_audio, format.has_video, format.url.len());

    Ok(StreamUrl {
        url: format.url.clone(),
        format: format!("{:?}", format.mime_type),
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
    use rusty_ytdl::{Video, VideoOptions};
    
    tracing::info!("⬇️  Downloading video: {} to {}", video_id, output_path);
    
    let url = format!("https://www.youtube.com/watch?v={}", video_id);
    
    let video = Video::new_with_options(&url, VideoOptions::default())
        .map_err(|e| anyhow::anyhow!("Failed to create video: {:?}", e))?;

    let info = video.get_info().await
        .map_err(|e| anyhow::anyhow!("Failed to get video info: {:?}", e))?;

    // Find best format
    let format = if audio_only {
        info.formats.iter()
            .filter(|f| f.has_audio && !f.has_video)
            .max_by_key(|f| f.audio_bitrate.unwrap_or(0))
    } else {
        match quality {
            "1080p" => info.formats.iter()
                .filter(|f| f.has_video && f.height.unwrap_or(0) <= 1080)
                .max_by_key(|f| f.height.unwrap_or(0)),
            "720p" => info.formats.iter()
                .filter(|f| f.has_video && f.height.unwrap_or(0) <= 720)
                .max_by_key(|f| f.height.unwrap_or(0)),
            "480p" => info.formats.iter()
                .filter(|f| f.has_video && f.height.unwrap_or(0) <= 480)
                .max_by_key(|f| f.height.unwrap_or(0)),
            _ => info.formats.iter()
                .filter(|f| f.has_video)
                .max_by_key(|f| f.height.unwrap_or(0)),
        }
    };

    let format = format.ok_or_else(|| anyhow::anyhow!("No suitable format found"))?;

    // Download the video
    let client = reqwest::Client::new();
    let response = client.get(&format.url).send().await
        .map_err(|e| anyhow::anyhow!("Failed to download: {}", e))?;

    let bytes = response.bytes().await
        .map_err(|e| anyhow::anyhow!("Failed to read response: {}", e))?;

    tokio::fs::write(output_path, bytes).await
        .map_err(|e| anyhow::anyhow!("Failed to write file: {}", e))?;

    tracing::info!("✅ Download complete: {}", output_path);
    Ok(output_path.to_string())
}
