import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'providers.dart';
import 'screens/home_screen.dart';
import 'screens/subscriptions_screen.dart';
import 'screens/history_screen.dart';
import 'screens/downloads_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/player_shell.dart';

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

      if (settings.containsKey('theme')) {
        final t = settings['theme'];
        ref.read(themeModeProvider.notifier).state =
            t == 'light' ? ThemeMode.light : (t == 'system' ? ThemeMode.system : ThemeMode.dark);
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
    } catch (e) {
      // Non-fatal: continue with defaults
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tubular PC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.grey[100],
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey[900],
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      themeMode: ref.watch(themeModeProvider),
      home: const PlayerShell(child: MainNavigation()),
    );
  }
}

class MainNavigation extends ConsumerWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);

    final screens = [
      const HomeScreen(),
      const SubscriptionsScreen(),
      const HistoryScreen(),
      const DownloadsScreen(),
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
            backgroundColor: Colors.grey[900],
            selectedIconTheme: IconThemeData(color: Colors.red[700]),
            selectedLabelTextStyle: TextStyle(color: Colors.red[700]),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('Home'),
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
                icon: Icon(Icons.download),
                label: Text('Downloads'),
              ),
            ],
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: NavigationRail(
                  selectedIndex: 0,
                  onDestinationSelected: (_) {
                    // Navigate to settings
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Settings coming soon')),
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

