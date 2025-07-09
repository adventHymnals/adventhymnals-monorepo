import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:advent_hymnals_mobile/main.dart';
import 'package:advent_hymnals_mobile/presentation/screens/search_screen.dart';
import 'package:advent_hymnals_mobile/core/constants/app_constants.dart';

void main() {
  group('Search Functionality Tests', () {
    testWidgets('Main search screen functionality', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SearchScreen()));
      await tester.pumpAndSettle();

      // Check initial state
      expect(find.text('Search Hymns'), findsOneWidget);
      expect(find.text('Find hymns by title, author, or lyrics'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Test search input
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Amazing Grace');
      await tester.pumpAndSettle();

      // Test search button
      final searchButton = find.byIcon(Icons.search);
      if (searchButton.evaluate().isNotEmpty) {
        await tester.tap(searchButton);
        await tester.pumpAndSettle();
      }

      // Test filter chips
      final filterChips = find.byType(FilterChip);
      if (filterChips.evaluate().isNotEmpty) {
        await tester.tap(filterChips.first);
        await tester.pumpAndSettle();
      }

      // Test clear functionality
      await tester.enterText(searchField, 'test');
      await tester.pumpAndSettle();
      
      final clearButton = find.byIcon(Icons.clear);
      if (clearButton.evaluate().isNotEmpty) {
        await tester.tap(clearButton);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Search across different browse screens', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      await tester.pumpAndSettle();

      // Test search in tunes screen
      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.tunesTitle));
      await tester.pumpAndSettle();

      var searchField = find.byType(TextField);
      await tester.enterText(searchField, 'AMAZING');
      await tester.pumpAndSettle();
      expect(find.text('AMAZING GRACE'), findsOneWidget);

      // Go back and test meters screen
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.metersTitle));
      await tester.pumpAndSettle();

      searchField = find.byType(TextField);
      await tester.enterText(searchField, 'CM');
      await tester.pumpAndSettle();
      expect(find.text('CM'), findsOneWidget);
      expect(find.text('Common Meter'), findsOneWidget);

      // Go back and test scripture screen
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.scriptureTitle));
      await tester.pumpAndSettle();

      searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Psalm');
      await tester.pumpAndSettle();
      expect(find.text('Psalm 23'), findsOneWidget);

      // Go back and test first lines screen
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.firstLinesTitle));
      await tester.pumpAndSettle();

      searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Amazing grace');
      await tester.pumpAndSettle();
      expect(find.text('Amazing grace! How sweet the sound'), findsOneWidget);
    });

    testWidgets('Search input validation and edge cases', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      await tester.pumpAndSettle();

      // Navigate to tunes screen for detailed search testing
      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.tunesTitle));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);

      // Test empty search
      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();
      expect(find.text('AMAZING GRACE'), findsOneWidget);

      // Test whitespace search
      await tester.enterText(searchField, '   ');
      await tester.pumpAndSettle();
      expect(find.text('AMAZING GRACE'), findsOneWidget);

      // Test single character search
      await tester.enterText(searchField, 'A');
      await tester.pumpAndSettle();
      expect(find.text('AMAZING GRACE'), findsOneWidget);
      expect(find.text('AUSTRIA'), findsOneWidget);

      // Test case insensitive search
      await tester.enterText(searchField, 'amazing');
      await tester.pumpAndSettle();
      expect(find.text('AMAZING GRACE'), findsOneWidget);

      // Test partial word search
      await tester.enterText(searchField, 'AMAZ');
      await tester.pumpAndSettle();
      expect(find.text('AMAZING GRACE'), findsOneWidget);

      // Test search with special characters
      await tester.enterText(searchField, 'AUSTRIA');
      await tester.pumpAndSettle();
      expect(find.text('AUSTRIA'), findsOneWidget);

      // Test no results
      await tester.enterText(searchField, 'xyz123nonexistent');
      await tester.pumpAndSettle();
      expect(find.text('No tunes found'), findsOneWidget);
    });

    testWidgets('Search clear functionality', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      await tester.pumpAndSettle();

      // Navigate to meters screen
      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.metersTitle));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);

      // Enter search text
      await tester.enterText(searchField, 'LM');
      await tester.pumpAndSettle();

      // Clear button should appear
      final clearButton = find.byIcon(Icons.clear);
      expect(clearButton, findsOneWidget);

      // Test clear functionality
      await tester.tap(clearButton);
      await tester.pumpAndSettle();

      // Should show all results again
      expect(find.text('CM'), findsOneWidget);
      expect(find.text('LM'), findsOneWidget);
      expect(find.text('87.87 D'), findsOneWidget);

      // Clear button should be gone
      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('Search performance with rapid typing', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      await tester.pumpAndSettle();

      // Navigate to first lines screen
      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.firstLinesTitle));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);

      // Test rapid typing
      await tester.enterText(searchField, 'A');
      await tester.pump(const Duration(milliseconds: 50));
      await tester.enterText(searchField, 'Am');
      await tester.pump(const Duration(milliseconds: 50));
      await tester.enterText(searchField, 'Ama');
      await tester.pump(const Duration(milliseconds: 50));
      await tester.enterText(searchField, 'Amaz');
      await tester.pump(const Duration(milliseconds: 50));
      await tester.enterText(searchField, 'Amazin');
      await tester.pump(const Duration(milliseconds: 50));
      await tester.enterText(searchField, 'Amazing');
      await tester.pumpAndSettle();

      // Should handle rapid typing gracefully
      expect(find.text('Amazing grace! How sweet the sound'), findsOneWidget);
    });

    testWidgets('Search with special characters and numbers', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      await tester.pumpAndSettle();

      // Navigate to scripture screen
      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.scriptureTitle));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);

      // Test search with numbers
      await tester.enterText(searchField, '23');
      await tester.pumpAndSettle();
      expect(find.text('Psalm 23'), findsOneWidget);

      // Test search with colon
      await tester.enterText(searchField, '3:16');
      await tester.pumpAndSettle();
      expect(find.text('John 3:16'), findsOneWidget);

      // Test search with dash
      await tester.enterText(searchField, '28:19-20');
      await tester.pumpAndSettle();
      expect(find.text('Matthew 28:19-20'), findsOneWidget);

      // Test search with special characters that don't match
      await tester.enterText(searchField, '!@#\$%');
      await tester.pumpAndSettle();
      expect(find.text('No scripture references found'), findsOneWidget);
    });

    testWidgets('Search field focus and keyboard interaction', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      await tester.pumpAndSettle();

      // Navigate to search screen
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);

      // Test tap to focus
      await tester.tap(searchField);
      await tester.pumpAndSettle();

      // Test typing
      await tester.enterText(searchField, 'test search');
      await tester.pumpAndSettle();

      // Test field shows entered text
      expect(find.text('test search'), findsOneWidget);
    });

    testWidgets('Search results interaction', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      await tester.pumpAndSettle();

      // Navigate to first lines screen
      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.firstLinesTitle));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Amazing grace');
      await tester.pumpAndSettle();

      // Test tap on search result
      final resultTile = find.text('Amazing grace! How sweet the sound');
      expect(resultTile, findsOneWidget);

      // Test tapping on result (should navigate to hymn detail)
      await tester.tap(resultTile);
      await tester.pumpAndSettle();
      // Navigation would be tested in integration tests
    });

    testWidgets('Filter chips functionality', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SearchScreen()));
      await tester.pumpAndSettle();

      // Test filter chips if they exist
      final filterChips = find.byType(FilterChip);
      if (filterChips.evaluate().isNotEmpty) {
        // Test selecting a filter
        await tester.tap(filterChips.first);
        await tester.pumpAndSettle();

        // Test deselecting a filter
        await tester.tap(filterChips.first);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Search tips functionality', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SearchScreen()));
      await tester.pumpAndSettle();

      // Test search tips if they exist
      final searchTips = find.text('Search Tips');
      if (searchTips.evaluate().isNotEmpty) {
        await tester.tap(searchTips);
        await tester.pumpAndSettle();
      }
    });
  });

  group('Search Edge Cases and Error Handling', () {
    testWidgets('Long search queries', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.tunesTitle));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      const longQuery = 'this is a very long search query that tests the limits of the search functionality and should be handled gracefully without causing any crashes or performance issues in the application';
      
      await tester.enterText(searchField, longQuery);
      await tester.pumpAndSettle();

      // Should handle long queries gracefully
      expect(find.text('No tunes found'), findsOneWidget);
    });

    testWidgets('Search with emoji and unicode', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.metersTitle));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      
      // Test with emoji
      await tester.enterText(searchField, '🎵🎶');
      await tester.pumpAndSettle();
      expect(find.text('No meters found'), findsOneWidget);

      // Test with unicode
      await tester.enterText(searchField, 'àáâãäå');
      await tester.pumpAndSettle();
      expect(find.text('No meters found'), findsOneWidget);
    });

    testWidgets('Concurrent search operations', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.scriptureTitle));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      
      // Simulate rapid search changes
      await tester.enterText(searchField, 'P');
      await tester.enterText(searchField, 'Ps');
      await tester.enterText(searchField, 'Psa');
      await tester.enterText(searchField, 'Psal');
      await tester.enterText(searchField, 'Psalm');
      await tester.pumpAndSettle();

      // Should handle concurrent operations gracefully
      expect(find.text('Psalm 23'), findsOneWidget);
    });

    testWidgets('Search field state management', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      await tester.pumpAndSettle();

      // Test search state across navigation
      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.tunesTitle));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'AMAZING');
      await tester.pumpAndSettle();

      // Navigate away and back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.tunesTitle));
      await tester.pumpAndSettle();

      // Check if state is maintained or reset appropriately
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}