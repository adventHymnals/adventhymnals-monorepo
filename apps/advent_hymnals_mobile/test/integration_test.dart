import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:advent_hymnals/main.dart';
import 'package:advent_hymnals/core/constants/app_constants.dart';

// Helper function to safely navigate back
Future<void> _safeNavigateBack(WidgetTester tester) async {
  await _safeNavigateBack(tester);
}

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
      
      // Use custom pumping instead of pumpAndSettle
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Navigate to browse
      await tester.tap(find.text('Browse').last);
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Test all browse categories
      await _testBrowseCategories(tester);
    });

    testWidgets('Search functionality across screens', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Use custom pumping instead of pumpAndSettle
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Test main search screen
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      await _testMainSearchScreen(tester);

      // Test browse screen searches
      await _testBrowseScreenSearches(tester);
    });

    testWidgets('Error handling and edge cases', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Use custom pumping instead of pumpAndSettle
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      await _testErrorHandling(tester);
    });
  });
}

Future<void> _testBottomNavigation(WidgetTester tester) async {
  // Test Home tab - use bottom nav
  await tester.tap(find.text('Home').last);
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(find.text('Welcome to'), findsOneWidget);

  // Test Browse tab - use bottom nav
  await tester.tap(find.text('Browse').last);
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(find.text('Explore Hymns'), findsOneWidget);

  // Test Search tab - use bottom nav
  await tester.tap(find.text('Search').last);
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(find.text('Search Suggestions'), findsOneWidget);

  // Test Favorites tab - use bottom nav
  await tester.tap(find.text('Favorites').last);
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(find.text('Favorites'), findsWidgets);

  // Test More tab - use bottom nav
  await tester.tap(find.text('More').last);
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(find.text('More'), findsWidgets);
}

Future<void> _testBrowseFunctionality(WidgetTester tester) async {
  // Go to browse screen
  await tester.tap(find.text('Browse'));
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }

  // Test Collections category
  await tester.tap(find.text(AppStrings.collectionsTitle).first);
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(find.text('Collections'), findsWidgets);
  
  // Go back to browse hub
  await _safeNavigateBack(tester);
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }

  // Test Authors category
  await tester.tap(find.text(AppStrings.authorsTitle).first);
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(find.text('Authors'), findsWidgets);
  
  // Go back to browse hub
  await _safeNavigateBack(tester);
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }

  // Test Topics category - ensure visible before tapping
  await tester.ensureVisible(find.text(AppStrings.topicsTitle).first);
  await tester.tap(find.text(AppStrings.topicsTitle).first);
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(find.text('Topics'), findsWidgets);
  
  // Go back to browse hub - check if back button exists
  final backButton = find.byIcon(Icons.arrow_back);
  if (backButton.evaluate().isNotEmpty) {
    await tester.tap(backButton);
  } else {
    // Alternative: use bottom navigation to go back to browse
    await tester.tap(find.text('Browse').last);
  }
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _testSearchFunctionality(WidgetTester tester) async {
  // Go to search screen
  await tester.tap(find.text('Search'));
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }

  // Find search field
  final searchField = find.byType(TextField);
  expect(searchField, findsOneWidget);

  // Test search input
  await tester.enterText(searchField, 'Amazing Grace');
  for (int i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }

  // Test search button
  final searchButton = find.byIcon(Icons.search);
  if (searchButton.evaluate().isNotEmpty) {
    await tester.tap(searchButton.first);
    for (int i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  // Test clear search
  await tester.enterText(searchField, 'Test search');
  for (int i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  
  final clearButton = find.byIcon(Icons.clear);
  if (clearButton.evaluate().isNotEmpty) {
    await tester.tap(clearButton);
    for (int i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }
}

Future<void> _testFavoritesFunctionality(WidgetTester tester) async {
  // Go to favorites screen
  await tester.tap(find.text('Favorites'));
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }

  // Check for empty state or favorites
  expect(find.text('Favorites'), findsWidgets);
  
  // Test search within favorites if available
  final searchField = find.byType(TextField);
  if (searchField.evaluate().isNotEmpty) {
    await tester.enterText(searchField, 'test');
    for (int i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }
}

Future<void> _testBrowseCategories(WidgetTester tester) async {
  // Test Tunes category
  await tester.tap(find.text(AppStrings.tunesTitle).first);
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(find.text('Search Tunes'), findsOneWidget);
  
  // Test search in tunes
  final tunesSearchField = find.byType(TextField);
  await tester.enterText(tunesSearchField, 'AMAZING');
  for (int i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  
  // Clear search
  final clearButton = find.byIcon(Icons.clear);
  if (clearButton.evaluate().isNotEmpty) {
    await tester.tap(clearButton);
    for (int i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }
  
  // Go back
  await _safeNavigateBack(tester);
  for (int i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }

  // Test Meters category - ensure visible before tapping
  await tester.ensureVisible(find.text(AppStrings.metersTitle).first);
  await tester.tap(find.text(AppStrings.metersTitle).first);
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(find.text('Search Meters'), findsOneWidget);
  
  // Test search in meters
  final metersSearchField = find.byType(TextField);
  await tester.enterText(metersSearchField, 'CM');
  for (int i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  
  // Go back
  await _safeNavigateBack(tester);
  for (int i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }

  // Test Scripture category - ensure visible before tapping
  await tester.ensureVisible(find.text(AppStrings.scriptureTitle).first);
  await tester.tap(find.text(AppStrings.scriptureTitle).first);
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(find.text('Search Scripture References'), findsOneWidget);
  
  // Test search in scripture
  final scriptureSearchField = find.byType(TextField);
  await tester.enterText(scriptureSearchField, 'Psalm');
  for (int i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  
  // Go back
  await _safeNavigateBack(tester);
  for (int i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }

  // Test First Lines category - ensure visible before tapping
  await tester.ensureVisible(find.text(AppStrings.firstLinesTitle).first);
  await tester.tap(find.text(AppStrings.firstLinesTitle).first);
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(find.text('Search First Lines'), findsOneWidget);
  
  // Test search in first lines
  final firstLinesSearchField = find.byType(TextField);
  await tester.enterText(firstLinesSearchField, 'Amazing grace');
  for (int i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  
  // Go back
  await _safeNavigateBack(tester);
  for (int i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _testMainSearchScreen(WidgetTester tester) async {
  // Test basic search functionality
  final searchField = find.byType(TextField);
  await tester.enterText(searchField, 'grace');
  for (int i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }

  // Test filter chips if available
  final filterChips = find.byType(FilterChip);
  if (filterChips.evaluate().isNotEmpty) {
    await tester.tap(filterChips.first);
    for (int i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  // Test search tips expansion
  final searchTips = find.text('Search Tips');
  if (searchTips.evaluate().isNotEmpty) {
    await tester.tap(searchTips);
    for (int i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }
}

Future<void> _testBrowseScreenSearches(WidgetTester tester) async {
  // Navigate to browse - use bottom nav
  await tester.tap(find.text('Browse').last);
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }

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
    // Navigate to category - use first match
    await tester.tap(find.text(browseCategories[i]).first);
    for (int j = 0; j < 5; j++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Find and test search field
    final searchField = find.byType(TextField);
    if (searchField.evaluate().isNotEmpty) {
      await tester.enterText(searchField, searchQueries[i]);
      for (int j = 0; j < 3; j++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Test clear functionality
      final clearButton = find.byIcon(Icons.clear);
      if (clearButton.evaluate().isNotEmpty) {
        await tester.tap(clearButton);
        for (int j = 0; j < 3; j++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
      }
    }

    // Go back to browse hub
    await _safeNavigateBack(tester);
    for (int j = 0; j < 3; j++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }
}

Future<void> _testErrorHandling(WidgetTester tester) async {
  // Test navigation to non-existent routes (should be handled gracefully)
  // This is more of a unit test but we can test UI responses
  
  // Test empty search results - use bottom nav
  await tester.tap(find.text('Search').last);
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  
  final searchField = find.byType(TextField);
  await tester.enterText(searchField, 'xyznonexistentquery123');
  for (int i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  
  // Test various edge cases in browse screens - use bottom nav
  await tester.tap(find.text('Browse').last);
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  
  // Test search with special characters - ensure visible before tapping
  await tester.ensureVisible(find.text(AppStrings.tunesTitle).first);
  await tester.tap(find.text(AppStrings.tunesTitle).first);
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  
  final tunesSearchField = find.byType(TextField);
  await tester.enterText(tunesSearchField, '!@#\$%^&*()');
  for (int i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  
  // Should handle gracefully without crashing
  expect(find.byType(TextField), findsOneWidget);
}