import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/video.dart';
import '../models/video_details.dart';
import '../providers.dart';
import '../controllers/player_controller.dart';
import '../screens/player_screen.dart';
import '../widgets/video_details/actions_section.dart';
import '../widgets/video_details/comments_section.dart';
import '../widgets/video_details/stats_section.dart';
import '../widgets/video_details/thumbnail_section.dart';

class VideoDetailsScreen extends ConsumerWidget {
  final Video video;

  const VideoDetailsScreen({super.key, required this.video});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(videoDetailsProvider(video.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Details'),
        backgroundColor: Colors.red[700],
      ),
      body: detailsAsync.when(
        data: (details) {
          final safeDetails = _buildSafeDetails(details);

          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ThumbnailSection(
                      thumbnailUrl: safeDetails.thumbnailUrl,
                      onPlay: () async {
                        await ref.read(playerControllerProvider.notifier).playVideo(video);
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => PlayerScreen(video: video)),
                          );
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StatsSection(details: safeDetails),
                          const SizedBox(height: 12),
                          ActionsSection(
                            items: [
                              ActionItem(
                                icon: Icons.playlist_add,
                                label: 'Add To',
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Add to playlist')),
                                  );
                                },
                              ),
                              ActionItem(
                                icon: Icons.headset,
                                label: 'Background',
                                onTap: () async {
                                  final controller = ref.read(playerControllerProvider.notifier);
                                  await controller.playVideo(
                                    video,
                                    quality: 'audio',
                                    surface: PlayerSurface.mini,
                                  );
                                  await controller.toggleBackgroundAudio();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Background mode enabled'),
                                      ),
                                    );
                                  }
                                },
                              ),
                              ActionItem(
                                icon: Icons.crop_square,
                                label: 'Popup',
                                onTap: () async {
                                  final controller = ref.read(playerControllerProvider.notifier);
                                  await controller.playVideo(
                                    video,
                                    quality: ref.read(preferredQualityProvider),
                                    surface: PlayerSurface.popup,
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Popup mode enabled')),
                                    );
                                  }
                                },
                              ),
                              ActionItem(
                                icon: Icons.download,
                                label: 'Download',
                                onTap: () async {
                                  if (context.mounted) {
                                    await _showQualitySelectionDialog(context, ref, video, safeDetails);
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Description',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Description coming soon',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.70),
                            ),
                          ),
                          const SizedBox(height: 16),
                          CommentsSection(comments: safeDetails.comments),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Failed to load details: $err')),
      ),
    );
  }

  VideoDetails _buildSafeDetails(VideoDetails details) {
    return VideoDetails(
      id: details.id.isNotEmpty ? details.id : video.id,
      title: details.title.isNotEmpty ? details.title : video.title,
      channelName: details.channelName.isNotEmpty
          ? details.channelName
          : video.channelName,
      channelId: details.channelId.isNotEmpty ? details.channelId : video.channelId,
      subscriberCount: details.subscriberCount,
      viewCount: details.viewCount > 0 ? details.viewCount : video.views,
      uploadDate: details.uploadDate.isNotEmpty
          ? details.uploadDate
          : video.uploadDate.toIso8601String(),
      duration: details.duration > Duration.zero ? details.duration : video.duration,
      thumbnailUrl: details.thumbnailUrl.isNotEmpty
          ? details.thumbnailUrl
          : video.thumbnail,
      likeCount: details.likeCount,
      dislikeCount: details.dislikeCount,
      comments: details.comments,
    );
  }

  String _buildOutputPath(
    String folder,
    VideoDetails details, {
    required bool audioOnly,
  }) {
    final home = Platform.environment['HOME'] ?? '.';
    final basePath = folder.startsWith('~/')
        ? '$home/${folder.substring(2)}'
        : (folder.trim().isEmpty ? '$home/Downloads/Tubular' : folder);

    final safeTitle = details.title
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    final ext = audioOnly ? '.m4a' : '.mp4';
    return '$basePath/$safeTitle$ext';
  }

  Future<void> _showQualitySelectionDialog(
    Video video,
    VideoDetails details,
  ) async {
    final selectedQuality = await showDialog<String>(
      context: context,
      builder: (context) => _QualitySelectionDialog(
        currentQuality: ref.read(preferredQualityProvider),
      ),
    );

    if (selectedQuality != null && context.mounted) {
      await _performDownload(
        context,
        ref,
        video,
        details,
        selectedQuality,
      );
    }
  }

  Future<void> _performDownload(
    BuildContext context,
    WidgetRef ref,
    Video video,
    VideoDetails details,
    String quality,
  ) async {
    final api = ref.read(apiServiceProvider);
    final audioOnly = quality == 'audio';
    final folder = ref.read(downloadFolderProvider);
    final outputPath = _buildOutputPath(
      folder,
      details,
      audioOnly: audioOnly,
    );
    int? id;

    try {
      await File(outputPath).parent.create(recursive: true);

      id = await api.createDownload(
        video.id,
        details.title,
        outputPath,
        quality,
      );

      if (id != null) {
        await api.updateDownloadProgress(
          id,
          'downloading',
          0.0,
          0.0,
          0,
        );
      }

      await api.downloadVideo(
        videoId: video.id,
        outputPath: outputPath,
        quality: quality,
        audioOnly: audioOnly,
      );

      if (id != null) {
        final fileSize = await File(outputPath)
            .length()
            .catchError((_) => 0);
        await api.completeDownload(id, fileSize);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download complete: $outputPath')),
        );
      }
    } catch (e) {
      if (id != null) {
        await api.failDownload(id, e.toString());
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

}

class _QualitySelectionDialog extends StatefulWidget {
  final String currentQuality;

  const _QualitySelectionDialog({required this.currentQuality});

  @override
  State<_QualitySelectionDialog> createState() => _QualitySelectionDialogState();
}

class _QualitySelectionDialogState extends State<_QualitySelectionDialog> {
  late String _selectedQuality;

  static const List<QualityOption> qualityOptions = [
    QualityOption('best', 'Best (Auto)', Icons.auto_awesome, true),
    QualityOption('1080p', '1080p (Full HD)', Icons.high_quality, false),
    QualityOption('720p', '720p (HD)', Icons.high_quality, false),
    QualityOption('480p', '480p (SD)', Icons.high_quality, false),
    QualityOption('360p', '360p (Low)', Icons.high_quality, false),
    QualityOption('audio', 'Audio Only', Icons.headphones, false),
  ];

  @override
  void initState() {
    super.initState();
    _selectedQuality = widget.currentQuality;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.file_download, color: Colors.red),
          SizedBox(width: 8),
          Text('Select Download Quality'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...qualityOptions.map((option) {
              final isSelected = _selectedQuality == option.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() => _selectedQuality = option.value);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? Colors.red[700]!
                              : Colors.grey[600]!,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: isSelected
                            ? Colors.red[700]!.withValues(alpha: 0.1)
                            : Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          if (isSelected)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.red[700],
                                size: 22,
                              ),
                            )
                          else
                            const SizedBox(width: 22 + 8),
                          Icon(option.icon, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option.label,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (option.isRecommended)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 2),
                                    child: Text(
                                      'Recommended',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton.tonal(
          onPressed: () => Navigator.pop(context, _selectedQuality),
          child: const Text('Download'),
        ),
      ],
    );
  }
}

class QualityOption {
  final String value;
  final String label;
  final IconData icon;
  final bool isRecommended;

  const QualityOption(
    this.value,
    this.label,
    this.icon,
    this.isRecommended,
  );
}
