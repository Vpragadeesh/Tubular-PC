import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../providers/streaming_provider.dart';

class ScreenSharingDialog extends ConsumerStatefulWidget {
  const ScreenSharingDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<ScreenSharingDialog> createState() => _ScreenSharingDialogState();
}

class _ScreenSharingDialogState extends ConsumerState<ScreenSharingDialog> {
  String _platform = 'Discord';
  String _streamUrl = '';
  String _streamKey = '';
  String _bitrate = '2500k';
  String _resolution = '1080p';
  bool _includeAudio = true;

  @override
  Widget build(BuildContext context) {
    final streamingState = ref.watch(streamingStateProvider);

    return AlertDialog(
      title: const Text('Screen Sharing'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Platform', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _platform,
              isExpanded: true,
              items: ['Discord', 'OBS', 'Twitch', 'YouTube Live']
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => setState(() => _platform = v ?? 'Discord'),
            ),
            const SizedBox(height: 16),
            const Text('Resolution', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _resolution,
              isExpanded: true,
              items: ['720p', '1080p', '1440p', '4K']
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) => setState(() => _resolution = v ?? '1080p'),
            ),
            const SizedBox(height: 16),
            const Text('Bitrate', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _bitrate,
              isExpanded: true,
              items: ['1000k', '1500k', '2500k', '4000k', '6000k']
                  .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                  .toList(),
              onChanged: (v) => setState(() => _bitrate = v ?? '2500k'),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Include Audio'),
              value: _includeAudio,
              onChanged: (v) => setState(() => _includeAudio = v ?? true),
            ),
            const SizedBox(height: 16),
            if (_platform != 'Discord') ...[
              const Text('Stream URL', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'rtmp://...',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => _streamUrl = v,
              ),
              const SizedBox(height: 16),
              const Text('Stream Key', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Enter stream key',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                onChanged: (v) => _streamKey = v,
              ),
              const SizedBox(height: 16),
            ],
            if (streamingState.isStreaming) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🟢 Streaming Live',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    const SizedBox(height: 8),
                    Text('Platform: ${streamingState.platform}'),
                    Text('Resolution: ${streamingState.resolution}'),
                    Text('Bitrate: ${streamingState.bitrate}'),
                    Text('Duration: ${_formatDuration(streamingState.streamDuration)}'),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: streamingState.bufferHealth,
                      minHeight: 4,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Buffer Health: ${(streamingState.bufferHealth * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        if (!streamingState.isStreaming)
          ElevatedButton(
            onPressed: _startStreaming,
            child: const Text('Start Streaming'),
          )
        else
          ElevatedButton.icon(
            onPressed: _stopStreaming,
            icon: const Icon(Icons.stop),
            label: const Text('Stop Streaming'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
      ],
    );
  }

  void _startStreaming() async {
    if (_platform != 'Discord' && _streamUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stream URL is required')),
      );
      return;
    }

    ref.read(streamingStateProvider.notifier).startStreaming(
          platform: _platform,
          resolution: _resolution,
          bitrate: _bitrate,
          includeAudio: _includeAudio,
          streamUrl: _streamUrl,
          streamKey: _streamKey,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Streaming to $_platform started')),
      );
    }
  }

  void _stopStreaming() {
    ref.read(streamingStateProvider.notifier).stopStreaming();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Streaming stopped')),
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }
}
