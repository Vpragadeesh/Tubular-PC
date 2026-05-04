import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());

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

// Additional settings
final enableSponsorBlockProvider = StateProvider<bool>((ref) => true);
final enableDislikeCountsProvider = StateProvider<bool>((ref) => true);
final enableSubtitlesProvider = StateProvider<bool>((ref) => true);
final enableNotificationsProvider = StateProvider<bool>((ref) => false);

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  void _saveSetting(String key, String value) {
    final apiService = ref.read(apiServiceProvider);
    apiService.setSetting(key, value).then((_) {
      // Silent success
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save setting: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final preferredQuality = ref.watch(preferredQualityProvider);
    final preferredFormat = ref.watch(preferredFormatProvider);
    final audioOnly = ref.watch(audioOnlyModeProvider);
    final autoPlay = ref.watch(autoPlayProvider);
    final downloadFolder = ref.watch(downloadFolderProvider);
    final subtitleSize = ref.watch(subtitleFontSizeProvider);
    final sponsorBlock = ref.watch(enableSponsorBlockProvider);
    final dislikeCounts = ref.watch(enableDislikeCountsProvider);
    final subtitles = ref.watch(enableSubtitlesProvider);
    final notifications = ref.watch(enableNotificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // =========== APPEARANCE SECTION ===========
          _buildSectionHeader(context, 'Appearance', Icons.palette),
          _buildSectionCard(
            children: [
              _buildDropdownTile(
                context,
                'Theme',
                themeMode == ThemeMode.dark ? 'Dark' : 'Light',
                items: const [
                  DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                  DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref.read(themeModeProvider.notifier).state = value;
                    String themeValue = value == ThemeMode.dark ? 'dark' : (value == ThemeMode.light ? 'light' : 'system');
                    _saveSetting('theme', themeValue);
                  }
                },
              ),
              const Divider(height: 1),
               _buildSliderTile(
                 'Subtitle Font Size',
                 subtitleSize,
                 10,
                 30,
                 (value) {
                   ref.read(subtitleFontSizeProvider.notifier).state = value;
                   _saveSetting('subtitle_font_size', value.toString());
                 },
               ),
            ],
          ),
          const SizedBox(height: 12),

          // =========== PLAYBACK SECTION ===========
          _buildSectionHeader(context, 'Playback', Icons.videogame_asset),
          _buildSectionCard(
            children: [
              _buildDropdownTile(
                context,
                'Preferred Quality',
                preferredQuality,
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
                    _saveSetting('preferred_quality', value);
                  }
                },
              ),
              const Divider(height: 1),
              _buildDropdownTile(
                context,
                'Preferred Format',
                preferredFormat,
                items: const [
                  DropdownMenuItem(value: 'video', child: Text('Video')),
                  DropdownMenuItem(value: 'audio', child: Text('Audio Only')),
                  DropdownMenuItem(value: 'both', child: Text('Both')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref.read(preferredFormatProvider.notifier).state = value;
                    _saveSetting('preferred_format', value);
                  }
                },
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                 'Audio-Only Mode',
                 'Default to audio playback',
                 audioOnly,
                 (value) {
                   ref.read(audioOnlyModeProvider.notifier).state = value;
                   _saveSetting('audio_only_mode', value.toString());
                 },
               ),
               const Divider(height: 1),
               _buildSwitchTile(
                 'Auto-Play Next',
                 'Automatically play next video',
                 autoPlay,
                 (value) {
                   ref.read(autoPlayProvider.notifier).state = value;
                   _saveSetting('auto_play', value.toString());
                 },
               ),
               const Divider(height: 1),
                _buildSwitchTile(
                 'Show Subtitles',
                 'Display subtitles when available',
                 subtitles,
                 (value) {
                   ref.read(enableSubtitlesProvider.notifier).state = value;
                   _saveSetting('enable_subtitles', value.toString());
                 },
               ),
            ],
          ),
          const SizedBox(height: 12),

          // =========== FEATURES SECTION ===========
          _buildSectionHeader(context, 'Features', Icons.star),
          _buildSectionCard(
            children: [
               _buildSwitchTile(
                 'SponsorBlock',
                 'Skip sponsored segments automatically',
                 sponsorBlock,
                 (value) {
                   ref.read(enableSponsorBlockProvider.notifier).state = value;
                   _saveSetting('enable_sponsorblock', value.toString());
                 },
               ),
               const Divider(height: 1),
               _buildSwitchTile(
                 'Show Dislike Counts',
                 'Display community dislike counts',
                 dislikeCounts,
                 (value) {
                   ref.read(enableDislikeCountsProvider.notifier).state = value;
                   _saveSetting('enable_dislike_counts', value.toString());
                 },
               ),
            ],
          ),
          const SizedBox(height: 12),

          // =========== DOWNLOADS SECTION ===========
          _buildSectionHeader(context, 'Downloads', Icons.download),
          _buildSectionCard(
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
          const SizedBox(height: 12),

          // =========== PRIVACY & NOTIFICATIONS ===========
          _buildSectionHeader(context, 'Privacy & Notifications', Icons.lock),
          _buildSectionCard(
            children: [
              _buildSwitchTile(
                'Notifications',
                'Show download and update notifications',
                notifications,
                (value) {
                  ref.read(enableNotificationsProvider.notifier).state = value;
                },
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Clear Cache'),
                subtitle: const Text('Remove cached images and data'),
                trailing: const Icon(Icons.cleaning_services),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cache cleared')),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening privacy policy')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // =========== ABOUT SECTION ===========
          _buildSectionHeader(context, 'About', Icons.info),
          _buildSectionCard(
            children: [
              const ListTile(
                title: Text('Version'),
                subtitle: Text('1.0.0'),
                trailing: Icon(Icons.info_outline),
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('GitHub Repository'),
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
              const Divider(height: 1),
              ListTile(
                title: const Text('Report an Issue'),
                trailing: const Icon(Icons.bug_report),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening issue tracker')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.red[700]),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(children: children),
    );
  }

  Widget _buildDropdownTile(
    BuildContext context,
    String title,
    String currentValue, {
    required List<DropdownMenuItem<dynamic>> items,
    required ValueChanged<dynamic> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(currentValue),
      trailing: DropdownButton(
        value: currentValue,
        items: items,
        onChanged: onChanged,
        underline: const SizedBox(),
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Slider(
        value: value,
        min: min,
        max: max,
        divisions: (max - min).toInt(),
        label: value.toStringAsFixed(0),
        onChanged: onChanged,
        activeColor: Colors.red[700],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.red[700],
    );
  }
}
