import 'dart:ffi' as ffi;
import 'dart:io' show Platform, stdout;
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Windows debugging service for playing sounds and creating debug windows
class WindowsDebugService {
  static const _channel = MethodChannel('windows_debug');
  
  /// Play a system beep sound on Windows
  static Future<void> playDebugSound({int frequency = 800, int duration = 300}) async {
    if (!Platform.isWindows || !kDebugMode) return;
    
    try {
      // Try multiple methods to play sound
      
      // Method 1: System beep via console
      debugPrint('🔊 [DEBUG] Playing sound: freq=$frequency, duration=$duration');
      
      // Method 2: Try Windows API call if available
      if (Platform.isWindows) {
        try {
          final kernel32 = ffi.DynamicLibrary.open('kernel32.dll');
          final beep = kernel32.lookupFunction<
              ffi.Bool Function(ffi.Uint32, ffi.Uint32),
              bool Function(int, int)>('Beep');
          
          beep(frequency, duration);
          debugPrint('🔊 [DEBUG] Windows API beep successful');
        } catch (e) {
          debugPrint('🔊 [DEBUG] Windows API beep failed: $e');
          // Fallback to console bell
          stdout.write('\x07');
        }
      }
    } catch (e) {
      debugPrint('🔊 [DEBUG] Sound failed: $e');
    }
  }
  
  /// Log a debug milestone with sound alert
  static Future<void> debugMilestone(String message, {int soundFreq = 800}) async {
    if (!Platform.isWindows || !kDebugMode) return;
    
    debugPrint('🎯 [DEBUG MILESTONE] $message');
    await playDebugSound(frequency: soundFreq);
  }
  
  /// Create a debug overlay window
  static OverlayEntry? createDebugOverlay(BuildContext context, String message) {
    if (!Platform.isWindows || !kDebugMode) return null;
    
    debugPrint('🪟 [DEBUG OVERLAY] $message');
    
    return OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        right: 50,
        child: Material(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(maxWidth: 300),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bug_report, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Debug Info',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  '${DateTime.now().toIso8601String().substring(11, 19)}',
                  style: TextStyle(color: Colors.grey[400], fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Mixin for adding debug capabilities to StatefulWidgets
mixin WindowsDebugMixin<T extends StatefulWidget> on State<T> {
  List<OverlayEntry> _debugOverlays = [];
  
  @override
  void dispose() {
    _clearDebugOverlays();
    super.dispose();
  }
  
  void _clearDebugOverlays() {
    for (final overlay in _debugOverlays) {
      overlay.remove();
    }
    _debugOverlays.clear();
  }
  
  /// Add a debug milestone with sound and optional overlay
  Future<void> debugMilestone(String message, {
    bool showOverlay = true,
    int soundFreq = 800,
    Duration overlayDuration = const Duration(seconds: 3),
  }) async {
    await WindowsDebugService.debugMilestone(message, soundFreq: soundFreq);
    
    if (showOverlay && Platform.isWindows && kDebugMode) {
      try {
        // Check if overlay is available before trying to use it
        final overlayState = Overlay.maybeOf(context);
        if (overlayState != null) {
          final overlay = WindowsDebugService.createDebugOverlay(context, message);
          if (overlay != null) {
            overlayState.insert(overlay);
            _debugOverlays.add(overlay);
            
            // Auto-remove after duration
            Future.delayed(overlayDuration, () {
              if (_debugOverlays.contains(overlay)) {
                overlay.remove();
                _debugOverlays.remove(overlay);
              }
            });
          }
        }
      } catch (e) {
        // Silently handle overlay errors during app initialization
        if (kDebugMode) {
          print('🪟 [DEBUG] Overlay not ready yet: $e');
        }
      }
    }
  }
}