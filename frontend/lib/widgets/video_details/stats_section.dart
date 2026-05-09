import 'package:flutter/material.dart';

import '../../models/video_details.dart';

class StatsSection extends StatelessWidget {
  const StatsSection({super.key, required this.details});

  final VideoDetails details;

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          details.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[700],
              child: Text(
                details.channelName.isNotEmpty
                    ? details.channelName[0].toUpperCase()
                    : '?',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    details.channelName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${details.subscriberCount} subscribers',
                    style: TextStyle(color: secondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${details.viewCount} views',
                  style: TextStyle(color: secondary),
                ),
                const SizedBox(height: 4),
                Text(
                  details.uploadDate,
                  style: TextStyle(color: secondary, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.thumb_up, size: 16, color: secondary),
            const SizedBox(width: 4),
            Text('${details.likeCount}'),
            const SizedBox(width: 16),
            Icon(Icons.thumb_down, size: 16, color: secondary),
            const SizedBox(width: 4),
            Text('${details.dislikeCount}'),
          ],
        ),
      ],
    );
  }
}
