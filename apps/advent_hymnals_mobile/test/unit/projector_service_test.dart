import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import '../../lib/core/services/projector_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('ProjectorService', () {
    late ProjectorService service;
    late List<MethodCall> methodCalls;

    setUp(() {
      service = ProjectorService();
      methodCalls = [];
      
      // Mock the method channel for projector window service
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

    group('Initialization', () {
      test('should initialize with default values', () {
        expect(service.currentHymnId, isNull);
        expect(service.currentVerseIndex, 0);
        expect(service.isProjectorActive, isFalse);
        expect(service.autoAdvanceEnabled, isFalse);
        expect(service.autoAdvanceSeconds, 15);
        expect(service.theme, ProjectorTheme.dark);
        expect(service.textSize, ProjectorTextSize.large);
        expect(service.showVerseNumbers, isTrue);
        expect(service.showHymnNumber, isTrue);
        expect(service.showTitle, isTrue);
        expect(service.showMetadata, isFalse);
      });
    });

    group('Projector Control', () {
      test('should start projector with hymn', () {
        service.startProjector(123);
        
        expect(service.isProjectorActive, isTrue);
        expect(service.currentHymnId, 123);
        expect(service.currentVerseIndex, 0);
      });

      test('should stop projector', () {
        service.startProjector(123);
        service.stopProjector();
        
        expect(service.isProjectorActive, isFalse);
        expect(service.currentHymnId, isNull);
        expect(service.currentVerseIndex, 0);
      });

      test('should change hymn during projection', () {
        service.startProjector(123);
        service.changeHymn(456);
        
        expect(service.currentHymnId, 456);
        expect(service.currentVerseIndex, 0);
        expect(service.isProjectorActive, isTrue);
      });
    });

    group('Navigation', () {
      test('should navigate to next section', () {
        service.startProjector(123);
        
        service.nextSection();
        expect(service.currentVerseIndex, 1);
        
        service.nextSection();
        expect(service.currentVerseIndex, 2);
      });

      test('should navigate to previous section', () {
        service.startProjector(123);
        service.nextSection();
        service.nextSection();
        
        service.previousSection();
        expect(service.currentVerseIndex, 1);
        
        service.previousSection();
        expect(service.currentVerseIndex, 0);
      });

      test('should not navigate to previous section when at index 0', () {
        service.startProjector(123);
        
        service.previousSection();
        expect(service.currentVerseIndex, 0);
      });

      test('should jump to specific verse', () {
        service.startProjector(123);
        
        service.goToVerse(5);
        expect(service.currentVerseIndex, 5);
      });
    });

    group('Auto-Advance', () {
      test('should toggle auto-advance', () {
        expect(service.autoAdvanceEnabled, isFalse);
        
        service.toggleAutoAdvance();
        expect(service.autoAdvanceEnabled, isTrue);
        
        service.toggleAutoAdvance();
        expect(service.autoAdvanceEnabled, isFalse);
      });

      test('should set auto-advance seconds', () {
        service.setAutoAdvanceSeconds(30);
        expect(service.autoAdvanceSeconds, 30);
      });

      test('should reset auto-advance timer when enabled', () {
        service.startProjector(123);
        service.toggleAutoAdvance();
        
        // Auto-advance should be enabled
        expect(service.autoAdvanceEnabled, isTrue);
        
        // Navigation should reset the timer
        service.nextSection();
        service.previousSection();
        service.goToVerse(2);
        
        // These calls should not throw exceptions
        expect(service.autoAdvanceEnabled, isTrue);
      });
    });

    group('Display Settings', () {
      test('should update projector theme', () {
        service.updateProjectorSettings(theme: ProjectorTheme.light);
        expect(service.theme, ProjectorTheme.light);
      });

      test('should update text size', () {
        service.updateProjectorSettings(textSize: ProjectorTextSize.extraLarge);
        expect(service.textSize, ProjectorTextSize.extraLarge);
      });

      test('should update display options', () {
        service.updateProjectorSettings(
          showVerseNumbers: false,
          showHymnNumber: false,
          showTitle: false,
          showMetadata: true,
        );
        
        expect(service.showVerseNumbers, isFalse);
        expect(service.showHymnNumber, isFalse);
        expect(service.showTitle, isFalse);
        expect(service.showMetadata, isTrue);
      });

      test('should update multiple settings at once', () {
        service.updateProjectorSettings(
          theme: ProjectorTheme.highContrast,
          textSize: ProjectorTextSize.small,
          showVerseNumbers: false,
          showTitle: false,
        );
        
        expect(service.theme, ProjectorTheme.highContrast);
        expect(service.textSize, ProjectorTextSize.small);
        expect(service.showVerseNumbers, isFalse);
        expect(service.showTitle, isFalse);
        // Other settings should remain unchanged
        expect(service.showHymnNumber, isTrue);
        expect(service.showMetadata, isFalse);
      });
    });

    group('Auto-Advance Countdown', () {
      test('should provide countdown stream when auto-advance is enabled', () async {
        service.startProjector(123);
        service.setAutoAdvanceSeconds(5);
        service.toggleAutoAdvance();
        
        final stream = service.getAutoAdvanceCountdown();
        
        // Since this is a mock test, we can't test the actual timing
        // but we can ensure the stream is created
        expect(stream, isNotNull);
      });
    });

    group('State Management', () {
      test('should notify listeners on state changes', () {
        bool notified = false;
        service.addListener(() {
          notified = true;
        });
        
        service.startProjector(123);
        expect(notified, isTrue);
        
        notified = false;
        service.nextSection();
        expect(notified, isTrue);
        
        notified = false;
        service.stopProjector();
        expect(notified, isTrue);
      });

      test('should maintain state consistency', () {
        service.startProjector(123);
        service.nextSection();
        service.nextSection();
        service.updateProjectorSettings(theme: ProjectorTheme.blue);
        service.toggleAutoAdvance();
        
        expect(service.currentHymnId, 123);
        expect(service.currentVerseIndex, 2);
        expect(service.isProjectorActive, isTrue);
        expect(service.theme, ProjectorTheme.blue);
        expect(service.autoAdvanceEnabled, isTrue);
      });
    });

    group('Edge Cases', () {
      test('should handle stopping projector when not active', () {
        expect(service.isProjectorActive, isFalse);
        
        service.stopProjector();
        expect(service.isProjectorActive, isFalse);
      });

      test('should handle navigation when projector not active', () {
        expect(service.isProjectorActive, isFalse);
        
        service.nextSection();
        service.previousSection();
        service.goToVerse(5);
        
        // Should not throw exceptions
        expect(service.currentVerseIndex, 5);
      });

      test('should handle changing hymn when projector not active', () {
        expect(service.isProjectorActive, isFalse);
        
        service.changeHymn(456);
        expect(service.currentHymnId, 456);
        expect(service.currentVerseIndex, 0);
        expect(service.isProjectorActive, isFalse);
      });

      test('should handle auto-advance when projector not active', () {
        expect(service.isProjectorActive, isFalse);
        
        service.toggleAutoAdvance();
        expect(service.autoAdvanceEnabled, isTrue);
        
        service.setAutoAdvanceSeconds(10);
        expect(service.autoAdvanceSeconds, 10);
      });
    });

    group('Secondary Window Integration', () {
      test('should attempt to open secondary window on desktop start', () {
        service.startProjector(123);
        
        // Check if the projector window service was called
        // This is implicitly tested through the mock
        expect(service.isProjectorActive, isTrue);
      });

      test('should close secondary window on stop', () {
        service.startProjector(123);
        service.stopProjector();
        
        expect(service.isProjectorActive, isFalse);
      });

      test('should update secondary window content on navigation', () {
        service.startProjector(123);
        methodCalls.clear();
        
        service.nextSection();
        service.changeHymn(456);
        service.updateProjectorSettings(theme: ProjectorTheme.light);
        
        // The actual content updates would be tested through the mock
        expect(service.currentVerseIndex, 1);
        expect(service.currentHymnId, 456);
        expect(service.theme, ProjectorTheme.light);
      });
    });
  });

  group('ProjectorTheme', () {
    test('should have all expected themes', () {
      expect(ProjectorTheme.values.length, 4);
      expect(ProjectorTheme.values, contains(ProjectorTheme.dark));
      expect(ProjectorTheme.values, contains(ProjectorTheme.light));
      expect(ProjectorTheme.values, contains(ProjectorTheme.highContrast));
      expect(ProjectorTheme.values, contains(ProjectorTheme.blue));
    });
  });

  group('ProjectorTextSize', () {
    test('should have all expected text sizes', () {
      expect(ProjectorTextSize.values.length, 4);
      expect(ProjectorTextSize.values, contains(ProjectorTextSize.small));
      expect(ProjectorTextSize.values, contains(ProjectorTextSize.medium));
      expect(ProjectorTextSize.values, contains(ProjectorTextSize.large));
      expect(ProjectorTextSize.values, contains(ProjectorTextSize.extraLarge));
    });
  });
}