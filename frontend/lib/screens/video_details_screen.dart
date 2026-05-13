import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/video.dart';
import '../models/video_details.dart';
import '../providers.dart';
import '../controllers/player_controller.dart';
import '../screens/player_screen.dart';
import '../widgets/video_details/actions_section.dart';
import '../widgets/video_details/comments_section.dart';
import '../widgets/video_details/recommended_videos_section.dart';
import '../widgets/video_details/stats_section.dart';
import '../widgets/video_details/thumbnail_section.dart';
import '../widgets/video_details/transcripts_section.dart';
import '../widgets/video_details/chapters_section.dart';

class VideoDetailsScreen extends ConsumerStatefulWidget {
  final Video video;

  const VideoDetailsScreen({super.key, required this.video});

  @override
  ConsumerState<VideoDetailsScreen> createState() => _VideoDetailsScreenState();
}

class _VideoDetailsScreenState extends ConsumerState<VideoDetailsScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(videoDetailsProvider(widget.video.id));

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
                        await ref.read(playerControllerProvider.notifier).playVideo(widget.video);
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => PlayerScreen(video: widget.video)),
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
                                icon: Icons.bookmark_outline,
                                label: 'Bookmark',
                                onTap: () async {
                                  final apiService = ref.read(apiServiceProvider);
                                  
                                  // Check if already bookmarked
                                  final checkResult = await apiService.isBookmarked(widget.video.id);
                                  final isBookmarked = checkResult.data ?? false;
                                  
                                  if (isBookmarked) {
                                    // Remove bookmark
                                    final result = await apiService.removeBookmark(widget.video.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(result.success 
                                            ? '❌ Bookmark removed' 
                                            : 'Failed to remove bookmark'),
                                        ),
                                      );
                                      // Invalidate bookmark providers to refresh
                                      ref.invalidate(bookmarksProvider);
                                      ref.invalidate(isBookmarkedProvider(widget.video.id));
                                    }
                                  } else {
                                    // Add bookmark
                                    final result = await apiService.addBookmark(
                                      videoId: widget.video.id,
                                      title: widget.video.title,
                                      channel: widget.video.channelName,
                                      thumbnail: widget.video.thumbnail,
                                      duration: int.tryParse(widget.video.duration.toString()) ?? 0,
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(result.success 
                                            ? '✅ Bookmark added' 
                                            : 'Failed to add bookmark'),
                                        ),
                                      );
                                      // Invalidate bookmark providers to refresh
                                      ref.invalidate(bookmarksProvider);
                                      ref.invalidate(isBookmarkedProvider(widget.video.id));
                                    }
                                  }
                                },
                              ),
                              ActionItem(
                                icon: Icons.headset,
                                label: 'Background',
                                onTap: () async {
                                  final controller = ref.read(playerControllerProvider.notifier);
                                  await controller.playVideo(
                                    widget.video,
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
                                    widget.video,
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
                                    await _showQualitySelectionDialog(context, ref, widget.video, safeDetails);
                                  }
                                },
                              ),
                              ActionItem(
                                icon: Icons.share,
                                label: 'Share',
                                onTap: () async {
                                  // Create a shareable video URL
                                  // Using YouTube format: https://youtu.be/{videoId}
                                  final shareUrl = 'https://youtu.be/${widget.video.id}';
                                  
                                  // Copy to clipboard
                                  await Clipboard.setData(ClipboardData(text: shareUrl));
                                  
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('✅ Link copied to clipboard'),
                                        duration: const Duration(seconds: 2),
                                        action: SnackBarAction(
                                          label: 'Show',
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                title: const Text('Share Video'),
                                                content: SelectableText(
                                                  shareUrl,
                                                  style: const TextStyle(fontFamily: 'monospace'),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    child: const Text('Close'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                              ActionItem(
                                icon: Icons.open_in_new,
                                label: 'New Window',
                                onTap: () {
                                  final activePlayers = ref.read(activePlayersProvider.notifier);
                                  final currentPlayers = ref.read(activePlayersProvider);
                                  
                                  if (currentPlayers.length >= 4) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Maximum 4 windows allowed')),
                                    );
                                    return;
                                  }
                                  
                                  if (!currentPlayers.contains(widget.video.id)) {
                                    activePlayers.state = [...currentPlayers, widget.video.id];
                                    
                                    // Set as focused player if it's the first one
                                    if (currentPlayers.isEmpty) {
                                      ref.read(focusedPlayerProvider.notifier).state = widget.video.id;
                                      // Switch to multi-player layout
                                      ref.read(multiPlayerLayoutProvider.notifier).state = MultiPlayerLayout.single;
                                    }
                                    
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Opened in new window'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Already open in a window')),
                                    );
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
                          Container(
                            decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: Colors.grey[700]!)),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              labelColor: Colors.red[700],
                              unselectedLabelColor: Colors.grey[400],
                              indicatorColor: Colors.red[700],
                              tabs: const [
                                Tab(text: 'Comments'),
                                Tab(text: 'Transcripts'),
                                Tab(text: 'Chapters'),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 300,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                CommentsSection(comments: safeDetails.comments),
                                TranscriptsSection(subtitles: safeDetails.subtitles, videoId: widget.video.id),
                                ChaptersSection(chapters: safeDetails.chapters),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          RecommendedVideosSection(videoId: widget.video.id),
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
      id: details.id.isNotEmpty ? details.id : widget.video.id,
      title: details.title.isNotEmpty ? details.title : widget.video.title,
      channelName: details.channelName.isNotEmpty
          ? details.channelName
          : widget.video.channelName,
      channelId: details.channelId.isNotEmpty ? details.channelId : widget.video.channelId,
      subscriberCount: details.subscriberCount,
      viewCount: details.viewCount > 0 ? details.viewCount : widget.video.views,
      uploadDate: details.uploadDate.isNotEmpty
          ? details.uploadDate
          : widget.video.uploadDate.toIso8601String(),
      duration: details.duration > Duration.zero ? details.duration : widget.video.duration,
      thumbnailUrl: details.thumbnailUrl.isNotEmpty
          ? details.thumbnailUrl
          : widget.video.thumbnail,
      likeCount: details.likeCount,
      dislikeCount: details.dislikeCount,
      comments: details.comments,
      subtitles: details.subtitles,
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
    BuildContext context,
    WidgetRef ref,
    Video video,
    VideoDetails details,
  ) async {
    final selectedQuality = await showDialog<String>(
      context: context,
      builder: (dialogContext) => _QualitySelectionDialog(
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
        audioOnly: audioOnly,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download started: $outputPath')),
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
