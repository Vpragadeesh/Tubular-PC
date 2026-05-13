import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import 'player_card.dart';

/// Multi-player layout widget for displaying 1-4 videos side-by-side
class MultiPlayerLayoutWidget extends ConsumerWidget {
  const MultiPlayerLayoutWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePlayers = ref.watch(activePlayersProvider);
    final layout = ref.watch(multiPlayerLayoutProvider);

    // If no active players, show empty state
    if (activePlayers.isEmpty) {
      return const Center(
        child: Text('No videos playing. Open a video to start.'),
      );
    }

    // Single player mode
    if (activePlayers.length == 1 || layout == MultiPlayerLayout.single) {
      return _buildSinglePlayer(context, ref, activePlayers[0]);
    }

    // Multi-player modes
    return switch (layout) {
      MultiPlayerLayout.splitHorizontal => _buildSplitHorizontal(context, ref, activePlayers),
      MultiPlayerLayout.splitVertical => _buildSplitVertical(context, ref, activePlayers),
      MultiPlayerLayout.grid2x2 => _buildGrid2x2(context, ref, activePlayers),
      MultiPlayerLayout.single => _buildSinglePlayer(context, ref, activePlayers[0]),
    };
  }

  /// Single player (full width/height)
  Widget _buildSinglePlayer(BuildContext context, WidgetRef ref, String videoId) {
    return PlayerCard(videoId: videoId);
  }

  /// Split horizontal - 2 players side-by-side
  Widget _buildSplitHorizontal(BuildContext context, WidgetRef ref, List<String> activePlayers) {
    return Row(
      children: [
        Expanded(
          child: PlayerCard(videoId: activePlayers[0], compact: true),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: activePlayers.length > 1
              ? PlayerCard(videoId: activePlayers[1], compact: true)
              : const Center(child: Text('Open a video\nin this window')),
        ),
      ],
    );
  }

  /// Split vertical - 2 players stacked
  Widget _buildSplitVertical(BuildContext context, WidgetRef ref, List<String> activePlayers) {
    return Column(
      children: [
        Expanded(
          child: PlayerCard(videoId: activePlayers[0], compact: true),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: activePlayers.length > 1
              ? PlayerCard(videoId: activePlayers[1], compact: true)
              : const Center(child: Text('Open a video\nin this window')),
        ),
      ],
    );
  }

  /// 2x2 grid - 4 players
  Widget _buildGrid2x2(BuildContext context, WidgetRef ref, List<String> activePlayers) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: PlayerCard(videoId: activePlayers[0], compact: true),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: activePlayers.length > 1
                    ? PlayerCard(videoId: activePlayers[1], compact: true)
                    : const Center(child: Text('Open\nvideo')),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: activePlayers.length > 2
                    ? PlayerCard(videoId: activePlayers[2], compact: true)
                    : const Center(child: Text('Open\nvideo')),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: activePlayers.length > 3
                    ? PlayerCard(videoId: activePlayers[3], compact: true)
                    : const Center(child: Text('Open\nvideo')),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
