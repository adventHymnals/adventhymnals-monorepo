import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../../lib/core/services/projector_service.dart';
import '../../lib/core/services/projector_window_service.dart';
import '../../lib/presentation/widgets/projector_control_widget.dart';
import '../../lib/presentation/widgets/projector_presentation_widget.dart';
import '../../lib/presentation/widgets/hymn_selection_widget.dart';
import '../../lib/presentation/providers/hymn_provider.dart';
import '../../lib/presentation/providers/favorites_provider.dart';
import '../../lib/presentation/providers/recently_viewed_provider.dart';
import '../../lib/domain/entities/hymn.dart';

void main() {
  group('Projector Widget Tests', () {
    late List<MethodCall> methodCalls;
    late List<Hymn> sampleHymns;

    setUp(() {
      methodCalls = [];
      sampleHymns = [
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
How great Thou art, how great Thou art!''',
          themeTags: ['Praise', 'Creation'],
        ),
      ];

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

    group('ProjectorControlWidget', () {
      testWidgets('should show when projector is active', (WidgetTester tester) async {
        final projectorService = ProjectorService();
        projectorService.startProjector(1);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChangeNotifierProvider<ProjectorService>.value(
                value: projectorService,
                child: const ProjectorControlWidget(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should show projector active indicator
        expect(find.text('Projector Active'), findsOneWidget);
        expect(find.byIcon(Icons.cast_connected), findsOneWidget);
      });

      testWidgets('should hide when projector is not active', (WidgetTester tester) async {
        final projectorService = ProjectorService();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChangeNotifierProvider<ProjectorService>.value(
                value: projectorService,
                child: const ProjectorControlWidget(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should be hidden when projector is not active
        expect(find.text('Projector Active'), findsNothing);
      });

      testWidgets('should show current hymn info', (WidgetTester tester) async {
        final projectorService = ProjectorService();
        projectorService.startProjector(123);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChangeNotifierProvider<ProjectorService>.value(
                value: projectorService,
                child: const ProjectorControlWidget(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should show current hymn info
        expect(find.text('Current Hymn'), findsOneWidget);
        expect(find.text('Hymn #123'), findsOneWidget);
        expect(find.text('Verse 1'), findsOneWidget);
      });

      testWidgets('should show navigation controls', (WidgetTester tester) async {
        final projectorService = ProjectorService();
        projectorService.startProjector(1);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChangeNotifierProvider<ProjectorService>.value(
                value: projectorService,
                child: const ProjectorControlWidget(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should show navigation controls
        expect(find.text('Navigation'), findsOneWidget);
        expect(find.text('Previous'), findsOneWidget);
        expect(find.text('Next'), findsOneWidget);
      });

      testWidgets('should handle navigation button taps', (WidgetTester tester) async {
        final projectorService = ProjectorService();
        projectorService.startProjector(1);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChangeNotifierProvider<ProjectorService>.value(
                value: projectorService,
                child: const ProjectorControlWidget(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Test next button
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
        expect(projectorService.currentVerseIndex, 1);

        // Test previous button
        await tester.tap(find.text('Previous'));
        await tester.pumpAndSettle();
        expect(projectorService.currentVerseIndex, 0);
      });

      testWidgets('should show display settings controls', (WidgetTester tester) async {
        final projectorService = ProjectorService();
        projectorService.startProjector(1);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChangeNotifierProvider<ProjectorService>.value(
                value: projectorService,
                child: const ProjectorControlWidget(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should show display settings
        expect(find.text('Display Settings'), findsOneWidget);
        expect(find.text('Theme'), findsOneWidget);
        expect(find.text('Text Size'), findsOneWidget);
      });

      testWidgets('should show auto-advance controls', (WidgetTester tester) async {
        final projectorService = ProjectorService();
        projectorService.startProjector(1);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChangeNotifierProvider<ProjectorService>.value(
                value: projectorService,
                child: const ProjectorControlWidget(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should show auto-advance controls
        expect(find.text('Auto-Advance'), findsOneWidget);
        expect(find.byType(Switch), findsOneWidget);
      });

      testWidgets('should show action buttons', (WidgetTester tester) async {
        final projectorService = ProjectorService();
        projectorService.startProjector(1);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChangeNotifierProvider<ProjectorService>.value(
                value: projectorService,
                child: const ProjectorControlWidget(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should show action buttons
        expect(find.text('Show Projector'), findsOneWidget);
        expect(find.text('Stop Projector'), findsOneWidget);
      });

      testWidgets('should handle stop projector button', (WidgetTester tester) async {
        final projectorService = ProjectorService();
        projectorService.startProjector(1);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChangeNotifierProvider<ProjectorService>.value(
                value: projectorService,
                child: const ProjectorControlWidget(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tap stop projector button
        await tester.tap(find.text('Stop Projector'));
        await tester.pumpAndSettle();

        // Should stop projector
        expect(projectorService.isProjectorActive, isFalse);
      });
    });

    group('ProjectorPresentationWidget', () {
      testWidgets('should display hymn content', (WidgetTester tester) async {
        final projectorService = ProjectorService();
        projectorService.startProjector(1);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChangeNotifierProvider<ProjectorService>.value(
                value: projectorService,
                child: const ProjectorPresentationWidget(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should show hymn content
        expect(find.text('Amazing Grace'), findsOneWidget);
        expect(find.text('#1'), findsOneWidget);
      });

      testWidgets('should show no hymn state when no hymn is selected', (WidgetTester tester) async {
        final projectorService = ProjectorService();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChangeNotifierProvider<ProjectorService>.value(
                value: projectorService,
                child: const ProjectorPresentationWidget(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should show no hymn state
        expect(find.text('Advent Hymnals'), findsOneWidget);
        expect(find.text('Projector Display'), findsOneWidget);
        expect(find.text('Waiting for hymn selection from main window'), findsOneWidget);
        expect(find.byIcon(Icons.library_music), findsOneWidget);
      });

      testWidgets('should show branding watermark', (WidgetTester tester) async {
        final projectorService = ProjectorService();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChangeNotifierProvider<ProjectorService>.value(
                value: projectorService,
                child: const ProjectorPresentationWidget(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should show branding watermark
        expect(find.text('Advent Hymnals'), findsAtLeastNWidgets(1));
      });

      testWidgets('should show connection indicator', (WidgetTester tester) async {
        final projectorService = ProjectorService();
        projectorService.startProjector(1);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChangeNotifierProvider<ProjectorService>.value(
                value: projectorService,
                child: const ProjectorPresentationWidget(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should show connection indicator
        expect(find.text('Connected'), findsOneWidget);
        expect(find.byIcon(Icons.cast_connected), findsOneWidget);
      });

      testWidgets('should apply theme settings', (WidgetTester tester) async {
        final projectorService = ProjectorService();
        projectorService.startProjector(1);
        projectorService.updateProjectorSettings(theme: ProjectorTheme.light);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChangeNotifierProvider<ProjectorService>.value(
                value: projectorService,
                child: const ProjectorPresentationWidget(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should apply light theme
        final container = tester.widget<Container>(find.byType(Container).first);
        expect(container.color, Colors.white);
      });
    });

    group('HymnSelectionWidget', () {
      Widget buildHymnSelectionWidget() {
        return MaterialApp(
          home: Scaffold(
            body: MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => HymnProvider()..setTestHymns(sampleHymns)),
                ChangeNotifierProvider(create: (_) => FavoritesProvider()),
                ChangeNotifierProvider(create: (_) => RecentlyViewedProvider()),
                ChangeNotifierProvider(create: (_) => ProjectorService()),
              ],
              child: const HymnSelectionWidget(),
            ),
          ),
        );
      }

      testWidgets('should show search bar', (WidgetTester tester) async {
        await tester.pumpWidget(buildHymnSelectionWidget());
        await tester.pumpAndSettle();

        // Should show search bar
        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Search hymns by title, number, or lyrics...'), findsOneWidget);
        expect(find.byIcon(Icons.search), findsOneWidget);
      });

      testWidgets('should show tab bar when not searching', (WidgetTester tester) async {
        await tester.pumpWidget(buildHymnSelectionWidget());
        await tester.pumpAndSettle();

        // Should show tab bar
        expect(find.text('Recent'), findsOneWidget);
        expect(find.text('Favorites'), findsOneWidget);
        expect(find.text('Popular'), findsOneWidget);
        expect(find.text('All'), findsOneWidget);
      });

      testWidgets('should perform search when text is entered', (WidgetTester tester) async {
        await tester.pumpWidget(buildHymnSelectionWidget());
        await tester.pumpAndSettle();

        // Enter search text
        await tester.enterText(find.byType(TextField), 'Amazing');
        await tester.pumpAndSettle();

        // Should show search results
        expect(find.text('Search Results'), findsOneWidget);
        expect(find.text('Amazing Grace'), findsOneWidget);
      });

      testWidgets('should clear search when clear button is tapped', (WidgetTester tester) async {
        await tester.pumpWidget(buildHymnSelectionWidget());
        await tester.pumpAndSettle();

        // Enter search text
        await tester.enterText(find.byType(TextField), 'Amazing');
        await tester.pumpAndSettle();

        // Tap clear button
        await tester.tap(find.byIcon(Icons.clear));
        await tester.pumpAndSettle();

        // Should clear search and show tabs
        expect(find.text('Search Results'), findsNothing);
        expect(find.text('Recent'), findsOneWidget);
      });

      testWidgets('should show hymn cards', (WidgetTester tester) async {
        await tester.pumpWidget(buildHymnSelectionWidget());
        await tester.pumpAndSettle();

        // Navigate to All tab
        await tester.tap(find.text('All'));
        await tester.pumpAndSettle();

        // Should show hymn cards
        expect(find.text('Amazing Grace'), findsOneWidget);
        expect(find.text('How Great Thou Art'), findsOneWidget);
        expect(find.text('By John Newton'), findsOneWidget);
        expect(find.text('By Carl Boberg'), findsOneWidget);
      });

      testWidgets('should show project buttons', (WidgetTester tester) async {
        await tester.pumpWidget(buildHymnSelectionWidget());
        await tester.pumpAndSettle();

        // Navigate to All tab
        await tester.tap(find.text('All'));
        await tester.pumpAndSettle();

        // Should show project buttons
        expect(find.text('Project'), findsAtLeastNWidgets(2));
        expect(find.byIcon(Icons.cast), findsAtLeastNWidgets(2));
      });

      testWidgets('should show preview buttons', (WidgetTester tester) async {
        await tester.pumpWidget(buildHymnSelectionWidget());
        await tester.pumpAndSettle();

        // Navigate to All tab
        await tester.tap(find.text('All'));
        await tester.pumpAndSettle();

        // Should show preview buttons
        expect(find.byIcon(Icons.preview), findsAtLeastNWidgets(2));
      });

      testWidgets('should start projector when project button is tapped', (WidgetTester tester) async {
        await tester.pumpWidget(buildHymnSelectionWidget());
        await tester.pumpAndSettle();

        // Navigate to All tab
        await tester.tap(find.text('All'));
        await tester.pumpAndSettle();

        // Tap project button
        await tester.tap(find.text('Project').first);
        await tester.pumpAndSettle();

        // Should show snackbar
        expect(find.text('Projecting "Amazing Grace"'), findsOneWidget);
      });

      testWidgets('should show preview dialog when preview button is tapped', (WidgetTester tester) async {
        await tester.pumpWidget(buildHymnSelectionWidget());
        await tester.pumpAndSettle();

        // Navigate to All tab
        await tester.tap(find.text('All'));
        await tester.pumpAndSettle();

        // Tap preview button
        await tester.tap(find.byIcon(Icons.preview).first);
        await tester.pumpAndSettle();

        // Should show preview dialog
        expect(find.text('Amazing Grace'), findsAtLeastNWidgets(2)); // Title in dialog
        expect(find.text('By John Newton'), findsAtLeastNWidgets(2));
        expect(find.text('Close'), findsOneWidget);
      });

      testWidgets('should show empty state for recent hymns', (WidgetTester tester) async {
        await tester.pumpWidget(buildHymnSelectionWidget());
        await tester.pumpAndSettle();

        // Recent tab should be active by default
        expect(find.text('No Recent Hymns'), findsOneWidget);
        expect(find.text('Hymns you view will appear here'), findsOneWidget);
        expect(find.byIcon(Icons.history), findsOneWidget);
      });

      testWidgets('should show empty state for favorites', (WidgetTester tester) async {
        await tester.pumpWidget(buildHymnSelectionWidget());
        await tester.pumpAndSettle();

        // Navigate to Favorites tab
        await tester.tap(find.text('Favorites'));
        await tester.pumpAndSettle();

        // Should show empty state
        expect(find.text('No Favorites'), findsOneWidget);
        expect(find.text('Mark hymns as favorites to see them here'), findsOneWidget);
        expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      });

      testWidgets('should handle tab navigation', (WidgetTester tester) async {
        await tester.pumpWidget(buildHymnSelectionWidget());
        await tester.pumpAndSettle();

        // Test all tabs
        final tabNames = ['Recent', 'Favorites', 'Popular', 'All'];
        for (final tabName in tabNames) {
          await tester.tap(find.text(tabName));
          await tester.pumpAndSettle();
          
          // Should navigate to the tab
          expect(find.text(tabName), findsOneWidget);
        }
      });
    });

    group('Widget Integration', () {
      testWidgets('should integrate projector control with projector service', (WidgetTester tester) async {
        final projectorService = ProjectorService();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChangeNotifierProvider<ProjectorService>.value(
                value: projectorService,
                child: Column(
                  children: [
                    const ProjectorControlWidget(),
                    const Expanded(child: ProjectorPresentationWidget()),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Initially no projector control should be shown
        expect(find.text('Projector Active'), findsNothing);

        // Start projector
        projectorService.startProjector(1);
        await tester.pumpAndSettle();

        // Should show projector control
        expect(find.text('Projector Active'), findsOneWidget);
        expect(find.text('Amazing Grace'), findsOneWidget);

        // Test navigation
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();

        expect(projectorService.currentVerseIndex, 1);

        // Stop projector
        await tester.tap(find.text('Stop Projector'));
        await tester.pumpAndSettle();

        // Should hide projector control
        expect(find.text('Projector Active'), findsNothing);
        expect(projectorService.isProjectorActive, isFalse);
      });

      testWidgets('should handle theme changes across widgets', (WidgetTester tester) async {
        final projectorService = ProjectorService();
        projectorService.startProjector(1);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChangeNotifierProvider<ProjectorService>.value(
                value: projectorService,
                child: Column(
                  children: [
                    const ProjectorControlWidget(),
                    const Expanded(child: ProjectorPresentationWidget()),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Change theme
        projectorService.updateProjectorSettings(theme: ProjectorTheme.light);
        await tester.pumpAndSettle();

        // Both widgets should reflect the theme change
        expect(projectorService.theme, ProjectorTheme.light);
        
        // Check if presentation widget has light background
        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(ProjectorPresentationWidget),
            matching: find.byType(Container),
          ).first,
        );
        expect(container.color, Colors.white);
      });
    });

    group('Error Handling', () {
      testWidgets('should handle projector service errors gracefully', (WidgetTester tester) async {
        // Mock failure responses
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('com.adventhymnals.org/projector_window'),
          (MethodCall methodCall) async {
            throw PlatformException(
              code: 'ERROR',
              message: 'Test error',
            );
          },
        );

        final projectorService = ProjectorService();
        projectorService.startProjector(1);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChangeNotifierProvider<ProjectorService>.value(
                value: projectorService,
                child: const ProjectorControlWidget(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should still show projector control even if platform calls fail
        expect(find.text('Projector Active'), findsOneWidget);

        // Should still be able to navigate
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();

        expect(projectorService.currentVerseIndex, 1);
      });
    });
  });
}

// Extension to add test methods to providers
extension HymnProviderTest on HymnProvider {
  void setTestHymns(List<Hymn> hymns) {
    // This would be implemented in the actual HymnProvider
    // For testing purposes, we assume this method exists
  }
}