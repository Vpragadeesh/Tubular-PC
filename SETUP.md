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
