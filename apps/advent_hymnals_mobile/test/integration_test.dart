import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:advent_hymnals_mobile/main.dart';
import 'package:advent_hymnals_mobile/core/constants/app_constants.dart';

void main() {
  group('App Integration Tests', () {
    testWidgets('Complete app navigation flow', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Allow async operations to complete
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Verify app starts on home screen
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Home'), findsAtLeastNWidgets(1));

      // Test bottom navigation
      await _testBottomNavigation(tester);

      // Test browse functionality
      await _testBrowseFunctionality(tester);

      // Test search functionality
      await _testSearchFunctionality(tester);

      // Test favorites functionality
      await _testFavoritesFunctionality(tester);
    });

    testWidgets('Browse screens navigation and search', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      await tester.pumpAndSettle();

      // Navigate to browse
      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();

      // Test all browse categories
      await _testBrowseCategories(tester);
    });

    testWidgets('Search functionality across screens', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      await tester.pumpAndSettle();

      // Test main search screen
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      await _testMainSearchScreen(tester);

      // Test browse screen searches
      await _testBrowseScreenSearches(tester);
    });

    testWidgets('Error handling and edge cases', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      await tester.pumpAndSettle();

      await _testErrorHandling(tester);
    });
  });
}

Future<void> _testBottomNavigation(WidgetTester tester) async {
  // Test Home tab
  await tester.tap(find.text('Home').first);
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(find.text('Welcome to Advent Hymnals'), findsOneWidget);

  // Test Browse tab
  await tester.tap(find.text('Browse').first);
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(find.text('Explore Hymns'), findsOneWidget);

  // Test Search tab
  await tester.tap(find.text('Search').first);
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(find.text('Search Hymns'), findsOneWidget);

  // Test Favorites tab
  await tester.tap(find.text('Favorites').first);
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(find.text('Your Favorites'), findsOneWidget);

  // Test More tab
  await tester.tap(find.text('More').first);
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(find.text('More Options'), findsOneWidget);
}

Future<void> _testBrowseFunctionality(WidgetTester tester) async {
  // Go to browse screen
  await tester.tap(find.text('Browse'));
  await tester.pumpAndSettle();

  // Test Collections category
  await tester.tap(find.text(AppStrings.collectionsTitle));
  await tester.pumpAndSettle();
  expect(find.text('Browse Collections'), findsOneWidget);
  
  // Go back to browse hub
  await tester.tap(find.byIcon(Icons.arrow_back));
  await tester.pumpAndSettle();

  // Test Authors category
  await tester.tap(find.text(AppStrings.authorsTitle));
  await tester.pumpAndSettle();
  expect(find.text('Browse Authors'), findsOneWidget);
  
  // Go back to browse hub
  await tester.tap(find.byIcon(Icons.arrow_back));
  await tester.pumpAndSettle();

  // Test Topics category
  await tester.tap(find.text(AppStrings.topicsTitle));
  await tester.pumpAndSettle();
  expect(find.text('Browse Topics'), findsOneWidget);
  
  // Go back to browse hub
  await tester.tap(find.byIcon(Icons.arrow_back));
  await tester.pumpAndSettle();
}

Future<void> _testSearchFunctionality(WidgetTester tester) async {
  // Go to search screen
  await tester.tap(find.text('Search'));
  await tester.pumpAndSettle();

  // Find search field
  final searchField = find.byType(TextField);
  expect(searchField, findsOneWidget);

  // Test search input
  await tester.enterText(searchField, 'Amazing Grace');
  await tester.pumpAndSettle();

  // Test search button
  final searchButton = find.byIcon(Icons.search);
  if (searchButton.evaluate().isNotEmpty) {
    await tester.tap(searchButton);
    await tester.pumpAndSettle();
  }

  // Test clear search
  await tester.enterText(searchField, 'Test search');
  await tester.pumpAndSettle();
  
  final clearButton = find.byIcon(Icons.clear);
  if (clearButton.evaluate().isNotEmpty) {
    await tester.tap(clearButton);
    await tester.pumpAndSettle();
  }
}

Future<void> _testFavoritesFunctionality(WidgetTester tester) async {
  // Go to favorites screen
  await tester.tap(find.text('Favorites'));
  await tester.pumpAndSettle();

  // Check for empty state or favorites
  expect(find.text('Your Favorites'), findsOneWidget);
  
  // Test search within favorites if available
  final searchField = find.byType(TextField);
  if (searchField.evaluate().isNotEmpty) {
    await tester.enterText(searchField, 'test');
    await tester.pumpAndSettle();
  }
}

Future<void> _testBrowseCategories(WidgetTester tester) async {
  // Test Tunes category
  await tester.tap(find.text(AppStrings.tunesTitle));
  await tester.pumpAndSettle();
  expect(find.text('Search Tunes'), findsOneWidget);
  
  // Test search in tunes
  final tunesSearchField = find.byType(TextField);
  await tester.enterText(tunesSearchField, 'AMAZING');
  await tester.pumpAndSettle();
  
  // Clear search
  final clearButton = find.byIcon(Icons.clear);
  if (clearButton.evaluate().isNotEmpty) {
    await tester.tap(clearButton);
    await tester.pumpAndSettle();
  }
  
  // Go back
  await tester.tap(find.byIcon(Icons.arrow_back));
  await tester.pumpAndSettle();

  // Test Meters category
  await tester.tap(find.text(AppStrings.metersTitle));
  await tester.pumpAndSettle();
  expect(find.text('Search Meters'), findsOneWidget);
  
  // Test search in meters
  final metersSearchField = find.byType(TextField);
  await tester.enterText(metersSearchField, 'CM');
  await tester.pumpAndSettle();
  
  // Go back
  await tester.tap(find.byIcon(Icons.arrow_back));
  await tester.pumpAndSettle();

  // Test Scripture category
  await tester.tap(find.text(AppStrings.scriptureTitle));
  await tester.pumpAndSettle();
  expect(find.text('Search Scripture References'), findsOneWidget);
  
  // Test search in scripture
  final scriptureSearchField = find.byType(TextField);
  await tester.enterText(scriptureSearchField, 'Psalm');
  await tester.pumpAndSettle();
  
  // Go back
  await tester.tap(find.byIcon(Icons.arrow_back));
  await tester.pumpAndSettle();

  // Test First Lines category
  await tester.tap(find.text(AppStrings.firstLinesTitle));
  await tester.pumpAndSettle();
  expect(find.text('Search First Lines'), findsOneWidget);
  
  // Test search in first lines
  final firstLinesSearchField = find.byType(TextField);
  await tester.enterText(firstLinesSearchField, 'Amazing grace');
  await tester.pumpAndSettle();
  
  // Go back
  await tester.tap(find.byIcon(Icons.arrow_back));
  await tester.pumpAndSettle();
}

Future<void> _testMainSearchScreen(WidgetTester tester) async {
  // Test basic search functionality
  final searchField = find.byType(TextField);
  await tester.enterText(searchField, 'grace');
  await tester.pumpAndSettle();

  // Test filter chips if available
  final filterChips = find.byType(FilterChip);
  if (filterChips.evaluate().isNotEmpty) {
    await tester.tap(filterChips.first);
    await tester.pumpAndSettle();
  }

  // Test search tips expansion
  final searchTips = find.text('Search Tips');
  if (searchTips.evaluate().isNotEmpty) {
    await tester.tap(searchTips);
    await tester.pumpAndSettle();
  }
}

Future<void> _testBrowseScreenSearches(WidgetTester tester) async {
  // Navigate to browse
  await tester.tap(find.text('Browse'));
  await tester.pumpAndSettle();

  // Test search in each browse screen
  final browseCategories = [
    AppStrings.tunesTitle,
    AppStrings.metersTitle,
    AppStrings.scriptureTitle,
    AppStrings.firstLinesTitle,
  ];

  final searchQueries = [
    'AMAZING',
    'CM',
    'Psalm',
    'Amazing grace',
  ];

  for (int i = 0; i < browseCategories.length; i++) {
    // Navigate to category
    await tester.tap(find.text(browseCategories[i]));
    await tester.pumpAndSettle();

    // Find and test search field
    final searchField = find.byType(TextField);
    if (searchField.evaluate().isNotEmpty) {
      await tester.enterText(searchField, searchQueries[i]);
      await tester.pumpAndSettle();

      // Test clear functionality
      final clearButton = find.byIcon(Icons.clear);
      if (clearButton.evaluate().isNotEmpty) {
        await tester.tap(clearButton);
        await tester.pumpAndSettle();
      }
    }

    // Go back to browse hub
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
  }
}

Future<void> _testErrorHandling(WidgetTester tester) async {
  // Test navigation to non-existent routes (should be handled gracefully)
  // This is more of a unit test but we can test UI responses
  
  // Test empty search results
  await tester.tap(find.text('Search'));
  await tester.pumpAndSettle();
  
  final searchField = find.byType(TextField);
  await tester.enterText(searchField, 'xyznonexistentquery123');
  await tester.pumpAndSettle();
  
  // Test various edge cases in browse screens
  await tester.tap(find.text('Browse'));
  await tester.pumpAndSettle();
  
  // Test search with special characters
  await tester.tap(find.text(AppStrings.tunesTitle));
  await tester.pumpAndSettle();
  
  final tunesSearchField = find.byType(TextField);
  await tester.enterText(tunesSearchField, '!@#\$%^&*()');
  await tester.pumpAndSettle();
  
  // Should handle gracefully without crashing
  expect(find.byType(TextField), findsOneWidget);
}