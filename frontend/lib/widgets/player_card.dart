import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../models/video.dart';

/// Compact player card for multi-window mode
class PlayerCard extends ConsumerWidget {
  final String videoId;
  final bool compact;

  const PlayerCard({
    required this.videoId,
    this.compact = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoDetails = ref.watch(videoDetailsProvider(videoId));
    final focusedPlayer = ref.watch(focusedPlayerProvider);
    final isFocused = focusedPlayer == videoId;

    return Card(
      margin: const EdgeInsets.all(4),
      elevation: isFocused ? 8 : 2,
      child: Container(
        color: Colors.black,
        child: Column(
          children: [
            // Video preview area
            Expanded(
              child: Stack(
                children: [
                  Container(
                    color: Colors.black87,
                    child: videoDetails.when(
                      data: (video) => Stack(
                        children: [
                          // Thumbnail
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(video.thumbnailUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          // Play button overlay
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(16),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                        ],
                      ),
                      loading: () => const Center(
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                          ),
                        ),
                      ),
                      error: (err, stack) => Center(
                        child: Text(
                          'Error loading video',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                  // Title bar
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.black87,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: videoDetails.when(
                              data: (video) => Text(
                                video.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              loading: () =>
                                  const Text('Loading...', style: TextStyle(color: Colors.white, fontSize: 12)),
                              error: (err, stack) => const Text('Error', style: TextStyle(color: Colors.red, fontSize: 12)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              ref.read(activePlayersProvider.notifier).state =
                                  ref.read(activePlayersProvider).where((id) => id != videoId).toList();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red[700],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Mini controls
            Container(
              color: Colors.grey[900],
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Play button
                  IconButton(
                    icon: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
                    onPressed: () {
                      // Would trigger playback in the main player
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Playing in main player')),
                      );
                    },
                    iconSize: 20,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                  // Pause button
                  IconButton(
                    icon: const Icon(Icons.pause, color: Colors.white, size: 20),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Paused')),
                      );
                    },
                    iconSize: 20,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                  // Focus button
                  if (!isFocused)
                    IconButton(
                      icon: const Icon(Icons.fullscreen, color: Colors.white, size: 20),
                      onPressed: () {
                        ref.read(focusedPlayerProvider.notifier).state = videoId;
                      },
                      iconSize: 20,
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
