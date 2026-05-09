import 'package:flutter/material.dart';

import '../../models/video_details.dart';

class CommentsSection extends StatelessWidget {
  const CommentsSection({super.key, required this.comments});

  final List<Comment> comments;

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.70);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comments',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (comments.isEmpty)
          Text(
            'No comments available',
            style: TextStyle(color: secondary),
          )
        else
          ...comments.map((comment) => _buildCommentTile(comment, secondary)),
      ],
    );
  }

  Widget _buildCommentTile(Comment comment, Color secondary) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey[700],
            child: Text(
              comment.username.isNotEmpty
                  ? comment.username[0].toUpperCase()
                  : '?',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      comment.username,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      comment.publishedText.isNotEmpty
                          ? comment.publishedText
                          : _timeAgo(comment.timestamp),
                      style: TextStyle(color: secondary, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.text),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.thumb_up, size: 16, color: secondary),
                    const SizedBox(width: 6),
                    Text('${comment.likeCount}'),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        '1 REPLY',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} minutes ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    }
    return '${diff.inDays} days ago';
  }
}
