import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../services/theme_builder.dart';

/// Theme customization screen
class ThemeCustomizationScreen extends ConsumerStatefulWidget {
  const ThemeCustomizationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ThemeCustomizationScreen> createState() =>
      _ThemeCustomizationScreenState();
}

class _ThemeCustomizationScreenState extends ConsumerState<ThemeCustomizationScreen> {
  late CustomTheme _currentTheme;

  @override
  void initState() {
    super.initState();
    _currentTheme = ref.read(customThemeProvider);
  }

  @override
  Widget build(BuildContext context) {
    final presets = ThemeBuilder.getPresetThemes();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Customization'),
        backgroundColor: Colors.red[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preset Themes Section
            const Text(
              'Preset Themes',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                for (final entry in presets.entries)
                  _PresetThemeCard(
                    preset: entry.key,
                    theme: entry.value,
                    isSelected: _currentTheme.preset == entry.key,
                    onTap: () {
                      setState(() {
                        _currentTheme = entry.value;
                      });
                      ref.read(customThemeProvider.notifier).state = entry.value;
                      _saveTheme();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Color Customization Section
            const Text(
              'Color Customization',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),

            // Primary Color
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade700),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Primary Color: '),
                      const SizedBox(width: 8),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _currentTheme.primaryColor,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey.shade600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Colors.red,
                      Colors.pink,
                      Colors.purple,
                      Colors.blue,
                      Colors.cyan,
                      Colors.teal,
                      Colors.green,
                      Colors.lime,
                      Colors.orange,
                      Colors.amber,
                    ].map((color) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentTheme = _currentTheme.copyWith(
                              primaryColor: color,
                              preset: PresetTheme.dark, // Mark as custom
                            );
                          });
                          ref.read(customThemeProvider.notifier).state =
                              _currentTheme;
                          _saveTheme();
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                            border: _currentTheme.primaryColor == color
                                ? Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  )
                                : Border.all(color: Colors.grey.shade600),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Dark Mode Toggle
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade700),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Dark Mode'),
                  Switch(
                    value: _currentTheme.isDark,
                    onChanged: (value) {
                      setState(() {
                        _currentTheme =
                            _currentTheme.copyWith(isDark: value);
                      });
                      ref.read(customThemeProvider.notifier).state =
                          _currentTheme;
                      _saveTheme();
                    },
                    activeColor: Colors.red[700],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // AMOLED Toggle
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade700),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('AMOLED Black Background'),
                  Switch(
                    value: _currentTheme.isAmoled,
                    onChanged: (value) {
                      setState(() {
                        _currentTheme =
                            _currentTheme.copyWith(isAmoled: value);
                      });
                      ref.read(customThemeProvider.notifier).state =
                          _currentTheme;
                      _saveTheme();
                    },
                    activeColor: Colors.red[700],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Preview Section
            const Text(
              'Preview',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _currentTheme.isDark
                    ? (_currentTheme.isAmoled
                        ? const Color(0xFF000000)
                        : Colors.grey.shade900)
                    : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade700),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _currentTheme.primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Primary Color Sample',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentTheme.primaryColor,
                    ),
                    child: const Text('Button'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Text Sample (Dark Mode: ${_currentTheme.isDark ? 'On' : 'Off'}, AMOLED: ${_currentTheme.isAmoled ? 'On' : 'Off'})',
                    style: TextStyle(
                      color: _currentTheme.isDark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTheme() async {
    final api = ref.read(apiServiceProvider);
    await api.setSetting(
      'primary_color_hex',
      '0x${_currentTheme.primaryColor.value.toRadixString(16).padLeft(8, '0')}',
    );
    await api.setSetting(
      'secondary_color_hex',
      '0x${_currentTheme.secondaryColor.value.toRadixString(16).padLeft(8, '0')}',
    );
    await api.setSetting('dark_mode', _currentTheme.isDark.toString());
    await api.setSetting('amoled_dark', _currentTheme.isAmoled.toString());
    await api.setSetting('preset_theme', _currentTheme.preset.name);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Theme saved'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

class _PresetThemeCard extends StatelessWidget {
  final PresetTheme preset;
  final CustomTheme theme;
  final bool isSelected;
  final VoidCallback onTap;

  const _PresetThemeCard({
    required this.preset,
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.red[700]! : Colors.grey.shade700,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              preset.label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.red[700],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
