import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

/// Dialog for batch download operations
class BatchDownloadDialog extends ConsumerStatefulWidget {
  final List<String> selectedVideoIds;

  const BatchDownloadDialog({
    required this.selectedVideoIds,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<BatchDownloadDialog> createState() => _BatchDownloadDialogState();
}

class _BatchDownloadDialogState extends ConsumerState<BatchDownloadDialog> {
  late String _selectedQuality;
  late String _selectedFormat;

  @override
  void initState() {
    super.initState();
    _selectedQuality = ref.read(preferredQualityProvider);
    _selectedFormat = ref.read(preferredFormatProvider);
  }

  @override
  Widget build(BuildContext context) {
    final api = ref.read(apiServiceProvider);
    final downloading = ref.watch(batchDownloadingProvider);
    final queue = ref.watch(batchDownloadQueueProvider);

    return AlertDialog(
      title: const Text('Batch Download'),
      content: SizedBox(
        width: 500,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected Videos: ${widget.selectedVideoIds.length}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Quality:'),
            DropdownButton<String>(
              value: _selectedQuality,
              items: const [
                DropdownMenuItem(value: '360p', child: Text('360p')),
                DropdownMenuItem(value: '480p', child: Text('480p')),
                DropdownMenuItem(value: '720p', child: Text('720p')),
                DropdownMenuItem(value: '1080p', child: Text('1080p')),
                DropdownMenuItem(value: 'best', child: Text('Best Available')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedQuality = value ?? '720p';
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Format:'),
            DropdownButton<String>(
              value: _selectedFormat,
              items: const [
                DropdownMenuItem(value: 'video', child: Text('Video + Audio')),
                DropdownMenuItem(value: 'audio', child: Text('Audio Only (MP3)')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedFormat = value ?? 'video';
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[700]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(12),
                child: queue.isEmpty
                    ? const Center(
                        child: Text('No downloads yet'),
                      )
                    : ListView.builder(
                        itemCount: queue.length,
                        itemBuilder: (context, index) {
                          final task = queue[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        task.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    if (task.completed)
                                      const Icon(Icons.check, color: Colors.green, size: 16)
                                    else if (task.error != null)
                                      const Icon(Icons.error, color: Colors.red, size: 16)
                                    else if (task.downloading)
                                      const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                  ],
                                ),
                                if (task.downloading || task.completed)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(2),
                                      child: LinearProgressIndicator(
                                        value: task.progress,
                                        minHeight: 4,
                                      ),
                                    ),
                                  ),
                                if (task.error != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      task.error!,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 10,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: downloading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: downloading
              ? null
              : () async {
                  // Start batch download
                  await _startBatchDownload(context, widget.selectedVideoIds);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[700],
            foregroundColor: Colors.white,
          ),
          child: Text(downloading ? 'Downloading...' : 'Download All'),
        ),
      ],
    );
  }

  Future<void> _startBatchDownload(BuildContext context, List<String> videoIds) async {
    final api = ref.read(apiServiceProvider);
    final notifier = ref.read(batchDownloadQueueProvider.notifier);

    // Initialize queue with all videos
    final tasks = <BatchDownloadTask>[];
    for (final videoId in videoIds) {
      try {
        final result = await api.getVideoDetails(videoId);
        if (result.id.isNotEmpty) {
          tasks.add(
            BatchDownloadTask(
              videoId: videoId,
              title: result.title,
              quality: _selectedQuality,
              format: _selectedFormat,
            ),
          );
        }
      } catch (e) {
        tasks.add(
          BatchDownloadTask(
            videoId: videoId,
            title: 'Unknown ($videoId)',
            quality: _selectedQuality,
            format: _selectedFormat,
            error: 'Failed to load',
          ),
        );
      }
    }

    notifier.state = tasks;
    ref.read(batchDownloadingProvider.notifier).state = true;

    // Start downloading each video
    for (int i = 0; i < tasks.length; i++) {
      final task = tasks[i];

      try {
        // Update task status to downloading
        notifier.state = [
          ...notifier.state.sublist(0, i),
          task.copyWith(downloading: true),
          ...notifier.state.sublist(i + 1),
        ];

        final outputPath = _buildOutputPath(task.title, task.format == 'audio');
        await api.createDownload(
          task.videoId,
          task.title,
          outputPath,
          task.format == 'audio' ? 'audio' : task.quality,
          audioOnly: task.format == 'audio',
        );

        notifier.state = [
          ...notifier.state.sublist(0, i),
          task.copyWith(progress: 0.01, downloading: true),
          ...notifier.state.sublist(i + 1),
        ];

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Started: ${task.title}'),
              duration: const Duration(seconds: 1),
              backgroundColor: Colors.green[700],
            ),
          );
        }
      } catch (e) {
        notifier.state = [
          ...notifier.state.sublist(0, i),
          task.copyWith(
            error: 'Download failed',
            downloading: false,
          ),
          ...notifier.state.sublist(i + 1),
        ];
      }
    }

    ref.read(batchDownloadingProvider.notifier).state = false;
  }

  String _buildOutputPath(String title, bool audioOnly) {
    final folder = ref.read(downloadFolderProvider);
    final home = Platform.environment['HOME'] ?? '.';
    final basePath = folder.startsWith('~/')
        ? '$home/${folder.substring(2)}'
        : (folder.trim().isEmpty ? '$home/Downloads/Tubular' : folder);
    final safeTitle = title
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return '$basePath/$safeTitle${audioOnly ? '.m4a' : '.mp4'}';
  }
}
