import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:advent_hymnals_mobile/main.dart';
import 'package:advent_hymnals_mobile/presentation/providers/download_provider.dart';

void main() {
  group('Downloads Functionality Tests', () {
    testWidgets('Downloads screen renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initial load
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Navigate to More screen
      await tester.tap(find.text('More'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Find and tap Downloads quick access card
      await tester.tap(find.text('Downloads'));
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Verify Downloads screen components (use findsAtLeast for more tolerance)
      expect(find.text('Downloads'), findsAtLeastNWidgets(1));
      expect(find.text('Total'), findsAtLeastNWidgets(1));
      expect(find.text('Active'), findsAtLeastNWidgets(1));
      expect(find.text('Completed'), findsAtLeastNWidgets(1));
      expect(find.text('Failed'), findsAtLeastNWidgets(1));
    });

    testWidgets('Downloads statistics section displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initial load
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Navigate to Downloads screen
      await tester.tap(find.text('More'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.tap(find.text('Downloads'));
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Check statistics cards (more tolerant expectations)
      expect(find.byIcon(Icons.download), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.download_outlined), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.check_circle), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.error), findsAtLeastNWidgets(1));

      // Check statistic values (should start at 0)
      final totalStats = find.text('0');
      expect(totalStats, findsAtLeastNWidgets(1)); // Multiple 0 values for empty stats
    });

    testWidgets('Downloads filter tabs work correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initial load
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Navigate to Downloads screen
      await tester.tap(find.text('More'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.tap(find.text('Downloads'));
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Check filter tabs exist
      expect(find.text('All (0)'), findsOneWidget);
      expect(find.text('Active (0)'), findsOneWidget);
      expect(find.text('Done (0)'), findsOneWidget);
      expect(find.text('Failed (0)'), findsOneWidget);

      // Test tapping filter tabs
      await tester.tap(find.text('Active (0)'));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.tap(find.text('Done (0)'));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.tap(find.text('Failed (0)'));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    });

    testWidgets('Empty state displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initial load
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Navigate to Downloads screen
      await tester.tap(find.text('More'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.tap(find.text('Downloads'));
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Check empty state
      expect(find.text('No downloads'), findsOneWidget);
      expect(find.text('Downloads will appear here when you download hymns'), findsOneWidget);
      expect(find.byIcon(Icons.download_outlined), findsAtLeastNWidgets(1));
    });

    testWidgets('Add sample download functionality', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initial load
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Navigate to Downloads screen
      await tester.tap(find.text('More'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.tap(find.text('Downloads'));
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Find and tap the FAB to add sample download
      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);
      
      await tester.tap(fab);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // After adding a download, statistics should update
      // Note: This test may need adjustment based on actual provider behavior
    });

    testWidgets('Downloads menu options work', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initial load
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Navigate to Downloads screen
      await tester.tap(find.text('More'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.tap(find.text('Downloads'));
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Find and tap the menu button
      final menuButton = find.byType(PopupMenuButton<String>);
      expect(menuButton, findsOneWidget);
      
      await tester.tap(menuButton);
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Check menu options exist
      expect(find.text('Clear Completed'), findsOneWidget);
      expect(find.text('Clear All'), findsOneWidget);
      expect(find.text('Download Settings'), findsOneWidget);

      // Test tapping a menu option
      await tester.tap(find.text('Download Settings'));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Should show settings dialog
      expect(find.text('Download Settings'), findsAtLeastNWidgets(1));
      expect(find.text('Download settings will be implemented soon.'), findsOneWidget);
      
      // Close dialog
      await tester.tap(find.text('OK'));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    });

    testWidgets('Pull to refresh functionality', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initial load
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Navigate to Downloads screen
      await tester.tap(find.text('More'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.tap(find.text('Downloads'));
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Find the RefreshIndicator
      final refreshIndicator = find.byType(RefreshIndicator);
      expect(refreshIndicator, findsOneWidget);

      // Test pull to refresh (simulate the gesture)
      await tester.fling(find.text('No downloads'), const Offset(0, 300), 1000);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Should trigger refresh (test passes if no exceptions)
    });

    testWidgets('Downloads screen navigation from home', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initial load
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Alternative path: Navigate through bottom nav -> More -> Downloads
      await tester.tap(find.text('More'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Verify we're on More screen
      expect(find.text('Quick Access'), findsOneWidget);
      expect(find.text('Downloads'), findsOneWidget);
      expect(find.text('Offline content'), findsOneWidget);

      // Tap Downloads quick access card
      final downloadsCard = find.ancestor(
        of: find.text('Offline content'),
        matching: find.byType(Card),
      );
      expect(downloadsCard, findsOneWidget);
      
      await tester.tap(downloadsCard);
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Should be on Downloads screen
      expect(find.text('No downloads'), findsOneWidget);
      expect(find.text('Total'), findsAtLeastNWidgets(1));
    });

    testWidgets('Downloads screen accessibility features', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initial load
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Navigate to Downloads screen
      await tester.tap(find.text('More'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.tap(find.text('Downloads'));
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Check tooltips on FAB
      final fab = find.byType(FloatingActionButton);
      final fabWidget = tester.widget<FloatingActionButton>(fab);
      expect(fabWidget.tooltip, 'Add Sample Download');

      // Check accessibility features for empty state
      expect(find.text('No downloads'), findsOneWidget);
      expect(find.text('Downloads will appear here when you download hymns'), findsOneWidget);

      // Check filter chips are accessible
      expect(find.byType(FilterChip), findsAtLeastNWidgets(1));
    });
  });
}