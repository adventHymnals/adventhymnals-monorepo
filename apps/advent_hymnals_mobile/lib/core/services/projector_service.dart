import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProjectorService extends ChangeNotifier {
  static final ProjectorService _instance = ProjectorService._internal();
  factory ProjectorService() => _instance;
  ProjectorService._internal();

  // Current state
  int? _currentHymnId;
  int _currentVerseIndex = 0;
  bool _isProjectorActive = false;
  Timer? _autoAdvanceTimer;
  
  // Auto-advance settings
  bool _autoAdvanceEnabled = false;
  int _autoAdvanceSeconds = 15;
  
  // Projector display settings
  ProjectorTheme _theme = ProjectorTheme.dark;
  ProjectorTextSize _textSize = ProjectorTextSize.large;
  bool _showVerseNumbers = true;
  bool _showHymnNumber = true;
  bool _showTitle = true;
  bool _showMetadata = false;
  
  // Getters
  int? get currentHymnId => _currentHymnId;
  int get currentVerseIndex => _currentVerseIndex;
  bool get isProjectorActive => _isProjectorActive;
  bool get autoAdvanceEnabled => _autoAdvanceEnabled;
  int get autoAdvanceSeconds => _autoAdvanceSeconds;
  ProjectorTheme get theme => _theme;
  ProjectorTextSize get textSize => _textSize;
  bool get showVerseNumbers => _showVerseNumbers;
  bool get showHymnNumber => _showHymnNumber;
  bool get showTitle => _showTitle;
  bool get showMetadata => _showMetadata;

  /// Start projector mode with a hymn
  void startProjector(int hymnId) {
    print('🎥 [ProjectorService] Starting projector mode with hymn $hymnId');
    _currentHymnId = hymnId;
    _currentVerseIndex = 0;
    _isProjectorActive = true;
    _resetAutoAdvanceTimer();
    notifyListeners();
    
    // Try to open secondary window on desktop
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      _openSecondaryWindow();
    }
  }

  /// Stop projector mode
  void stopProjector() {
    print('🎥 [ProjectorService] Stopping projector mode');
    _isProjectorActive = false;
    _currentHymnId = null;
    _currentVerseIndex = 0;
    _stopAutoAdvanceTimer();
    notifyListeners();
  }

  /// Change to a different hymn
  void changeHymn(int hymnId) {
    print('🎥 [ProjectorService] Changing hymn to $hymnId');
    _currentHymnId = hymnId;
    _currentVerseIndex = 0;
    _resetAutoAdvanceTimer();
    notifyListeners();
  }

  /// Navigate to next verse/chorus
  void nextSection() {
    print('🎥 [ProjectorService] Moving to next section (verse ${_currentVerseIndex + 1})');
    _currentVerseIndex++;
    _resetAutoAdvanceTimer();
    notifyListeners();
  }

  /// Navigate to previous verse/chorus
  void previousSection() {
    if (_currentVerseIndex > 0) {
      print('🎥 [ProjectorService] Moving to previous section (verse ${_currentVerseIndex - 1})');
      _currentVerseIndex--;
      _resetAutoAdvanceTimer();
      notifyListeners();
    }
  }

  /// Jump to specific verse
  void goToVerse(int verseIndex) {
    print('🎥 [ProjectorService] Jumping to verse $verseIndex');
    _currentVerseIndex = verseIndex;
    _resetAutoAdvanceTimer();
    notifyListeners();
  }

  /// Toggle auto-advance
  void toggleAutoAdvance() {
    _autoAdvanceEnabled = !_autoAdvanceEnabled;
    print('🎥 [ProjectorService] Auto-advance ${_autoAdvanceEnabled ? 'enabled' : 'disabled'}');
    
    if (_autoAdvanceEnabled) {
      _resetAutoAdvanceTimer();
    } else {
      _stopAutoAdvanceTimer();
    }
    notifyListeners();
  }

  /// Set auto-advance interval
  void setAutoAdvanceSeconds(int seconds) {
    _autoAdvanceSeconds = seconds;
    print('🎥 [ProjectorService] Auto-advance interval set to $seconds seconds');
    
    if (_autoAdvanceEnabled) {
      _resetAutoAdvanceTimer();
    }
    notifyListeners();
  }

  /// Update projector display settings
  void updateProjectorSettings({
    ProjectorTheme? theme,
    ProjectorTextSize? textSize,
    bool? showVerseNumbers,
    bool? showHymnNumber,
    bool? showTitle,
    bool? showMetadata,
  }) {
    if (theme != null) _theme = theme;
    if (textSize != null) _textSize = textSize;
    if (showVerseNumbers != null) _showVerseNumbers = showVerseNumbers;
    if (showHymnNumber != null) _showHymnNumber = showHymnNumber;
    if (showTitle != null) _showTitle = showTitle;
    if (showMetadata != null) _showMetadata = showMetadata;
    
    print('🎥 [ProjectorService] Updated projector settings');
    notifyListeners();
  }

  /// Reset auto-advance timer
  void _resetAutoAdvanceTimer() {
    _stopAutoAdvanceTimer();
    
    if (_autoAdvanceEnabled && _isProjectorActive) {
      _autoAdvanceTimer = Timer(Duration(seconds: _autoAdvanceSeconds), () {
        // Auto-advance to next verse
        nextSection();
      });
      print('🎥 [ProjectorService] Auto-advance timer reset for $_autoAdvanceSeconds seconds');
    }
  }

  /// Stop auto-advance timer
  void _stopAutoAdvanceTimer() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = null;
  }

  /// Open secondary window for projector (desktop only)
  void _openSecondaryWindow() {
    // This would require platform-specific implementation
    // For now, we'll use the same window but indicate it's projector mode
    print('🎥 [ProjectorService] Would open secondary window on desktop platform');
    
    // In a full implementation, this would:
    // 1. Create a new window using platform channels
    // 2. Position it on the secondary monitor
    // 3. Set it to fullscreen mode
    // 4. Navigate to the projector display screen
  }

  /// Get estimated time until next auto-advance (for UI feedback)
  Stream<int> getAutoAdvanceCountdown() async* {
    while (_autoAdvanceEnabled && _isProjectorActive && _autoAdvanceTimer != null) {
      final remaining = _autoAdvanceSeconds;
      for (int i = remaining; i >= 0; i--) {
        yield i;
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  @override
  void dispose() {
    _stopAutoAdvanceTimer();
    super.dispose();
  }
}

enum ProjectorTheme {
  dark,
  light,
  highContrast,
  blue,
}

enum ProjectorTextSize {
  small,
  medium,
  large,
  extraLarge,
}