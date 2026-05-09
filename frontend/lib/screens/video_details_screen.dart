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

  const VideoDetailsScreen({Key? key, required this.video}) : super(key: key);

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
                                  await ref
                                      .read(playerControllerProvider.notifier)
                                      .toggleAudioOnlyStream();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Toggled background/audio-only'),
                                      ),
                                    );
                                  }
                                },
                              ),
                              ActionItem(
                                icon: Icons.crop_square,
                                label: 'Popup',
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Popup mode coming soon')),
                                  );
                                },
                              ),
                              ActionItem(
                                icon: Icons.download,
                                label: 'Download',
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Queued download')),
                                  );
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
}
