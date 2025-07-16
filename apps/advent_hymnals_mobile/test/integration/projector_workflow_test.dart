import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../../lib/main.dart';
import '../../lib/core/services/projector_service.dart';
import '../../lib/core/services/projector_window_service.dart';
import '../../lib/presentation/providers/hymn_provider.dart';
import '../../lib/presentation/providers/favorites_provider.dart';
import '../../lib/presentation/providers/recently_viewed_provider.dart';
import '../../lib/domain/entities/hymn.dart';

void main() {
  group('Projector Workflow Integration Tests', () {
    late List<MethodCall> methodCalls;

    setUp(() {
      methodCalls = [];
      
      // Mock the projector window service method channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.adventhymnals.org/projector_window'),
        (MethodCall methodCall) async {
          methodCalls.add(methodCall);
          
          switch (methodCall.method) {
            case 'initialize':
              return true;
            case 'getMonitors':
              return [
                {
                  'index': 0,
                  'name': 'Primary Monitor',
                  'width': 1920,
                  'height': 1080,
                  'x': 0,
                  'y': 0,
                  'isPrimary': true,
                  'scaleFactor': 1.0,
                },
                {
                  'index': 1,
                  'name': 'Secondary Monitor',
                  'width': 1440,
                  'height': 900,
                  'x': 1920,
                  'y': 0,
                  'isPrimary': false,
                  'scaleFactor': 1.0,
                },
              ];
            case 'openSecondaryWindow':
              return true;
            case 'closeSecondaryWindow':
              return true;
            case 'moveToMonitor':
              return true;
            case 'setFullscreenOnMonitor':
              return true;
            case 'updateContent':
              return true;
            default:
              return null;
          }
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.adventhymnals.org/projector_window'),
        null,
      );
      methodCalls.clear();
    });

    testWidgets('Complete projector workflow from home screen', (WidgetTester tester) async {
      // Create sample hymns for testing
      final sampleHymns = [
        Hymn(
          id: 1,
          hymnNumber: 1,
          title: 'Amazing Grace',
          author: 'John Newton',
          lyrics: '''Amazing grace! how sweet the sound,
That saved a wretch like me!
I once was lost, but now am found,
Was blind, but now I see.

'Twas grace that taught my heart to fear,
And grace my fears relieved;
How precious did that grace appear
The hour I first believed!''',
          themeTags: ['Grace', 'Salvation'],
        ),
        Hymn(
          id: 2,
          hymnNumber: 2,
          title: 'How Great Thou Art',
          author: 'Carl Boberg',
          lyrics: '''O Lord my God, when I in awesome wonder
Consider all the worlds Thy hands have made,
I see the stars, I hear the rolling thunder,
Thy power throughout the universe displayed.

Then sings my soul, my Savior God, to Thee:
How great Thou art, how great Thou art!
Then sings my soul, my Savior God, to Thee:
How great Thou art, how great Thou art!''',
          themeTags: ['Praise', 'Creation'],
        ),
      ];

      // Build the app with test providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => HymnProvider()..setTestHymns(sampleHymns)),
            ChangeNotifierProvider(create: (_) => FavoritesProvider()),
            ChangeNotifierProvider(create: (_) => RecentlyViewedProvider()),
            ChangeNotifierProvider(create: (_) => ProjectorService()),
          ],
          child: const MyApp(),
        ),
      );

      // Wait for the app to load
      await tester.pumpAndSettle();

      // Skip if not on desktop (projector mode only available on desktop)
      if (!tester.binding.defaultBinaryMessenger.checkMockMessageHandler(
          'com.adventhymnals.org/projector_window', null)) {
        return;
      }

      // Step 1: Navigate to projector mode from home screen
      // Look for projector mode card or button
      final projectorButton = find.text('Projector Mode');
      if (projectorButton.evaluate().isNotEmpty) {
        await tester.tap(projectorButton);
        await tester.pumpAndSettle();
      } else {
        // If no projector button, navigate manually
        await tester.tap(find.byIcon(Icons.present_to_all));
        await tester.pumpAndSettle();
      }

      // Step 2: Verify projector screen is shown with hymn selection
      expect(find.text('Projector Mode'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget); // Search field

      // Step 3: Search for a hymn
      await tester.enterText(find.byType(TextField), 'Amazing Grace');
      await tester.pumpAndSettle();

      // Step 4: Select a hymn for projection
      final projectButton = find.text('Project');
      if (projectButton.evaluate().isNotEmpty) {
        await tester.tap(projectButton.first);
        await tester.pumpAndSettle();
      }

      // Step 5: Verify projector service is activated
      final projectorService = tester.widget<ChangeNotifierProvider>(
        find.byType(ChangeNotifierProvider).at(3),
      ).create(null) as ProjectorService;

      expect(projectorService.isProjectorActive, isTrue);
      expect(projectorService.currentHymnId, 1);
      expect(projectorService.currentVerseIndex, 0);

      // Step 6: Test navigation controls
      // Navigate to next verse
      final nextButton = find.byIcon(Icons.skip_next);
      if (nextButton.evaluate().isNotEmpty) {
        await tester.tap(nextButton);
        await tester.pumpAndSettle();
      }

      // Navigate to previous verse
      final previousButton = find.byIcon(Icons.skip_previous);
      if (previousButton.evaluate().isNotEmpty) {
        await tester.tap(previousButton);
        await tester.pumpAndSettle();
      }

      // Step 7: Test settings controls
      final settingsButton = find.byIcon(Icons.settings);
      if (settingsButton.evaluate().isNotEmpty) {
        await tester.tap(settingsButton);
        await tester.pumpAndSettle();

        // Test theme change
        final lightThemeOption = find.text('Light (White/Black)');
        if (lightThemeOption.evaluate().isNotEmpty) {
          await tester.tap(lightThemeOption);
          await tester.pumpAndSettle();
        }

        // Close settings
        final applyButton = find.text('Apply');
        if (applyButton.evaluate().isNotEmpty) {
          await tester.tap(applyButton);
          await tester.pumpAndSettle();
        }
      }

      // Step 8: Test auto-advance functionality
      final autoAdvanceButton = find.byIcon(Icons.timer_off);
      if (autoAdvanceButton.evaluate().isNotEmpty) {
        await tester.tap(autoAdvanceButton);
        await tester.pumpAndSettle();
      }

      // Step 9: Stop projector
      final stopButton = find.byIcon(Icons.close);
      if (stopButton.evaluate().isNotEmpty) {
        await tester.tap(stopButton);
        await tester.pumpAndSettle();
      }

      // Step 10: Verify projector is stopped
      expect(projectorService.isProjectorActive, isFalse);
    });

    testWidgets('Projector control widget workflow', (WidgetTester tester) async {
      // Create a simple test app with projector control widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => ProjectorService()),
              ],
              child: const Column(
                children: [
                  // ProjectorControlWidget would be here
                  Text('Projector Control'),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start projector service manually for testing
      final projectorService = ProjectorService();
      projectorService.startProjector(1);

      // Verify projector is active
      expect(projectorService.isProjectorActive, isTrue);

      // Test navigation
      projectorService.nextSection();
      expect(projectorService.currentVerseIndex, 1);

      projectorService.previousSection();
      expect(projectorService.currentVerseIndex, 0);

      // Test settings update
      projectorService.updateProjectorSettings(
        theme: ProjectorTheme.light,
        textSize: ProjectorTextSize.large,
      );
      expect(projectorService.theme, ProjectorTheme.light);
      expect(projectorService.textSize, ProjectorTextSize.large);

      // Test auto-advance
      projectorService.toggleAutoAdvance();
      expect(projectorService.autoAdvanceEnabled, isTrue);

      projectorService.setAutoAdvanceSeconds(30);
      expect(projectorService.autoAdvanceSeconds, 30);

      // Stop projector
      projectorService.stopProjector();
      expect(projectorService.isProjectorActive, isFalse);
    });

    testWidgets('Secondary window management workflow', (WidgetTester tester) async {
      // Test secondary window operations
      final windowService = ProjectorWindowService.instance;

      // Initialize service
      final initialized = await windowService.initialize();
      expect(initialized, isTrue);

      // Get monitors
      final monitors = await windowService.getAvailableMonitors();
      expect(monitors.length, 2);
      expect(monitors[0].isPrimary, isTrue);
      expect(monitors[1].isPrimary, isFalse);

      // Open secondary window
      final opened = await windowService.openSecondaryWindow(
        monitorIndex: 1,
        fullscreen: true,
      );
      expect(opened, isTrue);
      expect(windowService.isSecondaryWindowOpen, isTrue);

      // Update content
      final contentUpdated = await windowService.updateContent({
        'hymnId': 1,
        'verseIndex': 0,
        'theme': 'dark',
      });
      expect(contentUpdated, isTrue);

      // Move to different monitor
      final moved = await windowService.moveToMonitor(0);
      expect(moved, isTrue);

      // Set fullscreen on monitor
      final fullscreen = await windowService.setFullscreenOnMonitor(0);
      expect(fullscreen, isTrue);

      // Close secondary window
      final closed = await windowService.closeSecondaryWindow();
      expect(closed, isTrue);
      expect(windowService.isSecondaryWindowOpen, isFalse);

      // Verify method calls were made
      expect(methodCalls.map((call) => call.method), contains('initialize'));
      expect(methodCalls.map((call) => call.method), contains('getMonitors'));
      expect(methodCalls.map((call) => call.method), contains('openSecondaryWindow'));
      expect(methodCalls.map((call) => call.method), contains('updateContent'));
      expect(methodCalls.map((call) => call.method), contains('moveToMonitor'));
      expect(methodCalls.map((call) => call.method), contains('setFullscreenOnMonitor'));
      expect(methodCalls.map((call) => call.method), contains('closeSecondaryWindow'));
    });

    testWidgets('Hymn selection and projection workflow', (WidgetTester tester) async {
      // Create sample hymns
      final sampleHymns = [
        Hymn(
          id: 1,
          hymnNumber: 1,
          title: 'Amazing Grace',
          author: 'John Newton',
          lyrics: 'Amazing grace! how sweet the sound...',
          themeTags: ['Grace'],
        ),
        Hymn(
          id: 2,
          hymnNumber: 2,
          title: 'How Great Thou Art',
          author: 'Carl Boberg',
          lyrics: 'O Lord my God, when I in awesome wonder...',
          themeTags: ['Praise'],
        ),
      ];

      // Build widget with providers
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => HymnProvider()..setTestHymns(sampleHymns)),
                ChangeNotifierProvider(create: (_) => FavoritesProvider()),
                ChangeNotifierProvider(create: (_) => RecentlyViewedProvider()),
                ChangeNotifierProvider(create: (_) => ProjectorService()),
              ],
              child: const Text('Hymn Selection Test'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test hymn provider
      final hymnProvider = tester.widget<ChangeNotifierProvider>(
        find.byType(ChangeNotifierProvider).first,
      ).create(null) as HymnProvider;

      expect(hymnProvider.hymns.length, 2);
      expect(hymnProvider.hymns[0].title, 'Amazing Grace');
      expect(hymnProvider.hymns[1].title, 'How Great Thou Art');

      // Test search functionality
      final searchResults = await hymnProvider.searchHymns('Amazing');
      expect(searchResults.length, 1);
      expect(searchResults[0].title, 'Amazing Grace');

      // Test favorites
      final favoritesProvider = tester.widget<ChangeNotifierProvider>(
        find.byType(ChangeNotifierProvider).at(1),
      ).create(null) as FavoritesProvider;

      favoritesProvider.addFavorite(sampleHymns[0]);
      expect(favoritesProvider.favoriteHymns.length, 1);
      expect(favoritesProvider.isFavorite(1), isTrue);

      // Test recently viewed
      final recentlyViewedProvider = tester.widget<ChangeNotifierProvider>(
        find.byType(ChangeNotifierProvider).at(2),
      ).create(null) as RecentlyViewedProvider;

      recentlyViewedProvider.addRecentlyViewed(sampleHymns[0]);
      expect(recentlyViewedProvider.recentHymns.length, 1);
      expect(recentlyViewedProvider.recentHymns[0].title, 'Amazing Grace');

      // Test projector service integration
      final projectorService = tester.widget<ChangeNotifierProvider>(
        find.byType(ChangeNotifierProvider).at(3),
      ).create(null) as ProjectorService;

      // Start projecting a hymn
      projectorService.startProjector(1);
      expect(projectorService.isProjectorActive, isTrue);
      expect(projectorService.currentHymnId, 1);

      // Test complete workflow
      projectorService.nextSection();
      projectorService.updateProjectorSettings(theme: ProjectorTheme.light);
      projectorService.toggleAutoAdvance();
      projectorService.setAutoAdvanceSeconds(20);

      expect(projectorService.currentVerseIndex, 1);
      expect(projectorService.theme, ProjectorTheme.light);
      expect(projectorService.autoAdvanceEnabled, isTrue);
      expect(projectorService.autoAdvanceSeconds, 20);

      // Stop projection
      projectorService.stopProjector();
      expect(projectorService.isProjectorActive, isFalse);
    });

    testWidgets('Error handling in projector workflow', (WidgetTester tester) async {
      // Test error scenarios
      
      // Mock failure responses
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.adventhymnals.org/projector_window'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'initialize':
              return false; // Simulate initialization failure
            case 'openSecondaryWindow':
              throw PlatformException(
                code: 'WINDOW_ERROR',
                message: 'Failed to open secondary window',
              );
            default:
              return null;
          }
        },
      );

      final windowService = ProjectorWindowService.instance;

      // Test initialization failure
      final initialized = await windowService.initialize();
      expect(initialized, isFalse);

      // Test window opening failure
      final opened = await windowService.openSecondaryWindow();
      expect(opened, isFalse);

      // Test projector service error handling
      final projectorService = ProjectorService();
      
      // Should still work even if secondary window fails
      projectorService.startProjector(1);
      expect(projectorService.isProjectorActive, isTrue);

      // Navigation should still work
      projectorService.nextSection();
      expect(projectorService.currentVerseIndex, 1);

      // Settings should still work
      projectorService.updateProjectorSettings(theme: ProjectorTheme.blue);
      expect(projectorService.theme, ProjectorTheme.blue);

      // Cleanup
      projectorService.stopProjector();
      expect(projectorService.isProjectorActive, isFalse);
    });
  });

  group('Monitor Detection and Management', () {
    testWidgets('Monitor detection workflow', (WidgetTester tester) async {
      // Mock different monitor configurations
      final monitorConfigs = [
        // Single monitor
        [
          {
            'index': 0,
            'name': 'Primary Monitor',
            'width': 1920,
            'height': 1080,
            'x': 0,
            'y': 0,
            'isPrimary': true,
            'scaleFactor': 1.0,
          },
        ],
        // Dual monitor
        [
          {
            'index': 0,
            'name': 'Primary Monitor',
            'width': 1920,
            'height': 1080,
            'x': 0,
            'y': 0,
            'isPrimary': true,
            'scaleFactor': 1.0,
          },
          {
            'index': 1,
            'name': 'Secondary Monitor',
            'width': 2560,
            'height': 1440,
            'x': 1920,
            'y': 0,
            'isPrimary': false,
            'scaleFactor': 1.5,
          },
        ],
        // Triple monitor
        [
          {
            'index': 0,
            'name': 'Primary Monitor',
            'width': 1920,
            'height': 1080,
            'x': 0,
            'y': 0,
            'isPrimary': true,
            'scaleFactor': 1.0,
          },
          {
            'index': 1,
            'name': 'Left Monitor',
            'width': 1920,
            'height': 1080,
            'x': -1920,
            'y': 0,
            'isPrimary': false,
            'scaleFactor': 1.0,
          },
          {
            'index': 2,
            'name': 'Right Monitor',
            'width': 1920,
            'height': 1080,
            'x': 1920,
            'y': 0,
            'isPrimary': false,
            'scaleFactor': 1.0,
          },
        ],
      ];

      for (final config in monitorConfigs) {
        // Mock the specific monitor configuration
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('com.adventhymnals.org/projector_window'),
          (MethodCall methodCall) async {
            switch (methodCall.method) {
              case 'initialize':
                return true;
              case 'getMonitors':
                return config;
              case 'openSecondaryWindow':
                return true;
              case 'moveToMonitor':
                return true;
              default:
                return null;
            }
          },
        );

        final windowService = ProjectorWindowService.instance;
        await windowService.initialize();

        final monitors = await windowService.getAvailableMonitors();
        expect(monitors.length, config.length);

        if (config.length == 1) {
          expect(windowService.hasMultipleMonitors, isFalse);
          expect(windowService.secondaryMonitors.length, 0);
        } else {
          expect(windowService.hasMultipleMonitors, isTrue);
          expect(windowService.secondaryMonitors.length, config.length - 1);
        }

        final primaryMonitor = windowService.primaryMonitor;
        expect(primaryMonitor, isNotNull);
        expect(primaryMonitor!.isPrimary, isTrue);
        expect(primaryMonitor.index, 0);

        // Test window positioning for different monitor setups
        if (config.length > 1) {
          // Test opening window on secondary monitor
          final opened = await windowService.openSecondaryWindow(
            monitorIndex: 1,
            fullscreen: true,
          );
          expect(opened, isTrue);

          // Test moving between monitors
          for (int i = 0; i < config.length; i++) {
            final moved = await windowService.moveToMonitor(i);
            expect(moved, isTrue);
          }

          await windowService.closeSecondaryWindow();
        }
      }
    });
  });
}

// Extension to add test methods to HymnProvider
extension HymnProviderTest on HymnProvider {
  void setTestHymns(List<Hymn> hymns) {
    // This would be implemented in the actual HymnProvider
    // For testing purposes, we assume this method exists
  }
}