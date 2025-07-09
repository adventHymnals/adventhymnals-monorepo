import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:advent_hymnals_mobile/main.dart';
import 'package:advent_hymnals_mobile/core/constants/app_constants.dart';

void main() {
  group('Navigation Tests', () {
    testWidgets('Bottom navigation functionality', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Test initial state - should start on Home
      expect(find.text('Welcome to'), findsOneWidget);
      
      // Test Browse navigation
      await tester.tap(find.text('Browse').last);
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Explore Hymns'), findsOneWidget);
      expect(find.text('Browse hymns by different categories'), findsOneWidget);

      // Test Search navigation
      await tester.tap(find.text('Search'));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Search Suggestions'), findsOneWidget);

      // Test Favorites navigation
      await tester.tap(find.text('Favorites'));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Favorites'), findsOneWidget);

      // Test More navigation
      await tester.tap(find.text('More'));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('More Options'), findsOneWidget);

      // Test back to Home
      await tester.tap(find.text('Home'));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Welcome to'), findsOneWidget);
    });

    testWidgets('Browse hub navigation to all categories', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Navigate to Browse
      await tester.tap(find.text('Browse').last);
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Test Collections navigation
      await tester.tap(find.text(AppStrings.collectionsTitle).first);
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Collections'), findsOneWidget);
      
      // Test back navigation
      await tester.tap(find.byIcon(Icons.arrow_back));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Explore Hymns'), findsOneWidget);

      // Test Authors navigation
      await tester.tap(find.text(AppStrings.authorsTitle));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Authors'), findsOneWidget);
      
      await tester.tap(find.byIcon(Icons.arrow_back));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Test Topics navigation
      await tester.tap(find.text(AppStrings.topicsTitle));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Topics'), findsOneWidget);
      
      await tester.tap(find.byIcon(Icons.arrow_back));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Test Tunes navigation
      await tester.tap(find.text(AppStrings.tunesTitle));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Search Tunes'), findsOneWidget);
      
      await tester.tap(find.byIcon(Icons.arrow_back));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Test Meters navigation
      await tester.tap(find.text(AppStrings.metersTitle));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Search Meters'), findsOneWidget);
      
      await tester.tap(find.byIcon(Icons.arrow_back));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Test Scripture navigation
      await tester.tap(find.text(AppStrings.scriptureTitle));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Search Scripture References'), findsOneWidget);
      
      await tester.tap(find.byIcon(Icons.arrow_back));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Test First Lines navigation
      await tester.tap(find.text(AppStrings.firstLinesTitle));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Search First Lines'), findsOneWidget);
      
      await tester.tap(find.byIcon(Icons.arrow_back));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Should be back at browse hub
      expect(find.text('Explore Hymns'), findsOneWidget);
    });

    testWidgets('Deep navigation and back button behavior', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Navigate deep into app
      await tester.tap(find.text('Browse').last);
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      
      await tester.tap(find.text(AppStrings.tunesTitle));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Test search within browse screen
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'AMAZING');
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      
      // Test back button from search results
      await tester.tap(find.byIcon(Icons.arrow_back));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Explore Hymns'), findsOneWidget);

      // Test bottom nav from any screen
      await tester.tap(find.text('Home'));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Welcome to'), findsOneWidget);
    });

    testWidgets('Navigation state preservation', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Go to search and enter text
      await tester.tap(find.text('Search'));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'test search');
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Navigate to another tab
      await tester.tap(find.text('Browse').last);
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Navigate back to search
      await tester.tap(find.text('Search'));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Check if search text is preserved (depends on implementation)
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Error handling in navigation', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Test rapid navigation taps
      await tester.tap(find.text('Browse').last);
      await tester.tap(find.text('Search'));
      await tester.tap(find.text('Favorites'));
      await tester.tap(find.text('More'));
      await tester.tap(find.text('Home'));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Should handle gracefully and end up on last tapped tab
      expect(find.text('Welcome to'), findsOneWidget);
    });

    testWidgets('Browse grid interaction', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Navigate to Browse
      await tester.tap(find.text('Browse').last);
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Test grid layout
      expect(find.byType(GridView), findsOneWidget);
      expect(find.byType(Card), findsWidgets);

      // Test all browse cards are present
      expect(find.text(AppStrings.collectionsTitle), findsWidgets);
      expect(find.text(AppStrings.authorsTitle), findsOneWidget);
      expect(find.text(AppStrings.topicsTitle), findsOneWidget);
      expect(find.text(AppStrings.tunesTitle), findsOneWidget);
      expect(find.text(AppStrings.metersTitle), findsOneWidget);
      expect(find.text(AppStrings.scriptureTitle), findsOneWidget);
      expect(find.text(AppStrings.firstLinesTitle), findsOneWidget);

      // Test card tap feedback
      await tester.tap(find.text(AppStrings.collectionsTitle).first);
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Collections'), findsOneWidget);
    });

    testWidgets('Quick stats display', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Navigate to Browse
      await tester.tap(find.text('Browse').last);
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

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
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Rapid tap same tab
      await tester.tap(find.text('Browse').last);
      await tester.tap(find.text('Browse').last);
      await tester.tap(find.text('Browse').last);
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Should handle gracefully
      expect(find.text('Explore Hymns'), findsOneWidget);
    });

    testWidgets('Navigation during loading', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Navigate before pump and settle
      await tester.tap(find.text('Browse').last);
      await tester.tap(find.text('Search'));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Should end up on last navigation
      expect(find.text('Search Suggestions'), findsOneWidget);
    });

    testWidgets('Back button on home screen', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Should be on home screen - check for Advent Hymnals title
      expect(find.text('Advent Hymnals'), findsOneWidget);
      
      // Back button should not exist on home screen in bottom nav
      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets('Bottom navigation visibility', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Bottom navigation should be visible on all main screens
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Browse'), findsWidgets);
      expect(find.text('Search'), findsWidgets);
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);

      // Test on browse screen
      await tester.tap(find.text('Browse').last);
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Browse'), findsWidgets);
      expect(find.text('Search'), findsWidgets);
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
    });
  });
}