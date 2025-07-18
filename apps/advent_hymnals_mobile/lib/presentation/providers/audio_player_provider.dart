import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io' show Platform;
import '../../domain/entities/hymn.dart';
import '../providers/settings_provider.dart';
import '../../core/services/windows_audio_service.dart';
import '../../core/services/comprehensive_audio_service.dart';

enum AudioState {
  stopped,
  playing,
  paused,
  loading,
  error,
  checking_availability,
}

enum RepeatMode {
  off,
  one,
  all,
}

class AudioPlayerProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final SettingsProvider _settingsProvider;
  final ComprehensiveAudioService _audioService = ComprehensiveAudioService.instance;
  WindowsAudioService? _windowsAudioService;
  
  AudioState _audioState = AudioState.stopped;
  Hymn? _currentHymn;
  HymnAudioInfo? _currentAudioInfo;
  List<Hymn> _playlist = [];
  int _currentIndex = 0;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isShuffleEnabled = false;
  RepeatMode _repeatMode = RepeatMode.off;
  double _volume = 1.0;
  String? _errorMessage;
  
  // Getters
  AudioState get audioState => _audioState;
  Hymn? get currentHymn => _currentHymn;
  HymnAudioInfo? get currentAudioInfo => _currentAudioInfo;
  List<Hymn> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  Duration get duration => _duration;
  Duration get position => _position;
  bool get isShuffleEnabled => _isShuffleEnabled;
  RepeatMode get repeatMode => _repeatMode;
  double get volume => _volume;
  String? get errorMessage => _errorMessage;
  
  bool get isPlaying => _audioState == AudioState.playing;
  bool get isPaused => _audioState == AudioState.paused;
  bool get isLoading => _audioState == AudioState.loading;
  bool get isCheckingAvailability => _audioState == AudioState.checking_availability;
  bool get hasError => _audioState == AudioState.error;
  bool get hasPrevious => _currentIndex > 0;
  bool get hasNext => _currentIndex < _playlist.length - 1;
  
  // Audio availability getters
  bool get hasAnyAudio => _currentAudioInfo?.hasAnyAudio ?? false;
  bool get isCheckingAudio => _currentAudioInfo?.isChecking ?? false;
  List<AudioFormat> get availableFormats => _currentAudioInfo?.availableFormats ?? [];
  AudioFormat? get preferredFormat => _currentAudioInfo?.preferredFormat;
  
  double get progress {
    if (_duration.inMilliseconds == 0) return 0.0;
    return _position.inMilliseconds / _duration.inMilliseconds;
  }
  
  String get positionText => _formatDuration(_position);
  String get durationText => _formatDuration(_duration);
  String get remainingText => _formatDuration(_duration - _position);

  AudioPlayerProvider(this._settingsProvider) {
    _initializePlayer();
    _initializeAudioService();
  }
  
  Future<void> _initializeAudioService() async {
    try {
      await _audioService.loadCacheFromDisk();
      if (kDebugMode) {
        print('✅ [AudioPlayerProvider] Audio service initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [AudioPlayerProvider] Failed to initialize audio service: $e');
      }
    }
  }

  void _initializePlayer() {
    if (Platform.isWindows) {
      // Initialize Windows-specific audio service
      _windowsAudioService = WindowsAudioService.instance;
      _initializeWindowsAudio();
    } else {
      // Initialize standard audio player for other platforms
      _initializeStandardAudio();
    }
  }

  void _initializeStandardAudio() {
    // Listen to player state changes
    _audioPlayer.onPlayerStateChanged.listen((state) {
      switch (state) {
        case PlayerState.stopped:
          _setAudioState(AudioState.stopped);
          break;
        case PlayerState.playing:
          _setAudioState(AudioState.playing);
          break;
        case PlayerState.paused:
          _setAudioState(AudioState.paused);
          break;
        case PlayerState.completed:
          _onTrackCompleted();
          break;
        case PlayerState.disposed:
          _setAudioState(AudioState.stopped);
          break;
      }
    });

    // Listen to duration changes
    _audioPlayer.onDurationChanged.listen((duration) {
      _duration = duration;
      notifyListeners();
    });

    // Listen to position changes
    _audioPlayer.onPositionChanged.listen((position) {
      _position = position;
      notifyListeners();
    });

    // Set initial volume from settings
    _volume = _settingsProvider.settings.soundEnabled ? 1.0 : 0.0;
    _audioPlayer.setVolume(_volume);
  }

  Future<void> _initializeWindowsAudio() async {
    try {
      if (_windowsAudioService != null) {
        final initialized = await _windowsAudioService!.initialize();
        if (initialized) {
          // Set up Windows audio player event listeners
          final windowsPlayer = _windowsAudioService!.playerInstance;
          if (windowsPlayer != null) {
            windowsPlayer.onPlayerStateChanged.listen((state) {
              switch (state) {
                case PlayerState.stopped:
                  _setAudioState(AudioState.stopped);
                  break;
                case PlayerState.playing:
                  _setAudioState(AudioState.playing);
                  break;
                case PlayerState.paused:
                  _setAudioState(AudioState.paused);
                  break;
                case PlayerState.completed:
                  _onTrackCompleted();
                  break;
                case PlayerState.disposed:
                  _setAudioState(AudioState.stopped);
                  break;
              }
            });

            windowsPlayer.onDurationChanged.listen((duration) {
              _duration = duration;
              notifyListeners();
            });

            windowsPlayer.onPositionChanged.listen((position) {
              _position = position;
              notifyListeners();
            });

            // Set initial volume
            _volume = _settingsProvider.settings.soundEnabled ? 1.0 : 0.0;
            await _windowsAudioService!.setVolume(_volume);
          }
        } else {
          _setError('Failed to initialize Windows audio service');
        }
      }
    } catch (e) {
      _setError('Windows audio initialization failed: ${e.toString()}');
    }
  }

  // Audio availability checking
  Future<void> checkAudioAvailability(Hymn hymn) async {
    try {
      _setAudioState(AudioState.checking_availability);
      _currentAudioInfo = await _audioService.getAudioInfo(hymn, onComplete: (updatedInfo) {
        // Update state when audio check completes
        _currentAudioInfo = updatedInfo;
        if (updatedInfo.hasAnyAudio) {
          _setAudioState(AudioState.stopped);
        } else if (!updatedInfo.isChecking) {
          _setAudioState(AudioState.stopped);
        }
        notifyListeners();
      });
      
      if (_currentAudioInfo!.hasAnyAudio) {
        _setAudioState(AudioState.stopped);
      } else if (!_currentAudioInfo!.isChecking) {
        _setAudioState(AudioState.stopped);
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to check audio availability: ${e.toString()}');
    }
  }
  
  // Download audio for offline use
  Future<bool> downloadAudioFile(Hymn hymn, AudioFormat format) async {
    try {
      return await _audioService.downloadAudioFile(hymn, format);
    } catch (e) {
      _setError('Failed to download audio: ${e.toString()}');
      return false;
    }
  }

  // Play audio from local file
  Future<void> playFromLocalFile(String filePath) async {
    try {
      _setAudioState(AudioState.loading);
      
      if (Platform.isWindows && _windowsAudioService != null) {
        // Use Windows audio service
        final success = await _windowsAudioService!.playFromFile(filePath);
        if (!success) {
          _setError(_windowsAudioService!.lastError ?? 'Failed to play local file on Windows');
          return;
        }
        // State will be set via Windows audio service listeners
      } else {
        // Use standard audio player
        await _audioPlayer.play(DeviceFileSource(filePath));
        // State will be set via standard audio player listeners
      }
    } catch (e) {
      _setError('Failed to play local file: ${e.toString()}');
    }
  }
  
  // Playback control methods
  Future<void> playHymn(Hymn hymn, {List<Hymn>? playlist, AudioFormat? preferredFormat}) async {
    try {
      _setAudioState(AudioState.loading);
      _clearError();

      _currentHymn = hymn;
      
      if (playlist != null) {
        _playlist = playlist;
        _currentIndex = playlist.indexWhere((h) => h.id == hymn.id);
        if (_currentIndex == -1) {
          _playlist.insert(0, hymn);
          _currentIndex = 0;
        }
      } else {
        _playlist = [hymn];
        _currentIndex = 0;
      }

      // Get audio info with availability checking
      _currentAudioInfo = await _audioService.getAudioInfo(hymn);
      
      // Wait for availability check if still checking
      if (_currentAudioInfo!.isChecking) {
        // Give it a moment to complete the check
        await Future.delayed(const Duration(milliseconds: 1500));
        _currentAudioInfo = await _audioService.getAudioInfo(hymn);
      }
      
      if (!_currentAudioInfo!.hasAnyAudio) {
        _setError('No audio files available for this hymn');
        return;
      }
      
      // Get the best audio file for playback
      final audioFile = await _audioService.getBestAudioFile(
        _currentAudioInfo!,
        preferredFormat: preferredFormat,
      );
      
      if (audioFile == null) {
        _setError('No audio files available for this platform');
        return;
      }
      
      // Check if the selected format is supported on this platform
      if (!ComprehensiveAudioService.isFormatSupported(audioFile.format)) {
        _setError('Audio format not supported on this platform');
        return;
      }
      
      String audioSource;
      if (audioFile.isLocal && audioFile.localPath != null) {
        audioSource = audioFile.localPath!;
        if (kDebugMode) {
          print('🎵 [AudioPlayerProvider] Playing local file: $audioSource');
        }
      } else {
        audioSource = audioFile.url;
        if (kDebugMode) {
          print('🎵 [AudioPlayerProvider] Playing remote file: $audioSource');
        }
      }
      
      if (Platform.isWindows && _windowsAudioService != null) {
        // Use Windows audio service
        final success = audioFile.isLocal 
          ? await _windowsAudioService!.playFromFile(audioSource)
          : await _windowsAudioService!.playFromUrl(audioSource);
        if (!success) {
          _setError(_windowsAudioService!.lastError ?? 'Failed to play hymn on Windows');
          return;
        }
        // State will be set via Windows audio service listeners
      } else {
        // Use standard audio player
        if (audioFile.isLocal) {
          await _audioPlayer.play(DeviceFileSource(audioSource));
        } else {
          await _audioPlayer.play(UrlSource(audioSource));
        }
        // State will be set via standard audio player listeners
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to play hymn: ${e.toString()}');
    }
  }

  Future<void> pause() async {
    try {
      if (Platform.isWindows && _windowsAudioService != null) {
        final success = await _windowsAudioService!.pause();
        if (!success) {
          _setError(_windowsAudioService!.lastError ?? 'Failed to pause on Windows');
        }
      } else {
        await _audioPlayer.pause();
      }
    } catch (e) {
      _setError('Failed to pause: ${e.toString()}');
    }
  }

  Future<void> resume() async {
    try {
      if (Platform.isWindows && _windowsAudioService != null) {
        final success = await _windowsAudioService!.resume();
        if (!success) {
          _setError(_windowsAudioService!.lastError ?? 'Failed to resume on Windows');
        }
      } else {
        await _audioPlayer.resume();
      }
    } catch (e) {
      _setError('Failed to resume: ${e.toString()}');
    }
  }

  Future<void> stop() async {
    try {
      if (Platform.isWindows && _windowsAudioService != null) {
        final success = await _windowsAudioService!.stop();
        if (!success) {
          _setError(_windowsAudioService!.lastError ?? 'Failed to stop on Windows');
        }
      } else {
        await _audioPlayer.stop();
      }
      _position = Duration.zero;
      notifyListeners();
    } catch (e) {
      _setError('Failed to stop: ${e.toString()}');
    }
  }

  Future<void> seekTo(Duration position) async {
    try {
      if (Platform.isWindows && _windowsAudioService != null) {
        final success = await _windowsAudioService!.seekTo(position);
        if (!success) {
          _setError(_windowsAudioService!.lastError ?? 'Failed to seek on Windows');
        }
      } else {
        await _audioPlayer.seek(position);
      }
    } catch (e) {
      _setError('Failed to seek: ${e.toString()}');
    }
  }

  Future<void> seekForward({Duration duration = const Duration(seconds: 15)}) async {
    final newPosition = _position + duration;
    if (newPosition < _duration) {
      await seekTo(newPosition);
    } else {
      await seekTo(_duration);
    }
  }

  Future<void> seekBackward({Duration duration = const Duration(seconds: 15)}) async {
    final newPosition = _position - duration;
    if (newPosition > Duration.zero) {
      await seekTo(newPosition);
    } else {
      await seekTo(Duration.zero);
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      _volume = volume.clamp(0.0, 1.0);
      
      if (Platform.isWindows && _windowsAudioService != null) {
        final success = await _windowsAudioService!.setVolume(_volume);
        if (!success) {
          _setError(_windowsAudioService!.lastError ?? 'Failed to set volume on Windows');
        }
      } else {
        await _audioPlayer.setVolume(_volume);
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to set volume: ${e.toString()}');
    }
  }

  Future<void> setPlaybackRate(double rate) async {
    try {
      final clampedRate = rate.clamp(0.5, 2.0);
      await _audioPlayer.setPlaybackRate(clampedRate);
      notifyListeners();
    } catch (e) {
      _setError('Failed to set playback rate: ${e.toString()}');
    }
  }

  // Playlist navigation
  Future<void> playNext() async {
    if (!hasNext) {
      if (_repeatMode == RepeatMode.all) {
        _currentIndex = 0;
      } else {
        return;
      }
    } else {
      _currentIndex++;
    }
    
    await playHymn(_playlist[_currentIndex], playlist: _playlist);
  }

  Future<void> playPrevious() async {
    if (!hasPrevious) {
      if (_repeatMode == RepeatMode.all) {
        _currentIndex = _playlist.length - 1;
      } else {
        return;
      }
    } else {
      _currentIndex--;
    }
    
    await playHymn(_playlist[_currentIndex], playlist: _playlist);
  }

  Future<void> playAtIndex(int index) async {
    if (index >= 0 && index < _playlist.length) {
      _currentIndex = index;
      await playHymn(_playlist[_currentIndex], playlist: _playlist);
    }
  }

  // Playlist management
  void toggleShuffle() {
    _isShuffleEnabled = !_isShuffleEnabled;
    notifyListeners();
  }

  void toggleRepeat() {
    switch (_repeatMode) {
      case RepeatMode.off:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.off;
        break;
    }
    notifyListeners();
  }

  void addToPlaylist(Hymn hymn) {
    if (!_playlist.any((h) => h.id == hymn.id)) {
      _playlist.add(hymn);
      notifyListeners();
    }
  }

  void removeFromPlaylist(int index) {
    if (index >= 0 && index < _playlist.length) {
      _playlist.removeAt(index);
      if (_currentIndex >= index && _currentIndex > 0) {
        _currentIndex--;
      }
      notifyListeners();
    }
  }

  void clearPlaylist() {
    _playlist.clear();
    _currentIndex = 0;
    _currentHymn = null;
    stop();
    notifyListeners();
  }

  void reorderPlaylist(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final hymn = _playlist.removeAt(oldIndex);
    _playlist.insert(newIndex, hymn);
    
    // Update current index if necessary
    if (oldIndex == _currentIndex) {
      _currentIndex = newIndex;
    } else if (oldIndex < _currentIndex && newIndex >= _currentIndex) {
      _currentIndex--;
    } else if (oldIndex > _currentIndex && newIndex <= _currentIndex) {
      _currentIndex++;
    }
    
    notifyListeners();
  }

  // Private methods
  void _onTrackCompleted() {
    switch (_repeatMode) {
      case RepeatMode.one:
        // Replay current track
        playHymn(_currentHymn!, playlist: _playlist);
        break;
      case RepeatMode.all:
        // Play next track, or first if at end
        playNext();
        break;
      case RepeatMode.off:
        // Play next track if available, otherwise stop
        if (hasNext) {
          playNext();
        } else {
          _setAudioState(AudioState.stopped);
        }
        break;
    }
  }

  void _setAudioState(AudioState state) {
    _audioState = state;
    if (state != AudioState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String error) {
    _audioState = AudioState.error;
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    if (_audioState == AudioState.error) {
      _audioState = AudioState.stopped;
    }
  }
  
  // Cache management methods
  Future<int> getCacheSize() async {
    return await _audioService.getCacheSize();
  }
  
  String formatCacheSize(int bytes) {
    return _audioService.formatCacheSize(bytes);
  }
  
  Future<void> clearAudioCache() async {
    try {
      await _audioService.clearCache();
      _currentAudioInfo = null;
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear cache: ${e.toString()}');
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inHours > 0) {
      final hours = twoDigits(duration.inHours);
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _audioService.dispose();
    super.dispose();
  }
}