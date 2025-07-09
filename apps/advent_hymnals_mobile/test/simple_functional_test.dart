import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:advent_hymnals_mobile/main.dart';
import 'package:advent_hymnals_mobile/presentation/screens/tunes_browse_screen.dart';
import 'package:advent_hymnals_mobile/presentation/screens/meters_browse_screen.dart';
import 'package:advent_hymnals_mobile/presentation/screens/scripture_browse_screen.dart';
import 'package:advent_hymnals_mobile/presentation/screens/first_lines_browse_screen.dart';
import 'package:advent_hymnals_mobile/core/constants/app_constants.dart';

void main() {
  group('Functional Tests', () {
    testWidgets('App launches and shows navigation', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Allow async operations to complete
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Verify bottom navigation is present
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Home'), findsAtLeastNWidgets(1));
      expect(find.text('Browse'), findsAtLeastNWidgets(1));
      expect(find.text('Search'), findsAtLeastNWidgets(1));
      expect(find.text('Favorites'), findsAtLeastNWidgets(1));
      expect(find.text('More'), findsAtLeastNWidgets(1));
    });

    testWidgets('Navigation between main screens works', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Allow async operations to complete
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Test browse navigation
      await tester.tap(find.text('Browse').first);
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Explore Hymns'), findsOneWidget);

      // Test search navigation
      await tester.tap(find.text('Search').first);
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Search Hymns'), findsOneWidget);

      // Test favorites navigation
      await tester.tap(find.text('Favorites').first);
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Your Favorites'), findsOneWidget);

      // Test more navigation
      await tester.tap(find.text('More').first);
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('More Options'), findsOneWidget);
    });

    testWidgets('Browse screens are accessible', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Allow async operations to complete
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Navigate to browse
      await tester.tap(find.text('Browse').first);
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Test accessing tunes browse screen
      await tester.tap(find.text(AppStrings.tunesTitle));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Search Tunes'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Go back to browse hub
      await tester.tap(find.byIcon(Icons.arrow_back));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Explore Hymns'), findsOneWidget);

      // Test accessing meters browse screen
      await tester.tap(find.text(AppStrings.metersTitle));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Search Meters'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Individual browse screens work correctly', (WidgetTester tester) async {
      // Test Tunes Browse Screen
      await tester.pumpWidget(const MaterialApp(home: TunesBrowseScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Tunes'), findsOneWidget);
      expect(find.text('Search Tunes'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(Card), findsWidgets);

      // Test search functionality
      final tunesSearchField = find.byType(TextField);
      await tester.enterText(tunesSearchField, 'AMAZING');
      await tester.pumpAndSettle();
      // Should show filtered results without causing errors
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('Meters browse screen functions', (WidgetTester tester) async {
      // Test Meters Browse Screen
      await tester.pumpWidget(const MaterialApp(home: MetersBrowseScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Meters'), findsOneWidget);
      expect(find.text('Search Meters'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(Card), findsWidgets);

      // Test search functionality
      final metersSearchField = find.byType(TextField);
      await tester.enterText(metersSearchField, 'CM');
      await tester.pumpAndSettle();
      // Should show filtered results without causing errors
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('Scripture browse screen functions', (WidgetTester tester) async {
      // Test Scripture Browse Screen
      await tester.pumpWidget(const MaterialApp(home: ScriptureBrowseScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Scripture'), findsOneWidget);
      expect(find.text('Search Scripture References'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(Card), findsWidgets);

      // Test search functionality
      final scriptureSearchField = find.byType(TextField);
      await tester.enterText(scriptureSearchField, 'Psalm');
      await tester.pumpAndSettle();
      // Should show filtered results without causing errors
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('First Lines browse screen functions', (WidgetTester tester) async {
      // Test First Lines Browse Screen
      await tester.pumpWidget(const MaterialApp(home: FirstLinesBrowseScreen()));
      await tester.pumpAndSettle();

      expect(find.text('First Lines'), findsOneWidget);
      expect(find.text('Search First Lines'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(Card), findsWidgets);

      // Test search functionality
      final firstLinesSearchField = find.byType(TextField);
      await tester.enterText(firstLinesSearchField, 'Amazing');
      await tester.pumpAndSettle();
      // Should show filtered results without causing errors
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('Search and clear functionality works', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TunesBrowseScreen()));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      
      // Test search input
      await tester.enterText(searchField, 'AMAZING');
      await tester.pumpAndSettle();
      
      // Clear button should appear
      expect(find.byIcon(Icons.clear), findsOneWidget);
      
      // Test clear functionality
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();
      
      // Should show all results again
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('Empty search handling works', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MetersBrowseScreen()));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      
      // Test search with no results
      await tester.enterText(searchField, 'nonexistent123');
      await tester.pumpAndSettle();
      
      // Should show empty state
      expect(find.text('No meters found'), findsOneWidget);
      expect(find.text('Try adjusting your search terms'), findsOneWidget);
    });

    testWidgets('All browse categories are accessible from browse hub', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Allow async operations to complete
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Navigate to browse
      await tester.tap(find.text('Browse').first);
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Verify all browse categories are present
      expect(find.text(AppStrings.collectionsTitle), findsOneWidget);
      expect(find.text(AppStrings.authorsTitle), findsOneWidget);
      expect(find.text(AppStrings.topicsTitle), findsOneWidget);
      expect(find.text(AppStrings.tunesTitle), findsOneWidget);
      expect(find.text(AppStrings.metersTitle), findsOneWidget);
      expect(find.text(AppStrings.scriptureTitle), findsOneWidget);
      expect(find.text(AppStrings.firstLinesTitle), findsOneWidget);
      
      // Verify quick stats are present
      expect(find.text('Quick Stats'), findsOneWidget);
      expect(find.text('Total Hymns'), findsOneWidget);
      expect(find.text('Authors'), findsOneWidget);
      expect(find.text('Topics'), findsOneWidget);
      expect(find.text('Collections'), findsOneWidget);
      expect(find.text('Tunes'), findsOneWidget);
      expect(find.text('Meters'), findsOneWidget);
    });
  });
}