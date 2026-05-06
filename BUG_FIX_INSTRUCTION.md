# Tubular-PC Bug Fix Instructions 🐛➡️✅

**Last Updated**: 2026-05-06  
**Project**: Tubular PC Desktop  
**Difficulty**: Beginner to Intermediate

---

## 📋 Quick Reference

| Priority | Bug | Difficulty | Time | Status |
|----------|-----|-----------|------|--------|
| 🔴 P0 | yt-dlp Process Timeout | Medium | 30 min | [ ] |
| 🔴 P0 | Error UI Feedback | Easy | 45 min | [ ] |
| 🔴 P0 | Player Race Condition | Medium | 40 min | [ ] |
| 🟠 P1 | Image Caching | Easy | 25 min | [ ] |
| 🟠 P1 | Loading Indicators | Easy | 35 min | [ ] |
| 🟠 P1 | JSON Validation | Medium | 30 min | [ ] |
| 🟠 P2 | DB Connection Pool | Hard | 45 min | [ ] |
| 🟠 P2 | Rate Limiting | Medium | 40 min | [ ] |

---

# 🔴 PRIORITY 0 - CRITICAL BUGS

## Bug #1: yt-dlp Process Timeout (No Subprocess Timeout)

### 📌 Problem
- yt-dlp subprocess can hang indefinitely if network issues occur
- Backend becomes unresponsive, entire app freezes
- No way to kill hung processes

### 📂 File to Edit
`backend/src/yt_dlp.rs`

### 🔧 Fix Steps

#### Step 1: Add timeout dependency to Cargo.toml
```bash
# Open: backend/Cargo.toml
# Find the [dependencies] section
# Add this line:
```

**Location**: After existing dependencies like `tokio =`

```toml
tokio = { version = "1", features = ["full"] }
tokio-util = "0.7"  # ← ADD THIS
```

#### Step 2: Replace the search function with timeout handling

**Find this code**:
```rust
pub async fn search_videos(query: &str, limit: u32) -> Result<Vec<Video>> {
    let output = Command::new("yt-dlp")
        .args(&[...])
        .output()
        .await?;
```

**Replace with**:
```rust
use tokio::time::{timeout, Duration};

pub async fn search_videos(query: &str, limit: u32) -> Result<Vec<Video>> {
    // Set 30 second timeout for search
    let search_future = async {
        Command::new("yt-dlp")
            .args(&[
                "ytsearch:".to_string() + query,
                "--dump-json",
                "--skip-download",
                &format!("--playlist-items=1-{}", limit),
            ])
            .output()
    };

    let output = match timeout(Duration::from_secs(30), search_future).await {
        Ok(Ok(output)) => output,
        Ok(Err(e)) => {
            eprintln!("❌ yt-dlp command failed: {}", e);
            return Err(format!("Search failed: {}", e).into());
        }
        Err(_) => {
            eprintln!("❌ yt-dlp timeout after 30 seconds");
            return Err("Search timed out - yt-dlp taking too long".into());
        }
    };

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        eprintln!("❌ yt-dlp error: {}", stderr);
        return Err(format!("yt-dlp error: {}", stderr).into());
    }

    parse_yt_dlp_output(&String::from_utf8(output.stdout)?)
}
```

#### Step 3: Test the fix
```bash
cd backend
cargo build
cargo test

# Manual test with timeout:
# Start the app and intentionally disconnect internet
# Search should timeout with error message instead of hanging
```

### ✅ Verification
- [ ] App doesn't freeze on slow network
- [ ] Error message appears after 30 seconds
- [ ] Can still use other features after timeout
- [ ] No zombie processes in Task Manager

---

## Bug #2: No Error UI Feedback (Search/API Failures Show Nothing)

### 📌 Problem
- When API fails, user sees blank screen or frozen UI
- No indication that search failed
- No way to retry

### 📂 Files to Edit
1. `frontend/lib/services/api_service.dart`
2. `frontend/lib/screens/home_screen.dart`
3. `frontend/lib/widgets/error_widget.dart` (create new)

### 🔧 Fix Steps

#### Step 1: Create an Error Widget

**Create new file**: `frontend/lib/widgets/error_widget.dart`

```dart
import 'package:flutter/material.dart';

class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? details;

  const ErrorDisplay({
    Key? key,
    required this.message,
    this.onRetry,
    this.details,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          if (details != null) ...[
            SizedBox(height: 8),
            Text(
              details!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (onRetry != null) ...[
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
            ),
          ]
        ],
      ),
    );
  }
}
```

#### Step 2: Update API Service to return Result types

**Edit**: `frontend/lib/services/api_service.dart`

**Find this**:
```dart
Future<List<Video>> searchVideos(String query) async {
  final response = await http.get(
    Uri.parse('http://localhost:3000/api/search?q=$query'),
  );
  // Parsing...
}
```

**Replace with**:
```dart
import 'package:flutter/foundation.dart';

typedef ApiResult<T> = ({bool success, T? data, String? error, String? details});

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  static const Duration timeout = Duration(seconds: 30);

  Future<ApiResult<List<Video>>> searchVideos(String query) async {
    try {
      if (query.trim().isEmpty) {
        return (
          success: false,
          data: null,
          error: 'Search query cannot be empty',
          details: null,
        );
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/search?q=${Uri.encodeComponent(query)}'),
          )
          .timeout(timeout, onTimeout: () {
            throw TimeoutException('Search request took too long');
          });

      if (response.statusCode == 200) {
        try {
          final jsonData = jsonDecode(response.body);
          final videos = (jsonData['results'] as List)
              .map((v) => Video.fromJson(v))
              .toList();

          return (
            success: true,
            data: videos,
            error: null,
            details: null,
          );
        } catch (e) {
          return (
            success: false,
            data: null,
            error: 'Failed to parse search results',
            details: e.toString(),
          );
        }
      } else if (response.statusCode == 503) {
        return (
          success: false,
          data: null,
          error: 'Backend server is not running',
          details: 'Make sure the backend is started: cargo run',
        );
      } else {
        return (
          success: false,
          data: null,
          error: 'Search failed with status ${response.statusCode}',
          details: response.body,
        );
      }
    } on SocketException catch (e) {
      return (
        success: false,
        data: null,
        error: 'Network error',
        details: 'Cannot connect to backend server. Is it running?',
      );
    } on TimeoutException catch (e) {
      return (
        success: false,
        data: null,
        error: 'Search timed out',
        details: 'Backend took too long to respond. Try again.',
      );
    } catch (e) {
      return (
        success: false,
        data: null,
        error: 'Unexpected error',
        details: e.toString(),
      );
    }
  }

  // Similar pattern for other API methods:
  Future<ApiResult<Video>> getVideoInfo(String videoId) async {
    // ... same pattern
  }

  Future<ApiResult<bool>> addToHistory(String videoId) async {
    // ... same pattern
  }
}
```

#### Step 3: Update Home Screen to use error display

**Edit**: `frontend/lib/screens/home_screen.dart`

**Find this**:
```dart
class _HomeScreenState extends State<HomeScreen> {
  List<Video> searchResults = [];

  void _searchVideos(String query) async {
    final results = await ApiService().searchVideos(query);
    setState(() {
      searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemBuilder: (context, index) => VideoCard(video: searchResults[index]),
      ),
    );
  }
}
```

**Replace with**:
```dart
class _HomeScreenState extends State<HomeScreen> {
  final apiService = ApiService();
  
  List<Video>? searchResults;
  String? searchError;
  String? searchErrorDetails;
  bool isSearching = false;
  String lastQuery = '';

  void _searchVideos(String query) async {
    if (query.isEmpty) return;

    setState(() {
      isSearching = true;
      lastQuery = query;
      searchError = null;
      searchErrorDetails = null;
    });

    final result = await apiService.searchVideos(query);

    if (mounted) {
      setState(() {
        isSearching = false;
        if (result.success) {
          searchResults = result.data;
          searchError = null;
        } else {
          searchResults = null;
          searchError = result.error;
          searchErrorDetails = result.details;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onSubmitted: _searchVideos,
          decoration: InputDecoration(
            hintText: 'Search videos...',
            border: InputBorder.none,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Show loading state
    if (isSearching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Searching for videos...'),
          ],
        ),
      );
    }

    // Show error state
    if (searchError != null) {
      return ErrorDisplay(
        message: searchError!,
        details: searchErrorDetails,
        onRetry: () => _searchVideos(lastQuery),
      );
    }

    // Show results
    if (searchResults != null && searchResults!.isNotEmpty) {
      return ListView.builder(
        itemCount: searchResults!.length,
        itemBuilder: (context, index) {
          return VideoCard(
            video: searchResults![index],
            onTap: () => _playVideo(searchResults![index]),
          );
        },
      );
    }

    // Show empty state
    if (searchResults != null && searchResults!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No videos found'),
            SizedBox(height: 8),
            Text('Try a different search query',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );
    }

    // Show initial state
    return Center(
      child: Text('Search for a video to get started'),
    );
  }

  void _playVideo(Video video) {
    // Navigate to player
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerScreen(video: video),
      ),
    );
  }
}
```

#### Step 4: Test the fix
```bash
cd frontend
flutter run

# Test scenarios:
# 1. Stop backend, try to search → should show "Backend server is not running"
# 2. Search for empty query → should show "Search query cannot be empty"
# 3. Valid search → should work normally
# 4. Click retry after error → should re-attempt search
```

### ✅ Verification
- [ ] Error message appears when backend is down
- [ ] Loading spinner shows during search
- [ ] Retry button works
- [ ] Empty state shows when no results
- [ ] Different errors show different messages

---

## Bug #3: Player Race Condition (mpv Process Starts Before Ready)

### 📌 Problem
- Player screen tries to play before mpv process is ready
- Intermittent "player not found" errors
- Sometimes video plays, sometimes doesn't

### 📂 Files to Edit
1. `frontend/lib/controllers/player_controller.dart` (create new)
2. `frontend/lib/screens/player_screen.dart`

### 🔧 Fix Steps

#### Step 1: Create Player Controller with proper initialization

**Create new file**: `frontend/lib/controllers/player_controller.dart`

```dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

enum PlayerState {
  initializing,
  ready,
  playing,
  paused,
  stopped,
  error,
}

class PlayerController extends ChangeNotifier {
  PlayerState _state = PlayerState.initializing;
  String? _errorMessage;
  Process? _playerProcess;
  
  final String videoUrl;
  final String? videoTitle;

  PlayerState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isReady => _state != PlayerState.initializing && _state != PlayerState.error;

  PlayerController({
    required this.videoUrl,
    this.videoTitle,
  });

  /// Initialize the player process
  Future<bool> initialize() async {
    try {
      _setState(PlayerState.initializing);

      // Verify mpv is installed
      final whichResult = await Process.run('which', ['mpv']);
      if (whichResult.exitCode != 0) {
        _setState(PlayerState.error);
        _errorMessage = 'mpv player is not installed.\nInstall with: apt install mpv (Linux) or brew install mpv (macOS)';
        return false;
      }

      // Start mpv process with proper configuration
      _playerProcess = await Process.start(
        'mpv',
        [
          '--title=$videoTitle',
          '--keep-open=yes',  // Keep window open after playback
          '--fullscreen=no',
          '--ytdl=yes',
          videoUrl,
        ],
        mode: ProcessStartMode.detached,
      );

      // Give mpv time to start (max 5 seconds)
      final startupFuture = _waitForPlayerReady();
      final timeoutFuture = Future.delayed(Duration(seconds: 5));

      await Future.any([startupFuture, timeoutFuture]);

      _setState(PlayerState.ready);
      _listenToPlayerProcess();
      return true;

    } catch (e) {
      _setState(PlayerState.error);
      _errorMessage = 'Failed to start player: $e';
      debugPrint('Player initialization error: $e');
      return false;
    }
  }

  /// Wait for mpv to actually be ready (heuristic: window appears)
  Future<void> _waitForPlayerReady() async {
    for (int i = 0; i < 10; i++) {
      await Future.delayed(Duration(milliseconds: 200));
      
      // Check if process is still running
      if (_playerProcess == null || !_playerProcess!.killSignal(ProcessSignal.sigterm)) {
        continue; // Process not responding yet, retry
      }
    }
  }

  /// Listen for player process exit
  void _listenToPlayerProcess() {
    _playerProcess?.exitCode.then((exitCode) {
      if (_state != PlayerState.stopped) {
        _setState(PlayerState.stopped);
        _errorMessage = exitCode == 0 ? null : 'Player exited with code $exitCode';
        notifyListeners();
      }
    }).catchError((e) {
      _setState(PlayerState.error);
      _errorMessage = 'Player error: $e';
      notifyListeners();
    });
  }

  void _setState(PlayerState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  /// Safely terminate player
  Future<void> dispose() async {
    try {
      if (_playerProcess != null) {
        // Send SIGTERM first (graceful shutdown)
        Process.killPid(_playerProcess!.pid, ProcessSignal.sigterm);
        
        // Wait up to 2 seconds for graceful exit
        await _playerProcess!.exitCode.timeout(
          Duration(seconds: 2),
          onTimeout: () {
            // Force kill if not responding
            Process.killPid(_playerProcess!.pid, ProcessSignal.sigkill);
            return 0;
          },
        );
      }
    } catch (e) {
      debugPrint('Error closing player: $e');
    } finally {
      super.dispose();
    }
  }

  void play() {
    _setState(PlayerState.playing);
  }

  void pause() {
    _setState(PlayerState.paused);
  }

  void stop() {
    _setState(PlayerState.stopped);
  }
}
```

#### Step 2: Update Player Screen to use controller

**Edit**: `frontend/lib/screens/player_screen.dart`

**Find this**:
```dart
class PlayerScreen extends StatefulWidget {
  final Video video;

  PlayerScreen({required this.video});

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  @override
  void initState() {
    super.initState();
    _startPlayer();
  }

  void _startPlayer() async {
    // Start mpv process
    Process.start('mpv', [widget.video.url]);
  }
}
```

**Replace with**:
```dart
import 'package:provider/provider.dart';
import 'package:tubular_pc/controllers/player_controller.dart';

class PlayerScreen extends StatefulWidget {
  final Video video;

  const PlayerScreen({Key? key, required this.video}) : super(key: key);

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late PlayerController _playerController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _playerController = PlayerController(
      videoUrl: widget.video.url,
      videoTitle: widget.video.title,
    );

    final success = await _playerController.initialize();

    if (mounted) {
      if (success) {
        _playerController.play();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_playerController.errorMessage ?? 'Player initialization failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.video.title),
        elevation: 0,
      ),
      body: Center(
        child: _buildPlayerContent(),
      ),
    );
  }

  Widget _buildPlayerContent() {
    return ValueListenableBuilder<PlayerState>(
      valueListenable: _playerController,
      builder: (context, state, _) {
        switch (state) {
          case PlayerState.initializing:
            return _buildInitializingState();

          case PlayerState.ready:
          case PlayerState.playing:
            return _buildPlayingState();

          case PlayerState.paused:
            return _buildPausedState();

          case PlayerState.stopped:
            return _buildStoppedState();

          case PlayerState.error:
            return _buildErrorState();
        }
      },
    );
  }

  Widget _buildInitializingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('Initializing player...'),
        SizedBox(height: 8),
        Text(
          'Starting mpv video player',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildPlayingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.play_circle, size: 80, color: Colors.grey[400]),
        SizedBox(height: 16),
        Text('Player window opened'),
        SizedBox(height: 8),
        Text(
          'mpv is playing in a separate window',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        SizedBox(height: 24),
        Text(
          widget.video.title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildPausedState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.pause_circle, size: 80, color: Colors.grey[400]),
        SizedBox(height: 16),
        Text('Player paused'),
      ],
    );
  }

  Widget _buildStoppedState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.stop_circle, size: 80, color: Colors.grey[400]),
        SizedBox(height: 16),
        Text('Playback finished'),
        SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Back'),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 80, color: Colors.red),
        SizedBox(height: 16),
        Text(
          'Player Error',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            _playerController.errorMessage ?? 'An error occurred',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Back'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _playerController.dispose();
    super.dispose();
  }
}
```

#### Step 3: Update pubspec.yaml for ValueListenableBuilder

**Edit**: `frontend/pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0  # Add this for state management
```

Then run:
```bash
cd frontend
flutter pub get
```

#### Step 4: Test the fix
```bash
cd frontend
flutter run

# Test scenarios:
# 1. Click video → should show initializing state
# 2. Wait for player → should show "Player window opened"
# 3. mpv window should appear
# 4. Close mpv → should show "Playback finished"
# 5. Uninstall mpv, try to play → should show install instructions
```

### ✅ Verification
- [ ] Initializing state shows while player starts
- [ ] No race conditions (consistent playback)
- [ ] Error shown if mpv not installed
- [ ] Player window opens successfully
- [ ] Closing player shows stopped state

---

# 🟠 PRIORITY 1 - HIGH PRIORITY BUGS

## Bug #4: Image Caching Not Implemented

### 📌 Problem
- Thumbnail images redownload every scroll
- Heavy bandwidth usage
- Slow scrolling performance
- Network requests on every rebuild

### 📂 File to Edit
`frontend/lib/widgets/video_card.dart`

### 🔧 Fix Steps

#### Step 1: Update pubspec.yaml with caching library

**Edit**: `frontend/pubspec.yaml`

```yaml
dependencies:
  cached_network_image: ^3.3.0  # Add this
```

Run:
```bash
cd frontend
flutter pub get
```

#### Step 2: Replace Image Widget

**Find this in video_card.dart**:
```dart
class VideoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Image.network(
            video.thumbnail,  // ← Problem: Redownloads every time
          ),
          // ...
        ],
      ),
    );
  }
}
```

**Replace with**:
```dart
import 'package:cached_network_image/cached_network_image.dart';

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
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cached thumbnail
            CachedNetworkImage(
              imageUrl: video.thumbnail,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: Icon(Icons.broken_image, color: Colors.grey),
              ),
              progressIndicatorBuilder: (context, url, downloadProgress) {
                return Container(
                  color: Colors.grey[300],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: downloadProgress.progress,
                    ),
                  ),
                );
              },
              fadeInDuration: Duration(milliseconds: 300),
            ),
            // Video info
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  SizedBox(height: 4),
                  Text(
                    video.channel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.visibility, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        _formatViews(video.views),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(Icons.schedule, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        _formatDuration(video.duration),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatViews(int views) {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M views';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K views';
    }
    return '$views views';
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes}m ${secs}s';
  }
}
```

#### Step 3: Test the fix
```bash
cd frontend
flutter run

# Test:
# 1. Search for videos
# 2. Scroll through list
# 3. Check network tab (should cache images)
# 4. Scroll same videos again (should use cache)
# 5. Hot reload - images should load from cache instantly
```

### ✅ Verification
- [ ] Images load faster on second view
- [ ] Loading progress indicator shows
- [ ] Broken images show error icon
- [ ] Smooth scrolling without network requests

---

## Bug #5: No Loading Indicators

### 📌 Problem
- User doesn't know app is doing something
- Looks frozen during slow operations
- Bad UX

### 📂 Files to Edit
All screen files

### 🔧 Fix - Already covered in Bug #2

Use the same pattern shown in Bug #2 for all screens:
- Downloads screen: Show progress during download
- History screen: Show loading while fetching
- Subscriptions screen: Show loading while loading subs

**Example for downloads_screen.dart**:
```dart
class _DownloadsScreenState extends State<DownloadsScreen> {
  List<Download>? downloads;
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadDownloads();
  }

  void _loadDownloads() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final result = await apiService.getDownloads();
      if (mounted) {
        setState(() {
          isLoading = false;
          downloads = result;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return ErrorDisplay(
        message: error!,
        onRetry: _loadDownloads,
      );
    }

    if (downloads == null || downloads!.isEmpty) {
      return Center(child: Text('No downloads'));
    }

    return ListView.builder(
      itemCount: downloads!.length,
      itemBuilder: (context, index) => DownloadCard(
        download: downloads![index],
      ),
    );
  }
}
```

---

## Bug #6: JSON Parsing Without Validation

### 📌 Problem
- One malformed video entry crashes all search results
- No schema validation
- Unsafe JSON decoding

### 📂 File to Edit
`backend/src/yt_dlp.rs`

### 🔧 Fix Steps

#### Step 1: Add serde validation

**Edit**: `backend/Cargo.toml`

```toml
[dependencies]
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
```

#### Step 2: Update Video struct with strict parsing

**Edit**: `backend/src/player.rs` or where Video is defined

**Find this**:
```rust
#[derive(Serialize, Deserialize, Clone)]
pub struct Video {
    pub id: String,
    pub title: String,
    pub thumbnail: String,
    // ...
}
```

**Replace with**:
```rust
#[derive(Serialize, Deserialize, Clone, Debug)]
#[serde(deny_unknown_fields)]  // Reject unknown fields
pub struct Video {
    #[serde(rename = "id")]
    pub id: String,

    #[serde(rename = "title")]
    pub title: String,

    #[serde(rename = "thumbnail", default)]
    pub thumbnail: Option<String>,

    #[serde(rename = "duration", default)]
    pub duration: Option<i32>,

    #[serde(rename = "view_count", default)]
    pub views: Option<i64>,

    #[serde(rename = "uploader", default)]
    pub channel: Option<String>,

    #[serde(rename = "url")]
    pub url: String,

    #[serde(skip_deserializing)]  // Don't parse these
    #[serde(default)]
    pub _extra: serde_json::Value,
}

impl Video {
    /// Safe constructor with validation
    pub fn try_from_json(json: &serde_json::Value) -> Result<Self, String> {
        // Validate required fields
        if !json.get("id").and_then(|v| v.as_str()).is_some() {
            return Err("Missing required field: id".to_string());
        }

        if !json.get("title").and_then(|v| v.as_str()).is_some() {
            return Err("Missing required field: title".to_string());
        }

        if !json.get("url").and_then(|v| v.as_str()).is_some() {
            return Err("Missing required field: url".to_string());
        }

        // Attempt deserialization
        match serde_json::from_value::<Video>(json.clone()) {
            Ok(video) => Ok(video),
            Err(e) => Err(format!("Invalid video data: {}", e)),
        }
    }
}
```

#### Step 3: Update parse function to skip invalid entries

**Edit**: `backend/src/yt_dlp.rs`

**Find this**:
```rust
fn parse_yt_dlp_output(json_str: &str) -> Result<Vec<Video>> {
    let json: Vec<serde_json::Value> = serde_json::from_str(json_str)?;
    let videos: Vec<Video> = json.into_iter()
        .map(|j| serde_json::from_value::<Video>(j).unwrap())
        .collect();
    Ok(videos)
}
```

**Replace with**:
```rust
fn parse_yt_dlp_output(json_str: &str) -> Result<Vec<Video>> {
    let json: Vec<serde_json::Value> = match serde_json::from_str(json_str) {
        Ok(j) => j,
        Err(e) => {
            eprintln!("❌ Failed to parse JSON: {}", e);
            return Err(format!("Invalid JSON from yt-dlp: {}", e).into());
        }
    };

    let mut videos = Vec::new();
    let mut errors = Vec::new();

    for (index, video_json) in json.into_iter().enumerate() {
        match Video::try_from_json(&video_json) {
            Ok(video) => videos.push(video),
            Err(e) => {
                // Log error but continue processing
                eprintln!("⚠️  Skipping video {}: {}", index, e);
                errors.push(format!("Entry {}: {}", index, e));
            }
        }
    }

    if videos.is_empty() && !errors.is_empty() {
        return Err(format!(
            "All {} videos failed to parse. Errors: {}",
            errors.len(),
            errors.join("; ")
        ).into());
    }

    if !errors.is_empty() {
        eprintln!("⚠️  {} videos skipped due to parsing errors", errors.len());
    }

    Ok(videos)
}
```

#### Step 4: Test the fix
```bash
cd backend
cargo test

# Manual test with malformed JSON:
# Create test data with one bad entry
# Verify that good entries still parse
# Check stderr for warning messages
```

### ✅ Verification
- [ ] Single bad video doesn't crash search
- [ ] Error logged for bad entries
- [ ] Good videos still display
- [ ] Error message doesn't show to user

---

# 🟠 PRIORITY 2 - MEDIUM PRIORITY BUGS

## Bug #7: Database Connection Pooling

### 📌 Problem
- No connection pooling in SQLite
- Each request creates new connection
- Potential deadlocks with concurrent access
- Slow database operations

### 📂 File to Edit
`backend/src/db.rs`

### 🔧 Fix Steps

#### Step 1: Add connection pool dependency

**Edit**: `backend/Cargo.toml`

```toml
[dependencies]
r2d2 = "0.8"
r2d2_sqlite = "0.25"
rusqlite = { version = "0.31", features = ["bundled"] }
```

#### Step 2: Create connection pool

**Replace entire db.rs**:

```rust
use r2d2::Pool;
use r2d2_sqlite::SqliteConnectionManager;
use rusqlite::Connection;
use std::sync::Arc;
use tokio::sync::Mutex;

pub type DbPool = Arc<Pool<SqliteConnectionManager>>;

pub struct Database {
    pool: DbPool,
}

impl Database {
    /// Initialize database connection pool
    pub fn new(db_path: &str) -> Result<Self, Box<dyn std::error::Error>> {
        // Create pool manager
        let manager = SqliteConnectionManager::file(db_path)
            .init_flags(rusqlite::OpenFlags::SQLITE_OPEN_READ_WRITE 
                | rusqlite::OpenFlags::SQLITE_OPEN_CREATE);

        // Create pool with 5 connections
        let pool = Pool::new(manager)?;

        // Initialize schema
        {
            let conn = pool.get()?;
            Self::init_schema(&conn)?;
        }

        Ok(Self {
            pool: Arc::new(pool),
        })
    }

    /// Initialize database schema
    fn init_schema(conn: &Connection) -> Result<(), Box<dyn std::error::Error>> {
        conn.execute_batch(
            r#"
            CREATE TABLE IF NOT EXISTS videos (
                id TEXT PRIMARY KEY,
                title TEXT NOT NULL,
                channel TEXT,
                thumbnail TEXT,
                duration INTEGER,
                views INTEGER,
                url TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );

            CREATE TABLE IF NOT EXISTS history (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                video_id TEXT NOT NULL,
                watched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                position_seconds INTEGER DEFAULT 0,
                FOREIGN KEY (video_id) REFERENCES videos(id)
            );

            CREATE INDEX IF NOT EXISTS idx_history_video ON history(video_id);
            CREATE INDEX IF NOT EXISTS idx_history_watched ON history(watched_at);

            CREATE TABLE IF NOT EXISTS subscriptions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                channel_id TEXT NOT NULL,
                channel_name TEXT NOT NULL,
                subscribed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                UNIQUE(channel_id)
            );

            CREATE INDEX IF NOT EXISTS idx_subs_channel ON subscriptions(channel_id);

            CREATE TABLE IF NOT EXISTS downloads (
                id TEXT PRIMARY KEY,
                video_id TEXT NOT NULL,
                title TEXT NOT NULL,
                path TEXT NOT NULL,
                status TEXT DEFAULT 'downloading',
                progress REAL DEFAULT 0,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (video_id) REFERENCES videos(id)
            );

            CREATE INDEX IF NOT EXISTS idx_downloads_status ON downloads(status);
            "#,
        )?;

        Ok(())
    }

    /// Get a connection from the pool
    pub fn get_connection(&self) -> Result<r2d2::PooledConnection<SqliteConnectionManager>, Box<dyn std::error::Error>> {
        Ok(self.pool.get()?)
    }

    /// Save video to database
    pub fn save_video(&self, video: &crate::player::Video) -> Result<(), Box<dyn std::error::Error>> {
        let conn = self.get_connection()?;

        conn.execute(
            "INSERT OR REPLACE INTO videos (id, title, channel, thumbnail, duration, views, url)
             VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)",
            [
                &video.id,
                &video.title,
                &video.channel.clone().unwrap_or_default(),
                &video.thumbnail.clone().unwrap_or_default(),
                &video.duration.map(|d| d.to_string()).unwrap_or_default(),
                &video.views.map(|v| v.to_string()).unwrap_or_default(),
                &video.url,
            ],
        )?;

        Ok(())
    }

    /// Get watch history
    pub fn get_history(&self, limit: usize) -> Result<Vec<crate::player::Video>, Box<dyn std::error::Error>> {
        let conn = self.get_connection()?;

        let mut stmt = conn.prepare(
            "SELECT v.id, v.title, v.channel, v.thumbnail, v.duration, v.views, v.url
             FROM videos v
             INNER JOIN history h ON v.id = h.video_id
             ORDER BY h.watched_at DESC
             LIMIT ?1"
        )?;

        let videos = stmt.query_map([limit as i32], |row| {
            Ok(crate::player::Video {
                id: row.get(0)?,
                title: row.get(1)?,
                channel: row.get(2)?,
                thumbnail: row.get(3)?,
                duration: row.get(4)?,
                views: row.get(5)?,
                url: row.get(6)?,
                _extra: Default::default(),
            })
        })?;

        let mut results = Vec::new();
        for video in videos {
            results.push(video?);
        }

        Ok(results)
    }

    /// Add to watch history
    pub fn add_to_history(&self, video_id: &str) -> Result<(), Box<dyn std::error::Error>> {
        let conn = self.get_connection()?;

        // Save video first
        if let Err(_) = conn.execute(
            "INSERT INTO history (video_id) VALUES (?1)",
            [video_id],
        ) {
            // Ignore duplicate errors
        }

        Ok(())
    }

    /// Get subscriptions
    pub fn get_subscriptions(&self) -> Result<Vec<(String, String)>, Box<dyn std::error::Error>> {
        let conn = self.get_connection()?;

        let mut stmt = conn.prepare(
            "SELECT channel_id, channel_name FROM subscriptions ORDER BY subscribed_at DESC"
        )?;

        let subs = stmt.query_map([], |row| {
            Ok((row.get(0)?, row.get(1)?))
        })?;

        let mut results = Vec::new();
        for sub in subs {
            results.push(sub?);
        }

        Ok(results)
    }

    /// Add subscription
    pub fn add_subscription(&self, channel_id: &str, channel_name: &str) -> Result<(), Box<dyn std::error::Error>> {
        let conn = self.get_connection()?;

        conn.execute(
            "INSERT OR IGNORE INTO subscriptions (channel_id, channel_name) VALUES (?1, ?2)",
            [channel_id, channel_name],
        )?;

        Ok(())
    }

    /// Delete subscription
    pub fn remove_subscription(&self, channel_id: &str) -> Result<(), Box<dyn std::error::Error>> {
        let conn = self.get_connection()?;

        conn.execute(
            "DELETE FROM subscriptions WHERE channel_id = ?1",
            [channel_id],
        )?;

        Ok(())
    }

    /// Clean up old history entries (keep last 500)
    pub fn cleanup_history(&self) -> Result<(), Box<dyn std::error::Error>> {
        let conn = self.get_connection()?;

        conn.execute(
            "DELETE FROM history WHERE id NOT IN (
                SELECT id FROM history ORDER BY watched_at DESC LIMIT 500
            )",
            [],
        )?;

        Ok(())
    }
}
```

#### Step 3: Update main.rs to use pool

**Edit**: `backend/src/main.rs`

**Add to start of main function**:
```rust
// Initialize database with connection pool
let db = Database::new("~/.local/share/tubular-pc/data.db")
    .expect("Failed to initialize database");

// Run cleanup periodically
tokio::spawn({
    let db = db.clone();
    async move {
        loop {
            tokio::time::sleep(Duration::from_secs(3600)).await; // Every hour
            if let Err(e) = db.cleanup_history() {
                eprintln!("Warning: Failed to cleanup history: {}", e);
            }
        }
    }
});
```

### ✅ Verification
- [ ] Database uses connection pool
- [ ] Multiple concurrent requests don't deadlock
- [ ] No "database is locked" errors
- [ ] Old history cleaned up automatically

---

## Bug #8: Rate Limiting for External APIs

### 📌 Problem
- No rate limiting on SponsorBlock API
- No rate limiting on Return YouTube Dislike API
- Can get IP banned from external services
- Unlimited requests hammer free APIs

### 📂 File to Edit
`backend/src/api.rs`

### 🔧 Fix Steps

#### Step 1: Add rate limiting dependency

**Edit**: `backend/Cargo.toml`

```toml
[dependencies]
governor = "0.10"  # Rate limiting library
```

#### Step 2: Create rate limiter module

**Create new file**: `backend/src/rate_limiter.rs`

```rust
use governor::{Quota, RateLimiter};
use std::num::NonZeroU32;

pub struct ApiLimiter {
    sponsorblock: RateLimiter,
    dislike: RateLimiter,
    yt_dlp: RateLimiter,
}

impl ApiLimiter {
    pub fn new() -> Self {
        Self {
            // SponsorBlock: 100 requests per minute
            sponsorblock: RateLimiter::direct(Quota::per_minute(NonZeroU32::new(100).unwrap())),
            
            // Return YouTube Dislike: 60 requests per minute
            dislike: RateLimiter::direct(Quota::per_minute(NonZeroU32::new(60).unwrap())),
            
            // yt-dlp: 30 requests per minute (local, but be nice)
            yt_dlp: RateLimiter::direct(Quota::per_minute(NonZeroU32::new(30).unwrap())),
        }
    }

    pub fn check_sponsorblock(&self) -> Result<(), Box<dyn std::error::Error>> {
        self.sponsorblock.check().map_err(|e| format!("Rate limit: SponsorBlock ({})", e).into())
    }

    pub fn check_dislike(&self) -> Result<(), Box<dyn std::error::Error>> {
        self.dislike.check().map_err(|e| format!("Rate limit: Return YouTube Dislike ({})", e).into())
    }

    pub fn check_yt_dlp(&self) -> Result<(), Box<dyn std::error::Error>> {
        self.yt_dlp.check().map_err(|e| format!("Rate limit: yt-dlp ({})", e).into())
    }
}
```

#### Step 3: Use rate limiter in API calls

**Edit**: `backend/src/sponsorblock.rs`

**Find this**:
```rust
pub async fn get_segments(video_id: &str) -> Result<Vec<Segment>> {
    let url = format!("https://sponsor.ajay.app/api/skipSegments?videoID={}", video_id);
    let response = reqwest::get(&url).await?;
    // ...
}
```

**Replace with**:
```rust
use crate::rate_limiter::ApiLimiter;
use once_cell::sync::Lazy;

static LIMITER: Lazy<ApiLimiter> = Lazy::new(ApiLimiter::new);

pub async fn get_segments(video_id: &str) -> Result<Vec<Segment>> {
    // Check rate limit first
    LIMITER.check_sponsorblock()?;

    let url = format!("https://sponsor.ajay.app/api/skipSegments?videoID={}", video_id);
    let response = match reqwest::get(&url).await {
        Ok(r) => r,
        Err(e) => {
            eprintln!("❌ SponsorBlock request failed: {}", e);
            return Err(format!("Failed to fetch segments: {}", e).into());
        }
    };

    if !response.status().is_success() {
        eprintln!("⚠️  SponsorBlock API error: {}", response.status());
        return Err(format!("SponsorBlock error: {}", response.status()).into());
    }

    // ... rest of parsing
}
```

**Do the same for Return YouTube Dislike**:
```rust
pub async fn get_dislikes(video_id: &str) -> Result<DislikeData> {
    LIMITER.check_dislike()?;

    let url = format!("https://returnyoutubedislikeapi.com/votes?id={}", video_id);
    // ... rest of implementation
}
```

#### Step 4: Add rate limit error handling to frontend

**Edit**: `frontend/lib/services/api_service.dart`

```dart
Future<ApiResult<DislikeData>> getDislikes(String videoId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/video/$videoId/dislikes'),
    ).timeout(timeout);

    if (response.statusCode == 429) {  // Too Many Requests
      return (
        success: false,
        data: null,
        error: 'Rate limited',
        details: 'Too many requests. Please try again later.',
      );
    }

    // ... rest of error handling
  } catch (e) {
    // ...
  }
}
```

#### Step 5: Test the fix
```bash
cd backend
cargo build
cargo test

# Manual test:
# 1. Make rapid requests to /api/video/xxx/segments
# 2. Should get rate limit error after threshold
# 3. Wait a minute, should work again
```

### ✅ Verification
- [ ] Rate limiting enforced per API
- [ ] Error message when limit reached
- [ ] Can retry after timeout
- [ ] No IP bans from external services

---

# 📋 Testing Checklist

After fixing each bug, run these tests:

```bash
# Backend
cd backend
cargo fmt
cargo clippy
cargo test
cargo build --release

# Frontend
cd frontend
flutter format .
flutter analyze
flutter test
flutter run

# Integration test
# 1. Start backend: cargo run
# 2. Start frontend: flutter run
# 3. Test all screens
# 4. Test search, playback, downloads
# 5. Check error handling
```

---

# 🚀 Quick Start Guide to Fixes

### Do these in order:

1. **Bug #1** (yt-dlp timeout) - 30 min
   ```bash
   cd backend
   # Edit Cargo.toml: add tokio-util
   # Edit src/yt_dlp.rs: add timeout to search_videos()
   cargo test
   ```

2. **Bug #2** (Error UI) - 45 min
   ```bash
   cd frontend
   # Create lib/widgets/error_widget.dart
   # Edit lib/services/api_service.dart: return ApiResult
   # Edit lib/screens/home_screen.dart: use error display
   flutter run
   ```

3. **Bug #3** (Player race condition) - 40 min
   ```bash
   cd frontend
   # Create lib/controllers/player_controller.dart
   # Edit lib/screens/player_screen.dart: use controller
   flutter run
   ```

4. **Bug #4** (Image caching) - 25 min
   ```bash
   cd frontend
   # Edit pubspec.yaml: add cached_network_image
   # Edit lib/widgets/video_card.dart: use CachedNetworkImage
   flutter pub get && flutter run
   ```

5. **Bug #5** (Loading indicators) - 35 min
   ```bash
   # Apply loading pattern to all screens
   # Use the pattern from Bug #2
   ```

6. **Bug #6** (JSON validation) - 30 min
   ```bash
   cd backend
   # Edit Cargo.toml: ensure serde enabled
   # Edit src/player.rs: add Video::try_from_json()
   # Edit src/yt_dlp.rs: use try_from_json in parser
   cargo test
   ```

7. **Bug #7** (Connection pooling) - 45 min
   ```bash
   cd backend
   # Edit Cargo.toml: add r2d2, r2d2_sqlite
   # Rewrite src/db.rs with pool
   # Edit src/main.rs: initialize pool
   cargo test
   ```

8. **Bug #8** (Rate limiting) - 40 min
   ```bash
   cd backend
   # Edit Cargo.toml: add governor
   # Create src/rate_limiter.rs
   # Edit src/sponsorblock.rs: use limiter
   # Edit src/returnyoutubedislike.rs: use limiter
   cargo test
   ```

---

# 💡 Pro Tips

### Testing locally
```bash
# Terminal 1: Backend
cd backend && RUST_LOG=debug cargo run

# Terminal 2: Frontend
cd frontend && flutter run -v

# Terminal 3: Check processes
ps aux | grep -E "(cargo|flutter|mpv)"
```

### Debug Flutter network calls
```dart
// Add to your api_service.dart
import 'package:http/http.dart' as http;

// Wrap http client
class LoggingHttpClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    print('→ ${request.method} ${request.url}');
    final response = await super.send(request);
    print('← ${response.statusCode} ${response.contentLength} bytes');
    return response;
  }
}

// Use it
final httpClient = LoggingHttpClient();
```

### Debug Rust database
```rust
// Add to your db.rs
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_database_pool() {
        let db = Database::new(":memory:").unwrap();
        let conn = db.get_connection().unwrap();
        assert!(conn.execute("SELECT 1", []).is_ok());
    }
}
```

---

# 📚 References

- [yt-dlp Documentation](https://github.com/yt-dlp/yt-dlp)
- [Tokio Timeout](https://tokio.rs/tokio/tutorial/select#timeout)
- [r2d2 Connection Pool](https://github.com/sfackler/r2d2)
- [Flutter Cached Network Image](https://pub.dev/packages/cached_network_image)
- [Governor Rate Limiting](https://github.com/bheisler/governor)
- [SponsorBlock API Docs](https://wiki.sponsor.ajay.app/w/API_Docs)

---

**Happy fixing! 🚀🐛✨**

If you get stuck on any bug, check the error message carefully - it usually tells you exactly what's wrong!
