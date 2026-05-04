# 🎯 TUBULAR PC - COMPLETE BUILD PROMPT

> **Master Development Guide** | Complete architecture, implementation strategy, code patterns, and execution plan for Tubular PC (Desktop YouTube Client)

---

## 📋 TABLE OF CONTENTS

1. [Project Overview](#project-overview)
2. [Architecture & Tech Stack](#architecture--tech-stack)
3. [Project Structure](#project-structure)
4. [Database Schema](#database-schema)
5. [API Design](#api-design)
6. [Implementation Guidelines](#implementation-guidelines)
7. [Code Patterns & Examples](#code-patterns--examples)
8. [Phase-by-Phase Roadmap](#phase-by-phase-roadmap)
9. [Testing Strategy](#testing-strategy)
10. [Development Workflow](#development-workflow)

---

## PROJECT OVERVIEW

### **What is Tubular PC?**

Tubular PC is a **desktop-native YouTube client** combining:
- ✅ Privacy-first video streaming (no Google API)
- ✅ SponsorBlock automatic skip
- ✅ Return YouTube Dislike integration
- ✅ Lightweight, no ads, open-source
- ✅ Desktop optimization (Windows, macOS, Linux)

### **Core Identity**

```
Tubular PC = NewPipe (Android) + SponsorBlock + ReturnYouTubeDislike + Desktop
            + Better UX/Performance + Native platform features
```

### **Success Criteria**

- ✅ Play any YouTube video without ads
- ✅ Download videos (audio/video)
- ✅ Manage subscriptions offline
- ✅ Auto-skip sponsors (SponsorBlock)
- ✅ Show community dislikes (ReturnYouTubeDislike)
- ✅ Cross-platform (Windows/Mac/Linux)
- ✅ Responsive UI with no lag

---

## ARCHITECTURE & TECH STACK

### **Backend Stack**
```
Language:     Rust (performance, safety)
Framework:    Actix-web (async REST API)
Database:     SQLite (local storage)
Video Extract: yt-dlp (extract streams)
Player:       mpv (native desktop player)
```

### **Frontend Stack**
```
Language:     Dart
Framework:    Flutter (desktop: linux/windows/macos)
State Mgmt:   Riverpod
UI Library:   Material Design 3
Architecture: Clean Architecture + MVVM
```

### **External APIs**
```
SponsorBlock:       https://sponsor.ajay.app/api/
ReturnYouTubeDislike: https://returnyoutubedislikeapi.com/api/
yt-dlp:             CLI tool (subprocess calls)
```

### **Architecture Diagram**

```
┌─────────────────────────────────────────────────────────────┐
│                      FLUTTER UI (Dart)                      │
│  Home | Player | Subscriptions | Downloads | History | etc  │
└────────────────────────┬────────────────────────────────────┘
                         │ REST API (JSON)
                         ↓
┌─────────────────────────────────────────────────────────────┐
│              RUST BACKEND (Actix-web)                       │
│  ┌──────────────┬──────────────┬────────────────────────┐  │
│  │ API Handler  │ yt-dlp       │ SponsorBlock/RYD API   │  │
│  │ (routes.rs)  │ (player.rs)  │ (integrations.rs)      │  │
│  └──────────────┴──────────────┴────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │       Database Layer (SQLite)                        │  │
│  │  subscriptions | history | downloads | settings      │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
          ↓                              ↓
    ┌──────────────┐           ┌──────────────────┐
    │  SQLite DB   │           │   yt-dlp (CLI)   │
    │  (local)     │           │   & mpv player   │
    └──────────────┘           └──────────────────┘
```

---

## PROJECT STRUCTURE

### **Complete Directory Layout**

```
tubular-pc/
├── backend/                          # Rust backend
│   ├── Cargo.toml                   # Dependencies
│   ├── Cargo.lock
│   ├── src/
│   │   ├── main.rs                  # Entry point
│   │   ├── lib.rs                   # Lib exports
│   │   ├── api/
│   │   │   ├── mod.rs               # API module
│   │   │   ├── search.rs            # Search endpoint
│   │   │   ├── video.rs             # Video info endpoint
│   │   │   ├── subscriptions.rs     # Sub management
│   │   │   ├── history.rs           # History endpoint
│   │   │   ├── downloads.rs         # Download management
│   │   │   └── settings.rs          # Settings endpoint
│   │   ├── models/
│   │   │   ├── mod.rs
│   │   │   ├── video.rs             # Video data model
│   │   │   ├── subscription.rs      # Subscription model
│   │   │   ├── history.rs           # History entry model
│   │   │   ├── download.rs          # Download model
│   │   │   └── settings.rs          # Settings model
│   │   ├── db/
│   │   │   ├── mod.rs               # DB module
│   │   │   ├── schema.rs            # SQL schema
│   │   │   ├── migrations.rs        # Schema migrations
│   │   │   └── queries.rs           # Query builders
│   │   ├── player/
│   │   │   ├── mod.rs
│   │   │   ├── mpv.rs               # mpv integration
│   │   │   └── stream.rs            # Stream extraction
│   │   ├── extractors/
│   │   │   ├── mod.rs
│   │   │   ├── yt_dlp.rs            # yt-dlp wrapper
│   │   │   ├── sponsorblock.rs      # SponsorBlock API
│   │   │   └── dislike.rs           # Return YT Dislike API
│   │   ├── utils/
│   │   │   ├── mod.rs
│   │   │   ├── errors.rs            # Error types
│   │   │   ├── cache.rs             # Caching layer
│   │   │   └── validators.rs        # Input validation
│   │   └── config.rs                # Configuration
│   ├── tests/
│   │   ├── api_tests.rs
│   │   ├── player_tests.rs
│   │   └── db_tests.rs
│   └── .env.example                 # Environment template
│
├── frontend/                         # Flutter frontend
│   ├── lib/
│   │   ├── main.dart                # App entry
│   │   ├── config/
│   │   │   ├── constants.dart       # App constants
│   │   │   ├── theme.dart           # Theme config
│   │   │   └── api_config.dart      # API endpoints
│   │   ├── models/
│   │   │   ├── video.dart           # Video model
│   │   │   ├── subscription.dart    # Subscription model
│   │   │   ├── history.dart         # History model
│   │   │   ├── download.dart        # Download model
│   │   │   └── settings.dart        # Settings model
│   │   ├── providers/               # Riverpod providers
│   │   │   ├── video_provider.dart
│   │   │   ├── subscription_provider.dart
│   │   │   ├── player_provider.dart
│   │   │   ├── history_provider.dart
│   │   │   ├── download_provider.dart
│   │   │   └── settings_provider.dart
│   │   ├── services/
│   │   │   ├── api_service.dart     # REST client
│   │   │   ├── player_service.dart  # Player control
│   │   │   ├── storage_service.dart # Local storage
│   │   │   └── cache_service.dart   # Cache management
│   │   ├── screens/                 # UI screens
│   │   │   ├── home_screen.dart     # Home/Search
│   │   │   ├── player_screen.dart   # Video player
│   │   │   ├── subscriptions_screen.dart
│   │   │   ├── history_screen.dart
│   │   │   ├── downloads_screen.dart
│   │   │   ├── settings_screen.dart
│   │   │   ├── channel_screen.dart  # Channel page
│   │   │   └── playlists_screen.dart
│   │   ├── widgets/                 # Reusable widgets
│   │   │   ├── video_card.dart
│   │   │   ├── player_shell.dart
│   │   │   ├── channel_card.dart
│   │   │   ├── playlist_card.dart
│   │   │   ├── settings_tile.dart
│   │   │   ├── search_bar.dart
│   │   │   └── loading_spinner.dart
│   │   └── utils/
│   │       ├── formatters.dart      # Format duration, views
│   │       ├── validators.dart      # Input validation
│   │       ├── error_handler.dart   # Error UI handling
│   │       └── extensions.dart      # Dart extensions
│   ├── pubspec.yaml                 # Dependencies
│   ├── pubspec.lock
│   ├── test/
│   │   ├── widget_test.dart
│   │   ├── api_test.dart
│   │   └── integration_test.dart
│   ├── analysis_options.yaml
│   └── README.md
│
├── docs/                            # Documentation
│   ├── API.md                       # API documentation
│   ├── ARCHITECTURE.md              # Architecture details
│   ├── SETUP.md                     # Setup instructions
│   ├── CONTRIBUTING.md              # Contribution guide
│   └── TROUBLESHOOTING.md           # Common issues
│
├── scripts/                         # Helper scripts
│   ├── setup.sh                     # Initial setup
│   ├── start.sh                     # Start dev servers
│   ├── build.sh                     # Build for release
│   └── test.sh                      # Run tests
│
├── docker/                          # Docker files (optional)
│   ├── Dockerfile.backend
│   ├── Dockerfile.frontend
│   └── docker-compose.yml
│
├── .github/
│   ├── workflows/
│   │   ├── ci.yml                   # CI/CD pipeline
│   │   ├── test.yml
│   │   └── release.yml
│   └── ISSUE_TEMPLATE/
│
├── Cargo.toml                       # Workspace Cargo config
├── CHANGELOG.md
├── README.md
├── LICENSE
├── .gitignore
├── .env.example
└── project.md                       # This file

```

---

## DATABASE SCHEMA

### **SQLite Schema (Full)**

```sql
-- Users (future: multi-device sync)
CREATE TABLE users (
    id TEXT PRIMARY KEY,
    username TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_sync TIMESTAMP
);

-- Subscriptions
CREATE TABLE subscriptions (
    id TEXT PRIMARY KEY,
    channel_id TEXT NOT NULL UNIQUE,
    channel_name TEXT NOT NULL,
    channel_thumbnail TEXT,
    subscriber_count INTEGER,
    description TEXT,
    subscribed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_favorite BOOLEAN DEFAULT FALSE,
    notification_enabled BOOLEAN DEFAULT TRUE
);

-- Videos (cached from searches/subscriptions)
CREATE TABLE videos (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    thumbnail TEXT,
    duration INTEGER,
    views INTEGER,
    upload_date TIMESTAMP,
    channel_id TEXT NOT NULL,
    channel_name TEXT NOT NULL,
    url TEXT NOT NULL UNIQUE,
    is_live BOOLEAN DEFAULT FALSE,
    cached_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(channel_id) REFERENCES subscriptions(channel_id)
);

-- Watch History
CREATE TABLE history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    video_id TEXT NOT NULL,
    watched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    watch_duration INTEGER,
    total_duration INTEGER,
    resume_position INTEGER DEFAULT 0,
    FOREIGN KEY(video_id) REFERENCES videos(id)
);

-- Downloads
CREATE TABLE downloads (
    id TEXT PRIMARY KEY,
    video_id TEXT NOT NULL,
    video_title TEXT NOT NULL,
    file_path TEXT NOT NULL UNIQUE,
    file_size INTEGER,
    format TEXT NOT NULL,  -- 'video' | 'audio' | 'both'
    quality TEXT,          -- '360p', '720p', '1080p'
    status TEXT NOT NULL,  -- 'pending' | 'downloading' | 'completed' | 'failed' | 'paused'
    progress REAL DEFAULT 0.0,  -- 0-100
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    error_message TEXT,
    FOREIGN KEY(video_id) REFERENCES videos(id)
);

-- Playlists
CREATE TABLE playlists (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    thumbnail TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_favorite BOOLEAN DEFAULT FALSE
);

-- Playlist Videos
CREATE TABLE playlist_videos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    playlist_id TEXT NOT NULL,
    video_id TEXT NOT NULL,
    position INTEGER,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(playlist_id) REFERENCES playlists(id),
    FOREIGN KEY(video_id) REFERENCES videos(id)
);

-- Settings
CREATE TABLE settings (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    type TEXT,  -- 'string' | 'integer' | 'boolean' | 'json'
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- SponsorBlock Cache
CREATE TABLE sponsorblock_cache (
    video_id TEXT PRIMARY KEY,
    segments TEXT NOT NULL,  -- JSON array
    fetched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(video_id) REFERENCES videos(id)
);

-- Return YouTube Dislike Cache
CREATE TABLE ryd_cache (
    video_id TEXT PRIMARY KEY,
    likes INTEGER,
    dislikes INTEGER,
    rating REAL,
    view_count INTEGER,
    deleted BOOLEAN DEFAULT FALSE,
    fetched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(video_id) REFERENCES videos(id)
);

-- Create indexes for performance
CREATE INDEX idx_video_channel ON videos(channel_id);
CREATE INDEX idx_history_watched ON history(watched_at);
CREATE INDEX idx_history_video ON history(video_id);
CREATE INDEX idx_downloads_status ON downloads(status);
CREATE INDEX idx_playlist_video ON playlist_videos(playlist_id, position);
CREATE INDEX idx_sponsorblock_video ON sponsorblock_cache(video_id);
CREATE INDEX idx_ryd_video ON ryd_cache(video_id);
```

---

## API DESIGN

### **REST API Endpoints**

#### **Search & Discovery**
```
GET  /api/search?q=query&limit=20&offset=0
     → {videos: [{id, title, thumbnail, duration, views, channel}...]}

GET  /api/trending?category=all&region=US
     → {videos: [...]}

GET  /api/video/:video_id
     → {id, title, description, duration, views, channel, uploadDate, comments_count}

GET  /api/video/:video_id/streams
     → {streams: [{quality, format, url, bitrate}...]}

GET  /api/channel/:channel_id
     → {id, name, thumbnail, subscribers, description, videos: [...]}

GET  /api/channel/:channel_id/videos?page=1
     → {videos: [...], hasMore: boolean}
```

#### **Subscriptions**
```
GET  /api/subscriptions
     → {subscriptions: [{id, channel_id, name, thumbnail}...]}

POST /api/subscriptions
     {channel_id: "...", channel_name: "..."}
     → {id, created_at}

DELETE /api/subscriptions/:channel_id
     → {success: true}

GET  /api/subscriptions/:channel_id/latest
     → {videos: [...]}  // Latest uploads from channel
```

#### **Watch History**
```
GET  /api/history?limit=50&offset=0
     → {history: [{id, video, watched_at, resume_position}...]}

POST /api/history
     {video_id: "...", duration_watched: 120, total_duration: 600}
     → {id, created_at}

DELETE /api/history/:history_id
     → {success: true}

DELETE /api/history
     → {success: true}  // Clear all

PUT  /api/history/:history_id/resume
     {position: 45}
     → {resume_position: 45}
```

#### **Downloads**
```
GET  /api/downloads?status=downloading
     → {downloads: [{id, video, progress, status, file_path}...]}

POST /api/downloads
     {video_id: "...", format: "video", quality: "720p"}
     → {id, status: "pending"}

PATCH /api/downloads/:download_id
     {action: "pause"|"resume"|"cancel"}
     → {status: "paused"|"downloading"|"cancelled"}

DELETE /api/downloads/:download_id
     {delete_file: true}
     → {success: true}
```

#### **Playlists**
```
GET  /api/playlists
     → {playlists: [{id, name, thumbnail, video_count}...]}

POST /api/playlists
     {name: "My Playlist", description: "..."}
     → {id, created_at}

GET  /api/playlists/:playlist_id
     → {id, name, videos: [...]}

POST /api/playlists/:playlist_id/videos
     {video_id: "..."}
     → {success: true}

DELETE /api/playlists/:playlist_id/videos/:video_id
     → {success: true}

DELETE /api/playlists/:playlist_id
     → {success: true}
```

#### **Settings**
```
GET  /api/settings
     → {settings: {theme: "dark", quality: "720p", ...}}

PUT  /api/settings
     {key: "theme", value: "light"}
     → {settings: {...}}

GET  /api/settings/:key
     → {key: "theme", value: "dark"}
```

#### **SponsorBlock & RYD**
```
GET  /api/video/:video_id/sponsorblock
     → {segments: [{category, startTime, endTime}...]}

GET  /api/video/:video_id/dislike
     → {likes: 1500, dislikes: 300, rating: 0.83}

POST /api/sponsorblock/report
     {video_id: "...", segment: {category, start, end}}
     → {success: true}
```

### **WebSocket Events (Future)**
```
ws://localhost:3000/ws

Events:
  - download:progress {download_id, progress, speed}
  - video:playing {video_id, timestamp}
  - player:error {error_message}
  - subscription:new_video {channel_id, video}
```

---

## IMPLEMENTATION GUIDELINES

### **Rust Backend Best Practices**

#### **1. Error Handling**
```rust
// Use custom error type
#[derive(Debug)]
pub enum AppError {
    NotFound(String),
    InvalidInput(String),
    ExternalApiError(String),
    DatabaseError(String),
    IoError(String),
}

impl ResponseError for AppError {
    fn error_response(&self) -> HttpResponse {
        match self {
            Self::NotFound(msg) => HttpResponse::NotFound().json(json!({"error": msg})),
            Self::InvalidInput(msg) => HttpResponse::BadRequest().json(json!({"error": msg})),
            _ => HttpResponse::InternalServerError().json(json!({"error": "Internal error"})),
        }
    }
}

pub type AppResult<T> = Result<T, AppError>;
```

#### **2. Database Transactions**
```rust
pub async fn add_video_to_playlist(
    db: &DbPool,
    playlist_id: &str,
    video_id: &str,
) -> AppResult<()> {
    let mut conn = db.get_conn()?;

    conn.transaction::<_, _, rusqlite::Error>(|| {
        // Verify playlist exists
        let count: i32 = conn.query_row(
            "SELECT COUNT(*) FROM playlists WHERE id = ?1",
            params![playlist_id],
            |row| row.get(0),
        )?;

        if count == 0 {
            return Err(rusqlite::Error::ExecuteReturnedNoRows);
        }

        // Insert video
        conn.execute(
            "INSERT INTO playlist_videos (playlist_id, video_id, position)
             VALUES (?1, ?2, (SELECT COALESCE(MAX(position), 0) + 1
                              FROM playlist_videos WHERE playlist_id = ?1))",
            params![playlist_id, video_id],
        )?;

        Ok(())
    })?;

    Ok(())
}
```

#### **3. Async Operations**
```rust
// Use tokio for async operations
pub async fn search_videos(query: &str, limit: u32) -> AppResult<Vec<Video>> {
    let output = tokio::process::Command::new("yt-dlp")
        .arg(format!("ytsearch{}:{}", limit, query))
        .arg("--dump-json")
        .output()
        .await
        .map_err(|e| AppError::IoError(e.to_string()))?;

    let json = String::from_utf8(output.stdout)?;
    let videos = parse_yt_dlp_output(&json)?;

    Ok(videos)
}

// Parallel API calls
let (sponsors, dislikes) = tokio::join!(
    fetch_sponsorblock(&video_id),
    fetch_youtube_dislikes(&video_id)
);
```

### **Flutter Frontend Best Practices**

#### **1. Riverpod State Management**
```dart
// Define provider
final videoProvider = FutureProvider.family<Video, String>(
  (ref, videoId) async {
    final apiService = ref.watch(apiServiceProvider);
    return apiService.getVideo(videoId);
  },
);

// Use in widget
class VideoDetailsWidget extends ConsumerWidget {
  final String videoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoAsync = ref.watch(videoProvider(videoId));

    return videoAsync.when(
      data: (video) => VideoCard(video: video),
      loading: () => const LoadingSpinner(),
      error: (error, stack) => ErrorWidget(error: error.toString()),
    );
  }
}
```

#### **2. Screen Navigation**
```dart
// Use GoRouter for declarative routing
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'player/:videoId',
            builder: (context, state) => PlayerScreen(
              videoId: state.params['videoId']!,
            ),
          ),
          GoRoute(
            path: 'subscriptions',
            builder: (context, state) => const SubscriptionsScreen(),
          ),
        ],
      ),
    ],
  );
});
```

#### **3. Widget Composition**
```dart
// Break down into smaller, testable widgets
class VideoCard extends StatelessWidget {
  final Video video;
  final VoidCallback onTap;

  const VideoCard({required this.video, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Column(
          children: [
            VideoThumbnail(thumbnail: video.thumbnail),
            VideoInfo(video: video),
            VideoActions(video: video),
          ],
        ),
      ),
    );
  }
}

// Separate smaller widgets
class VideoThumbnail extends StatelessWidget {
  final String thumbnail;
  const VideoThumbnail({required this.thumbnail});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.network(thumbnail),
        // Duration badge, play button, etc.
      ],
    );
  }
}
```

---

## CODE PATTERNS & EXAMPLES

### **Example 1: Search Implementation**

**Backend (Rust)**:
```rust
// src/api/search.rs
use actix_web::{web, HttpResponse};
use crate::utils::{AppResult, AppError};

#[derive(Deserialize)]
pub struct SearchQuery {
    q: String,
    #[serde(default = "default_limit")]
    limit: u32,
    #[serde(default)]
    offset: u32,
}

fn default_limit() -> u32 { 20 }

#[get("/search")]
pub async fn search(
    query: web::Query<SearchQuery>,
) -> AppResult<HttpResponse> {
    if query.q.is_empty() {
        return Err(AppError::InvalidInput("Query cannot be empty".into()));
    }

    if query.limit > 100 {
        return Err(AppError::InvalidInput("Limit cannot exceed 100".into()));
    }

    let videos = search_videos(&query.q, query.limit).await?;

    Ok(HttpResponse::Ok().json(json!({
        "videos": videos,
        "count": videos.len(),
    })))
}

async fn search_videos(query: &str, limit: u32) -> AppResult<Vec<Video>> {
    let output = tokio::process::Command::new("yt-dlp")
        .args(&[
            &format!("ytsearch{}:{}", limit, query),
            "--dump-json",
            "--no-warnings",
        ])
        .output()
        .await
        .map_err(|e| AppError::IoError(format!("yt-dlp failed: {}", e)))?;

    if !output.status.success() {
        return Err(AppError::ExternalApiError("yt-dlp search failed".into()));
    }

    let json = String::from_utf8(output.stdout)?;
    parse_yt_dlp_output(&json)
}

fn parse_yt_dlp_output(json: &str) -> AppResult<Vec<Video>> {
    let entries: Vec<serde_json::Value> = serde_json::from_str(json)?;

    Ok(entries.into_iter().map(|entry| {
        Video {
            id: entry["id"].as_str().unwrap_or("").to_string(),
            title: entry["title"].as_str().unwrap_or("").to_string(),
            thumbnail: entry["thumbnail"].as_str().unwrap_or("").to_string(),
            duration: entry["duration"].as_i64().unwrap_or(0) as u32,
            views: entry["view_count"].as_i64().unwrap_or(0) as u32,
            channel: entry["uploader"].as_str().unwrap_or("Unknown").to_string(),
            url: format!("https://youtube.com/watch?v={}",
                        entry["id"].as_str().unwrap_or("")),
            upload_date: entry["upload_date"].as_str().map(|s| s.to_string()),
        }
    }).collect())
}
```

**Frontend (Flutter)**:
```dart
// lib/providers/search_provider.dart
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider.autoDispose<List<Video>>((ref) async {
    final query = ref.watch(searchQueryProvider);

    if (query.isEmpty) {
        return [];
    }

    final apiService = ref.watch(apiServiceProvider);
    return apiService.search(query, limit: 20);
});

// lib/screens/home_screen.dart
class HomeScreen extends ConsumerWidget {
    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final query = ref.watch(searchQueryProvider);
        final searchAsync = ref.watch(searchResultsProvider);

        return Scaffold(
            appBar: AppBar(
                title: SearchBar(
                    onChanged: (value) {
                        ref.read(searchQueryProvider.notifier).state = value;
                    },
                ),
            ),
            body: searchAsync.when(
                data: (videos) => _buildVideoGrid(videos, ref),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildErrorWidget(error),
            ),
        );
    }

    Widget _buildVideoGrid(List<Video> videos, WidgetRef ref) {
        return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
            ),
            itemCount: videos.length,
            itemBuilder: (context, index) {
                return VideoCard(
                    video: videos[index],
                    onTap: () {
                        context.push('/player/${videos[index].id}');
                    },
                );
            },
        );
    }
}
```

### **Example 2: SponsorBlock Integration**

**Backend (Rust)**:
```rust
// src/extractors/sponsorblock.rs
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug)]
pub struct SponsorSegment {
    pub category: String,  // "sponsor", "intro", "outro"
    #[serde(rename = "startTime")]
    pub start_time: f64,
    #[serde(rename = "endTime")]
    pub end_time: f64,
}

pub struct SponsorBlockClient {
    client: reqwest::Client,
    base_url: String,
}

impl SponsorBlockClient {
    pub fn new() -> Self {
        Self {
            client: reqwest::Client::new(),
            base_url: "https://sponsor.ajay.app/api".to_string(),
        }
    }

    pub async fn get_segments(&self, video_id: &str) -> AppResult<Vec<SponsorSegment>> {
        let url = format!(
            "{}/skipSegments?videoID={}&categories=[\"sponsor\",\"intro\",\"outro\"]",
            self.base_url, video_id
        );

        let response = self.client
            .get(&url)
            .send()
            .await
            .map_err(|e| AppError::ExternalApiError(format!("SponsorBlock request failed: {}", e)))?;

        if response.status().is_success() {
            let segments = response.json::<Vec<SponsorSegment>>().await?;
            Ok(segments)
        } else {
            Ok(vec![])  // No segments found
        }
    }
}

// API endpoint
#[get("/video/{video_id}/sponsorblock")]
pub async fn get_sponsorblock(
    video_id: web::Path<String>,
    db: web::Data<DbPool>,
) -> AppResult<HttpResponse> {
    let video_id = video_id.into_inner();

    // Check cache first
    if let Ok(cached) = get_cached_segments(&db, &video_id) {
        return Ok(HttpResponse::Ok().json(json!({"segments": cached})));
    }

    // Fetch from API
    let client = SponsorBlockClient::new();
    let segments = client.get_segments(&video_id).await?;

    // Cache result
    cache_segments(&db, &video_id, &segments)?;

    Ok(HttpResponse::Ok().json(json!({"segments": segments})))
}
```

**Frontend (Flutter)**:
```dart
// lib/providers/sponsorblock_provider.dart
final sponsorBlockProvider = FutureProvider.family<List<Segment>, String>(
  (ref, videoId) async {
    final apiService = ref.watch(apiServiceProvider);
    return apiService.getSponsorBlockSegments(videoId);
  },
);

// lib/widgets/player_shell.dart
class PlayerShell extends ConsumerWidget {
    final String videoId;

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final sponsorAsync = ref.watch(sponsorBlockProvider(videoId));

        return sponsorAsync.when(
            data: (segments) => _buildPlayer(segments),
            loading: () => const SizedBox(),  // No UI, just silent
            error: (_, __) => const SizedBox(),
        );
    }

    Widget _buildPlayer(List<Segment> segments) {
        return Stack(
            children: [
                VideoPlayer(),  // Main player
                if (segments.isNotEmpty)
                    Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: SponsorBlockTimeline(segments: segments),
                    ),
            ],
        );
    }
}

// Visual indicator on timeline
class SponsorBlockTimeline extends StatelessWidget {
    final List<Segment> segments;

    @override
    Widget build(BuildContext context) {
        return Container(
            height: 4,
            color: Colors.grey[700],
            child: Stack(
                children: segments.map((segment) {
                    final startPercent = segment.startTime / totalDuration;
                    final widthPercent = (segment.endTime - segment.startTime) / totalDuration;

                    return Positioned(
                        left: MediaQuery.of(context).size.width * startPercent,
                        width: MediaQuery.of(context).size.width * widthPercent,
                        top: 0,
                        bottom: 0,
                        child: Container(
                            color: _getCategoryColor(segment.category),
                        ),
                    );
                }).toList(),
            ),
        );
    }

    Color _getCategoryColor(String category) {
        switch (category) {
            case 'sponsor': return Colors.red;
            case 'intro': return Colors.blue;
            case 'outro': return Colors.green;
            default: return Colors.grey;
        }
    }
}
```

---

## PHASE-BY-PHASE ROADMAP

### **PHASE 1: MVP (Weeks 1-2)**

**Goal**: Core functionality works

**Deliverables**:
- ✅ Backend API server running
- ✅ Search & video playback working
- ✅ Basic UI (Home, Player)
- ✅ Subscriptions backend + basic UI
- ✅ History backend + basic UI

**Tasks**:
```bash
Week 1:
  - [ ] Complete Subscriptions Screen UI
  - [ ] Complete History Screen UI
  - [ ] Connect both to backend APIs
  - [ ] Basic error handling

Week 2:
  - [ ] Download queue UI (show/pause/cancel)
  - [ ] Basic Settings screen (theme, quality)
  - [ ] Test backend stability
  - [ ] Deploy & run on Linux
```

### **PHASE 2: Integrations (Weeks 3-4)**

**Goal**: SponsorBlock & Dislike working

**Deliverables**:
- ✅ SponsorBlock auto-skip in player
- ✅ Return YouTube Dislike display
- ✅ Settings for both integrations
- ✅ Caching system for both

**Tasks**:
```bash
Week 3:
  - [ ] Wire SponsorBlock API to player
  - [ ] Test sponsor skipping
  - [ ] Implement skip notifications
  - [ ] Add settings for categories

Week 4:
  - [ ] Integrate ReturnYouTubeDislike API
  - [ ] Display on video cards + player
  - [ ] Add bar graph visualization
  - [ ] Cache dislike data
```

### **PHASE 3: Advanced Features (Weeks 5-6)**

**Goal**: Playlists, Channels, Comments

**Deliverables**:
- ✅ Playlists system (create, add, play)
- ✅ Channel pages
- ✅ Comments display
- ✅ Background playback

**Tasks**:
```bash
Week 5:
  - [ ] Implement Playlists database schema
  - [ ] Playlists API endpoints
  - [ ] Playlists UI screen
  - [ ] Add to playlist context menu

Week 6:
  - [ ] Channel page design & implementation
  - [ ] Comments API & display
  - [ ] Background audio playback
  - [ ] Keyboard shortcuts
```

### **PHASE 4: Polish & Release (Weeks 7-8)**

**Goal**: Production-ready

**Deliverables**:
- ✅ Windows/macOS packaging
- ✅ Full testing coverage
- ✅ Documentation
- ✅ Performance optimization

**Tasks**:
```bash
Week 7:
  - [ ] Cross-platform testing
  - [ ] Windows .exe packaging
  - [ ] macOS .dmg packaging
  - [ ] Linux AppImage/Flatpak

Week 8:
  - [ ] Performance profiling & optimization
  - [ ] Security audit
  - [ ] Final testing
  - [ ] Release v1.0
```

---

## TESTING STRATEGY

### **Unit Testing (Rust)**

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_yt_dlp_output() {
        let json = r#"[{"id":"dQw4w9WgXcQ","title":"Video","duration":212}]"#;
        let videos = parse_yt_dlp_output(json).unwrap();

        assert_eq!(videos.len(), 1);
        assert_eq!(videos[0].id, "dQw4w9WgXcQ");
    }

    #[tokio::test]
    async fn test_search_videos() {
        let results = search_videos("rust tutorial", 10).await;
        assert!(results.is_ok());
        assert!(results.unwrap().len() > 0);
    }
}
```

### **Widget Testing (Flutter)**

```dart
void main() {
  testWidgets('VideoCard displays video info', (WidgetTester tester) async {
    final video = Video(
      id: 'test123',
      title: 'Test Video',
      thumbnail: 'https://example.com/thumb.jpg',
      duration: 300,
      views: 1000,
      channel: 'Test Channel',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VideoCard(video: video, onTap: () {}),
        ),
      ),
    );

    expect(find.text('Test Video'), findsOneWidget);
    expect(find.text('Test Channel'), findsOneWidget);
  });
}
```

### **Integration Testing**

```bash
# Test full workflow
1. Start backend server
2. Search for videos
3. Play video
4. Check SponsorBlock segments
5. Check Return YouTube Dislikes
6. Add to playlist
7. Resume from history
```

---

## DEVELOPMENT WORKFLOW

### **Local Development Setup**

```bash
# Clone repo
git clone https://github.com/yourusername/tubular-pc.git
cd tubular-pc

# Install dependencies
./scripts/setup.sh

# Start development
./scripts/start.sh

# Backend runs on: http://localhost:3000
# Frontend runs on: http://localhost:5000 (hot reload)
```

### **Git Workflow**

```bash
# Create feature branch
git checkout -b feat/subscriptions-screen

# Make changes, test locally
cargo test   # backend
flutter test # frontend

# Commit with conventional message
git commit -m "feat: Add subscriptions screen with filter"

# Push and create PR
git push origin feat/subscriptions-screen
```

### **Code Review Checklist**

- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] No hardcoded values
- [ ] Follows project style guide
- [ ] API errors handled
- [ ] Performance considered
- [ ] Security review done

### **Release Process**

```bash
# Update version
# Update CHANGELOG.md
# Create release branch
git checkout -b release/v1.0.0

# Build for all platforms
./scripts/build.sh

# Create GitHub release with assets
# Tag commit: git tag v1.0.0
# Push: git push --tags
```

---

## COMMON PATTERNS

### **Error Recovery**

```rust
// Retry with exponential backoff
async fn fetch_with_retry<T, F, Fut>(
    mut f: F,
    max_retries: u32,
) -> AppResult<T>
where
    F: FnMut() -> Fut,
    Fut: Future<Output = AppResult<T>>,
{
    let mut retries = 0;
    loop {
        match f().await {
            Ok(result) => return Ok(result),
            Err(e) => {
                retries += 1;
                if retries >= max_retries {
                    return Err(e);
                }
                tokio::time::sleep(Duration::from_millis(100 * 2u64.pow(retries))).await;
            }
        }
    }
}
```

### **Caching Pattern**

```dart
// Smart cache invalidation
final videoCache = StateNotifierProvider<
    VideoCacheNotifier,
    Map<String, Video>
>((ref) {
  return VideoCacheNotifier();
});

class VideoCacheNotifier extends StateNotifier<Map<String, Video>> {
  VideoCacheNotifier() : super({});

  void set(String id, Video video) {
    state = {...state, id: video};
  }

  Video? get(String id) => state[id];

  void clear() => state = {};
}
```

---

## DEBUGGING TIPS

### **Backend Debug**

```bash
# Enable debug logging
RUST_LOG=debug cargo run

# Test API endpoints
curl http://localhost:3000/api/search?q=rust

# Check yt-dlp
yt-dlp --version
yt-dlp "ytsearch:test" --dump-json
```

### **Frontend Debug**

```bash
# Enable verbose logs
flutter run -v

# Use DevTools
flutter pub global activate devtools
devtools

# Hot reload
Press 'r' in terminal
```

---

## PERFORMANCE TARGETS

- **Search**: < 2s response time
- **Video load**: < 1s to play
- **UI animations**: 60 FPS
- **Memory usage**: < 300MB idle
- **Startup time**: < 3s

---

## SECURITY CHECKLIST

- [ ] No hardcoded API keys
- [ ] Input validation on all endpoints
- [ ] HTTPS for external APIs
- [ ] SQLite encryption (optional)
- [ ] Secure credential storage
- [ ] Regular dependency updates
- [ ] Security audit before release

---

## RESOURCES

- **yt-dlp**: https://github.com/yt-dlp/yt-dlp
- **SponsorBlock API**: https://wiki.sponsor.ajay.app/w/API_Docs
- **Return YouTube Dislike**: https://returnyoutubedislikeapi.com/
- **Flutter**: https://flutter.dev/docs
- **Rust**: https://doc.rust-lang.org/book/
- **Riverpod**: https://riverpod.dev/

---

## NEXT STEPS

1. **Read this document end-to-end** (15 min)
2. **Review the project structure** (10 min)
3. **Set up local development** (20 min)
4. **Implement Phase 1 features** (1-2 weeks)
5. **Iterate based on feedback**

---

**Created**: 2026 | **For**: Tubular PC Desktop Project | **By**: AI Development Assistant

---

## QUICK REFERENCE

### Commands
```bash
# Backend
cd backend && cargo run --release

# Frontend
cd frontend && flutter run -d windows

# Tests
cargo test && flutter test

# Build Release
./scripts/build.sh
```

### File Locations
```
Backend API:      src/api/*
Frontend UI:      lib/screens/*
Database:         ~/.local/share/tubular-pc/data.db
Config:           ~/.config/tubular-pc/settings.json
```

### API Base URLs
```
Local Dev:        http://localhost:3000/api/
External APIs:    https://sponsor.ajay.app/api/
                  https://returnyoutubedislikeapi.com/
```

---

**Happy coding! 🚀**
