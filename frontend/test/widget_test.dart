import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tubular_pc/main.dart';

void main() {
  testWidgets('renders Tubular app shell', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: TubularApp()));

    expect(find.text('Tubular PC'), findsOneWidget);
    expect(find.text('Search videos...'), findsOneWidget);
  });
}
