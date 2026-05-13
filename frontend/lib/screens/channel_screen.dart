import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/video.dart';
import '../services/api_service.dart';
import 'video_details_screen.dart';
import 'package:intl/intl.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final channelInfoProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, channelId) async {
  final apiService = ref.read(apiServiceProvider);
  final result = await apiService.getChannelInfo(channelId);
  if (result.success && result.data != null) {
    return result.data!;
  }
  throw Exception(result.error ?? 'Failed to load channel info');
});

final channelVideosProvider = FutureProvider.family<List<Video>, String>((ref, channelId) async {
  final apiService = ref.read(apiServiceProvider);
  final result = await apiService.getChannelVideos(channelId, page: 1);
  if (result.success && result.data != null) {
    return result.data!;
  }
  throw Exception(result.error ?? 'Failed to load videos');
});

class ChannelScreen extends ConsumerWidget {
  final String channelId;
  final String initialChannelName;

  const ChannelScreen({
    super.key,
    required this.channelId,
    required this.initialChannelName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelInfoAsync = ref.watch(channelInfoProvider(channelId));
    final channelVideosAsync = ref.watch(channelVideosProvider(channelId));

    return Scaffold(
      appBar: AppBar(
        title: Text(initialChannelName),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: channelInfoAsync.when(
              data: (info) => _buildChannelHeader(context, ref, info),
              loading: () => const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => SizedBox(
                height: 100,
                child: Center(child: Text('Error loading channel: $err')),
              ),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.symmetric(vertical: 8),
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Videos',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          channelVideosAsync.when(
            data: (videos) {
              if (videos.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No videos found'),
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final video = videos[index];
                    return _buildVideoItem(context, video);
                  },
                  childCount: videos.length,
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (err, stack) => SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text('Error loading videos: $err'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelHeader(BuildContext context, WidgetRef ref, Map<String, dynamic> info) {
    final subCount = info['subCount'] != null ? NumberFormat.compact().format(info['subCount']) : '';
    final description = info['description'] ?? '';
    final isSubscribed = false; // TODO: Hook up to subscriptions state

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (info['authorBanners'] != null && (info['authorBanners'] as List).isNotEmpty)
          Image.network(
            info['authorBanners'].last['url'],
            height: 120,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 120,
              color: Colors.grey[800],
              child: const Icon(Icons.broken_image),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (info['authorThumbnails'] != null && (info['authorThumbnails'] as List).isNotEmpty)
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(info['authorThumbnails'].last['url']),
                    )
                  else
                    const CircleAvatar(
                      radius: 40,
                      child: Icon(Icons.person, size: 40),
                    ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          info['author'] ?? initialChannelName,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subCount.isNotEmpty ? '$subCount subscribers' : 'Channel',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            // TODO subscribe functionality
                          },
                          icon: Icon(isSubscribed ? Icons.notifications_active : Icons.notifications_none),
                          label: Text(isSubscribed ? 'Subscribed' : 'Subscribe'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSubscribed ? Colors.grey[800] : Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Channel description
              if (description.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[300],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildVideoItem(BuildContext context, Video video) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoDetailsScreen(video: video),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            SizedBox(
              width: 160,
              height: 90,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      video.thumbnail,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[800],
                        child: const Center(child: Icon(Icons.broken_image)),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _formatDuration(video.duration),
                        style: const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${NumberFormat.compact().format(video.views)} views',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    if (duration.inHours > 0) {
      return '${duration.inHours}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}';
    }
    return '${duration.inMinutes.remainder(60)}:${twoDigits(duration.inSeconds.remainder(60))}';
  }
}
