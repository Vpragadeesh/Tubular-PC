import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../controllers/player_controller.dart';
import '../providers.dart';
import '../services/media_player_holder.dart';

class PlayerShell extends ConsumerWidget {
  const PlayerShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerControllerProvider);

    return Stack(
      children: [child, if (playerState.isVisible) const _PlayerOverlay()],
    );
  }
}

class _PlayerOverlay extends ConsumerWidget {
  const _PlayerOverlay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerControllerProvider);

    switch (playerState.surface) {
      case PlayerSurface.fullscreen:
        return const _FullscreenPlayer();
      case PlayerSurface.mini:
        return const _MiniPlayer();
      case PlayerSurface.hidden:
        return const SizedBox.shrink();
    }
  }
}

class _FullscreenPlayer extends ConsumerWidget {
  const _FullscreenPlayer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerControllerProvider);
    final controller = ref.read(playerControllerProvider.notifier);
    final video = playerState.video;

    if (video == null) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) > 350) {
            controller.showMiniPlayer();
          }
        },
        child: Material(
          color: Colors.black,
          child: Column(
            children: [
              _PlayerTopBar(
                title: video.title,
                onMinimize: controller.showMiniPlayer,
              ),
              Expanded(child: _PlayerStage(playerState: playerState)),
              _FullscreenControls(playerState: playerState),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerTopBar extends StatelessWidget {
  const _PlayerTopBar({required this.title, required this.onMinimize});

  final String title;
  final VoidCallback onMinimize;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            IconButton(
              tooltip: 'Minimize',
              onPressed: onMinimize,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
            ),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

class _PlayerStage extends ConsumerStatefulWidget {
  const _PlayerStage({required this.playerState});

  final TubularPlayerState playerState;

  @override
  ConsumerState<_PlayerStage> createState() => _PlayerStageState();
}

class _PlayerStageState extends ConsumerState<_PlayerStage> {
  String? _currentStreamUrl;
  double _appliedSpeed = 1.0;
  bool _listenersAttached = false;

  @override
  void initState() {
    super.initState();
    _initializePlayerFromHolder();
  }

  void _initializePlayerFromHolder() {
    print('🎬 Initializing media_kit player from holder...');
    // Use the shared MediaPlayerHolder so the player survives when the UI minimizes
    final holder = MediaPlayerHolder.instance;
    final _player = holder.player;
    final _videoController = holder.videoController;

    // Attach listeners once per widget instance (safe because holder's player persists)
    if (!_listenersAttached) {
      _listenersAttached = true;

      _player.stream.position.listen((position) {
        ref.read(playerControllerProvider.notifier).updatePosition(position);
      });

      _player.stream.duration.listen((duration) {
        ref.read(playerControllerProvider.notifier).updateDuration(duration);
      });

      _player.stream.playing.listen((isPlaying) {
        print('🎵 Player playing state changed: $isPlaying');
        ref.read(playerControllerProvider.notifier).updatePlayingState(isPlaying);
      });

      _player.stream.buffering.listen((buffering) {
        print('📊 Player buffering: $buffering');
      });

      _player.stream.width.listen((width) {
        print('📐 Video width: $width');
        if (width != null && width > 0) {
          setState(() {});
        }
      });

      _player.stream.height.listen((height) {
        print('📐 Video height: $height');
      });

      _player.stream.error.listen((error) {
        if (error != null) {
          print('❌ Player error: $error');
          ref.read(playerControllerProvider.notifier).setError(error);
        }
      });

      _player.stream.completed.listen((completed) {
        if (completed) {
          print('✅ Playback completed');
        }
      });
    }

    print('✅ Player (holder) initialized');

    // If stream URL is already available, open it
    final streamUrl = widget.playerState.streamUrl;
    if (streamUrl != null && streamUrl.isNotEmpty) {
      _currentStreamUrl = streamUrl;
      print('🎥 Opening stream in initState (holder): $streamUrl');
      _player.open(Media(streamUrl), play: true);
    }

    // Apply current playback speed
    final speed = ref.read(playbackSpeedProvider);
    _appliedSpeed = speed;
    try {
      _player.setRate(speed);
      print('DEBUG: Applied playback speed $speed at init (holder)');
    } catch (e) {
      print('DEBUG: Failed to set initial playback speed (holder): $e');
    }
  }

  @override
  void didUpdateWidget(_PlayerStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    final streamUrl = widget.playerState.streamUrl;
    final isPlaying = widget.playerState.isPlaying;
    
    print('🎬 Player didUpdateWidget:');
    print('   streamUrl: $streamUrl');
    print('   _currentStreamUrl: $_currentStreamUrl');
    print('   isPlaying: $isPlaying');
    print('   status: ${widget.playerState.status}');
    
    // Load new stream URL if changed
    if (streamUrl != null && streamUrl != _currentStreamUrl && streamUrl.isNotEmpty) {
      _currentStreamUrl = streamUrl;
      print('🎥 Opening NEW stream: $streamUrl');
      print('   Will play: true');
      _player?.open(Media(streamUrl), play: true);
      return; // Let the player handle state changes
    }
    
    // Handle play/pause state changes only if URL hasn't changed
    if (oldWidget.playerState.isPlaying != isPlaying && streamUrl == _currentStreamUrl) {
      if (isPlaying) {
        print('▶️  Playing');
        _player?.play();
      } else {
        print('⏸️  Pausing');
        _player?.pause();
      }
    }
    
    // Handle seek
    if (oldWidget.playerState.position != widget.playerState.position) {
      final shouldSeek = (widget.playerState.position - (_player?.state.position ?? Duration.zero)).abs() > const Duration(seconds: 1);
      if (shouldSeek) {
        print('⏩ Seeking to: ${widget.playerState.position}');
        _player?.seek(widget.playerState.position);
      }
    }
  }

  @override
  void dispose() {
    // Do not dispose the shared player here. MediaPlayerHolder owns the player lifetime
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.playerState.video;
    final controller = ref.read(playerControllerProvider.notifier);
    final playbackSpeed = ref.watch(playbackSpeedProvider);
    final hasStreamUrl = widget.playerState.streamUrl != null;

    final holder = MediaPlayerHolder.instance;
    final _player = holder.isInitialized ? holder.player : null;
    final _videoController = holder.isInitialized ? holder.videoController : null;

    final hasVideo = _player != null && _player.state.width != null && 
                     _player.state.width! > 0 && 
                     _player.state.height != null && 
                     _player.state.height! > 0;

    print('🎨 Building _PlayerStage:');
    print('   hasStreamUrl: $hasStreamUrl');
    print('   streamUrl: ${widget.playerState.streamUrl}');
    print('   status: ${widget.playerState.status}');
    print('   _videoController: $_videoController');
    print('   _player state: ${_player?.state.playing}');
    print('   _player width: ${_player?.state.width}');
    print('   _player height: ${_player?.state.height}');
    print('   hasVideo: $hasVideo');

    // Apply playback speed updates if it changed
    if (_player != null && playbackSpeed != _appliedSpeed) {
      try {
        _player.setRate(playbackSpeed);
        _appliedSpeed = playbackSpeed;
        print('DEBUG: Applied playback speed $playbackSpeed in build');
      } catch (e) {
        print('DEBUG: Failed to apply playback speed $playbackSpeed in build: $e');
      }
    }

    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video player - only show if we have valid video dimensions
          if (_videoController != null && hasStreamUrl && hasVideo)
            SizedBox.expand(
              child: Video(
                controller: _videoController!,
                controls: NoVideoControls,
                fit: BoxFit.contain,
                fill: Colors.black,
                filterQuality: FilterQuality.medium,
                wakelock: true,
              ),
            )
          else if (_videoController != null && hasStreamUrl && !hasVideo)
            // Show loading indicator while waiting for video dimensions
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Loading video...',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            )
          else if (video != null && video.thumbnail.isNotEmpty)
            Opacity(
              opacity: 0.26,
              child: CachedNetworkImage(
                imageUrl: video.thumbnail,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          
          // Center control (loading/error/play button) - only show if not loading video
          if (!hasStreamUrl || hasVideo)
            Center(
              child: _PlayerCenterControl(
                playerState: widget.playerState,
                onRetry: controller.retry,
                onTogglePlayPause: controller.togglePlayPause,
              ),
            ),
        ],
      ),
    );
  }
}

class _PlayerCenterControl extends StatelessWidget {
  const _PlayerCenterControl({
    required this.playerState,
    required this.onRetry,
    required this.onTogglePlayPause,
  });

  final TubularPlayerState playerState;
  final VoidCallback onRetry;
  final VoidCallback onTogglePlayPause;

  @override
  Widget build(BuildContext context) {
    if (playerState.isLoading) {
      return const SizedBox(
        width: 42,
        height: 42,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: Color(0xFFE53935),
        ),
      );
    }

    if (playerState.status == PlaybackStatus.error) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 34),
          const SizedBox(height: 12),
          SizedBox(
            width: 420,
            child: Text(
              playerState.errorMessage ?? 'Playback failed',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFD6D6D6), fontSize: 13),
            ),
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      );
    }

    return IconButton(
      tooltip: playerState.isPlaying ? 'Pause' : 'Play',
      onPressed: onTogglePlayPause,
      iconSize: 76,
      color: Colors.white,
      icon: Icon(
        playerState.isPlaying
            ? Icons.pause_circle_filled
            : Icons.play_circle_fill,
      ),
    );
  }
}

class _FullscreenControls extends ConsumerWidget {
  const _FullscreenControls({required this.playerState});

  final TubularPlayerState playerState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(playerControllerProvider.notifier);
    final duration = playerState.duration;
    final position = _safePosition(playerState.position, duration);

    return SafeArea(
      top: false,
      child: Container(
        color: Colors.black,
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  _formatDuration(position),
                  style: const TextStyle(
                    color: Color(0xFFBDBDBD),
                    fontSize: 12,
                  ),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFFE53935),
                      inactiveTrackColor: const Color(0xFF3A3A3A),
                      thumbColor: const Color(0xFFE53935),
                      overlayColor: const Color(0x22E53935),
                      trackHeight: 3,
                    ),
                    child: Slider(
                      value: position.inMilliseconds.toDouble(),
                      max: math.max(1, duration.inMilliseconds).toDouble(),
                      onChanged: duration == Duration.zero
                          ? null
                          : (value) => controller.previewSeek(
                              Duration(milliseconds: value.round()),
                            ),
                      onChangeEnd: duration == Duration.zero
                          ? null
                          : (value) => controller.seek(
                              Duration(milliseconds: value.round()),
                            ),
                    ),
                  ),
                ),
                Text(
                  _formatDuration(duration),
                  style: const TextStyle(
                    color: Color(0xFFBDBDBD),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  tooltip: playerState.isPlaying ? 'Pause' : 'Play',
                  onPressed: controller.togglePlayPause,
                  color: Colors.white,
                  icon: Icon(
                    playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                ),
                IconButton(
                  tooltip: 'Stop',
                  onPressed: controller.stop,
                  color: Colors.white,
                  icon: const Icon(Icons.stop),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Background audio',
                  onPressed: controller.toggleBackgroundAudio,
                  color: playerState.backgroundAudio
                      ? const Color(0xFFE53935)
                      : Colors.white,
                  icon: const Icon(Icons.headphones),
                ),
                _QualityMenu(
                  selectedQuality: playerState.quality,
                  onSelected: controller.setQuality,
                ),
                const SizedBox(width: 8),
                _SpeedMenu(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QualityMenu extends StatelessWidget {
  const _QualityMenu({required this.selectedQuality, required this.onSelected});

  final String selectedQuality;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Quality',
      color: const Color(0xFF1C1C1C),
      initialValue: selectedQuality,
      onSelected: onSelected,
      itemBuilder: (context) {
        return const [
          PopupMenuItem(value: 'best', child: _QualityLabel('Best')),
          PopupMenuItem(value: '1080p', child: _QualityLabel('1080p')),
          PopupMenuItem(value: '720p', child: _QualityLabel('720p')),
          PopupMenuItem(value: '480p', child: _QualityLabel('480p')),
          PopupMenuItem(value: 'audio', child: _QualityLabel('Audio')),
        ];
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.high_quality, color: Colors.white, size: 22),
            const SizedBox(width: 6),
            Text(
              selectedQuality.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QualityLabel extends StatelessWidget {
  const _QualityLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(color: Colors.white));
  }
}

class _SpeedMenu extends ConsumerWidget {
  const _SpeedMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speed = ref.watch(playbackSpeedProvider);
    final controller = ref.read(playerControllerProvider.notifier);

    return PopupMenuButton<String>(
      tooltip: 'Speed',
      color: const Color(0xFF1C1C1C),
      initialValue: speed.toString(),
      onSelected: (value) {
        final v = double.tryParse(value) ?? 1.0;
        ref.read(playbackSpeedProvider.notifier).state = v;
        // controller doesn't need to apply speed; player_shell listens to provider
      },
      itemBuilder: (context) {
        return const [
          PopupMenuItem(value: '0.5', child: Text('0.5x')),
          PopupMenuItem(value: '0.75', child: Text('0.75x')),
          PopupMenuItem(value: '1.0', child: Text('1.0x')),
          PopupMenuItem(value: '1.25', child: Text('1.25x')),
          PopupMenuItem(value: '1.5', child: Text('1.5x')),
          PopupMenuItem(value: '2.0', child: Text('2.0x')),
          PopupMenuItem(value: '2.25', child: Text('2.25x')),
          PopupMenuItem(value: '2.5', child: Text('2.5x')),
          PopupMenuItem(value: '2.75', child: Text('2.75x')),
          PopupMenuItem(value: '3.0', child: Text('3.0x')),
          PopupMenuItem(value: '3.25', child: Text('3.25x')),
          PopupMenuItem(value: '3.5', child: Text('3.5x')),
          PopupMenuItem(value: '3.75', child: Text('3.75x')),
          PopupMenuItem(value: '4.0', child: Text('4.0x')),
        ];
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.speed, color: Colors.white, size: 22),
            const SizedBox(width: 6),
            Text(
              '${speed}x',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniPlayer extends ConsumerWidget {
  const _MiniPlayer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerControllerProvider);
    final controller = ref.read(playerControllerProvider.notifier);
    final video = playerState.video;

    if (video == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: controller.showFullscreen,
        onVerticalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) < -350) {
            controller.showFullscreen();
          }
        },
        child: Material(
          color: const Color(0xF20B0B0B),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 74,
              child: Row(
                children: [
                  SizedBox(
                    width: 128,
                    height: 74,
                    child: video.thumbnail.isEmpty
                        ? const ColoredBox(color: Color(0xFF181818))
                        : CachedNetworkImage(
                            imageUrl: video.thumbnail,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                                const ColoredBox(color: Color(0xFF181818)),
                          ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            video.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            video.channelName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF9E9E9E),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: playerState.isPlaying ? 'Pause' : 'Play',
                    onPressed: controller.togglePlayPause,
                    color: Colors.white,
                    icon: Icon(
                      playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: controller.stop,
                    color: Colors.white,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Duration _safePosition(Duration position, Duration duration) {
  if (duration == Duration.zero || position <= duration) {
    return position;
  }

  return duration;
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

  if (hours > 0) {
    return '$hours:$minutes:$seconds';
  }

  return '$minutes:$seconds';
}
