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
