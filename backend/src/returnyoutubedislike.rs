use anyhow::Result;
use serde::{Deserialize, Serialize};
use reqwest;

#[derive(Debug, Serialize, Deserialize)]
pub struct DislikeData {
    pub id: String,
    pub likes: i64,
    pub dislikes: i64,
    pub rating: f64,
    #[serde(rename = "viewCount")]
    pub view_count: i64,
}

/// Get dislike count from Return YouTube Dislike API
pub async fn get_dislikes(video_id: &str) -> Result<DislikeData> {
    let url = format!("https://returnyoutubedislikeapi.com/votes?videoId={}", video_id);

    let client = reqwest::Client::new();
    let response = client
        .get(&url)
        .header("User-Agent", "Tubular-PC/0.1.0")
        .send()
        .await?;

    let data: DislikeData = response.json().await?;
    Ok(data)
}

/// Format dislike count for display
#[allow(dead_code)]
pub fn format_dislikes(dislikes: i64) -> String {
    if dislikes >= 1_000_000 {
        format!("{:.1}M", dislikes as f64 / 1_000_000.0)
    } else if dislikes >= 1_000 {
        format!("{:.1}K", dislikes as f64 / 1_000.0)
    } else {
        dislikes.to_string()
    }
}

/// Format likes for display
#[allow(dead_code)]
pub fn format_likes(likes: i64) -> String {
    if likes >= 1_000_000 {
        format!("{:.1}M", likes as f64 / 1_000_000.0)
    } else if likes >= 1_000 {
        format!("{:.1}K", likes as f64 / 1_000.0)
    } else {
        likes.to_string()
    }
}
