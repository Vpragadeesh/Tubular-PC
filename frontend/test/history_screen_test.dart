import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../lib/screens/history_screen.dart';
import '../lib/providers.dart';

void main() {
  group('HistoryScreen CSV Export - Basic Structure', () {
    testWidgets('HistoryScreen has export button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HistoryScreen(),
          ),
        ),
      );

      // Check that the download/export icon is present in the app bar
      expect(find.byIcon(Icons.download), findsOneWidget);
    });

    testWidgets('HistoryScreen title is correct', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HistoryScreen(),
          ),
        ),
      );

      expect(find.text('Watch History'), findsOneWidget);
    });
  });
}