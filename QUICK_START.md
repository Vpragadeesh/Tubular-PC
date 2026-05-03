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
