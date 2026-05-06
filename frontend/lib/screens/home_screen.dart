import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../controllers/player_controller.dart';
import '../models/video.dart';
import '../services/api_service.dart';
import '../widgets/video_card.dart';
import '../widgets/error_widget.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider.autoDispose<ApiResult<List<Video>>>((
  ref,
) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) {
    return (
      success: true,
      data: <Video>[],
      error: null,
      details: null,
    );
  }

  final apiService = ref.watch(apiServiceProvider);
  return await apiService.searchVideos(query);
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _lastSearchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty && query != _lastSearchQuery) {
      _lastSearchQuery = query;
      ref.read(searchQueryProvider.notifier).state = query;
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _lastSearchQuery = '';
    ref.read(searchQueryProvider.notifier).state = '';
  }

  void _openVideo(Video video) {
    ref.read(playerControllerProvider.notifier).playVideo(video);
  }

  void _subscribeToChannel(BuildContext context, Video video) async {
    final apiService = ref.read(apiServiceProvider);
    try {
      await apiService.subscribeFromVideo(
        channelId: video.channelId,
        channelName: video.channelName,
        thumbnail: video.thumbnail,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Subscribed to ${video.channelName}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to subscribe: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tubular PC'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Search videos...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: _clearSearch,
                        tooltip: 'Clear',
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _performSearch,
                  icon: const Icon(Icons.search),
                  label: const Text('Search'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: searchResults.when(
        data: (result) {
          // Handle error state
          if (!result.success) {
            return ErrorDisplay(
              message: result.error ?? 'Unknown error',
              details: result.details,
              onRetry: () => ref.refresh(searchResultsProvider),
            );
          }

          final videos = result.data ?? [];

          if (videos.isEmpty && ref.read(searchQueryProvider).isEmpty) {
            // Show featured videos on initial load
            return _buildFeaturedVideos();
          } else if (videos.isEmpty) {
            return _buildEmptySearchResults();
          }

          return MasonryGridView.count(
            crossAxisCount: _getCrossAxisCount(context),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            padding: const EdgeInsets.all(8),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return VideoCard(
                video: video,
                onTap: () => _openVideo(video),
                onSubscribe: () => _subscribeToChannel(context, video),
              );
            },
          );
        },
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Searching YouTube...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This may take 10-30 seconds on first search',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
        error: (error, stack) => ErrorDisplay(
          message: 'Search error',
          details: error.toString(),
          onRetry: () => ref.refresh(searchResultsProvider),
        ),
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  Widget _buildFeaturedVideos() {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Icon(Icons.play_circle_outline, size: 80, color: Colors.red[400]),
              const SizedBox(height: 24),
              const Text(
                'Welcome to Tubular PC',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Ad-free video streaming with privacy in mind',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[700]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Try searching for:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children:
                          [
                                'Flutter',
                                'Rust',
                                'Desktop',
                                'Tutorial',
                                'Development',
                              ]
                              .map(
                                (tag) => OutlinedButton(
                                  onPressed: () {
                                    _searchController.text = tag;
                                    _performSearch();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.grey[850],
                                    side: BorderSide(color: Colors.red[700]!),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: Text(
                                    tag,
                                    style: TextStyle(
                                      color: Colors.red[400],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No videos found for "${_searchController.text}"',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            'Example searches:',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Flutter', 'Rust', 'Desktop', 'Tutorial']
                .map(
                  (tag) => ActionChip(
                    label: Text(tag),
                    onPressed: () {
                      _searchController.text = tag;
                      _performSearch();
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
