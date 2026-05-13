import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import 'player_screen.dart';
import '../controllers/player_controller.dart';
import '../models/video.dart';
import '../widgets/video_card.dart';

final bookmarkSearchProvider = StateProvider<String>((ref) => '');

final filteredBookmarksProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final bookmarks = ref.watch(bookmarksProvider);
  final search = ref.watch(bookmarkSearchProvider);
  
  final items = (bookmarks.valueOrNull ?? [])
      .map((item) => Map<String, dynamic>.from(item as Map))
      .toList();
  
  if (search.isEmpty) {
    return items;
  }
  
  return items.where((bookmark) {
    final title = (bookmark['title'] ?? '').toString().toLowerCase();
    final channel = (bookmark['channel'] ?? '').toString().toLowerCase();
    final searchLower = search.toLowerCase();
    return title.contains(searchLower) || channel.contains(searchLower);
  }).toList();
});

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookmarksAsync = ref.watch(filteredBookmarksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarked Videos'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.grey[850],
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                ref.read(bookmarkSearchProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                hintText: 'Search bookmarks...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                filled: true,
                fillColor: Colors.grey[800],
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(bookmarkSearchProvider.notifier).state = '';
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
          // Bookmarks list
          Expanded(
            child: bookmarksAsync.when(
              data: (bookmarks) {
                if (bookmarks.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: bookmarks.length,
                  itemBuilder: (context, index) {
                    final bookmark = bookmarks[index];
                    return _buildBookmarkTile(context, bookmark, ref);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorState(error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            'No bookmarks yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[400]),
          ),
          const SizedBox(height: 8),
          Text(
            'Save videos to view them later',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Error loading bookmarks',
            style: TextStyle(fontSize: 18, color: Colors.red[400]),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkTile(BuildContext context, Map<String, dynamic> bookmark, WidgetRef ref) {
    final videoId = bookmark['video_id'] as String? ?? '';
    final title = bookmark['title'] as String? ?? 'Unknown';
    final channel = bookmark['channel'] as String? ?? 'Unknown';
    final thumbnail = bookmark['thumbnail'] as String? ?? '';
    final duration = bookmark['duration'] as int? ?? 0;
    final bookmarkedAt = bookmark['bookmarked_at'] as String? ?? '';

    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: thumbnail.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  thumbnail,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[700],
                      child: const Icon(Icons.video_library, color: Colors.grey),
                    );
                  },
                ),
              )
            : Container(
                width: 60,
                height: 60,
                color: Colors.grey[700],
                child: const Icon(Icons.video_library, color: Colors.grey),
              ),
        title: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          channel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'play',
              child: Row(
                children: const [
                  Icon(Icons.play_arrow, size: 18),
                  SizedBox(width: 8),
                  Text('Play'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'remove',
              child: Row(
                children: const [
                  Icon(Icons.bookmark, size: 18),
                  SizedBox(width: 8),
                  Text('Remove'),
                ],
              ),
            ),
          ],
          onSelected: (value) async {
            if (value == 'play') {
              _playVideo(context, videoId, title, channel, thumbnail, duration, ref);
            } else if (value == 'remove') {
              _removeBookmark(videoId, ref);
            }
          },
        ),
        onTap: () {
          _playVideo(context, videoId, title, channel, thumbnail, duration, ref);
        },
      ),
    );
  }

  Future<void> _playVideo(
    BuildContext context,
    String videoId,
    String title,
    String channel,
    String thumbnail,
    int duration,
    WidgetRef ref,
  ) async {
    final video = Video(
      id: videoId,
      title: title,
      channelName: channel,
      thumbnail: thumbnail,
      description: '',
    );

    final controller = ref.read(playerControllerProvider.notifier);
    await controller.playVideo(video);

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PlayerScreen(video: video)),
      );
    }
  }

  Future<void> _removeBookmark(String videoId, WidgetRef ref) async {
    final apiService = ref.read(apiServiceProvider);
    
    final result = await apiService.removeBookmark(videoId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.success 
            ? '❌ Bookmark removed' 
            : 'Failed to remove bookmark'),
        ),
      );
      
      if (result.success) {
        // Invalidate bookmark providers to refresh
        ref.invalidate(bookmarksProvider);
        ref.invalidate(filteredBookmarksProvider);
      }
    }
  }
}
