import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'keyboard_shortcuts.dart';

typedef KeyboardShortcutHandler = void Function(RawKeyEvent event);

/// Wrapper widget that provides keyboard shortcut handling to its child
class KeyboardShortcutListener extends StatefulWidget {
  final Widget child;
  final KeyboardShortcutHandler? onPlayPause;
  final KeyboardShortcutHandler? onSkipForward;
  final KeyboardShortcutHandler? onSkipBackward;
  final KeyboardShortcutHandler? onVolumeUp;
  final KeyboardShortcutHandler? onVolumeDown;
  final KeyboardShortcutHandler? onMuteToggle;
  final KeyboardShortcutHandler? onFullscreen;
  final KeyboardShortcutHandler? onTheaterMode;
  final KeyboardShortcutHandler? onSearch;
  final KeyboardShortcutHandler? onHome;
  final KeyboardShortcutHandler? onQuit;
  final KeyboardShortcutHandler? onSpeedUp;
  final KeyboardShortcutHandler? onSpeedDown;
  final KeyboardShortcutHandler? onResetSpeed;
  final KeyboardShortcutHandler? onSubtitleToggle;
  final KeyboardShortcutHandler? onHelp;
  final Function(int)? onNavigationPageSelected;
  final bool focusNode;

  const KeyboardShortcutListener({
    required this.child,
    this.onPlayPause,
    this.onSkipForward,
    this.onSkipBackward,
    this.onVolumeUp,
    this.onVolumeDown,
    this.onMuteToggle,
    this.onFullscreen,
    this.onTheaterMode,
    this.onSearch,
    this.onHome,
    this.onQuit,
    this.onSpeedUp,
    this.onSpeedDown,
    this.onResetSpeed,
    this.onSubtitleToggle,
    this.onHelp,
    this.onNavigationPageSelected,
    this.focusNode = false,
    Key? key,
  }) : super(key: key);

  @override
  State<KeyboardShortcutListener> createState() => _KeyboardShortcutListenerState();
}

class _KeyboardShortcutListenerState extends State<KeyboardShortcutListener> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.focusNode) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;

    if (KeyboardShortcuts.isPlayPauseShortcut(event)) {
      widget.onPlayPause?.call(event);
    } else if (KeyboardShortcuts.isSkipForwardShortcut(event)) {
      widget.onSkipForward?.call(event);
    } else if (KeyboardShortcuts.isSkipBackwardShortcut(event)) {
      widget.onSkipBackward?.call(event);
    } else if (KeyboardShortcuts.isVolumeUpShortcut(event)) {
      widget.onVolumeUp?.call(event);
    } else if (KeyboardShortcuts.isVolumeDownShortcut(event)) {
      widget.onVolumeDown?.call(event);
    } else if (KeyboardShortcuts.isMuteToggleShortcut(event)) {
      widget.onMuteToggle?.call(event);
    } else if (KeyboardShortcuts.isFullscreenShortcut(event)) {
      widget.onFullscreen?.call(event);
    } else if (KeyboardShortcuts.isTheaterModeShortcut(event)) {
      widget.onTheaterMode?.call(event);
    } else if (KeyboardShortcuts.isSearchShortcut(event)) {
      widget.onSearch?.call(event);
    } else if (KeyboardShortcuts.isHomeShortcut(event)) {
      widget.onHome?.call(event);
    } else if (KeyboardShortcuts.isQuitShortcut(event)) {
      widget.onQuit?.call(event);
    } else if (KeyboardShortcuts.isSpeedUpShortcut(event)) {
      widget.onSpeedUp?.call(event);
    } else if (KeyboardShortcuts.isSpeedDownShortcut(event)) {
      widget.onSpeedDown?.call(event);
    } else if (KeyboardShortcuts.isResetSpeedShortcut(event)) {
      widget.onResetSpeed?.call(event);
    } else if (KeyboardShortcuts.isSubtitleToggleShortcut(event)) {
      widget.onSubtitleToggle?.call(event);
    } else if (KeyboardShortcuts.isHelpShortcut(event)) {
      widget.onHelp?.call(event);
    } else {
      // Check for navigation page shortcuts (1-9)
      final pageNum = KeyboardShortcuts.getNavigationPageNumber(event);
      if (pageNum != null) {
        widget.onNavigationPageSelected?.call(pageNum);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: _handleKeyEvent,
      child: widget.child,
    );
  }
}

/// Show keyboard shortcuts help dialog
Future<void> showKeyboardShortcutsDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Keyboard Shortcuts'),
      content: SingleChildScrollView(
        child: Text(
          keyboardShortcutsGuide,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}
