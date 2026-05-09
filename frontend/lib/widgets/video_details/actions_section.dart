import 'package:flutter/material.dart';

class ActionItem {
  const ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class ActionsSection extends StatelessWidget {
  const ActionsSection({super.key, required this.items});

  final List<ActionItem> items;

  @override
  Widget build(BuildContext context) {
    final foreground = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.90);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: items
          .map(
            (item) => GestureDetector(
              onTap: item.onTap,
              child: Column(
                children: [
                  Icon(item.icon, size: 28, color: foreground),
                  const SizedBox(height: 6),
                  Text(
                    item.label,
                    style: TextStyle(fontSize: 12, color: foreground),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
