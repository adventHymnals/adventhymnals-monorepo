import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:advent_hymnals/main.dart';
import 'package:advent_hymnals/core/constants/app_constants.dart';

void main() {
  group('End-to-End User Journey Tests', () {
    testWidgets('Complete user journey: Browse → Search → Navigate', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      await tester.pumpAndSettle();

      // Step 1: User starts on home screen
      expect(find.text('Welcome to Advent Hymnals'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);

      // Step 2: User explores browse functionality
      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();
      expect(find.text('Explore Hymns'), findsOneWidget);

      // Step 3: User checks quick stats
      expect(find.text('Quick Stats'), findsOneWidget);
      expect(find.text('2,500+'), findsOneWidget);
      expect(find.text('Total Hymns'), findsOneWidget);

      // Step 4: User browses tunes
      await tester.tap(find.text(AppStrings.tunesTitle));
      await tester.pumpAndSettle();
      expect(find.text('Search Tunes'), findsOneWidget);

      // Step 5: User searches for a specific tune
      final tunesSearchField = find.byType(TextField);
      await tester.enterText(tunesSearchField, 'AMAZING');
      await tester.pumpAndSettle();
      expect(find.text('AMAZING GRACE'), findsOneWidget);

      // Step 6: User clears search to see all tunes
      final clearButton = find.byIcon(Icons.clear);
      await tester.tap(clearButton);
      await tester.pumpAndSettle();
      expect(find.text('AUSTRIA'), findsOneWidget);
      expect(find.text('BEECHER'), findsOneWidget);

      // Step 7: User goes back to browse hub
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('Explore Hymns'), findsOneWidget);

      // Step 8: User tries meters
      await tester.tap(find.text(AppStrings.metersTitle));
      await tester.pumpAndSettle();
      expect(find.text('Search Meters'), findsOneWidget);

      // Step 9: User searches for common meter
      final metersSearchField = find.byType(TextField);
      await tester.enterText(metersSearchField, 'Common');
      await tester.pumpAndSettle();
      expect(find.text('CM'), findsOneWidget);
      expect(find.text('Common Meter'), findsOneWidget);

      // Step 10: User goes back and tries scripture
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.scriptureTitle));
      await tester.pumpAndSettle();
      expect(find.text('Search Scripture References'), findsOneWidget);

      // Step 11: User searches for Psalm
      final scriptureSearchField = find.byType(TextField);
      await tester.enterText(scriptureSearchField, 'Psalm');
      await tester.pumpAndSettle();
      expect(find.text('Psalm 23'), findsOneWidget);

      // Step 12: User goes back and tries first lines
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.firstLinesTitle));
      await tester.pumpAndSettle();
      expect(find.text('Search First Lines'), findsOneWidget);

      // Step 13: User searches for a hymn by first line
      final firstLinesSearchField = find.byType(TextField);
      await tester.enterText(firstLinesSearchField, 'Amazing grace');
      await tester.pumpAndSettle();
      expect(find.text('Amazing grace! How sweet the sound'), findsOneWidget);

      // Step 14: User navigates to main search
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      expect(find.text('Search Hymns'), findsOneWidget);

      // Step 15: User tries main search
      final mainSearchField = find.byType(TextField);
      await tester.enterText(mainSearchField, 'grace');
      await tester.pumpAndSettle();

      // Step 16: User checks favorites
      await tester.tap(find.text('Favorites'));
      await tester.pumpAndSettle();
      expect(find.text('Your Favorites'), findsOneWidget);

      // Step 17: User checks more options
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      expect(find.text('More Options'), findsOneWidget);

      // Step 18: User returns to home
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.text('Welcome to Advent Hymnals'), findsOneWidget);

      // Journey complete!
    });

    testWidgets('Power user search workflow', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      await tester.pumpAndSettle();

      // Power user immediately goes to search
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      // Tests multiple search terms
      final searchField = find.byType(TextField);
      
      // Search 1: Basic hymn search
      await tester.enterText(searchField, 'Amazing Grace');
      await tester.pumpAndSettle();
      
      // Search 2: Author search
      await tester.enterText(searchField, 'Charles Wesley');
      await tester.pumpAndSettle();
      
      // Search 3: Clear and try partial search
      final clearButton = find.byIcon(Icons.clear);
      if (clearButton.evaluate().isNotEmpty) {
        await tester.tap(clearButton);
        await tester.pumpAndSettle();
      }
      
      await tester.enterText(searchField, 'Holy');
      await tester.pumpAndSettle();

      // Power user then goes to specific browse screens
      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();

      // Quick tour of each browse screen
      final browseScreens = [
        AppStrings.collectionsTitle,
        AppStrings.authorsTitle,
        AppStrings.topicsTitle,
        AppStrings.tunesTitle,
        AppStrings.metersTitle,
        AppStrings.scriptureTitle,
        AppStrings.firstLinesTitle,
      ];

      for (final screenTitle in browseScreens) {
        await tester.tap(find.text(screenTitle));
        await tester.pumpAndSettle();
        
        // Quick search test in each screen
        final browseSearchField = find.byType(TextField);
        if (browseSearchField.evaluate().isNotEmpty) {
          await tester.enterText(browseSearchField, 'test');
          await tester.pumpAndSettle();
        }
        
        // Go back to browse hub
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
      }

      // Power user checks favorites
      await tester.tap(find.text('Favorites'));
      await tester.pumpAndSettle();
      
      // Power user workflow complete
    });

    testWidgets('Error recovery user journey', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      await tester.pumpAndSettle();

      // User encounters "errors" (empty searches, no results)
      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.tunesTitle));
      await tester.pumpAndSettle();

      // User searches for something that doesn't exist
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'nonexistentune123');
      await tester.pumpAndSettle();
      expect(find.text('No tunes found'), findsOneWidget);
      expect(find.text('Try adjusting your search terms'), findsOneWidget);

      // User recovers by clearing search
      final clearButton = find.byIcon(Icons.clear);
      await tester.tap(clearButton);
      await tester.pumpAndSettle();
      expect(find.text('AMAZING GRACE'), findsOneWidget);

      // User tries different browse screens with bad searches
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.metersTitle));
      await tester.pumpAndSettle();

      final metersSearchField = find.byType(TextField);
      await tester.enterText(metersSearchField, '!@#\$%^&*()');
      await tester.pumpAndSettle();
      expect(find.text('No meters found'), findsOneWidget);

      // User recovers by going back to browse
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('Explore Hymns'), findsOneWidget);

      // User successfully navigates to home
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.text('Welcome to Advent Hymnals'), findsOneWidget);
    });

    testWidgets('Mobile UX patterns test', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      await tester.pumpAndSettle();

      // Test tap targets are appropriate size
      final bottomNavButtons = find.byType(BottomNavigationBar);
      expect(bottomNavButtons, findsOneWidget);

      // Test card interactions
      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();

      final browseCards = find.byType(Card);
      expect(browseCards, findsWidgets);

      // Test each card is tappable
      await tester.tap(find.text(AppStrings.tunesTitle));
      await tester.pumpAndSettle();
      expect(find.text('Search Tunes'), findsOneWidget);

      // Test search field usability
      final searchField = find.byType(TextField);
      await tester.tap(searchField);
      await tester.pumpAndSettle();

      // Test list scrolling behavior
      await tester.enterText(searchField, 'A');
      await tester.pumpAndSettle();
      
      // Test if list is scrollable
      if (find.byType(ListView).evaluate().isNotEmpty) {
        await tester.drag(find.byType(ListView), const Offset(0, -100));
        await tester.pumpAndSettle();
      }

      // Test back navigation
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('Explore Hymns'), findsOneWidget);

      // Test bottom navigation persistence
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Browse'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('Accessibility and usability test', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      await tester.pumpAndSettle();

      // Test semantic labels and structure
      expect(find.text('Welcome to Advent Hymnals'), findsOneWidget);
      
      // Test navigation semantics
      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();

      // Test button accessibility
      final browseButtons = find.byType(InkWell);
      expect(browseButtons, findsWidgets);

      // Test search field accessibility
      await tester.tap(find.text(AppStrings.tunesTitle));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
      
      // Test that hint text is present
      expect(find.text('Search tunes or meters...'), findsOneWidget);

      // Test clear button accessibility
      await tester.enterText(searchField, 'test');
      await tester.pumpAndSettle();
      
      final clearButton = find.byIcon(Icons.clear);
      expect(clearButton, findsOneWidget);

      // Test navigation back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('Explore Hymns'), findsOneWidget);
    });
  });
}