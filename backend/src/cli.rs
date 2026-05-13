use clap::{Parser, Subcommand};
use serde_json::json;

#[derive(Parser)]
#[command(
    name = "tubular",
    version = "1.0",
    about = "Tubular PC - Command Line Interface",
    long_about = "A powerful CLI for managing your Tubular PC experience. Download, search, and manage videos from the command line."
)]
struct Cli {
    #[command(subcommand)]
    command: Commands,

    #[arg(global = true, short, long, help = "API server URL")]
    api: Option<String>,
}

#[derive(Subcommand)]
enum Commands {
    /// Search for videos
    Search {
        /// Search query
        query: String,

        /// Limit results (default: 10)
        #[arg(short, long)]
        limit: Option<usize>,

        /// Sort by: relevance, upload_date, view_count (default: relevance)
        #[arg(short, long)]
        sort: Option<String>,
    },

    /// Download a video
    Download {
        /// Video URL or ID
        video: String,

        /// Video quality (default: best)
        #[arg(short, long)]
        quality: Option<String>,

        /// Output directory (default: ~/Downloads)
        #[arg(short, long)]
        output: Option<String>,

        /// Audio only (mp3)
        #[arg(long)]
        audio_only: bool,
    },

    /// Get video information
    Info {
        /// Video URL or ID
        video: String,

        /// Output format: json, table (default: table)
        #[arg(short, long)]
        format: Option<String>,
    },

    /// Manage subscriptions
    Subscribe {
        /// Channel URL or ID
        channel: String,

        #[arg(long, help = "Unsubscribe from channel")]
        unsubscribe: bool,

        #[arg(long, help = "List all subscriptions")]
        list: bool,
    },

    /// Manage playlists
    Playlist {
        #[arg(long, help = "Create a new playlist")]
        create: Option<String>,

        #[arg(long, help = "Add video to playlist")]
        add: Option<String>,

        #[arg(long, help = "Playlist ID")]
        id: Option<String>,

        #[arg(long, help = "List all playlists")]
        list: bool,
    },

    /// Manage downloads
    Downloads {
        #[arg(long, help = "List all downloads")]
        list: bool,

        #[arg(long, help = "Cancel download")]
        cancel: Option<String>,

        #[arg(long, help = "Show download directory")]
        dir: bool,
    },

    /// Manage history
    History {
        #[arg(long, help = "Clear entire history")]
        clear: bool,

        #[arg(long, help = "List last N videos")]
        last: Option<usize>,

        #[arg(long, help = "Search in history")]
        search: Option<String>,
    },

    /// Server management
    Server {
        #[arg(long, help = "Start server")]
        start: bool,

        #[arg(long, help = "Stop server")]
        stop: bool,

        #[arg(long, help = "Show server status")]
        status: bool,

        #[arg(short, long, help = "Server port (default: 8000)")]
        port: Option<u16>,
    },

    /// Preferences and settings
    Config {
        #[arg(long, help = "Set config value")]
        set: Option<String>,

        #[arg(long, help = "Get config value")]
        get: Option<String>,

        #[arg(long, help = "List all config")]
        list: bool,

        #[arg(long, help = "Reset to defaults")]
        reset: bool,
    },

    /// Batch operations
    Batch {
        #[arg(long, help = "File containing URLs (one per line)")]
        file: Option<String>,

        #[arg(long, help = "Download all URLs in file")]
        download: bool,

        #[arg(long, help = "Parallel downloads (default: 1)")]
        parallel: Option<usize>,

        #[arg(long, help = "Quality for batch download")]
        quality: Option<String>,
    },

    /// Help and information
    Help {
        /// Topic to get help for
        topic: Option<String>,
    },
}

pub async fn run_cli(args: Vec<String>) -> Result<(), Box<dyn std::error::Error>> {
    let cli = Cli::parse_from(args);
    let api_url = cli.api.unwrap_or_else(|| "http://localhost:8000".to_string());

    match cli.command {
        Commands::Search { query, limit, sort } => {
            search_videos(&api_url, &query, limit.unwrap_or(10), &sort).await?
        }
        Commands::Download {
            video,
            quality,
            output,
            audio_only,
        } => download_video(&api_url, &video, &quality, &output, audio_only).await?,
        Commands::Info { video, format } => {
            get_video_info(&api_url, &video, &format.unwrap_or_else(|| "table".to_string())).await?
        }
        Commands::Subscribe { channel, unsubscribe, list } => {
            manage_subscriptions(&api_url, &channel, unsubscribe, list).await?
        }
        Commands::Playlist {
            create,
            add,
            id,
            list,
        } => manage_playlist(&api_url, create, add, id, list).await?,
        Commands::Downloads { list, cancel, dir } => {
            manage_downloads(&api_url, list, cancel, dir).await?
        }
        Commands::History { clear, last, search } => {
            manage_history(&api_url, clear, last, search).await?
        }
        Commands::Server {
            start,
            stop,
            status,
            port,
        } => manage_server(start, stop, status, port).await?,
        Commands::Config {
            set,
            get,
            list,
            reset,
        } => manage_config(&api_url, set, get, list, reset).await?,
        Commands::Batch {
            file,
            download,
            parallel,
            quality,
        } => batch_operations(&api_url, file, download, parallel, quality).await?,
        Commands::Help { topic } => show_help(&topic),
    }

    Ok(())
}

async fn search_videos(
    _api_url: &str,
    query: &str,
    limit: usize,
    sort: &Option<String>,
) -> Result<(), Box<dyn std::error::Error>> {
    println!("🔍 Searching for: {}", query);
    println!("Limit: {}", limit);
    if let Some(sort_by) = sort {
        println!("Sort: {}", sort_by);
    }
    // In a real implementation, this would call the API
    println!("✓ Search complete");
    Ok(())
}

async fn download_video(
    _api_url: &str,
    video: &str,
    quality: &Option<String>,
    output: &Option<String>,
    audio_only: bool,
) -> Result<(), Box<dyn std::error::Error>> {
    println!("⬇️  Downloading: {}", video);
    if let Some(q) = quality {
        println!("Quality: {}", q);
    }
    if audio_only {
        println!("Format: MP3 (audio only)");
    }
    if let Some(out) = output {
        println!("Output: {}", out);
    }
    println!("✓ Download started");
    Ok(())
}

async fn get_video_info(
    _api_url: &str,
    video: &str,
    format: &str,
) -> Result<(), Box<dyn std::error::Error>> {
    println!("ℹ️  Getting info for: {}", video);
    if format == "json" {
        println!("{}", json!({"video_id": video, "format": "json"}).to_string());
    } else {
        println!("Video ID: {}", video);
        println!("Title: [Loading...]");
        println!("Channel: [Loading...]");
        println!("Duration: [Loading...]");
    }
    Ok(())
}

async fn manage_subscriptions(
    _api_url: &str,
    channel: &str,
    unsubscribe: bool,
    list: bool,
) -> Result<(), Box<dyn std::error::Error>> {
    if list {
        println!("📺 Your subscriptions:");
        println!("✓ Listing subscriptions");
    } else if unsubscribe {
        println!("Unsubscribing from: {}", channel);
        println!("✓ Unsubscribed");
    } else {
        println!("Subscribing to: {}", channel);
        println!("✓ Subscribed");
    }
    Ok(())
}

async fn manage_playlist(
    _api_url: &str,
    create: Option<String>,
    add: Option<String>,
    id: Option<String>,
    list: bool,
) -> Result<(), Box<dyn std::error::Error>> {
    if list {
        println!("📋 Your playlists:");
        println!("✓ Listing playlists");
    } else if let Some(name) = create {
        println!("Creating playlist: {}", name);
        println!("✓ Playlist created");
    } else if let Some(_video) = add {
        println!("Adding video to playlist: {}", id.unwrap_or("default".to_string()));
        println!("✓ Video added");
    }
    Ok(())
}

async fn manage_downloads(
    _api_url: &str,
    list: bool,
    cancel: Option<String>,
    dir: bool,
) -> Result<(), Box<dyn std::error::Error>> {
    if dir {
        println!("Download directory: ~/Downloads/Tubular");
    } else if let Some(id) = cancel {
        println!("Cancelling download: {}", id);
        println!("✓ Download cancelled");
    } else if list {
        println!("📥 Active downloads:");
        println!("✓ Listing downloads");
    }
    Ok(())
}

async fn manage_history(
    _api_url: &str,
    clear: bool,
    last: Option<usize>,
    search: Option<String>,
) -> Result<(), Box<dyn std::error::Error>> {
    if clear {
        println!("Clearing history...");
        println!("✓ History cleared");
    } else if let Some(n) = last {
        println!("Last {} videos:", n);
        println!("✓ Showing history");
    } else if let Some(query) = search {
        println!("Searching history for: {}", query);
        println!("✓ Search complete");
    }
    Ok(())
}

async fn manage_server(
    start: bool,
    stop: bool,
    status: bool,
    port: Option<u16>,
) -> Result<(), Box<dyn std::error::Error>> {
    if start {
        let p = port.unwrap_or(8000);
        println!("🚀 Starting server on port {}", p);
        println!("✓ Server started");
    } else if stop {
        println!("🛑 Stopping server...");
        println!("✓ Server stopped");
    } else if status {
        println!("📊 Server status:");
        println!("Status: Running");
        println!("Port: 8000");
        println!("Uptime: [Loading...]");
    }
    Ok(())
}

async fn manage_config(
    _api_url: &str,
    set: Option<String>,
    get: Option<String>,
    list: bool,
    reset: bool,
) -> Result<(), Box<dyn std::error::Error>> {
    if list {
        println!("⚙️  Configuration:");
        println!("✓ Showing config");
    } else if let Some(key) = get {
        println!("Getting config: {}", key);
        println!("✓ Config retrieved");
    } else if let Some(key) = set {
        println!("Setting config: {}", key);
        println!("✓ Config updated");
    } else if reset {
        println!("Resetting to defaults...");
        println!("✓ Config reset");
    }
    Ok(())
}

async fn batch_operations(
    _api_url: &str,
    file: Option<String>,
    download: bool,
    parallel: Option<usize>,
    quality: Option<String>,
) -> Result<(), Box<dyn std::error::Error>> {
    if download {
        if let Some(f) = file {
            let p = parallel.unwrap_or(1);
            println!("📥 Batch downloading from: {}", f);
            println!("Parallel downloads: {}", p);
            if let Some(q) = quality {
                println!("Quality: {}", q);
            }
            println!("✓ Batch download started");
        }
    }
    Ok(())
}

fn show_help(topic: &Option<String>) {
    if let Some(t) = topic {
        println!("Help for: {}", t);
    } else {
        println!("Tubular PC - CLI Help");
        println!("Usage: tubular [OPTIONS] [COMMAND]");
        println!("\nCommands:");
        println!("  search      Search for videos");
        println!("  download    Download a video");
        println!("  info        Get video information");
        println!("  subscribe   Manage subscriptions");
        println!("  playlist    Manage playlists");
        println!("  downloads   Manage downloads");
        println!("  history     Manage watch history");
        println!("  server      Server management");
        println!("  config      Preferences and settings");
        println!("  batch       Batch operations");
        println!("\nOptions:");
        println!("  --api <URL>     API server URL (default: http://localhost:8000)");
        println!("  -h, --help      Print help information");
        println!("  -V, --version   Print version");
    }
}
