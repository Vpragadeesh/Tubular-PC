import 'package:flutter_riverpod/flutter_riverpod.dart';

class StreamingSession {
  final String platform;
  final String resolution;
  final String bitrate;
  final bool includeAudio;
  final String streamUrl;
  final String streamKey;
  final bool isStreaming;
  final Duration streamDuration;
  final double bufferHealth;
  final int viewerCount;

  StreamingSession({
    required this.platform,
    required this.resolution,
    required this.bitrate,
    required this.includeAudio,
    required this.streamUrl,
    required this.streamKey,
    required this.isStreaming,
    required this.streamDuration,
    required this.bufferHealth,
    required this.viewerCount,
  });

  StreamingSession copyWith({
    String? platform,
    String? resolution,
    String? bitrate,
    bool? includeAudio,
    String? streamUrl,
    String? streamKey,
    bool? isStreaming,
    Duration? streamDuration,
    double? bufferHealth,
    int? viewerCount,
  }) {
    return StreamingSession(
      platform: platform ?? this.platform,
      resolution: resolution ?? this.resolution,
      bitrate: bitrate ?? this.bitrate,
      includeAudio: includeAudio ?? this.includeAudio,
      streamUrl: streamUrl ?? this.streamUrl,
      streamKey: streamKey ?? this.streamKey,
      isStreaming: isStreaming ?? this.isStreaming,
      streamDuration: streamDuration ?? this.streamDuration,
      bufferHealth: bufferHealth ?? this.bufferHealth,
      viewerCount: viewerCount ?? this.viewerCount,
    );
  }
}

class StreamingStateNotifier extends StateNotifier<StreamingSession> {
  StreamingStateNotifier()
      : super(StreamingSession(
          platform: 'Discord',
          resolution: '1080p',
          bitrate: '2500k',
          includeAudio: true,
          streamUrl: '',
          streamKey: '',
          isStreaming: false,
          streamDuration: Duration.zero,
          bufferHealth: 1.0,
          viewerCount: 0,
        ));

  void startStreaming({
    required String platform,
    required String resolution,
    required String bitrate,
    required bool includeAudio,
    required String streamUrl,
    required String streamKey,
  }) {
    // In a real implementation, this would initiate FFmpeg streaming
    // For now, we update the state to reflect streaming is active
    state = state.copyWith(
      platform: platform,
      resolution: resolution,
      bitrate: bitrate,
      includeAudio: includeAudio,
      streamUrl: streamUrl,
      streamKey: streamKey,
      isStreaming: true,
      streamDuration: Duration.zero,
      bufferHealth: 1.0,
      viewerCount: 0,
    );
  }

  void stopStreaming() {
    state = state.copyWith(
      isStreaming: false,
      streamDuration: Duration.zero,
      viewerCount: 0,
    );
  }

  void updateStreamHealth(double bufferHealth) {
    state = state.copyWith(bufferHealth: bufferHealth);
  }

  void updateStreamDuration(Duration duration) {
    state = state.copyWith(streamDuration: duration);
  }

  void updateViewerCount(int count) {
    state = state.copyWith(viewerCount: count);
  }
}

final streamingStateProvider = StateNotifierProvider<StreamingStateNotifier, StreamingSession>(
  (ref) => StreamingStateNotifier(),
);
