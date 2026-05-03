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
