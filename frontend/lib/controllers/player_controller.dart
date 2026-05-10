import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/video.dart';
import '../providers.dart';
import '../services/api_service.dart';
import '../services/player_service.dart';

enum PlaybackStatus { idle, loading, playing, paused, stopped, error }

enum PlayerSurface { hidden, fullscreen, mini, popup }

class TubularPlayerState {
  const TubularPlayerState({
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

  TubularPlayerState copyWith({
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
    return TubularPlayerState(
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

  static const initial = TubularPlayerState();
}

final playerControllerProvider =
    StateNotifierProvider<PlayerController, TubularPlayerState>((ref) {
      final apiService = ref.watch(apiServiceProvider);
      final playerService = ref.watch(playerServiceProvider);
      return PlayerController(apiService, playerService);
    });

class PlayerController extends StateNotifier<TubularPlayerState> {
  PlayerController(this._apiService, this._playerService)
    : super(TubularPlayerState.initial);

  final ApiService _apiService;
  final PlayerService _playerService;
  int _playRequestSerial = 0;

  Future<void> playVideo(
    Video video, {
    String quality = 'best',
    PlayerSurface surface = PlayerSurface.fullscreen,
  }) async {
    final requestSerial = ++_playRequestSerial;

    print('🎬 playVideo called: ${video.title}');
    print('   quality: $quality');
    
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
      print('📡 Fetching stream URL...');
      final streamUrl = await _apiService.getStreamUrl(
        video.id,
        quality: quality,
      );
      print('✅ Got stream URL: $streamUrl');
      
      if (requestSerial != _playRequestSerial || state.video?.id != video.id) {
        print('⚠️  Request cancelled or video changed');
        return;
      }

      // Set stream URL and status to playing
      // The media_kit player in the widget will handle the actual playback
      print('🎥 Setting stream URL and status to playing');
      state = state.copyWith(
        streamUrl: streamUrl,
        status: PlaybackStatus.playing,
        clearError: true,
      );
      print('✅ State updated, player should start');
    } catch (error) {
      print('❌ Error getting stream URL: $error');
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
    state = state.copyWith(status: PlaybackStatus.paused);
  }

  Future<void> resume() async {
    if (state.status != PlaybackStatus.paused) {
      return;
    }
    state = state.copyWith(status: PlaybackStatus.playing);
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
    previewSeek(position);
    // The media_kit player widget will handle the actual seek
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

  void showPopupPlayer() {
    if (!state.hasVideo) {
      return;
    }

    state = state.copyWith(surface: PlayerSurface.popup);
  }

  Future<void> toggleBackgroundAudio() async {
    final enabled = !state.backgroundAudio;
    state = state.copyWith(backgroundAudio: enabled);
  }

  Future<void> toggleAudioOnlyStream({String fallbackQuality = 'best'}) async {
    if (!state.hasVideo) {
      return;
    }

    if (state.quality == 'audio') {
      final nextQuality = fallbackQuality == 'audio' ? 'best' : fallbackQuality;
      await setQuality(nextQuality);
      return;
    }

    await setQuality('audio');
  }

  Future<void> stop() async {
    _playRequestSerial++;
    state = TubularPlayerState.initial.copyWith(status: PlaybackStatus.stopped);
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

  // Methods for media_kit player to update state
  void updatePosition(Duration position) {
    if (state.video != null) {
      state = state.copyWith(position: position);
    }
  }

  void updateDuration(Duration duration) {
    if (state.video != null && duration != Duration.zero) {
      state = state.copyWith(duration: duration);
    }
  }

  void updatePlayingState(bool isPlaying) {
    if (state.video != null) {
      final newStatus = isPlaying ? PlaybackStatus.playing : PlaybackStatus.paused;
      if (state.status != newStatus && state.status != PlaybackStatus.loading) {
        state = state.copyWith(status: newStatus);
      }
    }
  }

  void setError(String error) {
    if (state.video != null) {
      state = state.copyWith(
        status: PlaybackStatus.error,
        errorMessage: error,
      );
    }
  }
}
