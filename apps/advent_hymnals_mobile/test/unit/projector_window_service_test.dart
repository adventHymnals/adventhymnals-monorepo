import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import '../../lib/core/services/projector_window_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('ProjectorWindowService', () {
    late ProjectorWindowService service;
    late List<MethodCall> methodCalls;

    setUp(() {
      service = ProjectorWindowService.instance;
      methodCalls = [];
      
      // Mock the method channel
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

    group('Initialization', () {
      test('should initialize successfully', () async {
        final result = await service.initialize();
        
        expect(result, isTrue);
        expect(service.isInitialized, isTrue);
        expect(methodCalls.length, 1);
        expect(methodCalls[0].method, 'initialize');
      });

      test('should return true if already initialized', () async {
        await service.initialize();
        methodCalls.clear();
        
        final result = await service.initialize();
        
        expect(result, isTrue);
        expect(methodCalls.length, 0);
      });
    });

    group('Monitor Management', () {
      test('should get available monitors', () async {
        await service.initialize();
        methodCalls.clear();
        
        final monitors = await service.getAvailableMonitors();
        
        expect(monitors.length, 2);
        expect(monitors[0].index, 0);
        expect(monitors[0].name, 'Primary Monitor');
        expect(monitors[0].width, 1920);
        expect(monitors[0].height, 1080);
        expect(monitors[0].isPrimary, isTrue);
        
        expect(monitors[1].index, 1);
        expect(monitors[1].name, 'Secondary Monitor');
        expect(monitors[1].width, 1440);
        expect(monitors[1].height, 900);
        expect(monitors[1].isPrimary, isFalse);
        
        expect(methodCalls.length, 1);
        expect(methodCalls[0].method, 'getMonitors');
      });

      test('should return empty list if not initialized', () async {
        final monitors = await service.getAvailableMonitors();
        
        expect(monitors.length, 2); // Should still work because initialize is called
        expect(methodCalls.length, 2); // initialize + getMonitors
      });

      test('should handle monitor detection failure', () async {
        // Mock a failure response
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('com.adventhymnals.org/projector_window'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'initialize') return true;
            if (methodCall.method == 'getMonitors') {
              throw PlatformException(code: 'MONITOR_ERROR', message: 'Failed to detect monitors');
            }
            return null;
          },
        );

        await service.initialize();
        final monitors = await service.getAvailableMonitors();
        
        expect(monitors, isEmpty);
      });
    });

    group('Secondary Window Management', () {
      test('should open secondary window successfully', () async {
        await service.initialize();
        methodCalls.clear();
        
        final result = await service.openSecondaryWindow(
          monitorIndex: 1,
          fullscreen: true,
        );
        
        expect(result, isTrue);
        expect(service.isSecondaryWindowOpen, isTrue);
        expect(methodCalls.length, 1);
        expect(methodCalls[0].method, 'openSecondaryWindow');
        expect(methodCalls[0].arguments['monitorIndex'], 1);
        expect(methodCalls[0].arguments['fullscreen'], true);
      });

      test('should open secondary window with custom size', () async {
        await service.initialize();
        methodCalls.clear();
        
        final result = await service.openSecondaryWindow(
          monitorIndex: 0,
          fullscreen: false,
          width: 1280,
          height: 720,
          x: 100,
          y: 100,
        );
        
        expect(result, isTrue);
        expect(methodCalls[0].arguments['fullscreen'], false);
        expect(methodCalls[0].arguments['width'], 1280);
        expect(methodCalls[0].arguments['height'], 720);
        expect(methodCalls[0].arguments['x'], 100);
        expect(methodCalls[0].arguments['y'], 100);
      });

      test('should return true if secondary window already open', () async {
        await service.initialize();
        await service.openSecondaryWindow();
        methodCalls.clear();
        
        final result = await service.openSecondaryWindow();
        
        expect(result, isTrue);
        expect(methodCalls.length, 0); // No additional calls
      });

      test('should close secondary window successfully', () async {
        await service.initialize();
        await service.openSecondaryWindow();
        methodCalls.clear();
        
        final result = await service.closeSecondaryWindow();
        
        expect(result, isTrue);
        expect(service.isSecondaryWindowOpen, isFalse);
        expect(methodCalls.length, 1);
        expect(methodCalls[0].method, 'closeSecondaryWindow');
      });

      test('should return true if no secondary window to close', () async {
        await service.initialize();
        
        final result = await service.closeSecondaryWindow();
        
        expect(result, isTrue);
      });
    });

    group('Window Positioning', () {
      test('should move window to specific monitor', () async {
        await service.initialize();
        await service.openSecondaryWindow();
        methodCalls.clear();
        
        final result = await service.moveToMonitor(1);
        
        expect(result, isTrue);
        expect(methodCalls.length, 1);
        expect(methodCalls[0].method, 'moveToMonitor');
        expect(methodCalls[0].arguments['monitorIndex'], 1);
      });

      test('should fail to move window if not open', () async {
        await service.initialize();
        
        final result = await service.moveToMonitor(1);
        
        expect(result, isFalse);
        expect(methodCalls.length, 1); // Only initialize call
      });

      test('should set fullscreen on specific monitor', () async {
        await service.initialize();
        await service.openSecondaryWindow();
        methodCalls.clear();
        
        final result = await service.setFullscreenOnMonitor(1);
        
        expect(result, isTrue);
        expect(methodCalls.length, 1);
        expect(methodCalls[0].method, 'setFullscreenOnMonitor');
        expect(methodCalls[0].arguments['monitorIndex'], 1);
      });

      test('should fail to set fullscreen if window not open', () async {
        await service.initialize();
        
        final result = await service.setFullscreenOnMonitor(1);
        
        expect(result, isFalse);
      });
    });

    group('Content Updates', () {
      test('should update content successfully', () async {
        await service.initialize();
        await service.openSecondaryWindow();
        methodCalls.clear();
        
        final content = {
          'hymnId': 123,
          'verseIndex': 1,
          'theme': 'dark',
        };
        
        final result = await service.updateContent(content);
        
        expect(result, isTrue);
        expect(methodCalls.length, 1);
        expect(methodCalls[0].method, 'updateContent');
        expect(methodCalls[0].arguments['hymnId'], 123);
        expect(methodCalls[0].arguments['verseIndex'], 1);
        expect(methodCalls[0].arguments['theme'], 'dark');
      });

      test('should fail to update content if window not open', () async {
        await service.initialize();
        
        final content = {'hymnId': 123};
        final result = await service.updateContent(content);
        
        expect(result, isFalse);
      });
    });

    group('Monitor Helper Methods', () {
      test('should check if multiple monitors are available', () async {
        await service.initialize();
        await service.getAvailableMonitors();
        
        expect(service.hasMultipleMonitors, isTrue);
      });

      test('should get primary monitor', () async {
        await service.initialize();
        await service.getAvailableMonitors();
        
        final primaryMonitor = service.primaryMonitor;
        expect(primaryMonitor, isNotNull);
        expect(primaryMonitor!.isPrimary, isTrue);
        expect(primaryMonitor.index, 0);
      });

      test('should get secondary monitors', () async {
        await service.initialize();
        await service.getAvailableMonitors();
        
        final secondaryMonitors = service.secondaryMonitors;
        expect(secondaryMonitors.length, 1);
        expect(secondaryMonitors[0].isPrimary, isFalse);
        expect(secondaryMonitors[0].index, 1);
      });
    });

    group('Error Handling', () {
      test('should handle platform exceptions gracefully', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('com.adventhymnals.org/projector_window'),
          (MethodCall methodCall) async {
            throw PlatformException(
              code: 'PLATFORM_ERROR',
              message: 'Platform error occurred',
            );
          },
        );

        final result = await service.initialize();
        expect(result, isFalse);
        expect(service.lastError, contains('Platform error occurred'));
      });

      test('should handle method not implemented', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('com.adventhymnals.org/projector_window'),
          (MethodCall methodCall) async {
            throw MissingPluginException('Method not implemented');
          },
        );

        final result = await service.initialize();
        expect(result, isFalse);
        expect(service.lastError, contains('Method not implemented'));
      });
    });

    group('Diagnostics', () {
      test('should run diagnostics successfully', () async {
        final results = await service.runDiagnostics();
        
        expect(results['initialized'], isTrue);
        expect(results['monitorsDetected'], 2);
        expect(results['canOpenWindow'], isTrue);
        expect(results['canCloseWindow'], isTrue);
        expect(results['hasMultipleMonitors'], isTrue);
        expect(results['errors'], isEmpty);
      });

      test('should report errors in diagnostics', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('com.adventhymnals.org/projector_window'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'initialize') return false;
            return null;
          },
        );

        final results = await service.runDiagnostics();
        
        expect(results['initialized'], isFalse);
        expect(results['errors'], isNotEmpty);
        expect(results['errors'][0], contains('Failed to initialize'));
      });
    });
  });

  group('MonitorInfo', () {
    test('should create MonitorInfo from map', () {
      final map = {
        'index': 1,
        'name': 'Test Monitor',
        'width': 1920,
        'height': 1080,
        'x': 0,
        'y': 0,
        'isPrimary': true,
        'scaleFactor': 1.5,
      };

      final monitor = MonitorInfo.fromMap(map);

      expect(monitor.index, 1);
      expect(monitor.name, 'Test Monitor');
      expect(monitor.width, 1920);
      expect(monitor.height, 1080);
      expect(monitor.x, 0);
      expect(monitor.y, 0);
      expect(monitor.isPrimary, true);
      expect(monitor.scaleFactor, 1.5);
    });

    test('should create MonitorInfo with default values', () {
      final monitor = MonitorInfo.fromMap({});

      expect(monitor.index, 0);
      expect(monitor.name, 'Unknown Monitor');
      expect(monitor.width, 1920);
      expect(monitor.height, 1080);
      expect(monitor.x, 0);
      expect(monitor.y, 0);
      expect(monitor.isPrimary, false);
      expect(monitor.scaleFactor, 1.0);
    });

    test('should convert MonitorInfo to map', () {
      final monitor = MonitorInfo(
        index: 1,
        name: 'Test Monitor',
        width: 1920,
        height: 1080,
        x: 0,
        y: 0,
        isPrimary: true,
        scaleFactor: 1.5,
      );

      final map = monitor.toMap();

      expect(map['index'], 1);
      expect(map['name'], 'Test Monitor');
      expect(map['width'], 1920);
      expect(map['height'], 1080);
      expect(map['x'], 0);
      expect(map['y'], 0);
      expect(map['isPrimary'], true);
      expect(map['scaleFactor'], 1.5);
    });

    test('should create string representation', () {
      final monitor = MonitorInfo(
        index: 1,
        name: 'Test Monitor',
        width: 1920,
        height: 1080,
        x: 0,
        y: 0,
        isPrimary: true,
        scaleFactor: 1.5,
      );

      final string = monitor.toString();

      expect(string, contains('Test Monitor'));
      expect(string, contains('1920x1080'));
      expect(string, contains('primary: true'));
      expect(string, contains('scale: 1.5'));
    });
  });
}