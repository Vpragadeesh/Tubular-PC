use axum::{
    routing::{get, post, delete},
    Router,
};
use std::net::SocketAddr;
use tower_http::cors::CorsLayer;
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
        .with_state(player);

    // Start server
    let addr = SocketAddr::from(([127, 0, 0, 1], 3030));
    tracing::info!("Listening on {}", addr);

    let listener = tokio::net::TcpListener::bind(addr).await?;
    axum::serve(listener, app).await?;

    Ok(())
}
