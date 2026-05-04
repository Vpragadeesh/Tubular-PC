import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';
import 'screens/subscriptions_screen.dart';
import 'screens/history_screen.dart';
import 'screens/downloads_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/player_shell.dart';

final navigationIndexProvider = StateProvider<int>((ref) => 0);

void main() {
  runApp(const ProviderScope(child: TubularApp()));
}

class TubularApp extends StatelessWidget {
  const TubularApp({super.key});

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

