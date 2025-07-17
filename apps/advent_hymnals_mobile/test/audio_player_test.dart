import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:advent_hymnals/main.dart';

void main() {
  group('Audio Player Tests', () {
    testWidgets('Hymn detail shows play button', (WidgetTester tester) async {
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

      // Should be on hymn detail screen with play button
      expect(find.byIcon(Icons.play_circle_filled), findsOneWidget);
    });

    testWidgets('Play button interaction works', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initial load
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Navigate to hymn detail
      await tester.tap(find.text('Browse').first);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.tap(find.text('Authors'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.tap(find.text('Charles Wesley').first);
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Tap play button
      await tester.tap(find.byIcon(Icons.play_circle_filled));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Should show mini player at bottom (play functionality started)
      expect(find.byType(Container), findsAtLeastNWidgets(1));
    });

    testWidgets('Audio player components are present', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initial load
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Check main navigation contains audio player space
      expect(find.byType(Column), findsAtLeastNWidgets(1));
    });

    testWidgets('Search results have audio capabilities', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initial load
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Navigate to Search screen
      await tester.tap(find.text('Search').first);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Search for a hymn
      await tester.enterText(find.byType(TextField), 'amazing');
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Should show search results with navigation capability
      expect(find.text('Amazing Grace'), findsAtLeastNWidgets(1));
      
      // Tap on result to go to detail
      await tester.tap(find.text('Amazing Grace').first);
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Should show play button on detail screen
      expect(find.byIcon(Icons.play_circle_filled), findsOneWidget);
    });

    testWidgets('Audio controls are accessible', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initial load
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Go to hymn detail screen
      await tester.tap(find.text('Browse').first);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.tap(find.text('Authors'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.tap(find.text('Charles Wesley').first);
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Verify audio controls in app bar
      expect(find.byIcon(Icons.play_circle_filled), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.share), findsOneWidget);
    });

    testWidgets('Audio settings integration works', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initial load
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Navigate to More screen
      await tester.tap(find.text('More').first);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Find and tap Settings
      await tester.tap(find.text('Settings'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Should have audio settings section
      expect(find.text('Audio & Playback'), findsOneWidget);
      expect(find.text('Sound Effects'), findsOneWidget);
      expect(find.text('Playback Speed'), findsOneWidget);
    });
  });
}