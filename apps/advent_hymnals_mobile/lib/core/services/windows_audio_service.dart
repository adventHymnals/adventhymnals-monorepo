import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'windows_midi_service.dart';

/// Windows-specific audio service for handling platform-specific audio operations
class WindowsAudioService {
  static final WindowsAudioService _instance = WindowsAudioService._internal();
  static WindowsAudioService get instance => _instance;
  WindowsAudioService._internal();

  AudioPlayer? _audioPlayer;
  WindowsMidiService? _midiService;
  bool _isInitialized = false;
  String? _lastError;

  /// Get the underlying AudioPlayer instance for event listening
  AudioPlayer? get playerInstance => _audioPlayer;

  /// Initialize Windows audio service
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      if (!Platform.isWindows) {
        throw Exception('WindowsAudioService can only be used on Windows platform');
      }

      _audioPlayer = AudioPlayer();
      _midiService = WindowsMidiService.instance;
      
      // Initialize MIDI service
      await _midiService!.initialize();
      
      // Windows-specific audio configuration
      await _configureWindowsAudio();
      
      _isInitialized = true;
      _lastError = null;
      
      if (kDebugMode) {
        print('✅ [WindowsAudioService] Successfully initialized Windows audio');
      }
      
      return true;
    } catch (e) {
      _lastError = 'Failed to initialize Windows audio: ${e.toString()}';
      if (kDebugMode) {
        print('❌ [WindowsAudioService] Initialization failed: $_lastError');
      }
      return false;
    }
  }

  /// Configure Windows-specific audio settings
  Future<void> _configureWindowsAudio() async {
    if (_audioPlayer == null) return;

    try {
      // Set Windows-specific audio context
      await _audioPlayer!.setAudioContext(const AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: [
            AVAudioSessionOptions.defaultToSpeaker,
            AVAudioSessionOptions.allowBluetooth,
          ],
        ),
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gain,
        ),
      ));

      if (kDebugMode) {
        print('✅ [WindowsAudioService] Windows audio context configured');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [WindowsAudioService] Audio context configuration failed: $e');
      }
      // Continue without audio context configuration - not critical for Windows
    }
  }

  /// Play audio from URL source
  Future<bool> playFromUrl(String url) async {
    if (!_isInitialized || _audioPlayer == null) {
      final initialized = await initialize();
      if (!initialized) return false;
    }

    try {
      await _audioPlayer!.play(UrlSource(url));
      _lastError = null;
      
      if (kDebugMode) {
        print('✅ [WindowsAudioService] Started playing: $url');
      }
      
      return true;
    } catch (e) {
      _lastError = 'Failed to play audio: ${e.toString()}';
      if (kDebugMode) {
        print('❌ [WindowsAudioService] Playback failed: $_lastError');
      }
      return false;
    }
  }

  /// Play audio from local file
  Future<bool> playFromFile(String filePath) async {
    if (!_isInitialized || _audioPlayer == null) {
      final initialized = await initialize();
      if (!initialized) return false;
    }

    try {
      // Convert to Windows-compatible file path
      final windowsPath = _normalizeWindowsPath(filePath);
      
      // Check if this is a MIDI file
      if (filePath.toLowerCase().endsWith('.mid') || filePath.toLowerCase().endsWith('.midi')) {
        if (kDebugMode) {
          print('🎵 [WindowsAudioService] Detected MIDI file, using MIDI service: $windowsPath');
        }
        
        if (_midiService != null) {
          final success = await _midiService!.playMidiFile(windowsPath);
          if (success) {
            _lastError = null;
            if (kDebugMode) {
              print('✅ [WindowsAudioService] Started playing MIDI file: $windowsPath');
            }
            return true;
          } else {
            _lastError = _midiService!.lastError ?? 'Failed to play MIDI file';
            if (kDebugMode) {
              print('❌ [WindowsAudioService] MIDI playback failed: $_lastError');
            }
            return false;
          }
        }
      } else {
        // Use regular audio player for non-MIDI files
        await _audioPlayer!.play(DeviceFileSource(windowsPath));
        _lastError = null;
        
        if (kDebugMode) {
          print('✅ [WindowsAudioService] Started playing file: $windowsPath');
        }
        
        return true;
      }
    } catch (e) {
      _lastError = 'Failed to play file: ${e.toString()}';
      if (kDebugMode) {
        print('❌ [WindowsAudioService] File playback failed: $_lastError');
      }
      return false;
    }
    
    return false;
  }

  /// Pause audio playback
  Future<bool> pause() async {
    if (_audioPlayer == null) return false;

    try {
      await _audioPlayer!.pause();
      if (kDebugMode) {
        print('✅ [WindowsAudioService] Audio paused');
      }
      return true;
    } catch (e) {
      _lastError = 'Failed to pause: ${e.toString()}';
      if (kDebugMode) {
        print('❌ [WindowsAudioService] Pause failed: $_lastError');
      }
      return false;
    }
  }

  /// Resume audio playback
  Future<bool> resume() async {
    if (_audioPlayer == null) return false;

    try {
      await _audioPlayer!.resume();
      if (kDebugMode) {
        print('✅ [WindowsAudioService] Audio resumed');
      }
      return true;
    } catch (e) {
      _lastError = 'Failed to resume: ${e.toString()}';
      if (kDebugMode) {
        print('❌ [WindowsAudioService] Resume failed: $_lastError');
      }
      return false;
    }
  }

  /// Stop audio playback
  Future<bool> stop() async {
    if (_audioPlayer == null) return false;

    try {
      // Stop both regular audio and MIDI playback
      await _audioPlayer!.stop();
      
      if (_midiService != null) {
        await _midiService!.stopMidiPlayback();
      }
      
      if (kDebugMode) {
        print('✅ [WindowsAudioService] Audio stopped');
      }
      return true;
    } catch (e) {
      _lastError = 'Failed to stop: ${e.toString()}';
      if (kDebugMode) {
        print('❌ [WindowsAudioService] Stop failed: $_lastError');
      }
      return false;
    }
  }

  /// Set volume (0.0 to 1.0)
  Future<bool> setVolume(double volume) async {
    if (_audioPlayer == null) return false;

    try {
      final clampedVolume = volume.clamp(0.0, 1.0);
      await _audioPlayer!.setVolume(clampedVolume);
      if (kDebugMode) {
        print('✅ [WindowsAudioService] Volume set to: ${(clampedVolume * 100).round()}%');
      }
      return true;
    } catch (e) {
      _lastError = 'Failed to set volume: ${e.toString()}';
      if (kDebugMode) {
        print('❌ [WindowsAudioService] Volume change failed: $_lastError');
      }
      return false;
    }
  }

  /// Seek to specific position
  Future<bool> seekTo(Duration position) async {
    if (_audioPlayer == null) return false;

    try {
      await _audioPlayer!.seek(position);
      if (kDebugMode) {
        print('✅ [WindowsAudioService] Seeked to: ${position.inSeconds}s');
      }
      return true;
    } catch (e) {
      _lastError = 'Failed to seek: ${e.toString()}';
      if (kDebugMode) {
        print('❌ [WindowsAudioService] Seek failed: $_lastError');
      }
      return false;
    }
  }

  /// Get current playback position
  Future<Duration> getCurrentPosition() async {
    if (_audioPlayer == null) return Duration.zero;

    try {
      final position = await _audioPlayer!.getCurrentPosition();
      return position ?? Duration.zero;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [WindowsAudioService] Failed to get position: $e');
      }
      return Duration.zero;
    }
  }

  /// Get audio duration
  Future<Duration> getDuration() async {
    if (_audioPlayer == null) return Duration.zero;

    try {
      final duration = await _audioPlayer!.getDuration();
      return duration ?? Duration.zero;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [WindowsAudioService] Failed to get duration: $e');
      }
      return Duration.zero;
    }
  }

  /// Get the underlying AudioPlayer instance for advanced operations
  AudioPlayer? get audioPlayer => _audioPlayer;

  /// Check if the service is initialized
  bool get isInitialized => _isInitialized;

  /// Get the last error message
  String? get lastError => _lastError;

  /// Normalize file path for Windows
  String _normalizeWindowsPath(String path) {
    // Convert forward slashes to backslashes for Windows
    String windowsPath = path.replaceAll('/', '\\');
    
    // Ensure absolute path format
    if (!windowsPath.contains(':') && !windowsPath.startsWith('\\\\')) {
      // Relative path - make it absolute
      windowsPath = '${Directory.current.path}\\$windowsPath';
    }
    
    return windowsPath;
  }

  /// Dispose of resources
  Future<void> dispose() async {
    try {
      await _audioPlayer?.dispose();
      _audioPlayer = null;
      _isInitialized = false;
      _lastError = null;
      
      if (kDebugMode) {
        print('✅ [WindowsAudioService] Disposed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [WindowsAudioService] Dispose error: $e');
      }
    }
  }

  /// Test Windows audio functionality
  Future<Map<String, dynamic>> runDiagnostics() async {
    final results = <String, dynamic>{
      'platform': Platform.operatingSystem,
      'isWindows': Platform.isWindows,
      'initialized': false,
      'canPlayUrl': false,
      'canControlPlayback': false,
      'canSetVolume': false,
      'errors': <String>[],
    };

    try {
      // Test initialization
      results['initialized'] = await initialize();
      if (!results['initialized']) {
        results['errors'].add('Failed to initialize audio service');
        return results;
      }

      // Test URL playback (using a test audio URL)
      const testUrl = 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav';
      results['canPlayUrl'] = await playFromUrl(testUrl);
      if (!results['canPlayUrl']) {
        results['errors'].add('Failed to play from URL');
      }

      // Test playback controls
      await Future.delayed(const Duration(milliseconds: 500));
      final pauseResult = await pause();
      final resumeResult = await resume();
      final stopResult = await stop();
      
      results['canControlPlayback'] = pauseResult && resumeResult && stopResult;
      if (!results['canControlPlayback']) {
        results['errors'].add('Failed to control playback');
      }

      // Test volume control
      results['canSetVolume'] = await setVolume(0.5);
      if (!results['canSetVolume']) {
        results['errors'].add('Failed to set volume');
      }

    } catch (e) {
      results['errors'].add('Diagnostic test failed: ${e.toString()}');
    }

    return results;
  }
}