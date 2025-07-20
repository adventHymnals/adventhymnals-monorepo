import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:advent_hymnals/main.dart';
import 'package:advent_hymnals/core/constants/app_constants.dart';

void main() {
  group('Comprehensive End-to-End Navigation Tests', () {
    testWidgets('Complete app navigation flow - All features', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      await tester.pumpAndSettle();

      // ==== HOME SCREEN ====
      expect(find.text('Welcome to Advent Hymnals'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      
      // Test quick access buttons on home screen
      final quickAccessButtons = find.byType(ElevatedButton);
      expect(quickAccessButtons, findsWidgets);

      // ==== BROWSE SECTION ====
      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();
      expect(find.text('Explore Hymns'), findsOneWidget);
      
      // Test all browse categories
      final browseCategories = [
        AppStrings.collectionsTitle,
        AppStrings.authorsTitle,
        AppStrings.topicsTitle,
        AppStrings.tunesTitle,
        AppStrings.metersTitle,
        AppStrings.scriptureTitle,
        AppStrings.firstLinesTitle,
      ];

      for (final category in browseCategories) {
        // Navigate to category
        await tester.tap(find.text(category).first);
        await tester.pumpAndSettle();
        
        // Test search functionality in each category
        final searchField = find.byType(TextField);
        if (searchField.evaluate().isNotEmpty) {
          await tester.enterText(searchField, 'test');
          await tester.pumpAndSettle();
          
          // Test clear button
          final clearButton = find.byIcon(Icons.clear);
          if (clearButton.evaluate().isNotEmpty) {
            await tester.tap(clearButton);
            await tester.pumpAndSettle();
          }
        }
        
        // Navigate back to browse hub
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
        expect(find.text('Explore Hymns'), findsOneWidget);
      }

      // ==== SEARCH FUNCTIONALITY ====
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      expect(find.text('Search Hymns'), findsOneWidget);
      
      // Test search functionality
      final mainSearchField = find.byType(TextField);
      await tester.enterText(mainSearchField, 'Amazing Grace');
      await tester.pumpAndSettle();
      
      // Test search results navigation
      final searchResults = find.byType(ListTile);
      if (searchResults.evaluate().isNotEmpty) {
        await tester.tap(searchResults.first);
        await tester.pumpAndSettle();
        
        // Should navigate to hymn detail page
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
        
        // Test back navigation from hymn detail
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
        expect(find.text('Search Hymns'), findsOneWidget);
      }

      // ==== FAVORITES SECTION ====
      await tester.tap(find.text('Favorites'));
      await tester.pumpAndSettle();
      expect(find.text('Your Favorites'), findsOneWidget);
      
      // Test empty favorites state
      expect(find.text('No favorites yet'), findsOneWidget);
      
      // Test add to favorites from browse
      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.collectionsTitle).first);
      await tester.pumpAndSettle();
      
      // Test hymn detail navigation and favorites
      final hymnTiles = find.byType(ListTile);
      if (hymnTiles.evaluate().isNotEmpty) {
        await tester.tap(hymnTiles.first);
        await tester.pumpAndSettle();
        
        // Test favorite button
        final favoriteButton = find.byIcon(Icons.favorite_border);
        if (favoriteButton.evaluate().isNotEmpty) {
          await tester.tap(favoriteButton);
          await tester.pumpAndSettle();
          
          // Should now show filled favorite
          expect(find.byIcon(Icons.favorite), findsOneWidget);
        }
        
        // Test audio playback if available
        final playButton = find.byIcon(Icons.play_arrow);
        if (playButton.evaluate().isNotEmpty) {
          await tester.tap(playButton);
          await tester.pumpAndSettle();
          
          // Should show pause button after play
          expect(find.byIcon(Icons.pause), findsOneWidget);
          
          // Test pause
          await tester.tap(find.byIcon(Icons.pause));
          await tester.pumpAndSettle();
        }
        
        // Navigate back
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
      }

      // ==== MORE SECTION ====
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      expect(find.text('More Options'), findsOneWidget);
      
      // Test downloads navigation
      final downloadsTile = find.text('Downloads');
      if (downloadsTile.evaluate().isNotEmpty) {
        await tester.tap(downloadsTile);
        await tester.pumpAndSettle();
        expect(find.text('Downloads'), findsOneWidget);
        
        // Test download categories
        expect(find.text('Audio Files'), findsOneWidget);
        expect(find.text('Hymnal PDFs'), findsOneWidget);
        expect(find.text('Sheet Music'), findsOneWidget);
        
        // Navigate back
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
      }
      
      // Test settings navigation
      final settingsTile = find.text('Settings');
      if (settingsTile.evaluate().isNotEmpty) {
        await tester.tap(settingsTile);
        await tester.pumpAndSettle();
        expect(find.text('Settings'), findsOneWidget);
        
        // Test settings categories
        expect(find.text('Theme'), findsOneWidget);
        expect(find.text('Language'), findsOneWidget);
        expect(find.text('Font Size'), findsOneWidget);
        expect(find.text('Audio Settings'), findsOneWidget);
        
        // Test theme switching
        final themeDropdown = find.byType(DropdownButton<String>).first;
        await tester.tap(themeDropdown);
        await tester.pumpAndSettle();
        
        // Test selecting different theme
        final darkThemeOption = find.text('Dark');
        if (darkThemeOption.evaluate().isNotEmpty) {
          await tester.tap(darkThemeOption);
          await tester.pumpAndSettle();
        }
        
        // Navigate back
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
      }

      // ==== RETURN TO HOME ====
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.text('Welcome to Advent Hymnals'), findsOneWidget);
    });

    testWidgets('Deep navigation stress test', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      await tester.pumpAndSettle();

      // Navigate through multiple levels rapidly
      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text(AppStrings.collectionsTitle).first);
      await tester.pumpAndSettle();
      
      // Navigate to hymn detail
      final hymnTiles = find.byType(ListTile);
      if (hymnTiles.evaluate().isNotEmpty) {
        await tester.tap(hymnTiles.first);
        await tester.pumpAndSettle();
        
        // Test multiple back navigations
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
        expect(find.text('Collections'), findsOneWidget);
        
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
        expect(find.text('Explore Hymns'), findsOneWidget);
      }
      
      // Test bottom navigation from any depth
      await tester.tap(find.text(AppStrings.authorsTitle));
      await tester.pumpAndSettle();
      
      // Jump to different section via bottom nav
      await tester.tap(find.text('Favorites'));
      await tester.pumpAndSettle();
      expect(find.text('Your Favorites'), findsOneWidget);
      
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      expect(find.text('Search Hymns'), findsOneWidget);
    });

    testWidgets('Audio player integration navigation', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      await tester.pumpAndSettle();

      // Navigate to hymn with audio
      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.collectionsTitle).first);
      await tester.pumpAndSettle();
      
      final hymnTiles = find.byType(ListTile);
      if (hymnTiles.evaluate().isNotEmpty) {
        await tester.tap(hymnTiles.first);
        await tester.pumpAndSettle();
        
        // Test audio playback
        final playButton = find.byIcon(Icons.play_arrow);
        if (playButton.evaluate().isNotEmpty) {
          await tester.tap(playButton);
          await tester.pumpAndSettle();
          
          // Test mini player appears
          expect(find.byKey(const Key('mini_audio_player')), findsOneWidget);
          
          // Test navigation with audio playing
          await tester.tap(find.text('Search'));
          await tester.pumpAndSettle();
          
          // Mini player should persist
          expect(find.byKey(const Key('mini_audio_player')), findsOneWidget);
          
          // Test full player navigation
          await tester.tap(find.byKey(const Key('mini_audio_player')));
          await tester.pumpAndSettle();
          
          // Should open full audio player
          expect(find.text('Now Playing'), findsOneWidget);
          
          // Test back from full player
          await tester.tap(find.byIcon(Icons.arrow_back));
          await tester.pumpAndSettle();
          expect(find.text('Search Hymns'), findsOneWidget);
        }
      }
    });

    testWidgets('Error handling and edge cases', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      await tester.pumpAndSettle();

      // Test rapid navigation
      await tester.tap(find.text('Browse'));
      await tester.tap(find.text('Search'));
      await tester.tap(find.text('Favorites'));
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      
      // Should end up on last tapped screen
      expect(find.text('More Options'), findsOneWidget);
      
      // Test empty search handling
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();
      
      // Should show search suggestions
      expect(find.text('Search Suggestions'), findsOneWidget);
      
      // Test invalid search
      await tester.enterText(searchField, 'nonexistentquery12345');
      await tester.pumpAndSettle();
      
      // Should handle gracefully
      expect(find.text('No results found'), findsOneWidget);
    });

    testWidgets('Accessibility and keyboard navigation', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      await tester.pumpAndSettle();

      // Test semantic labels
      expect(find.text('Welcome to Advent Hymnals'), findsOneWidget);
      
      // Test tab navigation
      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();
      
      // Test button accessibility
      final browseCards = find.byType(Card);
      expect(browseCards, findsWidgets);
      
      // Test search field accessibility
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
      
      // Test hint text
      expect(find.text('Search for hymns, authors, or topics...'), findsOneWidget);
      
      // Test focus management
      await tester.tap(searchField);
      await tester.pumpAndSettle();
      
      // Field should be focused
      expect(tester.binding.focusManager.primaryFocus?.hasFocus, true);
    });

    testWidgets('State preservation across navigation', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      await tester.pumpAndSettle();

      // Set up search state
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Amazing Grace');
      await tester.pumpAndSettle();
      
      // Navigate away
      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();
      
      // Navigate back
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      
      // State should be preserved
      expect(find.text('Amazing Grace'), findsOneWidget);
      
      // Test favorites state
      await tester.tap(find.text('Favorites'));
      await tester.pumpAndSettle();
      
      // Add a favorite from browse
      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.collectionsTitle).first);
      await tester.pumpAndSettle();
      
      final hymnTiles = find.byType(ListTile);
      if (hymnTiles.evaluate().isNotEmpty) {
        await tester.tap(hymnTiles.first);
        await tester.pumpAndSettle();
        
        final favoriteButton = find.byIcon(Icons.favorite_border);
        if (favoriteButton.evaluate().isNotEmpty) {
          await tester.tap(favoriteButton);
          await tester.pumpAndSettle();
          
          // Check favorites section
          await tester.tap(find.text('Favorites'));
          await tester.pumpAndSettle();
          
          // Should show the favorited hymn
          expect(find.byType(ListTile), findsOneWidget);
        }
      }
    });

    testWidgets('Performance under heavy navigation', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      await tester.pumpAndSettle();

      // Simulate heavy navigation usage
      const navigationSequence = [
        'Browse',
        'Search',
        'Favorites',
        'More',
        'Home',
        'Browse',
        'Search',
        'Favorites',
        'More',
        'Home',
      ];
      
      for (final navItem in navigationSequence) {
        await tester.tap(find.text(navItem));
        await tester.pumpAndSettle();
        
        // Should navigate successfully each time
        expect(find.text(navItem), findsOneWidget);
      }
      
      // Test browse navigation under load
      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();
      
      for (final category in [
        AppStrings.collectionsTitle,
        AppStrings.authorsTitle,
        AppStrings.topicsTitle,
      ]) {
        await tester.tap(find.text(category).first);
        await tester.pumpAndSettle();
        
        // Test search in each category
        final searchField = find.byType(TextField);
        if (searchField.evaluate().isNotEmpty) {
          await tester.enterText(searchField, 'test');
          await tester.pumpAndSettle();
          
          final clearButton = find.byIcon(Icons.clear);
          if (clearButton.evaluate().isNotEmpty) {
            await tester.tap(clearButton);
            await tester.pumpAndSettle();
          }
        }
        
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
      }
      
      // App should remain responsive
      expect(find.text('Explore Hymns'), findsOneWidget);
    });

    testWidgets('Complete user journey simulation', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      await tester.pumpAndSettle();

      // ==== NEW USER JOURNEY ====
      // 1. User opens app and sees welcome screen
      expect(find.text('Welcome to Advent Hymnals'), findsOneWidget);
      
      // 2. User explores browse functionality
      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();
      expect(find.text('Quick Stats'), findsOneWidget);
      
      // 3. User checks out collections
      await tester.tap(find.text(AppStrings.collectionsTitle).first);
      await tester.pumpAndSettle();
      expect(find.text('Seventh-day Adventist Hymnal'), findsOneWidget);
      
      // 4. User views a hymn
      final hymnTiles = find.byType(ListTile);
      if (hymnTiles.evaluate().isNotEmpty) {
        await tester.tap(hymnTiles.first);
        await tester.pumpAndSettle();
        
        // 5. User adds to favorites
        final favoriteButton = find.byIcon(Icons.favorite_border);
        if (favoriteButton.evaluate().isNotEmpty) {
          await tester.tap(favoriteButton);
          await tester.pumpAndSettle();
        }
        
        // 6. User plays audio
        final playButton = find.byIcon(Icons.play_arrow);
        if (playButton.evaluate().isNotEmpty) {
          await tester.tap(playButton);
          await tester.pumpAndSettle();
        }
        
        // 7. User navigates back
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
      }
      
      // 8. User tries search
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Amazing Grace');
      await tester.pumpAndSettle();
      
      // 9. User checks favorites
      await tester.tap(find.text('Favorites'));
      await tester.pumpAndSettle();
      
      // 10. User explores settings
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      
      final settingsTile = find.text('Settings');
      if (settingsTile.evaluate().isNotEmpty) {
        await tester.tap(settingsTile);
        await tester.pumpAndSettle();
        
        // User changes theme
        final themeDropdown = find.byType(DropdownButton<String>).first;
        await tester.tap(themeDropdown);
        await tester.pumpAndSettle();
        
        final darkThemeOption = find.text('Dark');
        if (darkThemeOption.evaluate().isNotEmpty) {
          await tester.tap(darkThemeOption);
          await tester.pumpAndSettle();
        }
        
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
      }
      
      // 11. User returns to home
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.text('Welcome to Advent Hymnals'), findsOneWidget);
      
      // Journey complete - all major features tested
    });
  });
}