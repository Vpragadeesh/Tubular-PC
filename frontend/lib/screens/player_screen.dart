import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/video.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final Video video;

  const PlayerScreen({Key? key, required this.video}) : super(key: key);

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  bool _isLoading = false;
  String? _streamUrl;
  String _selectedQuality = 'best';

  @override
  void initState() {
    super.initState();
    _loadStreamUrl();
    _addToHistory();
  }

  Future<void> _loadStreamUrl() async {
    setState(() => _isLoading = true);
    try {
      final apiService = ref.read(apiServiceProvider);
      final url = await apiService.getStreamUrl(
        widget.video.id,
        quality: _selectedQuality,
      );
      setState(() {
        _streamUrl = url;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load stream: $e')),
        );
      }
    }
  }

  Future<void> _addToHistory() async {
    try {
       final apiService = ref.read(apiServiceProvider);
       await apiService.addToHistory(
         videoId: widget.video.id,
         title: widget.video.title,
         channel: widget.video.channelName,
         thumbnail: widget.video.thumbnail,
       );
    } catch (e) {
      // Silently fail - history is not critical
    }
  }

  Future<void> _downloadVideo() async {
    // Show quality selection dialog
    final quality = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Quality'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Best Quality'),
              onTap: () => Navigator.pop(context, 'best'),
            ),
            ListTile(
              title: const Text('1080p'),
              onTap: () => Navigator.pop(context, '1080p'),
            ),
            ListTile(
              title: const Text('720p'),
              onTap: () => Navigator.pop(context, '720p'),
            ),
            ListTile(
              title: const Text('480p'),
              onTap: () => Navigator.pop(context, '480p'),
            ),
            ListTile(
              title: const Text('Audio Only'),
              onTap: () => Navigator.pop(context, 'audio'),
            ),
          ],
        ),
      ),
    );

    if (quality == null) return;

    try {
      final apiService = ref.read(apiServiceProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download started...')),
      );

      await apiService.downloadVideo(
        videoId: widget.video.id,
        outputPath: '~/Videos/%(title)s.%(ext)s',
        quality: quality,
        audioOnly: quality == 'audio',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download completed!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video player placeholder
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.black,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _streamUrl != null
                        ? Stack(
                            children: [
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.play_circle_outline,
                                      size: 64,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Stream URL ready',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // In a real app, this would open mpv
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Opening in external player...'),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.open_in_new),
                                      label: const Text('Open in MPV'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : const Center(
                            child: Text(
                              'Failed to load stream',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
              ),
            ),

            // Video info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.video.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                   const SizedBox(height: 8),
                   Row(
                     children: [
                       Text(
                         '${widget.video.formattedViews} views',
                         style: TextStyle(
                           color: Colors.grey[600],
                           fontSize: 14,
                         ),
                       ),
                       const SizedBox(width: 8),
                       Text(
                         '• ${widget.video.uploadedAgo}',
                         style: TextStyle(
                           color: Colors.grey[600],
                           fontSize: 14,
                         ),
                       ),
                     ],
                   ),
                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _downloadVideo,
                          icon: const Icon(Icons.download),
                          label: const Text('Download'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[700],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Implement subscribe
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Subscribe feature coming soon')),
                            );
                          },
                          icon: const Icon(Icons.subscriptions),
                          label: const Text('Subscribe'),
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 32),

                   // Channel info
                   Row(
                     children: [
                       CircleAvatar(
                         radius: 20,
                         backgroundColor: Colors.red[700],
                         child: Text(
                           widget.video.channelName[0].toUpperCase(),
                           style: const TextStyle(color: Colors.white),
                         ),
                       ),
                       const SizedBox(width: 12),
                       Expanded(
                         child: Text(
                           widget.video.channelName,
                           style: const TextStyle(
                             fontSize: 16,
                             fontWeight: FontWeight.w500,
                           ),
                         ),
                       ),
                     ],
                   ),

                  if (widget.video.description != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.video.description!,
                      style: TextStyle(
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
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
