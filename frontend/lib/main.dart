import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'providers.dart';
import 'screens/home_screen.dart';
import 'screens/trending_screen.dart';
import 'screens/playlists_screen.dart';
import 'screens/subscriptions_screen.dart';
import 'screens/history_screen.dart';
import 'screens/bookmarks_screen.dart';
import 'screens/downloads_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/player_shell.dart';
import 'widgets/drag_drop_target.dart';
import 'services/keyboard_shortcut_listener.dart';
import 'services/theme_builder.dart';

final navigationIndexProvider = StateProvider<int>((ref) => 0);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  runApp(const ProviderScope(child: TubularApp()));
}

class TubularApp extends ConsumerStatefulWidget {
  const TubularApp({super.key});

  @override
  ConsumerState<TubularApp> createState() => _TubularAppState();
}

class _TubularAppState extends ConsumerState<TubularApp> {
  @override
  void initState() {
    super.initState();
    // Load settings after first frame so providers are available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  Future<void> _loadSettings() async {
    final api = ref.read(apiServiceProvider);
    try {
      final settings = await api.getAllSettings();
      print('DEBUG: Loaded ${settings.length} settings: $settings');

      if (settings.containsKey('theme')) {
        final t = settings['theme'];
        ref.read(themeModeProvider.notifier).state =
            t == 'light' ? ThemeMode.light : (t == 'system' ? ThemeMode.system : ThemeMode.dark);
        print('DEBUG: Set theme to $t');
      }
      
      // Load custom theme settings
      if (settings.containsKey('dark_mode') || settings.containsKey('amoled_dark') || 
          settings.containsKey('primary_color_hex') || settings.containsKey('preset_theme')) {
        final isDark = settings['dark_mode'] != 'false';
        final isAmoled = settings['amoled_dark'] == 'true';
        final primaryColorHex = settings['primary_color_hex'];
        final presetName = settings['preset_theme'];
        
        Color primaryColor = Colors.red;
        if (primaryColorHex != null && primaryColorHex.startsWith('0x')) {
          try {
            primaryColor = Color(int.parse(primaryColorHex));
          } catch (e) {
            // Keep default
          }
        }
        
        PresetTheme preset = PresetTheme.dark;
        if (presetName != null) {
          try {
            preset = PresetTheme.values.firstWhere(
              (p) => p.name == presetName,
              orElse: () => PresetTheme.dark,
            );
          } catch (e) {
            // Keep default
          }
        }
        
        final customTheme = CustomTheme(
          preset: preset,
          primaryColor: primaryColor,
          secondaryColor: const Color(0xFFB71C1C),
          isDark: isDark,
          isAmoled: isAmoled,
        );
        ref.read(customThemeProvider.notifier).state = customTheme;
      }

      if (settings.containsKey('preferred_quality')) {
        ref.read(preferredQualityProvider.notifier).state = settings['preferred_quality']!;
        print('DEBUG: Set preferred_quality to ${settings['preferred_quality']}');
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
        print('DEBUG: Set playback_speed to $v');
      }
    } catch (e) {
      print('DEBUG: Failed to load settings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final customTheme = ref.watch(customThemeProvider);

    return MaterialApp(
      title: 'Tubular PC',
      debugShowCheckedModeBanner: false,
      theme: ThemeBuilder.buildTheme(
        customTheme.copyWith(isDark: false),
      ),
      darkTheme: ThemeBuilder.buildTheme(customTheme),
      themeMode: ref.watch(themeModeProvider),
      home: KeyboardShortcutListener(
        onSearch: (_) {
          // This will be handled by individual screens
        },
        onHelp: (_) {
          // Show keyboard shortcuts help
          final context = _navigatorKey.currentContext;
          if (context != null) {
            showKeyboardShortcutsDialog(context);
          }
        },
        onNavigationPageSelected: (pageNum) {
          ref.read(navigationIndexProvider.notifier).state = pageNum;
        },
        child: PlayerShell(
          child: DragDropTarget(
            child: MainNavigation(),
          ),
        ),
      ),
      navigatorKey: _navigatorKey,
    );
  }
}

final _navigatorKey = GlobalKey<NavigatorState>();

class MainNavigation extends ConsumerWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);

    final screens = [
      const HomeScreen(),
      const TrendingScreen(),
      const PlaylistsScreen(),
      const SubscriptionsScreen(),
      const HistoryScreen(),
      const BookmarksScreen(),
      const DownloadsScreen(),
      const NotificationsScreen(),
    ];

    return Scaffold(
      body: Row(
        children: [
          // Navigation rail for desktop
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) {
              ref.read(navigationIndexProvider.notifier).state = index;
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedIconTheme: IconThemeData(color: Colors.red[700]),
            selectedLabelTextStyle: TextStyle(color: Colors.red[700]),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.whatshot),
                label: Text('Trending'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.playlist_play),
                label: Text('Playlists'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.subscriptions),
                label: Text('Subscriptions'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.history),
                label: Text('History'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bookmark),
                label: Text('Bookmarks'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.download),
                label: Text('Downloads'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.notifications),
                label: Text('Notifications'),
              ),
            ],
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: NavigationRail(
                  selectedIndex: 0,
                  onDestinationSelected: (_) {
                    // Navigate to settings screen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  },
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: Colors.transparent,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.settings),
                      label: Text('Settings'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Main content
          Expanded(
            child: screens[currentIndex],
          ),
        ],
      ),
    );
  }
}

