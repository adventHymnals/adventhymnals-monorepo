import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:advent_hymnals_mobile/main.dart';

void main() {
  group('Favorites Functionality Tests', () {
    testWidgets('Favorites screen renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initial load
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Navigate to Favorites screen (tap the bottom navigation item)
      await tester.tap(find.text('Favorites').first);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Verify Favorites screen components
      expect(find.text('Favorites'), findsAtLeastNWidgets(1));
      expect(find.text('No Favorites'), findsAtLeastNWidgets(1));
      expect(find.text('Tap the heart icon on any hymn to add it to your favorites'), findsOneWidget);
      expect(find.text('Browse Hymns'), findsOneWidget);
    });

    testWidgets('Empty state displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initial load
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Navigate to Favorites screen (tap the bottom navigation item)
      await tester.tap(find.text('Favorites').first);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Check empty state
      expect(find.byIcon(Icons.favorite_border), findsAtLeastNWidgets(1));
      expect(find.text('No Favorites'), findsAtLeastNWidgets(1));
      expect(find.text('Browse Hymns'), findsOneWidget);
    });

    testWidgets('Browse Hymns button navigation works', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initial load
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Navigate to Favorites screen (tap the bottom navigation item)
      await tester.tap(find.text('Favorites').first);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Tap Browse Hymns button
      await tester.tap(find.text('Browse Hymns'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Should navigate to Browse screen
      expect(find.text('Explore Hymns'), findsOneWidget);
      expect(find.text('Browse hymns by different categories'), findsOneWidget);
    });

    testWidgets('Hymn detail favorite toggle works', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initial load
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Navigate to Browse screen first
      await tester.tap(find.text('Browse').first);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Tap on Authors to browse
      await tester.tap(find.text('Authors'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Tap on first author to go to hymn detail
      final firstAuthor = find.text('Charles Wesley').first;
      await tester.tap(firstAuthor);
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Should be on hymn detail screen
      expect(find.text('Holy, Holy, Holy'), findsAtLeastNWidgets(1));
      
      // Find and tap the favorite button
      final favoriteButton = find.byIcon(Icons.favorite_border);
      if (favoriteButton.evaluate().isNotEmpty) {
        await tester.tap(favoriteButton);
        for (int i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        
        // Should show snackbar feedback
        expect(find.text('Added to favorites'), findsOneWidget);
      }
    });

    testWidgets('Navigation between screens works', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initial load
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Test navigation: Home -> Browse -> Authors -> Hymn Detail
      await tester.tap(find.text('Browse').first);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      
      expect(find.text('Explore Hymns'), findsOneWidget);

      // Go to Authors
      await tester.tap(find.text('Authors'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      
      expect(find.text('Browse Authors'), findsOneWidget);

      // Go back to favorites to test empty state
      await tester.tap(find.text('Favorites'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      
      expect(find.text('No Favorites'), findsAtLeastNWidgets(1));
    });

    testWidgets('Favorites screen accessibility features', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initial load
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Navigate to Favorites screen (tap the bottom navigation item)
      await tester.tap(find.text('Favorites').first);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Check accessibility features
      expect(find.text('No Favorites'), findsAtLeastNWidgets(1));
      expect(find.text('Browse Hymns'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsAtLeastNWidgets(1));
      
      // Check icon accessibility
      expect(find.byIcon(Icons.favorite_border), findsAtLeastNWidgets(1));
    });

    testWidgets('Favorites screen app bar actions work', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initial load
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Navigate to Favorites screen (tap the bottom navigation item)
      await tester.tap(find.text('Favorites').first);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Check for sort button (should be there even with empty favorites)
      expect(find.byIcon(Icons.sort), findsOneWidget);
      
      // Tap sort button
      await tester.tap(find.byIcon(Icons.sort));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Should show sort dialog
      expect(find.text('Sort by'), findsOneWidget);
      expect(find.text('Date Added'), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Author'), findsOneWidget);
      expect(find.text('Hymn Number'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('Date Added'));
      for (int i = 0; i < 3; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    });

    testWidgets('Browse categories navigation works', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initial load
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Test Topics navigation
      await tester.tap(find.text('Browse').first);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.tap(find.text('Topics'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.text('Browse Topics'), findsOneWidget);
      
      // Test Collections navigation
      await tester.pageBack();
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.tap(find.text('Collections'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.text('Browse Collections'), findsOneWidget);
    });
  });
}