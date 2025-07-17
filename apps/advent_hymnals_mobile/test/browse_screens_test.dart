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

void main() {
  group('Browse Screens Tests', () {
    testWidgets('Tunes Browse Screen functionality', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TunesBrowseScreen()));
      await tester.pumpAndSettle();

      // Check if screen loads correctly
      expect(find.text('Tunes'), findsOneWidget);
      expect(find.text('Search Tunes'), findsOneWidget);
      expect(find.text('Find hymns by tune name or meter'), findsOneWidget);

      // Test search functionality
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      // Test search input
      await tester.enterText(searchField, 'AMAZING');
      await tester.pumpAndSettle();

      // Should show filtered results
      expect(find.text('AMAZING GRACE'), findsOneWidget);

      // Test clear search
      final clearButton = find.byIcon(Icons.clear);
      await tester.tap(clearButton);
      await tester.pumpAndSettle();

      // Should show all results again
      expect(find.text('AUSTRIA'), findsOneWidget);
      expect(find.text('BEECHER'), findsOneWidget);

      // Test case insensitive search
      await tester.enterText(searchField, 'duke');
      await tester.pumpAndSettle();
      expect(find.text('DUKE STREET'), findsOneWidget);

      // Test meter search
      await tester.enterText(searchField, 'CM');
      await tester.pumpAndSettle();
      expect(find.text('AMAZING GRACE'), findsOneWidget);
      expect(find.text('CORONATION'), findsOneWidget);

      // Test no results
      await tester.enterText(searchField, 'nonexistent');
      await tester.pumpAndSettle();
      expect(find.text('No tunes found'), findsOneWidget);
      expect(find.text('Try adjusting your search terms'), findsOneWidget);

      // Test tune item tap (should not crash)
      await tester.enterText(searchField, 'AMAZING');
      await tester.pumpAndSettle();
      await tester.tap(find.text('AMAZING GRACE'));
      await tester.pumpAndSettle();
    });

    testWidgets('Meters Browse Screen functionality', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MetersBrowseScreen()));
      await tester.pumpAndSettle();

      // Check if screen loads correctly
      expect(find.text('Meters'), findsOneWidget);
      expect(find.text('Search Meters'), findsOneWidget);
      expect(find.text('Find hymns by meter pattern'), findsOneWidget);

      // Test search functionality
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      // Test search by meter name
      await tester.enterText(searchField, 'CM');
      await tester.pumpAndSettle();
      // CM should appear in results (ignoring the one in search field)
      expect(find.text('CM'), findsWidgets);
      expect(find.text('Common Meter'), findsOneWidget);

      // Test search by full name
      await tester.enterText(searchField, 'Long');
      await tester.pumpAndSettle();
      expect(find.text('LM'), findsWidgets);
      expect(find.text('Long Meter'), findsOneWidget);

      // Test search by pattern
      await tester.enterText(searchField, '8.6.8.6');
      await tester.pumpAndSettle();
      expect(find.text('CM'), findsWidgets);

      // Test clear search
      final clearButton = find.byIcon(Icons.clear);
      await tester.tap(clearButton);
      await tester.pumpAndSettle();
      expect(find.text('87.87 D'), findsWidgets);

      // Test no results
      await tester.enterText(searchField, 'xyz123');
      await tester.pumpAndSettle();
      expect(find.text('No meters found'), findsOneWidget);
    });

    testWidgets('Scripture Browse Screen functionality', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ScriptureBrowseScreen()));
      await tester.pumpAndSettle();

      // Check if screen loads correctly
      expect(find.text('Scripture'), findsOneWidget);
      expect(find.text('Search Scripture References'), findsOneWidget);
      expect(find.text('Find hymns by biblical reference'), findsOneWidget);

      // Test search functionality
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      // Test search by book
      await tester.enterText(searchField, 'Psalm');
      await tester.pumpAndSettle();
      expect(find.text('Psalm 23'), findsOneWidget);
      expect(find.text('Psalm 46:1'), findsOneWidget);

      // Test search by specific reference
      await tester.enterText(searchField, 'John 3:16');
      await tester.pumpAndSettle();
      expect(find.text('John 3:16'), findsWidgets);

      // Test clear search
      final clearButton = find.byIcon(Icons.clear);
      await tester.tap(clearButton);
      await tester.pumpAndSettle();
      expect(find.text('Isaiah 40:31'), findsWidgets);

      // Test no results
      await tester.enterText(searchField, 'nonexistent');
      await tester.pumpAndSettle();
      expect(find.text('No scripture references found'), findsOneWidget);
    });

    testWidgets('First Lines Browse Screen functionality', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: FirstLinesBrowseScreen()));
      await tester.pumpAndSettle();

      // Check if screen loads correctly
      expect(find.text('First Lines'), findsOneWidget);
      expect(find.text('Search First Lines'), findsOneWidget);
      expect(find.text('Find hymns by first line or author'), findsOneWidget);

      // Test search functionality
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      // Test search by first line
      await tester.enterText(searchField, 'Amazing grace');
      await tester.pumpAndSettle();
      expect(find.text('Amazing grace! How sweet the sound'), findsOneWidget);

      // Test search by author
      await tester.enterText(searchField, 'Charles Wesley');
      await tester.pumpAndSettle();
      expect(find.text('Christ the Lord is risen today'), findsOneWidget);
      expect(find.text('Come, thou almighty King'), findsOneWidget);

      // Test clear search
      final clearButton = find.byIcon(Icons.clear);
      await tester.tap(clearButton);
      await tester.pumpAndSettle();
      expect(find.text('A mighty fortress is our God'), findsOneWidget);

      // Test hymn number navigation
      await tester.enterText(searchField, 'Amazing grace');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Amazing grace! How sweet the sound'));
      await tester.pumpAndSettle();
      // This would navigate to hymn detail (tested in integration)
    });

    testWidgets('Authors Browse Screen functionality', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AuthorsBrowseScreen()));
      await tester.pumpAndSettle();

      // Check if screen loads correctly
      expect(find.text('Authors'), findsOneWidget);

      // Test search functionality if available
      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField, 'Wesley');
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Topics Browse Screen functionality', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TopicsBrowseScreen()));
      await tester.pumpAndSettle();

      // Check if screen loads correctly
      expect(find.text('Topics'), findsOneWidget);

      // Test search functionality if available
      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField, 'Christmas');
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Collections Browse Screen functionality', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CollectionsBrowseScreen()));
      await tester.pumpAndSettle();

      // Check if screen loads correctly
      expect(find.text('Collections'), findsOneWidget);

      // Test search functionality if available
      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField, 'Hymnal');
        await tester.pumpAndSettle();
      }
    });
  });

  group('Browse Screen Edge Cases', () {
    testWidgets('Empty search handling', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TunesBrowseScreen()));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      
      // Test empty search - should show all tunes
      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();
      // Check if we get empty state or list view
      var emptyState = find.text('No tunes found');
      var listView = find.byType(ListView);
      // Either should show empty state or list view
      expect(emptyState.evaluate().isNotEmpty || listView.evaluate().isNotEmpty, true);

      // Test whitespace search - should show all tunes
      await tester.enterText(searchField, '   ');
      await tester.pumpAndSettle();
      // Check if we get empty state or list view
      emptyState = find.text('No tunes found');
      listView = find.byType(ListView);
      // Either should show empty state or list view
      expect(emptyState.evaluate().isNotEmpty || listView.evaluate().isNotEmpty, true);
    });

    testWidgets('Special characters in search', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MetersBrowseScreen()));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      
      // Test special characters
      await tester.enterText(searchField, '!@#\$%^&*()');
      await tester.pumpAndSettle();
      expect(find.text('No meters found'), findsOneWidget);

      // Test numbers in search
      await tester.enterText(searchField, '8.6.8.6');
      await tester.pumpAndSettle();
      expect(find.text('CM'), findsOneWidget);
    });

    testWidgets('Long search queries', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ScriptureBrowseScreen()));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      
      // Test very long search query
      await tester.enterText(searchField, 'this is a very long search query that should be handled gracefully');
      await tester.pumpAndSettle();
      expect(find.text('No scripture references found'), findsOneWidget);
    });

    testWidgets('Search field behavior', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: FirstLinesBrowseScreen()));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      
      // Test search field focus
      await tester.tap(searchField);
      await tester.pumpAndSettle();

      // Test text input
      await tester.enterText(searchField, 'Amazing');
      await tester.pumpAndSettle();
      expect(find.text('Amazing grace! How sweet the sound'), findsOneWidget);

      // Test search field clear
      final clearButton = find.byIcon(Icons.clear);
      await tester.tap(clearButton);
      await tester.pumpAndSettle();
      
      // Verify field is cleared
      expect(find.text('A mighty fortress is our God'), findsOneWidget);
    });
  });
}