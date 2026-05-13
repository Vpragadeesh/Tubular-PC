import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

/// Controls for multi-window playback
class MultiPlayerControls extends ConsumerWidget {
  final VoidCallback onOpenNewWindow;

  const MultiPlayerControls({
    required this.onOpenNewWindow,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePlayers = ref.watch(activePlayersProvider);
    final layout = ref.watch(multiPlayerLayoutProvider);

    if (activePlayers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.grey[850],
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          const Text(
            'Multi-window:',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(width: 8),
          // Layout selector
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _LayoutButton(
                    label: '1x1',
                    isSelected: layout == MultiPlayerLayout.single,
                    onPressed: () {
                      ref.read(multiPlayerLayoutProvider.notifier).state = MultiPlayerLayout.single;
                    },
                  ),
                  if (activePlayers.length > 1) ...[
                    const SizedBox(width: 4),
                    _LayoutButton(
                      label: '1x2',
                      isSelected: layout == MultiPlayerLayout.splitHorizontal,
                      onPressed: () {
                        ref.read(multiPlayerLayoutProvider.notifier).state = MultiPlayerLayout.splitHorizontal;
                      },
                    ),
                    const SizedBox(width: 4),
                    _LayoutButton(
                      label: '2x1',
                      isSelected: layout == MultiPlayerLayout.splitVertical,
                      onPressed: () {
                        ref.read(multiPlayerLayoutProvider.notifier).state = MultiPlayerLayout.splitVertical;
                      },
                    ),
                  ],
                  if (activePlayers.length > 3) ...[
                    const SizedBox(width: 4),
                    _LayoutButton(
                      label: '2x2',
                      isSelected: layout == MultiPlayerLayout.grid2x2,
                      onPressed: () {
                        ref.read(multiPlayerLayoutProvider.notifier).state = MultiPlayerLayout.grid2x2;
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Open new window button
          if (activePlayers.length < 4)
            ElevatedButton.icon(
              onPressed: onOpenNewWindow,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('New Window'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ),
          const SizedBox(width: 8),
          // Player count indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red[700],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${activePlayers.length}/4',
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _LayoutButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _LayoutButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? Colors.red[700] : Colors.transparent,
        side: BorderSide(color: isSelected ? Colors.red[700]! : Colors.grey),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[300],
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
