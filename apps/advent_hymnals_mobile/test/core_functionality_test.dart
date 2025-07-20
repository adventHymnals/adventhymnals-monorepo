import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:advent_hymnals/main.dart';
import 'package:advent_hymnals/presentation/screens/tunes_browse_screen.dart';
import 'package:advent_hymnals/presentation/screens/meters_browse_screen.dart';
import 'package:advent_hymnals/presentation/screens/scripture_browse_screen.dart';
import 'package:advent_hymnals/presentation/screens/first_lines_browse_screen.dart';
import 'package:advent_hymnals/presentation/screens/authors_browse_screen.dart';
import 'package:advent_hymnals/presentation/screens/topics_browse_screen.dart';
import 'package:advent_hymnals/presentation/screens/collections_browse_screen.dart';
import 'package:advent_hymnals/presentation/screens/search_screen.dart';
import 'package:advent_hymnals/presentation/screens/favorites_screen.dart';
import 'package:advent_hymnals/presentation/screens/more_screen.dart';
import 'package:advent_hymnals/core/constants/app_constants.dart';

void main() {
  group('Core Functionality Tests', () {
    testWidgets('App launches without errors', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Allow async operations to complete
      await tester.pump(const Duration(seconds: 1));

      // Verify app launched - should have bottom navigation
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('All 4 new browse screens work correctly', (WidgetTester tester) async {
      // Test Tunes Browse Screen
      await tester.pumpWidget(const MaterialApp(home: TunesBrowseScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Tunes'), findsOneWidget);
      expect(find.text('Search Tunes'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('AMAZING GRACE'), findsOneWidget);

      // Test Meters Browse Screen
      await tester.pumpWidget(const MaterialApp(home: MetersBrowseScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Meters'), findsOneWidget);
      expect(find.text('Search Meters'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('CM'), findsOneWidget);

      // Test Scripture Browse Screen
      await tester.pumpWidget(const MaterialApp(home: ScriptureBrowseScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Scripture'), findsOneWidget);
      expect(find.text('Search Scripture References'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Psalm 23'), findsOneWidget);

      // Test First Lines Browse Screen
      await tester.pumpWidget(const MaterialApp(home: FirstLinesBrowseScreen()));
      await tester.pumpAndSettle();
      expect(find.text('First Lines'), findsOneWidget);
      expect(find.text('Search First Lines'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Amazing grace! How sweet the sound'), findsOneWidget);
    });

    testWidgets('All existing browse screens still work', (WidgetTester tester) async {
      // Test Authors Browse Screen
      await tester.pumpWidget(const MaterialApp(home: AuthorsBrowseScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Browse Authors'), findsOneWidget);

      // Test Topics Browse Screen
      await tester.pumpWidget(const MaterialApp(home: TopicsBrowseScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Browse Topics'), findsOneWidget);

      // Test Collections Browse Screen
      await tester.pumpWidget(const MaterialApp(home: CollectionsBrowseScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Browse Collections'), findsOneWidget);
    });

    testWidgets('Main screens can be rendered', (WidgetTester tester) async {
      // Test Search Screen
      await tester.pumpWidget(const MaterialApp(home: SearchScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Search Hymns'), findsOneWidget);

      // Test Favorites Screen
      await tester.pumpWidget(const MaterialApp(home: FavoritesScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Your Favorites'), findsOneWidget);

      // Test More Screen
      await tester.pumpWidget(const MaterialApp(home: MoreScreen()));
      await tester.pumpAndSettle();
      expect(find.text('More Options'), findsOneWidget);
    });

    testWidgets('Search functionality works in all new browse screens', (WidgetTester tester) async {
      // Test Tunes search
      await tester.pumpWidget(const MaterialApp(home: TunesBrowseScreen()));
      await tester.pumpAndSettle();
      
      final tunesSearchField = find.byType(TextField);
      await tester.enterText(tunesSearchField, 'AMAZING');
      await tester.pumpAndSettle();
      // Should filter to show only AMAZING GRACE
      expect(find.text('AMAZING GRACE'), findsOneWidget);
      expect(find.text('AUSTRIA'), findsNothing);

      // Test Meters search
      await tester.pumpWidget(const MaterialApp(home: MetersBrowseScreen()));
      await tester.pumpAndSettle();
      
      final metersSearchField = find.byType(TextField);
      await tester.enterText(metersSearchField, 'Common');
      await tester.pumpAndSettle();
      // Should filter to show Common Meter
      expect(find.text('Common Meter'), findsOneWidget);

      // Test Scripture search
      await tester.pumpWidget(const MaterialApp(home: ScriptureBrowseScreen()));
      await tester.pumpAndSettle();
      
      final scriptureSearchField = find.byType(TextField);
      await tester.enterText(scriptureSearchField, 'Psalm');
      await tester.pumpAndSettle();
      // Should filter to show Psalm references
      expect(find.text('Psalm 23'), findsOneWidget);

      // Test First Lines search
      await tester.pumpWidget(const MaterialApp(home: FirstLinesBrowseScreen()));
      await tester.pumpAndSettle();
      
      final firstLinesSearchField = find.byType(TextField);
      await tester.enterText(firstLinesSearchField, 'Amazing');
      await tester.pumpAndSettle();
      // Should filter to show Amazing Grace
      expect(find.text('Amazing grace! How sweet the sound'), findsOneWidget);
    });

    testWidgets('Clear search functionality works', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TunesBrowseScreen()));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      
      // Enter search text
      await tester.enterText(searchField, 'AMAZING');
      await tester.pumpAndSettle();
      
      // Clear button should appear
      expect(find.byIcon(Icons.clear), findsOneWidget);
      
      // Test clear functionality
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();
      
      // Should show all results again
      expect(find.text('AUSTRIA'), findsOneWidget);
      expect(find.text('BEECHER'), findsOneWidget);
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

    testWidgets('Case insensitive search works', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TunesBrowseScreen()));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      
      // Test lowercase search
      await tester.enterText(searchField, 'amazing');
      await tester.pumpAndSettle();
      
      // Should still find AMAZING GRACE
      expect(find.text('AMAZING GRACE'), findsOneWidget);
    });

    testWidgets('All browse screens have required UI elements', (WidgetTester tester) async {
      final screens = [
        const TunesBrowseScreen(),
        const MetersBrowseScreen(),
        const ScriptureBrowseScreen(),
        const FirstLinesBrowseScreen(),
      ];

      for (final screen in screens) {
        await tester.pumpWidget(MaterialApp(home: screen));
        await tester.pumpAndSettle();
        
        // Each screen should have:
        // - A search field
        // - Cards displaying results
        // - App bar with title
        expect(find.byType(TextField), findsOneWidget);
        expect(find.byType(Card), findsWidgets);
        expect(find.byType(AppBar), findsOneWidget);
      }
    });

    testWidgets('Browse screens handle special characters safely', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TunesBrowseScreen()));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      
      // Test special characters don't crash the app
      await tester.enterText(searchField, '!@#\$%^&*()');
      await tester.pumpAndSettle();
      
      // Should handle gracefully
      expect(find.text('No tunes found'), findsOneWidget);
    });

    testWidgets('Navigation icons and UI elements are present', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TunesBrowseScreen()));
      await tester.pumpAndSettle();

      // Should have back button (arrow_back icon)
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      
      // Should have search icon
      expect(find.byIcon(Icons.search), findsOneWidget);
      
      // Should have cards with proper icons
      expect(find.byIcon(Icons.music_note), findsWidgets);
    });
  });
}