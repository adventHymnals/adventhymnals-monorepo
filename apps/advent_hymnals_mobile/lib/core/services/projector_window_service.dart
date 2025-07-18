import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service for managing secondary projector windows on desktop platforms
class ProjectorWindowService {
  static final ProjectorWindowService _instance = ProjectorWindowService._internal();
  static ProjectorWindowService get instance => _instance;
  ProjectorWindowService._internal();

  static const MethodChannel _channel = MethodChannel('com.adventhymnals.org/projector_window');
  
  bool _isInitialized = false;
  bool _isSecondaryWindowOpen = false;
  String? _lastError;
  List<MonitorInfo> _availableMonitors = [];
  
  /// Initialize the projector window service
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      // Only initialize on desktop platforms
      if (!(Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        if (kDebugMode) {
          print('🖥️ [ProjectorWindowService] Not a desktop platform, skipping initialization');
        }
        return false;
      }
      
      // Test if platform channel is available
      final result = await _channel.invokeMethod('initialize');
      _isInitialized = result == true;
      
      if (_isInitialized) {
        await _refreshMonitorList();
        if (kDebugMode) {
          print('✅ [ProjectorWindowService] Successfully initialized');
        }
      }
      
      return _isInitialized;
    } catch (e) {
      _lastError = 'Failed to initialize projector window service: ${e.toString()}';
      if (kDebugMode) {
        print('ℹ️ [ProjectorWindowService] Initialization failed (platform channel not available): $_lastError');
      }
      return false;
    }
  }
  
  /// Get list of available monitors
  Future<List<MonitorInfo>> getAvailableMonitors() async {
    if (!_isInitialized) {
      await initialize();
    }
    
    if (!_isInitialized) return [];
    
    try {
      await _refreshMonitorList();
      return _availableMonitors;
    } catch (e) {
      _lastError = 'Failed to get monitor list: ${e.toString()}';
      if (kDebugMode) {
        print('ℹ️ [ProjectorWindowService] Monitor detection failed (platform channel not available): $_lastError');
      }
      return [];
    }
  }
  
  /// Refresh the list of available monitors
  Future<void> _refreshMonitorList() async {
    if (!_isInitialized) return;
    
    try {
      final result = await _channel.invokeMethod('getMonitors');
      if (result is List) {
        _availableMonitors = result.map((monitor) => MonitorInfo.fromMap(monitor)).toList();
        if (kDebugMode) {
          print('🖥️ [ProjectorWindowService] Found ${_availableMonitors.length} monitors');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [ProjectorWindowService] Failed to refresh monitor list: $e');
      }
    }
  }
  
  /// Open secondary projector window
  Future<bool> openSecondaryWindow({
    int? monitorIndex,
    bool fullscreen = true,
    int? width,
    int? height,
    int? x,
    int? y,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    if (!_isInitialized) return false;
    
    if (_isSecondaryWindowOpen) {
      if (kDebugMode) {
        print('⚠️ [ProjectorWindowService] Secondary window already open');
      }
      return true;
    }
    
    try {
      final params = <String, dynamic>{
        'fullscreen': fullscreen,
      };
      
      if (monitorIndex != null) {
        params['monitorIndex'] = monitorIndex;
      }
      
      if (!fullscreen) {
        params['width'] = width ?? 1280;
        params['height'] = height ?? 720;
        params['x'] = x ?? 100;
        params['y'] = y ?? 100;
      }
      
      final result = await _channel.invokeMethod('openSecondaryWindow', params);
      _isSecondaryWindowOpen = result == true;
      
      if (_isSecondaryWindowOpen) {
        if (kDebugMode) {
          print('✅ [ProjectorWindowService] Secondary window opened successfully');
        }
      }
      
      return _isSecondaryWindowOpen;
    } catch (e) {
      _lastError = 'Failed to open secondary window: ${e.toString()}';
      if (kDebugMode) {
        print('❌ [ProjectorWindowService] Failed to open secondary window: $_lastError');
      }
      return false;
    }
  }
  
  /// Close secondary projector window
  Future<bool> closeSecondaryWindow() async {
    if (!_isInitialized || !_isSecondaryWindowOpen) {
      return true;
    }
    
    try {
      final result = await _channel.invokeMethod('closeSecondaryWindow');
      _isSecondaryWindowOpen = !(result == true);
      
      if (!_isSecondaryWindowOpen) {
        if (kDebugMode) {
          print('✅ [ProjectorWindowService] Secondary window closed successfully');
        }
      }
      
      return !_isSecondaryWindowOpen;
    } catch (e) {
      _lastError = 'Failed to close secondary window: ${e.toString()}';
      if (kDebugMode) {
        print('❌ [ProjectorWindowService] Failed to close secondary window: $_lastError');
      }
      return false;
    }
  }
  
  /// Update secondary window position and size
  Future<bool> updateSecondaryWindow({
    int? width,
    int? height,
    int? x,
    int? y,
    bool? fullscreen,
  }) async {
    if (!_isInitialized || !_isSecondaryWindowOpen) {
      return false;
    }
    
    try {
      final params = <String, dynamic>{};
      
      if (width != null) params['width'] = width;
      if (height != null) params['height'] = height;
      if (x != null) params['x'] = x;
      if (y != null) params['y'] = y;
      if (fullscreen != null) params['fullscreen'] = fullscreen;
      
      final result = await _channel.invokeMethod('updateSecondaryWindow', params);
      
      if (result == true) {
        if (kDebugMode) {
          print('✅ [ProjectorWindowService] Secondary window updated successfully');
        }
      }
      
      return result == true;
    } catch (e) {
      _lastError = 'Failed to update secondary window: ${e.toString()}';
      if (kDebugMode) {
        print('❌ [ProjectorWindowService] Failed to update secondary window: $_lastError');
      }
      return false;
    }
  }
  
  /// Move secondary window to specific monitor
  Future<bool> moveToMonitor(int monitorIndex) async {
    if (!_isInitialized || !_isSecondaryWindowOpen) {
      return false;
    }
    
    if (monitorIndex >= _availableMonitors.length || monitorIndex < 0) {
      _lastError = 'Invalid monitor index: $monitorIndex';
      return false;
    }
    
    try {
      final result = await _channel.invokeMethod('moveToMonitor', {'monitorIndex': monitorIndex});
      
      if (result == true) {
        if (kDebugMode) {
          print('✅ [ProjectorWindowService] Window moved to monitor $monitorIndex');
        }
      }
      
      return result == true;
    } catch (e) {
      _lastError = 'Failed to move window to monitor: ${e.toString()}';
      if (kDebugMode) {
        print('❌ [ProjectorWindowService] Failed to move to monitor: $_lastError');
      }
      return false;
    }
  }
  
  /// Set secondary window to fullscreen on specific monitor
  Future<bool> setFullscreenOnMonitor(int monitorIndex) async {
    if (!_isInitialized || !_isSecondaryWindowOpen) {
      return false;
    }
    
    try {
      final result = await _channel.invokeMethod('setFullscreenOnMonitor', {
        'monitorIndex': monitorIndex,
      });
      
      if (result == true) {
        if (kDebugMode) {
          print('✅ [ProjectorWindowService] Fullscreen set on monitor $monitorIndex');
        }
      }
      
      return result == true;
    } catch (e) {
      _lastError = 'Failed to set fullscreen on monitor: ${e.toString()}';
      if (kDebugMode) {
        print('❌ [ProjectorWindowService] Failed to set fullscreen: $_lastError');
      }
      return false;
    }
  }
  
  /// Send content update to secondary window
  Future<bool> updateContent(Map<String, dynamic> content) async {
    if (!_isInitialized || !_isSecondaryWindowOpen) {
      return false;
    }
    
    try {
      final result = await _channel.invokeMethod('updateContent', content);
      return result == true;
    } catch (e) {
      _lastError = 'Failed to update content: ${e.toString()}';
      if (kDebugMode) {
        print('❌ [ProjectorWindowService] Failed to update content: $_lastError');
      }
      return false;
    }
  }
  
  /// Check if secondary window is open
  bool get isSecondaryWindowOpen => _isSecondaryWindowOpen;
  
  /// Check if service is initialized
  bool get isInitialized => _isInitialized;
  
  /// Get last error message
  String? get lastError => _lastError;
  
  /// Get available monitors
  List<MonitorInfo> get availableMonitors => _availableMonitors;
  
  /// Check if multiple monitors are available
  bool get hasMultipleMonitors => _availableMonitors.length > 1;
  
  /// Get primary monitor
  MonitorInfo? get primaryMonitor {
    try {
      return _availableMonitors.firstWhere((monitor) => monitor.isPrimary);
    } catch (e) {
      return _availableMonitors.isNotEmpty ? _availableMonitors.first : null;
    }
  }
  
  /// Get secondary monitors (non-primary)
  List<MonitorInfo> get secondaryMonitors {
    return _availableMonitors.where((monitor) => !monitor.isPrimary).toList();
  }
  
  /// Run diagnostics on the projector window service
  Future<Map<String, dynamic>> runDiagnostics() async {
    final results = <String, dynamic>{
      'platform': Platform.operatingSystem,
      'isDesktop': Platform.isWindows || Platform.isLinux || Platform.isMacOS,
      'initialized': false,
      'monitorsDetected': 0,
      'canOpenWindow': false,
      'canCloseWindow': false,
      'hasMultipleMonitors': false,
      'errors': <String>[],
    };
    
    try {
      // Test initialization
      results['initialized'] = await initialize();
      if (!results['initialized']) {
        results['errors'].add('Failed to initialize projector window service');
        return results;
      }
      
      // Test monitor detection
      final monitors = await getAvailableMonitors();
      results['monitorsDetected'] = monitors.length;
      results['hasMultipleMonitors'] = monitors.length > 1;
      
      if (monitors.isEmpty) {
        results['errors'].add('No monitors detected');
        return results;
      }
      
      // Test window opening
      results['canOpenWindow'] = await openSecondaryWindow(
        monitorIndex: 0,
        fullscreen: false,
        width: 400,
        height: 300,
      );
      
      if (!results['canOpenWindow']) {
        results['errors'].add('Failed to open secondary window');
        return results;
      }
      
      // Test window closing
      await Future.delayed(const Duration(milliseconds: 500));
      results['canCloseWindow'] = await closeSecondaryWindow();
      
      if (!results['canCloseWindow']) {
        results['errors'].add('Failed to close secondary window');
      }
      
    } catch (e) {
      results['errors'].add('Diagnostic test failed: ${e.toString()}');
    }
    
    return results;
  }
  
  /// Dispose of resources
  Future<void> dispose() async {
    try {
      if (_isSecondaryWindowOpen) {
        await closeSecondaryWindow();
      }
      
      _isInitialized = false;
      _isSecondaryWindowOpen = false;
      _lastError = null;
      _availableMonitors.clear();
      
      if (kDebugMode) {
        print('✅ [ProjectorWindowService] Disposed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [ProjectorWindowService] Dispose error: $e');
      }
    }
  }
}

/// Information about a monitor/display
class MonitorInfo {
  final int index;
  final String name;
  final int width;
  final int height;
  final int x;
  final int y;
  final bool isPrimary;
  final double scaleFactor;
  
  const MonitorInfo({
    required this.index,
    required this.name,
    required this.width,
    required this.height,
    required this.x,
    required this.y,
    required this.isPrimary,
    required this.scaleFactor,
  });
  
  factory MonitorInfo.fromMap(Map<dynamic, dynamic> map) {
    return MonitorInfo(
      index: map['index'] ?? 0,
      name: map['name'] ?? 'Unknown Monitor',
      width: map['width'] ?? 1920,
      height: map['height'] ?? 1080,
      x: map['x'] ?? 0,
      y: map['y'] ?? 0,
      isPrimary: map['isPrimary'] ?? false,
      scaleFactor: (map['scaleFactor'] ?? 1.0).toDouble(),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'index': index,
      'name': name,
      'width': width,
      'height': height,
      'x': x,
      'y': y,
      'isPrimary': isPrimary,
      'scaleFactor': scaleFactor,
    };
  }
  
  @override
  String toString() {
    return 'MonitorInfo(index: $index, name: $name, size: ${width}x$height, '
           'position: ($x, $y), primary: $isPrimary, scale: $scaleFactor)';
  }
}