import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../controllers/player_controller.dart';
import '../models/video.dart';
import '../providers.dart';
import '../widgets/error_widget.dart';
import '../widgets/video_card.dart';
import 'video_details_screen.dart';

class TrendingScreen extends ConsumerWidget {
  const TrendingScreen({super.key});

  void _openVideo(BuildContext context, Video video) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VideoDetailsScreen(video: video)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingAsync = ref.watch(trendingVideosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trending'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: trendingAsync.when(
        data: (videos) {
          if (videos.isEmpty) {
            return _EmptyTrendingState(onRetry: () => ref.refresh(trendingVideosProvider));
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(trendingVideosProvider);
              await ref.read(trendingVideosProvider.future);
            },
            child: MasonryGridView.count(
              crossAxisCount: _getCrossAxisCount(context),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              padding: const EdgeInsets.all(8),
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];
                return VideoCard(
                  video: video,
                  onTap: () => _openVideo(context, video),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorDisplay(
          message: 'Trending error',
          details: error.toString(),
          onRetry: () => ref.refresh(trendingVideosProvider),
        ),
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1600) return 5;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }
}

class _EmptyTrendingState extends StatelessWidget {
  final VoidCallback onRetry;

  const _EmptyTrendingState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.whatshot_outlined, size: 64, color: Colors.grey[500]),
          const SizedBox(height: 16),
          const Text(
            'No trending videos right now',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Try again later or refresh the feed.',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}