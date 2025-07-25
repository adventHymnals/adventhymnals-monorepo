import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../domain/entities/hymn.dart';
import '../providers/settings_provider.dart';

enum AudioState {
  stopped,
  playing,
  paused,
  loading,
  error,
}

enum RepeatMode {
  off,
  one,
  all,
}

class AudioPlayerProvider extends ChangeNotifier {
  AudioPlayer? _audioPlayer;
  final SettingsProvider _settingsProvider;
  
  AudioState _audioState = AudioState.stopped;
  Hymn? _currentHymn;
  List<Hymn> _playlist = [];
  int _currentIndex = 0;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isShuffleEnabled = false;
  RepeatMode _repeatMode = RepeatMode.off;
  double _volume = 1.0;
  String? _errorMessage;
  
  // Stream subscriptions for cleanup
  late final List<StreamSubscription> _subscriptions = [];
  
  // Getters (same as before)
  AudioState get audioState => _audioState;
  Hymn? get currentHymn => _currentHymn;
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
  bool get hasError => _audioState == AudioState.error;
  bool get hasPrevious => _currentIndex > 0;
  bool get hasNext => _currentIndex < _playlist.length - 1;
  
  double get progress {
    if (_duration.inMilliseconds == 0) return 0.0;
    return _position.inMilliseconds / _duration.inMilliseconds;
  }
  
  String get positionText => _formatDuration(_position);
  String get durationText => _formatDuration(_duration);
  String get remainingText => _formatDuration(_duration - _position);

  AudioPlayerProvider(this._settingsProvider) {
    _initializePlayer();
  }

  void _initializePlayer() {
    try {
      _audioPlayer = AudioPlayer();
      
      // Safe stream subscription with null checks
      _subscriptions.add(
        _audioPlayer!.onPlayerStateChanged.listen((state) {
          if (!mounted) return;
          
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
        }, onError: (error) {
          debugPrint('Audio player state error: $error');
          _setError('Audio player state error: $error');
        }),
      );

      // Safe duration listener
      _subscriptions.add(
        _audioPlayer!.onDurationChanged.listen((duration) {
          if (!mounted) return;
          _duration = duration;
          notifyListeners();
        }, onError: (error) {
          debugPrint('Audio duration error: $error');
        }),
      );

      // Safe position listener
      _subscriptions.add(
        _audioPlayer!.onPositionChanged.listen((position) {
          if (!mounted) return;
          _position = position;
          notifyListeners();
        }, onError: (error) {
          debugPrint('Audio position error: $error');
        }),
      );

      // Set initial volume from settings
      _volume = _settingsProvider.settings.soundEnabled ? 1.0 : 0.0;
      _audioPlayer!.setVolume(_volume);
      
    } catch (e) {
      debugPrint('Failed to initialize audio player: $e');
      _setError('Failed to initialize audio player: $e');
    }
  }

  bool get mounted => _audioPlayer != null;

  // Fixed playback method with better error handling
  Future<void> playHymn(Hymn hymn, {List<Hymn>? playlist}) async {
    if (!mounted) {
      _setError('Audio player not initialized');
      return;
    }
    
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

      // WINDOWS FIX: Don't attempt to play demo URLs on Windows
      // Instead, set a placeholder state
      if (Platform.isWindows) {
        _setError('Audio playback not available on Windows in debug mode');
        return;
      }

      // For demo purposes, use a sample audio URL
      final audioUrl = _getAudioUrl(hymn);
      
      // Validate URL before attempting to play
      if (audioUrl.isEmpty) {
        _setError('No audio URL available for this hymn');
        return;
      }
      
      await _audioPlayer!.play(UrlSource(audioUrl));
      
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to play hymn: $e');
      _setError('Failed to play hymn: ${e.toString()}');
    }
  }

  Future<void> pause() async {
    if (!mounted) return;
    
    try {
      await _audioPlayer!.pause();
    } catch (e) {
      debugPrint('Failed to pause: $e');
      _setError('Failed to pause: ${e.toString()}');
    }
  }

  Future<void> resume() async {
    if (!mounted) return;
    
    try {
      await _audioPlayer!.resume();
    } catch (e) {
      debugPrint('Failed to resume: $e');
      _setError('Failed to resume: ${e.toString()}');
    }
  }

  Future<void> stop() async {
    if (!mounted) return;
    
    try {
      await _audioPlayer!.stop();
      _position = Duration.zero;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to stop: $e');
      _setError('Failed to stop: ${e.toString()}');
    }
  }

  Future<void> seekTo(Duration position) async {
    if (!mounted) return;
    
    try {
      await _audioPlayer!.seek(position);
    } catch (e) {
      debugPrint('Failed to seek: $e');
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
    if (!mounted) return;
    
    try {
      _volume = volume.clamp(0.0, 1.0);
      await _audioPlayer!.setVolume(_volume);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to set volume: $e');
      _setError('Failed to set volume: ${e.toString()}');
    }
  }

  Future<void> setPlaybackRate(double rate) async {
    if (!mounted) return;
    
    try {
      final clampedRate = rate.clamp(0.5, 2.0);
      await _audioPlayer!.setPlaybackRate(clampedRate);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to set playback rate: $e');
      _setError('Failed to set playback rate: ${e.toString()}');
    }
  }

  // Playlist navigation methods (same as before but with mounted checks)
  Future<void> playNext() async {
    if (!mounted) return;
    
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
    if (!mounted) return;
    
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
    if (!mounted) return;
    
    if (index >= 0 && index < _playlist.length) {
      _currentIndex = index;
      await playHymn(_playlist[_currentIndex], playlist: _playlist);
    }
  }

  // Playlist management methods (same as before)
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
    if (!mounted) return;
    
    switch (_repeatMode) {
      case RepeatMode.one:
        // Replay current track
        if (_currentHymn != null) {
          playHymn(_currentHymn!, playlist: _playlist);
        }
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
    if (!mounted) return;
    
    _audioState = state;
    if (state != AudioState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String error) {
    if (!mounted) return;
    
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

  String _getAudioUrl(Hymn hymn) {
    // WINDOWS FIX: Return empty string to avoid network calls on Windows
    if (Platform.isWindows) {
      return '';
    }
    
    // For demo purposes, return a sample audio URL
    // In a real app, this would be based on the hymn's actual audio file
    switch (hymn.id) {
      case 1:
        return 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav';
      case 2:
        return 'https://www.soundjay.com/misc/sounds/bell-ringing-04.wav';
      default:
        return 'https://www.soundjay.com/misc/sounds/bell-ringing-03.wav';
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
    // Cancel all subscriptions first
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    
    // Dispose audio player
    _audioPlayer?.dispose();
    _audioPlayer = null;
    
    super.dispose();
  }
}