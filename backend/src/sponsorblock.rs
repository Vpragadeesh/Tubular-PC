use anyhow::Result;
use serde::{Deserialize, Serialize};
use reqwest;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Segment {
    pub segment: [f64; 2], // [start, end] in seconds
    pub category: String,
    #[serde(rename = "UUID")]
    pub uuid: String,
}

#[allow(dead_code)]
#[derive(Debug, Serialize, Deserialize)]
pub struct SponsorBlockResponse {
    pub segments: Vec<Segment>,
}

/// Get SponsorBlock segments for a video
pub async fn get_segments(video_id: &str) -> Result<Vec<Segment>> {
    let url = format!(
        "https://sponsor.ajay.app/api/skipSegments?videoID={}&categories=[\"sponsor\",\"selfpromo\",\"interaction\",\"intro\",\"outro\",\"preview\",\"music_offtopic\"]",
        video_id
    );

    let client = reqwest::Client::new();
    let response = client
        .get(&url)
        .header("User-Agent", "Tubular-PC/0.1.0")
        .send()
        .await?;

    if response.status().is_success() {
        let segments: Vec<Segment> = response.json().await?;
        Ok(segments)
    } else {
        // No segments found or error
        Ok(Vec::new())
    }
}

/// Get formatted skip times for display
#[allow(dead_code)]
pub fn format_segments(segments: &[Segment]) -> Vec<String> {
    segments
        .iter()
        .map(|s| {
            let start = format_time(s.segment[0]);
            let end = format_time(s.segment[1]);
            format!("{}: {} - {}", s.category, start, end)
        })
        .collect()
}

#[allow(dead_code)]
fn format_time(seconds: f64) -> String {
    let total_secs = seconds as u64;
    let hours = total_secs / 3600;
    let minutes = (total_secs % 3600) / 60;
    let secs = total_secs % 60;

    if hours > 0 {
        format!("{}:{:02}:{:02}", hours, minutes, secs)
    } else {
        format!("{}:{:02}", minutes, secs)
    }
}
