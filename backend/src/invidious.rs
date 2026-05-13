use anyhow::Result;
use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::sync::Arc;
use tokio::sync::RwLock;

/// Invidious instance configuration
#[derive(Debug, Clone)]
pub struct InvidiousInstance {
    pub url: String,
    pub health: InstanceHealth,
}

#[derive(Debug, Clone, PartialEq)]
pub enum InstanceHealth {
    Healthy,
    Degraded,
    Unhealthy,
}

/// Default Invidious instances (public instances)
/// Updated list with more reliable instances as of 2026
const DEFAULT_INSTANCES: &[&str] = &[
    "https://inv.thepixora.com",
    "https://invidious.fdn.fr",
    "https://inv.nadeko.net",
    "https://invidious.nerdvpn.de",
    "https://vid.puffyan.us",
    "https://yewtu.be",
    "https://invidious.io.lol",
];

lazy_static::lazy_static! {
    static ref CURRENT_INSTANCE: Arc<RwLock<String>> = 
        Arc::new(RwLock::new(DEFAULT_INSTANCES[0].to_string()));
    static ref INSTANCE_INDEX: Arc<RwLock<usize>> = 
        Arc::new(RwLock::new(0));
}

#[derive(Debug, Serialize, Deserialize)]
pub struct InvidiousVideo {
    #[serde(rename = "videoId")]
    pub video_id: String,
    pub title: String,
    pub author: String,
    #[serde(rename = "authorId")]
    pub author_id: String,
    #[serde(rename = "videoThumbnails")]
    pub thumbnails: Vec<InvidiousThumbnail>,
    #[serde(rename = "lengthSeconds")]
    pub length_seconds: u64,
    #[serde(rename = "viewCount")]
    pub view_count: u64,
    #[serde(default)]
    pub description: Option<String>,
    #[serde(default)]
    pub published: Option<u64>,
    #[serde(rename = "publishedText", default)]
    pub published_text: Option<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct InvidiousThumbnail {
    pub url: String,
    pub width: u32,
    pub height: u32,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct InvidiousVideoInfo {
    #[serde(rename = "videoId")]
    pub video_id: String,
    pub title: String,
    pub description: String,
    pub author: String,
    #[serde(rename = "authorId")]
    pub author_id: String,
    #[serde(rename = "lengthSeconds")]
    pub length_seconds: u64,
    #[serde(rename = "viewCount")]
    pub view_count: u64,
    #[serde(rename = "likeCount")]
    pub like_count: Option<u64>,
    #[serde(rename = "formatStreams")]
    pub format_streams: Vec<InvidiousFormat>,
    #[serde(rename = "adaptiveFormats")]
    pub adaptive_formats: Vec<InvidiousFormat>,
    #[serde(default)]
    pub recommended: Option<Vec<InvidiousVideo>>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct InvidiousFormat {
    pub url: String,
    #[serde(rename = "type")]
    pub format_type: String,
    pub quality: Option<String>,
    pub resolution: Option<String>,
    pub bitrate: Option<String>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct InvidiousCommentItem {
    pub author: String,
    pub author_id: String,
    pub author_avatar: String,
    pub content: String,
    pub published_text: String,
    pub like_count: i64,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct InvidiousPlaylist {
    #[serde(rename = "playlistId")]
    pub playlist_id: String,
    pub title: String,
    pub playlist_thumbnail: Option<String>,
    pub author: Option<String>,
    #[serde(rename = "authorId", default)]
    pub author_id: Option<String>,
    #[serde(rename = "videoCount")]
    pub video_count: u32,
    pub videos: Option<Vec<InvidiousVideo>>,
}

/// Search videos using Invidious API
pub async fn search_videos(query: &str, limit: u32) -> Result<Vec<InvidiousVideo>> {
    let instance = CURRENT_INSTANCE.read().await;
    let url = format!("{}/api/v1/search?q={}&type=video", instance, 
        urlencoding::encode(query));
    
    tracing::info!("🔍 Searching Invidious: {} (limit: {})", query, limit);
    
    let client = reqwest::Client::new();
    let response = client
        .get(&url)
        .timeout(std::time::Duration::from_secs(30))
        .send()
        .await?;
    
    if !response.status().is_success() {
        return Err(anyhow::anyhow!("Invidious API error: {}", response.status()));
    }
    
    let videos: Vec<InvidiousVideo> = response.json().await?;
    let limited: Vec<InvidiousVideo> = videos.into_iter().take(limit as usize).collect();
    
    tracing::info!("✅ Found {} results from Invidious", limited.len());
    Ok(limited)
}

pub async fn search_videos_with_filters(
    query: &str,
    limit: u32,
    sort: &str,
    date: &str,
    duration: &str,
) -> Result<Vec<InvidiousVideo>> {
    let instance = CURRENT_INSTANCE.read().await;
    
    let mut params = vec![
        format!("q={}", urlencoding::encode(query)),
        "type=video".to_string(),
        format!("sort={}", urlencoding::encode(sort)),
    ];
    
    // Add optional filter parameters only if not "all" or "any"
    if date != "all" {
        params.push(format!("date={}", urlencoding::encode(date)));
    }
    if duration != "all" {
        params.push(format!("duration={}", urlencoding::encode(duration)));
    }
    
    let url = format!("{}/api/v1/search?{}", instance, params.join("&"));
    
    tracing::info!("🔍 Searching Invidious with filters: {} (sort={}, date={}, duration={}, limit: {})", 
        query, sort, date, duration, limit);
    
    let client = reqwest::Client::new();
    let response = client
        .get(&url)
        .timeout(std::time::Duration::from_secs(30))
        .send()
        .await?;
    
    if !response.status().is_success() {
        return Err(anyhow::anyhow!("Invidious API error: {}", response.status()));
    }
    
    let videos: Vec<InvidiousVideo> = response.json().await?;
    let limited: Vec<InvidiousVideo> = videos.into_iter().take(limit as usize).collect();
    
    tracing::info!("✅ Found {} filtered results from Invidious", limited.len());
    Ok(limited)
}

/// Get video info using Invidious API with automatic instance switching
pub async fn get_video_info(video_id: &str) -> Result<InvidiousVideoInfo> {
    let max_retries = 3;
    let mut last_error = None;
    
    for attempt in 0..max_retries {
        let instance = CURRENT_INSTANCE.read().await.clone();
        let url = format!("{}/api/v1/videos/{}", instance, video_id);
        
        tracing::info!("📹 Fetching video info from Invidious: {} (attempt {}/{})", video_id, attempt + 1, max_retries);
        
        let client = reqwest::Client::new();
        match client
            .get(&url)
            .timeout(std::time::Duration::from_secs(30))
            .send()
            .await
        {
            Ok(response) => {
                if response.status().is_success() {
                    match response.json::<InvidiousVideoInfo>().await {
                        Ok(info) => return Ok(info),
                        Err(e) => {
                            last_error = Some(anyhow::anyhow!("Failed to parse response: {}", e));
                            tracing::warn!("⚠️  Failed to parse Invidious response: {}", e);
                        }
                    }
                } else {
                    last_error = Some(anyhow::anyhow!("Invidious API error: {}", response.status()));
                    tracing::warn!("⚠️  Invidious API error: {}", response.status());
                }
            }
            Err(e) => {
                last_error = Some(anyhow::anyhow!("Request failed: {}", e));
                tracing::warn!("⚠️  Invidious request failed: {}", e);
            }
        }
        
        // Try next instance
        if attempt < max_retries - 1 {
            switch_to_next_instance().await;
        }
    }
    
    Err(last_error.unwrap_or_else(|| anyhow::anyhow!("Failed to get video info after {} attempts", max_retries)))
}

/// Switch to the next Invidious instance
async fn switch_to_next_instance() {
    let mut index = INSTANCE_INDEX.write().await;
    *index = (*index + 1) % DEFAULT_INSTANCES.len();
    let new_instance = DEFAULT_INSTANCES[*index].to_string();
    
    let mut instance = CURRENT_INSTANCE.write().await;
    *instance = new_instance.clone();
    
    tracing::info!("🔄 Switched to Invidious instance: {}", new_instance);
}

/// Get stream URL from Invidious
pub async fn get_stream_url(video_id: &str, quality: &str) -> Result<String> {
    let info = get_video_info(video_id).await?;
    
    tracing::info!("📊 Invidious formats: {} format_streams, {} adaptive_formats", 
        info.format_streams.len(), info.adaptive_formats.len());
    
    // Log all available formats for debugging
    for (i, f) in info.format_streams.iter().enumerate() {
        tracing::debug!("FormatStream {}: quality={:?}, resolution={:?}, type={}", 
            i, f.quality, f.resolution, f.format_type);
    }
    
    // Try format streams first (combined video+audio) - these are best for streaming
    if let Some(format) = find_best_format(&info.format_streams, quality) {
        tracing::info!("✅ Found format stream: quality={:?}, resolution={:?}, type={}", 
            format.quality, format.resolution, format.format_type);
        return Ok(format.url.clone());
    }
    
    // Fallback to adaptive formats (video only or audio only)
    if let Some(format) = find_best_format(&info.adaptive_formats, quality) {
        tracing::warn!("⚠️  Using adaptive format (may be video-only or audio-only): quality={:?}, resolution={:?}, type={}", 
            format.quality, format.resolution, format.format_type);
        return Ok(format.url.clone());
    }
    
    // Last resort: just get the first available format stream (should have both video+audio)
    if let Some(format) = info.format_streams.first() {
        tracing::warn!("⚠️  Using first available format stream as fallback: quality={:?}, type={}", 
            format.quality, format.format_type);
        return Ok(format.url.clone());
    }
    
    Err(anyhow::anyhow!("No suitable format found"))
}

fn find_best_format<'a>(formats: &'a [InvidiousFormat], quality: &str) -> Option<&'a InvidiousFormat> {
    // Log available formats for debugging
    for (i, f) in formats.iter().enumerate() {
        tracing::debug!("Format {}: quality={:?}, resolution={:?}, type={}", 
            i, f.quality, f.resolution, f.format_type);
    }
    
    // For format_streams, prioritize formats that contain both video and audio
    // These typically have "video/mp4" or similar in the type
    let video_formats: Vec<&InvidiousFormat> = formats.iter()
        .filter(|f| {
            let t = f.format_type.to_lowercase();
            t.contains("video") && !t.contains("audio/")
        })
        .collect();
    
    match quality {
        "best" => {
            // For "best", try to find highest quality format with video
            video_formats.iter()
                .filter(|f| f.resolution.is_some())
                .max_by_key(|f| {
                    // Extract height from resolution (e.g., "1920x1080" -> 1080)
                    f.resolution.as_ref()
                        .and_then(|r| r.split('x').nth(1))
                        .and_then(|h| h.parse::<u32>().ok())
                        .unwrap_or(0)
                })
                .copied()
                .or_else(|| video_formats.first().copied())
                .or_else(|| formats.first())
        }
        "1080p" => {
            // Strict: only 1080p and higher
            video_formats.iter()
                .filter(|f| {
                    f.resolution.as_deref() == Some("1920x1080") ||
                    f.quality.as_deref() == Some("1080p") || 
                    f.quality.as_deref() == Some("hd1080") ||
                    // Also accept 2K+ resolutions since they're >= 1080p
                    (f.resolution.is_some() && {
                        f.resolution.as_ref()
                            .and_then(|r| r.split('x').nth(1))
                            .and_then(|h| h.parse::<u32>().ok())
                            .map(|h| h >= 1080)
                            .unwrap_or(false)
                    })
                })
                .max_by_key(|f| {
                    // Prefer highest resolution available
                    f.resolution.as_ref()
                        .and_then(|r| r.split('x').nth(1))
                        .and_then(|h| h.parse::<u32>().ok())
                        .unwrap_or(0)
                })
                .copied()
        }
        "720p" => {
            // Strict: only 720p (not lower, not higher)
            video_formats.iter()
                .filter(|f| {
                    f.resolution.as_deref() == Some("1280x720") ||
                    f.quality.as_deref() == Some("720p") || 
                    f.quality.as_deref() == Some("hd720") ||
                    // Accept 720p range (600-800 height)
                    (f.resolution.is_some() && {
                        let height = f.resolution.as_ref()
                            .and_then(|r| r.split('x').nth(1))
                            .and_then(|h| h.parse::<u32>().ok())
                            .unwrap_or(0);
                        height >= 600 && height <= 800
                    })
                })
                .max_by_key(|f| {
                    f.resolution.as_ref()
                        .and_then(|r| r.split('x').nth(1))
                        .and_then(|h| h.parse::<u32>().ok())
                        .unwrap_or(0)
                })
                .copied()
        }
        "480p" => {
            // Strict: only 480p and below
            video_formats.iter()
                .filter(|f| {
                    f.resolution.as_deref() == Some("854x480") ||
                    f.resolution.as_deref() == Some("640x480") ||
                    f.quality.as_deref() == Some("480p") || 
                    f.quality.as_deref() == Some("large") ||
                    // Accept 480p range (360-540 height)
                    (f.resolution.is_some() && {
                        let height = f.resolution.as_ref()
                            .and_then(|r| r.split('x').nth(1))
                            .and_then(|h| h.parse::<u32>().ok())
                            .unwrap_or(0);
                        height >= 360 && height <= 540
                    })
                })
                .max_by_key(|f| {
                    f.resolution.as_ref()
                        .and_then(|r| r.split('x').nth(1))
                        .and_then(|h| h.parse::<u32>().ok())
                        .unwrap_or(0)
                })
                .copied()
        }
        "audio" => formats.iter().find(|f| f.format_type.contains("audio")),
        _ => video_formats.first().copied().or_else(|| formats.first()),
    }
}

/// Set current Invidious instance
pub async fn set_instance(url: String) {
    let mut instance = CURRENT_INSTANCE.write().await;
    *instance = url;
    tracing::info!("🔄 Switched to Invidious instance: {}", instance);
}

/// Get current instance
pub async fn get_current_instance() -> String {
    CURRENT_INSTANCE.read().await.clone()
}

/// Get list of default instances
pub fn get_default_instances() -> Vec<String> {
    DEFAULT_INSTANCES.iter().map(|s| s.to_string()).collect()
}

/// Get comments for a video using Invidious API.
///
/// This parser is intentionally tolerant because public Invidious instances may
/// differ slightly in response shape.
pub async fn get_comments(video_id: &str) -> Result<Vec<InvidiousCommentItem>> {
    let instance = CURRENT_INSTANCE.read().await.clone();
    let url = format!("{}/api/v1/comments/{}", instance, video_id);

    let client = reqwest::Client::new();
    let response = client
        .get(&url)
        .timeout(std::time::Duration::from_secs(30))
        .send()
        .await?;

    if !response.status().is_success() {
        return Err(anyhow::anyhow!(
            "Invidious comments API error: {}",
            response.status()
        ));
    }

    let value: Value = response.json().await?;

    let raw_comments = value
        .get("comments")
        .and_then(|v| v.as_array())
        .cloned()
        .or_else(|| value.as_array().cloned())
        .unwrap_or_default();

    let comments = raw_comments
        .into_iter()
        .map(|comment| {
            let author = comment
                .get("author")
                .and_then(|v| v.as_str())
                .unwrap_or("Unknown")
                .to_string();

            let author_id = comment
                .get("authorId")
                .or_else(|| comment.get("author_id"))
                .and_then(|v| v.as_str())
                .unwrap_or_default()
                .to_string();

            let author_avatar = comment
                .get("authorThumbnails")
                .and_then(|v| v.as_array())
                .and_then(|arr| arr.first())
                .and_then(|thumb| thumb.get("url"))
                .and_then(|v| v.as_str())
                .unwrap_or_default()
                .to_string();

            let content = comment
                .get("content")
                .or_else(|| comment.get("contentHtml"))
                .and_then(|v| v.as_str())
                .unwrap_or_default()
                .to_string();

            let published_text = comment
                .get("publishedText")
                .or_else(|| comment.get("published"))
                .and_then(|v| v.as_str())
                .unwrap_or_default()
                .to_string();

            let like_count = comment
                .get("likeCount")
                .or_else(|| comment.get("likes"))
                .and_then(|v| v.as_i64())
                .unwrap_or(0);

            InvidiousCommentItem {
                author,
                author_id,
                author_avatar,
                content,
                published_text,
                like_count,
            }
        })
        .collect();

    Ok(comments)
}

#[derive(Debug, Serialize, Deserialize)]
pub struct InvidiousChannelInfo {
    pub author: String,
    pub author_id: String,
    pub author_banners: Vec<InvidiousThumbnail>,
    pub author_thumbnails: Vec<InvidiousThumbnail>,
    pub sub_count: u64,
    pub description: String,
}

pub async fn get_channel_info(channel_id: &str) -> Result<InvidiousChannelInfo> {
    let instance = CURRENT_INSTANCE.read().await.clone();
    let url = format!("{}/api/v1/channels/{}", instance, channel_id);

    tracing::info!("📺 Fetching channel info from Invidious: {}", channel_id);

    let client = reqwest::Client::new();
    let response = client
        .get(&url)
        .timeout(std::time::Duration::from_secs(30))
        .send()
        .await?;

    if !response.status().is_success() {
        return Err(anyhow::anyhow!("Invidious API error: {}", response.status()));
    }

    let info: InvidiousChannelInfo = response.json().await?;
    Ok(info)
}

pub async fn get_channel_videos(channel_id: &str, page: u32) -> Result<Vec<InvidiousVideo>> {
    let instance = CURRENT_INSTANCE.read().await.clone();
    let url = format!("{}/api/v1/channels/{}/videos?page={}", instance, channel_id, page);

    tracing::info!("📺 Fetching channel videos from Invidious: {}", channel_id);

    let client = reqwest::Client::new();
    let response = client
        .get(&url)
        .timeout(std::time::Duration::from_secs(30))
        .send()
        .await?;

    if !response.status().is_success() {
        return Err(anyhow::anyhow!("Invidious API error: {}", response.status()));
    }

    let videos: Vec<InvidiousVideo> = response.json().await?;
    Ok(videos)
}

pub async fn get_trending(region: Option<&str>, trend_type: Option<&str>) -> Result<Vec<InvidiousVideo>> {
    let instance = CURRENT_INSTANCE.read().await.clone();
    let mut url = format!("{}/api/v1/trending", instance);

    let mut params = Vec::new();
    if let Some(region) = region.filter(|value| !value.trim().is_empty()) {
        params.push(format!("region={}", urlencoding::encode(region.trim())));
    }
    if let Some(trend_type) = trend_type.filter(|value| !value.trim().is_empty()) {
        params.push(format!("type={}", urlencoding::encode(trend_type.trim())));
    }
    if !params.is_empty() {
        url.push('?');
        url.push_str(&params.join("&"));
    }

    tracing::info!("📈 Fetching trending videos from Invidious");

    let client = reqwest::Client::new();
    let response = client
        .get(&url)
        .timeout(std::time::Duration::from_secs(30))
        .send()
        .await?;

    if !response.status().is_success() {
        return Err(anyhow::anyhow!("Invidious API error: {}", response.status()));
    }

    let videos: Vec<InvidiousVideo> = response.json().await?;
    Ok(videos)
}

pub async fn get_recommended(video_id: &str, limit: u32) -> Result<Vec<InvidiousVideo>> {
    // Fetch the video info which includes recommended videos from Invidious
    let video_info = get_video_info(video_id).await?;
    
    let recommended: Vec<InvidiousVideo> = video_info
        .recommended
        .unwrap_or_default()
        .into_iter()
        .take(limit as usize)
        .collect();
    
    tracing::info!("📌 Retrieved {} recommended videos for {}", recommended.len(), video_id);
    Ok(recommended)
}

pub async fn get_playlist(playlist_id: &str, page: u32) -> Result<InvidiousPlaylist> {
    let instance = CURRENT_INSTANCE.read().await.clone();
    let url = format!(
        "{}/api/v1/playlists/{}?page={}",
        instance,
        urlencoding::encode(playlist_id),
        page
    );
    
    tracing::info!("📋 Fetching playlist from Invidious: {} (page: {})", playlist_id, page);
    
    let client = reqwest::Client::new();
    let response = client
        .get(&url)
        .timeout(std::time::Duration::from_secs(30))
        .send()
        .await?;
    
    if !response.status().is_success() {
        return Err(anyhow::anyhow!("Invidious API error: {}", response.status()));
    }
    
    let playlist: InvidiousPlaylist = response.json().await?;
    tracing::info!("✅ Fetched playlist: {} with {} videos", playlist.title, playlist.video_count);
    Ok(playlist)
}
