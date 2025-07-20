import 'dart:io';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

/// Windows MIDI playback service using Windows API
class WindowsMidiService {
  static final WindowsMidiService _instance = WindowsMidiService._internal();
  static WindowsMidiService get instance => _instance;
  WindowsMidiService._internal();

  bool _isInitialized = false;
  String? _lastError;
  
  /// Initialize Windows MIDI service
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      if (!Platform.isWindows) {
        throw Exception('WindowsMidiService can only be used on Windows platform');
      }

      // For now, we'll use a simpler approach - shell execution of Windows Media Player
      // This is a temporary solution until we implement proper MIDI support
      _isInitialized = true;
      _lastError = null;
      
      if (kDebugMode) {
        print('✅ [WindowsMidiService] Successfully initialized Windows MIDI service');
      }
      
      return true;
    } catch (e) {
      _lastError = 'Failed to initialize Windows MIDI service: ${e.toString()}';
      if (kDebugMode) {
        print('❌ [WindowsMidiService] Initialization failed: $_lastError');
      }
      return false;
    }
  }

  /// Play MIDI file using Windows Media Player
  Future<bool> playMidiFile(String filePath) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return false;
    }

    try {
      // Convert to Windows path format
      final windowsPath = filePath.replaceAll('/', '\\');
      
      if (kDebugMode) {
        print('🎵 [WindowsMidiService] Playing MIDI file: $windowsPath');
      }

      // Use Windows Media Player command line to play MIDI
      final result = await Process.run(
        'cmd',
        ['/c', 'start', '', '/min', 'wmplayer.exe', '"$windowsPath"'],
        runInShell: true,
      );

      if (result.exitCode == 0) {
        if (kDebugMode) {
          print('✅ [WindowsMidiService] Successfully started MIDI playback');
        }
        return true;
      } else {
        _lastError = 'Failed to start Windows Media Player: ${result.stderr}';
        if (kDebugMode) {
          print('❌ [WindowsMidiService] Failed to start playback: $_lastError');
        }
        return false;
      }
    } catch (e) {
      _lastError = 'Failed to play MIDI file: ${e.toString()}';
      if (kDebugMode) {
        print('❌ [WindowsMidiService] MIDI playback failed: $_lastError');
      }
      return false;
    }
  }

  /// Stop MIDI playback
  Future<bool> stopMidiPlayback() async {
    try {
      // Kill Windows Media Player processes
      await Process.run('taskkill', ['/F', '/IM', 'wmplayer.exe'], runInShell: true);
      
      if (kDebugMode) {
        print('✅ [WindowsMidiService] Stopped MIDI playback');
      }
      return true;
    } catch (e) {
      _lastError = 'Failed to stop MIDI playback: ${e.toString()}';
      if (kDebugMode) {
        print('❌ [WindowsMidiService] Failed to stop playback: $_lastError');
      }
      return false;
    }
  }

  /// Get last error message
  String? get lastError => _lastError;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;
}