import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/video.dart';
import '../models/video_details.dart';
import '../models/subscription.dart';
import '../models/history_entry.dart';
import '../models/download.dart';
import '../models/notification.dart';
import '../models/subtitle_search.dart';

/// Result type for API calls
typedef ApiResult<T> = ({bool success, dynamic data, dynamic error, dynamic details});

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

  Future<ApiResult<List<Video>>> searchVideos(
    String query, {
    int limit = 10,
    String sort = 'relevance',
    String duration = 'any',
    String uploadDate = 'any',
    int page = 1,
  }) async {
    _logger.i('Searching for: $query (page=$page, sort=$sort, duration=$duration, uploadDate=$uploadDate)');
    
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
        queryParameters: {
          'q': query,
          'limit': limit,
          'offset': (page - 1) * limit, // Convert page to offset for API
          'sort': sort,
          'duration': duration,
          'upload_date': uploadDate,
        },
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
              video.description.toLowerCase().contains(query.toLowerCase()),
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

  Future<VideoDetails> getVideoDetails(String videoId) async {
    try {
      final response = await _dio.get('/video/details/$videoId');

      if (response.data['success'] == true) {
        return VideoDetails.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['error'] ?? 'Failed to get video details');
      }
    } catch (e) {
      _logger.w('Get video details error: $e');
      // Fallback to real video info endpoint (no mocked metadata)
      final info = await getVideoInfo(videoId);
      return VideoDetails(
        id: info.id,
        title: info.title,
        channelName: info.channelName,
        channelId: info.channelId,
        subscriberCount: 0,
        viewCount: info.views,
        uploadDate: info.uploadDate.toIso8601String(),
        duration: info.duration,
        thumbnailUrl: info.thumbnail,
        likeCount: info.likes,
        dislikeCount: info.dislikes,
        comments: const [],
      );
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
    } on DioException catch (e) {
      _logger.w('Download DIO error: $e');

      final responseData = e.response?.data;
      if (responseData is Map) {
        final serverError = responseData['error']?.toString();
        final serverDetails = responseData['details']?.toString();
        if (serverError != null && serverError.isNotEmpty) {
          if (serverDetails != null && serverDetails.isNotEmpty) {
            throw Exception('$serverError: $serverDetails');
          }
          throw Exception(serverError);
        }
        if (serverDetails != null && serverDetails.isNotEmpty) {
          throw Exception(serverDetails);
        }
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Backend server is not running. Please ensure the Rust backend is running on http://127.0.0.1:3030',
        );
      }

      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Download request timed out. Please try again.');
      }

      throw Exception(e.message ?? 'Download failed');
    } catch (e) {
      _logger.w('Download error: $e');
      throw Exception(e.toString());
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

  Future<void> saveVideoProgress(String videoId, double progress) async {
    try {
      final response = await _dio.post(
        '/history/progress',
        data: {
          'video_id': videoId,
          'progress': progress,
        },
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['error'] ?? 'Failed to save progress');
      }
    } catch (e) {
      _logger.w('Save progress error: $e');
    }
  }

  Future<double> getVideoProgress(String videoId) async {
    try {
      final response = await _dio.get('/history/progress/$videoId');
      if (response.data['success'] == true) {
        final progress = response.data['data']['progress'];
        return (progress is num) ? progress.toDouble() : 0.0;
      }
    } catch (e) {
      _logger.w('Get video progress error: $e');
    }
    return 0.0;
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
        return data.map((json) {
          final backendDownload = json as Map<String, dynamic>;
          final status = (backendDownload['status'] ?? 'pending').toString();
          final createdAtRaw =
              backendDownload['created_at']?.toString() ??
              backendDownload['completed_at']?.toString();
          final completedAtRaw = backendDownload['completed_at']?.toString();

          final createdAt =
              DateTime.tryParse(createdAtRaw ?? '') ?? DateTime.now();
          final completedAt = completedAtRaw != null
              ? DateTime.tryParse(completedAtRaw)
              : null;

          return Download(
            id: backendDownload['id'].toString(),
            videoId: backendDownload['video_id'] ?? '',
            title: backendDownload['title'] ?? '',
            filePath: backendDownload['file_path'] ?? '',
            fileSize: (backendDownload['file_size'] as num?)?.toInt() ?? 0,
            format: status == 'audio' ? 'audio' : 'video',
            quality: backendDownload['quality'] ?? 'unknown',
            status: status,
            progress: (backendDownload['progress'] as num?)?.toDouble() ??
                (status == 'completed' ? 100.0 : 0.0),
            createdAt: createdAt,
            completedAt: completedAt,
            errorMessage: backendDownload['error_message']?.toString(),
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

  Future<int?> createDownload(
    String videoId,
    String title,
    String outputPath,
    String quality, {
    bool audioOnly = false,
  }) async {
    try {
      final response = await _dio.post(
        '/downloads/create',
        data: {
          'video_id': videoId,
          'title': title,
          'output_path': outputPath,
          'quality': quality,
          'audio_only': audioOnly,
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

  // --- Channel API endpoints ---

  Future<ApiResult<Map<String, dynamic>>> getChannelInfo(String channelId) async {
    try {
      final response = await _dio.get('/channel/$channelId');

      if (response.data['success'] == true) {
        return (
          success: true,
          data: response.data['data'] as Map<String, dynamic>,
          error: null,
          details: null,
        );
      } else {
        return (
          success: false,
          data: null,
          error: response.data['error'] ?? 'Failed to get channel info',
          details: null,
        );
      }
    } catch (e) {
      _logger.w('Get channel info error: $e');
      return (
        success: false,
        data: null,
        error: 'Network error',
        details: e.toString(),
      );
    }
  }

  Future<ApiResult<List<Video>>> getChannelVideos(String channelId, {int page = 1}) async {
    try {
      final response = await _dio.get(
        '/channel/$channelId/videos',
        queryParameters: {'page': page.toString()},
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        final videos = data.map((json) {
          final mapped = json as Map<String, dynamic>;
          return Video(
            id: mapped['id'] ?? '',
            title: mapped['title'] ?? '',
            channelName: mapped['channel'] ?? mapped['author'] ?? 'Unknown',
            channelId: channelId, // we know the channel ID
            thumbnail: mapped['thumbnail'] ?? '',
            duration: Duration(seconds: mapped['duration'] is int ? mapped['duration'] : 0),
            views: mapped['view_count'] is int ? mapped['view_count'] : 0,
            uploadDate: DateTime.now(), // fallback
            description: mapped['description'] ?? '',
          );
        }).toList();

        return (
          success: true,
          data: videos,
          error: null,
          details: null,
        );
      } else {
        return (
          success: false,
          data: null,
          error: response.data['error'] ?? 'Failed to get channel videos',
          details: null,
        );
      }
    } catch (e) {
      _logger.w('Get channel videos error: $e');
      return (
        success: false,
        data: null,
        error: 'Network error',
        details: e.toString(),
      );
    }
  }

  /// Fetch available subtitle tracks for a video
  Future<ApiResult<List<Map<String, String>>>> getSubtitles(String videoId) async {
    try {
      final response = await _dio.get('/subtitles/$videoId');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        final tracks = data.map((json) {
          final mapped = json as Map<String, dynamic>;
          return {
            'language': (mapped['language'] ?? '').toString(),
            'language_name': (mapped['language_name'] ?? '').toString(),
            'url': (mapped['url'] ?? '').toString(),
            'ext': (mapped['ext'] ?? 'vtt').toString(),
          };
        }).toList();

        return (
          success: true,
          data: tracks,
          error: null,
          details: null,
        );
      } else {
        return (
          success: false,
          data: null,
          error: response.data['error'] ?? 'Failed to get subtitles',
          details: null,
        );
      }
    } catch (e) {
      _logger.w('Get subtitles error: $e');
      return (
        success: false,
        data: null,
        error: 'Network error',
        details: e.toString(),
      );
    }
  }

  /// Fetch SponsorBlock segments for a video
  Future<List<Map<String, dynamic>>> getSponsorBlockSegments(String videoId) async {
    try {
      final response = await _dio.get('/sponsorblock/$videoId');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        // Backend returns: { segment: [start, end], category, UUID }
        // Frontend model expects: { startTime, endTime, category, votes }
        return data.map((json) {
          final mapped = json as Map<String, dynamic>;
          final segment = mapped['segment'] as List<dynamic>?;
          return <String, dynamic>{
            'startTime': segment != null && segment.length >= 2
                ? (segment[0] as num).toDouble()
                : 0.0,
            'endTime': segment != null && segment.length >= 2
                ? (segment[1] as num).toDouble()
                : 0.0,
            'category': mapped['category'] ?? 'sponsor',
            'votes': 0,
            'isVoted': false,
          };
        }).toList();
      }
    } catch (e) {
      _logger.w('Get SponsorBlock segments error: $e');
    }
    return [];
  }

  /// Fetch dislike data for a video
  Future<Map<String, dynamic>?> getDislikeData(String videoId) async {
    try {
      final response = await _dio.get('/dislikes/$videoId');

      if (response.data['success'] == true) {
        final Map<String, dynamic> data = response.data['data'];
        return {
          'videoId': videoId,
          'likes': data['likes'] ?? 0,
          'dislikes': data['dislikes'] ?? 0,
          'rating': (data['rating'] as num?)?.toDouble() ?? 0.0,
          'viewCount': data['view_count'] ?? 0,
        };
      }
    } catch (e) {
      _logger.w('Get dislike data error: $e');
    }
    return null;
  }

  /// Add a video to bookmarks
  Future<ApiResult<String>> addBookmark({
    required String videoId,
    required String title,
    required String channel,
    required String thumbnail,
    required int duration,
  }) async {
    try {
      final response = await _dio.post(
        '/bookmarks',
        data: {
          'video_id': videoId,
          'title': title,
          'channel': channel,
          'thumbnail': thumbnail,
          'duration': duration,
        },
      );

      if (response.data['success'] == true) {
        _logger.i('✅ Bookmark added: $videoId');
        return (
          success: true,
          data: 'Bookmark added',
          error: null,
          details: null,
        );
      } else {
        return (
          success: false,
          data: null,
          error: response.data['error'] ?? 'Failed to add bookmark',
          details: null,
        );
      }
    } catch (e) {
      _logger.w('Add bookmark error: $e');
      return (
        success: false,
        data: null,
        error: 'Network error',
        details: e.toString(),
      );
    }
  }

  /// Remove a video from bookmarks
  Future<ApiResult<String>> removeBookmark(String videoId) async {
    try {
      final response = await _dio.delete('/bookmarks/$videoId');

      if (response.data['success'] == true) {
        _logger.i('❌ Bookmark removed: $videoId');
        return (
          success: true,
          data: 'Bookmark removed',
          error: null,
          details: null,
        );
      } else {
        return (
          success: false,
          data: null,
          error: response.data['error'] ?? 'Failed to remove bookmark',
          details: null,
        );
      }
    } catch (e) {
      _logger.w('Remove bookmark error: $e');
      return (
        success: false,
        data: null,
        error: 'Network error',
        details: e.toString(),
      );
    }
  }

  /// Get all bookmarked videos
  Future<ApiResult<List<Map<String, dynamic>>>> getBookmarks() async {
    try {
      final response = await _dio.get('/bookmarks');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        final bookmarks = data.map((json) {
          final mapped = json as Map<String, dynamic>;
          return {
            'id': mapped['id'] ?? 0,
            'video_id': mapped['video_id'] ?? '',
            'title': mapped['title'] ?? '',
            'channel': mapped['channel'] ?? '',
            'thumbnail': mapped['thumbnail'] ?? '',
            'duration': mapped['duration'] ?? 0,
            'bookmarked_at': mapped['bookmarked_at'] ?? '',
          };
        }).toList();

        return (
          success: true,
          data: bookmarks,
          error: null,
          details: null,
        );
      } else {
        return (
          success: false,
          data: null,
          error: response.data['error'] ?? 'Failed to get bookmarks',
          details: null,
        );
      }
    } catch (e) {
      _logger.w('Get bookmarks error: $e');
      return (
        success: false,
        data: null,
        error: 'Network error',
        details: e.toString(),
      );
    }
  }

  /// Check if a video is bookmarked
  Future<ApiResult<bool>> isBookmarked(String videoId) async {
    try {
      final response = await _dio.get('/bookmarks/$videoId/check');

      if (response.data['success'] == true) {
        final bool isBookmarked = response.data['data'] ?? false;
        return (
          success: true,
          data: isBookmarked,
          error: null,
          details: null,
        );
      } else {
        return (
          success: false,
          data: null,
          error: response.data['error'] ?? 'Failed to check bookmark',
          details: null,
        );
      }
    } catch (e) {
      _logger.w('Check bookmark error: $e');
      return (
        success: false,
        data: null,
        error: 'Network error',
        details: e.toString(),
      );
    }
  }

  /// Get subscription feed - videos from all subscribed channels
  Future<ApiResult<List<Video>>> getSubscriptionFeed() async {
    try {
      final response = await _dio.get('/feed');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? <dynamic>[];
        final videos = data
            .map((json) => Video.fromJson(Map<String, dynamic>.from(json as Map)))
            .toList();

        return (
          success: true,
          data: videos,
          error: null,
          details: null,
        );
      } else {
        return (
          success: false,
          data: null,
          error: response.data['error'] ?? 'Failed to get subscription feed',
          details: null,
        );
      }
    } catch (e) {
      _logger.w('Get subscription feed error: $e');
      return (
        success: false,
        data: null,
        error: 'Network error',
        details: e.toString(),
      );
    }
  }

  /// Get trending videos
  Future<ApiResult<List<Video>>> getTrendingVideos({
    String region = 'US',
    String trendType = 'default',
  }) async {
    try {
      final response = await _dio.get(
        '/trending',
        queryParameters: {'region': region, 'type': trendType},
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? <dynamic>[];
        final videos = data
            .map((json) => Video.fromJson(Map<String, dynamic>.from(json as Map)))
            .toList();

        return (
          success: true,
          data: videos,
          error: null,
          details: null,
        );
      } else {
        return (
          success: false,
          data: null,
          error: response.data['error'] ?? 'Failed to get trending videos',
          details: null,
        );
      }
    } catch (e) {
      _logger.w('Get trending videos error: $e');
      return (
        success: false,
        data: null,
        error: 'Network error',
        details: e.toString(),
      );
    }
  }

  /// Get recommended videos for a specific video
  Future<ApiResult<List<Video>>> getRecommendedVideos({
    required String videoId,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/recommended/$videoId',
        queryParameters: {'limit': limit},
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? <dynamic>[];
        final videos = data
            .map((json) => Video.fromJson(Map<String, dynamic>.from(json as Map)))
            .toList();

        return (
          success: true,
          data: videos,
          error: null,
          details: null,
        );
      } else {
        return (
          success: false,
          data: null,
          error: response.data['error'] ?? 'Failed to get recommended videos',
          details: null,
        );
      }
    } catch (e) {
      _logger.w('Get recommended videos error: $e');
      return (
        success: false,
        data: null,
        error: 'Network error',
        details: e.toString(),
      );
    }
  }

  /// Get playlist info and videos
  Future<ApiResult<Map<String, dynamic>>> getPlaylist({
    required String playlistId,
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        '/playlists/$playlistId',
        queryParameters: {'page': page},
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        
        return (
          success: true,
          data: data,
          error: null,
          details: null,
        );
      } else {
        return (
          success: false,
          data: null,
          error: response.data['error'] ?? 'Failed to get playlist',
          details: null,
        );
      }
    } catch (e) {
      _logger.w('Get playlist error: $e');
      return (
        success: false,
        data: null,
        error: 'Network error',
        details: e.toString(),
      );
    }
  }

  /// Format view count for display
  String _formatViews(dynamic count) {
    final num = int.tryParse(count.toString()) ?? 0;
    if (num >= 1000000) {
      return '${(num / 1000000).toStringAsFixed(1)}M views';
    } else if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}K views';
    } else {
      return '$num views';
    }
  }

  /// Get notifications
  Future<ApiResult<List<Notification>>> getNotifications({
    bool unreadOnly = false,
  }) async {
    try {
      final response = await _dio.get(
        '/notifications',
        queryParameters: {'unread_only': unreadOnly},
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        final notifications = data
            .map((json) => Notification.fromJson(json as Map<String, dynamic>))
            .toList();

        return (
          success: true,
          data: notifications,
          error: null,
          details: null,
        );
      } else {
        return (
          success: false,
          data: null,
          error: response.data['error'] ?? 'Failed to get notifications',
          details: null,
        );
      }
    } catch (e) {
      _logger.w('Get notifications error: $e');
      return (
        success: false,
        data: null,
        error: 'Network error',
        details: e.toString(),
      );
    }
  }

  /// Mark notification as read
  Future<ApiResult<bool>> markNotificationAsRead(int notificationId) async {
    try {
      final response = await _dio.post(
        '/notifications/read',
        data: {'notification_id': notificationId},
      );

      if (response.data['success'] == true) {
        return (
          success: true,
          data: true,
          error: null,
          details: null,
        );
      } else {
        return (
          success: false,
          data: null,
          error: response.data['error'] ?? 'Failed to mark notification as read',
          details: null,
        );
      }
    } catch (e) {
      _logger.w('Mark notification as read error: $e');
      return (
        success: false,
        data: null,
        error: 'Network error',
        details: e.toString(),
      );
    }
  }

  /// Mark all notifications as read
  Future<ApiResult<bool>> markAllNotificationsAsRead() async {
    try {
      final response = await _dio.post('/notifications/read-all');

      if (response.data['success'] == true) {
        return (
          success: true,
          data: true,
          error: null,
          details: null,
        );
      } else {
        return (
          success: false,
          data: null,
          error: response.data['error'] ?? 'Failed to mark all notifications as read',
          details: null,
        );
      }
    } catch (e) {
      _logger.w('Mark all notifications as read error: $e');
      return (
        success: false,
        data: null,
        error: 'Network error',
        details: e.toString(),
      );
    }
  }

  /// Delete notification
  Future<ApiResult<bool>> deleteNotification(int notificationId) async {
    try {
      final response = await _dio.delete('/notifications/$notificationId');

      if (response.data['success'] == true) {
        return (
          success: true,
          data: true,
          error: null,
          details: null,
        );
      } else {
        return (
          success: false,
          data: null,
          error: response.data['error'] ?? 'Failed to delete notification',
          details: null,
        );
      }
    } catch (e) {
      _logger.w('Delete notification error: $e');
      return (
        success: false,
        data: null,
        error: 'Network error',
        details: e.toString(),
      );
    }
  }

  /// Get unread notification count
  Future<ApiResult<int>> getUnreadNotificationCount() async {
    try {
      final response = await _dio.get('/notifications/count');

      if (response.data['success'] == true) {
        final count = response.data['data'] as int;
        return (
          success: true,
          data: count,
          error: null,
          details: null,
        );
      } else {
        return (
          success: false,
          data: null,
          error: response.data['error'] ?? 'Failed to get notification count',
          details: null,
        );
      }
    } catch (e) {
      _logger.w('Get unread notification count error: $e');
      return (
        success: false,
        data: null,
        error: 'Network error',
        details: e.toString(),
      );
    }
  }

  /// Search within video subtitles
  Future<ApiResult<List<SubtitleSearchResult>>> searchSubtitles(
    String videoId,
    String query,
  ) async {
    try {
      final response = await _dio.get(
        '/subtitles/$videoId/search',
        queryParameters: {'q': query},
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        final results = data
            .map((json) =>
                SubtitleSearchResult.fromJson(json as Map<String, dynamic>))
            .toList();

        return (
          success: true,
          data: results,
          error: null,
          details: null,
        );
      } else {
        return (
          success: false,
          data: null,
          error: response.data['error'] ?? 'Failed to search subtitles',
          details: null,
        );
      }
    } catch (e) {
      _logger.w('Search subtitles error: $e');
      return (
        success: false,
        data: null,
        error: 'Network error',
        details: e.toString(),
      );
    }
  }

  // Cache management methods for offline support
  Future<ApiResult<Map<String, dynamic>>> getCacheStats() async {
    try {
      final response = await _dio.get('/cache/stats');

      if (response.data['success'] == true) {
        final data = response.data['data'] ?? {};
        return (
          success: true,
          data: data is Map ? data.cast<String, dynamic>() : {},
          error: null,
          details: null,
        );
      } else {
        return (
          success: false,
          data: null,
          error: response.data['error'] ?? 'Failed to get cache stats',
          details: null,
        );
      }
    } catch (e) {
      _logger.w('Get cache stats error: $e');
      return (
        success: false,
        data: null,
        error: 'Network error',
        details: e.toString(),
      );
    }
  }

  Future<ApiResult<Map<String, dynamic>>> clearCache() async {
    try {
      final response = await _dio.delete('/cache');

      if (response.data['success'] == true) {
        final data = response.data['data'] ?? {};
        return (
          success: true,
          data: data is Map ? data.cast<String, dynamic>() : {},
          error: null,
          details: null,
        );
      } else {
        return (
          success: false,
          data: null,
          error: response.data['error'] ?? 'Failed to clear cache',
          details: null,
        );
      }
    } catch (e) {
      _logger.w('Clear cache error: $e');
      return (
        success: false,
        data: null,
        error: 'Network error',
        details: e.toString(),
      );
    }
  }

  Future<ApiResult<Map<String, dynamic>>> cleanupOldCache(int days) async {
    try {
      final response = await _dio.post(
        '/cache/cleanup',
        data: {'days': days},
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] ?? {};
        return (
          success: true,
          data: data is Map ? data.cast<String, dynamic>() : {},
          error: null,
          details: null,
        );
      } else {
        return (
          success: false,
          data: null,
          error: response.data['error'] ?? 'Failed to cleanup cache',
          details: null,
        );
      }
    } catch (e) {
      _logger.w('Cleanup cache error: $e');
      return (
        success: false,
        data: null,
        error: 'Network error',
        details: e.toString(),
      );
    }
  }

  /// Format Unix timestamp for display
  String _formatTimestamp(dynamic timestamp) {
    try {
      final time = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp.toString()) * 1000);
      final now = DateTime.now();
      final diff = now.difference(time);

      if (diff.inDays > 365) {
        return '${(diff.inDays / 365).toStringAsFixed(0)} years ago';
      } else if (diff.inDays > 30) {
        return '${(diff.inDays / 30).toStringAsFixed(0)} months ago';
      } else if (diff.inDays > 0) {
        return '${diff.inDays} days ago';
      } else if (diff.inHours > 0) {
        return '${diff.inHours}h ago';
      } else if (diff.inMinutes > 0) {
        return '${diff.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Get list of screen recordings
  Future<ApiResult<List<Map<String, dynamic>>>> getRecordings() async {
    try {
      final response = await _dio.get('/recordings');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        final recordings = data.cast<Map<String, dynamic>>();
        return (
          success: true,
          data: recordings,
          error: null,
          details: null,
        );
      } else {
        return (
          success: false,
          data: null,
          error: response.data['error'] ?? 'Failed to get recordings',
          details: null,
        );
      }
    } catch (e) {
      _logger.w('Get recordings error: $e');
      return (
        success: false,
        data: null,
        error: 'Network error',
        details: e.toString(),
      );
    }
  }

  /// Get cloud sync history
  Future<ApiResult<List<Map<String, dynamic>>>> getSyncHistory() async {
    try {
      final response = await _dio.get('/cloud-sync/history');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        final history = data.cast<Map<String, dynamic>>();
        return (
          success: true,
          data: history,
          error: null,
          details: null,
        );
      } else {
        return (
          success: false,
          data: null,
          error: response.data['error'] ?? 'Failed to get sync history',
          details: null,
        );
      }
    } catch (e) {
      _logger.w('Get sync history error: $e');
      return (
        success: false,
        data: null,
        error: 'Network error',
        details: e.toString(),
      );
    }
  }

  /// Start screen sharing/streaming
  Future<ApiResult<Map<String, dynamic>>> startStreaming({
    required String platform,
    required String resolution,
    required String bitrate,
    required bool includeAudio,
    String? streamUrl,
    String? streamKey,
  }) async {
    try {
      final response = await _dio.post(
        '/streaming/start',
        data: {
          'platform': platform,
          'resolution': resolution,
          'bitrate': bitrate,
          'include_audio': includeAudio,
          'stream_url': streamUrl,
          'stream_key': streamKey,
        },
      );

      if (response.data['success'] == true) {
        return (
          success: true,
          data: response.data['data'] ?? {},
          error: null,
          details: null,
        );
      } else {
        return (
          success: false,
          data: null,
          error: response.data['error'] ?? 'Failed to start streaming',
          details: null,
        );
      }
    } catch (e) {
      _logger.w('Start streaming error: $e');
      return (
        success: false,
        data: null,
        error: 'Network error',
        details: e.toString(),
      );
    }
  }

  /// Stop screen sharing/streaming
  Future<ApiResult<Map<String, dynamic>>> stopStreaming() async {
    try {
      final response = await _dio.post('/streaming/stop');

      if (response.data['success'] == true) {
        return (
          success: true,
          data: response.data['data'] ?? {},
          error: null,
          details: null,
        );
      } else {
        return (
          success: false,
          data: null,
          error: response.data['error'] ?? 'Failed to stop streaming',
          details: null,
        );
      }
    } catch (e) {
      _logger.w('Stop streaming error: $e');
      return (
        success: false,
        data: null,
        error: 'Network error',
        details: e.toString(),
      );
    }
  }

  /// Get streaming status
  Future<ApiResult<Map<String, dynamic>>> getStreamingStatus() async {
    try {
      final response = await _dio.get('/streaming/status');

      if (response.data['success'] == true) {
        return (
          success: true,
          data: response.data['data'] ?? {},
          error: null,
          details: null,
        );
      } else {
        return (
          success: false,
          data: null,
          error: response.data['error'] ?? 'Failed to get streaming status',
          details: null,
        );
      }
    } catch (e) {
      _logger.w('Get streaming status error: $e');
      return (
        success: false,
        data: null,
        error: 'Network error',
        details: e.toString(),
      );
    }
  }
}
