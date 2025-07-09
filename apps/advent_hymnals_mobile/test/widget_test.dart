// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:advent_hymnals_mobile/main.dart';
import 'package:advent_hymnals_mobile/presentation/screens/tunes_browse_screen.dart';
import 'package:advent_hymnals_mobile/presentation/screens/meters_browse_screen.dart';

void main() {
  group('Widget Tests', () {
    testWidgets('App smoke test - basic initialization', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Allow multiple pumps to settle async operations
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Verify that our app starts correctly - should have bottom navigation
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Home'), findsAtLeastNWidgets(1));
      expect(find.text('Browse'), findsAtLeastNWidgets(1));
      expect(find.text('Search'), findsAtLeastNWidgets(1));
      expect(find.text('Favorites'), findsAtLeastNWidgets(1));
      expect(find.text('More'), findsAtLeastNWidgets(1));
    });

    testWidgets('Tunes Browse Screen widget test', (WidgetTester tester) async {
      // Test individual screen without full app context
      await tester.pumpWidget(const MaterialApp(home: TunesBrowseScreen()));
      await tester.pumpAndSettle();

      // Verify screen loads correctly
      expect(find.text('Tunes'), findsOneWidget);
      expect(find.text('Search Tunes'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Meters Browse Screen widget test', (WidgetTester tester) async {
      // Test individual screen without full app context
      await tester.pumpWidget(const MaterialApp(home: MetersBrowseScreen()));
      await tester.pumpAndSettle();

      // Verify screen loads correctly
      expect(find.text('Meters'), findsOneWidget);
      expect(find.text('Search Meters'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
