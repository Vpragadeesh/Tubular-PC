import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/video.dart';
import '../models/dislike.dart';

class VideoCard extends StatefulWidget {
  final Video video;
  final VoidCallback onTap;
  final DislikeData? dislikeData;
  final VoidCallback? onSubscribe;

  const VideoCard({
    required this.video,
    required this.onTap,
    this.dislikeData,
    this.onSubscribe,
    super.key,
  });

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovering = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovering = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: _isHovering ? 8 : 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: InkWell(
            onTap: widget.onTap,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail with overlay
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: widget.video.thumbnail,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[800],
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[800],
                          child: const Icon(Icons.error, color: Colors.white),
                        ),
                      ),
                      // Hover overlay
                      if (_isHovering)
                        AnimatedOpacity(
                          opacity: _isHovering ? 0.3 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(color: Colors.black),
                        ),
                      // Play icon on hover
                      if (_isHovering)
                        Center(
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Icon(
                              Icons.play_circle_filled,
                              color: Colors.white,
                              size: 60,
                            ),
                          ),
                        ),
                      // Duration badge
                      if (widget.video.duration > Duration.zero)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              widget.video.formattedDuration,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Video info
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.video.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                         ),
                         const SizedBox(height: 6),
                         Row(
                           children: [
                             Flexible(
                               child: Text(
                                 widget.video.channelName,
                                 maxLines: 1,
                                 overflow: TextOverflow.ellipsis,
                                 style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                               ),
                             ),
                              if (widget.onSubscribe != null) ...[
                                const SizedBox(width: 8),
                                SizedBox(
                                  height: 24,
                                  child: GestureDetector(
                                    onTap: widget.onSubscribe,
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red[700],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.add, size: 14, color: Colors.white),
                                          const SizedBox(width: 4),
                                          const Text(
                                            'Subscribe',
                                            style: TextStyle(fontSize: 11, color: Colors.white),
                                          ),
                                          const SizedBox(width: 6),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                           ],
                         ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.video.formattedViews} views • ${widget.video.uploadedAgo}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        // Dislike information with better display
                        if (widget.dislikeData != null) ...[
                          const SizedBox(height: 8),
                          _buildDislikeBar(widget.dislikeData!),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.thumb_up,
                                  size: 14, color: Colors.green[600]),
                              const SizedBox(width: 4),
                              Text(
                                widget.dislikeData!.formattedLikes,
                                style: TextStyle(
                                    fontSize: 11, color: Colors.green[600]),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.thumb_down,
                                  size: 14, color: Colors.red[600]),
                              const SizedBox(width: 4),
                              Text(
                                widget.dislikeData!.formattedDislikes,
                                style: TextStyle(
                                    fontSize: 11, color: Colors.red[600]),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDislikeBar(DislikeData data) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        height: 4,
        child: Row(
          children: [
            Flexible(
              flex: (data.likePercentage * 100).toInt(),
              child: Container(color: Colors.green[600]),
            ),
            Flexible(
              flex: (data.dislikePercentage * 100).toInt(),
              child: Container(color: Colors.red[600]),
            ),
          ],
        ),
      ),
    );
  }
}

