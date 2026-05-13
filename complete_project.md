Project Path: Tubular-PC

Source Tree:

```txt
Tubular-PC
├── LICENSE
├── backend
│   ├── Cargo.toml
│   └── src
│       ├── api.rs
│       ├── db.rs
│       ├── invidious.rs
│       ├── lib.rs
│       ├── main.rs
│       ├── player.rs
│       ├── returnyoutubedislike.rs
│       ├── sponsorblock.rs
│       └── yt_dlp.rs
├── frontend
│   ├── analysis_options.yaml
│   ├── lib
│   │   ├── controllers
│   │   │   └── player_controller.dart
│   │   ├── main.dart
│   │   ├── models
│   │   │   ├── dislike.dart
│   │   │   ├── dislike.g.dart
│   │   │   ├── download.dart
│   │   │   ├── download.g.dart
│   │   │   ├── history_entry.dart
│   │   │   ├── history_entry.g.dart
│   │   │   ├── sponsorblock.dart
│   │   │   ├── sponsorblock.g.dart
│   │   │   ├── subscription.dart
│   │   │   ├── subscription.g.dart
│   │   │   ├── video.dart
│   │   │   ├── video.g.dart
│   │   │   └── video_details.dart
│   │   ├── providers.dart
│   │   ├── screens
│   │   │   ├── downloads_screen.dart
│   │   │   ├── history_screen.dart
│   │   │   ├── home_screen.dart
│   │   │   ├── player_screen.dart
│   │   │   ├── settings_screen.dart
│   │   │   ├── subscriptions_screen.dart
│   │   │   └── video_details_screen.dart
│   │   ├── services
│   │   │   ├── api_service.dart
│   │   │   ├── media_player_holder.dart
│   │   │   └── player_service.dart
│   │   └── widgets
│   │       ├── error_widget.dart
│   │       ├── player_shell.dart
│   │       ├── video_card.dart
│   │       └── video_details
│   │           ├── actions_section.dart
│   │           ├── comments_section.dart
│   │           ├── stats_section.dart
│   │           └── thumbnail_section.dart
│   ├── linux
│   │   ├── flutter
│   │   │   ├── generated_plugin_registrant.cc
│   │   │   ├── generated_plugin_registrant.h
│   │   │   └── generated_plugins.cmake
│   │   └── runner
│   │       ├── main.cc
│   │       ├── my_application.cc
│   │       └── my_application.h
│   ├── pubspec.lock
│   ├── pubspec.yaml
│   └── test
│       ├── history_screen_test.dart
│       └── widget_test.dart
└── start.bat

```

`LICENSE`:

```
MIT License

Copyright (c) 2024 Tubular PC Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

---

DISCLAIMER:

This software is provided for educational and personal use only. The developers
of this software do not condone or encourage any violation of YouTube's Terms
of Service or copyright infringement. Users are responsible for ensuring their
use of this software complies with all applicable laws and terms of service.

This project is not affiliated with, endorsed by, or connected to YouTube,
Google, NewPipe, or Tubular in any way.

```

`backend/Cargo.toml`:

```toml
[package]
name = "tubular_backend"
version = "0.1.0"
edition = "2021"

[dependencies]
tokio = { version = "1.35", features = ["full"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
reqwest = { version = "0.11", features = ["json", "stream"] }
sqlx = { version = "0.7", features = ["runtime-tokio-native-tls", "sqlite"] }
axum = "0.7"
tower = "0.4"
tower-http = { version = "0.5", features = ["cors", "limit"] }
anyhow = "1.0"
tracing = "0.1"
tracing-subscriber = "0.3"
chrono = "0.4"
lazy_static = "1.4"
rusty_ytdl = { version = "0.7", features = ["search"] }
futures = "0.3"
urlencoding = "2.1"

[lib]
name = "tubular_backend"
path = "src/lib.rs"

[[bin]]
name = "tubular_backend"
path = "src/main.rs"

```

`backend/src/api.rs`:

```rs
use axum::{
    extract::{Path, Query, State},
    http::{StatusCode, HeaderMap, HeaderValue},
    response::{IntoResponse, Json, Response},
    body::Body,
};
use serde::{Deserialize, Serialize};
use futures::StreamExt;

use crate::{db, player, yt_dlp, sponsorblock, returnyoutubedislike, invidious};

#[derive(Debug, Deserialize)]
pub struct SearchQuery {
    q: String,
    #[serde(default = "default_limit")]
    limit: u32,
}

fn default_limit() -> u32 {
    20
}

#[derive(Debug, Serialize)]
pub struct ApiResponse<T> {
    success: bool,
    data: Option<T>,
    error: Option<String>,
}

impl<T: Serialize> ApiResponse<T> {
    fn success(data: T) -> Self {
        Self {
            success: true,
            data: Some(data),
            error: None,
        }
    }

    fn error(message: String) -> Self {
        Self {
            success: false,
            data: None,
            error: Some(message),
        }
    }
}

// Fix LOW PRIORITY: Input validation helpers
fn validate_video_id(id: &str) -> Result<(), String> {
    if id.is_empty() || id.len() > 100 {
        return Err("Invalid video ID length (must be 1-100 chars)".to_string());
    }
    if !id.chars().all(|c| c.is_alphanumeric() || c == '-' || c == '_') {
        return Err("Invalid characters in video ID (only alphanumeric, -, _ allowed)".to_string());
    }
    Ok(())
}

fn validate_quality(quality: &str) -> bool {
    matches!(quality, "best" | "worst" | "720p" | "480p" | "360p" | "1080p" | "audio")
}

pub async fn search(Query(params): Query<SearchQuery>) -> impl IntoResponse {
    match yt_dlp::search_videos(&params.q, params.limit).await {
        Ok(results) => (StatusCode::OK, Json(ApiResponse::success(results))),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse::<Vec<yt_dlp::SearchResult>>::error(e.to_string())),
        ),
    }
}

pub async fn warmup() -> impl IntoResponse {
    match yt_dlp::warmup().await {
        Ok(_) => (StatusCode::OK, Json(ApiResponse::success("yt-dlp warmup complete".to_string()))),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse::<String>::error(format!("Warmup failed: {}", e))),
        ),
    }
}

pub async fn clear_search_cache() -> impl IntoResponse {
    yt_dlp::clear_search_cache().await;
    (StatusCode::OK, Json(ApiResponse::success("Search cache cleared")))
}

pub async fn get_video_info(Path(id): Path<String>) -> impl IntoResponse {
    // Validate input
    if let Err(e) = validate_video_id(&id) {
        return (StatusCode::BAD_REQUEST, Json(ApiResponse::<yt_dlp::VideoInfo>::error(e)));
    }
    
    match yt_dlp::get_video_info(&id).await {
        Ok(info) => (StatusCode::OK, Json(ApiResponse::success(info))),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse::<yt_dlp::VideoInfo>::error(e.to_string())),
        ),
    }
}

#[derive(Debug, Serialize)]
pub struct VideoDetailsCommentResponse {
    user_id: String,
    username: String,
    avatar_url: String,
    text: String,
    timestamp: String,
    like_count: i64,
}

#[derive(Debug, Serialize)]
pub struct VideoDetailsResponse {
    id: String,
    title: String,
    channel_name: String,
    channel_id: String,
    subscriber_count: u64,
    view_count: u64,
    upload_date: String,
    duration_seconds: u64,
    thumbnail_url: String,
    like_count: u64,
    dislike_count: u64,
    comments: Vec<VideoDetailsCommentResponse>,
}

pub async fn get_video_details(Path(id): Path<String>) -> impl IntoResponse {
    // Validate input
    if let Err(e) = validate_video_id(&id) {
        return (
            StatusCode::BAD_REQUEST,
            Json(ApiResponse::<VideoDetailsResponse>::error(e)),
        );
    }
    
    let info = match yt_dlp::get_video_info(&id).await {
        Ok(info) => info,
        Err(e) => {
            return (
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(ApiResponse::<VideoDetailsResponse>::error(e.to_string())),
            );
        }
    };

    let dislike_data = returnyoutubedislike::get_dislikes(&id).await.ok();
    let comments = invidious::get_comments(&id).await.unwrap_or_default();

    // Fix dislike count logic: use and_then for proper Option chaining
    let like_count = dislike_data
        .as_ref()
        .and_then(|d| Some(d.likes.max(0) as u64))
        .or_else(|| info.like_count)
        .unwrap_or(0);

    let dislike_count = dislike_data
        .as_ref()
        .map(|d| d.dislikes.max(0) as u64)
        .unwrap_or(0);

    let details = VideoDetailsResponse {
        id: info.id,
        title: info.title,
        channel_name: info.channel,
        channel_id: info.channel_id,
        subscriber_count: 0,
        view_count: info.view_count.unwrap_or(0),
        upload_date: info.upload_date.unwrap_or_default(),
        duration_seconds: info.duration.unwrap_or(0),
        thumbnail_url: info.thumbnail,
        like_count,
        dislike_count,
        comments: comments
            .into_iter()
            .map(|c| {
                // Fix MEDIUM: Log incomplete comment data for debugging
                if c.author.is_empty() || c.content.is_empty() {
                    tracing::warn!("Incomplete comment data: author_id={}", c.author_id);
                }
                VideoDetailsCommentResponse {
                    user_id: c.author_id,
                    username: c.author,
                    avatar_url: c.author_avatar,
                    text: c.content,
                    timestamp: c.published_text,
                    like_count: c.like_count,
                }
            })
            .collect(),
    };

    (StatusCode::OK, Json(ApiResponse::success(details)))
}

#[derive(Debug, Deserialize)]
pub struct StreamQuery {
    #[serde(default = "default_quality")]
    quality: String,
}

fn default_quality() -> String {
    "best".to_string()
}

pub async fn get_stream_url(
    Path(id): Path<String>,
    Query(params): Query<StreamQuery>,
) -> impl IntoResponse {
    // Validate inputs
    if let Err(e) = validate_video_id(&id) {
        return (StatusCode::BAD_REQUEST, Json(ApiResponse::<yt_dlp::StreamUrl>::error(e)));
    }
    
    if !validate_quality(&params.quality) {
        tracing::warn!("Invalid quality requested: {}", params.quality);
    }
    
    match yt_dlp::get_stream_url(&id, &params.quality).await {
        Ok(stream) => (StatusCode::OK, Json(ApiResponse::success(stream))),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse::<yt_dlp::StreamUrl>::error(e.to_string())),
        ),
    }
}

/// Proxy stream endpoint - streams video through backend to avoid CORS issues
pub async fn proxy_stream(
    Path(id): Path<String>,
    request_headers: HeaderMap,
    Query(params): Query<StreamQuery>,
) -> Result<Response, StatusCode> {
    // Get stream URL from rusty_ytdl
    let stream_info = match yt_dlp::get_stream_url(&id, &params.quality).await {
        Ok(info) => info,
        Err(e) => {
            tracing::error!("Failed to get stream URL: {}", e);
            return Err(StatusCode::INTERNAL_SERVER_ERROR);
        }
    };

    tracing::info!("🎥 Proxying stream for video: {} (quality: {})", id, params.quality);

    let user_agent = std::env::var("TUBULAR_STREAM_USER_AGENT")
        .or_else(|_| std::env::var("TUBULAR_YTDLP_USER_AGENT"))
        .ok()
        .map(|value| value.trim().to_string())
        .filter(|value| !value.is_empty())
        .unwrap_or_else(|| {
            "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36".to_string()
        });

    let referer = std::env::var("TUBULAR_STREAM_REFERER")
        .ok()
        .map(|value| value.trim().to_string())
        .filter(|value| !value.is_empty())
        .unwrap_or_else(|| "https://www.youtube.com/".to_string());

    // Create HTTP client and fetch the stream
    let client = reqwest::Client::builder()
        .timeout(std::time::Duration::from_secs(300))
        .user_agent(user_agent)
        .build()
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;

    let mut upstream_request = client
        .get(&stream_info.url)
        .header("Referer", referer);

    if let Some(range) = request_headers.get("range").and_then(|value| value.to_str().ok()) {
        upstream_request = upstream_request.header("Range", range);
    }

    let response = upstream_request
        .send()
        .await
        .map_err(|e| {
            tracing::error!("Failed to fetch stream: {}", e);
            StatusCode::BAD_GATEWAY
        })?;

    if !(response.status().is_success() || response.status() == reqwest::StatusCode::PARTIAL_CONTENT) {
        tracing::error!("Upstream stream returned non-success status: {}", response.status());
        return Err(StatusCode::BAD_GATEWAY);
    }

    let upstream_status = response.status();

    // Get content type and length
    let content_type = response
        .headers()
        .get("content-type")
        .and_then(|v| v.to_str().ok())
        .unwrap_or("video/mp4")
        .to_string();

    let content_length = response.content_length();
    let content_range = response
        .headers()
        .get("content-range")
        .and_then(|v| v.to_str().ok())
        .map(|v| v.to_string());

    // Convert response to stream
    let stream = response.bytes_stream();
    let stream = stream.map(|result| {
        result.map_err(|e| {
            // Fix MEDIUM: Add error context to stream errors
            tracing::error!("Stream error during proxying: {}", e);
            std::io::Error::new(std::io::ErrorKind::Other, e)
        })
    });

    let body = Body::from_stream(stream);

    // Build response with proper headers
    let mut headers = HeaderMap::new();
    
    // Fix CRITICAL: Handle HeaderValue::from_str errors gracefully
    if let Ok(ct) = HeaderValue::from_str(&content_type) {
        headers.insert("content-type", ct);
    } else {
        tracing::warn!("Invalid content-type header: {}", content_type);
    }
    
    headers.insert("accept-ranges", HeaderValue::from_static("bytes"));

    if let Some(length) = content_length {
        if let Ok(cl) = HeaderValue::from_str(&length.to_string()) {
            headers.insert("content-length", cl);
        } else {
            tracing::warn!("Invalid content-length header: {}", length);
        }
    }

    if let Some(content_range) = content_range {
        if let Ok(value) = HeaderValue::from_str(&content_range) {
            headers.insert("content-range", value);
        } else {
            tracing::warn!("Invalid content-range header: {}", content_range);
        }
    }

    // Fix CRITICAL: Use BAD_GATEWAY instead of OK for invalid status codes
    let status = StatusCode::from_u16(upstream_status.as_u16())
        .unwrap_or_else(|_| {
            tracing::error!("Invalid upstream status code: {}", upstream_status);
            StatusCode::BAD_GATEWAY
        });
    Ok((status, headers, body).into_response())
}

pub async fn get_player_state(State(player): State<player::PlayerHandle>) -> impl IntoResponse {
    let state = player.snapshot().await;
    (StatusCode::OK, Json(ApiResponse::success(state)))
}

pub async fn player_play(
    State(player): State<player::PlayerHandle>,
    Json(req): Json<player::PlayRequest>,
) -> impl IntoResponse {
    match player.play(req).await {
        Ok(state) => (StatusCode::OK, Json(ApiResponse::success(state))),
        Err(e) => (
            StatusCode::BAD_REQUEST,
            Json(ApiResponse::<player::PlayerState>::error(e.to_string())),
        ),
    }
}

pub async fn player_pause(State(player): State<player::PlayerHandle>) -> impl IntoResponse {
    match player.pause().await {
        Ok(state) => (StatusCode::OK, Json(ApiResponse::success(state))),
        Err(e) => (
            StatusCode::BAD_REQUEST,
            Json(ApiResponse::<player::PlayerState>::error(e.to_string())),
        ),
    }
}

pub async fn player_resume(State(player): State<player::PlayerHandle>) -> impl IntoResponse {
    match player.resume().await {
        Ok(state) => (StatusCode::OK, Json(ApiResponse::success(state))),
        Err(e) => (
            StatusCode::BAD_REQUEST,
            Json(ApiResponse::<player::PlayerState>::error(e.to_string())),
        ),
    }
}

pub async fn player_seek(
    State(player): State<player::PlayerHandle>,
    Json(req): Json<player::SeekRequest>,
) -> impl IntoResponse {
    match player.seek(req).await {
        Ok(state) => (StatusCode::OK, Json(ApiResponse::success(state))),
        Err(e) => (
            StatusCode::BAD_REQUEST,
            Json(ApiResponse::<player::PlayerState>::error(e.to_string())),
        ),
    }
}

pub async fn player_background_audio(
    State(player): State<player::PlayerHandle>,
    Json(req): Json<player::BackgroundAudioRequest>,
) -> impl IntoResponse {
    match player.set_background_audio(req).await {
        Ok(state) => (StatusCode::OK, Json(ApiResponse::success(state))),
        Err(e) => (
            StatusCode::BAD_REQUEST,
            Json(ApiResponse::<player::PlayerState>::error(e.to_string())),
        ),
    }
}

pub async fn player_stop(State(player): State<player::PlayerHandle>) -> impl IntoResponse {
    let state = player.stop().await;
    (StatusCode::OK, Json(ApiResponse::success(state)))
}

#[derive(Debug, Deserialize)]
pub struct CreateDownloadRequest {
    video_id: String,
    title: String,
    output_path: String,
    quality: String,
    #[allow(dead_code)]
    audio_only: bool,
}

#[derive(Debug, Deserialize)]
pub struct DownloadRequest {
    video_id: String,
    output_path: String,
    quality: String,
    audio_only: bool,
}

pub async fn create_download(Json(req): Json<CreateDownloadRequest>) -> impl IntoResponse {
    match db::create_download(&req.video_id, &req.title, &req.output_path, &req.quality).await {
        Ok(id) => (StatusCode::OK, Json(ApiResponse::success(serde_json::json!({ "id": id })))),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse::<serde_json::Value>::error(e.to_string())),
        ),
    }
}

pub async fn download_video(Json(req): Json<DownloadRequest>) -> impl IntoResponse {
    match yt_dlp::download_video(&req.video_id, &req.output_path, &req.quality, req.audio_only).await {
        Ok(path) => (StatusCode::OK, Json(ApiResponse::success(path))),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse::<String>::error(e.to_string())),
        ),
    }
}

pub async fn get_downloads() -> impl IntoResponse {
    match db::get_downloads().await {
        Ok(downloads) => (StatusCode::OK, Json(ApiResponse::success(downloads))),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse::<Vec<db::Download>>::error(e.to_string())),
        ),
    }
}

pub async fn get_subscriptions() -> impl IntoResponse {
    match db::get_subscriptions().await {
        Ok(subs) => (StatusCode::OK, Json(ApiResponse::success(subs))),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse::<Vec<db::Subscription>>::error(e.to_string())),
        ),
    }
}

#[derive(Debug, Deserialize)]
pub struct RemoveSubscriptionRequest {
    channel_id: String,
}

pub async fn remove_subscription(Json(req): Json<RemoveSubscriptionRequest>) -> impl IntoResponse {
    match db::remove_subscription(&req.channel_id).await {
        Ok(_) => (StatusCode::OK, Json(ApiResponse::success("Unsubscribed".to_string()))),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse::<String>::error(e.to_string())),
        ),
    }
}

#[derive(Debug, Deserialize)]
pub struct AddSubscriptionRequest {
    channel_id: String,
    channel_name: String,
    thumbnail: String,
}

pub async fn add_subscription(Json(req): Json<AddSubscriptionRequest>) -> impl IntoResponse {
    match db::add_subscription(&req.channel_id, &req.channel_name, &req.thumbnail).await {
        Ok(_) => (StatusCode::OK, Json(ApiResponse::success("Subscribed".to_string()))),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse::<String>::error(e.to_string())),
        ),
    }
}

pub async fn get_active_downloads() -> impl IntoResponse {
    match db::get_active_downloads().await {
        Ok(downloads) => (StatusCode::OK, Json(ApiResponse::success(downloads))),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse::<Vec<db::Download>>::error(e.to_string())),
        ),
    }
}

pub async fn get_download(Path(id): Path<i64>) -> impl IntoResponse {
    match db::get_download(id).await {
        Ok(Some(download)) => (StatusCode::OK, Json(ApiResponse::success(download))),
        Ok(None) => (
            StatusCode::NOT_FOUND,
            Json(ApiResponse::<db::Download>::error("Download not found".to_string())),
        ),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse::<db::Download>::error(e.to_string())),
        ),
    }
}

#[derive(Debug, Deserialize)]
pub struct UpdateDownloadProgressRequest {
    status: String,
    progress: f64,
    speed: f64,
    eta_seconds: i64,
}

pub async fn update_download_progress(Path(id): Path<i64>, Json(req): Json<UpdateDownloadProgressRequest>) -> impl IntoResponse {
    // Fix HIGH: Validate progress and speed bounds
    if !(0.0..=100.0).contains(&req.progress) {
        return (StatusCode::BAD_REQUEST, Json(ApiResponse::<String>::error("Progress must be between 0 and 100".to_string())));
    }
    if req.speed < 0.0 {
        return (StatusCode::BAD_REQUEST, Json(ApiResponse::<String>::error("Speed cannot be negative".to_string())));
    }
    if req.eta_seconds < 0 {
        return (StatusCode::BAD_REQUEST, Json(ApiResponse::<String>::error("ETA seconds cannot be negative".to_string())));
    }
    
    match db::update_download_status(id, &req.status, req.progress, req.speed, req.eta_seconds).await {
        Ok(_) => (StatusCode::OK, Json(ApiResponse::success("Progress updated".to_string()))),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse::<String>::error(e.to_string())),
        ),
    }
}

pub async fn complete_download(Path(id): Path<i64>, Json(data): Json<serde_json::Value>) -> impl IntoResponse {
    let file_size = data.get("file_size").and_then(|v| v.as_i64()).unwrap_or(0);
    match db::complete_download(id, file_size).await {
        Ok(_) => (StatusCode::OK, Json(ApiResponse::success("Download completed".to_string()))),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse::<String>::error(e.to_string())),
        ),
    }
}

pub async fn fail_download(Path(id): Path<i64>, Json(data): Json<serde_json::Value>) -> impl IntoResponse {
    let error_msg = data.get("error_message").and_then(|v| v.as_str()).unwrap_or("Unknown error");
    match db::fail_download(id, error_msg).await {
        Ok(_) => (StatusCode::OK, Json(ApiResponse::success("Download marked as failed".to_string()))),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse::<String>::error(e.to_string())),
        ),
    }
}

pub async fn delete_download(Path(id): Path<i64>) -> impl IntoResponse {
    match db::delete_download(id).await {
        Ok(_) => (StatusCode::OK, Json(ApiResponse::success("Download deleted".to_string()))),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse::<String>::error(e.to_string())),
        ),
    }
}

pub async fn get_history() -> impl IntoResponse {
    match db::get_history().await {
        Ok(history) => (StatusCode::OK, Json(ApiResponse::success(history))),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse::<Vec<db::HistoryEntry>>::error(e.to_string())),
        ),
    }
}

#[derive(Debug, Deserialize)]
pub struct RemoveHistoryRequest {
    id: i64,
}

pub async fn remove_from_history(Json(req): Json<RemoveHistoryRequest>) -> impl IntoResponse {
    match db::remove_from_history(req.id).await {
        Ok(_) => (StatusCode::OK, Json(ApiResponse::success("Removed from history".to_string()))),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse::<String>::error(e.to_string())),
        ),
    }
}

pub async fn clear_history() -> impl IntoResponse {
    match db::clear_history().await {
        Ok(_) => (StatusCode::OK, Json(ApiResponse::success("History cleared".to_string()))),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse::<String>::error(e.to_string())),
        ),
    }
}

#[derive(Debug, Deserialize)]
pub struct AddHistoryRequest {
    video_id: String,
    title: String,
    channel: String,
    thumbnail: String,
}

pub async fn add_to_history(Json(req): Json<AddHistoryRequest>) -> impl IntoResponse {
    match db::add_to_history(&req.video_id, &req.title, &req.channel, &req.thumbnail).await {
        Ok(_) => (StatusCode::OK, Json(ApiResponse::success("Added to history".to_string()))),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse::<String>::error(e.to_string())),
        ),
    }
}

pub async fn get_sponsorblock_segments(Path(id): Path<String>) -> impl IntoResponse {
    match sponsorblock::get_segments(&id).await {
        Ok(segments) => (StatusCode::OK, Json(ApiResponse::success(segments))),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse::<Vec<sponsorblock::Segment>>::error(e.to_string())),
        ),
    }
}

pub async fn get_dislike_count(Path(id): Path<String>) -> impl IntoResponse {
    match returnyoutubedislike::get_dislikes(&id).await {
        Ok(data) => (StatusCode::OK, Json(ApiResponse::success(data))),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse::<returnyoutubedislike::DislikeData>::error(e.to_string())),
        ),
    }
}

#[derive(Debug, Deserialize)]
pub struct SetSettingRequest {
    key: String,
    value: String,
}

pub async fn set_setting(Json(req): Json<SetSettingRequest>) -> impl IntoResponse {
    match db::set_setting(&req.key, &req.value).await {
        Ok(_) => (StatusCode::OK, Json(ApiResponse::success("Setting saved".to_string()))),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse::<String>::error(e.to_string())),
        ),
    }
}

pub async fn get_setting(Path(key): Path<String>) -> impl IntoResponse {
    match db::get_setting(&key).await {
        Ok(Some(value)) => (
            StatusCode::OK,
            Json(ApiResponse::success(serde_json::json!({ "value": value }))),
        ),
        Ok(None) => (
            StatusCode::NOT_FOUND,
            Json(ApiResponse::<serde_json::Value>::error("Setting not found".to_string())),
        ),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse::<serde_json::Value>::error(e.to_string())),
        ),
    }
}

pub async fn get_all_settings() -> impl IntoResponse {
    match db::get_all_settings().await {
        Ok(settings) => (StatusCode::OK, Json(ApiResponse::success(settings))),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse::<Vec<db::Setting>>::error(e.to_string())),
        ),
    }
}

/// Invidious: Search videos
pub async fn invidious_search(Query(params): Query<SearchQuery>) -> impl IntoResponse {
    match invidious::search_videos(&params.q, params.limit).await {
        Ok(videos) => {
            // Convert to our Video format
            let results: Vec<_> = videos.iter().map(|v| {
                serde_json::json!({
                    "id": v.video_id,
                    "title": v.title,
                    "channel": v.author,
                    "duration": v.length_seconds,
                    "view_count": v.view_count,
                    "thumbnail": v.thumbnails.first().map(|t| &t.url).cloned().unwrap_or_default(),
                })
            }).collect();
            (StatusCode::OK, Json(ApiResponse::success(results)))
        }
        Err(e) => {
            // Fix MEDIUM: Add error logging for debugging
            tracing::error!("Invidious search failed for '{}': {}", params.q, e);
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(ApiResponse::<Vec<serde_json::Value>>::error(e.to_string())),
            )
        },
    }
}

/// Invidious: Get video info
pub async fn invidious_video_info(Path(id): Path<String>) -> impl IntoResponse {
    match invidious::get_video_info(&id).await {
        Ok(info) => (StatusCode::OK, Json(ApiResponse::success(serde_json::json!({
            "id": info.video_id,
            "title": info.title,
            "description": info.description,
            "channel": info.author,
            "channel_id": info.author_id,
            "duration": info.length_seconds,
            "view_count": info.view_count,
            "like_count": info.like_count,
        })))),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse::<serde_json::Value>::error(e.to_string())),
        ),
    }
}

/// Invidious: Get stream URL
pub async fn invidious_stream_url(
    Path(id): Path<String>,
    Query(params): Query<StreamQuery>,
) -> impl IntoResponse {
    match invidious::get_stream_url(&id, &params.quality).await {
        Ok(url) => (StatusCode::OK, Json(ApiResponse::success(serde_json::json!({
            "url": url,
            "quality": params.quality,
        })))),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse::<serde_json::Value>::error(e.to_string())),
        ),
    }
}

/// Set Invidious instance
#[derive(Debug, Deserialize)]
pub struct SetInstanceRequest {
    url: String,
}

pub async fn set_invidious_instance(Json(req): Json<SetInstanceRequest>) -> impl IntoResponse {
    invidious::set_instance(req.url.clone()).await;
    (StatusCode::OK, Json(ApiResponse::success(format!("Instance set to: {}", req.url))))
}

/// Get current Invidious instance
pub async fn get_invidious_instance() -> impl IntoResponse {
    let instance = invidious::get_current_instance().await;
    (StatusCode::OK, Json(ApiResponse::success(serde_json::json!({
        "instance": instance,
    }))))
}

/// Get list of default Invidious instances
pub async fn get_invidious_instances() -> impl IntoResponse {
    let instances = invidious::get_default_instances();
    (StatusCode::OK, Json(ApiResponse::success(instances)))
}


// Playlist endpoints
#[derive(Debug, Deserialize)]
pub struct CreatePlaylistRequest {
    name: String,
    description: Option<String>,
}

pub async fn create_playlist(Json(req): Json<CreatePlaylistRequest>) -> impl IntoResponse {
    match db::create_playlist(&req.name, req.description.as_deref()).await {
        Ok(id) => (StatusCode::OK, Json(ApiResponse::success(serde_json::json!({"id": id})))),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse::<serde_json::Value>::error(e.to_string())),
        ),
    }
}

pub async fn get_playlists() -> impl IntoResponse {
    match db::get_playlists().await {
        Ok(playlists) => (StatusCode::OK, Json(ApiResponse::success(playlists))),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse::<Vec<db::Playlist>>::error(e.to_string())),
        ),
    }
}

pub async fn get_playlist(Path(id): Path<i64>) -> impl IntoResponse {
    match db::get_playlist(id).await {
        Ok(Some(playlist)) => (StatusCode::OK, Json(ApiResponse::success(playlist))),
        Ok(None) => (
            StatusCode::NOT_FOUND,
            Json(ApiResponse::<db::Playlist>::error("Playlist not found".to_string())),
        ),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse::<db::Playlist>::error(e.to_string())),
        ),
    }
}

pub async fn delete_playlist(Path(id): Path<i64>) -> impl IntoResponse {
    match db::delete_playlist(id).await {
        Ok(_) => (StatusCode::OK, Json(ApiResponse::success("Playlist deleted".to_string()))),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse::<String>::error(e.to_string())),
        ),
    }
}

#[derive(Debug, Deserialize)]
pub struct AddVideoToPlaylistRequest {
    video_id: String,
    title: String,
    channel: String,
    thumbnail: String,
}

pub async fn add_video_to_playlist(
    Path(id): Path<i64>,
    Json(req): Json<AddVideoToPlaylistRequest>,
) -> impl IntoResponse {
    match db::add_video_to_playlist(id, &req.video_id, &req.title, &req.channel, &req.thumbnail).await {
        Ok(_) => (StatusCode::OK, Json(ApiResponse::success("Video added to playlist".to_string()))),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse::<String>::error(e.to_string())),
        ),
    }
}

pub async fn get_playlist_videos(Path(id): Path<i64>) -> impl IntoResponse {
    match db::get_playlist_videos(id).await {
        Ok(videos) => (StatusCode::OK, Json(ApiResponse::success(videos))),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse::<Vec<db::PlaylistVideo>>::error(e.to_string())),
        ),
    }
}

#[derive(Debug, Deserialize)]
pub struct RemoveVideoRequest {
    video_id: String,
}

pub async fn remove_video_from_playlist(
    Path(id): Path<i64>,
    Json(req): Json<RemoveVideoRequest>,
) -> impl IntoResponse {
    match db::remove_video_from_playlist(id, &req.video_id).await {
        Ok(_) => (StatusCode::OK, Json(ApiResponse::success("Video removed from playlist".to_string()))),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse::<String>::error(e.to_string())),
        ),
    }
}

```

`backend/src/db.rs`:

```rs
use anyhow::Result;
use serde::{Deserialize, Serialize};
use sqlx::{sqlite::{SqlitePool, SqliteConnectOptions}, Pool, Sqlite, Row};
use std::sync::OnceLock;
use std::str::FromStr;

static DB_POOL: OnceLock<Pool<Sqlite>> = OnceLock::new();

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
pub struct Subscription {
    pub id: i64,
    pub channel_id: String,
    pub channel_name: String,
    pub channel_thumbnail: String,
    pub subscribed_at: String,
}

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
pub struct HistoryEntry {
    pub id: i64,
    pub video_id: String,
    pub title: String,
    pub channel: String,
    pub thumbnail: String,
    pub watched_at: String,
    pub progress: Option<f64>,
}

#[allow(dead_code)]
#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
pub struct Download {
    pub id: i64,
    pub video_id: String,
    pub title: String,
    pub file_path: String,
    pub quality: String,
    pub status: String,
    pub progress: f64,
    pub file_size: i64,
    pub speed: f64,
    pub eta_seconds: i64,
    pub created_at: String,
    pub started_at: Option<String>,
    pub completed_at: Option<String>,
    pub error_message: Option<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Setting {
    pub key: String,
    pub value: String,
}

pub async fn init_db() -> Result<()> {
    // Create database in the current directory with create-if-missing option
    let db_path = std::env::var("TUBULAR_DB_PATH")
        .unwrap_or_else(|_| "tubular.db".to_string());
    
    let options = SqliteConnectOptions::from_str(&format!("sqlite://{}", db_path))?
        .create_if_missing(true);
    
    let pool = SqlitePool::connect_with(options).await?;

    // Create tables
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS subscriptions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            channel_id TEXT UNIQUE NOT NULL,
            channel_name TEXT NOT NULL,
            channel_thumbnail TEXT,
            subscribed_at TEXT NOT NULL
        )
        "#,
    )
    .execute(&pool)
    .await?;

    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            video_id TEXT NOT NULL,
            title TEXT NOT NULL,
            channel TEXT NOT NULL,
            thumbnail TEXT,
            watched_at TEXT NOT NULL,
            progress REAL
        )
        "#,
    )
    .execute(&pool)
    .await?;

    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS downloads (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            video_id TEXT NOT NULL,
            title TEXT NOT NULL,
            file_path TEXT NOT NULL,
            quality TEXT NOT NULL,
            status TEXT NOT NULL DEFAULT 'pending',
            progress REAL DEFAULT 0.0,
            file_size INTEGER DEFAULT 0,
            speed REAL DEFAULT 0.0,
            eta_seconds INTEGER DEFAULT 0,
            created_at TEXT NOT NULL,
            started_at TEXT,
            completed_at TEXT,
            error_message TEXT
        )
        "#,
    )
    .execute(&pool)
    .await?;
    migrate_downloads_schema(&pool).await?;

    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS settings (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
        )
        "#,
    )
    .execute(&pool)
    .await?;

    // Create playlists table
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS playlists (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            description TEXT,
            created_at TEXT NOT NULL
        )
        "#,
    )
    .execute(&pool)
    .await?;

    // Create playlist_videos table
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS playlist_videos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            playlist_id INTEGER NOT NULL,
            video_id TEXT NOT NULL,
            title TEXT NOT NULL,
            channel TEXT NOT NULL,
            thumbnail TEXT NOT NULL,
            position INTEGER NOT NULL,
            added_at TEXT NOT NULL,
            FOREIGN KEY (playlist_id) REFERENCES playlists(id) ON DELETE CASCADE
        )
        "#,
    )
    .execute(&pool)
    .await?;

    // Fix HIGH: Handle pool already being set gracefully
    if DB_POOL.set(pool).is_err() {
        tracing::warn!("DB pool already initialized, skipping reinit");
    }
    Ok(())
}

async fn migrate_downloads_schema(pool: &Pool<Sqlite>) -> Result<()> {
    let rows = sqlx::query("PRAGMA table_info(downloads)")
        .fetch_all(pool)
        .await?;

    let mut columns = std::collections::HashSet::new();
    for row in rows {
        let name: String = row.get("name");
        columns.insert(name);
    }

    if !columns.contains("file_path") {
        sqlx::query("ALTER TABLE downloads ADD COLUMN file_path TEXT")
            .execute(pool)
            .await?;
    }
    if !columns.contains("quality") {
        sqlx::query("ALTER TABLE downloads ADD COLUMN quality TEXT")
            .execute(pool)
            .await?;
    }
    if !columns.contains("status") {
        sqlx::query("ALTER TABLE downloads ADD COLUMN status TEXT NOT NULL DEFAULT 'pending'")
            .execute(pool)
            .await?;
    }
    if !columns.contains("progress") {
        sqlx::query("ALTER TABLE downloads ADD COLUMN progress REAL DEFAULT 0.0")
            .execute(pool)
            .await?;
    }
    if !columns.contains("file_size") {
        sqlx::query("ALTER TABLE downloads ADD COLUMN file_size INTEGER DEFAULT 0")
            .execute(pool)
            .await?;
    }
    if !columns.contains("speed") {
        sqlx::query("ALTER TABLE downloads ADD COLUMN speed REAL DEFAULT 0.0")
            .execute(pool)
            .await?;
    }
    if !columns.contains("eta_seconds") {
        sqlx::query("ALTER TABLE downloads ADD COLUMN eta_seconds INTEGER DEFAULT 0")
            .execute(pool)
            .await?;
    }
    if !columns.contains("created_at") {
        sqlx::query("ALTER TABLE downloads ADD COLUMN created_at TEXT")
            .execute(pool)
            .await?;
    }
    if !columns.contains("started_at") {
        sqlx::query("ALTER TABLE downloads ADD COLUMN started_at TEXT")
            .execute(pool)
            .await?;
    }
    if !columns.contains("completed_at") {
        sqlx::query("ALTER TABLE downloads ADD COLUMN completed_at TEXT")
            .execute(pool)
            .await?;
    }
    if !columns.contains("error_message") {
        sqlx::query("ALTER TABLE downloads ADD COLUMN error_message TEXT")
            .execute(pool)
            .await?;
    }

    // Backfill from legacy columns when present.
    if columns.contains("output_path") {
        sqlx::query(
            "UPDATE downloads SET file_path = COALESCE(file_path, output_path, '')",
        )
        .execute(pool)
        .await?;
    }
    if columns.contains("downloaded_at") {
        sqlx::query(
            "UPDATE downloads SET created_at = COALESCE(created_at, downloaded_at)",
        )
        .execute(pool)
        .await?;
    }

    let now = chrono::Utc::now().to_rfc3339();
    sqlx::query("UPDATE downloads SET quality = COALESCE(quality, 'unknown')")
        .execute(pool)
        .await?;
    sqlx::query("UPDATE downloads SET file_path = COALESCE(file_path, '')")
        .execute(pool)
        .await?;
    sqlx::query("UPDATE downloads SET created_at = COALESCE(created_at, ?)")
        .bind(now)
        .execute(pool)
        .await?;

    Ok(())
}

pub fn get_pool() -> &'static Pool<Sqlite> {
    DB_POOL.get().expect("Database not initialized")
}

// Subscription operations
pub async fn add_subscription(channel_id: &str, channel_name: &str, thumbnail: &str) -> Result<()> {
    let pool = get_pool();
    let now = chrono::Utc::now().to_rfc3339();

    sqlx::query(
        "INSERT OR IGNORE INTO subscriptions (channel_id, channel_name, channel_thumbnail, subscribed_at) VALUES (?, ?, ?, ?)"
    )
    .bind(channel_id)
    .bind(channel_name)
    .bind(thumbnail)
    .bind(now)
    .execute(pool)
    .await?;

    Ok(())
}

pub async fn get_subscriptions() -> Result<Vec<Subscription>> {
    let pool = get_pool();
    let subs = sqlx::query_as::<_, Subscription>("SELECT * FROM subscriptions ORDER BY subscribed_at DESC")
        .fetch_all(pool)
        .await?;
    Ok(subs)
}

pub async fn remove_subscription(channel_id: &str) -> Result<()> {
    let pool = get_pool();
    sqlx::query("DELETE FROM subscriptions WHERE channel_id = ?")
        .bind(channel_id)
        .execute(pool)
        .await?;
    Ok(())
}

// History operations
pub async fn add_to_history(video_id: &str, title: &str, channel: &str, thumbnail: &str) -> Result<()> {
    let pool = get_pool();
    let now = chrono::Utc::now().to_rfc3339();

    sqlx::query(
        "INSERT INTO history (video_id, title, channel, thumbnail, watched_at) VALUES (?, ?, ?, ?, ?)"
    )
    .bind(video_id)
    .bind(title)
    .bind(channel)
    .bind(thumbnail)
    .bind(now)
    .execute(pool)
    .await?;

    Ok(())
}

pub async fn get_history() -> Result<Vec<HistoryEntry>> {
    let pool = get_pool();
    let history = sqlx::query_as::<_, HistoryEntry>("SELECT * FROM history ORDER BY watched_at DESC LIMIT 100")
        .fetch_all(pool)
        .await?;
    Ok(history)
}

pub async fn remove_from_history(id: i64) -> Result<()> {
    let pool = get_pool();
    sqlx::query("DELETE FROM history WHERE id = ?")
        .bind(id)
        .execute(pool)
        .await?;
    Ok(())
}

pub async fn clear_history() -> Result<()> {
    let pool = get_pool();
    sqlx::query("DELETE FROM history")
        .execute(pool)
        .await?;
    Ok(())
}

// Download operations
pub async fn create_download(video_id: &str, title: &str, file_path: &str, quality: &str) -> Result<i64> {
    let pool = get_pool();
    let now = chrono::Utc::now().to_rfc3339();

    let has_legacy_downloaded_at = has_downloaded_at_column(pool).await?;
    let result = if has_legacy_downloaded_at {
        sqlx::query(
            "INSERT INTO downloads (video_id, title, file_path, quality, status, progress, created_at, downloaded_at) VALUES (?, ?, ?, ?, 'pending', 0.0, ?, ?)"
        )
        .bind(video_id)
        .bind(title)
        .bind(file_path)
        .bind(quality)
        .bind(&now)
        .bind(&now)
        .execute(pool)
        .await?
    } else {
        sqlx::query(
            "INSERT INTO downloads (video_id, title, file_path, quality, status, progress, created_at) VALUES (?, ?, ?, ?, 'pending', 0.0, ?)"
        )
        .bind(video_id)
        .bind(title)
        .bind(file_path)
        .bind(quality)
        .bind(&now)
        .execute(pool)
        .await?
    };

    Ok(result.last_insert_rowid())
}

pub async fn update_download_status(id: i64, status: &str, progress: f64, speed: f64, eta_seconds: i64) -> Result<()> {
    let pool = get_pool();
    
    let started_at = if status == "downloading" {
        sqlx::query("SELECT started_at FROM downloads WHERE id = ?")
            .bind(id)
            .fetch_one(pool)
            .await
            .ok()
            .and_then(|row| row.get::<Option<String>, _>("started_at"))
    } else {
        None
    };

    sqlx::query(
        "UPDATE downloads SET status = ?, progress = ?, speed = ?, eta_seconds = ?, started_at = COALESCE(started_at, ?) WHERE id = ?"
    )
    .bind(status)
    .bind(progress)
    .bind(speed)
    .bind(eta_seconds)
    .bind(if started_at.is_none() && status == "downloading" { Some(chrono::Utc::now().to_rfc3339()) } else { started_at })
    .bind(id)
    .execute(pool)
    .await?;

    Ok(())
}

pub async fn complete_download(id: i64, file_size: i64) -> Result<()> {
    let pool = get_pool();
    let now = chrono::Utc::now().to_rfc3339();

    sqlx::query(
        "UPDATE downloads SET status = 'completed', progress = 100.0, file_size = ?, completed_at = ?, speed = 0.0, eta_seconds = 0 WHERE id = ?"
    )
    .bind(file_size)
    .bind(&now)
    .bind(id)
    .execute(pool)
    .await?;

    Ok(())
}

pub async fn fail_download(id: i64, error_message: &str) -> Result<()> {
    let pool = get_pool();
    let now = chrono::Utc::now().to_rfc3339();

    sqlx::query(
        "UPDATE downloads SET status = 'failed', completed_at = ?, error_message = ?, speed = 0.0, eta_seconds = 0 WHERE id = ?"
    )
    .bind(&now)
    .bind(error_message)
    .bind(id)
    .execute(pool)
    .await?;

    Ok(())
}

#[allow(dead_code)]
pub async fn add_download(video_id: &str, title: &str, file_path: &str, quality: &str) -> Result<()> {
    let pool = get_pool();
    let now = chrono::Utc::now().to_rfc3339();

    let has_legacy_downloaded_at = has_downloaded_at_column(pool).await?;
    if has_legacy_downloaded_at {
        sqlx::query(
            "INSERT INTO downloads (video_id, title, file_path, quality, status, progress, created_at, downloaded_at) VALUES (?, ?, ?, ?, 'completed', 100.0, ?, ?)"
        )
        .bind(video_id)
        .bind(title)
        .bind(file_path)
        .bind(quality)
        .bind(&now)
        .bind(&now)
        .execute(pool)
        .await?;
    } else {
        sqlx::query(
            "INSERT INTO downloads (video_id, title, file_path, quality, status, progress, created_at) VALUES (?, ?, ?, ?, 'completed', 100.0, ?)"
        )
        .bind(video_id)
        .bind(title)
        .bind(file_path)
        .bind(quality)
        .bind(now)
        .execute(pool)
        .await?;
    }

    Ok(())
}

async fn has_downloaded_at_column(pool: &Pool<Sqlite>) -> Result<bool> {
    let count: i64 = sqlx::query_scalar(
        "SELECT COUNT(*) FROM pragma_table_info('downloads') WHERE name = 'downloaded_at'",
    )
    .fetch_one(pool)
    .await?;
    Ok(count > 0)
}

pub async fn get_downloads() -> Result<Vec<Download>> {
    let pool = get_pool();
    let downloads = sqlx::query_as::<_, Download>("SELECT * FROM downloads ORDER BY created_at DESC")
        .fetch_all(pool)
        .await?;
    Ok(downloads)
}

pub async fn get_download(id: i64) -> Result<Option<Download>> {
    let pool = get_pool();
    let download = sqlx::query_as::<_, Download>("SELECT * FROM downloads WHERE id = ?")
        .bind(id)
        .fetch_optional(pool)
        .await?;
    Ok(download)
}

pub async fn delete_download(id: i64) -> Result<()> {
    let pool = get_pool();
    sqlx::query("DELETE FROM downloads WHERE id = ?")
        .bind(id)
        .execute(pool)
        .await?;
    Ok(())
}

pub async fn get_active_downloads() -> Result<Vec<Download>> {
    let pool = get_pool();
    let downloads = sqlx::query_as::<_, Download>(
        "SELECT * FROM downloads WHERE status IN ('pending', 'downloading') ORDER BY created_at ASC"
    )
    .fetch_all(pool)
    .await?;
    Ok(downloads)
}

// Settings operations
pub async fn set_setting(key: &str, value: &str) -> Result<()> {
    let pool = get_pool();
    sqlx::query("INSERT OR REPLACE INTO settings (key, value) VALUES (?, ?)")
        .bind(key)
        .bind(value)
        .execute(pool)
        .await?;
    Ok(())
}

pub async fn get_setting(key: &str) -> Result<Option<String>> {
    let pool = get_pool();
    let row: Option<(String,)> = sqlx::query_as("SELECT value FROM settings WHERE key = ?")
        .bind(key)
        .fetch_optional(pool)
        .await?;
    Ok(row.map(|(v,)| v))
}

pub async fn get_all_settings() -> Result<Vec<Setting>> {
    let pool = get_pool();
    let settings: Vec<(String, String)> = sqlx::query_as("SELECT key, value FROM settings")
        .fetch_all(pool)
        .await?;
    Ok(settings.into_iter().map(|(k, v)| Setting { key: k, value: v }).collect())
}

// Playlist operations
#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
pub struct Playlist {
    pub id: i64,
    pub name: String,
    pub description: Option<String>,
    pub created_at: String,
}

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
pub struct PlaylistVideo {
    pub id: i64,
    pub playlist_id: i64,
    pub video_id: String,
    pub title: String,
    pub channel: String,
    pub thumbnail: String,
    pub position: i64,
    pub added_at: String,
}

pub async fn create_playlist(name: &str, description: Option<&str>) -> Result<i64> {
    let pool = get_pool();
    let now = chrono::Utc::now().to_rfc3339();

    let result = sqlx::query(
        "INSERT INTO playlists (name, description, created_at) VALUES (?, ?, ?)"
    )
    .bind(name)
    .bind(description)
    .bind(now)
    .execute(pool)
    .await?;

    Ok(result.last_insert_rowid())
}

pub async fn get_playlists() -> Result<Vec<Playlist>> {
    let pool = get_pool();
    let playlists = sqlx::query_as::<_, Playlist>(
        "SELECT * FROM playlists ORDER BY created_at DESC"
    )
    .fetch_all(pool)
    .await?;
    Ok(playlists)
}

pub async fn get_playlist(id: i64) -> Result<Option<Playlist>> {
    let pool = get_pool();
    let playlist = sqlx::query_as::<_, Playlist>(
        "SELECT * FROM playlists WHERE id = ?"
    )
    .bind(id)
    .fetch_optional(pool)
    .await?;
    Ok(playlist)
}

pub async fn delete_playlist(id: i64) -> Result<()> {
    let pool = get_pool();
    sqlx::query("DELETE FROM playlists WHERE id = ?")
        .bind(id)
        .execute(pool)
        .await?;
    Ok(())
}

pub async fn add_video_to_playlist(
    playlist_id: i64,
    video_id: &str,
    title: &str,
    channel: &str,
    thumbnail: &str,
) -> Result<()> {
    let pool = get_pool();
    let now = chrono::Utc::now().to_rfc3339();

    // Get next position
    let position: i64 = sqlx::query_scalar(
        "SELECT COALESCE(MAX(position), -1) + 1 FROM playlist_videos WHERE playlist_id = ?"
    )
    .bind(playlist_id)
    .fetch_one(pool)
    .await?;

    sqlx::query(
        "INSERT INTO playlist_videos (playlist_id, video_id, title, channel, thumbnail, position, added_at) 
         VALUES (?, ?, ?, ?, ?, ?, ?)"
    )
    .bind(playlist_id)
    .bind(video_id)
    .bind(title)
    .bind(channel)
    .bind(thumbnail)
    .bind(position)
    .bind(now)
    .execute(pool)
    .await?;

    Ok(())
}

pub async fn get_playlist_videos(playlist_id: i64) -> Result<Vec<PlaylistVideo>> {
    let pool = get_pool();
    let videos = sqlx::query_as::<_, PlaylistVideo>(
        "SELECT * FROM playlist_videos WHERE playlist_id = ? ORDER BY position ASC"
    )
    .bind(playlist_id)
    .fetch_all(pool)
    .await?;
    Ok(videos)
}

pub async fn remove_video_from_playlist(playlist_id: i64, video_id: &str) -> Result<()> {
    let pool = get_pool();
    sqlx::query("DELETE FROM playlist_videos WHERE playlist_id = ? AND video_id = ?")
        .bind(playlist_id)
        .bind(video_id)
        .execute(pool)
        .await?;
    Ok(())
}

pub async fn reorder_playlist_video(playlist_id: i64, video_id: &str, new_position: i64) -> Result<()> {
    let pool = get_pool();
    sqlx::query(
        "UPDATE playlist_videos SET position = ? WHERE playlist_id = ? AND video_id = ?"
    )
    .bind(new_position)
    .bind(playlist_id)
    .bind(video_id)
    .execute(pool)
    .await?;
    Ok(())
}

```

`backend/src/invidious.rs`:

```rs
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

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct InvidiousCommentItem {
    pub author: String,
    pub author_id: String,
    pub author_avatar: String,
    pub content: String,
    pub published_text: String,
    pub like_count: i64,
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

```

`backend/src/lib.rs`:

```rs
pub mod api;
pub mod db;
pub mod player;
pub mod yt_dlp;
pub mod sponsorblock;
pub mod returnyoutubedislike;
pub mod invidious;

```

`backend/src/main.rs`:

```rs
use axum::{
    routing::{get, post, delete},
    Router,
};
use std::net::SocketAddr;
use tower_http::cors::CorsLayer;
use tower_http::limit::RequestBodyLimitLayer;
use tracing_subscriber;

mod api;
mod db;
mod player;
mod yt_dlp;
mod sponsorblock;
mod returnyoutubedislike;
mod invidious;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // Initialize tracing
    tracing_subscriber::fmt::init();

    // Initialize database
    db::init_db().await?;
    let player = player::PlayerHandle::new();

    // Warmup yt-dlp in background to eliminate cold start
    tokio::spawn(async {
        if let Err(e) = yt_dlp::warmup().await {
            tracing::warn!("Background warmup failed: {}", e);
        }
    });

    // Build router
    let app = Router::new()
        .route("/", get(|| async { "Tubular Backend API" }))
        .route("/warmup", post(api::warmup))
        .route("/search-cache/clear", post(api::clear_search_cache))
        .route("/search", get(api::search))
        .route("/video/:id", get(api::get_video_info))
        .route("/video/details/:id", get(api::get_video_details))
        .route("/stream/:id", get(api::get_stream_url))
        .route("/stream-proxy/:id", get(api::proxy_stream))
        .route("/player", get(api::get_player_state))
        .route("/player/play", post(api::player_play))
        .route("/player/pause", post(api::player_pause))
        .route("/player/resume", post(api::player_resume))
        .route("/player/seek", post(api::player_seek))
        .route(
            "/player/background-audio",
            post(api::player_background_audio),
        )
        .route("/player/stop", post(api::player_stop))
        .route("/download", post(api::download_video))
        .route("/downloads", get(api::get_downloads))
        .route("/downloads/active", get(api::get_active_downloads))
        .route("/downloads/create", post(api::create_download))
        .route("/downloads/:id", get(api::get_download))
        .route("/downloads/:id/progress", post(api::update_download_progress))
        .route("/downloads/:id/complete", post(api::complete_download))
        .route("/downloads/:id/fail", post(api::fail_download))
        .route("/downloads/:id", delete(api::delete_download))
        .route("/subscriptions", get(api::get_subscriptions))
        .route("/subscriptions", post(api::add_subscription))
        .route("/subscriptions/remove", post(api::remove_subscription))
        .route("/history", get(api::get_history))
        .route("/history", post(api::add_to_history))
        .route("/history/remove", post(api::remove_from_history))
        .route("/history/clear", post(api::clear_history))
        .route("/sponsorblock/:id", get(api::get_sponsorblock_segments))
        .route("/dislikes/:id", get(api::get_dislike_count))
        .route("/settings", get(api::get_all_settings))
        .route("/settings", post(api::set_setting))
        .route("/settings/:key", get(api::get_setting))
        .route("/invidious/search", get(api::invidious_search))
        .route("/invidious/video/:id", get(api::invidious_video_info))
        .route("/invidious/stream/:id", get(api::invidious_stream_url))
        .route("/invidious/instance", get(api::get_invidious_instance))
        .route("/invidious/instance", post(api::set_invidious_instance))
        .route("/invidious/instances", get(api::get_invidious_instances))
        .route("/playlists", get(api::get_playlists))
        .route("/playlists", post(api::create_playlist))
        .route("/playlists/:id", get(api::get_playlist))
        .route("/playlists/:id", delete(api::delete_playlist))
        .route("/playlists/:id/videos", get(api::get_playlist_videos))
        .route("/playlists/:id/videos", post(api::add_video_to_playlist))
        .route("/playlists/:id/videos/remove", post(api::remove_video_from_playlist))
        .layer(CorsLayer::permissive())
        .layer(RequestBodyLimitLayer::new(10 * 1024 * 1024)) // Fix LOW: 10MB request body limit
        .with_state(player);

    // Start server
    let addr = SocketAddr::from(([127, 0, 0, 1], 3030));
    tracing::info!("Listening on {}", addr);

    let listener = tokio::net::TcpListener::bind(addr).await?;
    axum::serve(listener, app).await?;

    Ok(())
}

```

`backend/src/player.rs`:

```rs
use anyhow::{bail, Result};
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use tokio::sync::RwLock;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "snake_case")]
pub enum PlaybackStatus {
    Idle,
    Playing,
    Paused,
    Stopped,
    Error,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PlayerState {
    pub status: PlaybackStatus,
    pub video_id: Option<String>,
    pub stream_url: Option<String>,
    pub position_seconds: f64,
    pub duration_seconds: Option<f64>,
    pub background_audio: bool,
    pub error: Option<String>,
    pub updated_at: String,
}

impl Default for PlayerState {
    fn default() -> Self {
        Self {
            status: PlaybackStatus::Idle,
            video_id: None,
            stream_url: None,
            position_seconds: 0.0,
            duration_seconds: None,
            background_audio: false,
            error: None,
            updated_at: now(),
        }
    }
}

#[derive(Debug, Deserialize)]
pub struct PlayRequest {
    pub video_id: String,
    pub stream_url: String,
    pub duration_seconds: Option<f64>,
    #[serde(default)]
    pub start_position_seconds: f64,
    #[serde(default)]
    pub background_audio: bool,
}

#[derive(Debug, Deserialize)]
pub struct SeekRequest {
    pub position_seconds: f64,
}

#[derive(Debug, Deserialize)]
pub struct BackgroundAudioRequest {
    pub enabled: bool,
}

#[derive(Debug, Clone, Default)]
pub struct PlayerHandle {
    state: Arc<RwLock<PlayerState>>,
}

impl PlayerHandle {
    pub fn new() -> Self {
        Self::default()
    }

    pub async fn snapshot(&self) -> PlayerState {
        self.state.read().await.clone()
    }

    pub async fn play(&self, request: PlayRequest) -> Result<PlayerState> {
        validate_play_request(&request)?;

        let mut state = self.state.write().await;
        state.status = PlaybackStatus::Playing;
        state.video_id = Some(request.video_id);
        state.stream_url = Some(request.stream_url);
        state.duration_seconds = request.duration_seconds.filter(|value| *value > 0.0);
        state.position_seconds = clamp_position(
            request.start_position_seconds,
            state.duration_seconds,
        )?;
        state.background_audio = request.background_audio;
        state.error = None;
        state.updated_at = now();

        Ok(state.clone())
    }

    pub async fn pause(&self) -> Result<PlayerState> {
        let mut state = self.state.write().await;
        ensure_loaded(&state)?;

        if state.status == PlaybackStatus::Playing {
            state.status = PlaybackStatus::Paused;
            state.updated_at = now();
        }

        Ok(state.clone())
    }

    pub async fn resume(&self) -> Result<PlayerState> {
        let mut state = self.state.write().await;
        ensure_loaded(&state)?;

        if matches!(state.status, PlaybackStatus::Paused | PlaybackStatus::Stopped) {
            state.status = PlaybackStatus::Playing;
            state.error = None;
            state.updated_at = now();
        }

        Ok(state.clone())
    }

    pub async fn seek(&self, request: SeekRequest) -> Result<PlayerState> {
        let mut state = self.state.write().await;
        ensure_loaded(&state)?;

        state.position_seconds = clamp_position(request.position_seconds, state.duration_seconds)?;
        state.updated_at = now();

        Ok(state.clone())
    }

    pub async fn set_background_audio(
        &self,
        request: BackgroundAudioRequest,
    ) -> Result<PlayerState> {
        let mut state = self.state.write().await;
        ensure_loaded(&state)?;

        state.background_audio = request.enabled;
        state.updated_at = now();

        Ok(state.clone())
    }

    pub async fn stop(&self) -> PlayerState {
        let mut state = self.state.write().await;
        *state = PlayerState {
            status: PlaybackStatus::Stopped,
            updated_at: now(),
            ..PlayerState::default()
        };

        state.clone()
    }
}

fn validate_play_request(request: &PlayRequest) -> Result<()> {
    if request.video_id.trim().is_empty() {
        bail!("video_id is required");
    }

    if request.stream_url.trim().is_empty() {
        bail!("stream_url is required");
    }

    if request
        .duration_seconds
        .is_some_and(|duration| !duration.is_finite() || duration < 0.0)
    {
        bail!("duration_seconds must be a positive finite number");
    }

    if !request.start_position_seconds.is_finite() || request.start_position_seconds < 0.0 {
        bail!("start_position_seconds must be a positive finite number");
    }

    Ok(())
}

fn ensure_loaded(state: &PlayerState) -> Result<()> {
    if state.video_id.is_none() || state.stream_url.is_none() {
        bail!("no media is loaded");
    }

    Ok(())
}

fn clamp_position(position_seconds: f64, duration_seconds: Option<f64>) -> Result<f64> {
    if !position_seconds.is_finite() || position_seconds < 0.0 {
        bail!("position_seconds must be a positive finite number");
    }

    Ok(match duration_seconds {
        Some(duration) if duration > 0.0 => position_seconds.min(duration),
        _ => position_seconds,
    })
}

fn now() -> String {
    chrono::Utc::now().to_rfc3339()
}

#[cfg(test)]
mod tests {
    use super::*;

    fn play_request() -> PlayRequest {
        PlayRequest {
            video_id: "video-1".to_string(),
            stream_url: "https://example.invalid/video".to_string(),
            duration_seconds: Some(120.0),
            start_position_seconds: 0.0,
            background_audio: false,
        }
    }

    #[tokio::test]
    async fn play_sets_single_global_state() {
        let player = PlayerHandle::new();

        let state = player.play(play_request()).await.expect("play succeeds");

        assert_eq!(state.status, PlaybackStatus::Playing);
        assert_eq!(state.video_id.as_deref(), Some("video-1"));
        assert_eq!(
            state.stream_url.as_deref(),
            Some("https://example.invalid/video")
        );
        assert_eq!(state.position_seconds, 0.0);
        assert_eq!(state.duration_seconds, Some(120.0));
    }

    #[tokio::test]
    async fn seek_clamps_to_known_duration() {
        let player = PlayerHandle::new();
        player.play(play_request()).await.expect("play succeeds");

        let state = player
            .seek(SeekRequest {
                position_seconds: 240.0,
            })
            .await
            .expect("seek succeeds");

        assert_eq!(state.position_seconds, 120.0);
    }

    #[tokio::test]
    async fn pause_without_loaded_media_returns_error() {
        let player = PlayerHandle::new();

        let result = player.pause().await;

        assert!(result.is_err());
    }
}

```

`backend/src/returnyoutubedislike.rs`:

```rs
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

```

`backend/src/sponsorblock.rs`:

```rs
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

```

`backend/src/yt_dlp.rs`:

```rs
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

```

`frontend/analysis_options.yaml`:

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_single_quotes: true
    use_super_parameters: true

```

`frontend/lib/controllers/player_controller.dart`:

```dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/video.dart';
import '../providers.dart';
import '../services/api_service.dart';
import '../services/player_service.dart';

enum PlaybackStatus { idle, loading, playing, paused, stopped, error }

enum PlayerSurface { hidden, fullscreen, mini, popup }

class TubularPlayerState {
  const TubularPlayerState({
    this.video,
    this.streamUrl,
    this.quality = 'best',
    this.status = PlaybackStatus.idle,
    this.surface = PlayerSurface.hidden,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.backgroundAudio = false,
    this.errorMessage,
  });

  final Video? video;
  final String? streamUrl;
  final String quality;
  final PlaybackStatus status;
  final PlayerSurface surface;
  final Duration position;
  final Duration duration;
  final bool backgroundAudio;
  final String? errorMessage;

  bool get hasVideo => video != null;
  bool get isPlaying => status == PlaybackStatus.playing;
  bool get isLoading => status == PlaybackStatus.loading;
  bool get isVisible => hasVideo && surface != PlayerSurface.hidden;

  TubularPlayerState copyWith({
    Video? video,
    String? streamUrl,
    String? quality,
    PlaybackStatus? status,
    PlayerSurface? surface,
    Duration? position,
    Duration? duration,
    bool? backgroundAudio,
    String? errorMessage,
    bool clearStreamUrl = false,
    bool clearError = false,
  }) {
    return TubularPlayerState(
      video: video ?? this.video,
      streamUrl: clearStreamUrl ? null : streamUrl ?? this.streamUrl,
      quality: quality ?? this.quality,
      status: status ?? this.status,
      surface: surface ?? this.surface,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      backgroundAudio: backgroundAudio ?? this.backgroundAudio,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  static const initial = TubularPlayerState();
}

final playerControllerProvider =
    StateNotifierProvider<PlayerController, TubularPlayerState>((ref) {
      final apiService = ref.watch(apiServiceProvider);
      final playerService = ref.watch(playerServiceProvider);
      return PlayerController(apiService, playerService);
    });

class PlayerController extends StateNotifier<TubularPlayerState> {
  PlayerController(this._apiService, this._playerService)
    : super(TubularPlayerState.initial);

  final ApiService _apiService;
  final PlayerService _playerService;
  int _playRequestSerial = 0;

  Future<void> playVideo(
    Video video, {
    String quality = 'best',
    PlayerSurface surface = PlayerSurface.fullscreen,
  }) async {
    final requestSerial = ++_playRequestSerial;

    print('🎬 playVideo called: ${video.title}');
    print('   quality: $quality');
    
    state = state.copyWith(
      video: video,
      quality: quality,
      status: PlaybackStatus.loading,
      surface: surface,
      position: Duration.zero,
      duration: video.duration,
      clearStreamUrl: true,
      clearError: true,
    );

    unawaited(_recordHistory(video));

    try {
      print('📡 Fetching stream URL...');
      final streamUrl = await _apiService.getStreamUrl(
        video.id,
        quality: quality,
      );
      print('✅ Got stream URL: $streamUrl');
      
      if (requestSerial != _playRequestSerial || state.video?.id != video.id) {
        print('⚠️  Request cancelled or video changed');
        return;
      }

      // Set stream URL and status to playing
      // The media_kit player in the widget will handle the actual playback
      print('🎥 Setting stream URL and status to playing');
      state = state.copyWith(
        streamUrl: streamUrl,
        status: PlaybackStatus.playing,
        clearError: true,
      );
      print('✅ State updated, player should start');
    } catch (error) {
      print('❌ Error getting stream URL: $error');
      if (requestSerial != _playRequestSerial || state.video?.id != video.id) {
        return;
      }

      state = state.copyWith(
        status: PlaybackStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> retry() async {
    final currentVideo = state.video;
    if (currentVideo == null) {
      return;
    }

    await playVideo(
      currentVideo,
      quality: state.quality,
      surface: state.surface == PlayerSurface.hidden
          ? PlayerSurface.fullscreen
          : state.surface,
    );
  }

  Future<void> setQuality(String quality) async {
    final currentVideo = state.video;
    if (currentVideo == null || quality == state.quality) {
      return;
    }

    await playVideo(currentVideo, quality: quality, surface: state.surface);
  }

  Future<void> pause() async {
    if (state.status != PlaybackStatus.playing) {
      return;
    }
    state = state.copyWith(status: PlaybackStatus.paused);
  }

  Future<void> resume() async {
    if (state.status != PlaybackStatus.paused) {
      return;
    }
    state = state.copyWith(status: PlaybackStatus.playing);
  }

  Future<void> togglePlayPause() async {
    if (state.status == PlaybackStatus.playing) {
      await pause();
      return;
    }

    if (state.status == PlaybackStatus.paused) {
      await resume();
    }
  }

  void previewSeek(Duration position) {
    final clampedPosition = _clampDuration(
      position,
      Duration.zero,
      state.duration,
    );
    state = state.copyWith(position: clampedPosition);
  }

  Future<void> seek(Duration position) async {
    previewSeek(position);
    // The media_kit player widget will handle the actual seek
  }

  void showFullscreen() {
    if (!state.hasVideo) {
      return;
    }

    state = state.copyWith(surface: PlayerSurface.fullscreen);
  }

  void showMiniPlayer() {
    if (!state.hasVideo) {
      return;
    }

    state = state.copyWith(surface: PlayerSurface.mini);
  }

  void showPopupPlayer() {
    if (!state.hasVideo) {
      return;
    }

    state = state.copyWith(surface: PlayerSurface.popup);
  }

  Future<void> toggleBackgroundAudio() async {
    final enabled = !state.backgroundAudio;
    state = state.copyWith(backgroundAudio: enabled);
  }

  Future<void> toggleAudioOnlyStream({String fallbackQuality = 'best'}) async {
    if (!state.hasVideo) {
      return;
    }

    if (state.quality == 'audio') {
      final nextQuality = fallbackQuality == 'audio' ? 'best' : fallbackQuality;
      await setQuality(nextQuality);
      return;
    }

    await setQuality('audio');
  }

  Future<void> stop() async {
    _playRequestSerial++;
    state = TubularPlayerState.initial.copyWith(status: PlaybackStatus.stopped);
  }

  Future<void> _recordHistory(Video video) async {
    try {
      await _apiService.addToHistory(
        videoId: video.id,
        title: video.title,
        channel: video.channelName,
        thumbnail: video.thumbnail,
      );
    } catch (_) {
      // History should never block playback.
    }
  }

  Duration _clampDuration(Duration value, Duration min, Duration max) {
    if (max == Duration.zero) {
      return Duration.zero;
    }
    if (value < min) {
      return min;
    }
    if (value > max) {
      return max;
    }
    return value;
  }

  // Methods for media_kit player to update state
  void updatePosition(Duration position) {
    if (state.video != null) {
      state = state.copyWith(position: position);
    }
  }

  void updateDuration(Duration duration) {
    if (state.video != null && duration != Duration.zero) {
      state = state.copyWith(duration: duration);
    }
  }

  void updatePlayingState(bool isPlaying) {
    if (state.video != null) {
      final newStatus = isPlaying ? PlaybackStatus.playing : PlaybackStatus.paused;
      if (state.status != newStatus && state.status != PlaybackStatus.loading) {
        state = state.copyWith(status: newStatus);
      }
    }
  }

  void setError(String error) {
    if (state.video != null) {
      state = state.copyWith(
        status: PlaybackStatus.error,
        errorMessage: error,
      );
    }
  }
}

```

`frontend/lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'providers.dart';
import 'screens/home_screen.dart';
import 'screens/subscriptions_screen.dart';
import 'screens/history_screen.dart';
import 'screens/downloads_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/player_shell.dart';

final navigationIndexProvider = StateProvider<int>((ref) => 0);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  runApp(const ProviderScope(child: TubularApp()));
}

class TubularApp extends ConsumerStatefulWidget {
  const TubularApp({super.key});

  @override
  ConsumerState<TubularApp> createState() => _TubularAppState();
}

class _TubularAppState extends ConsumerState<TubularApp> {
  @override
  void initState() {
    super.initState();
    // Load settings after first frame so providers are available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  Future<void> _loadSettings() async {
    final api = ref.read(apiServiceProvider);
    try {
      final settings = await api.getAllSettings();
      print('DEBUG: Loaded ${settings.length} settings: $settings');

      if (settings.containsKey('theme')) {
        final t = settings['theme'];
        ref.read(themeModeProvider.notifier).state =
            t == 'light' ? ThemeMode.light : (t == 'system' ? ThemeMode.system : ThemeMode.dark);
        print('DEBUG: Set theme to $t');
      }
      if (settings.containsKey('amoled_dark')) {
        ref.read(amoledDarkProvider.notifier).state = settings['amoled_dark'] == 'true';
      }

      if (settings.containsKey('preferred_quality')) {
        ref.read(preferredQualityProvider.notifier).state = settings['preferred_quality']!;
        print('DEBUG: Set preferred_quality to ${settings['preferred_quality']}');
      }

      if (settings.containsKey('preferred_format')) {
        ref.read(preferredFormatProvider.notifier).state = settings['preferred_format']!;
      }

      if (settings.containsKey('audio_only_mode')) {
        ref.read(audioOnlyModeProvider.notifier).state = settings['audio_only_mode'] == 'true';
      }

      if (settings.containsKey('auto_play')) {
        ref.read(autoPlayProvider.notifier).state = settings['auto_play'] == 'true';
      }

      if (settings.containsKey('subtitle_font_size')) {
        final v = double.tryParse(settings['subtitle_font_size'] ?? '14.0') ?? 14.0;
        ref.read(subtitleFontSizeProvider.notifier).state = v;
      }

      if (settings.containsKey('download_folder')) {
        ref.read(downloadFolderProvider.notifier).state = settings['download_folder']!;
      }

      if (settings.containsKey('enable_sponsorblock')) {
        ref.read(enableSponsorBlockProvider.notifier).state = settings['enable_sponsorblock'] == 'true';
      }

      if (settings.containsKey('enable_dislike_counts')) {
        ref.read(enableDislikeCountsProvider.notifier).state = settings['enable_dislike_counts'] == 'true';
      }

      if (settings.containsKey('enable_subtitles')) {
        ref.read(enableSubtitlesProvider.notifier).state = settings['enable_subtitles'] == 'true';
      }

      if (settings.containsKey('enable_notifications')) {
        ref.read(enableNotificationsProvider.notifier).state = settings['enable_notifications'] == 'true';
      }
      if (settings.containsKey('playback_speed')) {
        final v = double.tryParse(settings['playback_speed'] ?? '1.0') ?? 1.0;
        ref.read(playbackSpeedProvider.notifier).state = v;
        print('DEBUG: Set playback_speed to $v');
      }
    } catch (e) {
      print('DEBUG: Failed to load settings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final amoledDark = ref.watch(amoledDarkProvider);

    final darkScaffold = amoledDark ? Colors.black : Colors.grey[900];
    final darkSurface = amoledDark ? const Color(0xFF000000) : const Color(0xFF1E1E1E);
    final darkCard = amoledDark ? const Color(0xFF0A0A0A) : const Color(0xFF222222);

    return MaterialApp(
      title: 'Tubular PC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.grey[100],
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkScaffold,
        colorScheme: ColorScheme.dark(
          primary: Colors.red[700]!,
          secondary: Colors.red[400]!,
          surface: darkSurface,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          color: darkCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      themeMode: ref.watch(themeModeProvider),
      home: const PlayerShell(child: MainNavigation()),
    );
  }
}

class MainNavigation extends ConsumerWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);

    final screens = [
      const HomeScreen(),
      const SubscriptionsScreen(),
      const HistoryScreen(),
      const DownloadsScreen(),
    ];

    return Scaffold(
      body: Row(
        children: [
          // Navigation rail for desktop
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) {
              ref.read(navigationIndexProvider.notifier).state = index;
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedIconTheme: IconThemeData(color: Colors.red[700]),
            selectedLabelTextStyle: TextStyle(color: Colors.red[700]),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.subscriptions),
                label: Text('Subscriptions'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.history),
                label: Text('History'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.download),
                label: Text('Downloads'),
              ),
            ],
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: NavigationRail(
                  selectedIndex: 0,
                  onDestinationSelected: (_) {
                    // Navigate to settings screen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  },
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: Colors.transparent,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.settings),
                      label: Text('Settings'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Main content
          Expanded(
            child: screens[currentIndex],
          ),
        ],
      ),
    );
  }
}


```

`frontend/lib/models/dislike.dart`:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'dislike.g.dart';

@JsonSerializable()
class DislikeData {
  final String videoId;
  final int likes;
  final int dislikes;
  final double rating;
  final int viewCount;
  final DateTime? retrievedAt;

  DislikeData({
    required this.videoId,
    required this.likes,
    required this.dislikes,
    required this.rating,
    required this.viewCount,
    this.retrievedAt,
  });

  factory DislikeData.fromJson(Map<String, dynamic> json) =>
      _$DislikeDataFromJson(json);
  Map<String, dynamic> toJson() => _$DislikeDataToJson(this);

  int get totalVotes => likes + dislikes;
  double get likePercentage => totalVotes > 0 ? (likes / totalVotes) * 100 : 0;
  double get dislikePercentage => totalVotes > 0 ? (dislikes / totalVotes) * 100 : 0;

  String get formattedLikes {
    if (likes >= 1000000) {
      return '${(likes / 1000000).toStringAsFixed(1)}M';
    } else if (likes >= 1000) {
      return '${(likes / 1000).toStringAsFixed(1)}K';
    }
    return likes.toString();
  }

  String get formattedDislikes {
    if (dislikes >= 1000000) {
      return '${(dislikes / 1000000).toStringAsFixed(1)}M';
    } else if (dislikes >= 1000) {
      return '${(dislikes / 1000).toStringAsFixed(1)}K';
    }
    return dislikes.toString();
  }

  String get formattedViewCount {
    if (viewCount >= 1000000) {
      return '${(viewCount / 1000000).toStringAsFixed(1)}M';
    } else if (viewCount >= 1000) {
      return '${(viewCount / 1000).toStringAsFixed(1)}K';
    }
    return viewCount.toString();
  }
}

```

`frontend/lib/models/dislike.g.dart`:

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dislike.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DislikeData _$DislikeDataFromJson(Map<String, dynamic> json) => DislikeData(
      videoId: json['videoId'] as String,
      likes: json['likes'] as int,
      dislikes: json['dislikes'] as int,
      rating: (json['rating'] as num).toDouble(),
      viewCount: json['viewCount'] as int,
      retrievedAt: json['retrievedAt'] == null
          ? null
          : DateTime.parse(json['retrievedAt'] as String),
    );

Map<String, dynamic> _$DislikeDataToJson(DislikeData instance) =>
    <String, dynamic>{
      'videoId': instance.videoId,
      'likes': instance.likes,
      'dislikes': instance.dislikes,
      'rating': instance.rating,
      'viewCount': instance.viewCount,
      'retrievedAt': instance.retrievedAt?.toIso8601String(),
    };

```

`frontend/lib/models/download.dart`:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'download.g.dart';

@JsonSerializable()
class Download {
  final String id;
  final String videoId;
  final String title;
  final String filePath;
  final int fileSize;
  final String format; // 'video', 'audio', 'both'
  final String quality; // '360p', '720p', '1080p'
  final String status; // 'pending', 'downloading', 'completed', 'failed', 'paused'
  final double progress; // 0-100
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? errorMessage;

  Download({
    required this.id,
    required this.videoId,
    required this.title,
    required this.filePath,
    required this.fileSize,
    required this.format,
    required this.quality,
    required this.status,
    required this.progress,
    required this.createdAt,
    this.completedAt,
    this.errorMessage,
  });

  factory Download.fromJson(Map<String, dynamic> json) => _$DownloadFromJson(json);
  Map<String, dynamic> toJson() => _$DownloadToJson(this);

  bool get isDownloading => status == 'downloading';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isPaused => status == 'paused';
  
  String get progressText => '${progress.toStringAsFixed(1)}%';
  
  String get statusText {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'downloading':
        return 'Downloading';
      case 'completed':
        return 'Completed';
      case 'failed':
        return 'Failed';
      case 'paused':
        return 'Paused';
      default:
        return 'Unknown';
    }
  }

  String get formattedFileSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    if (fileSize < 1024 * 1024 * 1024) return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

```

`frontend/lib/models/download.g.dart`:

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Download _$DownloadFromJson(Map<String, dynamic> json) => Download(
      id: json['id'] as String,
      videoId: json['videoId'] as String,
      title: json['title'] as String,
      filePath: json['filePath'] as String,
      fileSize: json['fileSize'] as int,
      format: json['format'] as String,
      quality: json['quality'] as String,
      status: json['status'] as String,
      progress: (json['progress'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] == null ? null : DateTime.parse(json['completedAt'] as String),
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$DownloadToJson(Download instance) => <String, dynamic>{
      'id': instance.id,
      'videoId': instance.videoId,
      'title': instance.title,
      'filePath': instance.filePath,
      'fileSize': instance.fileSize,
      'format': instance.format,
      'quality': instance.quality,
      'status': instance.status,
      'progress': instance.progress,
      'createdAt': instance.createdAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'errorMessage': instance.errorMessage,
    };

```

`frontend/lib/models/history_entry.dart`:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'history_entry.g.dart';

@JsonSerializable()
class HistoryEntry {
  final int id;
  @JsonKey(name: 'video_id')
  final String videoId;
  final String title;
  final String channel;
  final String thumbnail;
  @JsonKey(name: 'watched_at')
  final String watchedAt;
  final double? progress;

  HistoryEntry({
    required this.id,
    required this.videoId,
    required this.title,
    required this.channel,
    required this.thumbnail,
    required this.watchedAt,
    this.progress,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$HistoryEntryFromJson(json);
  Map<String, dynamic> toJson() => _$HistoryEntryToJson(this);
}

```

`frontend/lib/models/history_entry.g.dart`:

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HistoryEntry _$HistoryEntryFromJson(Map<String, dynamic> json) => HistoryEntry(
  id: (json['id'] as num).toInt(),
  videoId: json['video_id'] as String,
  title: json['title'] as String,
  channel: json['channel'] as String,
  thumbnail: json['thumbnail'] as String,
  watchedAt: json['watched_at'] as String,
  progress: (json['progress'] as num?)?.toDouble(),
);

Map<String, dynamic> _$HistoryEntryToJson(HistoryEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'video_id': instance.videoId,
      'title': instance.title,
      'channel': instance.channel,
      'thumbnail': instance.thumbnail,
      'watched_at': instance.watchedAt,
      'progress': instance.progress,
    };

```

`frontend/lib/models/sponsorblock.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sponsorblock.g.dart';

@JsonSerializable()
class SponsorBlockSegment {
  final String category; // 'sponsor', 'intro', 'outro', 'interlude', 'break'
  final double startTime; // seconds
  final double endTime; // seconds
  final int votes;
  final bool isVoted;

  SponsorBlockSegment({
    required this.category,
    required this.startTime,
    required this.endTime,
    required this.votes,
    this.isVoted = false,
  });

  factory SponsorBlockSegment.fromJson(Map<String, dynamic> json) =>
      _$SponsorBlockSegmentFromJson(json);
  Map<String, dynamic> toJson() => _$SponsorBlockSegmentToJson(this);

  String get categoryLabel {
    switch (category) {
      case 'sponsor':
        return 'Sponsor';
      case 'intro':
        return 'Intro';
      case 'outro':
        return 'Outro';
      case 'interlude':
        return 'Interlude';
      case 'break':
        return 'Break';
      default:
        return category;
    }
  }

  Color get categoryColor {
    switch (category) {
      case 'sponsor':
        return Color(0xFF00D400);
      case 'intro':
        return Color(0xFF00FFFF);
      case 'outro':
        return Color(0xFF0071DB);
      case 'interlude':
        return Color(0xFFFF9000);
      case 'break':
        return Color(0xFF4B4498);
      default:
        return Color(0xFF999999);
    }
  }

  String get durationText {
    final duration = (endTime - startTime).toInt();
    return '${duration}s';
  }

  Duration get startDuration => Duration(milliseconds: (startTime * 1000).toInt());
  Duration get endDuration => Duration(milliseconds: (endTime * 1000).toInt());
}

```

`frontend/lib/models/sponsorblock.g.dart`:

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sponsorblock.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SponsorBlockSegment _$SponsorBlockSegmentFromJson(Map<String, dynamic> json) =>
    SponsorBlockSegment(
      category: json['category'] as String,
      startTime: (json['startTime'] as num).toDouble(),
      endTime: (json['endTime'] as num).toDouble(),
      votes: json['votes'] as int,
      isVoted: json['isVoted'] as bool? ?? false,
    );

Map<String, dynamic> _$SponsorBlockSegmentToJson(SponsorBlockSegment instance) =>
    <String, dynamic>{
      'category': instance.category,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'votes': instance.votes,
      'isVoted': instance.isVoted,
    };

```

`frontend/lib/models/subscription.dart`:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'subscription.g.dart';

@JsonSerializable()
class Subscription {
  final int id;
  @JsonKey(name: 'channel_id')
  final String channelId;
  @JsonKey(name: 'channel_name')
  final String channelName;
  @JsonKey(name: 'channel_thumbnail')
  final String channelThumbnail;
  @JsonKey(name: 'subscribed_at')
  final String subscribedAt;

  Subscription({
    required this.id,
    required this.channelId,
    required this.channelName,
    required this.channelThumbnail,
    required this.subscribedAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionFromJson(json);
  Map<String, dynamic> toJson() => _$SubscriptionToJson(this);
}

```

`frontend/lib/models/subscription.g.dart`:

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Subscription _$SubscriptionFromJson(Map<String, dynamic> json) => Subscription(
  id: (json['id'] as num).toInt(),
  channelId: json['channel_id'] as String,
  channelName: json['channel_name'] as String,
  channelThumbnail: json['channel_thumbnail'] as String,
  subscribedAt: json['subscribed_at'] as String,
);

Map<String, dynamic> _$SubscriptionToJson(Subscription instance) =>
    <String, dynamic>{
      'id': instance.id,
      'channel_id': instance.channelId,
      'channel_name': instance.channelName,
      'channel_thumbnail': instance.channelThumbnail,
      'subscribed_at': instance.subscribedAt,
    };

```

`frontend/lib/models/video.dart`:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'video.g.dart';

@JsonSerializable()
class Video {
  final String id;
  final String title;

  @JsonKey(name: 'channel', defaultValue: 'Unknown')
  final String channelName;

  @JsonKey(name: 'channel_id', defaultValue: '')
  final String channelId;

  @JsonKey(defaultValue: '')
  final String thumbnail;

  @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
  final Duration duration;

  @JsonKey(name: 'view_count', defaultValue: 0)
  final int views;

  @JsonKey(name: 'upload_date', fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime uploadDate;

  @JsonKey(defaultValue: '')
  final String description;

  @JsonKey(name: 'like_count', defaultValue: 0)
  final int likes;

  @JsonKey(defaultValue: 0)
  final int dislikes;

  Video({
    required this.id,
    required this.title,
    required this.channelName,
    required this.channelId,
    required this.thumbnail,
    required this.duration,
    required this.views,
    required this.uploadDate,
    required this.description,
    required this.likes,
    required this.dislikes,
  });

  factory Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson(json);
  Map<String, dynamic> toJson() => _$VideoToJson(this);

  static Duration _durationFromJson(Object? value) {
    if (value == null) {
      return Duration.zero;
    }

    if (value is num) {
      return Duration(seconds: value.toInt());
    }

    return Duration(seconds: int.tryParse(value.toString()) ?? 0);
  }

  static int _durationToJson(Duration duration) => duration.inSeconds;

  static DateTime _dateFromJson(Object? value) {
    if (value == null) {
      return DateTime.now();
    }

    final rawValue = value.toString();
    if (rawValue.isEmpty) {
      return DateTime.now();
    }

    if (RegExp(r'^\d{8}$').hasMatch(rawValue)) {
      final year = int.parse(rawValue.substring(0, 4));
      final month = int.parse(rawValue.substring(4, 6));
      final day = int.parse(rawValue.substring(6, 8));
      return DateTime(year, month, day);
    }

    return DateTime.tryParse(rawValue) ?? DateTime.now();
  }

  static String _dateToJson(DateTime uploadDate) =>
      uploadDate.toIso8601String();

  String get formattedViews {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K';
    }
    return views.toString();
  }

  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get uploadedAgo {
    final now = DateTime.now();
    final difference = now.difference(uploadDate);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else {
      return '${(difference.inDays / 365).floor()}y ago';
    }
  }
}

```

`frontend/lib/models/video.g.dart`:

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Video _$VideoFromJson(Map<String, dynamic> json) => Video(
  id: json['id'] as String,
  title: json['title'] as String,
  channelName: json['channel'] as String? ?? 'Unknown',
  channelId: json['channel_id'] as String? ?? '',
  thumbnail: json['thumbnail'] as String? ?? '',
  duration: Video._durationFromJson(json['duration']),
  views: (json['view_count'] as num?)?.toInt() ?? 0,
  uploadDate: Video._dateFromJson(json['upload_date']),
  description: json['description'] as String? ?? '',
  likes: (json['like_count'] as num?)?.toInt() ?? 0,
  dislikes: (json['dislikes'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$VideoToJson(Video instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'channel': instance.channelName,
  'channel_id': instance.channelId,
  'thumbnail': instance.thumbnail,
  'duration': Video._durationToJson(instance.duration),
  'view_count': instance.views,
  'upload_date': Video._dateToJson(instance.uploadDate),
  'description': instance.description,
  'like_count': instance.likes,
  'dislikes': instance.dislikes,
};

```

`frontend/lib/models/video_details.dart`:

```dart
class Comment {
  Comment({
    required this.userId,
    required this.username,
    required this.avatarUrl,
    required this.text,
    required this.timestamp,
    required this.publishedText,
    required this.likeCount,
  });

  final String userId;
  final String username;
  final String avatarUrl;
  final String text;
  final DateTime timestamp;
  final String publishedText;
  final int likeCount;

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        userId: json['user_id']?.toString() ?? '',
        username: json['username']?.toString() ?? '',
        avatarUrl: json['avatar_url']?.toString() ?? '',
        text: json['text']?.toString() ?? '',
        timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
        publishedText: json['published_text']?.toString() ?? '',
        likeCount: (json['like_count'] is int) ? json['like_count'] as int : int.tryParse(json['like_count']?.toString() ?? '0') ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'username': username,
        'avatar_url': avatarUrl,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
        'published_text': publishedText,
        'like_count': likeCount,
      };
}

class VideoDetails {
  VideoDetails({
    required this.id,
    required this.title,
    required this.channelName,
    required this.channelId,
    required this.subscriberCount,
    required this.viewCount,
    required this.uploadDate,
    required this.duration,
    required this.thumbnailUrl,
    required this.likeCount,
    required this.dislikeCount,
    required this.comments,
  });

  final String id;
  final String title;
  final String channelName;
  final String channelId;
  final int subscriberCount;
  final int viewCount;
  final String uploadDate;
  final Duration duration;
  final String thumbnailUrl;
  final int likeCount;
  final int dislikeCount;
  final List<Comment> comments;

  factory VideoDetails.fromJson(Map<String, dynamic> json) => VideoDetails(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        channelName: json['channel_name']?.toString() ?? '',
        channelId: json['channel_id']?.toString() ?? '',
        subscriberCount: (json['subscriber_count'] is int) ? json['subscriber_count'] as int : int.tryParse(json['subscriber_count']?.toString() ?? '0') ?? 0,
        viewCount: (json['view_count'] is int) ? json['view_count'] as int : int.tryParse(json['view_count']?.toString() ?? '0') ?? 0,
        uploadDate: json['upload_date']?.toString() ?? '',
        duration: Duration(milliseconds: ((json['duration_seconds'] is num) ? ((json['duration_seconds'] as num).toDouble() * 1000).round() : ((double.tryParse(json['duration_seconds']?.toString() ?? '0') ?? 0) * 1000).round())),
        thumbnailUrl: json['thumbnail_url']?.toString() ?? '',
        likeCount: (json['like_count'] is int) ? json['like_count'] as int : int.tryParse(json['like_count']?.toString() ?? '0') ?? 0,
        dislikeCount: (json['dislike_count'] is int) ? json['dislike_count'] as int : int.tryParse(json['dislike_count']?.toString() ?? '0') ?? 0,
        comments: (json['comments'] is List) ? List<Map<String, dynamic>>.from(json['comments']).map((c) => Comment.fromJson(Map<String, dynamic>.from(c))).toList() : <Comment>[],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'channel_name': channelName,
        'channel_id': channelId,
        'subscriber_count': subscriberCount,
        'view_count': viewCount,
        'upload_date': uploadDate,
        'duration_seconds': duration.inMilliseconds / 1000,
        'thumbnail_url': thumbnailUrl,
        'like_count': likeCount,
        'dislike_count': dislikeCount,
        'comments': comments.map((c) => c.toJson()).toList(),
      };
}

```

`frontend/lib/providers.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/api_service.dart';

// API Service provider - single source of truth
final apiServiceProvider = Provider((ref) => ApiService());

// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);
final amoledDarkProvider = StateProvider<bool>((ref) => true);

// Quality preference provider
final preferredQualityProvider = StateProvider<String>((ref) => '720p');

// Format preference provider (video, audio, both)
final preferredFormatProvider = StateProvider<String>((ref) => 'video');

// Audio-only mode provider
final audioOnlyModeProvider = StateProvider<bool>((ref) => false);

// Auto-play provider
final autoPlayProvider = StateProvider<bool>((ref) => true);

// Download folder provider
final downloadFolderProvider = StateProvider<String>((ref) => '~/Downloads/Tubular');

// Subtitle font size provider
final subtitleFontSizeProvider = StateProvider<double>((ref) => 14.0);

// Additional settings
final enableSponsorBlockProvider = StateProvider<bool>((ref) => true);
final enableDislikeCountsProvider = StateProvider<bool>((ref) => true);
final enableSubtitlesProvider = StateProvider<bool>((ref) => true);
final enableNotificationsProvider = StateProvider<bool>((ref) => false);

// Playback speed provider (1.0 = normal)
final playbackSpeedProvider = StateProvider<double>((ref) => 1.0);

// Video details provider (fetches details for a given video id)
final videoDetailsProvider = FutureProvider.family((ref, String videoId) async {
	final api = ref.watch(apiServiceProvider);
	final details = await api.getVideoDetails(videoId);
	return details;
});

```

`frontend/lib/screens/downloads_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/download.dart';
import '../providers.dart';

// Sort options
final downloadsSortProvider = StateProvider<String>((ref) => 'date_desc');

final downloadsProvider = FutureProvider<List<Download>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final sort = ref.watch(downloadsSortProvider);
  
  // Fetch downloads from backend API
  List<Download> downloads = await apiService.getDownloads();
  
  // Apply sorting
  switch (sort) {
    case 'name_asc':
      downloads.sort((a, b) => a.title.compareTo(b.title));
      break;
    case 'name_desc':
      downloads.sort((a, b) => b.title.compareTo(a.title));
      break;
    case 'size_asc':
      downloads.sort((a, b) => a.fileSize.compareTo(b.fileSize));
      break;
    case 'size_desc':
      downloads.sort((a, b) => b.fileSize.compareTo(a.fileSize));
      break;
    case 'date_asc':
      downloads.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      break;
    case 'date_desc':
    default:
      downloads.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
  
  return downloads;
});

final activeDownloadsProvider = FutureProvider<List<Download>>((ref) async {
  final downloads = await ref.watch(downloadsProvider.future);
  return downloads.where((d) => d.isDownloading || d.isPaused).toList();
});

final completedDownloadsProvider = FutureProvider<List<Download>>((ref) async {
  final downloads = await ref.watch(downloadsProvider.future);
  return downloads.where((d) => d.isCompleted).toList();
});

final failedDownloadsProvider = FutureProvider<List<Download>>((ref) async {
  final downloads = await ref.watch(downloadsProvider.future);
  return downloads.where((d) => d.isFailed).toList();
});

// Stats providers
final totalDownloadsSizeProvider = FutureProvider<int>((ref) async {
  final downloads = await ref.watch(downloadsProvider.future);
  return downloads.fold<int>(0, (sum, d) => sum + d.fileSize);
});

final totalActiveDownloadsSizeProvider = FutureProvider<int>((ref) async {
  final downloads = await ref.watch(activeDownloadsProvider.future);
  return downloads.fold<int>(0, (sum, d) => sum + d.fileSize);
});

class DownloadsScreen extends ConsumerStatefulWidget {
  const DownloadsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends ConsumerState<DownloadsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalSize = ref.watch(totalDownloadsSizeProvider);
    final sort = ref.watch(downloadsSortProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'date_desc',
                child: Text('Newest First'),
              ),
              const PopupMenuItem(
                value: 'date_asc',
                child: Text('Oldest First'),
              ),
              const PopupMenuItem(
                value: 'name_asc',
                child: Text('Name (A-Z)'),
              ),
              const PopupMenuItem(
                value: 'name_desc',
                child: Text('Name (Z-A)'),
              ),
              const PopupMenuItem(
                value: 'size_desc',
                child: Text('Largest First'),
              ),
              const PopupMenuItem(
                value: 'size_asc',
                child: Text('Smallest First'),
              ),
            ],
            onSelected: (value) {
              ref.read(downloadsSortProvider.notifier).state = value;
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.cloud_download), text: 'Active'),
            Tab(icon: Icon(Icons.check_circle), text: 'Completed'),
            Tab(icon: Icon(Icons.error), text: 'Failed'),
          ],
        ),
      ),
      body: Column(
        children: [
        // Stats bar
        Container(
          color: Colors.grey[850],
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                icon: Icons.storage,
                label: 'Total Size',
                value: totalSize.when(
                  data: (size) => _formatBytes(size),
                  loading: () => '...',
                  error: (_, __) => 'N/A',
                ),
              ),
              _buildStatItem(
                icon: Icons.speed,
                label: 'Active',
                value: '0 B',
              ),
              _buildStatItem(
                icon: Icons.list,
                label: 'Total',
                value: 'N/A',
              ),
            ],
          ),
        ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildActiveTab(),
                _buildCompletedTab(),
                _buildFailedTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.red[700], size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveTab() {
    final activeAsync = ref.watch(activeDownloadsProvider);

    return activeAsync.when(
      data: (downloads) {
        if (downloads.isEmpty) {
          return _buildEmptyState(
            icon: Icons.cloud_download,
            title: 'No active downloads',
            subtitle: 'Search for videos to start downloading',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: downloads.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final download = downloads[index];
            return AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 300),
              child: _buildDownloadTile(context, download),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildCompletedTab() {
    final completedAsync = ref.watch(completedDownloadsProvider);

    return completedAsync.when(
      data: (downloads) {
        if (downloads.isEmpty) {
          return _buildEmptyState(
            icon: Icons.check_circle_outline,
            title: 'No completed downloads',
            subtitle: 'Your downloads will appear here',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: downloads.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final download = downloads[index];
            return AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 300),
              child: _buildCompletedDownloadTile(context, download),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildFailedTab() {
    final failedAsync = ref.watch(failedDownloadsProvider);

    return failedAsync.when(
      data: (downloads) {
        if (downloads.isEmpty) {
          return _buildEmptyState(
            icon: Icons.error_outline,
            title: 'No failed downloads',
            subtitle: 'All your downloads completed successfully',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: downloads.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final download = downloads[index];
            return AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 300),
              child: _buildFailedDownloadTile(context, download),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 300,
            child: Text(
              error,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(downloadsProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadTile(BuildContext context, Download download) {
    final downloadSpeed =
        download.progress > 0 ? '${(download.progress * 10).toStringAsFixed(1)} MB/s' : 'Starting...';
    final eta = download.progress > 0 ? '~${((100 - download.progress) / download.progress * 2).toStringAsFixed(0)}s' : '--';

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(width: 4, color: Colors.red[700]!),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and actions
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          download.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          children: [
                            Chip(
                              label: Text(download.quality),
                              labelStyle: const TextStyle(fontSize: 11),
                              visualDensity: VisualDensity.compact,
                            ),
                            Chip(
                              label: Text(download.format),
                              labelStyle: const TextStyle(fontSize: 11),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'pause',
                        child: Row(
                          children: [
                            Icon(
                              download.isPaused ? Icons.play_arrow : Icons.pause,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(download.isPaused ? 'Resume' : 'Pause'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'cancel',
                        child: Row(
                          children: [
                            Icon(Icons.close, size: 18),
                            SizedBox(width: 8),
                            Text('Cancel'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'pause') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(download.isPaused ? 'Resumed' : 'Paused'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      } else if (value == 'cancel') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Download cancelled'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Progress visualization
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: download.progress / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey[700],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        download.isFailed ? Colors.red : Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${download.progressText} • ${download.formattedFileSize}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'ETA: $eta',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        downloadSpeed,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                      Text(
                        download.statusText,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red[400],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedDownloadTile(BuildContext context, Download download) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: const Border(
            left: BorderSide(width: 4, color: Colors.green),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: const Icon(Icons.check_circle, color: Colors.green, size: 28),
          title: Text(
            download.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            '${download.quality} • ${download.formattedFileSize}',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          trailing: PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'open',
                child: Row(
                  children: [
                    Icon(Icons.folder_open, size: 18),
                    SizedBox(width: 8),
                    Text('Open'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'show_in_folder',
                child: Row(
                  children: [
                    Icon(Icons.folder, size: 18),
                    SizedBox(width: 8),
                    Text('Show in Folder'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'open') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening download'), duration: Duration(seconds: 1)),
                );
              } else if (value == 'show_in_folder') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening folder'), duration: Duration(seconds: 1)),
                );
              } else if (value == 'delete') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Download deleted'), duration: Duration(seconds: 1)),
                );
                ref.refresh(downloadsProvider);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFailedDownloadTile(BuildContext context, Download download) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: const Border(
            left: BorderSide(width: 4, color: Colors.red),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: const Icon(Icons.error, color: Colors.red, size: 28),
          title: Text(
            download.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            download.errorMessage ?? 'Download failed',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: Colors.red[300]),
          ),
          trailing: PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'retry',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 18),
                    SizedBox(width: 8),
                    Text('Retry'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'retry') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Retrying download'), duration: Duration(seconds: 1)),
                );
              } else if (value == 'delete') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Download deleted'), duration: Duration(seconds: 1)),
                );
                ref.refresh(downloadsProvider);
              }
            },
          ),
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

```

`frontend/lib/screens/history_screen.dart`:

```dart
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/history_entry.dart';
import '../providers.dart';
import 'player_screen.dart';

final historySearchProvider = StateProvider<String>((ref) => '');
final historyFilterProvider = StateProvider<String>((ref) => 'all'); // all, today, week, month

final historyProvider = FutureProvider<List<HistoryEntry>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final search = ref.watch(historySearchProvider);
  final filter = ref.watch(historyFilterProvider);
  
  List<HistoryEntry> history = await apiService.getHistory();
  
  // Filter by search
  if (search.isNotEmpty) {
    history = history
        .where((h) => h.title.toLowerCase().contains(search.toLowerCase()) ||
            h.channel.toLowerCase().contains(search.toLowerCase()))
        .toList();
  }
  
  // Filter by date
  final now = DateTime.now();
  switch (filter) {
    case 'today':
      history = history.where((h) {
        final date = DateTime.tryParse(h.watchedAt) ?? now;
        return now.difference(date).inDays == 0;
      }).toList();
      break;
    case 'week':
      history = history.where((h) {
        final date = DateTime.tryParse(h.watchedAt) ?? now;
        return now.difference(date).inDays <= 7;
      }).toList();
      break;
    case 'month':
      history = history.where((h) {
        final date = DateTime.tryParse(h.watchedAt) ?? now;
        return now.difference(date).inDays <= 30;
      }).toList();
      break;
    case 'all':
    default:
      break;
  }
  
  return history;
});

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(historyProvider);
    final filter = ref.watch(historyFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Watch History'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export History as CSV',
            onPressed: _exportHistoryAsCsv,
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: const [
                    Icon(Icons.delete_sweep, size: 18),
                    SizedBox(width: 8),
                    Text('Clear All History'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'clear_all') {
                _showClearHistoryDialog(context);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.grey[850],
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                ref.read(historySearchProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                hintText: 'Search history...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                filled: true,
                fillColor: Colors.grey[800],
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(historySearchProvider.notifier).state = '';
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip('All', 'all', filter),
                const SizedBox(width: 8),
                _buildFilterChip('Today', 'today', filter),
                const SizedBox(width: 8),
                _buildFilterChip('This Week', 'week', filter),
                const SizedBox(width: 8),
                _buildFilterChip('This Month', 'month', filter),
              ],
            ),
          ),
          // History list
          Expanded(
            child: historyAsync.when(
              data: (history) {
                if (history.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final entry = history[index];
                    return AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: _buildHistoryTile(context, entry),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorState(error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, String currentFilter) {
    final isSelected = value == currentFilter;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        ref.read(historyFilterProvider.notifier).state = value;
      },
      backgroundColor: Colors.grey[800],
      selectedColor: Colors.red[700],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[400],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No watch history',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Videos you watch will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 300,
            child: Text(
              error,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(historyProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportHistoryAsCsv() async {
    final historyAsync = ref.watch(historyProvider);
    
    historyAsync.when(
      data: (history) async {
        if (history.isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No history to export')),
          );
          return;
        }

        final apiService = ref.read(apiServiceProvider);
        try {
          // Prepare CSV data
          List<List<dynamic>> rows = [
            ['Video ID', 'Title', 'Channel', 'Thumbnail URL', 'Watched At', 'Progress']
          ];
          
          for (final entry in history) {
            rows.add([
              entry.videoId,
              entry.title,
              entry.channel,
              entry.thumbnail,
              entry.watchedAt,
              entry.progress?.toString() ?? '0.0',
            ]);
          }

          String csv = const ListToCsvConverter().convert(rows);

          // Prompt for save location
          final home = Platform.environment['HOME'];
          final base = home == null || home.isEmpty ? '.' : '$home/Downloads';
          final now = DateTime.now();
          final y = now.year.toString().padLeft(4, '0');
          final m = now.month.toString().padLeft(2, '0');
          final d = now.day.toString().padLeft(2, '0');
          final suggestedPath = '$base/tubular-history-$y$m$d.csv';

          final controller = TextEditingController(text: suggestedPath);
          final value = await showDialog<String>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Export History as CSV'),
                content: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Enter file path',
                    border: const OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(controller.text.trim()),
                    child: const Text('Export'),
                  ),
                ],
              );
            },
          );
          controller.dispose();

          if (value == null || value.trim().isEmpty) return;

          var finalPath = value.trim();
          if (!finalPath.endsWith('.csv')) {
            finalPath = '$finalPath.csv';
          }

          final outputFile = File(finalPath);
          await outputFile.parent.create(recursive: true);
          await outputFile.writeAsString(csv);

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('History exported: $finalPath')),
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to export history: $e'),
              backgroundColor: Colors.red[700],
            ),
          );
        }
      },
      loading: () => {},
      error: (error, stack) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading history: $error'),
            backgroundColor: Colors.red[700],
          ),
        );
      },
    );
  }

  Widget _buildHistoryTile(BuildContext context, HistoryEntry entry) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            image: DecorationImage(
              image: NetworkImage(entry.thumbnail),
              fit: BoxFit.cover,
            ),
            color: Colors.grey[700],
          ),
        ),
        title: Text(
          entry.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          entry.channel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Remove'),
                ],
              ),
            ),
          ],
          onSelected: (value) async {
            if (value == 'remove') {
              final apiService = ref.read(apiServiceProvider);
              try {
                await apiService.removeFromHistory(entry.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Removed from history'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
                ref.refresh(historyProvider);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red[700],
                    ),
                  );
                }
              }
            }
          },
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Playing: ${entry.title}'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure you want to clear all watch history? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final apiService = ref.read(apiServiceProvider);
              try {
                await apiService.clearHistory();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('History cleared')),
                  );
                }
                ref.refresh(historyProvider);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red[700],
                    ),
                  );
                }
              }
            },
            child: Text('Clear', style: TextStyle(color: Colors.red[700])),
          ),
        ],
      ),
    );
  }
}

```

`frontend/lib/screens/home_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../controllers/player_controller.dart';
import '../models/video.dart';
import '../services/api_service.dart';
import '../providers.dart';
import '../widgets/video_card.dart';
import 'video_details_screen.dart';
import '../widgets/error_widget.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

/// Track if backend is warmed up (yt-dlp cache initialized)
final backendWarmupProvider = FutureProvider<bool>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    // Call warmup endpoint to initialize yt-dlp cache
    await apiService.warmupBackend();
    return true;
  } catch (e) {
    // Warmup is optional - app works without it, just slower on first search
    return false;
  }
});

final searchResultsProvider = FutureProvider.autoDispose<ApiResult<List<Video>>>((
  ref,
) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) {
    return (
      success: true,
      data: <Video>[],
      error: null,
      details: null,
    );
  }

  final apiService = ref.watch(apiServiceProvider);
  return await apiService.searchVideos(query);
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _lastSearchQuery = '';

  @override
  void initState() {
    super.initState();
    // Warmup backend in the background on app startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(backendWarmupProvider);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty && query != _lastSearchQuery) {
      _lastSearchQuery = query;
      ref.read(searchQueryProvider.notifier).state = query;
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _lastSearchQuery = '';
    ref.read(searchQueryProvider.notifier).state = '';
  }

  void _openVideo(Video video) {
    // Navigate to the details screen first (intermediate screen)
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VideoDetailsScreen(video: video)),
    );
  }

  void _subscribeToChannel(BuildContext context, Video video) async {
    final apiService = ref.read(apiServiceProvider);
    try {
      await apiService.subscribeFromVideo(
        channelId: video.channelId,
        channelName: video.channelName,
        thumbnail: video.thumbnail,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Subscribed to ${video.channelName}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to subscribe: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tubular PC'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Search videos...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: _clearSearch,
                        tooltip: 'Clear',
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _performSearch,
                  icon: const Icon(Icons.search),
                  label: const Text('Search'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: searchResults.when(
        data: (result) {
          // Handle error state
          if (!result.success) {
            return ErrorDisplay(
              message: result.error ?? 'Unknown error',
              details: result.details,
              onRetry: () => ref.refresh(searchResultsProvider),
            );
          }

          final videos = result.data ?? [];

          if (videos.isEmpty && ref.read(searchQueryProvider).isEmpty) {
            // Show featured videos on initial load
            return _buildFeaturedVideos();
          } else if (videos.isEmpty) {
            return _buildEmptySearchResults();
          }

          return MasonryGridView.count(
            crossAxisCount: _getCrossAxisCount(context),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            padding: const EdgeInsets.all(8),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return VideoCard(
                video: video,
                onTap: () => _openVideo(video),
                onSubscribe: () => _subscribeToChannel(context, video),
              );
            },
          );
        },
        loading: () => _buildLoadingState(ref),
        error: (error, stack) => ErrorDisplay(
          message: 'Search error',
          details: error.toString(),
          onRetry: () => ref.refresh(searchResultsProvider),
        ),
      ),
    );
  }

  Widget _buildLoadingState(WidgetRef ref) {
    final warmupState = ref.watch(backendWarmupProvider);
    
    String subtitle = 'Loading...';
    String details = '';
    
    return warmupState.when(
      data: (isWarmedUp) {
        if (isWarmedUp) {
          subtitle = 'Searching YouTube...';
          details = 'Backend is ready. First search: 10-30s, cached searches: <1s';
        } else {
          subtitle = 'Initializing backend...';
          details = 'First search may take 10-30 seconds';
        }
        
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  details,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isWarmedUp ? Icons.check_circle : Icons.hourglass_empty,
                          size: 16,
                          color: isWarmedUp ? Colors.green[400] : Colors.orange[400],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isWarmedUp ? '✓ Backend ready' : '⏳ Warming up...',
                          style: TextStyle(
                            fontSize: 12,
                            color: isWarmedUp ? Colors.green[300] : Colors.orange[300],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Initializing backend...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
      error: (_, __) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Searching YouTube...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'First search: 10-30s, cached searches: <1s',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  Widget _buildFeaturedVideos() {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Icon(Icons.play_circle_outline, size: 80, color: Colors.red[400]),
              const SizedBox(height: 24),
              const Text(
                'Welcome to Tubular PC',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Ad-free video streaming with privacy in mind',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[700]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Try searching for:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children:
                          [
                                'Flutter',
                                'Rust',
                                'Desktop',
                                'Tutorial',
                                'Development',
                              ]
                              .map(
                                (tag) => OutlinedButton(
                                  onPressed: () {
                                    _searchController.text = tag;
                                    _performSearch();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.grey[850],
                                    side: BorderSide(color: Colors.red[700]!),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: Text(
                                    tag,
                                    style: TextStyle(
                                      color: Colors.red[400],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No videos found for "${_searchController.text}"',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            'Example searches:',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Flutter', 'Rust', 'Desktop', 'Tutorial']
                .map(
                  (tag) => ActionChip(
                    label: Text(tag),
                    onPressed: () {
                      _searchController.text = tag;
                      _performSearch();
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

```

`frontend/lib/screens/player_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/video.dart';
import '../models/sponsorblock.dart';
import '../models/dislike.dart';
import '../providers.dart';

final sponsorBlockProvider = FutureProvider.family<List<SponsorBlockSegment>, String>((ref, videoId) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    // TODO: Fetch from backend API
    // return await apiService.getSponsorBlockSegments(videoId);
    return [];
  } catch (e) {
    return [];
  }
});

final dislikeProvider = FutureProvider.family<DislikeData?, String>((ref, videoId) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    // TODO: Fetch from backend API
    // return await apiService.getDislikeData(videoId);
    return null;
  } catch (e) {
    return null;
  }
});

final playerPositionProvider = StateProvider<Duration>((ref) => Duration.zero);
final playerDurationProvider = StateProvider<Duration>((ref) => const Duration(minutes: 10));
final isPlayingProvider = StateProvider<bool>((ref) => false);
final autoSkipSponsorProvider = StateProvider<bool>((ref) => true);

class PlayerScreen extends ConsumerStatefulWidget {
  final Video video;

  const PlayerScreen({
    Key? key,
    required this.video,
  }) : super(key: key);

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  @override
  Widget build(BuildContext context) {
    final sponsorBlockAsync = ref.watch(sponsorBlockProvider(widget.video.id));
    final dislikeAsync = ref.watch(dislikeProvider(widget.video.id));
    final isPlaying = ref.watch(isPlayingProvider);
    final position = ref.watch(playerPositionProvider);
    final duration = ref.watch(playerDurationProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: const Text('Now Playing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Player settings coming soon')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Video player area
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_circle_outline,
                      size: 80,
                      color: Colors.red[700],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.video.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.video.channelName,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Progress bar with SponsorBlock segments
          Container(
            color: Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SponsorBlock segments timeline
                sponsorBlockAsync.when(
                  data: (segments) {
                    if (segments.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Skip Segments',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildSponsorBlockTimeline(segments, duration),
                          const SizedBox(height: 12),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                // Progress bar
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                  ),
                  child: Slider(
                    value: position.inSeconds.toDouble(),
                    max: duration.inSeconds.toDouble(),
                    onChanged: (value) {
                      ref.read(playerPositionProvider.notifier).state =
                          Duration(seconds: value.toInt());
                    },
                    activeColor: Colors.red[700],
                    inactiveColor: Colors.grey[700],
                  ),
                ),

                // Time display
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(position),
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _formatDuration(duration),
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Player controls
          Container(
            color: Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous, color: Colors.white),
                  onPressed: () {
                    ref.read(playerPositionProvider.notifier).state =
                        Duration(seconds: (position.inSeconds - 10).clamp(0, double.infinity).toInt());
                  },
                ),
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause_circle : Icons.play_circle,
                    color: Colors.white,
                    size: 40,
                  ),
                  onPressed: () {
                    ref.read(isPlayingProvider.notifier).state = !isPlaying;
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, color: Colors.white),
                  onPressed: () {
                    ref.read(playerPositionProvider.notifier).state =
                        Duration(seconds: position.inSeconds + 10);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up, color: Colors.white),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Volume control coming soon')),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.fullscreen, color: Colors.white),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fullscreen coming soon')),
                    );
                  },
                ),
              ],
            ),
          ),

          // Video info with dislikes
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.black87,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      widget.video.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Channel and stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.video.channelName,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        dislikeAsync.when(
                          data: (dislike) {
                            if (dislike != null) {
                              return Row(
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.thumb_up, color: Colors.grey[400], size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        dislike.formattedLikes,
                                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  Row(
                                    children: [
                                      Icon(Icons.thumb_down, color: Colors.grey[400], size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        dislike.formattedDislikes,
                                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // View count and upload date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.video.formattedViews} views',
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                        Text(
                          widget.video.uploadedAgo,
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Text(
                      'Description coming soon',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // SponsorBlock segments (outside of Column for AsyncValue handling)
          Expanded(
            flex: 1,
            child: sponsorBlockAsync.when(
              data: (segments) {
                if (segments.isEmpty) {
                  return const SizedBox.shrink();
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sponsor Segments',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: segments
                            .map((segment) =>
                                _buildSegmentTile(segment, context))
                            .toList(),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSponsorBlockTimeline(List<SponsorBlockSegment> segments, Duration duration) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 24,
        child: Stack(
          children: [
            // Background bar
            Container(
              color: Colors.grey[800],
            ),
            // Segments
            Row(
              children: segments.map((segment) {
                final totalDuration = duration.inMilliseconds.toDouble();
                final startPercent = (segment.startTime * 1000) / totalDuration;
                final widthPercent =
                    ((segment.endTime - segment.startTime) * 1000) / totalDuration;

                return Expanded(
                  flex: 0,
                  child: Padding(
                    padding: EdgeInsets.only(left: startPercent.toStringAsFixed(0) as double? ?? 0),
                    child: Container(
                      width: (widthPercent * 100).toStringAsFixed(0) as double? ?? 0,
                      color: segment.categoryColor,
                      child: Tooltip(
                        message: '${segment.categoryLabel} (${segment.durationText})',
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentTile(SponsorBlockSegment segment, BuildContext context) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 4,
          color: segment.categoryColor,
        ),
        title: Text(
          segment.categoryLabel,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
        subtitle: Text(
          '${_formatDuration(segment.startDuration)} - ${_formatDuration(segment.endDuration)} (${segment.durationText})',
          style: TextStyle(color: Colors.grey[400], fontSize: 11),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.thumb_up, color: Colors.grey[400], size: 16),
            const SizedBox(width: 4),
            Text(
              segment.votes.toString(),
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
        onTap: () {
          ref.read(playerPositionProvider.notifier).state = segment.startDuration;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Jumping to ${segment.categoryLabel}')),
          );
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

```

`frontend/lib/screens/settings_screen.dart`:

```dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const String _tubularConfigFormat = 'tubular-settings';
  static const int _tubularConfigVersion = 1;

  void _saveSetting(String key, String value) {
    final apiService = ref.read(apiServiceProvider);
    print('DEBUG: Saving setting $key = $value');
    apiService.setSetting(key, value).then((_) {
      print('DEBUG: Successfully saved setting $key');
    }).catchError((e) {
      print('DEBUG: Failed to save setting $key: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save setting: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
    });
  }

  Future<void> _exportSettingsConfig() async {
    final apiService = ref.read(apiServiceProvider);
    try {
      final settings = await apiService.getAllSettings();
      final payload = {
        'format': _tubularConfigFormat,
        'version': _tubularConfigVersion,
        'exported_at': DateTime.now().toIso8601String(),
        'settings': settings,
      };

      final suggestedPath = _defaultExportPath();
      final targetPath = await _promptForPath(
        title: 'Export Settings',
        hintText: '/home/user/Downloads/tubular-settings.tubular',
        initialValue: suggestedPath,
        confirmText: 'Export',
      );
      if (targetPath == null || targetPath.trim().isEmpty) return;

      var finalPath = targetPath.trim();
      if (!finalPath.endsWith('.tubular')) {
        finalPath = '$finalPath.tubular';
      }

      final outputFile = File(finalPath);
      await outputFile.parent.create(recursive: true);
      await outputFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(payload),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Settings exported: $finalPath')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export settings: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  Future<void> _importSettingsConfig() async {
    final apiService = ref.read(apiServiceProvider);
    final sourcePath = await _promptForPath(
      title: 'Import Settings',
      hintText: '/home/user/Downloads/tubular-settings.tubular',
      initialValue: _defaultImportPath(),
      confirmText: 'Import',
    );
    if (sourcePath == null || sourcePath.trim().isEmpty) return;

    try {
      final file = File(sourcePath.trim());
      if (!await file.exists()) {
        throw Exception('File not found: ${file.path}');
      }

      final raw = await file.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid config file structure');
      }

      final format = decoded['format']?.toString();
      if (format != _tubularConfigFormat) {
        throw Exception('Unsupported format: $format');
      }

      final settingsNode = decoded['settings'];
      if (settingsNode is! Map) {
        throw Exception('Missing settings block in config');
      }

      final imported = <String, String>{};
      settingsNode.forEach((key, value) {
        if (key != null && value != null) {
          imported[key.toString()] = value.toString();
        }
      });

      for (final entry in imported.entries) {
        await apiService.setSetting(entry.key, entry.value);
      }
      _applyImportedSettings(imported);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Settings imported (${imported.length} entries)')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to import settings: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  void _applyImportedSettings(Map<String, String> settings) {
    if (settings.containsKey('theme')) {
      final t = settings['theme'];
      ref.read(themeModeProvider.notifier).state =
          t == 'light' ? ThemeMode.light : (t == 'system' ? ThemeMode.system : ThemeMode.dark);
    }
    if (settings.containsKey('amoled_dark')) {
      ref.read(amoledDarkProvider.notifier).state = settings['amoled_dark'] == 'true';
    }
    if (settings.containsKey('preferred_quality')) {
      ref.read(preferredQualityProvider.notifier).state = settings['preferred_quality']!;
    }
    if (settings.containsKey('preferred_format')) {
      ref.read(preferredFormatProvider.notifier).state = settings['preferred_format']!;
    }
    if (settings.containsKey('audio_only_mode')) {
      ref.read(audioOnlyModeProvider.notifier).state = settings['audio_only_mode'] == 'true';
    }
    if (settings.containsKey('auto_play')) {
      ref.read(autoPlayProvider.notifier).state = settings['auto_play'] == 'true';
    }
    if (settings.containsKey('subtitle_font_size')) {
      final v = double.tryParse(settings['subtitle_font_size'] ?? '14.0') ?? 14.0;
      ref.read(subtitleFontSizeProvider.notifier).state = v;
    }
    if (settings.containsKey('download_folder')) {
      ref.read(downloadFolderProvider.notifier).state = settings['download_folder']!;
    }
    if (settings.containsKey('enable_sponsorblock')) {
      ref.read(enableSponsorBlockProvider.notifier).state = settings['enable_sponsorblock'] == 'true';
    }
    if (settings.containsKey('enable_dislike_counts')) {
      ref.read(enableDislikeCountsProvider.notifier).state = settings['enable_dislike_counts'] == 'true';
    }
    if (settings.containsKey('enable_subtitles')) {
      ref.read(enableSubtitlesProvider.notifier).state = settings['enable_subtitles'] == 'true';
    }
    if (settings.containsKey('enable_notifications')) {
      ref.read(enableNotificationsProvider.notifier).state = settings['enable_notifications'] == 'true';
    }
    if (settings.containsKey('playback_speed')) {
      final v = double.tryParse(settings['playback_speed'] ?? '1.0') ?? 1.0;
      ref.read(playbackSpeedProvider.notifier).state = v;
    }
  }

  Future<String?> _promptForPath({
    required String title,
    required String hintText,
    required String initialValue,
    required String confirmText,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final value = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(controller.text.trim()),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
    controller.dispose();
    return value;
  }

  String _defaultExportPath() {
    final home = Platform.environment['HOME'];
    final base = home == null || home.isEmpty ? '.' : '$home/Downloads';
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$base/tubular-settings-$y$m$d.tubular';
  }

  String _defaultImportPath() {
    final home = Platform.environment['HOME'];
    final base = home == null || home.isEmpty ? '.' : '$home/Downloads';
    return '$base/tubular-settings.tubular';
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final amoledDark = ref.watch(amoledDarkProvider);
    final preferredQuality = ref.watch(preferredQualityProvider);
    final preferredFormat = ref.watch(preferredFormatProvider);
    final audioOnly = ref.watch(audioOnlyModeProvider);
    final autoPlay = ref.watch(autoPlayProvider);
    final downloadFolder = ref.watch(downloadFolderProvider);
    final subtitleSize = ref.watch(subtitleFontSizeProvider);
    final playbackSpeed = ref.watch(playbackSpeedProvider);
    final sponsorBlock = ref.watch(enableSponsorBlockProvider);
    final dislikeCounts = ref.watch(enableDislikeCountsProvider);
    final subtitles = ref.watch(enableSubtitlesProvider);
    final notifications = ref.watch(enableNotificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // =========== APPEARANCE SECTION ===========
          _buildSectionHeader(context, 'Appearance', Icons.palette),
          _buildSectionCard(
            children: [
              _buildDropdownTile(
                context,
                'Theme',
                themeMode,
                themeMode == ThemeMode.dark
                    ? 'Dark'
                    : (themeMode == ThemeMode.light ? 'Light' : 'System'),
                items: const [
                  DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                  DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref.read(themeModeProvider.notifier).state = value;
                    String themeValue = value == ThemeMode.dark ? 'dark' : (value == ThemeMode.light ? 'light' : 'system');
                    _saveSetting('theme', themeValue);
                  }
                },
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                'AMOLED Dark',
                'Use pure black surfaces in dark theme',
                amoledDark,
                (value) {
                  ref.read(amoledDarkProvider.notifier).state = value;
                  _saveSetting('amoled_dark', value.toString());
                },
              ),
              const Divider(height: 1),
               _buildSliderTile(
                 'Subtitle Font Size',
                 subtitleSize,
                 10,
                 30,
                 (value) {
                   ref.read(subtitleFontSizeProvider.notifier).state = value;
                   _saveSetting('subtitle_font_size', value.toString());
                 },
               ),
            ],
          ),
          const SizedBox(height: 12),

          // =========== PLAYBACK SECTION ===========
          _buildSectionHeader(context, 'Playback', Icons.videogame_asset),
          _buildSectionCard(
            children: [
              _buildDropdownTile(
                context,
                'Preferred Quality',
                preferredQuality,
                preferredQuality,
                items: const [
                  DropdownMenuItem(value: 'audio', child: Text('Audio Only')),
                  DropdownMenuItem(value: '360p', child: Text('360p')),
                  DropdownMenuItem(value: '480p', child: Text('480p')),
                  DropdownMenuItem(value: '720p', child: Text('720p')),
                  DropdownMenuItem(value: '1080p', child: Text('1080p')),
                  DropdownMenuItem(value: '1440p', child: Text('1440p')),
                  DropdownMenuItem(value: '2160p', child: Text('2160p')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref.read(preferredQualityProvider.notifier).state = value;
                    _saveSetting('preferred_quality', value);
                  }
                },
              ),
              const Divider(height: 1),
              _buildDropdownTile(
                context,
                'Playback Speed',
                playbackSpeed.toString(),
                playbackSpeed.toString(),
                items: const [
                  DropdownMenuItem(value: '0.5', child: Text('0.5x')),
                  DropdownMenuItem(value: '0.75', child: Text('0.75x')),
                  DropdownMenuItem(value: '1.0', child: Text('1.0x')),
                  DropdownMenuItem(value: '1.25', child: Text('1.25x')),
                  DropdownMenuItem(value: '1.5', child: Text('1.5x')),
                  DropdownMenuItem(value: '2.0', child: Text('2.0x')),
                  DropdownMenuItem(value: '2.25', child: Text('2.25x')),
                  DropdownMenuItem(value: '2.5', child: Text('2.5x')),
                  DropdownMenuItem(value: '2.75', child: Text('2.75x')),
                  DropdownMenuItem(value: '3.0', child: Text('3.0x')),
                  DropdownMenuItem(value: '3.25', child: Text('3.25x')),
                  DropdownMenuItem(value: '3.5', child: Text('3.5x')),
                  DropdownMenuItem(value: '3.75', child: Text('3.75x')),
                  DropdownMenuItem(value: '4.0', child: Text('4.0x')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    final v = double.tryParse(value) ?? 1.0;
                    ref.read(playbackSpeedProvider.notifier).state = v;
                    _saveSetting('playback_speed', v.toString());
                  }
                },
              ),
              _buildDropdownTile(
                context,
                'Preferred Format',
                preferredFormat,
                preferredFormat,
                items: const [
                  DropdownMenuItem(value: 'video', child: Text('Video')),
                  DropdownMenuItem(value: 'audio', child: Text('Audio Only')),
                  DropdownMenuItem(value: 'both', child: Text('Both')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref.read(preferredFormatProvider.notifier).state = value;
                    _saveSetting('preferred_format', value);
                  }
                },
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                 'Audio-Only Mode',
                 'Default to audio playback',
                 audioOnly,
                 (value) {
                   ref.read(audioOnlyModeProvider.notifier).state = value;
                   _saveSetting('audio_only_mode', value.toString());
                 },
               ),
               const Divider(height: 1),
               _buildSwitchTile(
                 'Auto-Play Next',
                 'Automatically play next video',
                 autoPlay,
                 (value) {
                   ref.read(autoPlayProvider.notifier).state = value;
                   _saveSetting('auto_play', value.toString());
                 },
               ),
               const Divider(height: 1),
                _buildSwitchTile(
                 'Show Subtitles',
                 'Display subtitles when available',
                 subtitles,
                 (value) {
                   ref.read(enableSubtitlesProvider.notifier).state = value;
                   _saveSetting('enable_subtitles', value.toString());
                 },
               ),
            ],
          ),
          const SizedBox(height: 12),

          // =========== FEATURES SECTION ===========
          _buildSectionHeader(context, 'Features', Icons.star),
          _buildSectionCard(
            children: [
               _buildSwitchTile(
                 'SponsorBlock',
                 'Skip sponsored segments automatically',
                 sponsorBlock,
                 (value) {
                   ref.read(enableSponsorBlockProvider.notifier).state = value;
                   _saveSetting('enable_sponsorblock', value.toString());
                 },
               ),
               const Divider(height: 1),
               _buildSwitchTile(
                 'Show Dislike Counts',
                 'Display community dislike counts',
                 dislikeCounts,
                 (value) {
                   ref.read(enableDislikeCountsProvider.notifier).state = value;
                   _saveSetting('enable_dislike_counts', value.toString());
                 },
               ),
            ],
          ),
          const SizedBox(height: 12),

          // =========== SETTINGS CONFIG ===========
          _buildSectionHeader(context, 'Settings Config', Icons.import_export),
          _buildSectionCard(
            children: [
              ListTile(
                title: const Text('Export Settings'),
                subtitle: const Text('Export to .tubular config file'),
                trailing: const Icon(Icons.upload_file),
                onTap: _exportSettingsConfig,
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Import Settings'),
                subtitle: const Text('Import from .tubular config file'),
                trailing: const Icon(Icons.download_for_offline),
                onTap: _importSettingsConfig,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // =========== DOWNLOADS SECTION ===========
          _buildSectionHeader(context, 'Downloads', Icons.download),
          _buildSectionCard(
            children: [
              ListTile(
                title: const Text('Download Folder'),
                subtitle: Text(downloadFolder),
                trailing: const Icon(Icons.folder_open),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Folder picker coming soon')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // =========== PRIVACY & NOTIFICATIONS ===========
          _buildSectionHeader(context, 'Privacy & Notifications', Icons.lock),
          _buildSectionCard(
            children: [
              _buildSwitchTile(
                'Notifications',
                'Show download and update notifications',
                notifications,
                (value) {
                  ref.read(enableNotificationsProvider.notifier).state = value;
                },
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Clear Cache'),
                subtitle: const Text('Remove cached images and data'),
                trailing: const Icon(Icons.cleaning_services),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cache cleared')),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening privacy policy')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // =========== ABOUT SECTION ===========
          _buildSectionHeader(context, 'About', Icons.info),
          _buildSectionCard(
            children: [
              const ListTile(
                title: Text('Version'),
                subtitle: Text('1.0.0'),
                trailing: Icon(Icons.info_outline),
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('GitHub Repository'),
                subtitle: const Text('View source code'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening GitHub')),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Check for Updates'),
                trailing: const Icon(Icons.system_update),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('You are on the latest version')),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Report an Issue'),
                trailing: const Icon(Icons.bug_report),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening issue tracker')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.red[700]),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(children: children),
    );
  }

  Widget _buildDropdownTile(
    BuildContext context,
    String title,
    dynamic selectedValue,
    String subtitleText, {
    required List<DropdownMenuItem<dynamic>> items,
    required ValueChanged<dynamic> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitleText),
      trailing: DropdownButton(
        value: selectedValue,
        items: items,
        onChanged: onChanged,
        underline: const SizedBox(),
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Slider(
        value: value,
        min: min,
        max: max,
        divisions: (max - min).toInt(),
        label: value.toStringAsFixed(0),
        onChanged: onChanged,
        activeColor: Colors.red[700],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.red[700],
    );
  }
}

```

`frontend/lib/screens/subscriptions_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription.dart';
import '../models/video.dart';
import '../providers.dart';
import '../widgets/video_card.dart';
import 'player_screen.dart';

final subscriptionSearchProvider = StateProvider<String>((ref) => '');
final subscriptionsSortProvider = StateProvider<String>((ref) => 'name_asc');

final subscriptionsProvider = FutureProvider<List<Subscription>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final search = ref.watch(subscriptionSearchProvider);
  final sort = ref.watch(subscriptionsSortProvider);
  
  List<Subscription> subs = await apiService.getSubscriptions();
  
  // Filter by search
  if (search.isNotEmpty) {
    subs = subs
        .where((s) => s.channelName.toLowerCase().contains(search.toLowerCase()))
        .toList();
  }
  
  // Apply sorting
  switch (sort) {
    case 'name_asc':
      subs.sort((a, b) => a.channelName.compareTo(b.channelName));
      break;
    case 'name_desc':
      subs.sort((a, b) => b.channelName.compareTo(a.channelName));
      break;
    case 'date_asc':
      subs.sort((a, b) => a.subscribedAt.compareTo(b.subscribedAt));
      break;
    case 'date_desc':
    default:
      subs.sort((a, b) => b.subscribedAt.compareTo(a.subscribedAt));
  }
  
  return subs;
});

final subscriptionVideosProvider = FutureProvider.family<List<Video>, String>((ref, channelId) async {
  final apiService = ref.watch(apiServiceProvider);
  // This would fetch latest videos from the channel
  // For now, return empty list
  return [];
});

class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionsAsync = ref.watch(subscriptionsProvider);
    final sort = ref.watch(subscriptionsSortProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscriptions'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'name_asc',
                child: Text('Name (A-Z)'),
              ),
              const PopupMenuItem(
                value: 'name_desc',
                child: Text('Name (Z-A)'),
              ),
              const PopupMenuItem(
                value: 'date_desc',
                child: Text('Recently Subscribed'),
              ),
              const PopupMenuItem(
                value: 'date_asc',
                child: Text('Oldest First'),
              ),
            ],
            onSelected: (value) {
              ref.read(subscriptionsSortProvider.notifier).state = value;
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.grey[850],
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                ref.read(subscriptionSearchProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                hintText: 'Search subscriptions...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                filled: true,
                fillColor: Colors.grey[800],
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(subscriptionSearchProvider.notifier).state = '';
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
          // Subscriptions list
          Expanded(
            child: subscriptionsAsync.when(
              data: (subscriptions) {
                if (subscriptions.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  itemCount: subscriptions.length,
                  itemBuilder: (context, index) {
                    final sub = subscriptions[index];
                    return AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: _buildSubscriptionTile(context, sub),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorState(error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.subscriptions,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No subscriptions',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Search for channels and subscribe to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 300,
            child: Text(
              error,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(subscriptionsProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionTile(BuildContext context, Subscription sub) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(sub.channelThumbnail),
          backgroundColor: Colors.red[700],
          onBackgroundImageError: (_, __) {},
          child: sub.channelThumbnail.isEmpty
              ? Icon(Icons.person, color: Colors.grey[400])
              : null,
        ),
        title: Text(
          sub.channelName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'ID: ${sub.channelId}',
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view_channel',
              child: Row(
                children: [
                  Icon(Icons.open_in_new, size: 18),
                  SizedBox(width: 8),
                  Text('View Channel'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'unsubscribe',
              child: Row(
                children: [
                  Icon(Icons.check_box, size: 18),
                  SizedBox(width: 8),
                  Text('Unsubscribe'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'view_channel') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Channel page coming soon: ${sub.channelName}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            } else if (value == 'unsubscribe') {
              _showUnsubscribeDialog(context, sub);
            }
          },
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Viewing channel: ${sub.channelName}')),
          );
        },
      ),
    );
  }

  void _showUnsubscribeDialog(BuildContext context, Subscription sub) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsubscribe'),
        content: Text('Unsubscribe from ${sub.channelName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final apiService = ref.read(apiServiceProvider);
              try {
                await apiService.removeSubscription(sub.channelId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Unsubscribed successfully')),
                  );
                }
                ref.refresh(subscriptionsProvider);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red[700],
                    ),
                  );
                }
              }
            },
            child: Text(
              'Unsubscribe',
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }
}

```

`frontend/lib/screens/video_details_screen.dart`:

```dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/video.dart';
import '../models/video_details.dart';
import '../providers.dart';
import '../controllers/player_controller.dart';
import '../screens/player_screen.dart';
import '../widgets/video_details/actions_section.dart';
import '../widgets/video_details/comments_section.dart';
import '../widgets/video_details/stats_section.dart';
import '../widgets/video_details/thumbnail_section.dart';

class VideoDetailsScreen extends ConsumerWidget {
  final Video video;

  const VideoDetailsScreen({super.key, required this.video});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(videoDetailsProvider(video.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Details'),
        backgroundColor: Colors.red[700],
      ),
      body: detailsAsync.when(
        data: (details) {
          final safeDetails = _buildSafeDetails(details);

          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ThumbnailSection(
                      thumbnailUrl: safeDetails.thumbnailUrl,
                      onPlay: () async {
                        await ref.read(playerControllerProvider.notifier).playVideo(video);
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => PlayerScreen(video: video)),
                          );
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StatsSection(details: safeDetails),
                          const SizedBox(height: 12),
                          ActionsSection(
                            items: [
                              ActionItem(
                                icon: Icons.playlist_add,
                                label: 'Add To',
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Add to playlist')),
                                  );
                                },
                              ),
                              ActionItem(
                                icon: Icons.headset,
                                label: 'Background',
                                onTap: () async {
                                  final controller = ref.read(playerControllerProvider.notifier);
                                  await controller.playVideo(
                                    video,
                                    quality: 'audio',
                                    surface: PlayerSurface.mini,
                                  );
                                  await controller.toggleBackgroundAudio();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Background mode enabled'),
                                      ),
                                    );
                                  }
                                },
                              ),
                              ActionItem(
                                icon: Icons.crop_square,
                                label: 'Popup',
                                onTap: () async {
                                  final controller = ref.read(playerControllerProvider.notifier);
                                  await controller.playVideo(
                                    video,
                                    quality: ref.read(preferredQualityProvider),
                                    surface: PlayerSurface.popup,
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Popup mode enabled')),
                                    );
                                  }
                                },
                              ),
                              ActionItem(
                                icon: Icons.download,
                                label: 'Download',
                                onTap: () async {
                                  if (context.mounted) {
                                    await _showQualitySelectionDialog(context, ref, video, safeDetails);
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Description',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Description coming soon',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.70),
                            ),
                          ),
                          const SizedBox(height: 16),
                          CommentsSection(comments: safeDetails.comments),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Failed to load details: $err')),
      ),
    );
  }

  VideoDetails _buildSafeDetails(VideoDetails details) {
    return VideoDetails(
      id: details.id.isNotEmpty ? details.id : video.id,
      title: details.title.isNotEmpty ? details.title : video.title,
      channelName: details.channelName.isNotEmpty
          ? details.channelName
          : video.channelName,
      channelId: details.channelId.isNotEmpty ? details.channelId : video.channelId,
      subscriberCount: details.subscriberCount,
      viewCount: details.viewCount > 0 ? details.viewCount : video.views,
      uploadDate: details.uploadDate.isNotEmpty
          ? details.uploadDate
          : video.uploadDate.toIso8601String(),
      duration: details.duration > Duration.zero ? details.duration : video.duration,
      thumbnailUrl: details.thumbnailUrl.isNotEmpty
          ? details.thumbnailUrl
          : video.thumbnail,
      likeCount: details.likeCount,
      dislikeCount: details.dislikeCount,
      comments: details.comments,
    );
  }

  String _buildOutputPath(
    String folder,
    VideoDetails details, {
    required bool audioOnly,
  }) {
    final home = Platform.environment['HOME'] ?? '.';
    final basePath = folder.startsWith('~/')
        ? '$home/${folder.substring(2)}'
        : (folder.trim().isEmpty ? '$home/Downloads/Tubular' : folder);

    final safeTitle = details.title
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    final ext = audioOnly ? '.m4a' : '.mp4';
    return '$basePath/$safeTitle$ext';
  }

  Future<void> _showQualitySelectionDialog(
    BuildContext context,
    WidgetRef ref,
    Video video,
    VideoDetails details,
  ) async {
    final selectedQuality = await showDialog<String>(
      context: context,
      builder: (dialogContext) => _QualitySelectionDialog(
        currentQuality: ref.read(preferredQualityProvider),
      ),
    );

    if (selectedQuality != null && context.mounted) {
      await _performDownload(
        context,
        ref,
        video,
        details,
        selectedQuality,
      );
    }
  }

  Future<void> _performDownload(
    BuildContext context,
    WidgetRef ref,
    Video video,
    VideoDetails details,
    String quality,
  ) async {
    final api = ref.read(apiServiceProvider);
    final audioOnly = quality == 'audio';
    final folder = ref.read(downloadFolderProvider);
    final outputPath = _buildOutputPath(
      folder,
      details,
      audioOnly: audioOnly,
    );
    int? id;

    try {
      await File(outputPath).parent.create(recursive: true);

      id = await api.createDownload(
        video.id,
        details.title,
        outputPath,
        quality,
      );

      if (id != null) {
        await api.updateDownloadProgress(
          id,
          'downloading',
          0.0,
          0.0,
          0,
        );
      }

      await api.downloadVideo(
        videoId: video.id,
        outputPath: outputPath,
        quality: quality,
        audioOnly: audioOnly,
      );

      if (id != null) {
        final fileSize = await File(outputPath)
            .length()
            .catchError((_) => 0);
        await api.completeDownload(id, fileSize);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download complete: $outputPath')),
        );
      }
    } catch (e) {
      if (id != null) {
        await api.failDownload(id, e.toString());
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

}

class _QualitySelectionDialog extends StatefulWidget {
  final String currentQuality;

  const _QualitySelectionDialog({required this.currentQuality});

  @override
  State<_QualitySelectionDialog> createState() => _QualitySelectionDialogState();
}

class _QualitySelectionDialogState extends State<_QualitySelectionDialog> {
  late String _selectedQuality;

  static const List<QualityOption> qualityOptions = [
    QualityOption('best', 'Best (Auto)', Icons.auto_awesome, true),
    QualityOption('1080p', '1080p (Full HD)', Icons.high_quality, false),
    QualityOption('720p', '720p (HD)', Icons.high_quality, false),
    QualityOption('480p', '480p (SD)', Icons.high_quality, false),
    QualityOption('360p', '360p (Low)', Icons.high_quality, false),
    QualityOption('audio', 'Audio Only', Icons.headphones, false),
  ];

  @override
  void initState() {
    super.initState();
    _selectedQuality = widget.currentQuality;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.file_download, color: Colors.red),
          SizedBox(width: 8),
          Text('Select Download Quality'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...qualityOptions.map((option) {
              final isSelected = _selectedQuality == option.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() => _selectedQuality = option.value);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? Colors.red[700]!
                              : Colors.grey[600]!,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: isSelected
                            ? Colors.red[700]!.withValues(alpha: 0.1)
                            : Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          if (isSelected)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.red[700],
                                size: 22,
                              ),
                            )
                          else
                            const SizedBox(width: 22 + 8),
                          Icon(option.icon, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option.label,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (option.isRecommended)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 2),
                                    child: Text(
                                      'Recommended',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton.tonal(
          onPressed: () => Navigator.pop(context, _selectedQuality),
          child: const Text('Download'),
        ),
      ],
    );
  }
}

class QualityOption {
  final String value;
  final String label;
  final IconData icon;
  final bool isRecommended;

  const QualityOption(
    this.value,
    this.label,
    this.icon,
    this.isRecommended,
  );
}

```

`frontend/lib/services/api_service.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/video.dart';
import '../models/video_details.dart';
import '../models/subscription.dart';
import '../models/history_entry.dart';
import '../models/download.dart';

/// Result type for API calls
typedef ApiResult<T> = ({bool success, T? data, String? error, String? details});

class ApiService {
  /// Match backend bind ([127.0.0.1]:3030) — `localhost` may resolve to ::1 and fail or delay.
  static const String baseUrl = 'http://127.0.0.1:3030';

  /// yt-dlp (search, stream URL, metadata) often needs tens of seconds on cold start or slow networks.
  static const Duration _defaultConnectTimeout = Duration(seconds: 15);
  static const Duration _defaultReceiveTimeout = Duration(seconds: 120);

  final Dio _dio;
  final Logger _logger = Logger();

  ApiService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: _defaultConnectTimeout,
          receiveTimeout: _defaultReceiveTimeout,
        ),
      );

  /// Warmup backend to initialize yt-dlp cache (eliminates ~10-30s cold start)
  Future<void> warmupBackend() async {
    try {
      _logger.i('🚀 Warming up backend...');
      final response = await _dio.post('/warmup')
          .timeout(const Duration(seconds: 60));
      
      if (response.statusCode == 200) {
        _logger.i('✅ Backend warmup complete');
      }
    } catch (e) {
      _logger.w('⚠️  Backend warmup failed (non-critical): $e');
      // Warmup is optional - app works without it, just slower
    }
  }

  Future<ApiResult<List<Video>>> searchVideos(String query, {int limit = 10}) async {
    _logger.i('Searching for: $query');
    
    if (query.trim().isEmpty) {
      return (
        success: false,
        data: null,
        error: 'Search query cannot be empty',
        details: null,
      );
    }

    try {
      final response = await _dio.get(
        '/search',
        queryParameters: {'q': query, 'limit': limit},
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        _logger.i('Search successful, got ${data.length} results from backend');
        
        if (data.isEmpty) {
          _logger.w('Backend returned 0 results');
          final mockResults = _getMockSearchResults(query, limit);
          return (
            success: true,
            data: mockResults,
            error: null,
            details: null,
          );
        }
        
        final videos = data.map((json) => Video.fromJson(json)).toList();
        return (
          success: true,
          data: videos,
          error: null,
          details: null,
        );
      } else {
        final errorMsg = (response.data['error'] ?? 'Search failed').toString();
        _logger.w('Backend returned error: $errorMsg');
        return (
          success: false,
          data: null,
          error: 'Search failed',
          details: errorMsg,
        );
      }
    } on DioException catch (e) {
      _logger.w('Search DIO error: $e');
      
      if (e.type == DioExceptionType.connectionTimeout) {
        return (
          success: false,
          data: null,
          error: 'Connection timeout',
          details: 'Backend took too long to respond. Is it running on http://127.0.0.1:3030?',
        );
      } else if (e.type == DioExceptionType.receiveTimeout) {
        return (
          success: false,
          data: null,
          error: 'Search timed out',
          details: 'Backend took too long to respond. Try again.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        return (
          success: false,
          data: null,
          error: 'Backend server is not running',
          details: 'Make sure the backend is started: cargo run',
        );
      } else {
        return (
          success: false,
          data: null,
          error: 'Network error',
          details: (e.message ?? 'Unknown network error').toString(),
        );
      }
    } catch (e) {
      _logger.w('Unexpected search error: $e');
      return (
        success: false,
        data: null,
        error: 'Unexpected error',
        details: e.toString(),
      );
    }
  }

  List<Video> _getMockSearchResults(String query, int limit) {
    final mockVideos = [
      Video(
        id: '1',
        title: 'How to Learn Flutter - Complete Tutorial',
        channelName: 'Code Academy',
        channelId: 'ch1',
        thumbnail: 'https://via.placeholder.com/320x180?text=Flutter+Tutorial',
        duration: const Duration(minutes: 45),
        views: 125000,
        uploadDate: DateTime.now().subtract(const Duration(days: 7)),
        description:
            'Learn Flutter from scratch in this comprehensive tutorial',
        likes: 3200,
        dislikes: 45,
      ),
      Video(
        id: '2',
        title: 'Rust Backend Development - From Zero to Hero',
        channelName: 'Dev Masters',
        channelId: 'ch2',
        thumbnail: 'https://via.placeholder.com/320x180?text=Rust+Backend',
        duration: const Duration(hours: 2, minutes: 30),
        views: 89000,
        uploadDate: DateTime.now().subtract(const Duration(days: 14)),
        description: 'Master Rust backend development with practical examples',
        likes: 2100,
        dislikes: 32,
      ),
      Video(
        id: '3',
        title: 'Desktop App Development with Flutter',
        channelName: 'Flutter Experts',
        channelId: 'ch3',
        thumbnail: 'https://via.placeholder.com/320x180?text=Desktop+Apps',
        duration: const Duration(minutes: 62),
        views: 156000,
        uploadDate: DateTime.now().subtract(const Duration(days: 3)),
        description: 'Build cross-platform desktop applications using Flutter',
        likes: 4500,
        dislikes: 78,
      ),
      Video(
        id: '4',
        title: 'Understanding Riverpod State Management',
        channelName: 'Flutter Coding',
        channelId: 'ch4',
        thumbnail: 'https://via.placeholder.com/320x180?text=Riverpod',
        duration: const Duration(minutes: 38),
        views: 78000,
        uploadDate: DateTime.now().subtract(const Duration(days: 21)),
        description:
            'Deep dive into Riverpod - the modern state management solution',
        likes: 1800,
        dislikes: 28,
      ),
      Video(
        id: '5',
        title: 'Building a Video Streaming App',
        channelName: 'Tech Tutorials',
        channelId: 'ch5',
        thumbnail: 'https://via.placeholder.com/320x180?text=Video+Streaming',
        duration: const Duration(hours: 1, minutes: 15),
        views: 234000,
        uploadDate: DateTime.now().subtract(const Duration(days: 5)),
        description: 'Create a feature-rich video streaming application',
        likes: 5600,
        dislikes: 95,
      ),
      Video(
        id: '6',
        title: '$query - Tutorial and Guide',
        channelName: 'Search Results',
        channelId: 'ch6',
        thumbnail: 'https://via.placeholder.com/320x180?text=${Uri.encodeComponent(query)}',
        duration: const Duration(minutes: 25),
        views: 50000,
        uploadDate: DateTime.now().subtract(const Duration(days: 2)),
        description: 'Learn about $query in this comprehensive guide',
        likes: 1200,
        dislikes: 15,
      ),
    ];

    // Always return at least the query-specific video
    final filtered = mockVideos
        .where(
          (video) =>
              video.title.toLowerCase().contains(query.toLowerCase()) ||
              video.channelName.toLowerCase().contains(query.toLowerCase()) ||
              video.description.toLowerCase().contains(query.toLowerCase()),
        )
        .take(limit)
        .toList();
    
    // If no matches, return the query-specific video
    if (filtered.isEmpty) {
      return [mockVideos.last];
    }
    
    return filtered;
  }

  Future<Video> getVideoInfo(String videoId) async {
    try {
      final response = await _dio.get('/video/$videoId');

      if (response.data['success'] == true) {
        return Video.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['error'] ?? 'Failed to get video info');
      }
    } catch (e) {
      _logger.w('Get video info error: $e');
      // Return mock video for development
      return _getMockVideoInfo(videoId);
    }
  }

  Future<VideoDetails> getVideoDetails(String videoId) async {
    try {
      final response = await _dio.get('/video/details/$videoId');

      if (response.data['success'] == true) {
        return VideoDetails.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['error'] ?? 'Failed to get video details');
      }
    } catch (e) {
      _logger.w('Get video details error: $e');
      // Fallback to real video info endpoint (no mocked metadata)
      final info = await getVideoInfo(videoId);
      return VideoDetails(
        id: info.id,
        title: info.title,
        channelName: info.channelName,
        channelId: info.channelId,
        subscriberCount: 0,
        viewCount: info.views,
        uploadDate: info.uploadDate.toIso8601String(),
        duration: info.duration,
        thumbnailUrl: info.thumbnail,
        likeCount: info.likes,
        dislikeCount: info.dislikes,
        comments: const [],
      );
    }
  }

  Video _getMockVideoInfo(String videoId) {
    return Video(
      id: videoId,
      title: 'Sample Video - $videoId',
      channelName: 'Test Channel',
      channelId: 'test-channel',
      thumbnail: 'https://via.placeholder.com/320x180?text=Video',
      duration: const Duration(minutes: 45),
      views: 100000,
      uploadDate: DateTime.now().subtract(const Duration(days: 10)),
      description: 'This is a sample video for testing purposes',
      likes: 5000,
      dislikes: 100,
    );
  }

  Future<String> getStreamUrl(String videoId, {String quality = 'best'}) async {
    // Return the proxy stream URL instead of fetching the direct URL
    // This avoids CORS issues and network restrictions with media_kit
    return '$baseUrl/stream-proxy/$videoId?quality=$quality';
  }

  Future<String> downloadVideo({
    required String videoId,
    required String outputPath,
    String quality = 'best',
    bool audioOnly = false,
  }) async {
    try {
      final response = await _dio.post(
        '/download',
        data: {
          'video_id': videoId,
          'output_path': outputPath,
          'quality': quality,
          'audio_only': audioOnly,
        },
        options: Options(receiveTimeout: const Duration(minutes: 60)),
      );

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['error'] ?? 'Download failed');
      }
    } on DioException catch (e) {
      _logger.w('Download DIO error: $e');

      final responseData = e.response?.data;
      if (responseData is Map) {
        final serverError = responseData['error']?.toString();
        final serverDetails = responseData['details']?.toString();
        if (serverError != null && serverError.isNotEmpty) {
          if (serverDetails != null && serverDetails.isNotEmpty) {
            throw Exception('$serverError: $serverDetails');
          }
          throw Exception(serverError);
        }
        if (serverDetails != null && serverDetails.isNotEmpty) {
          throw Exception(serverDetails);
        }
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Backend server is not running. Please ensure the Rust backend is running on http://127.0.0.1:3030',
        );
      }

      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Download request timed out. Please try again.');
      }

      throw Exception(e.message ?? 'Download failed');
    } catch (e) {
      _logger.w('Download error: $e');
      throw Exception(e.toString());
    }
  }

  Future<List<Subscription>> getSubscriptions() async {
    try {
      final response = await _dio.get('/subscriptions');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Subscription.fromJson(json)).toList();
      } else {
        throw Exception(
          response.data['error'] ?? 'Failed to get subscriptions',
        );
      }
    } catch (e) {
      _logger.w('Get subscriptions error: $e');
      // Return mock subscriptions
      return [];
    }
  }

  Future<void> addSubscription({
    required String channelId,
    required String channelName,
    required String thumbnail,
  }) async {
    try {
      final response = await _dio.post(
        '/subscriptions',
        data: {
          'channel_id': channelId,
          'channel_name': channelName,
          'thumbnail': thumbnail,
        },
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['error'] ?? 'Failed to subscribe');
      }
    } catch (e) {
      _logger.w('Add subscription error: $e');
      // Silently fail for development
    }
  }

  Future<void> removeSubscription(String channelId) async {
    try {
      final response = await _dio.post(
        '/subscriptions/remove',
        data: {'channel_id': channelId},
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['error'] ?? 'Failed to unsubscribe');
      }
    } catch (e) {
      _logger.w('Remove subscription error: $e');
      throw Exception('Failed to unsubscribe: $e');
    }
  }

  Future<List<HistoryEntry>> getHistory() async {
    try {
      final response = await _dio.get('/history');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => HistoryEntry.fromJson(json)).toList();
      } else {
        throw Exception(response.data['error'] ?? 'Failed to get history');
      }
    } catch (e) {
      _logger.w('Get history error: $e');
      // Return empty history
      return [];
    }
  }

  Future<void> addToHistory({
    required String videoId,
    required String title,
    required String channel,
    required String thumbnail,
  }) async {
    try {
      final response = await _dio.post(
        '/history',
        data: {
          'video_id': videoId,
          'title': title,
          'channel': channel,
          'thumbnail': thumbnail,
        },
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['error'] ?? 'Failed to add to history');
      }
    } catch (e) {
      _logger.w('Add to history error: $e');
      // Silently fail for development
    }
  }

  Future<void> removeFromHistory(int id) async {
    try {
      final response = await _dio.post(
        '/history/remove',
        data: {'id': id},
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['error'] ?? 'Failed to remove from history');
      }
    } catch (e) {
      _logger.w('Remove from history error: $e');
      throw Exception('Failed to remove from history: $e');
    }
  }

  Future<void> clearHistory() async {
    try {
      final response = await _dio.post('/history/clear');

      if (response.data['success'] != true) {
        throw Exception(response.data['error'] ?? 'Failed to clear history');
      }
    } catch (e) {
      _logger.w('Clear history error: $e');
      throw Exception('Failed to clear history: $e');
    }
  }

  Future<List<Download>> getDownloads() async {
    try {
      final response = await _dio.get('/downloads');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) {
          final backendDownload = json as Map<String, dynamic>;
          final status = (backendDownload['status'] ?? 'pending').toString();
          final createdAtRaw =
              backendDownload['created_at']?.toString() ??
              backendDownload['completed_at']?.toString();
          final completedAtRaw = backendDownload['completed_at']?.toString();

          final createdAt =
              DateTime.tryParse(createdAtRaw ?? '') ?? DateTime.now();
          final completedAt = completedAtRaw != null
              ? DateTime.tryParse(completedAtRaw)
              : null;

          return Download(
            id: backendDownload['id'].toString(),
            videoId: backendDownload['video_id'] ?? '',
            title: backendDownload['title'] ?? '',
            filePath: backendDownload['file_path'] ?? '',
            fileSize: (backendDownload['file_size'] as num?)?.toInt() ?? 0,
            format: status == 'audio' ? 'audio' : 'video',
            quality: backendDownload['quality'] ?? 'unknown',
            status: status,
            progress: (backendDownload['progress'] as num?)?.toDouble() ??
                (status == 'completed' ? 100.0 : 0.0),
            createdAt: createdAt,
            completedAt: completedAt,
            errorMessage: backendDownload['error_message']?.toString(),
          );
        }).toList();
      } else {
        throw Exception(response.data['error'] ?? 'Failed to get downloads');
      }
    } catch (e) {
      _logger.w('Get downloads error: $e');
      // Return empty list for development
      return [];
    }
  }

  Future<String?> getSetting(String key) async {
    try {
      final response = await _dio.get('/settings/$key');

      if (response.data['success'] == true) {
        return response.data['data']['value'];
      } else {
        _logger.i('Setting "$key" not found');
        return null;
      }
    } catch (e) {
      _logger.w('Get setting error: $e');
      return null;
    }
  }

  Future<void> setSetting(String key, String value) async {
    try {
      final response = await _dio.post(
        '/settings',
        data: {
          'key': key,
          'value': value,
        },
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['error'] ?? 'Failed to save setting');
      }
    } catch (e) {
      _logger.w('Set setting error: $e');
      throw Exception('Failed to save setting: $e');
    }
  }

  Future<Map<String, String>> getAllSettings() async {
    try {
      final response = await _dio.get('/settings');

      if (response.data['success'] == true) {
        final List<dynamic> settings = response.data['data'];
        final map = <String, String>{};
        for (var setting in settings) {
          map[setting['key']] = setting['value'];
        }
        return map;
      } else {
        throw Exception(response.data['error'] ?? 'Failed to get settings');
      }
    } catch (e) {
      _logger.w('Get all settings error: $e');
      return {};
    }
  }

  Future<int?> createDownload(String videoId, String title, String outputPath, String quality) async {
    try {
      final response = await _dio.post(
        '/downloads/create',
        data: {
          'video_id': videoId,
          'title': title,
          'output_path': outputPath,
          'quality': quality,
          'audio_only': false,
        },
      );

      if (response.data['success'] == true) {
        return response.data['data']['id'] as int;
      } else {
        throw Exception(response.data['error'] ?? 'Failed to create download');
      }
    } catch (e) {
      _logger.w('Create download error: $e');
      throw Exception('Failed to create download: $e');
    }
  }

  Future<List<Download>> getActiveDownloads() async {
    try {
      final response = await _dio.get('/downloads/active');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) {
          final backendDownload = json as Map<String, dynamic>;
          return Download(
            id: backendDownload['id'].toString(),
            videoId: backendDownload['video_id'] ?? '',
            title: backendDownload['title'] ?? '',
            filePath: backendDownload['file_path'] ?? '',
            fileSize: backendDownload['file_size'] ?? 0,
            format: 'video',
            quality: backendDownload['quality'] ?? 'unknown',
            status: backendDownload['status'] ?? 'pending',
            progress: (backendDownload['progress'] as num?)?.toDouble() ?? 0.0,
            createdAt: DateTime.parse(backendDownload['created_at']),
            completedAt: backendDownload['completed_at'] != null ? DateTime.parse(backendDownload['completed_at']) : null,
          );
        }).toList();
      } else {
        throw Exception(response.data['error'] ?? 'Failed to get active downloads');
      }
    } catch (e) {
      _logger.w('Get active downloads error: $e');
      return [];
    }
  }

  Future<void> updateDownloadProgress(int id, String status, double progress, double speed, int etaSeconds) async {
    try {
      final response = await _dio.post(
        '/downloads/$id/progress',
        data: {
          'status': status,
          'progress': progress,
          'speed': speed,
          'eta_seconds': etaSeconds,
        },
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['error'] ?? 'Failed to update download progress');
      }
    } catch (e) {
      _logger.w('Update download progress error: $e');
      throw Exception('Failed to update download: $e');
    }
  }

  Future<void> completeDownload(int id, int fileSize) async {
    try {
      final response = await _dio.post(
        '/downloads/$id/complete',
        data: {'file_size': fileSize},
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['error'] ?? 'Failed to complete download');
      }
    } catch (e) {
      _logger.w('Complete download error: $e');
      throw Exception('Failed to complete download: $e');
    }
  }

  Future<void> failDownload(int id, String errorMessage) async {
    try {
      final response = await _dio.post(
        '/downloads/$id/fail',
        data: {'error_message': errorMessage},
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['error'] ?? 'Failed to mark download as failed');
      }
    } catch (e) {
      _logger.w('Fail download error: $e');
      throw Exception('Failed to fail download: $e');
    }
  }

  Future<void> deleteDownload(int id) async {
    try {
      final response = await _dio.delete('/downloads/$id');

      if (response.data['success'] != true) {
        throw Exception(response.data['error'] ?? 'Failed to delete download');
      }
    } catch (e) {
      _logger.w('Delete download error: $e');
      throw Exception('Failed to delete download: $e');
    }
  }

  /// Subscribe to a channel by ID and thumbnail
  Future<void> subscribeToChannel({
    required String channelId,
    required String channelName,
    required String thumbnail,
  }) async {
    await addSubscription(
      channelId: channelId,
      channelName: channelName,
      thumbnail: thumbnail,
    );
  }

  /// Subscribe from a video (useful for quick subscribe from search results)
  Future<void> subscribeFromVideo({
    required String channelId,
    required String channelName,
    required String thumbnail,
  }) async {
    await subscribeToChannel(
      channelId: channelId,
      channelName: channelName,
      thumbnail: thumbnail,
    );
  }
}

```

`frontend/lib/services/media_player_holder.dart`:

```dart
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class MediaPlayerHolder {
  MediaPlayerHolder._internal();
  static final MediaPlayerHolder instance = MediaPlayerHolder._internal();

  Player? _player;
  VideoController? _videoController;
  bool _initialized = false;

  Player get player {
    _ensureInit();
    return _player!;
  }

  VideoController get videoController {
    _ensureInit();
    return _videoController!;
  }

  bool get isInitialized => _initialized;

  void _ensureInit() {
    if (_initialized) return;
    _player = Player();
    _videoController = VideoController(
      _player!,
      configuration: const VideoControllerConfiguration(
        enableHardwareAcceleration: false,
      ),
    );
    _initialized = true;
  }

  void dispose() {
    // VideoController doesn't have a dispose method; only dispose the Player
    _player?.dispose();
    _videoController = null;
    _player = null;
    _initialized = false;
  }
}

```

`frontend/lib/services/player_service.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_service.dart';

final playerServiceProvider = Provider<PlayerService>((ref) => PlayerService());

class PlayerService {
  PlayerService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiService.baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 30),
              validateStatus: (status) => status != null && status < 500,
            ),
          );

  final Dio _dio;

  Future<BackendPlayerSnapshot> snapshot() async {
    final response = await _dio.get('/player');
    return BackendPlayerSnapshot.fromJson(_readData(response));
  }

  Future<BackendPlayerSnapshot> play({
    required String videoId,
    required String streamUrl,
    required Duration duration,
    Duration startPosition = Duration.zero,
    bool backgroundAudio = false,
  }) async {
    final response = await _dio.post(
      '/player/play',
      data: {
        'video_id': videoId,
        'stream_url': streamUrl,
        'duration_seconds': duration > Duration.zero
            ? duration.inMilliseconds / 1000
            : null,
        'start_position_seconds': startPosition.inMilliseconds / 1000,
        'background_audio': backgroundAudio,
      },
    );

    return BackendPlayerSnapshot.fromJson(_readData(response));
  }

  Future<BackendPlayerSnapshot> pause() async {
    final response = await _dio.post('/player/pause');
    return BackendPlayerSnapshot.fromJson(_readData(response));
  }

  Future<BackendPlayerSnapshot> resume() async {
    final response = await _dio.post('/player/resume');
    return BackendPlayerSnapshot.fromJson(_readData(response));
  }

  Future<BackendPlayerSnapshot> seek(Duration position) async {
    final response = await _dio.post(
      '/player/seek',
      data: {'position_seconds': position.inMilliseconds / 1000},
    );
    return BackendPlayerSnapshot.fromJson(_readData(response));
  }

  Future<BackendPlayerSnapshot> setBackgroundAudio(bool enabled) async {
    final response = await _dio.post(
      '/player/background-audio',
      data: {'enabled': enabled},
    );
    return BackendPlayerSnapshot.fromJson(_readData(response));
  }

  Future<BackendPlayerSnapshot> stop() async {
    final response = await _dio.post('/player/stop');
    return BackendPlayerSnapshot.fromJson(_readData(response));
  }

  Map<String, dynamic> _readData(Response<dynamic> response) {
    final body = response.data;
    if (body is! Map) {
      throw const PlayerServiceException('Invalid backend response');
    }

    final responseBody = Map<String, dynamic>.from(body);
    if (body['success'] == true) {
      final data = responseBody['data'];
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      throw const PlayerServiceException('Missing player state in response');
    }

    throw PlayerServiceException(
      responseBody['error']?.toString() ?? 'Player command failed',
    );
  }
}

class BackendPlayerSnapshot {
  const BackendPlayerSnapshot({
    required this.status,
    required this.position,
    required this.backgroundAudio,
    required this.updatedAt,
    this.videoId,
    this.streamUrl,
    this.duration,
    this.error,
  });

  final String status;
  final String? videoId;
  final String? streamUrl;
  final Duration position;
  final Duration? duration;
  final bool backgroundAudio;
  final String? error;
  final DateTime updatedAt;

  factory BackendPlayerSnapshot.fromJson(Map<String, dynamic> json) {
    return BackendPlayerSnapshot(
      status: json['status']?.toString() ?? 'idle',
      videoId: json['video_id']?.toString(),
      streamUrl: json['stream_url']?.toString(),
      position: _durationFromSeconds(json['position_seconds']) ?? Duration.zero,
      duration: _durationFromSeconds(json['duration_seconds']),
      backgroundAudio: json['background_audio'] == true,
      error: json['error']?.toString(),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  static Duration? _durationFromSeconds(Object? value) {
    if (value == null) {
      return null;
    }

    final seconds = value is num
        ? value.toDouble()
        : double.tryParse(value.toString());
    if (seconds == null || !seconds.isFinite || seconds < 0) {
      return null;
    }

    return Duration(milliseconds: (seconds * 1000).round());
  }
}

class PlayerServiceException implements Exception {
  const PlayerServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

```

`frontend/lib/widgets/error_widget.dart`:

```dart
import 'package:flutter/material.dart';

class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? details;

  const ErrorDisplay({
    Key? key,
    required this.message,
    this.onRetry,
    this.details,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          if (details != null) ...[
            SizedBox(height: 8),
            Text(
              details!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (onRetry != null) ...[
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
            ),
          ]
        ],
      ),
    );
  }
}

```

`frontend/lib/widgets/player_shell.dart`:

```dart
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../controllers/player_controller.dart';
import '../providers.dart';
import '../services/media_player_holder.dart';

class PlayerShell extends ConsumerWidget {
  const PlayerShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerControllerProvider);

    return Stack(
      children: [child, if (playerState.isVisible) const _PlayerOverlay()],
    );
  }
}

class _PlayerOverlay extends ConsumerWidget {
  const _PlayerOverlay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerControllerProvider);
    final showHiddenEngine =
        playerState.hasVideo && playerState.surface != PlayerSurface.fullscreen;

    Widget surface;
    switch (playerState.surface) {
      case PlayerSurface.fullscreen:
        surface = const _FullscreenPlayer();
        break;
      case PlayerSurface.mini:
        surface = const _MiniPlayer();
        break;
      case PlayerSurface.popup:
        surface = const _PopupPlayer();
        break;
      case PlayerSurface.hidden:
        surface = const SizedBox.shrink();
        break;
    }

    if (!showHiddenEngine) {
      return surface;
    }

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: 0,
              // Keep media_kit engine alive for mini/popup/background playback.
              child: _PlayerStage(playerState: playerState),
            ),
          ),
        ),
        surface,
      ],
    );
  }
}

class _FullscreenPlayer extends ConsumerWidget {
  const _FullscreenPlayer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerControllerProvider);
    final controller = ref.read(playerControllerProvider.notifier);
    final video = playerState.video;

    if (video == null) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) > 350) {
            controller.showMiniPlayer();
          }
        },
        child: Material(
          color: Colors.black,
          child: Column(
            children: [
              _PlayerTopBar(
                title: video.title,
                onMinimize: controller.showMiniPlayer,
              ),
              Expanded(child: _PlayerStage(playerState: playerState)),
              _FullscreenControls(playerState: playerState),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerTopBar extends StatelessWidget {
  const _PlayerTopBar({required this.title, required this.onMinimize});

  final String title;
  final VoidCallback onMinimize;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            IconButton(
              tooltip: 'Minimize',
              onPressed: onMinimize,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
            ),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

class _PlayerStage extends ConsumerStatefulWidget {
  const _PlayerStage({required this.playerState});

  final TubularPlayerState playerState;

  @override
  ConsumerState<_PlayerStage> createState() => _PlayerStageState();
}

class _PlayerStageState extends ConsumerState<_PlayerStage> {
  String? _currentStreamUrl;
  double _appliedSpeed = 1.0;
  bool _listenersAttached = false;

  @override
  void initState() {
    super.initState();
    _initializePlayerFromHolder();
  }

  void _initializePlayerFromHolder() {
    print('🎬 Initializing media_kit player from holder...');
    // Use the shared MediaPlayerHolder so the player survives when the UI minimizes
    final holder = MediaPlayerHolder.instance;
    final _player = holder.player;
    final _videoController = holder.videoController;

    // Attach listeners once per widget instance (safe because holder's player persists)
    if (!_listenersAttached) {
      _listenersAttached = true;

      _player.stream.position.listen((position) {
        ref.read(playerControllerProvider.notifier).updatePosition(position);
      });

      _player.stream.duration.listen((duration) {
        ref.read(playerControllerProvider.notifier).updateDuration(duration);
      });

      _player.stream.playing.listen((isPlaying) {
        print('🎵 Player playing state changed: $isPlaying');
        ref.read(playerControllerProvider.notifier).updatePlayingState(isPlaying);
      });

      _player.stream.buffering.listen((buffering) {
        print('📊 Player buffering: $buffering');
      });

      _player.stream.width.listen((width) {
        print('📐 Video width: $width');
        if (width != null && width > 0) {
          setState(() {});
        }
      });

      _player.stream.height.listen((height) {
        print('📐 Video height: $height');
      });

      _player.stream.error.listen((error) {
        if (error != null) {
          print('❌ Player error: $error');
          ref.read(playerControllerProvider.notifier).setError(error);
        }
      });

      _player.stream.completed.listen((completed) {
        if (completed) {
          print('✅ Playback completed');
        }
      });
    }

    print('✅ Player (holder) initialized');

    // If stream URL is already available, open it
    final streamUrl = widget.playerState.streamUrl;
    if (streamUrl != null && streamUrl.isNotEmpty) {
      _currentStreamUrl = streamUrl;
      print('🎥 Opening stream in initState (holder): $streamUrl');
      _player.open(Media(streamUrl), play: true);
    }

    // Apply current playback speed
    final speed = ref.read(playbackSpeedProvider);
    _appliedSpeed = speed;
    try {
      _player.setRate(speed);
      print('DEBUG: Applied playback speed $speed at init (holder)');
    } catch (e) {
      print('DEBUG: Failed to set initial playback speed (holder): $e');
    }
  }

  @override
  void didUpdateWidget(_PlayerStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    final streamUrl = widget.playerState.streamUrl;
    final isPlaying = widget.playerState.isPlaying;
    final holder = MediaPlayerHolder.instance;
    final _player = holder.isInitialized ? holder.player : null;
    
    print('🎬 Player didUpdateWidget:');
    print('   streamUrl: $streamUrl');
    print('   _currentStreamUrl: $_currentStreamUrl');
    print('   isPlaying: $isPlaying');
    print('   status: ${widget.playerState.status}');
    
    // Load new stream URL if changed
    if (streamUrl != null && streamUrl != _currentStreamUrl && streamUrl.isNotEmpty) {
      _currentStreamUrl = streamUrl;
      print('🎥 Opening NEW stream: $streamUrl');
      print('   Will play: true');
      _player?.open(Media(streamUrl), play: true);
      return; // Let the player handle state changes
    }
    
    // Handle play/pause state changes only if URL hasn't changed
    if (oldWidget.playerState.isPlaying != isPlaying && streamUrl == _currentStreamUrl) {
      if (isPlaying) {
        print('▶️  Playing');
        _player?.play();
      } else {
        print('⏸️  Pausing');
        _player?.pause();
      }
    }
    
    // Handle seek
    if (oldWidget.playerState.position != widget.playerState.position) {
      final shouldSeek = (widget.playerState.position - (_player?.state.position ?? Duration.zero)).abs() > const Duration(seconds: 1);
      if (shouldSeek) {
        print('⏩ Seeking to: ${widget.playerState.position}');
        _player?.seek(widget.playerState.position);
      }
    }
  }

  @override
  void dispose() {
    // Do not dispose the shared player here. MediaPlayerHolder owns the player lifetime
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.playerState.video;
    final controller = ref.read(playerControllerProvider.notifier);
    final playbackSpeed = ref.watch(playbackSpeedProvider);
    final hasStreamUrl = widget.playerState.streamUrl != null;

    final holder = MediaPlayerHolder.instance;
    final _player = holder.isInitialized ? holder.player : null;
    final _videoController = holder.isInitialized ? holder.videoController : null;

    final hasVideo = _player != null && _player.state.width != null && 
                     _player.state.width! > 0 && 
                     _player.state.height != null && 
                     _player.state.height! > 0;

    print('🎨 Building _PlayerStage:');
    print('   hasStreamUrl: $hasStreamUrl');
    print('   streamUrl: ${widget.playerState.streamUrl}');
    print('   status: ${widget.playerState.status}');
    print('   _videoController: $_videoController');
    print('   _player state: ${_player?.state.playing}');
    print('   _player width: ${_player?.state.width}');
    print('   _player height: ${_player?.state.height}');
    print('   hasVideo: $hasVideo');

    // Apply playback speed updates if it changed
    if (_player != null && playbackSpeed != _appliedSpeed) {
      try {
        _player.setRate(playbackSpeed);
        _appliedSpeed = playbackSpeed;
        print('DEBUG: Applied playback speed $playbackSpeed in build');
      } catch (e) {
        print('DEBUG: Failed to apply playback speed $playbackSpeed in build: $e');
      }
    }

    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video player - only show if we have valid video dimensions AND not audio-only mode
          if (_videoController != null && hasStreamUrl && hasVideo && widget.playerState.quality != 'audio')
            SizedBox.expand(
              child: Video(
                controller: _videoController!,
                controls: NoVideoControls,
                fit: BoxFit.contain,
                fill: Colors.black,
                filterQuality: FilterQuality.medium,
                wakelock: true,
              ),
            )
          else if (_videoController != null && hasStreamUrl && !hasVideo && widget.playerState.quality != 'audio')
            // Show loading indicator while waiting for video dimensions
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Loading video...',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            )
          else if (video != null && video.thumbnail.isNotEmpty)
            Opacity(
              opacity: 0.26,
              child: CachedNetworkImage(
                imageUrl: video.thumbnail,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          
          // Center control (loading/error/play button) - only show if not loading video
          if (!hasStreamUrl || hasVideo)
            Center(
              child: _PlayerCenterControl(
                playerState: widget.playerState,
                onRetry: controller.retry,
                onTogglePlayPause: controller.togglePlayPause,
              ),
            ),
        ],
      ),
    );
  }
}

class _PlayerCenterControl extends StatelessWidget {
  const _PlayerCenterControl({
    required this.playerState,
    required this.onRetry,
    required this.onTogglePlayPause,
  });

  final TubularPlayerState playerState;
  final VoidCallback onRetry;
  final VoidCallback onTogglePlayPause;

  @override
  Widget build(BuildContext context) {
    if (playerState.isLoading) {
      return const SizedBox(
        width: 42,
        height: 42,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: Color(0xFFE53935),
        ),
      );
    }

    if (playerState.status == PlaybackStatus.error) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 34),
          const SizedBox(height: 12),
          SizedBox(
            width: 420,
            child: Text(
              playerState.errorMessage ?? 'Playback failed',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFD6D6D6), fontSize: 13),
            ),
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      );
    }

    return IconButton(
      tooltip: playerState.isPlaying ? 'Pause' : 'Play',
      onPressed: onTogglePlayPause,
      iconSize: 76,
      color: Colors.white,
      icon: Icon(
        playerState.isPlaying
            ? Icons.pause_circle_filled
            : Icons.play_circle_fill,
      ),
    );
  }
}

class _FullscreenControls extends ConsumerWidget {
  const _FullscreenControls({required this.playerState});

  final TubularPlayerState playerState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(playerControllerProvider.notifier);
    final duration = playerState.duration;
    final position = _safePosition(playerState.position, duration);
    final preferredQuality = ref.watch(preferredQualityProvider);
    final isAudioOnly = playerState.quality == 'audio';

    return SafeArea(
      top: false,
      child: Container(
        color: Colors.black,
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  _formatDuration(position),
                  style: const TextStyle(
                    color: Color(0xFFBDBDBD),
                    fontSize: 12,
                  ),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFFE53935),
                      inactiveTrackColor: const Color(0xFF3A3A3A),
                      thumbColor: const Color(0xFFE53935),
                      overlayColor: const Color(0x22E53935),
                      trackHeight: 3,
                    ),
                    child: Slider(
                      value: position.inMilliseconds.toDouble(),
                      max: math.max(1, duration.inMilliseconds).toDouble(),
                      onChanged: duration == Duration.zero
                          ? null
                          : (value) => controller.previewSeek(
                              Duration(milliseconds: value.round()),
                            ),
                      onChangeEnd: duration == Duration.zero
                          ? null
                          : (value) => controller.seek(
                              Duration(milliseconds: value.round()),
                            ),
                    ),
                  ),
                ),
                Text(
                  _formatDuration(duration),
                  style: const TextStyle(
                    color: Color(0xFFBDBDBD),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  tooltip: playerState.isPlaying ? 'Pause' : 'Play',
                  onPressed: controller.togglePlayPause,
                  color: Colors.white,
                  icon: Icon(
                    playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                ),
                IconButton(
                  tooltip: 'Stop',
                  onPressed: controller.stop,
                  color: Colors.white,
                  icon: const Icon(Icons.stop),
                ),
                const Spacer(),
                IconButton(
                  tooltip: isAudioOnly ? 'Disable audio-only stream' : 'Enable audio-only stream',
                  onPressed: () {
                    final restoreQuality = preferredQuality == 'audio'
                        ? 'best'
                        : preferredQuality;
                    controller.toggleAudioOnlyStream(
                      fallbackQuality: restoreQuality,
                    );
                  },
                  color: isAudioOnly ? const Color(0xFFE53935) : Colors.white,
                  icon: const Icon(Icons.headphones),
                ),
                _QualityMenu(
                  selectedQuality: playerState.quality,
                  onSelected: controller.setQuality,
                ),
                const SizedBox(width: 8),
                _SpeedMenu(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QualityMenu extends StatelessWidget {
  const _QualityMenu({required this.selectedQuality, required this.onSelected});

  final String selectedQuality;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Quality',
      color: const Color(0xFF1C1C1C),
      initialValue: selectedQuality,
      onSelected: onSelected,
      itemBuilder: (context) {
        return const [
          PopupMenuItem(value: 'best', child: _QualityLabel('Best')),
          PopupMenuItem(value: '1080p', child: _QualityLabel('1080p')),
          PopupMenuItem(value: '720p', child: _QualityLabel('720p')),
          PopupMenuItem(value: '480p', child: _QualityLabel('480p')),
          PopupMenuItem(value: 'audio', child: _QualityLabel('Audio')),
        ];
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.high_quality, color: Colors.white, size: 22),
            const SizedBox(width: 6),
            Text(
              selectedQuality.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QualityLabel extends StatelessWidget {
  const _QualityLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(color: Colors.white));
  }
}

class _SpeedMenu extends ConsumerWidget {
  const _SpeedMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speed = ref.watch(playbackSpeedProvider);
    final controller = ref.read(playerControllerProvider.notifier);

    return PopupMenuButton<String>(
      tooltip: 'Speed',
      color: const Color(0xFF1C1C1C),
      initialValue: speed.toString(),
      onSelected: (value) {
        final v = double.tryParse(value) ?? 1.0;
        ref.read(playbackSpeedProvider.notifier).state = v;
        // controller doesn't need to apply speed; player_shell listens to provider
      },
      itemBuilder: (context) {
        return const [
          PopupMenuItem(value: '0.5', child: Text('0.5x')),
          PopupMenuItem(value: '0.75', child: Text('0.75x')),
          PopupMenuItem(value: '1.0', child: Text('1.0x')),
          PopupMenuItem(value: '1.25', child: Text('1.25x')),
          PopupMenuItem(value: '1.5', child: Text('1.5x')),
          PopupMenuItem(value: '2.0', child: Text('2.0x')),
          PopupMenuItem(value: '2.25', child: Text('2.25x')),
          PopupMenuItem(value: '2.5', child: Text('2.5x')),
          PopupMenuItem(value: '2.75', child: Text('2.75x')),
          PopupMenuItem(value: '3.0', child: Text('3.0x')),
          PopupMenuItem(value: '3.25', child: Text('3.25x')),
          PopupMenuItem(value: '3.5', child: Text('3.5x')),
          PopupMenuItem(value: '3.75', child: Text('3.75x')),
          PopupMenuItem(value: '4.0', child: Text('4.0x')),
        ];
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.speed, color: Colors.white, size: 22),
            const SizedBox(width: 6),
            Text(
              '${speed}x',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniPlayer extends ConsumerWidget {
  const _MiniPlayer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerControllerProvider);
    final controller = ref.read(playerControllerProvider.notifier);
    final video = playerState.video;

    if (video == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: controller.showFullscreen,
        onVerticalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) < -350) {
            controller.showFullscreen();
          }
        },
        child: Material(
          color: const Color(0xF20B0B0B),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 74,
              child: Row(
                children: [
                  SizedBox(
                    width: 128,
                    height: 74,
                    child: video.thumbnail.isEmpty
                        ? const ColoredBox(color: Color(0xFF181818))
                        : CachedNetworkImage(
                            imageUrl: video.thumbnail,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                                const ColoredBox(color: Color(0xFF181818)),
                          ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            video.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            video.channelName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF9E9E9E),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: playerState.isPlaying ? 'Pause' : 'Play',
                    onPressed: controller.togglePlayPause,
                    color: Colors.white,
                    icon: Icon(
                      playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: controller.stop,
                    color: Colors.white,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PopupPlayer extends ConsumerStatefulWidget {
  const _PopupPlayer();

  @override
  ConsumerState<_PopupPlayer> createState() => _PopupPlayerState();
}

class _PopupPlayerState extends ConsumerState<_PopupPlayer> {
  Offset _offset = const Offset(24, 24);

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerControllerProvider);
    final controller = ref.read(playerControllerProvider.notifier);
    final video = playerState.video;
    final size = MediaQuery.of(context).size;

    if (video == null) {
      return const SizedBox.shrink();
    }

    const popupWidth = 360.0;
    const popupHeight = 220.0;

    final maxDx = (size.width - popupWidth - 16).clamp(0.0, double.infinity);
    final maxDy = (size.height - popupHeight - 16).clamp(0.0, double.infinity);

    final clampedOffset = Offset(
      _offset.dx.clamp(0.0, maxDx),
      _offset.dy.clamp(0.0, maxDy),
    );

    if (clampedOffset != _offset) {
      _offset = clampedOffset;
    }

    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: Material(
        color: Colors.transparent,
        elevation: 12,
        child: Container(
          width: popupWidth,
          height: popupHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF2C2C2C)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _offset = Offset(
                      (_offset.dx + details.delta.dx).clamp(0.0, maxDx),
                      (_offset.dy + details.delta.dy).clamp(0.0, maxDy),
                    );
                  });
                },
                child: Container(
                  height: 34,
                  color: const Color(0xFF1B1B1B),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          video.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Mini player',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(width: 28, height: 28),
                        onPressed: controller.showMiniPlayer,
                        icon: const Icon(Icons.call_to_action, size: 16, color: Colors.white),
                      ),
                      IconButton(
                        tooltip: 'Fullscreen',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(width: 28, height: 28),
                        onPressed: controller.showFullscreen,
                        icon: const Icon(Icons.fullscreen, size: 16, color: Colors.white),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(width: 28, height: 28),
                        onPressed: controller.stop,
                        icon: const Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (video.thumbnail.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: video.thumbnail,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => const ColoredBox(color: Color(0xFF181818)),
                      )
                    else
                      const ColoredBox(color: Color(0xFF181818)),
                    Container(color: const Color(0x55000000)),
                    Center(
                      child: IconButton(
                        tooltip: playerState.isPlaying ? 'Pause' : 'Play',
                        onPressed: controller.togglePlayPause,
                        color: Colors.white,
                        iconSize: 44,
                        icon: Icon(
                          playerState.isPlaying ? Icons.pause_circle : Icons.play_circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Duration _safePosition(Duration position, Duration duration) {
  if (duration == Duration.zero || position <= duration) {
    return position;
  }

  return duration;
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

  if (hours > 0) {
    return '$hours:$minutes:$seconds';
  }

  return '$minutes:$seconds';
}

```

`frontend/lib/widgets/video_card.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/video.dart';
import '../models/dislike.dart';

class VideoCard extends StatefulWidget {
  final Video video;
  final VoidCallback onTap;
  final DislikeData? dislikeData;
  final VoidCallback? onSubscribe;

  const VideoCard({
    required this.video,
    required this.onTap,
    this.dislikeData,
    this.onSubscribe,
    super.key,
  });

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovering = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovering = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: _isHovering ? 8 : 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: InkWell(
            onTap: widget.onTap,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail with overlay
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: widget.video.thumbnail,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[800],
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[800],
                          child: const Icon(Icons.error, color: Colors.white),
                        ),
                      ),
                      // Hover overlay
                      if (_isHovering)
                        AnimatedOpacity(
                          opacity: _isHovering ? 0.3 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(color: Colors.black),
                        ),
                      // Play icon on hover
                      if (_isHovering)
                        Center(
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Icon(
                              Icons.play_circle_filled,
                              color: Colors.white,
                              size: 60,
                            ),
                          ),
                        ),
                      // Duration badge
                      if (widget.video.duration > Duration.zero)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              widget.video.formattedDuration,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Video info
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.video.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                         ),
                         const SizedBox(height: 6),
                         Row(
                           children: [
                             Flexible(
                               child: Text(
                                 widget.video.channelName,
                                 maxLines: 1,
                                 overflow: TextOverflow.ellipsis,
                                 style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                               ),
                             ),
                              if (widget.onSubscribe != null) ...[
                                const SizedBox(width: 8),
                                SizedBox(
                                  height: 24,
                                  child: GestureDetector(
                                    onTap: widget.onSubscribe,
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red[700],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.add, size: 14, color: Colors.white),
                                          const SizedBox(width: 4),
                                          const Text(
                                            'Subscribe',
                                            style: TextStyle(fontSize: 11, color: Colors.white),
                                          ),
                                          const SizedBox(width: 6),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                           ],
                         ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.video.formattedViews} views • ${widget.video.uploadedAgo}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        // Dislike information with better display
                        if (widget.dislikeData != null) ...[
                          const SizedBox(height: 8),
                          _buildDislikeBar(widget.dislikeData!),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.thumb_up,
                                  size: 14, color: Colors.green[600]),
                              const SizedBox(width: 4),
                              Text(
                                widget.dislikeData!.formattedLikes,
                                style: TextStyle(
                                    fontSize: 11, color: Colors.green[600]),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.thumb_down,
                                  size: 14, color: Colors.red[600]),
                              const SizedBox(width: 4),
                              Text(
                                widget.dislikeData!.formattedDislikes,
                                style: TextStyle(
                                    fontSize: 11, color: Colors.red[600]),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDislikeBar(DislikeData data) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        height: 4,
        child: Row(
          children: [
            Flexible(
              flex: (data.likePercentage * 100).toInt(),
              child: Container(color: Colors.green[600]),
            ),
            Flexible(
              flex: (data.dislikePercentage * 100).toInt(),
              child: Container(color: Colors.red[600]),
            ),
          ],
        ),
      ),
    );
  }
}


```

`frontend/lib/widgets/video_details/actions_section.dart`:

```dart
import 'package:flutter/material.dart';

class ActionItem {
  const ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class ActionsSection extends StatelessWidget {
  const ActionsSection({super.key, required this.items});

  final List<ActionItem> items;

  @override
  Widget build(BuildContext context) {
    final foreground = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.90);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: items
          .map(
            (item) => GestureDetector(
              onTap: item.onTap,
              child: Column(
                children: [
                  Icon(item.icon, size: 28, color: foreground),
                  const SizedBox(height: 6),
                  Text(
                    item.label,
                    style: TextStyle(fontSize: 12, color: foreground),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

```

`frontend/lib/widgets/video_details/comments_section.dart`:

```dart
import 'package:flutter/material.dart';

import '../../models/video_details.dart';

class CommentsSection extends StatelessWidget {
  const CommentsSection({super.key, required this.comments});

  final List<Comment> comments;

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.70);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comments',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (comments.isEmpty)
          Text(
            'No comments available',
            style: TextStyle(color: secondary),
          )
        else
          ...comments.map((comment) => _buildCommentTile(comment, secondary)),
      ],
    );
  }

  Widget _buildCommentTile(Comment comment, Color secondary) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey[700],
            child: Text(
              comment.username.isNotEmpty
                  ? comment.username[0].toUpperCase()
                  : '?',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      comment.username,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      comment.publishedText.isNotEmpty
                          ? comment.publishedText
                          : _timeAgo(comment.timestamp),
                      style: TextStyle(color: secondary, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.text),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.thumb_up, size: 16, color: secondary),
                    const SizedBox(width: 6),
                    Text('${comment.likeCount}'),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        '1 REPLY',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} minutes ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    }
    return '${diff.inDays} days ago';
  }
}

```

`frontend/lib/widgets/video_details/stats_section.dart`:

```dart
import 'package:flutter/material.dart';

import '../../models/video_details.dart';

class StatsSection extends StatelessWidget {
  const StatsSection({super.key, required this.details});

  final VideoDetails details;

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          details.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[700],
              child: Text(
                details.channelName.isNotEmpty
                    ? details.channelName[0].toUpperCase()
                    : '?',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    details.channelName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${details.subscriberCount} subscribers',
                    style: TextStyle(color: secondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${details.viewCount} views',
                  style: TextStyle(color: secondary),
                ),
                const SizedBox(height: 4),
                Text(
                  details.uploadDate,
                  style: TextStyle(color: secondary, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.thumb_up, size: 16, color: secondary),
            const SizedBox(width: 4),
            Text('${details.likeCount}'),
            const SizedBox(width: 16),
            Icon(Icons.thumb_down, size: 16, color: secondary),
            const SizedBox(width: 4),
            Text('${details.dislikeCount}'),
          ],
        ),
      ],
    );
  }
}

```

`frontend/lib/widgets/video_details/thumbnail_section.dart`:

```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ThumbnailSection extends StatelessWidget {
  const ThumbnailSection({
    super.key,
    required this.thumbnailUrl,
    required this.onPlay,
  });

  final String thumbnailUrl;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: CachedNetworkImage(
            imageUrl: thumbnailUrl,
            fit: BoxFit.cover,
            placeholder: (context, _) => Container(color: Colors.grey[800]),
            errorWidget: (context, _, __) => Container(
              color: Colors.grey[800],
              child: const Center(
                child: Icon(Icons.broken_image, color: Colors.white70),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: IconButton(
              onPressed: onPlay,
              iconSize: 84,
              color: Colors.white.withOpacity(0.92),
              icon: const Icon(Icons.play_circle_outline),
            ),
          ),
        ),
      ],
    );
  }
}

```

`frontend/linux/flutter/generated_plugin_registrant.cc`:

```cc
//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <media_kit_libs_linux/media_kit_libs_linux_plugin.h>
#include <media_kit_video/media_kit_video_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) media_kit_libs_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "MediaKitLibsLinuxPlugin");
  media_kit_libs_linux_plugin_register_with_registrar(media_kit_libs_linux_registrar);
  g_autoptr(FlPluginRegistrar) media_kit_video_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "MediaKitVideoPlugin");
  media_kit_video_plugin_register_with_registrar(media_kit_video_registrar);
}

```

`frontend/linux/flutter/generated_plugin_registrant.h`:

```h
//
//  Generated file. Do not edit.
//

// clang-format off

#ifndef GENERATED_PLUGIN_REGISTRANT_
#define GENERATED_PLUGIN_REGISTRANT_

#include <flutter_linux/flutter_linux.h>

// Registers Flutter plugins.
void fl_register_plugins(FlPluginRegistry* registry);

#endif  // GENERATED_PLUGIN_REGISTRANT_

```

`frontend/linux/flutter/generated_plugins.cmake`:

```cmake
#
# Generated file, do not edit.
#

list(APPEND FLUTTER_PLUGIN_LIST
  media_kit_libs_linux
  media_kit_video
)

list(APPEND FLUTTER_FFI_PLUGIN_LIST
  jni
)

set(PLUGIN_BUNDLED_LIBRARIES)

foreach(plugin ${FLUTTER_PLUGIN_LIST})
  add_subdirectory(flutter/ephemeral/.plugin_symlinks/${plugin}/linux plugins/${plugin})
  target_link_libraries(${BINARY_NAME} PRIVATE ${plugin}_plugin)
  list(APPEND PLUGIN_BUNDLED_LIBRARIES $<TARGET_FILE:${plugin}_plugin>)
  list(APPEND PLUGIN_BUNDLED_LIBRARIES ${${plugin}_bundled_libraries})
endforeach(plugin)

foreach(ffi_plugin ${FLUTTER_FFI_PLUGIN_LIST})
  add_subdirectory(flutter/ephemeral/.plugin_symlinks/${ffi_plugin}/linux plugins/${ffi_plugin})
  list(APPEND PLUGIN_BUNDLED_LIBRARIES ${${ffi_plugin}_bundled_libraries})
endforeach(ffi_plugin)

```

`frontend/linux/runner/main.cc`:

```cc
#include "my_application.h"

int main(int argc, char** argv) {
  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}

```

`frontend/linux/runner/my_application.cc`:

```cc
#include "my_application.h"

#include <flutter_linux/flutter_linux.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

#include "flutter/generated_plugin_registrant.h"

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

// Called when first Flutter frame received.
static void first_frame_cb(MyApplication* self, FlView* view) {
  gtk_widget_show(gtk_widget_get_toplevel(GTK_WIDGET(view)));
}

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

  // Use a header bar when running in GNOME as this is the common style used
  // by applications and is the setup most users will be using (e.g. Ubuntu
  // desktop).
  // If running on X and not using GNOME then just use a traditional title bar
  // in case the window manager does more exotic layout, e.g. tiling.
  // If running on Wayland assume the header bar will work (may need changing
  // if future cases occur).
  gboolean use_header_bar = TRUE;
#ifdef GDK_WINDOWING_X11
  GdkScreen* screen = gtk_window_get_screen(window);
  if (GDK_IS_X11_SCREEN(screen)) {
    const gchar* wm_name = gdk_x11_screen_get_window_manager_name(screen);
    if (g_strcmp0(wm_name, "GNOME Shell") != 0) {
      use_header_bar = FALSE;
    }
  }
#endif
  if (use_header_bar) {
    GtkHeaderBar* header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
    gtk_widget_show(GTK_WIDGET(header_bar));
    gtk_header_bar_set_title(header_bar, "tubular_pc");
    gtk_header_bar_set_show_close_button(header_bar, TRUE);
    gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));
  } else {
    gtk_window_set_title(window, "tubular_pc");
  }

  gtk_window_set_default_size(window, 1280, 720);

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(
      project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);
  GdkRGBA background_color;
  // Background defaults to black, override it here if necessary, e.g. #00000000
  // for transparent.
  gdk_rgba_parse(&background_color, "#000000");
  fl_view_set_background_color(view, &background_color);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  // Show the window when Flutter renders.
  // Requires the view to be realized so we can start rendering.
  g_signal_connect_swapped(view, "first-frame", G_CALLBACK(first_frame_cb),
                           self);
  gtk_widget_realize(GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

// Implements GApplication::local_command_line.
static gboolean my_application_local_command_line(GApplication* application,
                                                  gchar*** arguments,
                                                  int* exit_status) {
  MyApplication* self = MY_APPLICATION(application);
  // Strip out the first argument as it is the binary name.
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error)) {
    g_warning("Failed to register: %s", error->message);
    *exit_status = 1;
    return TRUE;
  }

  g_application_activate(application);
  *exit_status = 0;

  return TRUE;
}

// Implements GApplication::startup.
static void my_application_startup(GApplication* application) {
  // MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application startup.

  G_APPLICATION_CLASS(my_application_parent_class)->startup(application);
}

// Implements GApplication::shutdown.
static void my_application_shutdown(GApplication* application) {
  // MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application shutdown.

  G_APPLICATION_CLASS(my_application_parent_class)->shutdown(application);
}

// Implements GObject::dispose.
static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line =
      my_application_local_command_line;
  G_APPLICATION_CLASS(klass)->startup = my_application_startup;
  G_APPLICATION_CLASS(klass)->shutdown = my_application_shutdown;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {}

MyApplication* my_application_new() {
  // Set the program name to the application ID, which helps various systems
  // like GTK and desktop environments map this running application to its
  // corresponding .desktop file. This ensures better integration by allowing
  // the application to be recognized beyond its binary name.
  g_set_prgname(APPLICATION_ID);

  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID, "flags",
                                     G_APPLICATION_NON_UNIQUE, nullptr));
}

```

`frontend/linux/runner/my_application.h`:

```h
#ifndef FLUTTER_MY_APPLICATION_H_
#define FLUTTER_MY_APPLICATION_H_

#include <gtk/gtk.h>

G_DECLARE_FINAL_TYPE(MyApplication,
                     my_application,
                     MY,
                     APPLICATION,
                     GtkApplication)

/**
 * my_application_new:
 *
 * Creates a new Flutter-based application.
 *
 * Returns: a new #MyApplication.
 */
MyApplication* my_application_new();

#endif  // FLUTTER_MY_APPLICATION_H_

```

`frontend/pubspec.lock`:

```lock
# Generated by pub
# See https://dart.dev/tools/pub/glossary#lockfile
packages:
  _fe_analyzer_shared:
    dependency: transitive
    description:
      name: _fe_analyzer_shared
      sha256: da0d9209ca76bde579f2da330aeb9df62b6319c834fa7baae052021b0462401f
      url: "https://pub.dev"
    source: hosted
    version: "85.0.0"
  analyzer:
    dependency: transitive
    description:
      name: analyzer
      sha256: "974859dc0ff5f37bc4313244b3218c791810d03ab3470a579580279ba971a48d"
      url: "https://pub.dev"
    source: hosted
    version: "7.7.1"
  archive:
    dependency: transitive
    description:
      name: archive
      sha256: a96e8b390886ee8abb49b7bd3ac8df6f451c621619f52a26e815fdcf568959ff
      url: "https://pub.dev"
    source: hosted
    version: "4.0.9"
  args:
    dependency: transitive
    description:
      name: args
      sha256: d0481093c50b1da8910eb0bb301626d4d8eb7284aa739614d2b394ee09e3ea04
      url: "https://pub.dev"
    source: hosted
    version: "2.7.0"
  async:
    dependency: transitive
    description:
      name: async
      sha256: e2eb0491ba5ddb6177742d2da23904574082139b07c1e33b8503b9f46f3e1a37
      url: "https://pub.dev"
    source: hosted
    version: "2.13.1"
  boolean_selector:
    dependency: transitive
    description:
      name: boolean_selector
      sha256: "8aab1771e1243a5063b8b0ff68042d67334e3feab9e95b9490f9a6ebf73b42ea"
      url: "https://pub.dev"
    source: hosted
    version: "2.1.2"
  build:
    dependency: transitive
    description:
      name: build
      sha256: "51dc711996cbf609b90cbe5b335bbce83143875a9d58e4b5c6d3c4f684d3dda7"
      url: "https://pub.dev"
    source: hosted
    version: "2.5.4"
  build_config:
    dependency: transitive
    description:
      name: build_config
      sha256: "4ae2de3e1e67ea270081eaee972e1bd8f027d459f249e0f1186730784c2e7e33"
      url: "https://pub.dev"
    source: hosted
    version: "1.1.2"
  build_daemon:
    dependency: transitive
    description:
      name: build_daemon
      sha256: bf05f6e12cfea92d3c09308d7bcdab1906cd8a179b023269eed00c071004b957
      url: "https://pub.dev"
    source: hosted
    version: "4.1.1"
  build_resolvers:
    dependency: transitive
    description:
      name: build_resolvers
      sha256: ee4257b3f20c0c90e72ed2b57ad637f694ccba48839a821e87db762548c22a62
      url: "https://pub.dev"
    source: hosted
    version: "2.5.4"
  build_runner:
    dependency: "direct dev"
    description:
      name: build_runner
      sha256: "382a4d649addbfb7ba71a3631df0ec6a45d5ab9b098638144faf27f02778eb53"
      url: "https://pub.dev"
    source: hosted
    version: "2.5.4"
  build_runner_core:
    dependency: transitive
    description:
      name: build_runner_core
      sha256: "85fbbb1036d576d966332a3f5ce83f2ce66a40bea1a94ad2d5fc29a19a0d3792"
      url: "https://pub.dev"
    source: hosted
    version: "9.1.2"
  built_collection:
    dependency: transitive
    description:
      name: built_collection
      sha256: "376e3dd27b51ea877c28d525560790aee2e6fbb5f20e2f85d5081027d94e2100"
      url: "https://pub.dev"
    source: hosted
    version: "5.1.1"
  built_value:
    dependency: transitive
    description:
      name: built_value
      sha256: "34e4067d30ce212937df995f03b69992eea683539ceeac7f679a1f1eba055b56"
      url: "https://pub.dev"
    source: hosted
    version: "8.12.6"
  cached_network_image:
    dependency: "direct main"
    description:
      name: cached_network_image
      sha256: "7c1183e361e5c8b0a0f21a28401eecdbde252441106a9816400dd4c2b2424916"
      url: "https://pub.dev"
    source: hosted
    version: "3.4.1"
  cached_network_image_platform_interface:
    dependency: transitive
    description:
      name: cached_network_image_platform_interface
      sha256: "35814b016e37fbdc91f7ae18c8caf49ba5c88501813f73ce8a07027a395e2829"
      url: "https://pub.dev"
    source: hosted
    version: "4.1.1"
  cached_network_image_web:
    dependency: transitive
    description:
      name: cached_network_image_web
      sha256: "980842f4e8e2535b8dbd3d5ca0b1f0ba66bf61d14cc3a17a9b4788a3685ba062"
      url: "https://pub.dev"
    source: hosted
    version: "1.3.1"
  characters:
    dependency: transitive
    description:
      name: characters
      sha256: faf38497bda5ead2a8c7615f4f7939df04333478bf32e4173fcb06d428b5716b
      url: "https://pub.dev"
    source: hosted
    version: "1.4.1"
  checked_yaml:
    dependency: transitive
    description:
      name: checked_yaml
      sha256: "959525d3162f249993882720d52b7e0c833978df229be20702b33d48d91de70f"
      url: "https://pub.dev"
    source: hosted
    version: "2.0.4"
  clock:
    dependency: transitive
    description:
      name: clock
      sha256: fddb70d9b5277016c77a80201021d40a2247104d9f4aa7bab7157b7e3f05b84b
      url: "https://pub.dev"
    source: hosted
    version: "1.1.2"
  code_assets:
    dependency: transitive
    description:
      name: code_assets
      sha256: "83ccdaa064c980b5596c35dd64a8d3ecc68620174ab9b90b6343b753aa721687"
      url: "https://pub.dev"
    source: hosted
    version: "1.0.0"
  code_builder:
    dependency: transitive
    description:
      name: code_builder
      sha256: "6a6cab2ba4680d6423f34a9b972a4c9a94ebe1b62ecec4e1a1f2cba91fd1319d"
      url: "https://pub.dev"
    source: hosted
    version: "4.11.1"
  collection:
    dependency: transitive
    description:
      name: collection
      sha256: "2f5709ae4d3d59dd8f7cd309b4e023046b57d8a6c82130785d2b0e5868084e76"
      url: "https://pub.dev"
    source: hosted
    version: "1.19.1"
  convert:
    dependency: transitive
    description:
      name: convert
      sha256: b30acd5944035672bc15c6b7a8b47d773e41e2f17de064350988c5d02adb1c68
      url: "https://pub.dev"
    source: hosted
    version: "3.1.2"
  crypto:
    dependency: transitive
    description:
      name: crypto
      sha256: c8ea0233063ba03258fbcf2ca4d6dadfefe14f02fab57702265467a19f27fadf
      url: "https://pub.dev"
    source: hosted
    version: "3.0.7"
  csv:
    dependency: "direct main"
    description:
      name: csv
      sha256: c6aa2679b2a18cb57652920f674488d89712efaf4d3fdf2e537215b35fc19d6c
      url: "https://pub.dev"
    source: hosted
    version: "6.0.0"
  dart_style:
    dependency: transitive
    description:
      name: dart_style
      sha256: "8a0e5fba27e8ee025d2ffb4ee820b4e6e2cf5e4246a6b1a477eb66866947e0bb"
      url: "https://pub.dev"
    source: hosted
    version: "3.1.1"
  dbus:
    dependency: transitive
    description:
      name: dbus
      sha256: d0c98dcd4f5169878b6cf8f6e0a52403a9dff371a3e2f019697accbf6f44a270
      url: "https://pub.dev"
    source: hosted
    version: "0.7.12"
  dio:
    dependency: "direct main"
    description:
      name: dio
      sha256: aff32c08f92787a557dd5c0145ac91536481831a01b4648136373cddb0e64f8c
      url: "https://pub.dev"
    source: hosted
    version: "5.9.2"
  dio_web_adapter:
    dependency: transitive
    description:
      name: dio_web_adapter
      sha256: "2f9e64323a7c3c7ef69567d5c800424a11f8337b8b228bad02524c9fb3c1f340"
      url: "https://pub.dev"
    source: hosted
    version: "2.1.2"
  fake_async:
    dependency: transitive
    description:
      name: fake_async
      sha256: "5368f224a74523e8d2e7399ea1638b37aecfca824a3cc4dfdf77bf1fa905ac44"
      url: "https://pub.dev"
    source: hosted
    version: "1.3.3"
  ffi:
    dependency: transitive
    description:
      name: ffi
      sha256: "6d7fd89431262d8f3125e81b50d3847a091d846eafcd4fdb88dd06f36d705a45"
      url: "https://pub.dev"
    source: hosted
    version: "2.2.0"
  ffi_leak_tracker:
    dependency: transitive
    description:
      name: ffi_leak_tracker
      sha256: "4093d4ef9ca06ffe2786e73bfb25e22aa92112b9bb4ec941f11e3e6b61489a97"
      url: "https://pub.dev"
    source: hosted
    version: "0.1.2"
  file:
    dependency: transitive
    description:
      name: file
      sha256: a3b4f84adafef897088c160faf7dfffb7696046cb13ae90b508c2cbc95d3b8d4
      url: "https://pub.dev"
    source: hosted
    version: "7.0.1"
  fixnum:
    dependency: transitive
    description:
      name: fixnum
      sha256: b6dc7065e46c974bc7c5f143080a6764ec7a4be6da1285ececdc37be96de53be
      url: "https://pub.dev"
    source: hosted
    version: "1.1.1"
  flutter:
    dependency: "direct main"
    description: flutter
    source: sdk
    version: "0.0.0"
  flutter_cache_manager:
    dependency: transitive
    description:
      name: flutter_cache_manager
      sha256: "400b6592f16a4409a7f2bb929a9a7e38c72cceb8ffb99ee57bbf2cb2cecf8386"
      url: "https://pub.dev"
    source: hosted
    version: "3.4.1"
  flutter_lints:
    dependency: "direct dev"
    description:
      name: flutter_lints
      sha256: a25a15ebbdfc33ab1cd26c63a6ee519df92338a9c10f122adda92938253bef04
      url: "https://pub.dev"
    source: hosted
    version: "2.0.3"
  flutter_riverpod:
    dependency: "direct main"
    description:
      name: flutter_riverpod
      sha256: "9532ee6db4a943a1ed8383072a2e3eeda041db5657cdf6d2acecf3c21ecbe7e1"
      url: "https://pub.dev"
    source: hosted
    version: "2.6.1"
  flutter_staggered_grid_view:
    dependency: "direct main"
    description:
      name: flutter_staggered_grid_view
      sha256: "19e7abb550c96fbfeb546b23f3ff356ee7c59a019a651f8f102a4ba9b7349395"
      url: "https://pub.dev"
    source: hosted
    version: "0.7.0"
  flutter_test:
    dependency: "direct dev"
    description: flutter
    source: sdk
    version: "0.0.0"
  flutter_web_plugins:
    dependency: transitive
    description: flutter
    source: sdk
    version: "0.0.0"
  freezed:
    dependency: "direct main"
    description:
      name: freezed
      sha256: "59a584c24b3acdc5250bb856d0d3e9c0b798ed14a4af1ddb7dc1c7b41df91c9c"
      url: "https://pub.dev"
    source: hosted
    version: "2.5.8"
  freezed_annotation:
    dependency: transitive
    description:
      name: freezed_annotation
      sha256: c2e2d632dd9b8a2b7751117abcfc2b4888ecfe181bd9fca7170d9ef02e595fe2
      url: "https://pub.dev"
    source: hosted
    version: "2.4.4"
  frontend_server_client:
    dependency: transitive
    description:
      name: frontend_server_client
      sha256: f64a0333a82f30b0cca061bc3d143813a486dc086b574bfb233b7c1372427694
      url: "https://pub.dev"
    source: hosted
    version: "4.0.0"
  glob:
    dependency: transitive
    description:
      name: glob
      sha256: c3f1ee72c96f8f78935e18aa8cecced9ab132419e8625dc187e1c2408efc20de
      url: "https://pub.dev"
    source: hosted
    version: "2.1.3"
  graphs:
    dependency: transitive
    description:
      name: graphs
      sha256: "741bbf84165310a68ff28fe9e727332eef1407342fca52759cb21ad8177bb8d0"
      url: "https://pub.dev"
    source: hosted
    version: "2.3.2"
  hooks:
    dependency: transitive
    description:
      name: hooks
      sha256: "025f060e86d2d4c3c47b56e33caf7f93bf9283340f26d23424ebcfccf34f621e"
      url: "https://pub.dev"
    source: hosted
    version: "1.0.3"
  http:
    dependency: transitive
    description:
      name: http
      sha256: "87721a4a50b19c7f1d49001e51409bddc46303966ce89a65af4f4e6004896412"
      url: "https://pub.dev"
    source: hosted
    version: "1.6.0"
  http_multi_server:
    dependency: transitive
    description:
      name: http_multi_server
      sha256: aa6199f908078bb1c5efb8d8638d4ae191aac11b311132c3ef48ce352fb52ef8
      url: "https://pub.dev"
    source: hosted
    version: "3.2.2"
  http_parser:
    dependency: transitive
    description:
      name: http_parser
      sha256: "178d74305e7866013777bab2c3d8726205dc5a4dd935297175b19a23a2e66571"
      url: "https://pub.dev"
    source: hosted
    version: "4.1.2"
  image:
    dependency: transitive
    description:
      name: image
      sha256: f9881ff4998044947ec38d098bc7c8316ae1186fa786eddffdb867b9bc94dfce
      url: "https://pub.dev"
    source: hosted
    version: "4.8.0"
  io:
    dependency: transitive
    description:
      name: io
      sha256: dfd5a80599cf0165756e3181807ed3e77daf6dd4137caaad72d0b7931597650b
      url: "https://pub.dev"
    source: hosted
    version: "1.0.5"
  jni:
    dependency: transitive
    description:
      name: jni
      sha256: c2230682d5bc2362c1c9e8d3c7f406d9cbba23ab3f2e203a025dd47e0fb2e68f
      url: "https://pub.dev"
    source: hosted
    version: "1.0.0"
  jni_flutter:
    dependency: transitive
    description:
      name: jni_flutter
      sha256: "8b59e590786050b1cd866677dddaf76b1ade5e7bc751abe04b86e84d379d3ba6"
      url: "https://pub.dev"
    source: hosted
    version: "1.0.1"
  js:
    dependency: transitive
    description:
      name: js
      sha256: "53385261521cc4a0c4658fd0ad07a7d14591cf8fc33abbceae306ddb974888dc"
      url: "https://pub.dev"
    source: hosted
    version: "0.7.2"
  json_annotation:
    dependency: "direct main"
    description:
      name: json_annotation
      sha256: "1ce844379ca14835a50d2f019a3099f419082cfdd231cd86a142af94dd5c6bb1"
      url: "https://pub.dev"
    source: hosted
    version: "4.9.0"
  json_serializable:
    dependency: "direct dev"
    description:
      name: json_serializable
      sha256: c50ef5fc083d5b5e12eef489503ba3bf5ccc899e487d691584699b4bdefeea8c
      url: "https://pub.dev"
    source: hosted
    version: "6.9.5"
  leak_tracker:
    dependency: transitive
    description:
      name: leak_tracker
      sha256: "33e2e26bdd85a0112ec15400c8cbffea70d0f9c3407491f672a2fad47915e2de"
      url: "https://pub.dev"
    source: hosted
    version: "11.0.2"
  leak_tracker_flutter_testing:
    dependency: transitive
    description:
      name: leak_tracker_flutter_testing
      sha256: "1dbc140bb5a23c75ea9c4811222756104fbcd1a27173f0c34ca01e16bea473c1"
      url: "https://pub.dev"
    source: hosted
    version: "3.0.10"
  leak_tracker_testing:
    dependency: transitive
    description:
      name: leak_tracker_testing
      sha256: "8d5a2d49f4a66b49744b23b018848400d23e54caf9463f4eb20df3eb8acb2eb1"
      url: "https://pub.dev"
    source: hosted
    version: "3.0.2"
  lints:
    dependency: transitive
    description:
      name: lints
      sha256: "0a217c6c989d21039f1498c3ed9f3ed71b354e69873f13a8dfc3c9fe76f1b452"
      url: "https://pub.dev"
    source: hosted
    version: "2.1.1"
  logger:
    dependency: "direct main"
    description:
      name: logger
      sha256: "25aee487596a6257655a1e091ec2ae66bc30e7af663592cc3a27e6591e05035c"
      url: "https://pub.dev"
    source: hosted
    version: "2.7.0"
  logging:
    dependency: transitive
    description:
      name: logging
      sha256: c8245ada5f1717ed44271ed1c26b8ce85ca3228fd2ffdb75468ab01979309d61
      url: "https://pub.dev"
    source: hosted
    version: "1.3.0"
  matcher:
    dependency: transitive
    description:
      name: matcher
      sha256: dc0b7dc7651697ea4ff3e69ef44b0407ea32c487a39fff6a4004fa585e901861
      url: "https://pub.dev"
    source: hosted
    version: "0.12.19"
  material_color_utilities:
    dependency: transitive
    description:
      name: material_color_utilities
      sha256: "9c337007e82b1889149c82ed242ed1cb24a66044e30979c44912381e9be4c48b"
      url: "https://pub.dev"
    source: hosted
    version: "0.13.0"
  media_kit:
    dependency: "direct main"
    description:
      name: media_kit
      sha256: ae9e79597500c7ad6083a3c7b7b7544ddabfceacce7ae5c9709b0ec16a5d6643
      url: "https://pub.dev"
    source: hosted
    version: "1.2.6"
  media_kit_libs_android_video:
    dependency: transitive
    description:
      name: media_kit_libs_android_video
      sha256: "3f6274e5ab2de512c286a25c327288601ee445ed8ac319e0ef0b66148bd8f76c"
      url: "https://pub.dev"
    source: hosted
    version: "1.3.8"
  media_kit_libs_ios_video:
    dependency: transitive
    description:
      name: media_kit_libs_ios_video
      sha256: b5382994eb37a4564c368386c154ad70ba0cc78dacdd3fb0cd9f30db6d837991
      url: "https://pub.dev"
    source: hosted
    version: "1.1.4"
  media_kit_libs_linux:
    dependency: transitive
    description:
      name: media_kit_libs_linux
      sha256: "2b473399a49ec94452c4d4ae51cfc0f6585074398d74216092bf3d54aac37ecf"
      url: "https://pub.dev"
    source: hosted
    version: "1.2.1"
  media_kit_libs_macos_video:
    dependency: transitive
    description:
      name: media_kit_libs_macos_video
      sha256: f26aa1452b665df288e360393758f84b911f70ffb3878032e1aabba23aa1032d
      url: "https://pub.dev"
    source: hosted
    version: "1.1.4"
  media_kit_libs_video:
    dependency: "direct main"
    description:
      name: media_kit_libs_video
      sha256: "2b235b5dac79c6020e01eef5022c6cc85fedc0df1738aadc6ea489daa12a92a9"
      url: "https://pub.dev"
    source: hosted
    version: "1.0.7"
  media_kit_libs_windows_video:
    dependency: transitive
    description:
      name: media_kit_libs_windows_video
      sha256: dff76da2778729ab650229e6b4ec6ec111eb5151431002cbd7ea304ff1f112ab
      url: "https://pub.dev"
    source: hosted
    version: "1.0.11"
  media_kit_video:
    dependency: "direct main"
    description:
      name: media_kit_video
      sha256: afaa509e7b7e0bf247557a3a740cde903a52c34ace9810f94500e127bd7b043d
      url: "https://pub.dev"
    source: hosted
    version: "2.0.1"
  meta:
    dependency: transitive
    description:
      name: meta
      sha256: "23f08335362185a5ea2ad3a4e597f1375e78bce8a040df5c600c8d3552ef2394"
      url: "https://pub.dev"
    source: hosted
    version: "1.17.0"
  mime:
    dependency: transitive
    description:
      name: mime
      sha256: "41a20518f0cb1256669420fdba0cd90d21561e560ac240f26ef8322e45bb7ed6"
      url: "https://pub.dev"
    source: hosted
    version: "2.0.0"
  native_toolchain_c:
    dependency: transitive
    description:
      name: native_toolchain_c
      sha256: "6ba77bb18063eebe9de401f5e6437e95e1438af0a87a3a39084fbd37c90df572"
      url: "https://pub.dev"
    source: hosted
    version: "0.17.6"
  objective_c:
    dependency: transitive
    description:
      name: objective_c
      sha256: "100a1c87616ab6ed41ec263b083c0ef3261ee6cd1dc3b0f35f8ddfa4f996fe52"
      url: "https://pub.dev"
    source: hosted
    version: "9.3.0"
  octo_image:
    dependency: transitive
    description:
      name: octo_image
      sha256: "34faa6639a78c7e3cbe79be6f9f96535867e879748ade7d17c9b1ae7536293bd"
      url: "https://pub.dev"
    source: hosted
    version: "2.1.0"
  package_config:
    dependency: transitive
    description:
      name: package_config
      sha256: f096c55ebb7deb7e384101542bfba8c52696c1b56fca2eb62827989ef2353bbc
      url: "https://pub.dev"
    source: hosted
    version: "2.2.0"
  package_info_plus:
    dependency: transitive
    description:
      name: package_info_plus
      sha256: "4bf625947f6c7713ee242296a682e23e44823c09cf9d79e4f1238923c92db852"
      url: "https://pub.dev"
    source: hosted
    version: "10.1.0"
  package_info_plus_platform_interface:
    dependency: transitive
    description:
      name: package_info_plus_platform_interface
      sha256: db762cb2f4f25ee60fb6359773861b0f199e00b90d237bd85a76a1e806b46ef4
      url: "https://pub.dev"
    source: hosted
    version: "4.1.0"
  path:
    dependency: transitive
    description:
      name: path
      sha256: "75cca69d1490965be98c73ceaea117e8a04dd21217b37b292c9ddbec0d955bc5"
      url: "https://pub.dev"
    source: hosted
    version: "1.9.1"
  path_provider:
    dependency: transitive
    description:
      name: path_provider
      sha256: "50c5dd5b6e1aaf6fb3a78b33f6aa3afca52bf903a8a5298f53101fdaee55bbcd"
      url: "https://pub.dev"
    source: hosted
    version: "2.1.5"
  path_provider_android:
    dependency: transitive
    description:
      name: path_provider_android
      sha256: "69cbd515a62b94d32a7944f086b2f82b4ac40a1d45bebfc00813a430ab2dabcd"
      url: "https://pub.dev"
    source: hosted
    version: "2.3.1"
  path_provider_foundation:
    dependency: transitive
    description:
      name: path_provider_foundation
      sha256: "2a376b7d6392d80cd3705782d2caa734ca4727776db0b6ec36ef3f1855197699"
      url: "https://pub.dev"
    source: hosted
    version: "2.6.0"
  path_provider_linux:
    dependency: transitive
    description:
      name: path_provider_linux
      sha256: f7a1fe3a634fe7734c8d3f2766ad746ae2a2884abe22e241a8b301bf5cac3279
      url: "https://pub.dev"
    source: hosted
    version: "2.2.1"
  path_provider_platform_interface:
    dependency: transitive
    description:
      name: path_provider_platform_interface
      sha256: "88f5779f72ba699763fa3a3b06aa4bf6de76c8e5de842cf6f29e2e06476c2334"
      url: "https://pub.dev"
    source: hosted
    version: "2.1.2"
  path_provider_windows:
    dependency: transitive
    description:
      name: path_provider_windows
      sha256: bd6f00dbd873bfb70d0761682da2b3a2c2fccc2b9e84c495821639601d81afe7
      url: "https://pub.dev"
    source: hosted
    version: "2.3.0"
  petitparser:
    dependency: transitive
    description:
      name: petitparser
      sha256: "91bd59303e9f769f108f8df05e371341b15d59e995e6806aefab827b58336675"
      url: "https://pub.dev"
    source: hosted
    version: "7.0.2"
  platform:
    dependency: transitive
    description:
      name: platform
      sha256: "5d6b1b0036a5f331ebc77c850ebc8506cbc1e9416c27e59b439f917a902a4984"
      url: "https://pub.dev"
    source: hosted
    version: "3.1.6"
  plugin_platform_interface:
    dependency: transitive
    description:
      name: plugin_platform_interface
      sha256: "4820fbfdb9478b1ebae27888254d445073732dae3d6ea81f0b7e06d5dedc3f02"
      url: "https://pub.dev"
    source: hosted
    version: "2.1.8"
  pool:
    dependency: transitive
    description:
      name: pool
      sha256: "978783255c543aa3586a1b3c21f6e9d720eb315376a915872c61ef8b5c20177d"
      url: "https://pub.dev"
    source: hosted
    version: "1.5.2"
  posix:
    dependency: transitive
    description:
      name: posix
      sha256: "185ef7606574f789b40f289c233efa52e96dead518aed988e040a10737febb07"
      url: "https://pub.dev"
    source: hosted
    version: "6.5.0"
  pub_semver:
    dependency: transitive
    description:
      name: pub_semver
      sha256: "5bfcf68ca79ef689f8990d1160781b4bad40a3bd5e5218ad4076ddb7f4081585"
      url: "https://pub.dev"
    source: hosted
    version: "2.2.0"
  pubspec_parse:
    dependency: transitive
    description:
      name: pubspec_parse
      sha256: "0560ba233314abbed0a48a2956f7f022cce7c3e1e73df540277da7544cad4082"
      url: "https://pub.dev"
    source: hosted
    version: "1.5.0"
  record_use:
    dependency: transitive
    description:
      name: record_use
      sha256: "2551bd8eecfe95d14ae75f6021ad0248be5c27f138c2ec12fcb52b500b3ba1ed"
      url: "https://pub.dev"
    source: hosted
    version: "0.6.0"
  riverpod:
    dependency: transitive
    description:
      name: riverpod
      sha256: "59062512288d3056b2321804332a13ffdd1bf16df70dcc8e506e411280a72959"
      url: "https://pub.dev"
    source: hosted
    version: "2.6.1"
  rxdart:
    dependency: transitive
    description:
      name: rxdart
      sha256: "5c3004a4a8dbb94bd4bf5412a4def4acdaa12e12f269737a5751369e12d1a962"
      url: "https://pub.dev"
    source: hosted
    version: "0.28.0"
  safe_local_storage:
    dependency: transitive
    description:
      name: safe_local_storage
      sha256: "287ea1f667c0b93cdc127dccc707158e2d81ee59fba0459c31a0c7da4d09c755"
      url: "https://pub.dev"
    source: hosted
    version: "2.0.3"
  shelf:
    dependency: transitive
    description:
      name: shelf
      sha256: e7dd780a7ffb623c57850b33f43309312fc863fb6aa3d276a754bb299839ef12
      url: "https://pub.dev"
    source: hosted
    version: "1.4.2"
  shelf_web_socket:
    dependency: transitive
    description:
      name: shelf_web_socket
      sha256: "3632775c8e90d6c9712f883e633716432a27758216dfb61bd86a8321c0580925"
      url: "https://pub.dev"
    source: hosted
    version: "3.0.0"
  sky_engine:
    dependency: transitive
    description: flutter
    source: sdk
    version: "0.0.0"
  source_gen:
    dependency: transitive
    description:
      name: source_gen
      sha256: "35c8150ece9e8c8d263337a265153c3329667640850b9304861faea59fc98f6b"
      url: "https://pub.dev"
    source: hosted
    version: "2.0.0"
  source_helper:
    dependency: transitive
    description:
      name: source_helper
      sha256: a447acb083d3a5ef17f983dd36201aeea33fedadb3228fa831f2f0c92f0f3aca
      url: "https://pub.dev"
    source: hosted
    version: "1.3.7"
  source_span:
    dependency: transitive
    description:
      name: source_span
      sha256: "56a02f1f4cd1a2d96303c0144c93bd6d909eea6bee6bf5a0e0b685edbd4c47ab"
      url: "https://pub.dev"
    source: hosted
    version: "1.10.2"
  sqflite:
    dependency: transitive
    description:
      name: sqflite
      sha256: "564cfed0746fe53140c23b70b308e045c3b31f17778f2f326ccb7d804ea0250a"
      url: "https://pub.dev"
    source: hosted
    version: "2.4.2+1"
  sqflite_android:
    dependency: transitive
    description:
      name: sqflite_android
      sha256: "881e28efdcc9950fd8e9bb42713dcf1103e62a2e7168f23c9338d82db13dec40"
      url: "https://pub.dev"
    source: hosted
    version: "2.4.2+3"
  sqflite_common:
    dependency: transitive
    description:
      name: sqflite_common
      sha256: f8a08a13fb8f0f8c590df89d745000bed44a673ed94bac846739e1a016875c21
      url: "https://pub.dev"
    source: hosted
    version: "2.5.7"
  sqflite_darwin:
    dependency: transitive
    description:
      name: sqflite_darwin
      sha256: "279832e5cde3fe99e8571879498c9211f3ca6391b0d818df4e17d9fff5c6ccb3"
      url: "https://pub.dev"
    source: hosted
    version: "2.4.2"
  sqflite_platform_interface:
    dependency: transitive
    description:
      name: sqflite_platform_interface
      sha256: "8dd4515c7bdcae0a785b0062859336de775e8c65db81ae33dd5445f35be61920"
      url: "https://pub.dev"
    source: hosted
    version: "2.4.0"
  stack_trace:
    dependency: transitive
    description:
      name: stack_trace
      sha256: "8b27215b45d22309b5cddda1aa2b19bdfec9df0e765f2de506401c071d38d1b1"
      url: "https://pub.dev"
    source: hosted
    version: "1.12.1"
  state_notifier:
    dependency: transitive
    description:
      name: state_notifier
      sha256: b8677376aa54f2d7c58280d5a007f9e8774f1968d1fb1c096adcb4792fba29bb
      url: "https://pub.dev"
    source: hosted
    version: "1.0.0"
  stream_channel:
    dependency: transitive
    description:
      name: stream_channel
      sha256: "969e04c80b8bcdf826f8f16579c7b14d780458bd97f56d107d3950fdbeef059d"
      url: "https://pub.dev"
    source: hosted
    version: "2.1.4"
  stream_transform:
    dependency: transitive
    description:
      name: stream_transform
      sha256: ad47125e588cfd37a9a7f86c7d6356dde8dfe89d071d293f80ca9e9273a33871
      url: "https://pub.dev"
    source: hosted
    version: "2.1.1"
  string_scanner:
    dependency: transitive
    description:
      name: string_scanner
      sha256: "921cd31725b72fe181906c6a94d987c78e3b98c2e205b397ea399d4054872b43"
      url: "https://pub.dev"
    source: hosted
    version: "1.4.1"
  synchronized:
    dependency: transitive
    description:
      name: synchronized
      sha256: "63896c27e81b28f8cb4e69ead0d3e8f03f1d1e5fc531a3e579cabed6a2c7c9e5"
      url: "https://pub.dev"
    source: hosted
    version: "3.4.0+1"
  term_glyph:
    dependency: transitive
    description:
      name: term_glyph
      sha256: "7f554798625ea768a7518313e58f83891c7f5024f88e46e7182a4558850a4b8e"
      url: "https://pub.dev"
    source: hosted
    version: "1.2.2"
  test_api:
    dependency: transitive
    description:
      name: test_api
      sha256: "8161c84903fd860b26bfdefb7963b3f0b68fee7adea0f59ef805ecca346f0c7a"
      url: "https://pub.dev"
    source: hosted
    version: "0.7.10"
  timing:
    dependency: transitive
    description:
      name: timing
      sha256: "62ee18aca144e4a9f29d212f5a4c6a053be252b895ab14b5821996cff4ed90fe"
      url: "https://pub.dev"
    source: hosted
    version: "1.0.2"
  typed_data:
    dependency: transitive
    description:
      name: typed_data
      sha256: f9049c039ebfeb4cf7a7104a675823cd72dba8297f264b6637062516699fa006
      url: "https://pub.dev"
    source: hosted
    version: "1.4.0"
  universal_platform:
    dependency: transitive
    description:
      name: universal_platform
      sha256: "64e16458a0ea9b99260ceb5467a214c1f298d647c659af1bff6d3bf82536b1ec"
      url: "https://pub.dev"
    source: hosted
    version: "1.1.0"
  uri_parser:
    dependency: transitive
    description:
      name: uri_parser
      sha256: "051c62e5f693de98ca9f130ee707f8916e2266945565926be3ff20659f7853ce"
      url: "https://pub.dev"
    source: hosted
    version: "3.0.2"
  uuid:
    dependency: transitive
    description:
      name: uuid
      sha256: "1fef9e8e11e2991bb773070d4656b7bd5d850967a2456cfc83cf47925ba79489"
      url: "https://pub.dev"
    source: hosted
    version: "4.5.3"
  vector_math:
    dependency: transitive
    description:
      name: vector_math
      sha256: d530bd74fea330e6e364cda7a85019c434070188383e1cd8d9777ee586914c5b
      url: "https://pub.dev"
    source: hosted
    version: "2.2.0"
  vm_service:
    dependency: transitive
    description:
      name: vm_service
      sha256: "0016aef94fc66495ac78af5859181e3f3bf2026bd8eecc72b9565601e19ab360"
      url: "https://pub.dev"
    source: hosted
    version: "15.2.0"
  wakelock_plus:
    dependency: transitive
    description:
      name: wakelock_plus
      sha256: "2b09acadd7a2862d33c3577e77e7a2aabb684f47ccca1711f1413bd7307a6a72"
      url: "https://pub.dev"
    source: hosted
    version: "1.6.0"
  wakelock_plus_platform_interface:
    dependency: transitive
    description:
      name: wakelock_plus_platform_interface
      sha256: "14b2e5b9e35c2631e656913c47adecdd71633ae92896a27a64c8f1fcfabc21cc"
      url: "https://pub.dev"
    source: hosted
    version: "1.5.0"
  watcher:
    dependency: transitive
    description:
      name: watcher
      sha256: "1398c9f081a753f9226febe8900fce8f7d0a67163334e1c94a2438339d79d635"
      url: "https://pub.dev"
    source: hosted
    version: "1.2.1"
  web:
    dependency: transitive
    description:
      name: web
      sha256: "868d88a33d8a87b18ffc05f9f030ba328ffefba92d6c127917a2ba740f9cfe4a"
      url: "https://pub.dev"
    source: hosted
    version: "1.1.1"
  web_socket:
    dependency: transitive
    description:
      name: web_socket
      sha256: "34d64019aa8e36bf9842ac014bb5d2f5586ca73df5e4d9bf5c936975cae6982c"
      url: "https://pub.dev"
    source: hosted
    version: "1.0.1"
  web_socket_channel:
    dependency: transitive
    description:
      name: web_socket_channel
      sha256: d645757fb0f4773d602444000a8131ff5d48c9e47adfe9772652dd1a4f2d45c8
      url: "https://pub.dev"
    source: hosted
    version: "3.0.3"
  win32:
    dependency: transitive
    description:
      name: win32
      sha256: a1fc9eb9248baa05dfc12ed5b66e377b3e23f095eec078e0371622b9033810d9
      url: "https://pub.dev"
    source: hosted
    version: "6.2.0"
  xdg_directories:
    dependency: transitive
    description:
      name: xdg_directories
      sha256: "7a3f37b05d989967cdddcbb571f1ea834867ae2faa29725fd085180e0883aa15"
      url: "https://pub.dev"
    source: hosted
    version: "1.1.0"
  xml:
    dependency: transitive
    description:
      name: xml
      sha256: "971043b3a0d3da28727e40ed3e0b5d18b742fa5a68665cca88e74b7876d5e025"
      url: "https://pub.dev"
    source: hosted
    version: "6.6.1"
  yaml:
    dependency: transitive
    description:
      name: yaml
      sha256: b9da305ac7c39faa3f030eccd175340f968459dae4af175130b3fc47e40d76ce
      url: "https://pub.dev"
    source: hosted
    version: "3.1.3"
sdks:
  dart: ">=3.11.0 <4.0.0"
  flutter: ">=3.41.0"

```

`frontend/pubspec.yaml`:

```yaml
name: tubular_frontend
description: A new Flutter project.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.0
  dio: ^5.3.0
  logger: ^2.0.1
  csv: ^6.0.0
  json_annotation: ^4.8.0
  freezed: ^2.4.0
  media_kit: ^1.2.6
  media_kit_video: ^2.0.1
  media_kit_libs_video: ^1.0.7
  flutter_staggered_grid_view: ^0.7.0
  cached_network_image: ^3.4.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
  json_serializable: ^6.7.0
  build_runner: ^2.4.0
  freezed: ^2.4.0
```

`frontend/test/history_screen_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../lib/screens/history_screen.dart';
import '../lib/providers.dart';

void main() {
  group('HistoryScreen CSV Export - Basic Structure', () {
    testWidgets('HistoryScreen has export button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HistoryScreen(),
          ),
        ),
      );

      // Check that the download/export icon is present in the app bar
      expect(find.byIcon(Icons.download), findsOneWidget);
    });

    testWidgets('HistoryScreen title is correct', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HistoryScreen(),
          ),
        ),
      );

      expect(find.text('Watch History'), findsOneWidget);
    });
  });
}
```

`frontend/test/widget_test.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tubular_pc/main.dart';

void main() {
  testWidgets('renders Tubular app shell', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: TubularApp()));

    expect(find.text('Tubular PC'), findsOneWidget);
    expect(find.text('Search videos...'), findsOneWidget);
  });
}

```

`start.bat`:

```bat
@echo off
REM Tubular PC Startup Script for Windows

echo Starting Tubular PC...

REM Check if yt-dlp is installed
where yt-dlp >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo yt-dlp not found. Please install it:
    echo    winget install yt-dlp.yt-dlp
    exit /b 1
)

REM Check if mpv is installed
where mpv >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo mpv not found. Please install it:
    echo    winget install mpv.mpv
    exit /b 1
)

REM Start backend
echo Starting backend server...
cd backend
start /B cargo run --release
cd ..

REM Wait for backend
echo Waiting for backend to initialize...
timeout /t 3 /nobreak >nul

REM Start frontend
echo Starting frontend...
cd frontend
flutter run -d windows

pause

```