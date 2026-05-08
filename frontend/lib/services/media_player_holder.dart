import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class MediaPlayerHolder {
  MediaPlayerHolder._internal();
  static final MediaPlayerHolder instance = MediaPlayerHolder._internal();

  Player? _player;
  VideoController? _videoController;
  bool _initialized = false;

  Player get player {
    _ensureInit();
    return _player!;
  }

  VideoController get videoController {
    _ensureInit();
    return _videoController!;
  }

  bool get isInitialized => _initialized;

  void _ensureInit() {
    if (_initialized) return;
    _player = Player();
    _videoController = VideoController(
      _player!,
      configuration: const VideoControllerConfiguration(
        enableHardwareAcceleration: false,
      ),
    );
    _initialized = true;
  }

  void dispose() {
    _videoController?.dispose();
    _player?.dispose();
    _videoController = null;
    _player = null;
    _initialized = false;
  }
}
