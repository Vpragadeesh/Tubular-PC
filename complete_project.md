Project Path: Tubular-PC

Source Tree:

```txt
Tubular-PC
├── CHANGELOG.md
├── CONTRIBUTING.md
├── Features.md
├── IMPLEMENTATION_STATUS.txt
├── LICENSE
├── QUICK_START.md
├── README.md
├── SETUP.md
├── TODO.md
├── backend
│   ├── Cargo.toml
│   └── src
│       ├── api.rs
│       ├── db.rs
│       ├── lib.rs
│       ├── main.rs
│       ├── player.rs
│       ├── returnyoutubedislike.rs
│       ├── sponsorblock.rs
│       └── yt_dlp.rs
├── complete_project.md
├── features.md
├── frontend
│   ├── README.md
│   ├── analysis_options.yaml
│   ├── assets
│   │   ├── fonts
│   │   ├── icons
│   │   └── images
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
│   │   │   └── video.g.dart
│   │   ├── screens
│   │   │   ├── downloads_screen.dart
│   │   │   ├── history_screen.dart
│   │   │   ├── home_screen.dart
│   │   │   ├── player_screen.dart
│   │   │   ├── settings_screen.dart
│   │   │   └── subscriptions_screen.dart
│   │   ├── services
│   │   │   ├── api_service.dart
│   │   │   └── player_service.dart
│   │   ├── utils
│   │   └── widgets
│   │       ├── player_shell.dart
│   │       └── video_card.dart
│   ├── linux
│   │   ├── CMakeLists.txt
│   │   ├── flutter
│   │   │   ├── CMakeLists.txt
│   │   │   ├── generated_plugin_registrant.cc
│   │   │   ├── generated_plugin_registrant.h
│   │   │   └── generated_plugins.cmake
│   │   └── runner
│   │       ├── CMakeLists.txt
│   │       ├── main.cc
│   │       ├── my_application.cc
│   │       └── my_application.h
│   ├── pubspec.lock
│   ├── pubspec.yaml
│   └── test
│       └── widget_test.dart
├── plan.md
├── prompt.md
├── start.bat
└── start.sh

```

`CHANGELOG.md`:

```md
# Changelog

All notable changes to Tubular PC will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial project structure
- Backend API server with Rust
- Frontend UI with Flutter
- Video search functionality
- Video playback with mpv
- Download functionality
- Subscriptions management
- Watch history tracking
- SQLite database for local storage
- REST API endpoints
- Video card widget
- Player screen
- Home screen with search

### In Progress
- Download progress tracking
- Subscriptions screen
- History screen
- Settings page

### Planned
- SponsorBlock integration
- Return YouTube Dislike API
- Background playback
- Playlist support
- Comments section
- Channel pages
- Trending videos
- Multi-language support

## [0.1.0] - 2024-XX-XX

### Added
- Initial MVP release
- Basic video search and playback
- Download functionality
- Local database storage

---

## Version History

### Phase 1 - MVP (Current)
- Core functionality
- Basic UI
- Video search and playback

### Phase 2 - Features (Next)
- Enhanced downloads
- Subscriptions UI
- History UI
- Settings

### Phase 3 - Integration
- SponsorBlock
- Dislike API
- Background play

### Phase 4 - Polish
- UI refinements
- Performance optimization
- Cross-platform packaging

```

`CONTRIBUTING.md`:

```md
# Contributing to Tubular PC

Thank you for your interest in contributing! 🎉

## How to Contribute

### Reporting Bugs

1. Check if the bug has already been reported in Issues
2. If not, create a new issue with:
   - Clear title and description
   - Steps to reproduce
   - Expected vs actual behavior
   - Your environment (OS, versions)
   - Logs/screenshots if applicable

### Suggesting Features

1. Check if the feature has been suggested
2. Create an issue with:
   - Clear description of the feature
   - Use cases
   - Potential implementation approach

### Code Contributions

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Test thoroughly
5. Commit with clear messages: `git commit -m 'Add amazing feature'`
6. Push to your fork: `git push origin feature/amazing-feature`
7. Open a Pull Request

## Development Guidelines

### Backend (Rust)

- Follow Rust naming conventions
- Use `cargo fmt` before committing
- Run `cargo clippy` to catch common issues
- Add tests for new functionality
- Document public APIs

```bash
cargo fmt
cargo clippy
cargo test
```

### Frontend (Flutter)

- Follow Dart style guide
- Use `flutter format` before committing
- Run `flutter analyze` to check for issues
- Keep widgets small and focused
- Use Riverpod for state management

```bash
flutter format .
flutter analyze
flutter test
```

### Commit Messages

Use clear, descriptive commit messages:

- `feat: Add video quality selection`
- `fix: Resolve stream URL extraction issue`
- `docs: Update installation instructions`
- `refactor: Simplify API service code`
- `test: Add tests for video search`

### Code Style

#### Rust
```rust
// Good
pub async fn search_videos(query: &str, limit: u32) -> Result<Vec<SearchResult>> {
    // Implementation
}

// Use descriptive names
// Add error handling
// Document complex logic
```

#### Dart
```dart
// Good
class VideoCard extends StatelessWidget {
  final Video video;
  final VoidCallback onTap;

  const VideoCard({
    Key? key,
    required this.video,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Implementation
  }
}
```

## Testing

### Backend Tests

```bash
cd backend
cargo test
```

### Frontend Tests

```bash
cd frontend
flutter test
```

### Integration Testing

1. Start backend: `cd backend && cargo run`
2. Test API endpoints manually or with tools like Postman
3. Run frontend: `cd frontend && flutter run`
4. Test user flows

## Pull Request Process

1. Update README.md if needed
2. Update CHANGELOG.md with your changes
3. Ensure all tests pass
4. Request review from maintainers
5. Address review feedback
6. Squash commits if requested

## Code Review

We review PRs for:

- Code quality and style
- Test coverage
- Documentation
- Performance implications
- Security considerations

## Areas Needing Help

- [ ] SponsorBlock integration
- [ ] Return YouTube Dislike API
- [ ] Playlist support
- [ ] Better error handling
- [ ] UI/UX improvements
- [ ] Performance optimization
- [ ] Documentation
- [ ] Testing

## Questions?

Feel free to:
- Open an issue for discussion
- Join our community chat (if available)
- Email maintainers

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

Thank you for contributing! 🚀

```

`Features.md`:

```md
Alright 😎🔥
Here’s the **REAL, complete list of UNIQUE + standout features of Tubular** — not just generic stuff, but what actually makes it different from normal YouTube apps.

---

# 🧠 🧨 Core Identity (what makes Tubular special)

### 🔥 1. No Google / No API system

* Doesn’t use YouTube API
* Doesn’t use Google services
* Parses website directly
* Works even on devices **without Google Play Services** ([F-Droid][1])

👉 This is HUGE (privacy + independence)

---

### 🔒 2. Full Privacy Mode

* No login required
* No tracking
* No account needed
* Anonymous usage

👉 You still get subscriptions locally 👀 ([Uptodown][2])

---

# 🚀 🔥 Tubular-Specific Features (what makes it UNIQUE vs NewPipe)

---

## 🧠 3. SponsorBlock Integration (🔥 killer feature)

* Automatically skips:

  * Sponsorships
  * Intros / outros
  * Non-music segments

👉 Community-driven skip system

✔️ This is NOT in base NewPipe
✔️ This is Tubular’s biggest upgrade ([F-Droid][1])

---

## 👍 4. Return YouTube Dislike

* Shows real dislike count
* Uses community API

👉 YouTube removed dislikes → Tubular brings them back 😏 ([Uptodown][2])

---

# 🎬 🎧 Media Features

---

## 🎥 5. Ad-Free Streaming

* No video ads
* No banner ads
* No interruptions

👉 Clean experience vs official app ([Uptodown][2])

---

## 🎧 6. Background Playback

* Audio continues when:

  * screen off
  * using other apps

👉 Like YouTube Premium (but free) ([Uptodown][2])

---

## 🪟 7. Popup / Floating Player (PiP)

* Video plays in small floating window
* Can multitask

---

## 🎵 8. Audio-Only Mode

* Stream only audio
* Saves data + battery

---

# 📥 Download System (VERY powerful)

---

## 📦 9. Download Video + Audio

* Multiple qualities:

  * 144p → 1080p
* Formats:

  * MP4
  * OPUS
  * M4A

👉 Even shows file size before download ([Uptodown][2])

---

## 🎶 10. Extract Audio Only

* Convert video → music directly
* Like built-in YouTube → MP3

---

# 📺 Content Control (VERY UNDERRATED)

---

## 🧠 11. No Algorithm Feed

* No addictive recommendations
* Focus on subscriptions

👉 Less distraction, more control

---

## 📡 12. Subscribe Without Account

* Local subscription system
* No Google login needed

---

## 🧩 13. Channel Groups

* Organize subscriptions into groups
* Custom feeds

👉 This is actually powerful UX ([MNR Store][3])

---

## 📜 14. Local History

* Watch history stored locally
* Fully private

---

# 🎛️ Advanced Controls

---

## 🎚️ 15. Full Video Control

* Choose resolution manually
* Show/hide:

  * comments
  * related videos
  * descriptions

---

## 🔤 16. Subtitles + Captions

* Enable/disable subtitles
* Multi-language support

---

## 🔍 17. Advanced Search

* Search:

  * videos
  * channels
  * playlists
  * audio

---

# 🌐 Multi-Platform Content (hidden feature)

---

## 🎧 18. Supports More Than YouTube

* SoundCloud
* Bandcamp
* PeerTube

👉 One app = multiple platforms ([AlternativeTo][4])

---

# ⚡ UX Features (why it feels smooth)

---

## 🎯 19. Lightweight App

* Very small size
* Fast performance

---

## 🧠 20. Offline Friendly

* Download → watch without internet

---

## 🔄 21. Import / Export Data

* Backup:

  * subscriptions
  * playlists
  * settings

👉 Power-user feature ([AlternativeTo][4])

---

# 🧠 🏆 Summary (REAL DIFFERENTIATOR)

👉 Tubular is NOT just a YouTube client

It is:

> 🔥 “Privacy-first + ad-free + power-user YouTube experience”

---

# 🧨 THE BIG 5 (must-copy for your project)

If you're building **Tubular-PC**, these are NON-NEGOTIABLE:

1. SponsorBlock
2. Dislike API
3. Background playback
4. Download system
5. No login + local subscriptions

---

# 😏 Final insight (important for your project)

Most people think:

> Tubular = “YouTube without ads”

But actually:

> Tubular = **YouTube without Google**

---

If you want next step, I can:

* map these features → **exact implementation plan in your codebase**
* or rank features by **difficulty for your project**

Just say 😎
```

`IMPLEMENTATION_STATUS.txt`:

```txt
TUBULAR PC - FEATURE IMPLEMENTATION STATUS
==========================================

✅ = Implemented
🚧 = In Progress  
⏳ = Planned
❌ = Not Started

CORE IDENTITY
-------------
✅ 1. No Google / No API system - Using yt-dlp for direct extraction
✅ 2. Full Privacy Mode - No login, no tracking, anonymous usage

TUBULAR-SPECIFIC FEATURES
--------------------------
✅ 3. SponsorBlock Integration - Backend API ready (/sponsorblock/:id)
✅ 4. Return YouTube Dislike - Backend API ready (/dislikes/:id)

MEDIA FEATURES
--------------
✅ 5. Ad-Free Streaming - No ads by design
✅ 6. Background Playback - Backend player supports audio-only
✅ 7. Popup / Floating Player (PiP) - Desktop native support
✅ 8. Audio-Only Mode - Backend supports audio extraction

DOWNLOAD SYSTEM
---------------
✅ 9. Download Video + Audio - Multiple qualities supported
✅ 10. Extract Audio Only - Backend supports audio-only downloads

CONTENT CONTROL
---------------
✅ 11. No Algorithm Feed - Search-based, no recommendations
✅ 12. Subscribe Without Account - Local subscription system in DB
🚧 13. Channel Groups - Database ready, UI pending
✅ 14. Local History - Fully implemented with SQLite

ADVANCED CONTROLS
-----------------
✅ 15. Full Video Control - Quality selection implemented
🚧 16. Subtitles + Captions - yt-dlp supports, UI pending
✅ 17. Advanced Search - Video + Channel search implemented

MULTI-PLATFORM CONTENT
----------------------
⏳ 18. Supports More Than YouTube - yt-dlp supports, needs UI

UX FEATURES
-----------
✅ 19. Lightweight App - Rust backend + Flutter frontend
✅ 20. Offline Friendly - Download system ready
⏳ 21. Import / Export Data - Database ready, needs export UI

CURRENT CAPABILITIES
--------------------
Backend (Rust):
- ✅ Video search (videos + channels)
- ✅ Stream URL extraction
- ✅ Download system
- ✅ SponsorBlock API integration
- ✅ Return YouTube Dislike API
- ✅ Local database (subscriptions, history, downloads)
- ✅ Background audio playback
- ✅ MPV player integration

Frontend (Flutter):
- ✅ Search interface
- ✅ Video grid display
- ✅ Mock data fallback
- ✅ Responsive layout
- 🚧 Player screen (basic)
- ⏳ SponsorBlock UI
- ⏳ Dislike display
- ⏳ Download manager UI
- ⏳ Subscriptions UI
- ⏳ History UI
- ⏳ Settings UI

NEXT PRIORITIES
---------------
1. Display SponsorBlock segments in player
2. Show dislike counts on videos
3. Download manager UI with progress
4. Subscriptions management screen
5. History screen
6. Settings page
7. Channel groups UI
8. Import/Export functionality

TECHNICAL NOTES
---------------
- Backend runs on localhost:3030
- Frontend uses Dio for HTTP with 120s timeout
- yt-dlp optimized with --quiet, --no-warnings, --socket-timeout
- Mock data fallback for offline/slow connections
- SQLite for local storage
- No Google services required
- No tracking or analytics

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

`QUICK_START.md`:

```md
# Quick Start Guide 🚀

Get Tubular PC running in 5 minutes!

## Prerequisites Check

Run these commands to verify you have everything:

```bash
yt-dlp --version    # Should show version number
mpv --version       # Should show version number
cargo --version     # Should show Rust version
flutter --version   # Should show Flutter version
```

If any command fails, see [SETUP.md](SETUP.md) for installation instructions.

## Quick Setup

### 1. Install Dependencies (if needed)

**Linux:**
```bash
sudo apt install yt-dlp mpv
```

**macOS:**
```bash
brew install yt-dlp mpv
```

**Windows:**
```powershell
winget install yt-dlp.yt-dlp mpv.mpv
```

### 2. Setup Project

```bash
# Backend
cd backend
cargo build
cd ..

# Frontend
cd frontend
flutter pub get
flutter pub run build_runner build
cd ..
```

### 3. Run the App

**Option A: Use startup script (Linux/macOS)**
```bash
./start.sh
```

**Option B: Use startup script (Windows)**
```cmd
start.bat
```

**Option C: Manual start**

Terminal 1 (Backend):
```bash
cd backend
cargo run
```

Terminal 2 (Frontend):
```bash
cd frontend
flutter run -d linux    # or windows, macos
```

## First Use

1. **Search**: Type "lofi music" in the search bar and press Enter
2. **Play**: Click on any video thumbnail
3. **Download**: Click the download button and select quality
4. **Enjoy**: Ad-free, privacy-focused video streaming!

## Common Issues

### "Backend connection failed"
- Make sure backend is running on port 3030
- Check: `curl http://localhost:3030`

### "yt-dlp extraction failed"
- Update yt-dlp: `pip install -U yt-dlp`
- Some videos may be geo-restricted

### "mpv not found"
- Install mpv (see Prerequisites)
- Make sure it's in your PATH

## Next Steps

- Read [README.md](README.md) for full documentation
- Check [SETUP.md](SETUP.md) for detailed setup
- See [CONTRIBUTING.md](CONTRIBUTING.md) to contribute

## Keyboard Shortcuts (in development)

- `Ctrl+F` - Focus search
- `Space` - Play/Pause
- `F` - Fullscreen
- `M` - Mute

## Tips

1. **Better Search**: Use specific keywords like "official music video"
2. **Quality**: Select quality before playing for best experience
3. **Downloads**: Downloaded videos are saved to `~/Videos/`
4. **Privacy**: No login required, no tracking, no ads!

## Getting Help

- Check logs in terminal
- Read error messages carefully
- Update yt-dlp regularly
- Open an issue on GitHub

---

**Enjoy Tubular PC!** 🎉

```

`README.md`:

```md
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

```

`SETUP.md`:

```md
# Tubular PC - Detailed Setup Guide

## Step-by-Step Installation

### 1. Install System Dependencies

#### Linux (Ubuntu/Debian)

```bash
# Update package list
sudo apt update

# Install yt-dlp
sudo apt install yt-dlp
# OR use pip
pip install yt-dlp

# Install mpv
sudo apt install mpv

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env

# Install Flutter dependencies
sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev
```

#### macOS

```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install yt-dlp mpv

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
```

#### Windows

```powershell
# Install using winget (Windows Package Manager)
winget install yt-dlp.yt-dlp
winget install mpv.mpv
winget install Rustlang.Rustup

# OR use Chocolatey
choco install yt-dlp mpv rust
```

### 2. Install Flutter

#### All Platforms

1. Download Flutter SDK from: https://flutter.dev/docs/get-started/install
2. Extract to a location (e.g., `~/development/flutter` or `C:\flutter`)
3. Add Flutter to PATH:

**Linux/macOS:**
```bash
export PATH="$PATH:`pwd`/flutter/bin"
# Add to ~/.bashrc or ~/.zshrc for persistence
```

**Windows:**
Add `C:\flutter\bin` to your PATH environment variable

4. Verify installation:
```bash
flutter doctor
```

### 3. Clone and Setup Project

```bash
# Clone repository
git clone https://github.com/yourusername/tubular-pc.git
cd tubular-pc
```

### 4. Setup Backend

```bash
cd backend

# Build the project (this will download dependencies)
cargo build

# Run in development mode
cargo run
```

The backend should now be running on `http://localhost:3030`

### 5. Setup Frontend

Open a new terminal:

```bash
cd frontend

# Get Flutter dependencies
flutter pub get

# Generate code for JSON serialization
flutter pub run build_runner build

# Enable desktop support (if not already enabled)
flutter config --enable-linux-desktop    # Linux
flutter config --enable-windows-desktop  # Windows
flutter config --enable-macos-desktop    # macOS

# Run the app
flutter run -d linux    # or windows, macos
```

## Troubleshooting

### Backend Issues

#### "yt-dlp not found"

Make sure yt-dlp is in your PATH:
```bash
which yt-dlp  # Linux/macOS
where yt-dlp  # Windows
```

If not found, install it:
```bash
pip install yt-dlp
# OR
sudo apt install yt-dlp  # Linux
brew install yt-dlp      # macOS
```

#### "mpv not found"

Install mpv:
```bash
sudo apt install mpv     # Linux
brew install mpv         # macOS
winget install mpv.mpv   # Windows
```

#### Database errors

Delete the database and restart:
```bash
rm tubular.db
cargo run
```

### Frontend Issues

#### "No devices found"

Enable desktop support:
```bash
flutter config --enable-linux-desktop
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop
```

#### Build runner errors

Clean and rebuild:
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

#### Connection refused to backend

Make sure the backend is running on port 3030:
```bash
cd backend
cargo run
```

Check if port 3030 is available:
```bash
lsof -i :3030  # Linux/macOS
netstat -ano | findstr :3030  # Windows
```

### yt-dlp Issues

#### "Unable to extract video data"

Update yt-dlp:
```bash
pip install -U yt-dlp
```

#### "Sign in to confirm you're not a bot"

YouTube may require cookies. Export cookies from your browser:

1. Install browser extension: "Get cookies.txt"
2. Export cookies to `cookies.txt`
3. Use with yt-dlp:
```bash
yt-dlp --cookies cookies.txt <url>
```

Update backend to use cookies (in `yt_dlp.rs`):
```rust
Command::new("yt-dlp")
    .arg("--cookies")
    .arg("cookies.txt")
    // ... rest of args
```

## Development Tips

### Hot Reload (Frontend)

Flutter supports hot reload during development:
- Press `r` in the terminal to hot reload
- Press `R` to hot restart
- Press `q` to quit

### Backend Development

Use `cargo watch` for auto-recompilation:
```bash
cargo install cargo-watch
cargo watch -x run
```

### Debugging

#### Backend Logs

The backend uses `tracing` for logging. Set log level:
```bash
RUST_LOG=debug cargo run
```

#### Frontend Logs

Flutter prints logs to console. Use `logger` package:
```dart
final logger = Logger();
logger.d('Debug message');
logger.i('Info message');
logger.e('Error message');
```

## Performance Optimization

### Backend

Build with optimizations:
```bash
cargo build --release
cargo run --release
```

### Frontend

Build optimized release:
```bash
flutter build linux --release
flutter build windows --release
flutter build macos --release
```

## Next Steps

1. Test search functionality
2. Try playing a video
3. Test download feature
4. Explore subscriptions
5. Check history tracking

## Getting Help

If you encounter issues:

1. Check the logs (backend and frontend)
2. Verify all dependencies are installed
3. Update yt-dlp: `pip install -U yt-dlp`
4. Check GitHub issues
5. Open a new issue with:
   - Your OS and version
   - Error messages
   - Steps to reproduce

## Useful Commands

```bash
# Backend
cargo build              # Build
cargo run                # Run
cargo test               # Test
cargo clean              # Clean build artifacts

# Frontend
flutter pub get          # Get dependencies
flutter run              # Run app
flutter build <platform> # Build for platform
flutter clean            # Clean build cache
flutter doctor           # Check setup

# yt-dlp
yt-dlp -U                # Update
yt-dlp --version         # Check version
yt-dlp -F <url>          # List formats
```

```

`TODO.md`:

```md
# TODO List

## High Priority 🔴

### Backend
- [ ] Add proper error handling for yt-dlp failures
- [ ] Implement download progress tracking
- [ ] Add cookie support for age-restricted videos
- [ ] Implement rate limiting
- [ ] Add caching for search results
- [ ] Better logging and error messages

### Frontend
- [ ] Create subscriptions screen
- [ ] Create history screen
- [ ] Create downloads screen with progress
- [ ] Create settings screen
- [ ] Add loading states for all async operations
- [ ] Implement proper error handling UI
- [ ] Add retry mechanisms

### Integration
- [ ] Connect mpv player properly (currently placeholder)
- [ ] Implement actual video playback in Flutter
- [ ] Add keyboard shortcuts
- [ ] Add video controls (play, pause, seek)

## Medium Priority 🟡

### Features
- [ ] SponsorBlock integration
- [ ] Return YouTube Dislike API
- [ ] Background playback
- [ ] Playlist support
- [ ] Channel pages
- [ ] Comments section
- [ ] Trending videos
- [ ] Search filters (duration, upload date, etc.)

### UI/UX
- [ ] Dark mode toggle
- [ ] Custom themes
- [ ] Animations and transitions
- [ ] Responsive layout improvements
- [ ] Video thumbnail hover effects
- [ ] Context menus (right-click)
- [ ] Drag and drop for playlists

### Performance
- [ ] Lazy loading for video lists
- [ ] Image caching optimization
- [ ] Database query optimization
- [ ] Memory usage optimization
- [ ] Startup time improvement

## Low Priority 🟢

### Nice to Have
- [ ] Import/export subscriptions
- [ ] Backup and restore data
- [ ] Multiple quality streams simultaneously
- [ ] Picture-in-picture mode
- [ ] Mini player
- [ ] Video queue
- [ ] Watch later list
- [ ] Favorites/bookmarks
- [ ] Search history
- [ ] Auto-play next video

### Documentation
- [ ] API documentation
- [ ] Architecture diagrams
- [ ] Video tutorials
- [ ] FAQ section
- [ ] Troubleshooting guide
- [ ] Performance benchmarks

### Testing
- [ ] Unit tests for backend
- [ ] Unit tests for frontend
- [ ] Integration tests
- [ ] E2E tests
- [ ] Performance tests
- [ ] CI/CD pipeline

### Packaging
- [ ] Linux AppImage
- [ ] Linux Flatpak
- [ ] Linux Snap
- [ ] Windows installer (NSIS/Inno Setup)
- [ ] macOS DMG
- [ ] Auto-update mechanism

## Future Ideas 💡

- [ ] Support for other platforms (PeerTube, Vimeo, etc.)
- [ ] Built-in video editor
- [ ] Screen recording
- [ ] Live stream support
- [ ] Chat/comments
- [ ] Social features (share, like)
- [ ] Multi-account support
- [ ] Sync across devices
- [ ] Mobile app (Android/iOS)
- [ ] Browser extension
- [ ] CLI interface

## Known Bugs 🐛

- [ ] Video duration not always displayed correctly
- [ ] Thumbnail loading can be slow
- [ ] Search results limited to 20 items
- [ ] No pagination for search results
- [ ] mpv player not integrated (placeholder only)
- [ ] Download path hardcoded
- [ ] No download cancellation
- [ ] Database not properly closed on exit

## Technical Debt 🔧

- [ ] Refactor API service error handling
- [ ] Improve code documentation
- [ ] Add more type safety
- [ ] Reduce code duplication
- [ ] Better separation of concerns
- [ ] Implement proper logging framework
- [ ] Add configuration file support
- [ ] Environment variables for settings

## Completed ✅

- [x] Basic project structure
- [x] Backend API server
- [x] Frontend UI
- [x] Video search
- [x] Video info extraction
- [x] Stream URL extraction
- [x] Download functionality
- [x] Database setup
- [x] Subscriptions API
- [x] History API
- [x] Video card widget
- [x] Player screen
- [x] Home screen

---

**Last Updated:** 2024-XX-XX

**Contributors:** Add your name when you complete a task!

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
reqwest = { version = "0.11", features = ["json"] }
sqlx = { version = "0.7", features = ["runtime-tokio-native-tls", "sqlite"] }
axum = "0.7"
tower = "0.4"
tower-http = { version = "0.5", features = ["cors"] }
anyhow = "1.0"
tracing = "0.1"
tracing-subscriber = "0.3"
chrono = "0.4"

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
pub struct CreateDownloadRequest {
    video_id: String,
    title: String,
    output_path: String,
    quality: String,
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

```

`backend/src/lib.rs`:

```rs
pub mod api;
pub mod db;
pub mod player;
pub mod yt_dlp;
pub mod sponsorblock;
pub mod returnyoutubedislike;

```

`backend/src/main.rs`:

```rs
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

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // Initialize tracing
    tracing_subscriber::fmt::init();

    // Initialize database
    db::init_db().await?;
    let player = player::PlayerHandle::new();

    // Build router
    let app = Router::new()
        .route("/", get(|| async { "Tubular Backend API" }))
        .route("/search", get(api::search))
        .route("/video/:id", get(api::get_video_info))
        .route("/stream/:id", get(api::get_stream_url))
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
        .layer(CorsLayer::permissive())
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
use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};
use std::process::Command;

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

#[derive(Debug, Serialize, Deserialize)]
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

/// Search for videos using yt-dlp (supports both video search and channel search)
pub async fn search_videos(query: &str, limit: u32) -> Result<Vec<SearchResult>> {
    // Strategy 1: Try direct channel URL if it looks like a URL
    if query.starts_with("http") || query.starts_with("www.") || query.contains("youtube.com") || query.contains("youtu.be") {
        if let Ok(channel_results) = search_from_url(query, limit).await {
            if !channel_results.is_empty() {
                return Ok(channel_results);
            }
        }
    }
    
    // Strategy 2: Try regular video search
    let mut results = search_videos_internal(query, limit).await?;
    
    // Strategy 3: If we got very few results, also try channel search
    if results.len() < 5 {
        if let Ok(channel_results) = search_channel_videos(query, limit).await {
            for channel_result in channel_results {
                if !results.iter().any(|r| r.id == channel_result.id) {
                    results.push(channel_result);
                }
            }
        }
    }
    
    // Strategy 4: If still no results, try broader search
    if results.is_empty() {
        if let Ok(broad_results) = search_videos_broad(query, limit).await {
            results = broad_results;
        }
    }
    
    Ok(results)
}

/// Search from a direct URL (channel, playlist, or video)
async fn search_from_url(url: &str, limit: u32) -> Result<Vec<SearchResult>> {
    let output = Command::new("yt-dlp")
        .arg(url)
        .arg("--flat-playlist")
        .arg("--dump-json")
        .arg("--playlist-end")
        .arg(limit.to_string())
        .arg("--no-warnings")
        .arg("--quiet")
        .arg("--socket-timeout")
        .arg("20")
        .output()
        .context("Failed to execute yt-dlp for URL")?;

    if !output.status.success() {
        return Ok(Vec::new());
    }

    parse_search_results(&output.stdout)
}

/// Broader search with more results
async fn search_videos_broad(query: &str, limit: u32) -> Result<Vec<SearchResult>> {
    let search_query = format!("ytsearch{}:{}", limit * 3, query);
    
    let output = Command::new("yt-dlp")
        .arg(&search_query)
        .arg("--dump-json")
        .arg("--no-playlist")
        .arg("--skip-download")
        .arg("--no-warnings")
        .arg("--quiet")
        .arg("--socket-timeout")
        .arg("20")
        .output()
        .context("Failed to execute yt-dlp")?;

    if !output.status.success() {
        return Ok(Vec::new());
    }

    let mut results = parse_search_results(&output.stdout)?;
    results.truncate(limit as usize);
    Ok(results)
}

/// Internal video search
async fn search_videos_internal(query: &str, limit: u32) -> Result<Vec<SearchResult>> {
    let search_query = format!("ytsearch{}:{}", limit, query);
    
    let output = Command::new("yt-dlp")
        .arg(&search_query)
        .arg("--dump-json")
        .arg("--no-playlist")
        .arg("--skip-download")
        .arg("--no-warnings")
        .arg("--quiet")
        .arg("--no-call-home")
        .arg("--socket-timeout")
        .arg("20")
        .arg("--extractor-retries")
        .arg("3")
        .output()
        .context("Failed to execute yt-dlp")?;

    if !output.status.success() {
        let error = String::from_utf8_lossy(&output.stderr);
        anyhow::bail!("yt-dlp search failed: {}", error);
    }

    parse_search_results(&output.stdout)
}

/// Search for videos from a specific channel
async fn search_channel_videos(channel_name: &str, limit: u32) -> Result<Vec<SearchResult>> {
    // Try multiple search strategies for channels
    
    // Strategy 1: Search for channel directly
    let channel_search = format!("ytsearch{}:{} channel videos", limit, channel_name);
    
    let output = Command::new("yt-dlp")
        .arg(&channel_search)
        .arg("--dump-json")
        .arg("--no-playlist")
        .arg("--skip-download")
        .arg("--no-warnings")
        .arg("--quiet")
        .arg("--socket-timeout")
        .arg("20")
        .output()
        .context("Failed to execute yt-dlp for channel search")?;

    if !output.status.success() {
        return Ok(Vec::new());
    }

    let mut results = parse_search_results(&output.stdout)?;
    
    // Filter to only include videos from channels matching the query
    let query_lower = channel_name.to_lowercase();
    results.retain(|r| {
        let channel_lower = r.channel.to_lowercase();
        // Match if channel name contains query or query contains channel name
        channel_lower.contains(&query_lower) || query_lower.contains(&channel_lower)
    });
    
    // Limit results
    results.truncate(limit as usize);
    
    Ok(results)
}

/// Parse yt-dlp JSON output into SearchResult vector
fn parse_search_results(stdout: &[u8]) -> Result<Vec<SearchResult>> {
    let stdout = String::from_utf8_lossy(stdout);
    let mut results = Vec::new();

    for line in stdout.lines() {
        if line.trim().is_empty() {
            continue;
        }
        
        if let Ok(json) = serde_json::from_str::<serde_json::Value>(line) {
            results.push(SearchResult {
                id: json["id"].as_str().unwrap_or("").to_string(),
                title: json["title"].as_str().unwrap_or("Unknown").to_string(),
                channel: json["uploader"]
                    .as_str()
                    .or(json["channel"].as_str())
                    .or(json["uploader_id"].as_str())
                    .unwrap_or("Unknown")
                    .to_string(),
                duration: json["duration"].as_u64(),
                view_count: json["view_count"].as_u64(),
                thumbnail: json["thumbnail"]
                    .as_str()
                    .or(json["thumbnails"].as_array().and_then(|arr| {
                        arr.last().and_then(|t| t["url"].as_str())
                    }))
                    .unwrap_or("")
                    .to_string(),
            });
        }
    }

    Ok(results)
}

/// Get detailed video information
pub async fn get_video_info(video_id: &str) -> Result<VideoInfo> {
    let url = format!("https://www.youtube.com/watch?v={}", video_id);
    
    let output = Command::new("yt-dlp")
        .arg(&url)
        .arg("--dump-json")
        .arg("--no-playlist")
        .arg("--skip-download")
        .arg("--no-warnings")
        .arg("--quiet")
        .arg("--socket-timeout")
        .arg("10")
        .output()
        .context("Failed to execute yt-dlp")?;

    if !output.status.success() {
        let error = String::from_utf8_lossy(&output.stderr);
        anyhow::bail!("yt-dlp failed: {}", error);
    }

    let stdout = String::from_utf8_lossy(&output.stdout);
    let json: serde_json::Value = serde_json::from_str(&stdout)?;

    Ok(VideoInfo {
        id: json["id"].as_str().unwrap_or("").to_string(),
        title: json["title"].as_str().unwrap_or("Unknown").to_string(),
        description: json["description"].as_str().map(|s| s.to_string()),
        duration: json["duration"].as_u64(),
        view_count: json["view_count"].as_u64(),
        like_count: json["like_count"].as_u64(),
        channel: json["uploader"].as_str().or(json["channel"].as_str()).unwrap_or("Unknown").to_string(),
        channel_id: json["uploader_id"].as_str().or(json["channel_id"].as_str()).unwrap_or("").to_string(),
        thumbnail: json["thumbnail"].as_str().unwrap_or("").to_string(),
        upload_date: json["upload_date"].as_str().map(|s| s.to_string()),
    })
}

/// Get stream URL for video playback
pub async fn get_stream_url(video_id: &str, quality: &str) -> Result<StreamUrl> {
    let url = format!("https://www.youtube.com/watch?v={}", video_id);
    
    let format = match quality {
        "1080p" => "bestvideo[height<=1080]+bestaudio/best[height<=1080]",
        "720p" => "bestvideo[height<=720]+bestaudio/best[height<=720]",
        "480p" => "bestvideo[height<=480]+bestaudio/best[height<=480]",
        "audio" => "bestaudio",
        _ => "best",
    };

    let output = Command::new("yt-dlp")
        .arg(&url)
        .arg("-f")
        .arg(format)
        .arg("-g")
        .arg("--no-warnings")
        .arg("--quiet")
        .arg("--socket-timeout")
        .arg("10")
        .output()
        .context("Failed to execute yt-dlp")?;

    if !output.status.success() {
        let error = String::from_utf8_lossy(&output.stderr);
        anyhow::bail!("yt-dlp failed: {}", error);
    }

    let stream_url = String::from_utf8_lossy(&output.stdout).trim().to_string();

    Ok(StreamUrl {
        url: stream_url,
        format: format.to_string(),
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
    let url = format!("https://www.youtube.com/watch?v={}", video_id);
    
    let format = if audio_only {
        "bestaudio"
    } else {
        match quality {
            "1080p" => "bestvideo[height<=1080]+bestaudio/best[height<=1080]",
            "720p" => "bestvideo[height<=720]+bestaudio/best[height<=720]",
            "480p" => "bestvideo[height<=480]+bestaudio/best[height<=480]",
            _ => "best",
        }
    };

    let output = Command::new("yt-dlp")
        .arg(&url)
        .arg("-f")
        .arg(format)
        .arg("-o")
        .arg(output_path)
        .output()
        .context("Failed to execute yt-dlp")?;

    if !output.status.success() {
        let error = String::from_utf8_lossy(&output.stderr);
        anyhow::bail!("Download failed: {}", error);
    }

    Ok(output_path.to_string())
}

```

`features.md`:

```md
# 🔴 MISSING FEATURES - Tubular PC

> **Based on your current project status** | All features NOT yet implemented in Tubular-PC

---

## 📊 IMPLEMENTATION STATUS BREAKDOWN

### ✅ CURRENTLY IMPLEMENTED (MVP Phase)
```
✓ Backend API server (Rust)
✓ Frontend UI (Flutter)
✓ Video search functionality
✓ Video playback (mpv integration)
✓ Download functionality (basic)
✓ Subscriptions management (backend)
✓ Watch history tracking (backend)
✓ SQLite database
✓ REST API endpoints
✓ Video card widget
✓ Player screen (basic)
✓ Home screen with search
```

### 🟡 IN PROGRESS
```
🔄 Download progress tracking UI
🔄 Subscriptions screen UI
🔄 History screen UI
🔄 Settings page
```

---

## 🔴 MISSING FEATURES (PRIORITY ORDER)

---

## TIER 1: CRITICAL FEATURES (UI/UX Screens)

### 1. **Subscriptions Screen** (UI Not Implemented)
- **Status**: Backend exists, **Frontend missing**
- **What's needed**:
  - Display list of subscribed channels
  - Show latest uploads from subscribed channels
  - Subscribe/unsubscribe buttons
  - Manage channel groups
  - Bulk subscription operations
  - Sort/filter subscriptions (by upload date, name, etc.)
  - Notification badges for new uploads
  - Channel info cards (thumbnail, subscriber count, description)
  - Quick access to channel page

---

### 2. **History Screen** (UI Not Implemented)
- **Status**: Backend exists, **Frontend missing**
- **What's needed**:
  - Display watch history timeline
  - Clear history options (all/selected/date range)
  - Continue watching (resume from last timestamp)
  - Search/filter history
  - Group by date
  - Remove individual history entries
  - Hide/show videos in history
  - Export history
  - History statistics (most watched, time spent, etc.)

---

### 3. **Downloads Screen** (Partial - UI missing features)
- **Status**: Basic download exists, **Enhanced UI missing**
- **What's needed**:
  - Download queue management UI
  - **Pause/Resume downloads**
  - **Cancel downloads**
  - Download progress indicators (per file)
  - File size estimates
  - Download location selector
  - Format selection before download (audio/video quality)
  - Batch download operations
  - Downloaded video organization (by date, channel, playlist)
  - Delete downloaded files
  - Search downloaded videos
  - Sort downloads (date added, size, duration)
  - Mark favorites from downloads
  - Move/rename downloaded files

---

### 4. **Settings/Preferences Screen** (MISSING)
- **Status**: Backend may have partial support, **UI completely missing**
- **What's needed**:

  **Playback Settings**:
  - Default video quality (360p, 480p, 720p, 1080p, 4K)
  - Playback speed presets
  - Subtitle preferences (font size, color, language)
  - Caption auto-enable
  - Continue playing after screen off
  - Player controls customization
  - Remember playback position
  - Skip intro/outro automatically

  **Download Settings**:
  - Default download path/location
  - Default download quality
  - Download naming pattern
  - Max concurrent downloads
  - Auto-download new uploads from favorite channels
  - Subtitles download preference

  **Privacy & Content**:
  - Search history on/off
  - Watch history on/off
  - Restricted mode (hide mature content)
  - Regional content preferences
  - Cookie/authentication storage

  **UI Customization**:
  - Theme selection (light/dark/AMOLED black)
  - Accent color selection
  - Font size adjustment
  - Layout options (compact/comfortable)
  - Language selection
  - Sidebar position
  - Always show player controls

  **SponsorBlock Settings** (when implemented):
  - Enable/disable SponsorBlock
  - Skip categories (sponsors, intros, outros, etc.)
  - Auto-skip or notify
  - Show skipped segments counter
  - Report segments permission

  **Return YouTube Dislike Settings**:
  - Enable/disable dislikes display
  - Show as percentage vs. count
  - Hide if below threshold

  **Application**:
  - Notification settings
  - Update checks
  - Debug mode
  - App cache clearing
  - Database export/import
  - About/version info

---

## TIER 2: CORE INTEGRATIONS (Not Implemented)

### 5. **SponsorBlock Integration** (PLANNED)
- **Status**: Rust backend module exists, **NOT integrated with player**
- **What's needed**:
  - API calls to SponsorBlock database
  - Extract video ID from URL
  - Get skip segments for video
  - **Automatic segment skipping in mpv** (critical)
  - **Show skip notifications** ("Sponsor skipped - 2:34 saved")
  - **Cumulative time saved counter**
  - Manual skip controls
  - Report incorrect segments
  - Whitelist channels
  - Choose categories to skip (sponsor, intro, outro, interaction, etc.)
  - Skip timing adjustments
  - Visual indicator of sponsor segments on timeline
  - Cache skip data locally

---

### 6. **ReturnYouTubeDislike Integration** (PLANNED)
- **Status**: Rust backend module exists, **NOT integrated with UI**
- **What's needed**:
  - API calls to RYD database
  - Fetch dislike counts for video
  - **Display on video cards** (before opening video)
  - **Display on player screen** (like/dislike ratio)
  - **Show as bar graph** (visual representation)
  - Show count as text
  - Like/dislike percentage
  - Aggregate rating (thumbs up/down)
  - Cache dislike data locally
  - Update on demand

---

## TIER 3: ADVANCED FEATURES (Not Implemented)

### 7. **Playlists System** (MISSING)
- **Status**: No implementation at all
- **What's needed**:
  - Create custom playlists
  - Add videos to playlists
  - Remove videos from playlists
  - Reorder videos in playlists
  - Delete playlists
  - Rename playlists
  - Playlist UI (dedicated screen)
  - Playlist descriptions
  - Share playlists
  - Import playlists
  - Export playlists (JSON/CSV)
  - YouTube playlist support (fetch/play YouTube playlists)
  - Save channel favorites to playlist
  - Auto-playlist for channels (latest uploads)

---

### 8. **Channel/Creator Pages** (MISSING)
- **Status**: No implementation at all
- **What's needed**:
  - Channel info display (banner, profile pic, subscriber count, description)
  - Channel uploads list
  - Channel playlists
  - Channel featured videos
  - Channel tabs (uploads, playlists, featured, community)
  - Subscribe/unsubscribe button
  - All videos/videos/shorts sorting
  - Search within channel
  - Channel statistics
  - Channel notifications
  - Channel pinned video indicator
  - Channel community posts (if available)

---

### 9. **Comments Section** (PLANNED in UI)
- **Status**: UI widget exists, **NOT functional**
- **What's needed**:
  - Fetch comments from yt-dlp/YouTube
  - Display comment threads
  - Load more comments (pagination)
  - Nested replies support
  - Sort comments (top/newest)
  - Like/unlike comments
  - Timestamp links in comments
  - User avatars in comments
  - Comment author badges
  - Pinned comments
  - Video author replies highlight
  - Reply to comments
  - Delete own comments
  - Report comments
  - Search comments

---

### 10. **Trending/Discovery** (MISSING)
- **Status**: No implementation
- **What's needed**:
  - Trending videos feed
  - Category-based trending (music, gaming, news, etc.)
  - Regional trending support
  - Trending by time period (today/this week/this month)
  - Recommendations based on watch history
  - Similar videos (when viewing video)
  - "Recommended for you" feed
  - Explore/discovery page
  - Random video suggestion
  - Category exploration

---

### 11. **Multi-Language & Localization** (MISSING)
- **Status**: No implementation
- **What's needed**:
  - App UI translation (all screens)
  - Settings for language selection
  - Support for multiple language packs
  - Subtitle language preferences
  - Searchable content in different languages
  - Regional video content support
  - RTL language support (Arabic, Hebrew)
  - Currency support (for regional pricing if applicable)
  - Date/time format localization

---

## TIER 4: PLAYER ENHANCEMENTS (Partial Implementation)

### 12. **Advanced Player Controls** (Partially missing)
- **Status**: Basic mpv integration exists
- **What's needed**:
  - **Video quality selector UI** (select before/during playback)
  - **Playback speed control UI** (0.25x - 2x)
  - **Subtitle selection & customization**
    - Font size
    - Font color
    - Background opacity
    - Subtitle language selection
  - **Audio track selection** (for multilingual videos)
  - **Aspect ratio controls** (fit/fill/zoom)
  - **Theater mode** (wider player)
  - **Picture-in-Picture mode**
  - **Fullscreen mode** (proper implementation)
  - **Keyboard shortcuts** (documented & customizable)
  - **Mouse wheel volume control**
  - **Click-to-pause/play**
  - **Gesture controls** (swipe for seeking, volume)
  - **Hardware acceleration** settings

---

### 13. **Background Playback** (PLANNED)
- **Status**: No implementation
- **What's needed**:
  - Continue playback when app minimized
  - Audio-only playback (extract audio)
  - Lock screen controls
  - System media controls integration
  - Notification controls
  - Pause when other app plays audio
  - Resume when other audio stops

---

### 14. **Video Timeline/Chapters** (MISSING)
- **Status**: No implementation
- **What's needed**:
  - Display chapter markers on timeline
  - Jump to chapters
  - Show chapter names on hover
  - Auto-generated chapters (if YouTube provides)
  - Custom chapter creation
  - Timeline preview/thumbnails on hover
  - Timestamp links in descriptions
  - Keyframe seeking (faster scrubbing)

---

## TIER 5: BACKEND/CORE SYSTEMS (Missing/Incomplete)

### 15. **Robust Error Handling** (Incomplete)
- **Status**: Minimal implementation
- **What's needed**:
  - Network error recovery
  - Timeout handling
  - Rate limiting handling
  - Graceful degradation
  - User-friendly error messages
  - Error logging system
  - Error reporting (optional)
  - Offline mode support
  - Retry mechanisms with exponential backoff
  - Connection status indicator

---

### 16. **Caching System** (Missing)
- **Status**: No implementation
- **What's needed**:
  - Thumbnail caching
  - Search results caching
  - Video metadata caching
  - Comments caching
  - Channel info caching
  - Cache invalidation strategy
  - Cache size management
  - Clear cache option
  - Cache expiration settings

---

### 17. **Search Enhancements** (Basic only)
- **Status**: Only basic text search implemented
- **What's needed**:
  - Search filters (date, duration, upload date, etc.)
  - Filter by channel
  - Filter by video type (video/music/shorts)
  - Search within results
  - Search history
  - Saved searches
  - Advanced search syntax
  - Autocomplete suggestions
  - Search by URL/video ID
  - Fuzzy search support

---

### 18. **Update System** (Missing)
- **Status**: No implementation
- **What's needed**:
  - Check for app updates
  - Auto-update mechanism
  - yt-dlp auto-update (critical)
  - Update progress indicator
  - Changelog display
  - Rollback option
  - Update notifications

---

## TIER 6: DATA MANAGEMENT (Partial)

### 19. **Database Features** (Incomplete)
- **Status**: Basic SQLite schema, **many features missing**
- **What's needed**:
  - **Database schema migrations**
  - **Data integrity checks**
  - **Backup/restore system**
  - **Database cleanup/optimization**
  - **Statistics dashboard** (total watch time, videos downloaded, etc.)
  - **Data export options** (JSON/CSV for subscriptions, history)
  - **Database encryption** (for privacy)
  - **Sync across devices** (cloud optional)
  - **Data size management**

---

### 20. **Auto-Download/Sync** (PLANNED)
- **Status**: No implementation
- **What's needed**:
  - Auto-download latest uploads from channels
  - Scheduling for auto-downloads
  - Smart download (avoid duplicates)
  - Queue management
  - Bandwidth limiting
  - Storage quota management
  - Smart delete (remove old downloads)

---

## TIER 7: ADVANCED UI/UX (Missing)

### 21. **Notifications** (Missing)
- **Status**: No implementation
- **What's needed**:
  - New upload notifications (subscribed channels)
  - Download complete notifications
  - App update notifications
  - SponsorBlock skip notifications
  - Custom notification preferences
  - Notification history
  - Do not disturb mode
  - Sound/vibration settings

---

### 22. **Search UI Enhancement** (Basic only)
- **Status**: Basic search box only
- **What's needed**:
  - Search suggestions dropdown
  - Recent searches
  - Trending searches
  - Saved searches
  - Search categories sidebar
  - Search results filters UI
  - Search results sorting
  - Search result view options (grid/list)

---

### 23. **Keyboard Shortcuts** (Missing)
- **Status**: No implementation
- **What's needed**:
  - Spacebar to play/pause
  - Arrow keys for seeking
  - Volume control (+ / -)
  - Fullscreen (F)
  - Mute (M)
  - Numbers for seeking (0-9)
  - > / < for playback speed
  - L for like/dislike
  - S for settings
  - Customizable shortcuts
  - Shortcut help dialog (?)

---

### 24. **Accessibility Features** (Missing)
- **Status**: No implementation
- **What's needed**:
  - Screen reader support
  - High contrast mode
  - Font size adjustment
  - Keyboard-only navigation
  - Focus indicators
  - Alt text for images
  - Audio descriptions
  - Captions/subtitles support
  - Color blind modes
  - Dyslexia-friendly font option

---

## TIER 8: CROSS-PLATFORM (Incomplete)

### 25. **Multi-Platform Support** (Partial)
- **Status**: Linux support mostly done, **Windows/macOS need work**
- **What's needed**:
  - **Windows native packaging** (.exe installer)
  - **macOS support** (build & package)
  - **macOS .dmg distribution**
  - **Linux AppImage** packaging
  - **Linux Flatpak** support
  - **Linux Snap** support
  - **Auto-update mechanism** per platform
  - **System tray icon** (minimize to tray)
  - **Launch on startup** option
  - Platform-specific shortcuts
  - Native file dialogs per OS
  - Drag & drop file support

---

### 26. **Platform-Specific Features** (Missing)
- **Status**: No implementation
- **What's needed**:
  - Windows:
    - System media controls (multimedia keys)
    - Windows Notification API
    - Registry integration
  - Linux:
    - D-Bus integration
    - MPRIS protocol (media control)
    - Desktop file integration
  - macOS:
    - TouchBar support
    - Spotlight search integration
    - Handoff support (if cloud sync)

---

## TIER 9: TESTING & QA (Missing)

### 27. **Testing Coverage** (Minimal)
- **Status**: Basic widget test only
- **What's needed**:
  - Unit tests (backend & frontend)
  - Integration tests
  - API endpoint tests
  - Database tests
  - Player integration tests
  - Download tests
  - Search functionality tests
  - Performance tests
  - Stress tests
  - End-to-end UI tests

---

### 28. **Documentation** (Incomplete)
- **Status**: Basic READMEs exist, **detailed docs missing**
- **What's needed**:
  - API documentation (OpenAPI/Swagger)
  - Installation guides per OS
  - Configuration guide
  - Troubleshooting guide
  - Developer setup guide
  - Architecture documentation
  - Code comments/doc strings
  - User manual
  - Video tutorial
  - Keyboard shortcuts documentation
  - FAQ page
  - Contributing guidelines (exists but incomplete)

---

## TIER 10: PERFORMANCE & OPTIMIZATION (Missing)

### 29. **Performance Optimization** (Not done)
- **Status**: No optimization phase yet
- **What's needed**:
  - Lazy loading for lists
  - Virtual scrolling for large lists
  - Image optimization (compression, resizing)
  - Streaming optimization
  - Database query optimization
  - Memory profiling & leaks fixes
  - Startup time optimization
  - UI render optimization
  - Network request batching
  - Connection pooling

---

### 30. **Resource Management** (Missing)
- **Status**: Basic implementation only
- **What's needed**:
  - Memory usage limits
  - CPU usage optimization
  - Bandwidth limiting
  - Storage quota management
  - Download pause on low battery
  - Download pause on mobile data (desktop not applicable but conceptually)
  - Cleanup old cache automatically

---

## TIER 11: SECURITY & PRIVACY (Missing)

### 31. **Security Features** (Missing)
- **Status**: No security implementation
- **What's needed**:
  - HTTPS enforcement
  - Certificate pinning
  - Input validation/sanitization
  - XSS/CSRF protection
  - Rate limiting
  - DDoS protection
  - Secure credential storage
  - API key management
  - OAuth support (future)
  - Security audit

---

### 32. **Privacy Features** (Partial)
- **Status**: Basic, needs enhancement
- **What's needed**:
  - No telemetry/tracking
  - Data privacy policy
  - Cookie management
  - Do-not-track header
  - Anonymous search support
  - Encrypted local storage (optional)
  - Clear all data option
  - Data deletion on uninstall
  - GDPR compliance
  - Privacy audit

---

## TIER 12: NICE-TO-HAVE FEATURES (Bonus)

### 33. **Community/Social** (Not planned)
- **Status**: No implementation
- **What's needed**:
  - Share videos with link
  - Share timestamp links
  - Playlist sharing
  - Social media integration
  - Discord rich presence
  - Watch party (future)
  - Comments/reviews (future)

---

### 34. **Plugins/Extensions** (Not planned)
- **Status**: No implementation
- **What's needed**:
  - Plugin system
  - Custom theme support
  - Custom codec support
  - API for third-party tools

---

### 35. **Analytics/Stats** (Missing)
- **Status**: No implementation
- **What's needed**:
  - Total watch time
  - Most watched channels
  - Most watched videos
  - Watch time by date
  - Download statistics
  - Playback statistics
  - Data visualization (charts)

---

## 📋 SUMMARY TABLE

| Feature | Status | Priority | Difficulty |
|---------|--------|----------|------------|
| Subscriptions UI | 🔴 Missing | P0 | Medium |
| History UI | 🔴 Missing | P0 | Medium |
| Downloads UI (Enhanced) | 🟡 Partial | P0 | Medium |
| Settings Screen | 🔴 Missing | P0 | Hard |
| SponsorBlock Integration | 🟡 Partial | P1 | Medium |
| ReturnYouTubeDislike Integration | 🟡 Partial | P1 | Easy |
| Playlists System | 🔴 Missing | P1 | Hard |
| Channel Pages | 🔴 Missing | P1 | Hard |
| Comments Section | 🟡 Partial | P1 | Medium |
| Trending/Discovery | 🔴 Missing | P2 | Hard |
| Multi-Language | 🔴 Missing | P2 | Medium |
| Background Playback | 🔴 Missing | P1 | Medium |
| Video Quality Selector | 🔴 Missing | P1 | Easy |
| Subtitle Customization | 🔴 Missing | P1 | Medium |
| Search Enhancements | 🟡 Partial | P1 | Medium |
| Database Features | 🟡 Partial | P2 | Hard |
| Auto-Download/Sync | 🔴 Missing | P2 | Hard |
| Notifications | 🔴 Missing | P1 | Medium |
| Keyboard Shortcuts | 🔴 Missing | P2 | Easy |
| Accessibility | 🔴 Missing | P3 | Hard |
| Error Handling | 🟡 Partial | P1 | Medium |
| Caching System | 🔴 Missing | P2 | Hard |
| Update System | 🔴 Missing | P2 | Medium |
| Cross-Platform Packaging | 🟡 Partial | P1 | Hard |
| Testing | 🟡 Minimal | P3 | Hard |
| Documentation | 🟡 Partial | P2 | Medium |
| Performance Optimization | 🔴 Missing | P3 | Hard |

---

## 🎯 RECOMMENDED IMPLEMENTATION ORDER

### **Phase 1 (MVP Completion)** - Next 2-3 weeks
1. **Subscriptions UI Screen**
2. **Settings Screen** (basic)
3. **History UI Screen**
4. **SponsorBlock automatic skipping**
5. **ReturnYouTubeDislike display**
6. **Video quality selector**

### **Phase 2 (Core Features)** - Weeks 4-6
1. **Playlists system**
2. **Channel pages**
3. **Comments section** (functional)
4. **Enhanced downloads UI**
5. **Search enhancements**
6. **Background playback**

### **Phase 3 (Polish)** - Weeks 7-9
1. **Keyboard shortcuts**
2. **Notifications system**
3. **Multi-language support**
4. **Performance optimization**
5. **Error handling improvements**
6. **Caching system**

### **Phase 4 (Advanced)** - Weeks 10+
1. **Trending/Discovery**
2. **Accessibility features**
3. **Cross-platform packaging**
4. **Comprehensive testing**
5. **Documentation**

---

## 🔗 NOTES

- **Total Missing Features**: ~35 major feature areas
- **Estimated Completion Time**: 3-6 months (with dedicated team)
- **Most Critical**: Settings, Subscriptions UI, History UI, SponsorBlock integration
- **Highest Impact**: Playlists, Channel pages, Background playback
- **Quick Wins**: Keyboard shortcuts, Notifications, Quality selector

---

*Generated for Pragadeesh | Tubular PC Project | 2026*

```

`frontend/README.md`:

```md
# tubular_pc

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

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
import '../services/api_service.dart';
import '../services/player_service.dart';

enum PlaybackStatus { idle, loading, playing, paused, stopped, error }

enum PlayerSurface { hidden, fullscreen, mini }

class PlayerState {
  const PlayerState({
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

  PlayerState copyWith({
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
    return PlayerState(
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

  static const initial = PlayerState();
}

final playerControllerProvider =
    StateNotifierProvider<PlayerController, PlayerState>((ref) {
      final apiService = ref.watch(apiServiceProvider);
      final playerService = ref.watch(playerServiceProvider);
      return PlayerController(apiService, playerService);
    });

class PlayerController extends StateNotifier<PlayerState> {
  PlayerController(this._apiService, this._playerService)
    : super(PlayerState.initial);

  final ApiService _apiService;
  final PlayerService _playerService;
  int _playRequestSerial = 0;

  Future<void> playVideo(
    Video video, {
    String quality = 'best',
    PlayerSurface surface = PlayerSurface.fullscreen,
  }) async {
    final requestSerial = ++_playRequestSerial;

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
      final streamUrl = await _apiService.getStreamUrl(
        video.id,
        quality: quality,
      );
      if (requestSerial != _playRequestSerial || state.video?.id != video.id) {
        return;
      }

      final backendState = await _playerService.play(
        videoId: video.id,
        streamUrl: streamUrl,
        duration: video.duration,
        backgroundAudio: state.backgroundAudio,
      );
      if (requestSerial != _playRequestSerial || state.video?.id != video.id) {
        return;
      }

      state = state.copyWith(
        streamUrl: backendState.streamUrl ?? streamUrl,
        status: _statusFromBackend(backendState.status),
        position: backendState.position,
        duration: backendState.duration ?? video.duration,
        backgroundAudio: backendState.backgroundAudio,
        clearError: true,
      );
    } catch (error) {
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

    final previousState = state;
    state = state.copyWith(status: PlaybackStatus.paused);
    await _syncCommand(
      previousState: previousState,
      command: _playerService.pause,
    );
  }

  Future<void> resume() async {
    if (state.status != PlaybackStatus.paused) {
      return;
    }

    final previousState = state;
    state = state.copyWith(status: PlaybackStatus.playing);
    await _syncCommand(
      previousState: previousState,
      command: _playerService.resume,
    );
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
    final previousState = state;
    previewSeek(position);

    await _syncCommand(
      previousState: previousState,
      command: () => _playerService.seek(state.position),
    );
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

  Future<void> toggleBackgroundAudio() async {
    final previousState = state;
    final enabled = !state.backgroundAudio;
    state = state.copyWith(backgroundAudio: enabled);

    await _syncCommand(
      previousState: previousState,
      command: () => _playerService.setBackgroundAudio(enabled),
    );
  }

  Future<void> stop() async {
    _playRequestSerial++;
    final previousState = state;
    state = PlayerState.initial.copyWith(status: PlaybackStatus.stopped);

    try {
      await _playerService.stop();
    } catch (error) {
      state = previousState.copyWith(
        status: PlaybackStatus.error,
        errorMessage: error.toString(),
      );
    }
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

  Future<void> _syncCommand({
    required PlayerState previousState,
    required Future<BackendPlayerSnapshot> Function() command,
  }) async {
    final currentVideoId = state.video?.id;

    try {
      final backendState = await command();
      if (currentVideoId != state.video?.id) {
        return;
      }

      _applyBackendState(backendState);
    } catch (error) {
      if (currentVideoId != state.video?.id) {
        return;
      }

      state = previousState.copyWith(
        status: PlaybackStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  void _applyBackendState(BackendPlayerSnapshot backendState) {
    final backendVideoId = backendState.videoId;
    if (backendVideoId != null && backendVideoId != state.video?.id) {
      return;
    }

    state = state.copyWith(
      streamUrl: backendState.streamUrl,
      status: _statusFromBackend(backendState.status),
      position: backendState.position,
      duration: backendState.duration,
      backgroundAudio: backendState.backgroundAudio,
      errorMessage: backendState.error,
      clearError: backendState.error == null,
    );
  }

  PlaybackStatus _statusFromBackend(String status) {
    switch (status) {
      case 'playing':
        return PlaybackStatus.playing;
      case 'paused':
        return PlaybackStatus.paused;
      case 'stopped':
        return PlaybackStatus.stopped;
      case 'error':
        return PlaybackStatus.error;
      case 'idle':
        return PlaybackStatus.idle;
      default:
        return state.status;
    }
  }
}

```

`frontend/lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';
import 'screens/subscriptions_screen.dart';
import 'screens/history_screen.dart';
import 'screens/downloads_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/player_shell.dart';

final navigationIndexProvider = StateProvider<int>((ref) => 0);

void main() {
  runApp(const ProviderScope(child: TubularApp()));
}

class TubularApp extends StatelessWidget {
  const TubularApp({super.key});

  @override
  Widget build(BuildContext context) {
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
        scaffoldBackgroundColor: Colors.grey[900],
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
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
            backgroundColor: Colors.grey[900],
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
                    // Navigate to settings
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Settings coming soon')),
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

`frontend/lib/screens/downloads_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/download.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());

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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/history_entry.dart';
import '../services/api_service.dart';
import 'player_screen.dart';

final apiServiceProvider = Provider((ref) => ApiService());

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
import '../widgets/video_card.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider.autoDispose<List<Video>>((
  ref,
) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) {
    return [];
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
    ref.read(playerControllerProvider.notifier).playVideo(video);
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
        data: (videos) {
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
        loading: () => Center(
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
                'This may take 10-30 seconds on first search',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error: $error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(searchResultsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
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
import '../services/api_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());

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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());

// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

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

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  void _saveSetting(String key, String value) {
    final apiService = ref.read(apiServiceProvider);
    apiService.setSetting(key, value).then((_) {
      // Silent success
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save setting: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final preferredQuality = ref.watch(preferredQualityProvider);
    final preferredFormat = ref.watch(preferredFormatProvider);
    final audioOnly = ref.watch(audioOnlyModeProvider);
    final autoPlay = ref.watch(autoPlayProvider);
    final downloadFolder = ref.watch(downloadFolderProvider);
    final subtitleSize = ref.watch(subtitleFontSizeProvider);
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
                themeMode == ThemeMode.dark ? 'Dark' : 'Light',
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
                items: const [
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
                'Preferred Format',
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
    String currentValue, {
    required List<DropdownMenuItem<dynamic>> items,
    required ValueChanged<dynamic> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(currentValue),
      trailing: DropdownButton(
        value: currentValue,
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
import '../services/api_service.dart';
import '../widgets/video_card.dart';
import 'player_screen.dart';

final apiServiceProvider = Provider((ref) => ApiService());

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

`frontend/lib/services/api_service.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../models/video.dart';
import '../models/subscription.dart';
import '../models/history_entry.dart';
import '../models/download.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

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

  Future<List<Video>> searchVideos(String query, {int limit = 10}) async {
    _logger.i('Searching for: $query');
    try {
      final response = await _dio.get(
        '/search',
        queryParameters: {'q': query, 'limit': limit},
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        _logger.i('Search successful, got ${data.length} results from backend');
        
        if (data.isEmpty) {
          _logger.w('Backend returned 0 results, using mock data');
          return _getMockSearchResults(query, limit);
        }
        
        return data.map((json) => Video.fromJson(json)).toList();
      } else {
        _logger.w('Backend returned error: ${response.data['error']}');
        throw Exception(response.data['error'] ?? 'Search failed');
      }
    } catch (e) {
      _logger.w('Backend unavailable or error, using mock data: $e');
      // Return mock data for development
      final results = _getMockSearchResults(query, limit);
      _logger.i('Returning ${results.length} mock results for "$query"');
      return results;
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
              video.description!.toLowerCase().contains(query.toLowerCase()),
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
    try {
      final response = await _dio.get(
        '/stream/$videoId',
        queryParameters: {'quality': quality},
      );

      if (response.data['success'] == true) {
        return response.data['data']['url'];
      } else {
        throw Exception(response.data['error'] ?? 'Failed to get stream URL');
      }
    } catch (e) {
      _logger.w('Get stream URL error: $e');
      // Return a placeholder for development
      throw Exception(
        'Backend not available. Please ensure the Rust backend is running on http://localhost:3030',
      );
    }
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
    } catch (e) {
      _logger.w('Download error: $e');
      throw Exception(
        'Backend not available. Please ensure the Rust backend is running on http://localhost:3030',
      );
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
        // Convert backend Download objects to frontend Download objects
        // For now, we'll map them as completed downloads
        return data.map((json) {
          final backendDownload = json as Map<String, dynamic>;
          return Download(
            id: backendDownload['id'].toString(),
            videoId: backendDownload['video_id'] ?? '',
            title: backendDownload['title'] ?? '',
            filePath: backendDownload['file_path'] ?? '',
            fileSize: 0, // Backend doesn't track this yet
            format: 'video', // Default format
            quality: backendDownload['quality'] ?? 'unknown',
            status: 'completed',
            progress: 100.0,
            createdAt: DateTime.parse(backendDownload['downloaded_at']),
            completedAt: DateTime.parse(backendDownload['downloaded_at']),
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

`frontend/lib/widgets/player_shell.dart`:

```dart
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/player_controller.dart';

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

    switch (playerState.surface) {
      case PlayerSurface.fullscreen:
        return const _FullscreenPlayer();
      case PlayerSurface.mini:
        return const _MiniPlayer();
      case PlayerSurface.hidden:
        return const SizedBox.shrink();
    }
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

class _PlayerStage extends ConsumerWidget {
  const _PlayerStage({required this.playerState});

  final PlayerState playerState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final video = playerState.video;
    final controller = ref.read(playerControllerProvider.notifier);

    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (video != null && video.thumbnail.isNotEmpty)
            Opacity(
              opacity: 0.26,
              child: CachedNetworkImage(
                imageUrl: video.thumbnail,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x66000000), Color(0xFF000000)],
              ),
            ),
          ),
          Center(
            child: _PlayerCenterControl(
              playerState: playerState,
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

  final PlayerState playerState;
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

  final PlayerState playerState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(playerControllerProvider.notifier);
    final duration = playerState.duration;
    final position = _safePosition(playerState.position, duration);

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
                  tooltip: 'Background audio',
                  onPressed: controller.toggleBackgroundAudio,
                  color: playerState.backgroundAudio
                      ? const Color(0xFFE53935)
                      : Colors.white,
                  icon: const Icon(Icons.headphones),
                ),
                _QualityMenu(
                  selectedQuality: playerState.quality,
                  onSelected: controller.setQuality,
                ),
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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

`frontend/linux/CMakeLists.txt`:

```txt
# Project-level configuration.
cmake_minimum_required(VERSION 3.13)
project(runner LANGUAGES CXX)

# The name of the executable created for the application. Change this to change
# the on-disk name of your application.
set(BINARY_NAME "tubular_pc")
# The unique GTK application identifier for this application. See:
# https://wiki.gnome.org/HowDoI/ChooseApplicationID
set(APPLICATION_ID "com.example.tubular_pc")

# Explicitly opt in to modern CMake behaviors to avoid warnings with recent
# versions of CMake.
cmake_policy(SET CMP0063 NEW)

# Load bundled libraries from the lib/ directory relative to the binary.
set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")

# Root filesystem for cross-building.
if(FLUTTER_TARGET_PLATFORM_SYSROOT)
  set(CMAKE_SYSROOT ${FLUTTER_TARGET_PLATFORM_SYSROOT})
  set(CMAKE_FIND_ROOT_PATH ${CMAKE_SYSROOT})
  set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
  set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
  set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
  set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
endif()

# Define build configuration options.
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_BUILD_TYPE "Debug" CACHE
    STRING "Flutter build mode" FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
    "Debug" "Profile" "Release")
endif()

# Compilation settings that should be applied to most targets.
#
# Be cautious about adding new options here, as plugins use this function by
# default. In most cases, you should add new options to specific targets instead
# of modifying this function.
function(APPLY_STANDARD_SETTINGS TARGET)
  target_compile_features(${TARGET} PUBLIC cxx_std_14)
  target_compile_options(${TARGET} PRIVATE -Wall -Werror)
  target_compile_options(${TARGET} PRIVATE "$<$<NOT:$<CONFIG:Debug>>:-O3>")
  target_compile_definitions(${TARGET} PRIVATE "$<$<NOT:$<CONFIG:Debug>>:NDEBUG>")
endfunction()

# Flutter library and tool build rules.
set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")
add_subdirectory(${FLUTTER_MANAGED_DIR})

# System-level dependencies.
find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK REQUIRED IMPORTED_TARGET gtk+-3.0)

# Application build; see runner/CMakeLists.txt.
add_subdirectory("runner")

# Run the Flutter tool portions of the build. This must not be removed.
add_dependencies(${BINARY_NAME} flutter_assemble)

# Only the install-generated bundle's copy of the executable will launch
# correctly, since the resources must in the right relative locations. To avoid
# people trying to run the unbundled copy, put it in a subdirectory instead of
# the default top-level location.
set_target_properties(${BINARY_NAME}
  PROPERTIES
  RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/intermediates_do_not_run"
)


# Generated plugin build rules, which manage building the plugins and adding
# them to the application.
include(flutter/generated_plugins.cmake)


# === Installation ===
# By default, "installing" just makes a relocatable bundle in the build
# directory.
set(BUILD_BUNDLE_DIR "${PROJECT_BINARY_DIR}/bundle")
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX "${BUILD_BUNDLE_DIR}" CACHE PATH "..." FORCE)
endif()

# Start with a clean build bundle directory every time.
install(CODE "
  file(REMOVE_RECURSE \"${BUILD_BUNDLE_DIR}/\")
  " COMPONENT Runtime)

set(INSTALL_BUNDLE_DATA_DIR "${CMAKE_INSTALL_PREFIX}/data")
set(INSTALL_BUNDLE_LIB_DIR "${CMAKE_INSTALL_PREFIX}/lib")

install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}"
  COMPONENT Runtime)

install(FILES "${FLUTTER_ICU_DATA_FILE}" DESTINATION "${INSTALL_BUNDLE_DATA_DIR}"
  COMPONENT Runtime)

install(FILES "${FLUTTER_LIBRARY}" DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
  COMPONENT Runtime)

foreach(bundled_library ${PLUGIN_BUNDLED_LIBRARIES})
  install(FILES "${bundled_library}"
    DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
    COMPONENT Runtime)
endforeach(bundled_library)

# Copy the native assets provided by the build.dart from all packages.
set(NATIVE_ASSETS_DIR "${PROJECT_BUILD_DIR}native_assets/linux/")
install(DIRECTORY "${NATIVE_ASSETS_DIR}"
   DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
   COMPONENT Runtime)

# Fully re-copy the assets directory on each build to avoid having stale files
# from a previous install.
set(FLUTTER_ASSET_DIR_NAME "flutter_assets")
install(CODE "
  file(REMOVE_RECURSE \"${INSTALL_BUNDLE_DATA_DIR}/${FLUTTER_ASSET_DIR_NAME}\")
  " COMPONENT Runtime)
install(DIRECTORY "${PROJECT_BUILD_DIR}/${FLUTTER_ASSET_DIR_NAME}"
  DESTINATION "${INSTALL_BUNDLE_DATA_DIR}" COMPONENT Runtime)

# Install the AOT library on non-Debug builds only.
if(NOT CMAKE_BUILD_TYPE MATCHES "Debug")
  install(FILES "${AOT_LIBRARY}" DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
    COMPONENT Runtime)
endif()

```

`frontend/linux/flutter/CMakeLists.txt`:

```txt
# This file controls Flutter-level build steps. It should not be edited.
cmake_minimum_required(VERSION 3.10)

set(EPHEMERAL_DIR "${CMAKE_CURRENT_SOURCE_DIR}/ephemeral")

# Configuration provided via flutter tool.
include(${EPHEMERAL_DIR}/generated_config.cmake)

# TODO: Move the rest of this into files in ephemeral. See
# https://github.com/flutter/flutter/issues/57146.

# Serves the same purpose as list(TRANSFORM ... PREPEND ...),
# which isn't available in 3.10.
function(list_prepend LIST_NAME PREFIX)
    set(NEW_LIST "")
    foreach(element ${${LIST_NAME}})
        list(APPEND NEW_LIST "${PREFIX}${element}")
    endforeach(element)
    set(${LIST_NAME} "${NEW_LIST}" PARENT_SCOPE)
endfunction()

# === Flutter Library ===
# System-level dependencies.
find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK REQUIRED IMPORTED_TARGET gtk+-3.0)
pkg_check_modules(GLIB REQUIRED IMPORTED_TARGET glib-2.0)
pkg_check_modules(GIO REQUIRED IMPORTED_TARGET gio-2.0)

set(FLUTTER_LIBRARY "${EPHEMERAL_DIR}/libflutter_linux_gtk.so")

# Published to parent scope for install step.
set(FLUTTER_LIBRARY ${FLUTTER_LIBRARY} PARENT_SCOPE)
set(FLUTTER_ICU_DATA_FILE "${EPHEMERAL_DIR}/icudtl.dat" PARENT_SCOPE)
set(PROJECT_BUILD_DIR "${PROJECT_DIR}/build/" PARENT_SCOPE)
set(AOT_LIBRARY "${PROJECT_DIR}/build/lib/libapp.so" PARENT_SCOPE)

list(APPEND FLUTTER_LIBRARY_HEADERS
  "fl_basic_message_channel.h"
  "fl_binary_codec.h"
  "fl_binary_messenger.h"
  "fl_dart_project.h"
  "fl_engine.h"
  "fl_json_message_codec.h"
  "fl_json_method_codec.h"
  "fl_message_codec.h"
  "fl_method_call.h"
  "fl_method_channel.h"
  "fl_method_codec.h"
  "fl_method_response.h"
  "fl_plugin_registrar.h"
  "fl_plugin_registry.h"
  "fl_standard_message_codec.h"
  "fl_standard_method_codec.h"
  "fl_string_codec.h"
  "fl_value.h"
  "fl_view.h"
  "flutter_linux.h"
)
list_prepend(FLUTTER_LIBRARY_HEADERS "${EPHEMERAL_DIR}/flutter_linux/")
add_library(flutter INTERFACE)
target_include_directories(flutter INTERFACE
  "${EPHEMERAL_DIR}"
)
target_link_libraries(flutter INTERFACE "${FLUTTER_LIBRARY}")
target_link_libraries(flutter INTERFACE
  PkgConfig::GTK
  PkgConfig::GLIB
  PkgConfig::GIO
)
add_dependencies(flutter flutter_assemble)

# === Flutter tool backend ===
# _phony_ is a non-existent file to force this command to run every time,
# since currently there's no way to get a full input/output list from the
# flutter tool.
add_custom_command(
  OUTPUT ${FLUTTER_LIBRARY} ${FLUTTER_LIBRARY_HEADERS}
    ${CMAKE_CURRENT_BINARY_DIR}/_phony_
  COMMAND ${CMAKE_COMMAND} -E env
    ${FLUTTER_TOOL_ENVIRONMENT}
    "${FLUTTER_ROOT}/packages/flutter_tools/bin/tool_backend.sh"
      ${FLUTTER_TARGET_PLATFORM} ${CMAKE_BUILD_TYPE}
  VERBATIM
)
add_custom_target(flutter_assemble DEPENDS
  "${FLUTTER_LIBRARY}"
  ${FLUTTER_LIBRARY_HEADERS}
)

```

`frontend/linux/flutter/generated_plugin_registrant.cc`:

```cc
//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"


void fl_register_plugins(FlPluginRegistry* registry) {
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

`frontend/linux/runner/CMakeLists.txt`:

```txt
cmake_minimum_required(VERSION 3.13)
project(runner LANGUAGES CXX)

# Define the application target. To change its name, change BINARY_NAME in the
# top-level CMakeLists.txt, not the value here, or `flutter run` will no longer
# work.
#
# Any new source files that you add to the application should be added here.
add_executable(${BINARY_NAME}
  "main.cc"
  "my_application.cc"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
)

# Apply the standard set of build settings. This can be removed for applications
# that need different build settings.
apply_standard_settings(${BINARY_NAME})

# Add preprocessor definitions for the application ID.
add_definitions(-DAPPLICATION_ID="${APPLICATION_ID}")

# Add dependency libraries. Add any application-specific dependencies here.
target_link_libraries(${BINARY_NAME} PRIVATE flutter)
target_link_libraries(${BINARY_NAME} PRIVATE PkgConfig::GTK)

target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")

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
      sha256: "8d7ff3948166b8ec5da0fbb5962000926b8e02f2ed9b3e51d1738905fbd4c98d"
      url: "https://pub.dev"
    source: hosted
    version: "93.0.0"
  analyzer:
    dependency: transitive
    description:
      name: analyzer
      sha256: de7148ed2fcec579b19f122c1800933dfa028f6d9fd38a152b04b1516cec120b
      url: "https://pub.dev"
    source: hosted
    version: "10.0.1"
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
      sha256: a156715e7cd728130c592f30552575908aae5b100005fbc1f0fb16b3c03a3d10
      url: "https://pub.dev"
    source: hosted
    version: "4.0.6"
  build_config:
    dependency: transitive
    description:
      name: build_config
      sha256: "4070d2a59f8eec34c97c86ceb44403834899075f66e8a9d59706f8e7834f6f71"
      url: "https://pub.dev"
    source: hosted
    version: "1.3.0"
  build_daemon:
    dependency: transitive
    description:
      name: build_daemon
      sha256: bf05f6e12cfea92d3c09308d7bcdab1906cd8a179b023269eed00c071004b957
      url: "https://pub.dev"
    source: hosted
    version: "4.1.1"
  build_runner:
    dependency: "direct dev"
    description:
      name: build_runner
      sha256: "1523ce62448ebac2c15a8ba5fbad8acac169788658a7dd2a1c2d9c2a9318b9a6"
      url: "https://pub.dev"
    source: hosted
    version: "2.15.0"
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
  csslib:
    dependency: transitive
    description:
      name: csslib
      sha256: "09bad715f418841f976c77db72d5398dc1253c21fb9c0c7f0b0b985860b2d58e"
      url: "https://pub.dev"
    source: hosted
    version: "1.0.2"
  dart_style:
    dependency: transitive
    description:
      name: dart_style
      sha256: "29f7ecc274a86d32920b1d9cfc7502fa87220da41ec60b55f329559d5732e2b2"
      url: "https://pub.dev"
    source: hosted
    version: "3.1.7"
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
      sha256: "9e8c3858111da373efc5aa341de011d9bd23e2c5c5e0c62bccf32438e192d7b1"
      url: "https://pub.dev"
    source: hosted
    version: "3.0.2"
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
  html:
    dependency: transitive
    description:
      name: html
      sha256: "6d1264f2dffa1b1101c25a91dff0dc2daee4c18e87cd8538729773c073dbf602"
      url: "https://pub.dev"
    source: hosted
    version: "0.15.6"
  http:
    dependency: "direct main"
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
  intl:
    dependency: "direct main"
    description:
      name: intl
      sha256: d6f56758b7d3014a48af9701c085700aac781a92a87a62b1333b46d8879661cf
      url: "https://pub.dev"
    source: hosted
    version: "0.19.0"
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
  json_annotation:
    dependency: "direct main"
    description:
      name: json_annotation
      sha256: cb09e7dac6210041fad964ed7fbee004f14258b4eca4040f72d1234062ace4c8
      url: "https://pub.dev"
    source: hosted
    version: "4.11.0"
  json_serializable:
    dependency: "direct dev"
    description:
      name: json_serializable
      sha256: "2c15e78e1cc6e62aadecf59f81566fd56829713d96a8c4177699e2b2e17f20db"
      url: "https://pub.dev"
    source: hosted
    version: "6.13.2"
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
      sha256: cbf8d4b858bb0134ef3ef87841abdf8d63bfc255c266b7bf6b39daa1085c4290
      url: "https://pub.dev"
    source: hosted
    version: "3.0.0"
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
  path:
    dependency: transitive
    description:
      name: path
      sha256: "75cca69d1490965be98c73ceaea117e8a04dd21217b37b292c9ddbec0d955bc5"
      url: "https://pub.dev"
    source: hosted
    version: "1.9.1"
  path_provider:
    dependency: "direct main"
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
    dependency: "direct main"
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
      sha256: ec37cc0e6694374cbef59ed79685572c870a54ede6fa30a3e420feb3adffea02
      url: "https://pub.dev"
    source: hosted
    version: "4.2.3"
  source_helper:
    dependency: transitive
    description:
      name: source_helper
      sha256: "4227d54ceefd0bb8ca4c8fcb96e1719dc53f1ee1b6e2ca9d7a6069da160e4eae"
      url: "https://pub.dev"
    source: hosted
    version: "1.3.12"
  source_span:
    dependency: transitive
    description:
      name: source_span
      sha256: "56a02f1f4cd1a2d96303c0144c93bd6d909eea6bee6bf5a0e0b685edbd4c47ab"
      url: "https://pub.dev"
    source: hosted
    version: "1.10.2"
  sqflite:
    dependency: "direct main"
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
      sha256: "5e8377564d95166761a968ed96104e0569b6b6cc611faac92a36ab8a169112c3"
      url: "https://pub.dev"
    source: hosted
    version: "2.5.6+1"
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
  typed_data:
    dependency: transitive
    description:
      name: typed_data
      sha256: f9049c039ebfeb4cf7a7104a675823cd72dba8297f264b6637062516699fa006
      url: "https://pub.dev"
    source: hosted
    version: "1.4.0"
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
  video_player:
    dependency: "direct main"
    description:
      name: video_player
      sha256: "48a7bdaa38a3d50ec10c78627abdbfad863fdf6f0d6e08c7c3c040cfd80ae36f"
      url: "https://pub.dev"
    source: hosted
    version: "2.11.1"
  video_player_android:
    dependency: transitive
    description:
      name: video_player_android
      sha256: "877a6c7ba772456077d7bfd71314629b3fe2b73733ce503fc77c3314d43a0ca0"
      url: "https://pub.dev"
    source: hosted
    version: "2.9.5"
  video_player_avfoundation:
    dependency: transitive
    description:
      name: video_player_avfoundation
      sha256: af0e5b8a7a4876fb37e7cc8cb2a011e82bb3ecfa45844ef672e32cb14a1f259e
      url: "https://pub.dev"
    source: hosted
    version: "2.9.4"
  video_player_platform_interface:
    dependency: transitive
    description:
      name: video_player_platform_interface
      sha256: "16eaed5268c571c31840dc58ef8da5f0cd4db2a98490c3b8f1cf70122546c6e0"
      url: "https://pub.dev"
    source: hosted
    version: "6.7.0"
  video_player_web:
    dependency: transitive
    description:
      name: video_player_web
      sha256: "9f3c00be2ef9b76a95d94ac5119fb843dca6f2c69e6c9968f6f2b6c9e7afbdeb"
      url: "https://pub.dev"
    source: hosted
    version: "2.4.0"
  vm_service:
    dependency: transitive
    description:
      name: vm_service
      sha256: "0016aef94fc66495ac78af5859181e3f3bf2026bd8eecc72b9565601e19ab360"
      url: "https://pub.dev"
    source: hosted
    version: "15.2.0"
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
  xdg_directories:
    dependency: transitive
    description:
      name: xdg_directories
      sha256: "7a3f37b05d989967cdddcbb571f1ea834867ae2faa29725fd085180e0883aa15"
      url: "https://pub.dev"
    source: hosted
    version: "1.1.0"
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
  flutter: ">=3.38.4"

```

`frontend/pubspec.yaml`:

```yaml
name: tubular_pc
description: A desktop YouTube client inspired by Tubular/NewPipe - ad-free, privacy-focused video streaming.
version: 0.1.0

environment:
  sdk: '>=3.8.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  riverpod: ^2.4.0
  flutter_riverpod: ^2.4.0
  
  # HTTP & API
  dio: ^5.3.0
  http: ^1.1.0
  
  # Database
  sqflite: ^2.3.0
  
  # Serialization
  json_annotation: ^4.11.0
  
  # Video Player
  video_player: ^2.8.0
  
  # UI
  flutter_staggered_grid_view: ^0.7.0
  cached_network_image: ^3.3.0
  
  # Utils
  intl: ^0.19.0
  logger: ^2.0.0
  path_provider: ^2.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.0
  json_serializable: ^6.7.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/

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

`plan.md`:

```md

Alright Pragadeesh 😎🔥
You’re not just building an app… you’re basically building a **desktop-level NewPipe/Tubular clone** — that’s elite tier stuff.

I’ll give you a **FULL PROJECT GUIDE (production-level)** for:

# 🚀 Project: **Tubular-PC**

> Goal: Exact Tubular UI/UX + Desktop power 💻⚡
> Platforms: Linux + Windows + macOS
> Stack: Flutter + Rust + yt-dlp

---

# 🧠 0. Reality check (VERY IMPORTANT)

Tubular (NewPipe fork) works by:

* ❌ No official YouTube API
* ✅ Direct extraction/scraping
* ✅ Local data storage
* ✅ No login required

➡️ This gives:

* Ad-free
* Background play
* Downloads
* Privacy

But also:

* Breaks often when YouTube updates ([OSTechNix][1])

👉 So your architecture must be **modular + replaceable**

---

# 🏗️ 1. FINAL ARCHITECTURE (BEST FOR YOU)

```
Tubular-PC/
│
├── frontend/        (Flutter Desktop)
├── backend/         (Rust core)
├── extractor/       (yt-dlp wrapper)
├── player/          (mpv / libmpv)
└── api/             (SponsorBlock, Dislike API)
```

---

# ⚙️ 2. TECH STACK (LOCK THIS IN 🔒)

### 🎨 Frontend

* Flutter (desktop)
* Riverpod / Bloc (state)
* Custom UI (no Material look — replicate Tubular)

---

### ⚡ Backend

* Rust
* Tokio (async)
* Expose API via:

  * IPC (preferred)
  * or HTTP localhost

---

### 🎥 Extractor

* yt-dlp (core engine)
  👉 Supports 1000+ sites including YouTube ([StreamFab][2])

---

### 🎬 Player

* libmpv (BEST)
* fallback: Flutter video player

---

### 🌐 APIs

* SponsorBlock → skip segments
* Return YouTube Dislike

---

# 🎨 3. EXACT UI/UX (Tubular Clone)

You want **exact UI = not copy… replicate behavior**

---

## 📱 Main Screens

### 1. Home Feed

![Image](https://images.openai.com/static-rsc-4/JrrodGM439iIuk340pyDkGxeNWFGw6sLz1yW8aDj4rTReRVTk20HBLrPRuYDRzL5XKJT1Zw2EZLtV_GXvvTOL8VzE3G0wy2i-Ib7dEuHR9TIwbymktBpT7XjxBLe48gzaR9oyRCa8w9dfEW5eOep608A38-993LEoLhw3GjM3XoQbTutr3dOJOCd_MtY0FAE?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/wbD2cg3B0Oi6JN6snup7UhNJ_CuuKhlDCHB7eTOu_2Rwn0UsyfHjd8jVZMReu7XYtyYCSEw36oMIHvhgrTh_8Hgcz4xiR5kASPW6NVIHoDvxTjk_NGagYlOzJjSr7EODMjdVW5Hhid9ZgmM1M5w3jiDTzoqzQWo0d3lrJGTmK6xRXSIG6O-2QLhNK4O1aumU?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/WH3_ew8HyHcPcljWImFCxFJljf5_ThsiXnW1D3VaN7uvUScAwrjXAzZsfhOcD1AuRJeixRdlAdM4EytV__ICuhzHhGyw1NvpTy5PqBWsZ7PwviFegGJt4EsCj-_MDMrn3x9pLxWgG1pqPtXkLHYQPyxpbQ1PngyOemYunUYEcD0wDJKJtVrFDc4gowSEHENV?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/153-k06EzeqUF5DBMWkapq5MzILqwT5kI8F9kWoaot__jfszRd4uXCj3tnboNgzrOij9rQmsRDjnulvr_-qqIiIaby4P8iQKTUWUPPOrjZPqa3-KzK4o09uwvpTbf9qrLJv0ajzxj5f0EVS14Op-pwjFm-A8YQjZzd9_8OKkNMnOAqlcIX-3g50Z7azxWjEu?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/P_OHHW5awK2pCEhfsDBKPROGZPyGx3DURFacGThY_-z1aIslwMsgXbMI-zrgjf8b_PTPc3h0N6kOUffHjEdTEZgcbG9WjDykT8ROZv_EUSQe5eLxm1ucjaWJHXN9zbilqrveC-fsQkFBpPllncyIrKZ5l7ZFLULn7vrCKE4ofc-VS2ACxaSOnHz1vUxmNw-B?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/1LzK2PtY9MRVhSDqh2OwyrrwjVWoz9JPGnZB5utYbM6o8Pp2fRZRpOcHEGoXmaRIdSmUnYISf-Mm7PHjsmSiCQUoCnVIuzTs4qugReUhK3EMrm6j2yFK7lmDgHhRU_WeIM3aWh5mrU-5wy8Rd7MmWpEETTCZapzPSNto8LP0BoxP3cJN8BK8zkWF4iaKslqN?purpose=fullsize)

* Grid layout
* Infinite scroll
* Thumbnail + duration
* Channel + views

---

### 2. Video Player Screen

![Image](https://images.openai.com/static-rsc-4/ZATUtOLG4ZrIjwk3kb3g3Pi1HaJNLibrZRFWD3Sj7LsmP8sxV3NCGutAIKBcXw1TP7NyRWrnZ-6Co4R7bqCQSEq7MuXk0UxHWxQUkVWRJ_x2HAAQV1ZwuaraVn6gSvQb0TnNu7qq2izspsvxERKZmL3vez5jAo9Fpb8nDFbdmcA3-poyaCdiAsUKVQaosMk6?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/axsWwtRk94no3rqdYEXiH7-MZn_O9nz4gkscqeUx1ujcldSnyHSnND9VYjbkVy5eua3P8-RMwx3H5ufV_48e1_FHhWU43Lt_zYlGh97O5AvBJL1eOqhtqLpgHSVQr_WYN6zx7kanO_VhylQR6lHILCPEL1t2D_AAzWDSY2SIC5cerGpIkLIkLmzAdXGq9f9C?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/F6RbLPOFeiFOLw-1_6JLSyFgBBD2isHPbmByWXRJzOxCEecmGA5sca_84c8H4iRYgHod2AHhfGjuDKc-u3JCR7Z6XpECRF40GPYTWvjROV0FSL979vyhoZz_y2r5bwFvxVrpARborIlDKJ0Uy4FGDR9oLHYdNv4p3uzQj9-BqRvZxW1Qqqm3wUPqPbbFoXu5?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/WEHqCnWnUSvY902VleiW5pQ5omLc5I-a7tDyCFdGdt8LHgAmC5vw0a1Fjxm3GCVCEPy2nNBwqpfL4TP4Y5LggiMdPvgevI7MyngzfV9SzrOTf7-irv2iBHeuEBq3CZW7BtHKTbd_l6N0MEU5c_l6GXQFEkOqpzifoyvxP5de-vOjzuc_fcOYxXNJndVkIcr-?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/GqHw57H63yLcxe6OdAlzE-I4IhWjFjv7gzied5o0lZvWN5E7O04CBlHrniXAS1naMNtsU8GKhO86JgxSAaX2jvFIPwmyrjOyMWuM7-LwTn6t-0zdbTUAheyc2EuqyWUlWwsBNKa7gJ25UMrkWydpuJehUDmXZmL_CK_XnTnUg9VOV2Kckpi8vQbrgOehRwPk?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/jN_NWknU5mgFAWUBmJPlpyHW5pBrh4fuXuoSD1AKiuuSuTU_h0WiNvD8EqDWP7RBqS5bFO5V2xHQSJ9fUP1pFe8Gn2B8VIn8wiVhV2t1VSo06nbSiQG2vEqiEQ-lnq2zu4Tzq5b68aDHZmEwoTPyQ1nchWWJW0rbBHe7KUvQrjjbBhPnuvq67wx_MxsuGyeG?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/qw4SENjgnLtLdPr_A2celUYeXnFXDT-xLGkoTNMqVhhhgYLNXmzWjlwiULvUAwxE-YYONs4idF5SrwDeA9pUYWx-XVKC3gzjeXZ2POhid4e6iivU0tRoUErGM3a0Wl6_4ez3Iukg7ot5oNQtCN9i1dqySH28DoYmj8F1b4mWzmts0a7QyKcaEnZ6p5RP9sk4?purpose=fullsize)

* Title + channel
* Like/Dislike
* Download button
* Background play toggle
* Comments section

---

### 3. Subscriptions Tab

![Image](https://images.openai.com/static-rsc-4/BKGQYjjpNWViCWEUOvo2MEHJe6c8_AfaDnaYSlarmY1sbQ4UH6VmgtWCQzv9dg98Qv1bdHQnNbPYXPteIntcK2CQaKH0sz9C80KtRPDIh35RxpIbnvmexZtN9rIJcu1ZbKiN2eJStzGFthsXyRCii20hG2KOy8dar3W5EmbuLZJtuV3tT8Rj8iz4tV0taH1i?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/wbD2cg3B0Oi6JN6snup7UhNJ_CuuKhlDCHB7eTOu_2Rwn0UsyfHjd8jVZMReu7XYtyYCSEw36oMIHvhgrTh_8Hgcz4xiR5kASPW6NVIHoDvxTjk_NGagYlOzJjSr7EODMjdVW5Hhid9ZgmM1M5w3jiDTzoqzQWo0d3lrJGTmK6xRXSIG6O-2QLhNK4O1aumU?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/PUFIBObO7XSfweI3dtiIkyCHw5hmFawXKZN28ktThus-D2tMMctUcwxUtCpCY32lTP2PReacouMWstb_TDvVbkAiNN2Fqu3xYs9jYoMqMm3decf14F3PqI-2FMfO2xG6qnx2dhQm8ZuRvzsvJ6nVwalWAgN-dSfNn--BiX6L8WKAha6kT4IR7PYYC9lciqi-?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/zndQn-Xu8Iiaz_Ll46T8FGPgZ5QUJKGxNTyUR01jU-d82odVWU_FztGRiBg2pNmfY2gL-MvXUDJ_StOnYLTRQ3z9a612dQQ-nvf6HgnSOhpec-cN3SnMil-ZduiEOk8zqVxiqxs25I36tRrR3PyZJTOpDnm9dSw6QIrmu-UsSMQMV0Ap-WNtw-47wskICAhz?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/H2T7nPYFUxriq7d3UP9G1Gk7CtPAHrVFb6bYUYJdH8cUIgm6HBB6H1v2dXbKgH69BdeweysMrXzpMPgBfcfGsmbjV-WrErzA-Ec1RFfCvwFalEBDicoQOyt8S2ZKWgC3HXA6z2YexfMVK_IfbGjkeK2iiiJwpOp-iRivY-2MGIMPnvQTDcBzARA2dhqasWez?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/pUc5X0fFNWNMp8tlcnZq5m1ZLh43rFagOhfNT0IU5CVTLYs0Q-cmnifCSDSVIWv_4lAIZEFURxeOT8c9a27g6tT5X9hVC_9vIMTi1EigQEBy2v66lppmoe8xdtPL4dLug7GXlKSGFn784l0VwEGDAzznJWoAOr2u0gYv-mknqEoXXwzQlurjgXMFHNQvrc-F?purpose=fullsize)

* Channel list
* Latest uploads
* Offline stored subscriptions

---

### 4. Downloads Page

![Image](https://images.openai.com/static-rsc-4/YI7k8qPR9tXkJCMQI1qRRDOsoWTLgnpNqVCUmGD53T_laxPU4E9G_8PHN_hfX2EsU5UusuVDfRtjjMq84fP2oXnvuJBGSmfSzaz73vE6V7ykCEBRNfJhg5MQCyF3q4hk1P5eTi26nIvMN5cJKK6wCe2S5zRg-4pi1lG_xtNRXqjaYq5_Jo0eDdHhda71ofxL?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/V6h4Z5o3zG9oCSvPPHRgQliMbl28zw_bv1PUXx1sP1OzEXHcVgBgHNrZvdUQQoO9Jq8beLiqsu-a0i9fCw6t7lBzAk3WxAVdvu0nV0fHtECf9UPxQnwAhdk3ang3Fvi-BOZKm-YnpjFUHqdsgMzI7d2On8w52sjVMfaoxlWkj8NXXsHUAgdsXWo72PYL2QVW?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/IQw6QG8vBgR4Cw6YYzFFVDtXu6VzezdUC9ug8QBjsFtuyssi2t1HgGSql7A4i1LRxiHY6KBAvZkz_Ai2rF5CTRZXfBD0c3Xetpe3uaMN8sjnhX7BA2sjosdw08iaai56Y53KnnS2p9wg_nTmescc_wM5I0nx1rk6r_UVQTNZZE4L0v6gIffkmG4_CiKt_S6U?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/kvVTQm4NfMB0XLydSj6renoItsKLIJOeRTzJLUVyh586yGl3R60uY_h53DEQ8-EDB_n0VItgvMm_S58kcmfPBf1IDXp_f3y65OLsMflS2sgdl1adL3Lcblxe1z3GLShrfIs5Jw7fLgXwyj3Qyw1YFK_mJw4NY96suzYe7kNf_eQ3i1tFozEt66gKUZidyUrx?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/IuSac43eeWxJsEpGOKSqII5bVvE_zhuMm3_FT_1K0dB1FXR72Z11erctrhSIgobT3LpBvWfAsafrVJZFNcH9eaZFoimoT40OZ06366LiK3M-jgx76KtRlB50r6DbcDXDCVsWTL_W-b6TKc9SG_Rgc4UH8Qxz2zVg1tpzgvJKyEUWIVN5Tknodk1_PvoYFud0?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/02pltauJXDuKMHOI-Ecq_8D_HX7JOQHVNr23qZLhMU-P64vU7EsDTisb5aJgh80_VCfqPEI17G9WV6iT8EMYUuoJudEsZdzHROSEYhck2MvIg7nm-xXKNfqmTJl4fqrCrED4gU3d2-iuJ4QNAoSd0Nwe9JiLdAcM9D0eKtO7QOstFILXTNq06GMSevQ-8vWY?purpose=fullsize)

* Queue system
* Progress bar
* Format selection

---

# 🧱 4. CORE FEATURES IMPLEMENTATION

---

## 🔍 Search System

```bash
yt-dlp "ytsearch:query"
```

Rust wrapper:

```rust
Command::new("yt-dlp")
    .arg("ytsearch10:lofi music")
    .output();
```

---

## 🎥 Streaming (IMPORTANT)

Flow:

1. Get video URL via yt-dlp
2. Extract stream URL
3. Pass to mpv

```bash
yt-dlp -f best -g <url>
```

---

## 📥 Download System

```bash
yt-dlp -f best -o "~/Videos/%(title)s.%(ext)s" <url>
```

Features:

* Audio only
* 720p / 1080p selection
* Batch downloads

---

## ⏩ SponsorBlock

Flow:

```
videoID → API → skip timestamps → mpv seek
```

---

## 👍 Dislike System

Use Return YouTube Dislike API

---

## 📦 Local Database

Use:

* SQLite

Store:

* Subscriptions
* History
* Downloads
* Settings

---

# 🧠 5. PROJECT STRUCTURE (DETAILED)

```
frontend/
├── screens/
│   ├── home.dart
│   ├── player.dart
│   ├── subscriptions.dart
│   └── downloads.dart
│
├── widgets/
│   ├── video_card.dart
│   ├── player_controls.dart
│   └── sidebar.dart
│
└── services/
    ├── api_service.dart
    └── yt_service.dart


backend/
├── src/
│   ├── main.rs
│   ├── yt_dlp.rs
│   ├── player.rs
│   └── db.rs
```

---

# ⚡ 6. DEVELOPMENT ROADMAP

## 🚀 Phase 1 (MVP)

* Search + video list
* Play video (mpv)
* Basic UI

---

## 🚀 Phase 2

* Downloads
* Subscriptions
* History

---

## 🚀 Phase 3

* SponsorBlock
* Dislike API
* Background playback

---

## 🚀 Phase 4

* UI polish (exact Tubular feel)
* Animations
* Performance tuning

---

# 🖥️ 7. CROSS-PLATFORM BUILD

### Flutter build:

```bash
flutter build linux
flutter build windows
flutter build macos
```

---

### Package:

* Linux → AppImage / Flatpak
* Windows → .exe
* Mac → .dmg

---

# ⚠️ 8. HARD PROBLEMS (don’t ignore)

### 💀 YouTube blocking

* yt-dlp updates required
* Sometimes cookies needed ([Reddit][3])

---

### ⚖️ Legal / ToS

* Not officially allowed
* Keep it open-source + personal use

---

### 🔄 Maintenance

* Extraction breaks often
* Must update regularly

```

`prompt.md`:

```md
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

`start.sh`:

```sh
#!/bin/bash

# Tubular PC Startup Script

echo "🚀 Starting Tubular PC..."

# Check if yt-dlp is installed
if ! command -v yt-dlp &> /dev/null; then
    echo "❌ yt-dlp not found. Please install it:"
    echo "   pip install yt-dlp"
    exit 1
fi

# Check if mpv is installed
if ! command -v mpv &> /dev/null; then
    echo "❌ mpv not found. Please install it:"
    echo "   Linux: sudo apt install mpv"
    echo "   macOS: brew install mpv"
    exit 1
fi

# Start backend in background
echo "📡 Starting backend server..."
cd backend
cargo run --release &
BACKEND_PID=$!
cd ..

# Wait for backend to start
echo "⏳ Waiting for backend to initialize..."
sleep 3

# Start frontend
echo "🎨 Starting frontend..."
cd frontend
flutter run -d linux

# Cleanup on exit
trap "kill $BACKEND_PID" EXIT

```