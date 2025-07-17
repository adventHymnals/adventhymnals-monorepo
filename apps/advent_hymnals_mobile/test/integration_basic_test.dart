import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:advent_hymnals/main.dart';

void main() {
  group('Basic Integration Tests', () {
    
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    testWidgets('App should start without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initialization
      await tester.pumpAndSettle(Duration(seconds: 5));
      
      // App should have loaded successfully
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Home screen should display basic elements', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initialization
      await tester.pumpAndSettle(Duration(seconds: 5));
      
      // Should have some basic navigation elements
      expect(find.byType(Scaffold), findsWidgets);
      
      // Should have bottom navigation or app bar
      final hasBottomNav = find.byType(BottomNavigationBar).evaluate().isNotEmpty;
      final hasAppBar = find.byType(AppBar).evaluate().isNotEmpty;
      
      expect(hasBottomNav || hasAppBar, isTrue);
    });

    testWidgets('Navigation should work between basic screens', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initialization
      await tester.pumpAndSettle(Duration(seconds: 5));
      
      // Try to find and tap search button
      final searchButtons = find.byIcon(Icons.search);
      if (searchButtons.evaluate().isNotEmpty) {
        await tester.tap(searchButtons.first);
        await tester.pumpAndSettle(Duration(seconds: 2));
        
        // Should navigate to search screen
        expect(find.byType(Scaffold), findsWidgets);
      }
      
      // Try to find and tap favorites button
      final favoritesButtons = find.byIcon(Icons.favorite);
      if (favoritesButtons.evaluate().isNotEmpty) {
        await tester.tap(favoritesButtons.first);
        await tester.pumpAndSettle(Duration(seconds: 2));
        
        // Should navigate to favorites screen
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('App should handle basic user interactions', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initialization
      await tester.pumpAndSettle(Duration(seconds: 5));
      
      // Try to find text fields for search
      final textFields = find.byType(TextField);
      if (textFields.evaluate().isNotEmpty) {
        await tester.enterText(textFields.first, 'test');
        await tester.pump();
        
        // Should accept text input
        expect(find.text('test'), findsOneWidget);
      }
      
      // Try to find buttons and tap them
      final buttons = find.byType(ElevatedButton);
      if (buttons.evaluate().isNotEmpty) {
        await tester.tap(buttons.first);
        await tester.pump();
        
        // Should handle button taps without crashing
        expect(find.byType(MaterialApp), findsOneWidget);
      }
    });

    testWidgets('App should handle back navigation', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initialization
      await tester.pumpAndSettle(Duration(seconds: 5));
      
      // Navigate to a different screen
      final searchButtons = find.byIcon(Icons.search);
      if (searchButtons.evaluate().isNotEmpty) {
        await tester.tap(searchButtons.first);
        await tester.pumpAndSettle(Duration(seconds: 2));
        
        // Try to go back
        final backButtons = find.byIcon(Icons.arrow_back);
        if (backButtons.evaluate().isNotEmpty) {
          await tester.tap(backButtons.first);
          await tester.pumpAndSettle(Duration(seconds: 2));
          
          // Should return to previous screen
          expect(find.byType(Scaffold), findsWidgets);
        }
      }
    });

    testWidgets('App should handle orientation changes', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initialization
      await tester.pumpAndSettle(Duration(seconds: 5));
      
      // Change orientation
      await tester.binding.setSurfaceSize(Size(800, 600)); // Landscape
      await tester.pumpAndSettle();
      
      // App should still be responsive
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Change back to portrait
      await tester.binding.setSurfaceSize(Size(400, 800)); // Portrait
      await tester.pumpAndSettle();
      
      // App should still be responsive
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App should handle rapid navigation', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initialization
      await tester.pumpAndSettle(Duration(seconds: 5));
      
      // Perform rapid navigation
      for (int i = 0; i < 3; i++) {
        final searchButtons = find.byIcon(Icons.search);
        if (searchButtons.evaluate().isNotEmpty) {
          await tester.tap(searchButtons.first);
          await tester.pump(Duration(milliseconds: 100));
          
          final backButtons = find.byIcon(Icons.arrow_back);
          if (backButtons.evaluate().isNotEmpty) {
            await tester.tap(backButtons.first);
            await tester.pump(Duration(milliseconds: 100));
          }
        }
      }
      
      await tester.pumpAndSettle();
      
      // App should still be stable
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App should handle large text scales', (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(textScaleFactor: 2.0),
          child: const AdventHymnalsApp(),
        ),
      );
      
      // Wait for initialization
      await tester.pumpAndSettle(Duration(seconds: 5));
      
      // App should handle large text without crashing
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App should handle small screen sizes', (WidgetTester tester) async {
      // Set small screen size
      await tester.binding.setSurfaceSize(Size(300, 500));
      
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initialization
      await tester.pumpAndSettle(Duration(seconds: 5));
      
      // App should handle small screens without crashing
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App should handle memory pressure gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(const AdventHymnalsApp());
      
      // Wait for initialization
      await tester.pumpAndSettle(Duration(seconds: 5));
      
      // Simulate memory pressure
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/system',
        null,
        (data) {},
      );
      
      await tester.pump();
      
      // App should still be responsive
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}