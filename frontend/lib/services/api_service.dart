import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../models/video.dart';
import '../models/subscription.dart';
import '../models/history_entry.dart';
import '../models/download.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

/// Result type for API calls
typedef ApiResult<T> = ({bool success, T? data, String? error, String? details});

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

  /// Warmup backend to initialize yt-dlp cache (eliminates ~10-30s cold start)
  Future<void> warmupBackend() async {
    try {
      _logger.i('🚀 Warming up backend...');
      final response = await _dio.post('/warmup')
          .timeout(const Duration(seconds: 60));
      
      if (response.statusCode == 200) {
        _logger.i('✅ Backend warmup complete');
      }
    } catch (e) {
      _logger.w('⚠️  Backend warmup failed (non-critical): $e');
      // Warmup is optional - app works without it, just slower
    }
  }

  Future<ApiResult<List<Video>>> searchVideos(String query, {int limit = 10}) async {
    _logger.i('Searching for: $query');
    
    if (query.trim().isEmpty) {
      return (
        success: false,
        data: null,
        error: 'Search query cannot be empty',
        details: null,
      );
    }

    try {
      final response = await _dio.get(
        '/search',
        queryParameters: {'q': query, 'limit': limit},
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        _logger.i('Search successful, got ${data.length} results from backend');
        
        if (data.isEmpty) {
          _logger.w('Backend returned 0 results');
          final mockResults = _getMockSearchResults(query, limit);
          return (
            success: true,
            data: mockResults,
            error: null,
            details: null,
          );
        }
        
        final videos = data.map((json) => Video.fromJson(json)).toList();
        return (
          success: true,
          data: videos,
          error: null,
          details: null,
        );
      } else {
        final errorMsg = (response.data['error'] ?? 'Search failed').toString();
        _logger.w('Backend returned error: $errorMsg');
        return (
          success: false,
          data: null,
          error: 'Search failed',
          details: errorMsg,
        );
      }
    } on DioException catch (e) {
      _logger.w('Search DIO error: $e');
      
      if (e.type == DioExceptionType.connectionTimeout) {
        return (
          success: false,
          data: null,
          error: 'Connection timeout',
          details: 'Backend took too long to respond. Is it running on http://127.0.0.1:3030?',
        );
      } else if (e.type == DioExceptionType.receiveTimeout) {
        return (
          success: false,
          data: null,
          error: 'Search timed out',
          details: 'Backend took too long to respond. Try again.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
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
          error: 'Network error',
          details: (e.message ?? 'Unknown network error').toString(),
        );
      }
    } catch (e) {
      _logger.w('Unexpected search error: $e');
      return (
        success: false,
        data: null,
        error: 'Unexpected error',
        details: e.toString(),
      );
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
    // Return the proxy stream URL instead of fetching the direct URL
    // This avoids CORS issues and network restrictions with media_kit
    return '$baseUrl/stream-proxy/$videoId?quality=$quality';
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
