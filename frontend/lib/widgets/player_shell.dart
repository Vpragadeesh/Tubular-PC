import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/player_controller.dart';

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

class _PlayerStage extends ConsumerWidget {
  const _PlayerStage({required this.playerState});

  final PlayerState playerState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final video = playerState.video;
    final controller = ref.read(playerControllerProvider.notifier);

    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (video != null && video.thumbnail.isNotEmpty)
            Opacity(
              opacity: 0.26,
              child: CachedNetworkImage(
                imageUrl: video.thumbnail,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x66000000), Color(0xFF000000)],
              ),
            ),
          ),
          Center(
            child: _PlayerCenterControl(
              playerState: playerState,
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

  final PlayerState playerState;
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

  final PlayerState playerState;

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
