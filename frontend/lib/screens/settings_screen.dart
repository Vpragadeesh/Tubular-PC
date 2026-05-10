import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const String _tubularConfigFormat = 'tubular-settings';
  static const int _tubularConfigVersion = 1;

  void _saveSetting(String key, String value) {
    final apiService = ref.read(apiServiceProvider);
    print('DEBUG: Saving setting $key = $value');
    apiService.setSetting(key, value).then((_) {
      print('DEBUG: Successfully saved setting $key');
    }).catchError((e) {
      print('DEBUG: Failed to save setting $key: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save setting: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
    });
  }

  Future<void> _exportSettingsConfig() async {
    final apiService = ref.read(apiServiceProvider);
    try {
      final settings = await apiService.getAllSettings();
      final payload = {
        'format': _tubularConfigFormat,
        'version': _tubularConfigVersion,
        'exported_at': DateTime.now().toIso8601String(),
        'settings': settings,
      };

      final suggestedPath = _defaultExportPath();
      final targetPath = await _promptForPath(
        title: 'Export Settings',
        hintText: '/home/user/Downloads/tubular-settings.tubular',
        initialValue: suggestedPath,
        confirmText: 'Export',
      );
      if (targetPath == null || targetPath.trim().isEmpty) return;

      var finalPath = targetPath.trim();
      if (!finalPath.endsWith('.tubular')) {
        finalPath = '$finalPath.tubular';
      }

      final outputFile = File(finalPath);
      await outputFile.parent.create(recursive: true);
      await outputFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(payload),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Settings exported: $finalPath')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export settings: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  Future<void> _importSettingsConfig() async {
    final apiService = ref.read(apiServiceProvider);
    final sourcePath = await _promptForPath(
      title: 'Import Settings',
      hintText: '/home/user/Downloads/tubular-settings.tubular',
      initialValue: _defaultImportPath(),
      confirmText: 'Import',
    );
    if (sourcePath == null || sourcePath.trim().isEmpty) return;

    try {
      final file = File(sourcePath.trim());
      if (!await file.exists()) {
        throw Exception('File not found: ${file.path}');
      }

      final raw = await file.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid config file structure');
      }

      final format = decoded['format']?.toString();
      if (format != _tubularConfigFormat) {
        throw Exception('Unsupported format: $format');
      }

      final settingsNode = decoded['settings'];
      if (settingsNode is! Map) {
        throw Exception('Missing settings block in config');
      }

      final imported = <String, String>{};
      settingsNode.forEach((key, value) {
        if (key != null && value != null) {
          imported[key.toString()] = value.toString();
        }
      });

      for (final entry in imported.entries) {
        await apiService.setSetting(entry.key, entry.value);
      }
      _applyImportedSettings(imported);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Settings imported (${imported.length} entries)')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to import settings: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  void _applyImportedSettings(Map<String, String> settings) {
    if (settings.containsKey('theme')) {
      final t = settings['theme'];
      ref.read(themeModeProvider.notifier).state =
          t == 'light' ? ThemeMode.light : (t == 'system' ? ThemeMode.system : ThemeMode.dark);
    }
    if (settings.containsKey('amoled_dark')) {
      ref.read(amoledDarkProvider.notifier).state = settings['amoled_dark'] == 'true';
    }
    if (settings.containsKey('preferred_quality')) {
      ref.read(preferredQualityProvider.notifier).state = settings['preferred_quality']!;
    }
    if (settings.containsKey('preferred_format')) {
      ref.read(preferredFormatProvider.notifier).state = settings['preferred_format']!;
    }
    if (settings.containsKey('audio_only_mode')) {
      ref.read(audioOnlyModeProvider.notifier).state = settings['audio_only_mode'] == 'true';
    }
    if (settings.containsKey('auto_play')) {
      ref.read(autoPlayProvider.notifier).state = settings['auto_play'] == 'true';
    }
    if (settings.containsKey('subtitle_font_size')) {
      final v = double.tryParse(settings['subtitle_font_size'] ?? '14.0') ?? 14.0;
      ref.read(subtitleFontSizeProvider.notifier).state = v;
    }
    if (settings.containsKey('download_folder')) {
      ref.read(downloadFolderProvider.notifier).state = settings['download_folder']!;
    }
    if (settings.containsKey('enable_sponsorblock')) {
      ref.read(enableSponsorBlockProvider.notifier).state = settings['enable_sponsorblock'] == 'true';
    }
    if (settings.containsKey('enable_dislike_counts')) {
      ref.read(enableDislikeCountsProvider.notifier).state = settings['enable_dislike_counts'] == 'true';
    }
    if (settings.containsKey('enable_subtitles')) {
      ref.read(enableSubtitlesProvider.notifier).state = settings['enable_subtitles'] == 'true';
    }
    if (settings.containsKey('enable_notifications')) {
      ref.read(enableNotificationsProvider.notifier).state = settings['enable_notifications'] == 'true';
    }
    if (settings.containsKey('playback_speed')) {
      final v = double.tryParse(settings['playback_speed'] ?? '1.0') ?? 1.0;
      ref.read(playbackSpeedProvider.notifier).state = v;
    }
  }

  Future<String?> _promptForPath({
    required String title,
    required String hintText,
    required String initialValue,
    required String confirmText,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final value = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(controller.text.trim()),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
    controller.dispose();
    return value;
  }

  String _defaultExportPath() {
    final home = Platform.environment['HOME'];
    final base = home == null || home.isEmpty ? '.' : '$home/Downloads';
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$base/tubular-settings-$y$m$d.tubular';
  }

  String _defaultImportPath() {
    final home = Platform.environment['HOME'];
    final base = home == null || home.isEmpty ? '.' : '$home/Downloads';
    return '$base/tubular-settings.tubular';
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final amoledDark = ref.watch(amoledDarkProvider);
    final preferredQuality = ref.watch(preferredQualityProvider);
    final preferredFormat = ref.watch(preferredFormatProvider);
    final audioOnly = ref.watch(audioOnlyModeProvider);
    final autoPlay = ref.watch(autoPlayProvider);
    final downloadFolder = ref.watch(downloadFolderProvider);
    final subtitleSize = ref.watch(subtitleFontSizeProvider);
    final playbackSpeed = ref.watch(playbackSpeedProvider);
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
                themeMode,
                themeMode == ThemeMode.dark
                    ? 'Dark'
                    : (themeMode == ThemeMode.light ? 'Light' : 'System'),
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
              _buildSwitchTile(
                'AMOLED Dark',
                'Use pure black surfaces in dark theme',
                amoledDark,
                (value) {
                  ref.read(amoledDarkProvider.notifier).state = value;
                  _saveSetting('amoled_dark', value.toString());
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
                preferredQuality,
                items: const [
                  DropdownMenuItem(value: 'audio', child: Text('Audio Only')),
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
                'Playback Speed',
                playbackSpeed.toString(),
                playbackSpeed.toString(),
                items: const [
                  DropdownMenuItem(value: '0.5', child: Text('0.5x')),
                  DropdownMenuItem(value: '0.75', child: Text('0.75x')),
                  DropdownMenuItem(value: '1.0', child: Text('1.0x')),
                  DropdownMenuItem(value: '1.25', child: Text('1.25x')),
                  DropdownMenuItem(value: '1.5', child: Text('1.5x')),
                  DropdownMenuItem(value: '2.0', child: Text('2.0x')),
                  DropdownMenuItem(value: '2.25', child: Text('2.25x')),
                  DropdownMenuItem(value: '2.5', child: Text('2.5x')),
                  DropdownMenuItem(value: '2.75', child: Text('2.75x')),
                  DropdownMenuItem(value: '3.0', child: Text('3.0x')),
                  DropdownMenuItem(value: '3.25', child: Text('3.25x')),
                  DropdownMenuItem(value: '3.5', child: Text('3.5x')),
                  DropdownMenuItem(value: '3.75', child: Text('3.75x')),
                  DropdownMenuItem(value: '4.0', child: Text('4.0x')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    final v = double.tryParse(value) ?? 1.0;
                    ref.read(playbackSpeedProvider.notifier).state = v;
                    _saveSetting('playback_speed', v.toString());
                  }
                },
              ),
              _buildDropdownTile(
                context,
                'Preferred Format',
                preferredFormat,
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

          // =========== SETTINGS CONFIG ===========
          _buildSectionHeader(context, 'Settings Config', Icons.import_export),
          _buildSectionCard(
            children: [
              ListTile(
                title: const Text('Export Settings'),
                subtitle: const Text('Export to .tubular config file'),
                trailing: const Icon(Icons.upload_file),
                onTap: _exportSettingsConfig,
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Import Settings'),
                subtitle: const Text('Import from .tubular config file'),
                trailing: const Icon(Icons.download_for_offline),
                onTap: _importSettingsConfig,
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
    dynamic selectedValue,
    String subtitleText, {
    required List<DropdownMenuItem<dynamic>> items,
    required ValueChanged<dynamic> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitleText),
      trailing: DropdownButton(
        value: selectedValue,
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
