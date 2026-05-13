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

// Notification checker: periodically checks for new uploads from subscribed channels
async fn notification_checker() {
    loop {
        // Check every 5 minutes (300 seconds)
        tokio::time::sleep(tokio::time::Duration::from_secs(300)).await;

        if let Err(e) = check_new_uploads().await {
            tracing::warn!("Notification checker failed: {}", e);
        }
    }
}

async fn check_new_uploads() -> anyhow::Result<()> {
    let subscriptions = db::get_subscriptions().await?;
    
    for subscription in subscriptions {
        // Get latest videos from channel
        match invidious::get_channel_videos(&subscription.channel_id, 1).await {
            Ok(videos) => {
                // Check first 10 videos for new uploads
                for video in videos.iter().take(10) {
                    let thumbnail = video
                        .thumbnails
                        .first()
                        .map(|thumbnail| thumbnail.url.as_str())
                        .unwrap_or("");

                    // Add notification if not already created
                    if let Err(e) = db::add_notification(
                        &video.video_id,
                        &subscription.channel_id,
                        &video.title,
                        &subscription.channel_name,
                        thumbnail,
                    )
                    .await
                    {
                        tracing::warn!(
                            "Failed to add notification for video {}: {}",
                            video.video_id,
                            e
                        );
                    }
                }
            }
            Err(e) => {
                tracing::warn!(
                    "Failed to fetch videos for channel {}: {}",
                    subscription.channel_id,
                    e
                );
            }
        }
    }

    Ok(())
}

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

    // Start notification checker task
    tokio::spawn(async {
        notification_checker().await;
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
        .route("/channel/:id", get(api::get_channel_info))
        .route("/channel/:id/videos", get(api::get_channel_videos))
        .route("/subscriptions", get(api::get_subscriptions))
        .route("/subscriptions", post(api::add_subscription))
        .route("/subscriptions/remove", post(api::remove_subscription))
        .route("/feed", get(api::get_subscription_feed))
        .route("/trending", get(api::get_trending_videos))
        .route("/recommended/:id", get(api::get_recommended_videos))
        .route("/history", get(api::get_history))
        .route("/history", post(api::add_to_history))
        .route("/history/remove", post(api::remove_from_history))
        .route("/history/clear", post(api::clear_history))
        .route("/history/progress", post(api::save_video_progress))
        .route("/history/progress/:id", get(api::get_video_progress))
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
        .route("/subtitles/:id", get(api::get_subtitles))
        .route("/playlists", get(api::get_playlists))
        .route("/playlists", post(api::create_playlist))
        .route("/playlists/:id", get(api::get_playlist))
        .route("/playlists/:id", delete(api::delete_playlist))
        .route("/playlists/:id/videos", get(api::get_playlist_videos))
        .route("/playlists/:id/videos", post(api::add_video_to_playlist))
        .route("/playlists/:id/videos/remove", post(api::remove_video_from_playlist))
        .route("/invidious/playlists/:id", get(api::get_invidious_playlist))
        .route("/bookmarks", get(api::get_bookmarks))
        .route("/bookmarks", post(api::add_bookmark))
        .route("/bookmarks/:id", delete(api::remove_bookmark))
        .route("/bookmarks/:id/check", get(api::is_bookmarked))
        .route("/notifications", get(api::get_notifications))
        .route("/notifications/read", post(api::mark_notification_as_read))
        .route("/notifications/read-all", post(api::mark_all_notifications_as_read))
        .route("/notifications/:id", delete(api::delete_notification))
        .route("/notifications/count", get(api::get_unread_notification_count))
        .route("/cache/stats", get(api::get_cache_stats))
        .route("/cache", delete(api::clear_cache))
        .route("/cache/cleanup", post(api::cleanup_old_cache))
        .route("/cache/:video_id", get(api::get_cached_metadata))
        .route("/subtitles/:id/search", get(api::search_subtitles))
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
