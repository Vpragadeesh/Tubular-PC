# Tubular PC 🎥

A desktop YouTube client inspired by Tubular/NewPipe - ad-free, privacy-focused video streaming for Linux, Windows, and macOS.

## Features ✨

- 🔍 **Search Videos** - Search YouTube without ads
- 🎬 **Stream Videos** - Watch videos using mpv player
- 📥 **Download Videos** - Download videos in multiple qualities
- 🎵 **Audio Only** - Extract audio from videos
- 📚 **Subscriptions** - Manage channel subscriptions locally
- 📜 **History** - Track your watch history
- 🔒 **Privacy First** - No Google account required, no tracking
- 🌙 **Dark Mode** - Easy on the eyes

## Architecture

```
Tubular-PC/
├── frontend/        Flutter Desktop UI
├── backend/         Rust API server
└── extractor/       yt-dlp wrapper
```

## Prerequisites

### Required

1. **yt-dlp** - Video extraction engine
   ```bash
   # Linux
   sudo apt install yt-dlp
   # or
   pip install yt-dlp
   
   # macOS
   brew install yt-dlp
   
   # Windows
   winget install yt-dlp
   ```

2. **mpv** - Video player
   ```bash
   # Linux
   sudo apt install mpv
   
   # macOS
   brew install mpv
   
   # Windows
   winget install mpv
   ```

3. **Rust** - Backend development
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```

4. **Flutter** - Frontend development
   ```bash
   # Follow instructions at: https://flutter.dev/docs/get-started/install
   ```

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/yourusername/tubular-pc.git
cd tubular-pc
```

### 2. Setup Backend

```bash
cd backend
cargo build --release
```

### 3. Setup Frontend

```bash
cd frontend
flutter pub get
flutter pub run build_runner build
```

## Running the Application

### Start Backend Server

```bash
cd backend
cargo run --release
```

The backend will start on `http://localhost:3030`

### Start Frontend

In a new terminal:

```bash
cd frontend
flutter run -d linux    # or windows, macos
```

## Usage

1. **Search**: Enter a search query in the search bar
2. **Play**: Click on a video to open the player
3. **Download**: Click the download button and select quality
4. **Subscribe**: Subscribe to channels to track new uploads

## Development Roadmap

### Phase 1 (MVP) ✅
- [x] Search + video list
- [x] Play video (mpv)
- [x] Basic UI
- [x] Backend API

### Phase 2 (In Progress)
- [ ] Downloads with progress tracking
- [ ] Subscriptions management
- [ ] History tracking
- [ ] Settings page

### Phase 3 (Planned)
- [ ] SponsorBlock integration
- [ ] Return YouTube Dislike API
- [ ] Background playback
- [ ] Playlists

### Phase 4 (Future)
- [ ] UI polish (exact Tubular feel)
- [ ] Animations
- [ ] Performance tuning
- [ ] Multi-platform packaging

## Project Structure

### Backend (Rust)

```
backend/src/
├── main.rs          # Server entry point
├── api.rs           # REST API endpoints
├── yt_dlp.rs        # yt-dlp wrapper
├── player.rs        # mpv player control
└── db.rs            # SQLite database
```

### Frontend (Flutter)

```
frontend/lib/
├── main.dart
├── screens/
│   ├── home_screen.dart
│   ├── player_screen.dart
│   ├── subscriptions_screen.dart
│   └── downloads_screen.dart
├── widgets/
│   ├── video_card.dart
│   └── player_controls.dart
├── services/
│   └── api_service.dart
└── models/
    └── video.dart
```

## API Endpoints

- `GET /search?q=query&limit=20` - Search videos
- `GET /video/:id` - Get video info
- `GET /stream/:id?quality=best` - Get stream URL
- `POST /download` - Download video
- `GET /subscriptions` - Get subscriptions
- `POST /subscriptions` - Add subscription
- `GET /history` - Get watch history
- `POST /history` - Add to history

## Building for Production

### Linux

```bash
cd frontend
flutter build linux --release
```

Package as AppImage or Flatpak.

### Windows

```bash
cd frontend
flutter build windows --release
```

Create installer with Inno Setup or NSIS.

### macOS

```bash
cd frontend
flutter build macos --release
```

Create DMG installer.

## Important Notes ⚠️

### Legal Considerations

- This project is for **personal use** and **educational purposes**
- Downloading copyrighted content may violate YouTube's Terms of Service
- Use responsibly and respect content creators

### Maintenance

- YouTube frequently changes their API, which may break yt-dlp
- Keep yt-dlp updated: `pip install -U yt-dlp`
- Sometimes cookies are required for extraction

### Known Issues

- Extraction may fail when YouTube updates
- Some videos may be geo-restricted
- Age-restricted content requires authentication

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License - See LICENSE file for details

## Acknowledgments

- [NewPipe](https://newpipe.net/) - Original inspiration
- [Tubular](https://github.com/polymorphicshade/Tubular) - Direct inspiration
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) - Video extraction
- [mpv](https://mpv.io/) - Video playback

## Support

For issues and questions:
- Open an issue on GitHub
- Check existing issues for solutions

---

**Note**: This is an independent project and is not affiliated with YouTube, Google, NewPipe, or Tubular.
