import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:advent_hymnals_mobile/main.dart';
import 'package:advent_hymnals_mobile/core/constants/app_constants.dart';

void main() {
  group('Navigation Tests', () {
    testWidgets('Bottom navigation functionality', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      await tester.pumpAndSettle();

      // Test initial state - should start on Home
      expect(find.text('Welcome to Advent Hymnals'), findsOneWidget);
      
      // Test Browse navigation
      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();
      expect(find.text('Explore Hymns'), findsOneWidget);
      expect(find.text('Browse hymns by different categories'), findsOneWidget);

      // Test Search navigation
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      expect(find.text('Search Hymns'), findsOneWidget);

      // Test Favorites navigation
      await tester.tap(find.text('Favorites'));
      await tester.pumpAndSettle();
      expect(find.text('Your Favorites'), findsOneWidget);

      // Test More navigation
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      expect(find.text('More Options'), findsOneWidget);

      // Test back to Home
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.text('Welcome to Advent Hymnals'), findsOneWidget);
    });

    testWidgets('Browse hub navigation to all categories', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      await tester.pumpAndSettle();

      // Navigate to Browse
      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();

      // Test Collections navigation
      await tester.tap(find.text(AppStrings.collectionsTitle));
      await tester.pumpAndSettle();
      expect(find.text('Browse Collections'), findsOneWidget);
      
      // Test back navigation
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('Explore Hymns'), findsOneWidget);

      // Test Authors navigation
      await tester.tap(find.text(AppStrings.authorsTitle));
      await tester.pumpAndSettle();
      expect(find.text('Browse Authors'), findsOneWidget);
      
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Test Topics navigation
      await tester.tap(find.text(AppStrings.topicsTitle));
      await tester.pumpAndSettle();
      expect(find.text('Browse Topics'), findsOneWidget);
      
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Test Tunes navigation
      await tester.tap(find.text(AppStrings.tunesTitle));
      await tester.pumpAndSettle();
      expect(find.text('Search Tunes'), findsOneWidget);
      
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Test Meters navigation
      await tester.tap(find.text(AppStrings.metersTitle));
      await tester.pumpAndSettle();
      expect(find.text('Search Meters'), findsOneWidget);
      
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Test Scripture navigation
      await tester.tap(find.text(AppStrings.scriptureTitle));
      await tester.pumpAndSettle();
      expect(find.text('Search Scripture References'), findsOneWidget);
      
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Test First Lines navigation
      await tester.tap(find.text(AppStrings.firstLinesTitle));
      await tester.pumpAndSettle();
      expect(find.text('Search First Lines'), findsOneWidget);
      
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should be back at browse hub
      expect(find.text('Explore Hymns'), findsOneWidget);
    });

    testWidgets('Deep navigation and back button behavior', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      await tester.pumpAndSettle();

      // Navigate deep into app
      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text(AppStrings.tunesTitle));
      await tester.pumpAndSettle();

      // Test search within browse screen
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'AMAZING');
      await tester.pumpAndSettle();
      
      // Test back button from search results
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('Explore Hymns'), findsOneWidget);

      // Test bottom nav from any screen
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.text('Welcome to Advent Hymnals'), findsOneWidget);
    });

    testWidgets('Navigation state preservation', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      await tester.pumpAndSettle();

      // Go to search and enter text
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'test search');
      await tester.pumpAndSettle();

      // Navigate to another tab
      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();

      // Navigate back to search
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      // Check if search text is preserved (depends on implementation)
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Error handling in navigation', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      await tester.pumpAndSettle();

      // Test rapid navigation taps
      await tester.tap(find.text('Browse'));
      await tester.tap(find.text('Search'));
      await tester.tap(find.text('Favorites'));
      await tester.tap(find.text('More'));
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      // Should handle gracefully and end up on last tapped tab
      expect(find.text('Welcome to Advent Hymnals'), findsOneWidget);
    });

    testWidgets('Browse grid interaction', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      await tester.pumpAndSettle();

      // Navigate to Browse
      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();

      // Test grid layout
      expect(find.byType(GridView), findsOneWidget);
      expect(find.byType(Card), findsWidgets);

      // Test all browse cards are present
      expect(find.text(AppStrings.collectionsTitle), findsOneWidget);
      expect(find.text(AppStrings.authorsTitle), findsOneWidget);
      expect(find.text(AppStrings.topicsTitle), findsOneWidget);
      expect(find.text(AppStrings.tunesTitle), findsOneWidget);
      expect(find.text(AppStrings.metersTitle), findsOneWidget);
      expect(find.text(AppStrings.scriptureTitle), findsOneWidget);
      expect(find.text(AppStrings.firstLinesTitle), findsOneWidget);

      // Test card tap feedback
      await tester.tap(find.text(AppStrings.collectionsTitle));
      await tester.pumpAndSettle();
      expect(find.text('Browse Collections'), findsOneWidget);
    });

    testWidgets('Quick stats display', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      await tester.pumpAndSettle();

      // Navigate to Browse
      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();

      // Test quick stats section
      expect(find.text('Quick Stats'), findsOneWidget);
      expect(find.text('2,500+'), findsOneWidget);
      expect(find.text('Total Hymns'), findsOneWidget);
      expect(find.text('400+'), findsOneWidget);
      expect(find.text('Authors'), findsOneWidget);
      expect(find.text('50+'), findsOneWidget);
      expect(find.text('Topics'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
      expect(find.text('Collections'), findsOneWidget);
      expect(find.text('300+'), findsOneWidget);
      expect(find.text('Tunes'), findsOneWidget);
      expect(find.text('100+'), findsOneWidget);
      expect(find.text('Meters'), findsOneWidget);
    });
  });

  group('Navigation Edge Cases', () {
    testWidgets('Multiple rapid taps', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      await tester.pumpAndSettle();

      // Rapid tap same tab
      await tester.tap(find.text('Browse'));
      await tester.tap(find.text('Browse'));
      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();

      // Should handle gracefully
      expect(find.text('Explore Hymns'), findsOneWidget);
    });

    testWidgets('Navigation during loading', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Navigate before pump and settle
      await tester.tap(find.text('Browse'));
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      // Should end up on last navigation
      expect(find.text('Search Hymns'), findsOneWidget);
    });

    testWidgets('Back button on home screen', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      await tester.pumpAndSettle();

      // Should be on home screen
      expect(find.text('Welcome to Advent Hymnals'), findsOneWidget);
      
      // Back button should not exist on home screen in bottom nav
      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets('Bottom navigation visibility', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      await tester.pumpAndSettle();

      // Bottom navigation should be visible on all main screens
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Browse'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);

      // Test on browse screen
      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Browse'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
    });
  });
}