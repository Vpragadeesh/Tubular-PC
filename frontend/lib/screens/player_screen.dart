import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/video.dart';
import '../models/sponsorblock.dart';
import '../models/dislike.dart';
import '../providers.dart';

final sponsorBlockProvider = FutureProvider.family<List<SponsorBlockSegment>, String>((ref, videoId) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    // TODO: Fetch from backend API
    // return await apiService.getSponsorBlockSegments(videoId);
    return [];
  } catch (e) {
    return [];
  }
});

final dislikeProvider = FutureProvider.family<DislikeData?, String>((ref, videoId) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    // TODO: Fetch from backend API
    // return await apiService.getDislikeData(videoId);
    return null;
  } catch (e) {
    return null;
  }
});

final playerPositionProvider = StateProvider<Duration>((ref) => Duration.zero);
final playerDurationProvider = StateProvider<Duration>((ref) => const Duration(minutes: 10));
final isPlayingProvider = StateProvider<bool>((ref) => false);
final autoSkipSponsorProvider = StateProvider<bool>((ref) => true);

class PlayerScreen extends ConsumerStatefulWidget {
  final Video video;

  const PlayerScreen({
    Key? key,
    required this.video,
  }) : super(key: key);

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  @override
  Widget build(BuildContext context) {
    final sponsorBlockAsync = ref.watch(sponsorBlockProvider(widget.video.id));
    final dislikeAsync = ref.watch(dislikeProvider(widget.video.id));
    final isPlaying = ref.watch(isPlayingProvider);
    final position = ref.watch(playerPositionProvider);
    final duration = ref.watch(playerDurationProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: const Text('Now Playing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Player settings coming soon')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Video player area
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_circle_outline,
                      size: 80,
                      color: Colors.red[700],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.video.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.video.channelName,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Progress bar with SponsorBlock segments
          Container(
            color: Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SponsorBlock segments timeline
                sponsorBlockAsync.when(
                  data: (segments) {
                    if (segments.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Skip Segments',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildSponsorBlockTimeline(segments, duration),
                          const SizedBox(height: 12),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                // Progress bar
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                  ),
                  child: Slider(
                    value: position.inSeconds.toDouble(),
                    max: duration.inSeconds.toDouble(),
                    onChanged: (value) {
                      ref.read(playerPositionProvider.notifier).state =
                          Duration(seconds: value.toInt());
                    },
                    activeColor: Colors.red[700],
                    inactiveColor: Colors.grey[700],
                  ),
                ),

                // Time display
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(position),
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _formatDuration(duration),
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Player controls
          Container(
            color: Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous, color: Colors.white),
                  onPressed: () {
                    ref.read(playerPositionProvider.notifier).state =
                        Duration(seconds: (position.inSeconds - 10).clamp(0, double.infinity).toInt());
                  },
                ),
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause_circle : Icons.play_circle,
                    color: Colors.white,
                    size: 40,
                  ),
                  onPressed: () {
                    ref.read(isPlayingProvider.notifier).state = !isPlaying;
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, color: Colors.white),
                  onPressed: () {
                    ref.read(playerPositionProvider.notifier).state =
                        Duration(seconds: position.inSeconds + 10);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up, color: Colors.white),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Volume control coming soon')),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.fullscreen, color: Colors.white),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fullscreen coming soon')),
                    );
                  },
                ),
              ],
            ),
          ),

          // Video info with dislikes
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.black87,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      widget.video.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Channel and stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.video.channelName,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        dislikeAsync.when(
                          data: (dislike) {
                            if (dislike != null) {
                              return Row(
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.thumb_up, color: Colors.grey[400], size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        dislike.formattedLikes,
                                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  Row(
                                    children: [
                                      Icon(Icons.thumb_down, color: Colors.grey[400], size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        dislike.formattedDislikes,
                                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // View count and upload date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.video.formattedViews} views',
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                        Text(
                          widget.video.uploadedAgo,
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Text(
                      'Description coming soon',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // SponsorBlock segments (outside of Column for AsyncValue handling)
          Expanded(
            flex: 1,
            child: sponsorBlockAsync.when(
              data: (segments) {
                if (segments.isEmpty) {
                  return const SizedBox.shrink();
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sponsor Segments',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: segments
                            .map((segment) =>
                                _buildSegmentTile(segment, context))
                            .toList(),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSponsorBlockTimeline(List<SponsorBlockSegment> segments, Duration duration) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 24,
        child: Stack(
          children: [
            // Background bar
            Container(
              color: Colors.grey[800],
            ),
            // Segments
            Row(
              children: segments.map((segment) {
                final totalDuration = duration.inMilliseconds.toDouble();
                final startPercent = (segment.startTime * 1000) / totalDuration;
                final widthPercent =
                    ((segment.endTime - segment.startTime) * 1000) / totalDuration;

                return Expanded(
                  flex: 0,
                  child: Padding(
                    padding: EdgeInsets.only(left: startPercent.toStringAsFixed(0) as double? ?? 0),
                    child: Container(
                      width: (widthPercent * 100).toStringAsFixed(0) as double? ?? 0,
                      color: segment.categoryColor,
                      child: Tooltip(
                        message: '${segment.categoryLabel} (${segment.durationText})',
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentTile(SponsorBlockSegment segment, BuildContext context) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 4,
          color: segment.categoryColor,
        ),
        title: Text(
          segment.categoryLabel,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
        subtitle: Text(
          '${_formatDuration(segment.startDuration)} - ${_formatDuration(segment.endDuration)} (${segment.durationText})',
          style: TextStyle(color: Colors.grey[400], fontSize: 11),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.thumb_up, color: Colors.grey[400], size: 16),
            const SizedBox(width: 4),
            Text(
              segment.votes.toString(),
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
        onTap: () {
          ref.read(playerPositionProvider.notifier).state = segment.startDuration;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Jumping to ${segment.categoryLabel}')),
          );
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
