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

    DB_POOL.set(pool).map_err(|_| anyhow::anyhow!("Failed to set DB pool"))?;
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

    let result = sqlx::query(
        "INSERT INTO downloads (video_id, title, file_path, quality, status, progress, created_at) VALUES (?, ?, ?, ?, 'pending', 0.0, ?)"
    )
    .bind(video_id)
    .bind(title)
    .bind(file_path)
    .bind(quality)
    .bind(&now)
    .execute(pool)
    .await?;

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

pub async fn add_download(video_id: &str, title: &str, file_path: &str, quality: &str) -> Result<()> {
    let pool = get_pool();
    let now = chrono::Utc::now().to_rfc3339();

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

    Ok(())
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
