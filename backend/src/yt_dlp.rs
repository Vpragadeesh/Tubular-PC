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

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct SubtitleTrack {
    pub language: String,
    pub language_name: String,
    pub url: String,
    pub ext: String,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Chapter {
    pub title: String,
    pub start_time: u64,  // in seconds
    pub end_time: Option<u64>,
    pub thumbnail: Option<String>,
}

/// Get available subtitles for a video using yt-dlp JSON metadata
pub async fn get_subtitles(video_id: &str) -> Result<Vec<SubtitleTrack>> {
    use tokio::process::Command;

    let url = format!("https://www.youtube.com/watch?v={}", video_id);

    tracing::info!("📝 Fetching subtitles for: {}", video_id);

    let mut cmd = Command::new("yt-dlp");
    cmd.arg("--no-warnings")
        .arg("--no-playlist")
        .arg("--skip-download")
        .arg("-j")  // dump JSON metadata
        .arg(&url);

    let output = cmd.output().await
        .map_err(|e| anyhow::anyhow!("Failed to execute yt-dlp for subtitles: {}", e))?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        return Err(anyhow::anyhow!("yt-dlp subtitle fetch failed: {}", stderr));
    }

    let stdout = String::from_utf8_lossy(&output.stdout);
    let json: serde_json::Value = serde_json::from_str(&stdout)
        .map_err(|e| anyhow::anyhow!("Failed to parse yt-dlp JSON: {}", e))?;

    let mut tracks = Vec::new();

    // Parse "subtitles" (manually uploaded captions)
    if let Some(subs) = json.get("subtitles").and_then(|s| s.as_object()) {
        for (lang, entries) in subs {
            if let Some(arr) = entries.as_array() {
                // Prefer vtt format, fallback to first available
                let vtt_entry = arr.iter().find(|e| {
                    e.get("ext").and_then(|v| v.as_str()) == Some("vtt")
                });
                let entry = vtt_entry.or_else(|| arr.first());

                if let Some(entry) = entry {
                    if let Some(url) = entry.get("url").and_then(|u| u.as_str()) {
                        let ext = entry.get("ext").and_then(|v| v.as_str()).unwrap_or("vtt");
                        let lang_name = entry.get("name").and_then(|v| v.as_str()).unwrap_or(lang.as_str());
                        tracks.push(SubtitleTrack {
                            language: lang.clone(),
                            language_name: lang_name.to_string(),
                            url: url.to_string(),
                            ext: ext.to_string(),
                        });
                    }
                }
            }
        }
    }

    // Parse "automatic_captions" (auto-generated)
    if let Some(auto_caps) = json.get("automatic_captions").and_then(|s| s.as_object()) {
        // Only include auto captions for common languages to avoid hundreds of entries
        let common_langs = ["en", "es", "fr", "de", "pt", "ja", "ko", "zh", "hi", "ar", "ru", "it"];
        for (lang, entries) in auto_caps {
            if !common_langs.contains(&lang.as_str()) {
                continue;
            }
            // Skip if we already have a manual subtitle for this language
            if tracks.iter().any(|t| t.language == *lang) {
                continue;
            }
            if let Some(arr) = entries.as_array() {
                let vtt_entry = arr.iter().find(|e| {
                    e.get("ext").and_then(|v| v.as_str()) == Some("vtt")
                });
                let entry = vtt_entry.or_else(|| arr.first());

                if let Some(entry) = entry {
                    if let Some(url) = entry.get("url").and_then(|u| u.as_str()) {
                        let ext = entry.get("ext").and_then(|v| v.as_str()).unwrap_or("vtt");
                        let lang_name = entry.get("name").and_then(|v| v.as_str())
                            .map(|n| format!("{} (auto)", n))
                            .unwrap_or_else(|| format!("{} (auto)", lang));
                        tracks.push(SubtitleTrack {
                            language: lang.clone(),
                            language_name: lang_name,
                            url: url.to_string(),
                            ext: ext.to_string(),
                        });
                    }
                }
            }
        }
    }

    tracing::info!("📝 Found {} subtitle tracks for {}", tracks.len(), video_id);
    Ok(tracks)
}

/// Get video chapters using yt-dlp JSON metadata
pub async fn get_chapters(video_id: &str) -> Result<Vec<Chapter>> {
    use tokio::process::Command;

    let url = format!("https://www.youtube.com/watch?v={}", video_id);

    tracing::info!("📚 Fetching chapters for: {}", video_id);

    let mut cmd = Command::new("yt-dlp");
    cmd.arg("--no-warnings")
        .arg("--no-playlist")
        .arg("--skip-download")
        .arg("-j")  // dump JSON metadata
        .arg(&url);

    let output = cmd.output().await
        .map_err(|e| anyhow::anyhow!("Failed to execute yt-dlp for chapters: {}", e))?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        return Err(anyhow::anyhow!("yt-dlp chapter fetch failed: {}", stderr));
    }

    let stdout = String::from_utf8_lossy(&output.stdout);
    let json: serde_json::Value = serde_json::from_str(&stdout)
        .map_err(|e| anyhow::anyhow!("Failed to parse yt-dlp JSON: {}", e))?;

    let mut chapters = Vec::new();

    // Extract chapters from JSON
    if let Some(chapters_arr) = json.get("chapters").and_then(|c| c.as_array()) {
        for chapter in chapters_arr {
            if let Some(title) = chapter.get("title").and_then(|t| t.as_str()) {
                if let Some(start_time) = chapter.get("start_time").and_then(|t| t.as_u64()) {
                    let end_time = chapter.get("end_time").and_then(|t| t.as_u64());
                    let thumbnail = chapter.get("image").and_then(|i| i.as_str()).map(|s| s.to_string());
                    
                    chapters.push(Chapter {
                        title: title.to_string(),
                        start_time,
                        end_time,
                        thumbnail,
                    });
                }
            }
        }
    }

    tracing::info!("📚 Found {} chapters for {}", chapters.len(), video_id);
    Ok(chapters)
}

#[derive(Debug, Serialize, Deserialize)]
pub struct SubtitleSearchResult {
    pub text: String,
    pub start_time: f64,  // in seconds
    pub end_time: f64,
    pub line_number: u32,
}

/// Search within subtitle text for a query string
pub async fn search_subtitles(video_id: &str, query: &str) -> Result<Vec<SubtitleSearchResult>> {
    use tokio::process::Command;

    if query.is_empty() {
        return Ok(Vec::new());
    }

    let url = format!("https://www.youtube.com/watch?v={}", video_id);
    let query_lower = query.to_lowercase();

    tracing::info!("🔍 Searching subtitles for: {} in {}", query, video_id);

    let mut cmd = Command::new("yt-dlp");
    cmd.arg("--no-warnings")
        .arg("--no-playlist")
        .arg("--skip-download")
        .arg("-j")  // dump JSON metadata
        .arg(&url);

    let output = cmd.output().await
        .map_err(|e| anyhow::anyhow!("Failed to execute yt-dlp for subtitle search: {}", e))?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        return Err(anyhow::anyhow!("yt-dlp subtitle search failed: {}", stderr));
    }

    let stdout = String::from_utf8_lossy(&output.stdout);
    let json: serde_json::Value = serde_json::from_str(&stdout)
        .map_err(|e| anyhow::anyhow!("Failed to parse yt-dlp JSON: {}", e))?;

    let mut results = Vec::new();
    let mut used_language: Option<String> = None;

    // Try to get English subtitles first, fallback to first available
    if let Some(subs) = json.get("subtitles").and_then(|s| s.as_object()) {
        // Prefer English
        let lang = if subs.contains_key("en") {
            "en"
        } else if let Some(first_lang) = subs.keys().next() {
            first_lang.as_str()
        } else {
            return Ok(Vec::new());
        };

        used_language = Some(lang.to_string());

        if let Some(entries) = subs.get(lang).and_then(|e| e.as_array()) {
            if let Some(entry) = entries.iter().find(|e| e.get("ext").and_then(|v| v.as_str()) == Some("vtt"))
                .or_else(|| entries.first()) {
                if let Some(url) = entry.get("url").and_then(|u| u.as_str()) {
                    if let Ok(subtitle_text) = fetch_subtitle_file(url).await {
                        results = search_vtt_content(&subtitle_text, &query_lower)?;
                    }
                }
            }
        }
    }

    // Fallback to auto-generated captions if no manual subtitles
    if results.is_empty() {
        if let Some(auto_caps) = json.get("automatic_captions").and_then(|s| s.as_object()) {
            if let Some(entries) = auto_caps.get("en").and_then(|e| e.as_array()) {
                if let Some(entry) = entries.iter().find(|e| e.get("ext").and_then(|v| v.as_str()) == Some("vtt"))
                    .or_else(|| entries.first()) {
                    if let Some(url) = entry.get("url").and_then(|u| u.as_str()) {
                        if let Ok(subtitle_text) = fetch_subtitle_file(url).await {
                            results = search_vtt_content(&subtitle_text, &query_lower)?;
                            used_language = Some("en (auto)".to_string());
                        }
                    }
                }
            }
        }
    }

    tracing::info!("🔍 Found {} matches in subtitles{}",
        results.len(),
        used_language.map(|l| format!(" (language: {})", l)).unwrap_or_default()
    );

    Ok(results)
}

/// Fetch VTT subtitle file from URL
async fn fetch_subtitle_file(url: &str) -> Result<String> {
    let client = reqwest::Client::new();
    let text = client.get(url)
        .timeout(std::time::Duration::from_secs(30))
        .send()
        .await
        .map_err(|e| anyhow::anyhow!("Failed to fetch subtitle file: {}", e))?
        .text()
        .await
        .map_err(|e| anyhow::anyhow!("Failed to read subtitle content: {}", e))?;

    Ok(text)
}

/// Parse VTT format and search for query
fn search_vtt_content(content: &str, query_lower: &str) -> Result<Vec<SubtitleSearchResult>> {
    let mut results = Vec::new();
    let mut current_line_num = 0;

    let lines: Vec<&str> = content.lines().collect();
    let mut i = 0;

    while i < lines.len() {
        let line = lines[i].trim();

        // VTT timestamp format: 00:00:00.000 --> 00:00:05.000
        if line.contains("-->") {
            let timestamp_parts: Vec<&str> = line.split("-->").collect();
            if timestamp_parts.len() == 2 {
                if let (Ok(start), Ok(end)) = (
                    parse_vtt_timestamp(timestamp_parts[0].trim()),
                    parse_vtt_timestamp(timestamp_parts[1].trim()),
                ) {
                    // Collect text lines until next timestamp or empty line
                    let mut text_lines = Vec::new();
                    i += 1;
                    while i < lines.len() {
                        let text_line = lines[i].trim();
                        if text_line.is_empty() || text_line.contains("-->") {
                            break;
                        }
                        if !text_line.starts_with("WEBVTT") && !text_line.starts_with("NOTE") {
                            text_lines.push(text_line);
                        }
                        i += 1;
                    }

                    let text = text_lines.join(" ");
                    let text_lower = text.to_lowercase();

                    // Check if query matches
                    if text_lower.contains(query_lower) {
                        current_line_num += 1;
                        results.push(SubtitleSearchResult {
                            text,
                            start_time: start,
                            end_time: end,
                            line_number: current_line_num,
                        });
                    }
                    continue;
                }
            }
        }

        i += 1;
    }

    Ok(results)
}

/// Parse VTT timestamp format: HH:MM:SS.mmm
fn parse_vtt_timestamp(timestamp: &str) -> Result<f64> {
    let parts: Vec<&str> = timestamp.split(':').collect();
    if parts.len() != 3 {
        return Err(anyhow::anyhow!("Invalid timestamp format: {}", timestamp));
    }

    let hours = parts[0].parse::<f64>().unwrap_or(0.0);
    let minutes = parts[1].parse::<f64>().unwrap_or(0.0);
    let seconds = parts[2].parse::<f64>().unwrap_or(0.0);

    Ok(hours * 3600.0 + minutes * 60.0 + seconds)
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

    // Try the requested quality first with all available sources
    match try_stream_url_sources(video_id, quality).await {
        Ok(stream) => {
            tracing::info!("✅ Successfully got stream at requested quality: {}", quality);
            return Ok(stream);
        }
        Err(requested_quality_error) => {
            tracing::warn!(
                "⚠️  Requested quality '{}' failed for {}: {}",
                quality,
                video_id,
                requested_quality_error
            );
        }
    }

    // Only fall back to "best" if the requested quality was not "best"
    if quality != "best" {
        tracing::warn!(
            "⚠️  No source available for quality '{}'. Falling back to 'best' quality.",
            quality
        );

        match try_stream_url_sources(video_id, "best").await {
            Ok(stream) => {
                tracing::warn!(
                    "⚠️  Note: Using 'best' quality instead of requested '{}' for {}",
                    quality,
                    video_id
                );
                return Ok(stream);
            }
            Err(fallback_error) => {
                return Err(anyhow::anyhow!(
                    "Failed to get stream URL for {} (requested '{}', fallback 'best' also failed: {})",
                    video_id,
                    quality,
                    fallback_error
                ));
            }
        }
    }

    // If we get here, the requested quality was "best" and it failed
    Err(anyhow::anyhow!(
        "Failed to get stream URL for {} with quality '{}'",
        video_id,
        quality
    ))
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
        // Use strict height constraints - don't fall back to "best" without constraints
        "1080p" => "best[height<=1080][vcodec!=none][acodec!=none]/best[height<=1080][vcodec!=none]/best[height<=1080]",
        "720p" => "best[height<=720][vcodec!=none][acodec!=none]/best[height<=720][vcodec!=none]/best[height<=720]",
        "480p" => "best[height<=480][vcodec!=none][acodec!=none]/best[height<=480][vcodec!=none]/best[height<=480]",
        _ => "best[vcodec!=none][acodec!=none]/best[vcodec!=none]/best",
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

    Err(last_error.unwrap_or_else(|| {
        anyhow::anyhow!("all yt-dlp stream URL attempts failed (no error context available)")
    }))
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
    tracing::info!("⬇️  Downloading video: {} to {}", video_id, output_path);

    match download_video_with_ytdlp_command(video_id, output_path, quality, audio_only).await {
        Ok(path) => Ok(path),
        Err(ytdlp_error) => {
            tracing::warn!("⚠️  yt-dlp download failed, falling back to direct fetch: {}", ytdlp_error);

            match download_video_direct(video_id, output_path, quality, audio_only).await {
                Ok(path) => Ok(path),
                Err(direct_error) => Err(anyhow::anyhow!(
                    "yt-dlp download failed: {}; direct download failed: {}",
                    ytdlp_error,
                    direct_error
                )),
            }
        }
    }
}

async fn download_video_with_ytdlp_command(
    video_id: &str,
    output_path: &str,
    quality: &str,
    audio_only: bool,
) -> Result<String> {
    use tokio::process::Command;

    let url = format!("https://www.youtube.com/watch?v={}", video_id);
    let cookies_path = ytdlp_cookies_path();
    let user_agent = ytdlp_user_agent();

    if let Some(parent) = Path::new(output_path).parent() {
        if !parent.as_os_str().is_empty() {
            tokio::fs::create_dir_all(parent)
                .await
                .map_err(|e| anyhow::anyhow!("Failed to create output directory: {}", e))?;
        }
    }

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
            .arg("--newline")
            .arg("-o")
            .arg(output_path);

        if let Some(ref ua) = user_agent {
            cmd.arg("--user-agent").arg(ua);
        }

        if let Some(ref cookies) = cookies_path {
            cmd.arg("--cookies").arg(cookies);
        }

        if audio_only {
            cmd.arg("-x").arg("--audio-format").arg("m4a");
        } else {
            cmd.arg("--merge-output-format")
                .arg("mp4")
                .arg("-f")
                .arg(ytdlp_format_selector(quality));
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

            let err = anyhow::anyhow!("{} attempt failed (status {}): {}", attempt_name, output.status, details);
            tracing::warn!("⚠️  {}", err);
            last_error = Some(err);
            continue;
        }

        tracing::info!("✅ yt-dlp download complete: {}", output_path);
        return Ok(output_path.to_string());
    }

    Err(last_error.unwrap_or_else(|| {
        anyhow::anyhow!("all yt-dlp download attempts failed (no error context available)")
    }))
}

async fn download_video_direct(
    video_id: &str,
    output_path: &str,
    quality: &str,
    audio_only: bool,
) -> Result<String> {
    use rusty_ytdl::{Video, VideoOptions};

    let url = format!("https://www.youtube.com/watch?v={}", video_id);

    let video = Video::new_with_options(&url, VideoOptions::default())
        .map_err(|e| anyhow::anyhow!("Failed to create video: {:?}", e))?;

    let info = video
        .get_info()
        .await
        .map_err(|e| anyhow::anyhow!("Failed to get video info: {:?}", e))?;

    let format = if audio_only {
        info.formats
            .iter()
            .filter(|f| f.has_audio && !f.has_video)
            .max_by_key(|f| f.audio_bitrate.unwrap_or(0))
    } else {
        match quality {
            "1080p" => info
                .formats
                .iter()
                .filter(|f| f.has_video && f.height.unwrap_or(0) <= 1080)
                .max_by_key(|f| f.height.unwrap_or(0)),
            "720p" => info
                .formats
                .iter()
                .filter(|f| f.has_video && f.height.unwrap_or(0) <= 720)
                .max_by_key(|f| f.height.unwrap_or(0)),
            "480p" => info
                .formats
                .iter()
                .filter(|f| f.has_video && f.height.unwrap_or(0) <= 480)
                .max_by_key(|f| f.height.unwrap_or(0)),
            _ => info
                .formats
                .iter()
                .filter(|f| f.has_video)
                .max_by_key(|f| f.height.unwrap_or(0)),
        }
    };

    let format = format.ok_or_else(|| anyhow::anyhow!("No suitable format found"))?;

    let client = reqwest::Client::new();
    let response = client
        .get(&format.url)
        .send()
        .await
        .map_err(|e| anyhow::anyhow!("Failed to download: {}", e))?;

    let bytes = response
        .bytes()
        .await
        .map_err(|e| anyhow::anyhow!("Failed to read response: {}", e))?;

    tokio::fs::write(output_path, bytes)
        .await
        .map_err(|e| anyhow::anyhow!("Failed to write file: {}", e))?;

    tracing::info!("✅ Direct download complete: {}", output_path);
    Ok(output_path.to_string())
}
