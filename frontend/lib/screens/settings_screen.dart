import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

// Quality preference provider
final preferredQualityProvider = StateProvider<String>((ref) => '720p');

// Format preference provider (video, audio, both)
final preferredFormatProvider = StateProvider<String>((ref) => 'video');

// Audio-only mode provider
final audioOnlyModeProvider = StateProvider<bool>((ref) => false);

// Auto-play provider
final autoPlayProvider = StateProvider<bool>((ref) => true);

// Download folder provider
final downloadFolderProvider = StateProvider<String>((ref) => '~/Downloads/Tubular');

// Subtitle font size provider
final subtitleFontSizeProvider = StateProvider<double>((ref) => 14.0);

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final preferredQuality = ref.watch(preferredQualityProvider);
    final preferredFormat = ref.watch(preferredFormatProvider);
    final audioOnly = ref.watch(audioOnlyModeProvider);
    final autoPlay = ref.watch(autoPlayProvider);
    final downloadFolder = ref.watch(downloadFolderProvider);
    final subtitleSize = ref.watch(subtitleFontSizeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // Appearance Section
          _buildSectionHeader('Appearance'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  title: const Text('Theme'),
                  subtitle: Text(themeMode == ThemeMode.dark ? 'Dark' : 'Light'),
                  trailing: DropdownButton<ThemeMode>(
                    value: themeMode,
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Light'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Dark'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('System'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(themeModeProvider.notifier).state = value;
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Subtitle Font Size'),
                  subtitle: Slider(
                    value: subtitleSize,
                    min: 10,
                    max: 30,
                    divisions: 20,
                    label: subtitleSize.toStringAsFixed(0),
                    onChanged: (value) {
                      ref.read(subtitleFontSizeProvider.notifier).state = value;
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Playback Section
          _buildSectionHeader('Playback'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  title: const Text('Preferred Quality'),
                  subtitle: Text(preferredQuality),
                  trailing: DropdownButton<String>(
                    value: preferredQuality,
                    items: const [
                      DropdownMenuItem(value: '360p', child: Text('360p')),
                      DropdownMenuItem(value: '480p', child: Text('480p')),
                      DropdownMenuItem(value: '720p', child: Text('720p')),
                      DropdownMenuItem(value: '1080p', child: Text('1080p')),
                      DropdownMenuItem(value: '1440p', child: Text('1440p')),
                      DropdownMenuItem(value: '2160p', child: Text('2160p')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(preferredQualityProvider.notifier).state = value;
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Preferred Format'),
                  subtitle: Text(preferredFormat),
                  trailing: DropdownButton<String>(
                    value: preferredFormat,
                    items: const [
                      DropdownMenuItem(value: 'video', child: Text('Video')),
                      DropdownMenuItem(value: 'audio', child: Text('Audio Only')),
                      DropdownMenuItem(value: 'both', child: Text('Both')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(preferredFormatProvider.notifier).state = value;
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Audio-Only Mode'),
                  subtitle: const Text('Default to audio playback'),
                  value: audioOnly,
                  onChanged: (value) {
                    ref.read(audioOnlyModeProvider.notifier).state = value;
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Auto-Play Next'),
                  subtitle: const Text('Automatically play next video'),
                  value: autoPlay,
                  onChanged: (value) {
                    ref.read(autoPlayProvider.notifier).state = value;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Downloads Section
          _buildSectionHeader('Downloads'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  title: const Text('Download Folder'),
                  subtitle: Text(downloadFolder),
                  trailing: const Icon(Icons.folder_open),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Folder picker coming soon')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // About Section
          _buildSectionHeader('About'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  title: const Text('Version'),
                  subtitle: const Text('1.0.0'),
                  trailing: const Icon(Icons.info_outline),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('GitHub'),
                  subtitle: const Text('View source code'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening GitHub')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Check for Updates'),
                  trailing: const Icon(Icons.system_update),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('You are on the latest version')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.red[700],
        ),
      ),
    );
  }
}
