import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../providers/recording_provider.dart';

/// Screen recording dialog
class ScreenRecordingDialog extends ConsumerStatefulWidget {
  final String videoId;

  const ScreenRecordingDialog({
    required this.videoId,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<ScreenRecordingDialog> createState() =>
      _ScreenRecordingDialogState();
}

class _ScreenRecordingDialogState extends ConsumerState<ScreenRecordingDialog> {
  late RecordingSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = ref.read(recordingSettingsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final isRecording = ref.watch(isRecordingProvider);

    return AlertDialog(
      title: const Text('Screen Recording Settings'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Video Recording Toggle
              SwitchListTile(
                title: const Text('Record Video'),
                value: _settings.recordVideo,
                onChanged: isRecording
                    ? null
                    : (value) {
                        setState(() {
                          _settings = _settings.copyWith(recordVideo: value);
                        });
                      },
              ),
              const Divider(),

              // Audio Recording Toggle
              SwitchListTile(
                title: const Text('Record Audio'),
                value: _settings.recordAudio,
                onChanged: isRecording
                    ? null
                    : (value) {
                        setState(() {
                          _settings = _settings.copyWith(recordAudio: value);
                        });
                      },
              ),
              const Divider(),

              // Quality Bitrate Slider
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Video Quality: ${_settings.qualityBitrate} kbps',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Slider(
                      value: _settings.qualityBitrate.toDouble(),
                      min: 1000,
                      max: 15000,
                      divisions: 14,
                      enabled: !isRecording && _settings.recordVideo,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(
                            qualityBitrate: value.toInt(),
                          );
                        });
                      },
                      label: '${_settings.qualityBitrate} kbps',
                    ),
                  ],
                ),
              ),
              const Divider(),

              // Frame Rate Dropdown
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Frame Rate',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<int>(
                      value: _settings.frameRate,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 24, child: Text('24 FPS')),
                        DropdownMenuItem(value: 30, child: Text('30 FPS')),
                        DropdownMenuItem(value: 60, child: Text('60 FPS')),
                      ],
                      onChanged: isRecording
                          ? null
                          : (value) {
                              setState(() {
                                _settings = _settings.copyWith(
                                  frameRate: value ?? 30,
                                );
                              });
                            },
                    ),
                  ],
                ),
              ),
              const Divider(),

              // Caption Overlay Toggle
              SwitchListTile(
                title: const Text('Overlay Captions'),
                subtitle: const Text('Show subtitles while recording'),
                value: _settings.enableCaption,
                onChanged: isRecording
                    ? null
                    : (value) {
                        setState(() {
                          _settings = _settings.copyWith(enableCaption: value);
                        });
                      },
              ),
              const Divider(),

              // Quality Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recording Info',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Video: ${_settings.recordVideo ? _settings.qualityBitrate}kbps @ ${_settings.frameRate}fps' : 'Off'}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      'Audio: ${_settings.recordAudio ? 'MP3 320kbps' : 'Off'}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'File: MP4 (H.264 + AAC)',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isRecording ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isRecording
              ? null
              : () async {
                  ref.read(recordingSettingsProvider.notifier).state =
                      _settings;
                  await _startRecording();
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[700],
            foregroundColor: Colors.white,
          ),
          child: const Text('Start Recording'),
        ),
      ],
    );
  }

  Future<void> _startRecording() async {
    final recordingFolder =
        ref.read(downloadFolderProvider).replaceFirst('~', '/home/pragadeesh');
    final timestamp = DateTime.now().toString().replaceAll(':', '-');
    final outputPath = '$recordingFolder/recording_$timestamp.mp4';

    ref.read(recordingSessionProvider.notifier).state = RecordingSession(
      videoId: widget.videoId,
      outputPath: outputPath,
      isRecording: true,
      startTime: DateTime.now(),
    );

    ref.read(isRecordingProvider.notifier).state = true;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🔴 Recording started: $outputPath'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }
}

/// Recording controls widget (shows in player UI)
class RecordingControls extends ConsumerWidget {
  final String videoId;

  const RecordingControls({
    required this.videoId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRecording = ref.watch(isRecordingProvider);
    final session = ref.watch(recordingSessionProvider);

    if (!isRecording) {
      return Tooltip(
        message: 'Start screen recording',
        child: IconButton(
          icon: const Icon(Icons.fiber_manual_record_outlined, size: 20),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => ScreenRecordingDialog(videoId: videoId),
            );
          },
        ),
      );
    }

    // Recording active
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red[700],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.fiber_manual_record, color: Colors.white, size: 12),
          const SizedBox(width: 6),
          StreamBuilder<Duration>(
            stream: Stream.periodic(const Duration(milliseconds: 100), (_) {
              if (session != null) {
                return DateTime.now().difference(session.startTime);
              }
              return const Duration();
            }),
            builder: (context, snapshot) {
              final duration = snapshot.data ?? const Duration();
              final formatted =
                  '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
              return Text(
                formatted,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'Stop recording',
            child: GestureDetector(
              onTap: () => _stopRecording(context, ref),
              child: const Icon(Icons.stop, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _stopRecording(BuildContext context, WidgetRef ref) {
    final session = ref.read(recordingSessionProvider);
    ref.read(isRecordingProvider.notifier).state = false;
    ref.read(recordingSessionProvider.notifier).state = null;

    if (session != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Recording saved: ${session.outputPath}'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.green[700],
          action: SnackBarAction(
            label: 'Open Folder',
            onPressed: () {
              // Open folder in file manager
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening folder...')),
              );
            },
          ),
        ),
      );
    }
  }
}
