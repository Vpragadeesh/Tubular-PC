import 'package:flutter/material.dart';

import '../../models/video_details.dart';

enum CommentSortOrder {
  top,      // Most liked
  newest,   // Most recent
  oldest,   // Oldest first
}

class CommentsSection extends StatefulWidget {
  const CommentsSection({super.key, required this.comments});

  final List<Comment> comments;

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  late CommentSortOrder _sortOrder = CommentSortOrder.top;

  List<Comment> get _sortedComments {
    final comments = List<Comment>.from(widget.comments);
    
    switch (_sortOrder) {
      case CommentSortOrder.top:
        // Sort by like count (descending)
        comments.sort((a, b) => b.likeCount.compareTo(a.likeCount));
        break;
      case CommentSortOrder.newest:
        // Sort by timestamp (newest first)
        comments.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
      case CommentSortOrder.oldest:
        // Sort by timestamp (oldest first)
        comments.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        break;
    }
    
    return comments;
  }

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.70);
    final sortedComments = _sortedComments;

    return ListView(
      children: [
        // Sort selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Comments (${widget.comments.length})',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              DropdownButton<CommentSortOrder>(
                value: _sortOrder,
                icon: const Icon(Icons.sort),
                underline: const SizedBox.shrink(),
                items: [
                  DropdownMenuItem(
                    value: CommentSortOrder.top,
                    child: const Text('Top Comments'),
                  ),
                  DropdownMenuItem(
                    value: CommentSortOrder.newest,
                    child: const Text('Newest'),
                  ),
                  DropdownMenuItem(
                    value: CommentSortOrder.oldest,
                    child: const Text('Oldest'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _sortOrder = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),
        if (widget.comments.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'No comments available',
                style: TextStyle(color: secondary),
              ),
            ),
          )
        else
          ...sortedComments
              .map((comment) => _buildCommentTile(comment, secondary))
              .toList(),
      ],
    );
  }

  Widget _buildCommentTile(Comment comment, Color secondary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
