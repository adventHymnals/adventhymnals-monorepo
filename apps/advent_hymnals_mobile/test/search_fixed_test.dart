import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:advent_hymnals/main.dart';

void main() {
  group('Search Fixed Tests', () {
    testWidgets('Search screen renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initial load
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Navigate to Search screen
      await tester.tap(find.text('Search').first);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Verify Search screen components
      expect(find.text('Search'), findsAtLeastNWidgets(1));
      expect(find.text('Search Suggestions'), findsOneWidget);
      expect(find.text('Popular Searches'), findsOneWidget);
      expect(find.text('Search Tips'), findsOneWidget);
    });

    testWidgets('Search functionality works with typing', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initial load
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Navigate to Search screen
      await tester.tap(find.text('Search').first);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Find the search field and type
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
      
      await tester.enterText(searchField, 'amazing');
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Should show results
      expect(find.text('Amazing Grace'), findsAtLeastNWidgets(1));
    });

    testWidgets('Search results show hymn details', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initial load
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Navigate to Search screen
      await tester.tap(find.text('Search').first);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Search for a hymn
      await tester.enterText(find.byType(TextField), 'holy');
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Should show Holy, Holy, Holy
      expect(find.text('Holy, Holy, Holy'), findsAtLeastNWidgets(1));
      expect(find.text('by Reginald Heber'), findsAtLeastNWidgets(1));
    });

    testWidgets('Search navigation to hymn detail works', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initial load
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Navigate to Search screen
      await tester.tap(find.text('Search').first);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Search for a hymn
      await tester.enterText(find.byType(TextField), 'amazing');
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Tap on Amazing Grace result
      await tester.tap(find.text('Amazing Grace').first);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Should navigate to hymn detail
      expect(find.text('Amazing Grace'), findsAtLeastNWidgets(1));
      expect(find.text('John Newton'), findsAtLeastNWidgets(1));
    });

    testWidgets('Search clear button works', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initial load
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Navigate to Search screen
      await tester.tap(find.text('Search').first);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Type in search field
      await tester.enterText(find.byType(TextField), 'test');
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Clear button should appear
      expect(find.byIcon(Icons.clear), findsOneWidget);

      // Tap clear button
      await tester.tap(find.byIcon(Icons.clear));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Should return to suggestions
      expect(find.text('Search Suggestions'), findsOneWidget);
    });

    testWidgets('Search suggestion chips work', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initial load
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Navigate to Search screen
      await tester.tap(find.text('Search').first);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Tap on a suggestion chip
      await tester.tap(find.text('Amazing Grace'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Should show search results
      expect(find.text('Amazing Grace'), findsAtLeastNWidgets(1));
    });
  });
}