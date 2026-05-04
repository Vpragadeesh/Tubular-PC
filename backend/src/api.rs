use axum::{
    extract::{Path, Query, State},
    http::StatusCode,
    response::{IntoResponse, Json},
};
use serde::{Deserialize, Serialize};

use crate::{db, player, yt_dlp, sponsorblock, returnyoutubedislike};

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

pub async fn search(Query(params): Query<SearchQuery>) -> impl IntoResponse {
    match yt_dlp::search_videos(&params.q, params.limit).await {
        Ok(results) => (StatusCode::OK, Json(ApiResponse::success(results))),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse::<Vec<yt_dlp::SearchResult>>::error(e.to_string())),
        ),
    }
}

pub async fn get_video_info(Path(id): Path<String>) -> impl IntoResponse {
    match yt_dlp::get_video_info(&id).await {
        Ok(info) => (StatusCode::OK, Json(ApiResponse::success(info))),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse::<yt_dlp::VideoInfo>::error(e.to_string())),
        ),
    }
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
    match yt_dlp::get_stream_url(&id, &params.quality).await {
        Ok(stream) => (StatusCode::OK, Json(ApiResponse::success(stream))),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse::<yt_dlp::StreamUrl>::error(e.to_string())),
        ),
    }
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
pub struct DownloadRequest {
    video_id: String,
    output_path: String,
    quality: String,
    audio_only: bool,
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
