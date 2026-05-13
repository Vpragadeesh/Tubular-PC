import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../controllers/player_controller.dart';
import '../providers.dart';

/// Floating Picture-in-Picture video window
class PictureInPictureWindow extends ConsumerStatefulWidget {
  const PictureInPictureWindow({Key? key}) : super(key: key);

  @override
  ConsumerState<PictureInPictureWindow> createState() => _PictureInPictureWindowState();
}

class _PictureInPictureWindowState extends ConsumerState<PictureInPictureWindow> {
  late Offset _position;
  late Size _size;
  late bool _isDragging;
  late bool _isResizing;
  late Offset _dragStart;

  @override
  void initState() {
    super.initState();
    _position = const Offset(100, 100);
    _size = const Size(400, 225);
    _isDragging = false;
    _isResizing = false;
    _dragStart = Offset.zero;
  }

  void _onDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _dragStart = details.globalPosition;
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    
    final delta = details.globalPosition - _dragStart;
    setState(() {
      _position = Offset(
        _position.dx + delta.dx,
        _position.dy + delta.dy,
      );
      _dragStart = details.globalPosition;
    });

    // Persist position to provider
    ref.read(pipWindowPositionProvider.notifier).state = _position;
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
  }

  void _onResizeStart(DragStartDetails details) {
    setState(() {
      _isResizing = true;
      _dragStart = details.globalPosition;
    });
  }

  void _onResizeUpdate(DragUpdateDetails details) {
    if (!_isResizing) return;
    
    final delta = details.globalPosition - _dragStart;
    setState(() {
      _size = Size(
        (_size.width + delta.dx).clamp(200, 800),
        (_size.height + delta.dy).clamp(112.5, 450),
      );
      _dragStart = details.globalPosition;
    });

    // Persist size to provider
    ref.read(pipWindowSizeProvider.notifier).state = _size;
  }

  void _onResizeEnd(DragEndDetails details) {
    setState(() {
      _isResizing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerControllerProvider);
    final controller = ref.read(playerControllerProvider.notifier);

    // Load persisted position and size
    final storedPosition = ref.watch(pipWindowPositionProvider);
    final storedSize = ref.watch(pipWindowSizeProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_position != storedPosition) {
        setState(() => _position = storedPosition);
      }
      if (_size != storedSize) {
        setState(() => _size = storedSize);
      }
    });

    if (!playerState.hasVideo) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      width: _size.width,
      height: _size.height,
      child: GestureDetector(
        onPanStart: _onDragStart,
        onPanUpdate: _onDragUpdate,
        onPanEnd: _onDragEnd,
        child: Material(
          color: Colors.black,
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: Column(
            children: [
              // Title bar (draggable)
              GestureDetector(
                onPanStart: _onDragStart,
                onPanUpdate: _onDragUpdate,
                onPanEnd: _onDragEnd,
                child: Container(
                  color: Colors.black87,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Picture in Picture',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 16),
                        onPressed: () {
                          ref.read(pipEnabledProvider.notifier).state = false;
                        },
                        constraints: const BoxConstraints(
                          maxWidth: 24,
                          maxHeight: 24,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
              // Video player
              Expanded(
                child: Container(
                  color: Colors.black,
                  child: Stack(
                    children: [
                      // Video surface (hidden but active)
                      const Positioned.fill(child: ColoredBox(color: Colors.black)),
                      // Thumbnail and play button
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            controller.togglePlayPause();
                          },
                          child: Container(
                            color: Colors.black,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Thumbnail
                                if (playerState.video?.thumbnail != null)
                                  Image.network(
                                    playerState.video!.thumbnail!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(color: Colors.grey[900]),
                                  ),
                                // Play/pause button
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Mini controls
              Container(
                color: Colors.black87,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Play/pause
                    IconButton(
                      icon: Icon(
                        playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: () => controller.togglePlayPause(),
                      constraints: const BoxConstraints(maxWidth: 24, maxHeight: 24),
                      padding: EdgeInsets.zero,
                    ),
                    // Volume
                    Expanded(
                      child: Slider(
                        value: playerState.volume.toDouble(),
                        min: 0,
                        max: 100,
                        onChanged: (value) {
                          controller.setVolume(value);
                        },
                      ),
                    ),
                    // Duration / position
                    Text(
                      _formatDuration(playerState.position) +
                          ' / ' +
                          _formatDuration(playerState.duration),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
