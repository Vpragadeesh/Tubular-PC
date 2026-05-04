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
