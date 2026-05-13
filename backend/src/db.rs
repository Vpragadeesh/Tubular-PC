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

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
pub struct Bookmark {
    pub id: i64,
    pub video_id: String,
    pub title: String,
    pub channel: String,
    pub thumbnail: String,
    pub duration: i64,
    pub bookmarked_at: String,
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

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
pub struct Notification {
    pub id: i64,
    pub video_id: String,
    pub channel_id: String,
    pub title: String,
    pub channel_name: String,
    pub thumbnail: String,
    pub is_read: bool,
    pub created_at: String,
}

#[derive(Debug, Clone, Serialize, Deserialize, sqlx::FromRow)]
pub struct MetadataCache {
    pub id: i64,
    pub video_id: String,
    pub title: String,
    pub channel_id: String,
    pub channel_name: String,
    pub thumbnail: Option<String>,
    pub duration: Option<i32>,
    pub description: Option<String>,
    pub view_count: Option<i32>,
    pub upload_date: Option<String>,
    pub metadata: Option<String>,
    pub cached_at: String,
    pub last_accessed: String,
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

    // Create bookmarks table
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS bookmarks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            video_id TEXT UNIQUE NOT NULL,
            title TEXT NOT NULL,
            channel TEXT NOT NULL,
            thumbnail TEXT,
            duration INTEGER,
            bookmarked_at TEXT NOT NULL
        )
        "#,
    )
    .execute(&pool)
    .await?;

    // Create notifications table
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS notifications (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            video_id TEXT NOT NULL,
            channel_id TEXT NOT NULL,
            title TEXT NOT NULL,
            channel_name TEXT NOT NULL,
            thumbnail TEXT,
            is_read INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL,
            UNIQUE(video_id)
        )
        "#,
    )
    .execute(&pool)
    .await?;

    // Create metadata cache table for offline support
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS metadata_cache (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            video_id TEXT UNIQUE NOT NULL,
            title TEXT NOT NULL,
            channel_id TEXT NOT NULL,
            channel_name TEXT NOT NULL,
            thumbnail TEXT,
            duration INTEGER,
            description TEXT,
            view_count INTEGER,
            upload_date TEXT,
            metadata JSON,
            cached_at TEXT NOT NULL,
            last_accessed TEXT NOT NULL
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

pub async fn save_video_progress(video_id: &str, progress: f64) -> Result<()> {
    let pool = get_pool();
    sqlx::query(
        "UPDATE history SET progress = ? WHERE video_id = ? AND id = (SELECT id FROM history WHERE video_id = ? ORDER BY watched_at DESC LIMIT 1)"
    )
    .bind(progress)
    .bind(video_id)
    .bind(video_id)
    .execute(pool)
    .await?;
    Ok(())
}

pub async fn get_video_progress(video_id: &str) -> Result<Option<f64>> {
    let pool = get_pool();
    let row: Option<(f64,)> = sqlx::query_as(
        "SELECT progress FROM history WHERE video_id = ? AND progress IS NOT NULL ORDER BY watched_at DESC LIMIT 1"
    )
    .bind(video_id)
    .fetch_optional(pool)
    .await?;
    
    Ok(row.map(|(p,)| p))
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

// Bookmark methods
pub async fn add_bookmark(
    video_id: &str,
    title: &str,
    channel: &str,
    thumbnail: &str,
    duration: i64,
) -> Result<()> {
    let pool = get_pool();
    let now = chrono::Utc::now().to_rfc3339();
    sqlx::query(
        r#"
        INSERT OR REPLACE INTO bookmarks (video_id, title, channel, thumbnail, duration, bookmarked_at)
        VALUES (?, ?, ?, ?, ?, ?)
        "#,
    )
    .bind(video_id)
    .bind(title)
    .bind(channel)
    .bind(thumbnail)
    .bind(duration)
    .bind(now)
    .execute(pool)
    .await?;
    Ok(())
}

pub async fn remove_bookmark(video_id: &str) -> Result<()> {
    let pool = get_pool();
    sqlx::query("DELETE FROM bookmarks WHERE video_id = ?")
        .bind(video_id)
        .execute(pool)
        .await?;
    Ok(())
}

pub async fn get_bookmarks() -> Result<Vec<Bookmark>> {
    let pool = get_pool();
    let bookmarks = sqlx::query_as::<_, Bookmark>("SELECT * FROM bookmarks ORDER BY bookmarked_at DESC")
        .fetch_all(pool)
        .await?;
    Ok(bookmarks)
}

pub async fn is_bookmarked(video_id: &str) -> Result<bool> {
    let pool = get_pool();
    let row = sqlx::query("SELECT 1 FROM bookmarks WHERE video_id = ?")
        .bind(video_id)
        .fetch_optional(pool)
        .await?;
    Ok(row.is_some())
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

// Notification operations
pub async fn add_notification(
    video_id: &str,
    channel_id: &str,
    title: &str,
    channel_name: &str,
    thumbnail: &str,
) -> Result<()> {
    let pool = get_pool();
    let now = chrono::Utc::now().to_rfc3339();

    sqlx::query(
        "INSERT OR IGNORE INTO notifications (video_id, channel_id, title, channel_name, thumbnail, is_read, created_at) 
         VALUES (?, ?, ?, ?, ?, 0, ?)"
    )
    .bind(video_id)
    .bind(channel_id)
    .bind(title)
    .bind(channel_name)
    .bind(thumbnail)
    .bind(now)
    .execute(pool)
    .await?;

    Ok(())
}

pub async fn get_notifications(unread_only: bool) -> Result<Vec<Notification>> {
    let pool = get_pool();
    let query = if unread_only {
        "SELECT id, video_id, channel_id, title, channel_name, thumbnail, is_read, created_at FROM notifications WHERE is_read = 0 ORDER BY created_at DESC"
    } else {
        "SELECT id, video_id, channel_id, title, channel_name, thumbnail, is_read, created_at FROM notifications ORDER BY created_at DESC"
    };
    
    let notifications = sqlx::query_as::<_, Notification>(query)
        .fetch_all(pool)
        .await?;
    Ok(notifications)
}

pub async fn mark_notification_as_read(notification_id: i64) -> Result<()> {
    let pool = get_pool();
    sqlx::query("UPDATE notifications SET is_read = 1 WHERE id = ?")
        .bind(notification_id)
        .execute(pool)
        .await?;
    Ok(())
}

pub async fn mark_all_notifications_as_read() -> Result<()> {
    let pool = get_pool();
    sqlx::query("UPDATE notifications SET is_read = 1 WHERE is_read = 0")
        .execute(pool)
        .await?;
    Ok(())
}

pub async fn delete_notification(notification_id: i64) -> Result<()> {
    let pool = get_pool();
    sqlx::query("DELETE FROM notifications WHERE id = ?")
        .bind(notification_id)
        .execute(pool)
        .await?;
    Ok(())
}

pub async fn get_unread_notification_count() -> Result<i64> {
    let pool = get_pool();
    let count: i64 = sqlx::query_scalar("SELECT COUNT(*) FROM notifications WHERE is_read = 0")
        .fetch_one(pool)
        .await?;
    Ok(count)
}

// Metadata cache operations for offline support
pub async fn cache_video_metadata(
    video_id: &str,
    title: &str,
    channel_id: &str,
    channel_name: &str,
    thumbnail: Option<&str>,
    duration: Option<i32>,
    description: Option<&str>,
    view_count: Option<i32>,
    upload_date: Option<&str>,
) -> Result<()> {
    let pool = get_pool();
    let now = chrono::Utc::now().to_rfc3339();

    sqlx::query(
        r#"
        INSERT OR REPLACE INTO metadata_cache 
        (video_id, title, channel_id, channel_name, thumbnail, duration, description, 
         view_count, upload_date, cached_at, last_accessed)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        "#,
    )
    .bind(video_id)
    .bind(title)
    .bind(channel_id)
    .bind(channel_name)
    .bind(thumbnail)
    .bind(duration)
    .bind(description)
    .bind(view_count)
    .bind(upload_date)
    .bind(&now)
    .bind(&now)
    .execute(pool)
    .await?;

    Ok(())
}

pub async fn get_cached_metadata(video_id: &str) -> Result<Option<MetadataCache>> {
    let pool = get_pool();
    
    // Update last_accessed timestamp
    let now = chrono::Utc::now().to_rfc3339();
    let _ = sqlx::query("UPDATE metadata_cache SET last_accessed = ? WHERE video_id = ?")
        .bind(&now)
        .bind(video_id)
        .execute(pool)
        .await;

    let cache = sqlx::query_as::<_, MetadataCache>(
        "SELECT * FROM metadata_cache WHERE video_id = ?"
    )
    .bind(video_id)
    .fetch_optional(pool)
    .await?;

    Ok(cache)
}

pub async fn get_cache_stats() -> Result<(i64, String)> {
    let pool = get_pool();
    
    let count: i64 = sqlx::query_scalar("SELECT COUNT(*) FROM metadata_cache")
        .fetch_one(pool)
        .await?;

    let size_kb: f64 = sqlx::query_scalar(
        "SELECT ROUND(SUM(LENGTH(title) + LENGTH(channel_name) + LENGTH(description) + LENGTH(metadata)) / 1024.0, 2) FROM metadata_cache"
    )
    .fetch_one(pool)
    .await
    .unwrap_or(0.0);

    Ok((count, format!("{:.2} KB", size_kb)))
}

pub async fn clear_cache() -> Result<i64> {
    let pool = get_pool();
    
    let result = sqlx::query("DELETE FROM metadata_cache")
        .execute(pool)
        .await?;

    Ok(result.rows_affected() as i64)
}

pub async fn clear_old_cache(days: i32) -> Result<i64> {
    let pool = get_pool();
    
    let cutoff_date = chrono::Utc::now() - chrono::Duration::days(days as i64);
    let cutoff_iso = cutoff_date.to_rfc3339();

    let result = sqlx::query("DELETE FROM metadata_cache WHERE cached_at < ?")
        .bind(cutoff_iso)
        .execute(pool)
        .await?;

    Ok(result.rows_affected() as i64)
}
