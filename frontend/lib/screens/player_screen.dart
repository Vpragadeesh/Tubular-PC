import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/video.dart';
import '../models/sponsorblock.dart';
import '../models/dislike.dart';
import '../providers.dart';
import '../controllers/player_controller.dart';

final sponsorBlockProvider = FutureProvider.family<List<SponsorBlockSegment>, String>((ref, videoId) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final data = await apiService.getSponsorBlockSegments(videoId);
    return data.map((json) => SponsorBlockSegment.fromJson(json)).toList();
  } catch (e) {
    return [];
  }
});

final dislikeProvider = FutureProvider.family<DislikeData?, String>((ref, videoId) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final data = await apiService.getDislikeData(videoId);
    if (data != null) {
      return DislikeData.fromJson(data);
    }
    return null;
  } catch (e) {
    return null;
  }
});

/// Provider to fetch available subtitle tracks for a video
final subtitleTracksProvider = FutureProvider.family<List<Map<String, String>>, String>((ref, videoId) async {
  final apiService = ref.watch(apiServiceProvider);
  final result = await apiService.getSubtitles(videoId);
  if (result.success && result.data != null) {
    return result.data!;
  }
  return [];
});

/// Currently selected subtitle language (null = off)
final selectedSubtitleProvider = StateProvider<String?>((ref) => null);

/// Parsed VTT cues for the currently selected subtitle
final subtitleCuesProvider = StateProvider<List<SubtitleCue>>((ref) => []);

/// A single parsed VTT cue
class SubtitleCue {
  final Duration start;
  final Duration end;
  final String text;

  SubtitleCue({required this.start, required this.end, required this.text});
}

final playerPositionProvider = StateProvider<Duration>((ref) => Duration.zero);
final playerDurationProvider = StateProvider<Duration>((ref) => const Duration(minutes: 10));
final isPlayingProvider = StateProvider<bool>((ref) => false);

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
  /// Parse a VTT timestamp like "00:01:23.456" to Duration
  Duration _parseVttTimestamp(String ts) {
    ts = ts.trim();
    final parts = ts.split(':');
    if (parts.length == 3) {
      final hours = int.tryParse(parts[0]) ?? 0;
      final minutes = int.tryParse(parts[1]) ?? 0;
      final secParts = parts[2].split('.');
      final seconds = int.tryParse(secParts[0]) ?? 0;
      final millis = secParts.length > 1 ? int.tryParse(secParts[1].padRight(3, '0').substring(0, 3)) ?? 0 : 0;
      return Duration(hours: hours, minutes: minutes, seconds: seconds, milliseconds: millis);
    } else if (parts.length == 2) {
      final minutes = int.tryParse(parts[0]) ?? 0;
      final secParts = parts[1].split('.');
      final seconds = int.tryParse(secParts[0]) ?? 0;
      final millis = secParts.length > 1 ? int.tryParse(secParts[1].padRight(3, '0').substring(0, 3)) ?? 0 : 0;
      return Duration(minutes: minutes, seconds: seconds, milliseconds: millis);
    }
    return Duration.zero;
  }

  /// Parse VTT content into a list of SubtitleCue
  List<SubtitleCue> _parseVtt(String vttContent) {
    final cues = <SubtitleCue>[];
    final lines = vttContent.split('\n');
    int i = 0;

    // Skip header
    while (i < lines.length && !lines[i].contains('-->')) {
      i++;
    }

    while (i < lines.length) {
      final line = lines[i].trim();
      if (line.contains('-->')) {
        final timeParts = line.split('-->');
        if (timeParts.length == 2) {
          final start = _parseVttTimestamp(timeParts[0]);
          // Remove position styling after the end timestamp
          final endStr = timeParts[1].split(' ').first;
          final end = _parseVttTimestamp(endStr);

          // Collect text lines
          i++;
          final textLines = <String>[];
          while (i < lines.length && lines[i].trim().isNotEmpty && !lines[i].contains('-->')) {
            // Strip HTML tags from cue text
            textLines.add(lines[i].trim().replaceAll(RegExp(r'<[^>]*>'), ''));
            i++;
          }

          if (textLines.isNotEmpty) {
            cues.add(SubtitleCue(
              start: start,
              end: end,
              text: textLines.join('\n'),
            ));
          }
        } else {
          i++;
        }
      } else {
        i++;
      }
    }
    return cues;
  }

  /// Load and parse VTT from a URL
  Future<void> _loadSubtitle(String url) async {
    try {
      final dio = Dio();
      final response = await dio.get(url);
      if (response.statusCode == 200) {
        final cues = _parseVtt(response.data.toString());
        ref.read(subtitleCuesProvider.notifier).state = cues;
      }
    } catch (e) {
      debugPrint('Failed to load subtitle: $e');
      ref.read(subtitleCuesProvider.notifier).state = [];
    }
  }

  /// Get the current subtitle cue text for a given position
  String? _getCurrentCueText(List<SubtitleCue> cues, Duration position) {
    for (final cue in cues) {
      if (position >= cue.start && position <= cue.end) {
        return cue.text;
      }
    }
    return null;
  }

  /// Show subtitle track selection dialog
  void _showSubtitlePicker(List<Map<String, String>> tracks) {
    final selectedLang = ref.read(selectedSubtitleProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Subtitles', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: 300,
          child: ListView(
            shrinkWrap: true,
            children: [
              // "Off" option
              ListTile(
                leading: Icon(
                  selectedLang == null ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: selectedLang == null ? Colors.red[700] : Colors.grey[400],
                ),
                title: const Text('Off', style: TextStyle(color: Colors.white)),
                onTap: () {
                  ref.read(selectedSubtitleProvider.notifier).state = null;
                  ref.read(subtitleCuesProvider.notifier).state = [];
                  Navigator.pop(ctx);
                },
              ),
              const Divider(color: Colors.grey),
              // Available tracks
              ...tracks.map((track) {
                final isSelected = selectedLang == track['language'];
                return ListTile(
                  leading: Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isSelected ? Colors.red[700] : Colors.grey[400],
                  ),
                  title: Text(
                    track['language_name'] ?? track['language'] ?? '??',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    track['language'] ?? '',
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
                  onTap: () {
                    ref.read(selectedSubtitleProvider.notifier).state = track['language'];
                    final url = track['url'];
                    if (url != null && url.isNotEmpty) {
                      _loadSubtitle(url);
                    }
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sponsorBlockAsync = ref.watch(sponsorBlockProvider(widget.video.id));
    final dislikeAsync = ref.watch(dislikeProvider(widget.video.id));
    final isPlaying = ref.watch(isPlayingProvider);
    final position = ref.watch(playerPositionProvider);
    final duration = ref.watch(playerDurationProvider);
    final viewMode = ref.watch(playerViewModeProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: viewMode == PlayerViewMode.fullscreen 
        ? null  // Hide AppBar in fullscreen
        : AppBar(
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
          // Video player area with dynamic flex based on view mode
          Expanded(
            flex: viewMode == PlayerViewMode.normal 
              ? 3 
              : (viewMode == PlayerViewMode.theater ? 6 : 1),
            child: Container(
              color: Colors.black,
              child: Stack(
                children: [
                  Center(
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
                  // Subtitle overlay
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Builder(
                      builder: (context) {
                        final cues = ref.watch(subtitleCuesProvider);
                        final cueText = _getCurrentCueText(cues, position);
                        if (cueText == null) return const SizedBox.shrink();
                        return Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.75),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              cueText,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                height: 1.4,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Progress bar with SponsorBlock segments - hidden in fullscreen
          if (viewMode != PlayerViewMode.fullscreen)
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

          Container(
            color: Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous, color: Colors.white),
                  onPressed: () {
                    ref.read(playerPositionProvider.notifier).state = Duration(
                      seconds: (position.inSeconds - 10).clamp(0, position.inSeconds),
                    );
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
                  icon: Icon(
                    Icons.headphones,
                    color: ref.watch(audioOnlyModeProvider) ? Colors.red[700] : Colors.white,
                  ),
                  tooltip: ref.watch(audioOnlyModeProvider)
                      ? 'Audio-only mode (ON)'
                      : 'Audio-only mode (OFF)',
                  onPressed: () async {
                    final newMode = !ref.read(audioOnlyModeProvider);
                    ref.read(audioOnlyModeProvider.notifier).state = newMode;
                    final currentQuality = ref.read(preferredQualityProvider);
                    await ref.read(playerControllerProvider.notifier).playVideo(
                          widget.video,
                          quality: newMode ? 'audio' : currentQuality,
                        );
                  },
                ),
                ref.watch(subtitleTracksProvider(widget.video.id)).when(
                      data: (tracks) => IconButton(
                        icon: Icon(
                          Icons.subtitles,
                          color: ref.watch(selectedSubtitleProvider) != null
                              ? Colors.red[700]
                              : (tracks.isNotEmpty ? Colors.white : Colors.grey[700]),
                        ),
                        tooltip: tracks.isNotEmpty ? 'Subtitles' : 'No subtitles available',
                        onPressed: tracks.isNotEmpty ? () => _showSubtitlePicker(tracks) : null,
                      ),
                      loading: () => const IconButton(
                        icon: Icon(Icons.subtitles_outlined, color: Colors.grey),
                        onPressed: null,
                      ),
                      error: (_, __) => const IconButton(
                        icon: Icon(Icons.subtitles_off, color: Colors.grey),
                        onPressed: null,
                      ),
                    ),
                IconButton(
                  icon: const Icon(Icons.fullscreen, color: Colors.white),
                  onPressed: () {
                    final currentMode = ref.read(playerViewModeProvider);
                    ref.read(playerViewModeProvider.notifier).state =
                        currentMode == PlayerViewMode.normal
                            ? PlayerViewMode.theater
                            : currentMode == PlayerViewMode.theater
                                ? PlayerViewMode.fullscreen
                                : PlayerViewMode.normal;
                  },
                ),
              ],
            ),
          ),
          if (viewMode != PlayerViewMode.fullscreen)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.video.title,
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
                        color: Colors.red[700],
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.video.formattedViews} views • ${widget.video.uploadedAgo}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    dislikeAsync.when(
                      data: (dislike) => dislike == null
                          ? const SizedBox.shrink()
                          : Text(
                              '${dislike.formattedLikes} likes • ${dislike.formattedDislikes} dislikes',
                              style: TextStyle(color: Colors.grey[400], fontSize: 12),
                            ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.video.description.isEmpty
                          ? 'No description available.'
                          : widget.video.description,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                    sponsorBlockAsync.when(
                      data: (segments) => segments.isEmpty
                          ? const SizedBox.shrink()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                const Text(
                                  'Sponsor Segments',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...segments.map((segment) => _buildSegmentTile(segment, context)),
                              ],
                            ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSponsorBlockTimeline(List<SponsorBlockSegment> segments, Duration duration) {
    if (duration == Duration.zero) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final totalMs = duration.inMilliseconds.toDouble();

        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 12,
            child: Stack(
              children: [
                // Background bar
                Container(
                  color: Colors.grey[800],
                ),
                // Segments
                ...segments.map((segment) {
                  final startMs = segment.startTime * 1000;
                  final endMs = segment.endTime * 1000;
                  
                  final left = (startMs / totalMs) * totalWidth;
                  final width = ((endMs - startMs) / totalMs) * totalWidth;

                  return Positioned(
                    left: left,
                    top: 0,
                    bottom: 0,
                    width: width.clamp(1.0, totalWidth),
                    child: Tooltip(
                      message: '${segment.categoryLabel} (${segment.durationText})',
                      child: Container(
                        color: segment.categoryColor,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      }
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
