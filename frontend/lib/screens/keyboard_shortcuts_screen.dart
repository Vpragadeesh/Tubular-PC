import 'package:flutter/material.dart';
import '../services/keyboard_shortcuts.dart';

class KeyboardShortcutsScreen extends StatelessWidget {
  const KeyboardShortcutsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keyboard Shortcuts'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'PLAYBACK SHORTCUTS',
              [
                ('Space', 'Toggle play/pause'),
                ('→ / ← (Arrow)', 'Skip forward/backward 5 seconds'),
                ('J / L', 'Skip backward/forward 10 seconds'),
                ('↑ / ↓ (Arrow)', 'Volume up/down'),
                ('M', 'Mute toggle'),
                ('F', 'Toggle fullscreen'),
                ('Escape', 'Exit fullscreen'),
                ('Ctrl + P', 'Toggle picture-in-picture'),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              'PLAYBACK SPEED',
              [
                ('Shift + ↑', 'Speed up (0.25x increments)'),
                ('Shift + ↓', 'Speed down (0.25x increments)'),
                ('1', 'Reset speed to 1x'),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              'SUBTITLES',
              [
                ('C', 'Toggle subtitles'),
                ('Ctrl + ↑', 'Move subtitles up'),
                ('Ctrl + ↓', 'Move subtitles down'),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              'NAVIGATION',
              [
                ('Ctrl + F', 'Open search'),
                ('1-9', 'Jump to page (1 = Home, 2 = Trending, etc.)'),
                ('Home', 'Go to home page'),
                ('Ctrl + Q', 'Quit application'),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              'GENERAL',
              [
                ('H', 'Show this help'),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tips:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  _buildTip('Press H any time to open this shortcuts guide'),
                  _buildTip('Keyboard shortcuts work when the video player is visible'),
                  _buildTip('Use number keys 1-9 to quickly navigate between different sections'),
                  _buildTip('Hold Shift to adjust playback speed more precisely'),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<(String, String)> shortcuts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        ...shortcuts.map((item) {
          final (key, description) = item;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey[700]!),
                  ),
                  child: Text(
                    key,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[300],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(description),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 8),
            child: Icon(Icons.check_circle, size: 16, color: Colors.blue[700]),
          ),
          Expanded(child: Text(tip, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
