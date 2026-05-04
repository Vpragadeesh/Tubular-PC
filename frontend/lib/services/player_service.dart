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
