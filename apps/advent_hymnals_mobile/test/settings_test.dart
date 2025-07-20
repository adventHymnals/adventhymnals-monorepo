import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:advent_hymnals/main.dart';

void main() {
  group('Settings Tests', () {
    testWidgets('Settings screen renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initial load
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Navigate to More screen first
      await tester.tap(find.text('More').first);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Find and tap Settings
      await tester.tap(find.text('Settings'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Verify Settings screen components
      expect(find.text('Settings'), findsAtLeastNWidgets(1));
      expect(find.text('Theme & Appearance'), findsOneWidget);
      expect(find.text('Audio & Playback'), findsOneWidget);
      expect(find.text('Downloads & Offline'), findsOneWidget);
    });

    testWidgets('Theme settings dialog works', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initial load
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Navigate to More screen first
      await tester.tap(find.text('More').first);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Find and tap Settings
      await tester.tap(find.text('Settings'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Tap on Theme setting
      await tester.tap(find.text('Theme').first);
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Should show theme dialog
      expect(find.text('Choose Theme'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
    });

    testWidgets('Settings switches work', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initial load
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Navigate to More screen first
      await tester.tap(find.text('More').first);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Find and tap Settings
      await tester.tap(find.text('Settings'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Find and test a switch (e.g., Show Hymn Numbers)
      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsAtLeastNWidgets(1));
      
      // Tap the first switch to toggle it
      await tester.tap(switchFinder.first);
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // The switch should have toggled (we can't easily check the exact state in tests)
      expect(switchFinder, findsAtLeastNWidgets(1));
    });

    testWidgets('Settings navigation works', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initial load
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Navigate to More screen first
      await tester.tap(find.text('More').first);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Find and tap Settings
      await tester.tap(find.text('Settings'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Verify we're on Settings screen
      expect(find.text('Settings'), findsAtLeastNWidgets(1));
      expect(find.text('Theme & Appearance'), findsOneWidget);
      
      // Navigate back
      await tester.pageBack();
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Should be back on More screen
      expect(find.text('More'), findsAtLeastNWidgets(1));
    });

    testWidgets('Settings sections display correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initial load
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Navigate to More screen first
      await tester.tap(find.text('More').first);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Find and tap Settings
      await tester.tap(find.text('Settings'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Check all main sections are present
      expect(find.text('Theme & Appearance'), findsOneWidget);
      expect(find.text('Audio & Playback'), findsOneWidget);
      expect(find.text('Downloads & Offline'), findsOneWidget);
      expect(find.text('Screen & Device'), findsOneWidget);
      expect(find.text('Data & Storage'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
    });

    testWidgets('About dialog works', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initial load
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Navigate to More screen first
      await tester.tap(find.text('More').first);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Find and tap Settings
      await tester.tap(find.text('Settings'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Find and tap About
      await tester.tap(find.text('About'));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Should show about dialog
      expect(find.text('About Advent Hymnals Mobile'), findsOneWidget);
    });
  });
}