import 'package:flutter/services.dart';

class KeyboardShortcuts {
  /// Check if Ctrl key is pressed
  static bool isCtrlPressed(RawKeyEvent event) {
    return event.isControlPressed;
  }

  /// Check if Shift key is pressed
  static bool isShiftPressed(RawKeyEvent event) {
    return event.isShiftPressed;
  }

  /// Check if Alt key is pressed
  static bool isAltPressed(RawKeyEvent event) {
    return event.isAltPressed;
  }

  /// Check if a specific key was pressed
  static bool isKeyPressed(RawKeyEvent event, LogicalKeyboardKey key) {
    return event.logicalKey == key;
  }

  /// Playback shortcuts
  static bool isPlayPauseShortcut(RawKeyEvent event) {
    return isKeyPressed(event, LogicalKeyboardKey.space);
  }

  static bool isSkipForwardShortcut(RawKeyEvent event) {
    return isKeyPressed(event, LogicalKeyboardKey.arrowRight);
  }

  static bool isSkipBackwardShortcut(RawKeyEvent event) {
    return isKeyPressed(event, LogicalKeyboardKey.arrowLeft);
  }

  static bool isVolumeUpShortcut(RawKeyEvent event) {
    return isKeyPressed(event, LogicalKeyboardKey.arrowUp);
  }

  static bool isVolumeDownShortcut(RawKeyEvent event) {
    return isKeyPressed(event, LogicalKeyboardKey.arrowDown);
  }

  static bool isMuteToggleShortcut(RawKeyEvent event) {
    return isKeyPressed(event, LogicalKeyboardKey.keyM);
  }

  static bool isFullscreenShortcut(RawKeyEvent event) {
    return isKeyPressed(event, LogicalKeyboardKey.keyF);
  }

  static bool isTheaterModeShortcut(RawKeyEvent event) {
    return isKeyPressed(event, LogicalKeyboardKey.keyT);
  }

  static bool isPipToggleShortcut(RawKeyEvent event) {
    return isCtrlPressed(event) && isKeyPressed(event, LogicalKeyboardKey.keyP);
  }

  /// Navigation shortcuts
  static bool isSearchShortcut(RawKeyEvent event) {
    return isCtrlPressed(event) && isKeyPressed(event, LogicalKeyboardKey.keyF);
  }

  static bool isHomeShortcut(RawKeyEvent event) {
    return isKeyPressed(event, LogicalKeyboardKey.home);
  }

  static bool isQuitShortcut(RawKeyEvent event) {
    return isCtrlPressed(event) && isKeyPressed(event, LogicalKeyboardKey.keyQ);
  }

  /// Playback speed shortcuts
  static bool isSpeedUpShortcut(RawKeyEvent event) {
    return isShiftPressed(event) && isKeyPressed(event, LogicalKeyboardKey.arrowUp);
  }

  static bool isSpeedDownShortcut(RawKeyEvent event) {
    return isShiftPressed(event) && isKeyPressed(event, LogicalKeyboardKey.arrowDown);
  }

  static bool isResetSpeedShortcut(RawKeyEvent event) {
    return isKeyPressed(event, LogicalKeyboardKey.digit1);
  }

  /// Subtitle shortcuts
  static bool isSubtitleToggleShortcut(RawKeyEvent event) {
    return isKeyPressed(event, LogicalKeyboardKey.keyC);
  }

  static bool isSubtitlePositionUpShortcut(RawKeyEvent event) {
    return isCtrlPressed(event) && isKeyPressed(event, LogicalKeyboardKey.arrowUp);
  }

  static bool isSubtitlePositionDownShortcut(RawKeyEvent event) {
    return isCtrlPressed(event) && isKeyPressed(event, LogicalKeyboardKey.arrowDown);
  }

  /// Navigation page shortcuts (1-9)
  static int? getNavigationPageNumber(RawKeyEvent event) {
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.digit1) return 0;
    if (key == LogicalKeyboardKey.digit2) return 1;
    if (key == LogicalKeyboardKey.digit3) return 2;
    if (key == LogicalKeyboardKey.digit4) return 3;
    if (key == LogicalKeyboardKey.digit5) return 4;
    if (key == LogicalKeyboardKey.digit6) return 5;
    if (key == LogicalKeyboardKey.digit7) return 6;
    if (key == LogicalKeyboardKey.digit8) return 7;
    if (key == LogicalKeyboardKey.digit9) return 8;
    return null;
  }

  /// Help shortcuts
  static bool isHelpShortcut(RawKeyEvent event) {
    return isKeyPressed(event, LogicalKeyboardKey.keyH);
  }
}

/// Keyboard shortcuts guide
const keyboardShortcutsGuide = '''
PLAYBACK SHORTCUTS
━━━━━━━━━━━━━━━━━
Space              Toggle play/pause
→ / ← (Arrow)      Skip forward/backward
↑ / ↓ (Arrow)      Volume up/down
M                  Mute toggle
F                  Toggle fullscreen
T                  Toggle theater mode
Ctrl + P           Toggle picture-in-picture

PLAYBACK SPEED
━━━━━━━━━━━━━━━━━
Shift + ↑          Speed up (0.25x)
Shift + ↓          Speed down (0.25x)
1                  Reset speed to 1x

SUBTITLES
━━━━━━━━━━━━━━━━━
C                  Toggle subtitles
Ctrl + ↑           Move subtitles up
Ctrl + ↓           Move subtitles down

NAVIGATION
━━━━━━━━━━━━━━━━━
Ctrl + F           Open search
1-9                Jump to page (1-9)
Home               Go to home page
Ctrl + Q           Quit application

GENERAL
━━━━━━━━━━━━━━━━━
H                  Show this help
''';
