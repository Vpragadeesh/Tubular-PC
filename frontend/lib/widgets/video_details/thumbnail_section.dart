import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ThumbnailSection extends StatelessWidget {
  const ThumbnailSection({
    super.key,
    required this.thumbnailUrl,
    required this.onPlay,
  });

  final String thumbnailUrl;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: CachedNetworkImage(
            imageUrl: thumbnailUrl,
            fit: BoxFit.cover,
            placeholder: (context, _) => Container(color: Colors.grey[800]),
            errorWidget: (context, _, __) => Container(
              color: Colors.grey[800],
              child: const Center(
                child: Icon(Icons.broken_image, color: Colors.white70),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: IconButton(
              onPressed: onPlay,
              iconSize: 84,
              color: Colors.white.withOpacity(0.92),
              icon: const Icon(Icons.play_circle_outline),
            ),
          ),
        ),
      ],
    );
  }
}
