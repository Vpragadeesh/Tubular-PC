import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/video.dart';
import '../models/dislike.dart';

class VideoCard extends StatelessWidget {
  final Video video;
  final VoidCallback onTap;
  final DislikeData? dislikeData;

  const VideoCard({
    required this.video,
    required this.onTap,
    this.dislikeData,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: video.thumbnail,
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
                  // Duration badge
                  if (video.duration > Duration.zero)
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
                          video.formattedDuration,
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
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    video.channelName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                   const SizedBox(height: 2),
                   Text(
                     '${video.formattedViews} views • ${video.uploadedAgo}',
                     style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                   ),
                   if (dislikeData != null) ...[
                     const SizedBox(height: 6),
                     Row(
                       children: [
                         Icon(Icons.thumb_up, size: 14, color: Colors.green[600]),
                         const SizedBox(width: 4),
                         Text(
                           dislikeData!.formattedLikes,
                           style: TextStyle(fontSize: 11, color: Colors.green[600]),
                         ),
                         const SizedBox(width: 12),
                         Icon(Icons.thumb_down, size: 14, color: Colors.red[600]),
                         const SizedBox(width: 4),
                         Text(
                           dislikeData!.formattedDislikes,
                           style: TextStyle(fontSize: 11, color: Colors.red[600]),
                         ),
                         const SizedBox(width: 12),
                         Text(
                           '${(dislikeData!.likePercentage).toStringAsFixed(1)}% likes',
                           style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                         ),
                       ],
                     ),
                   ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
