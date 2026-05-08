use anyhow::Result;
use serde::{Deserialize, Serialize};
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
            video_formats.iter()
                .find(|f| {
                    f.resolution.as_deref() == Some("1920x1080") ||
                    f.quality.as_deref() == Some("1080p") || 
                    f.quality.as_deref() == Some("hd1080")
                })
                .copied()
                .or_else(|| {
                    // Fallback to highest available below 1080p
                    video_formats.iter()
                        .filter(|f| f.resolution.is_some())
                        .max_by_key(|f| {
                            f.resolution.as_ref()
                                .and_then(|r| r.split('x').nth(1))
                                .and_then(|h| h.parse::<u32>().ok())
                                .unwrap_or(0)
                        })
                        .copied()
                })
                .or_else(|| video_formats.first().copied())
        }
        "720p" => {
            video_formats.iter()
                .find(|f| {
                    f.resolution.as_deref() == Some("1280x720") ||
                    f.quality.as_deref() == Some("720p") || 
                    f.quality.as_deref() == Some("hd720")
                })
                .copied()
                .or_else(|| video_formats.first().copied())
        }
        "480p" => {
            video_formats.iter()
                .find(|f| {
                    f.resolution.as_deref() == Some("854x480") ||
                    f.resolution.as_deref() == Some("640x480") ||
                    f.quality.as_deref() == Some("480p") || 
                    f.quality.as_deref() == Some("large")
                })
                .copied()
                .or_else(|| video_formats.first().copied())
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
