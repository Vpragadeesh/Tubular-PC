import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

/// Screen recording session state
class RecordingSession {
  final String videoId;
  final String outputPath;
  final bool isRecording;
  final Duration recordedDuration;
  final DateTime startTime;

  RecordingSession({
    required this.videoId,
    required this.outputPath,
    required this.isRecording,
    this.recordedDuration = const Duration(),
    required this.startTime,
  });

  RecordingSession copyWith({
    String? videoId,
    String? outputPath,
    bool? isRecording,
    Duration? recordedDuration,
    DateTime? startTime,
  }) {
    return RecordingSession(
      videoId: videoId ?? this.videoId,
      outputPath: outputPath ?? this.outputPath,
      isRecording: isRecording ?? this.isRecording,
      recordedDuration: recordedDuration ?? this.recordedDuration,
      startTime: startTime ?? this.startTime,
    );
  }
}

/// Screen recording settings
class RecordingSettings {
  final bool recordAudio;
  final bool recordVideo;
  final int qualityBitrate; // in kbps
  final int frameRate;
  final bool enableCaption; // overlay captions during recording

  RecordingSettings({
    required this.recordAudio,
    required this.recordVideo,
    required this.qualityBitrate,
    required this.frameRate,
    required this.enableCaption,
  });

  RecordingSettings copyWith({
    bool? recordAudio,
    bool? recordVideo,
    int? qualityBitrate,
    int? frameRate,
    bool? enableCaption,
  }) {
    return RecordingSettings(
      recordAudio: recordAudio ?? this.recordAudio,
      recordVideo: recordVideo ?? this.recordVideo,
      qualityBitrate: qualityBitrate ?? this.qualityBitrate,
      frameRate: frameRate ?? this.frameRate,
      enableCaption: enableCaption ?? this.enableCaption,
    );
  }
}

// Recording settings provider
final recordingSettingsProvider = StateProvider<RecordingSettings>((ref) {
  return RecordingSettings(
    recordAudio: true,
    recordVideo: true,
    qualityBitrate: 5000, // 5 Mbps
    frameRate: 30,
    enableCaption: true,
  );
});

// Current recording session provider
final recordingSessionProvider = StateProvider<RecordingSession?>((ref) => null);

// Is recording provider
final isRecordingProvider = StateProvider<bool>((ref) => false);

// Recordings list provider (past recordings)
final recordingsListProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final result = await api.getRecordings();
  return result.data ?? [];
});
