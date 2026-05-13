import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../models/video.dart';

/// Drag-drop target for accepting video URLs
class DragDropTarget extends ConsumerWidget {
  final Widget child;

  const DragDropTarget({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) {
        // Accept any dragged content
        return true;
      },
      onAcceptWithDetails: (details) {
        _handleDroppedContent(context, ref, details.data);
      },
      builder: (context, candidateData, rejectedData) {
        return Material(
          color: candidateData.isNotEmpty
              ? Colors.red.withValues(alpha: 0.1)
              : Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              border: candidateData.isNotEmpty
                  ? Border.all(
                      color: Colors.red[700]!,
                      width: 3,
                      style: BorderStyle.solid,
                    )
                  : null,
            ),
            child: child,
          ),
        );
      },
    );
  }

  void _handleDroppedContent(
    BuildContext context,
    WidgetRef ref,
    String data,
  ) {
    // Try to extract video ID from various URL formats
    String? videoId = _extractVideoId(data);

    if (videoId != null && videoId.isNotEmpty) {
      _addVideoToPlayer(context, ref, videoId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invalid video URL'),
          backgroundColor: Colors.red[700],
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Extract video ID from various YouTube URL formats
  String? _extractVideoId(String input) {
    // youtube.com/watch?v=VIDEO_ID
    final watchRegex = RegExp(r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/.*[?&]v=)([^&\n?#]+)');
    final watchMatch = watchRegex.firstMatch(input);
    if (watchMatch != null) {
      return watchMatch.group(1);
    }

    // Invidious URLs
    final invidiousRegex = RegExp(r'(?:invidious\.io|iv\.\.)?(?:\/|watch\?v=)([^&\n?#]+)');
    final invidiousMatch = invidiousRegex.firstMatch(input);
    if (invidiousMatch != null) {
      return invidiousMatch.group(1);
    }

    // Plain video ID (11 characters)
    if (RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(input)) {
      return input;
    }

    return null;
  }

  void _addVideoToPlayer(
    BuildContext context,
    WidgetRef ref,
    String videoId,
  ) async {
    final api = ref.read(apiServiceProvider);
    final activePlayers = ref.read(activePlayersProvider);

    // Check if already open
    if (activePlayers.contains(videoId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video already open in a window'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Check max windows
    if (activePlayers.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Maximum 4 windows allowed'),
          backgroundColor: Colors.red[700],
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Validate video exists by trying to fetch details
    try {
      final result = await api.getVideoDetails(videoId);
      if (result.id.isNotEmpty) {
        // Add to active players
        ref.read(activePlayersProvider.notifier).state = [
          ...activePlayers,
          videoId,
        ];

        // Set as focused if it's the first one
        if (activePlayers.isEmpty) {
          ref.read(focusedPlayerProvider.notifier).state = videoId;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added to player: ${result.title}'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green[700],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Video not found'),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red[700],
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
