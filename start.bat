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
