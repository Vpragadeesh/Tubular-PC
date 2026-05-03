use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};
use std::process::Command;

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

#[derive(Debug, Serialize, Deserialize)]
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

/// Search for videos using yt-dlp
pub async fn search_videos(query: &str, limit: u32) -> Result<Vec<SearchResult>> {
    let output = Command::new("yt-dlp")
        .arg(format!("ytsearch{}:{}", limit, query))
        .arg("--dump-json")
        .arg("--no-playlist")
        .arg("--skip-download")
        .output()
        .context("Failed to execute yt-dlp")?;

    if !output.status.success() {
        let error = String::from_utf8_lossy(&output.stderr);
        anyhow::bail!("yt-dlp search failed: {}", error);
    }

    let stdout = String::from_utf8_lossy(&output.stdout);
    let mut results = Vec::new();

    for line in stdout.lines() {
        if line.trim().is_empty() {
            continue;
        }
        
        let json: serde_json::Value = serde_json::from_str(line)?;
        
        results.push(SearchResult {
            id: json["id"].as_str().unwrap_or("").to_string(),
            title: json["title"].as_str().unwrap_or("Unknown").to_string(),
            channel: json["uploader"].as_str().unwrap_or("Unknown").to_string(),
            duration: json["duration"].as_u64(),
            view_count: json["view_count"].as_u64(),
            thumbnail: json["thumbnail"].as_str().unwrap_or("").to_string(),
        });
    }

    Ok(results)
}

/// Get detailed video information
pub async fn get_video_info(video_id: &str) -> Result<VideoInfo> {
    let url = format!("https://www.youtube.com/watch?v={}", video_id);
    
    let output = Command::new("yt-dlp")
        .arg(&url)
        .arg("--dump-json")
        .arg("--no-playlist")
        .arg("--skip-download")
        .output()
        .context("Failed to execute yt-dlp")?;

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
        channel: json["uploader"].as_str().unwrap_or("Unknown").to_string(),
        channel_id: json["uploader_id"].as_str().unwrap_or("").to_string(),
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

    let output = Command::new("yt-dlp")
        .arg(&url)
        .arg("-f")
        .arg(format)
        .arg("-g")
        .output()
        .context("Failed to execute yt-dlp")?;

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

    let output = Command::new("yt-dlp")
        .arg(&url)
        .arg("-f")
        .arg(format)
        .arg("-o")
        .arg(output_path)
        .output()
        .context("Failed to execute yt-dlp")?;

    if !output.status.success() {
        let error = String::from_utf8_lossy(&output.stderr);
        anyhow::bail!("Download failed: {}", error);
    }

    Ok(output_path.to_string())
}
