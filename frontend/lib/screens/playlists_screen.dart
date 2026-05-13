import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../models/video.dart';
import '../providers.dart';
import '../widgets/video_card.dart';
import 'video_details_screen.dart';

final playlistIdProvider = StateProvider<String>((ref) => '');

class PlaylistsScreen extends ConsumerStatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  ConsumerState<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends ConsumerState<PlaylistsScreen> {
  final TextEditingController _playlistController = TextEditingController();
  String _lastPlaylistId = '';

  @override
  void dispose() {
    _playlistController.dispose();
    super.dispose();
  }

  void _loadPlaylist() {
    final id = _playlistController.text.trim();
    if (id.isNotEmpty && id != _lastPlaylistId) {
      _lastPlaylistId = id;
      ref.read(playlistIdProvider.notifier).state = id;
    }
  }

  void _clearPlaylist() {
    _playlistController.clear();
    _lastPlaylistId = '';
    ref.read(playlistIdProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context) {
    final playlistId = ref.watch(playlistIdProvider);
    final playlistAsync = playlistId.isNotEmpty ? ref.watch(playlistProvider(playlistId)) : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlists'),
        backgroundColor: Colors.red[700],
      ),
      body: Column(
        children: [
          // Playlist input section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter Playlist ID',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _playlistController,
                        decoration: InputDecoration(
                          hintText: 'e.g., PLrAXtmErZgOeiKm4sgNOknGvNjby9efdf',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        onSubmitted: (_) => _loadPlaylist(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _loadPlaylist,
                      icon: const Icon(Icons.search),
                      label: const Text('Load'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                      ),
                    ),
                    if (playlistId.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _clearPlaylist,
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[700],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Playlist content
          if (playlistAsync != null)
            Expanded(
              child: playlistAsync.when(
                data: (data) {
                  final title = data['title'] as String? ?? 'Playlist';
                  final author = data['author'] as String? ?? 'Unknown';
                  final videoCount = data['video_count'] as int? ?? 0;
                  final videos = data['videos'] as List<dynamic>? ?? [];

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Playlist header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$author • $videoCount videos',
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        // Videos grid
                        if (videos.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Text(
                                'No videos in this playlist',
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: MasonryGridView.count(
                              crossAxisCount: _getCrossAxisCount(context),
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: videos.length,
                              itemBuilder: (context, index) {
                                try {
                                  final video = Video.fromJson(
                                    Map<String, dynamic>.from(videos[index] as Map),
                                  );
                                  return VideoCard(
                                    video: video,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            VideoDetailsScreen(video: video),
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                          ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (err, st) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text('Failed to load playlist'),
                      const SizedBox(height: 4),
                      Text(
                        err.toString(),
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.playlist_play, size: 64, color: Colors.grey[700]),
                    const SizedBox(height: 16),
                    const Text(
                      'Enter a playlist ID to get started',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You can find playlist IDs in YouTube URLs',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            ),
        ],
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
