import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';

class ProjectorService extends ChangeNotifier {
  static final ProjectorService _instance = ProjectorService._internal();
  factory ProjectorService() => _instance;
  ProjectorService._internal();

  // Current state
  int? _currentHymnId;
  int _currentVerseIndex = 0;
  bool _isProjectorActive = false;
  Timer? _autoAdvanceTimer;
  int? _projectorWindowId;
  int _totalVerses = 0;
  
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
  int get totalVerses => _totalVerses;

  /// Start projector mode with a hymn
  void startProjector(int hymnId, {int totalVerses = 0}) {
    print('🎥 [ProjectorService] Starting projector mode with hymn $hymnId (${totalVerses} verses)');
    _currentHymnId = hymnId;
    _currentVerseIndex = 0;
    _totalVerses = totalVerses;
    _isProjectorActive = true;
    _resetAutoAdvanceTimer();
    notifyListeners();
    
    // Try to open secondary window on desktop
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      _openSecondaryWindow();
    }
  }

  /// Set the total number of verses for the current hymn
  void setTotalVerses(int totalVerses) {
    _totalVerses = totalVerses;
    print('🎥 [ProjectorService] Total verses set to $totalVerses');
    notifyListeners();
  }

  /// Stop projector mode
  void stopProjector() {
    print('🎥 [ProjectorService] Stopping projector mode');
    _isProjectorActive = false;
    _currentHymnId = null;
    _currentVerseIndex = 0;
    _totalVerses = 0;
    _stopAutoAdvanceTimer();
    
    // Close secondary window on desktop
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      _closeSecondaryWindow();
    }
    
    notifyListeners();
  }

  /// Change to a different hymn
  void changeHymn(int hymnId, {int totalVerses = 0}) {
    print('🎥 [ProjectorService] Changing hymn to $hymnId (${totalVerses} verses)');
    _currentHymnId = hymnId;
    _currentVerseIndex = 0;
    _totalVerses = totalVerses;
    _resetAutoAdvanceTimer();
    _updateSecondaryWindowContent();
    notifyListeners();
  }

  /// Navigate to next verse/chorus
  void nextSection() {
    // Check if we're at the last verse
    if (_totalVerses > 0 && _currentVerseIndex >= _totalVerses - 1) {
      print('🎥 [ProjectorService] Already at last verse (${_currentVerseIndex + 1}/$_totalVerses) - stopping auto-advance');
      _stopAutoAdvanceTimer();
      return;
    }
    
    print('🎥 [ProjectorService] Moving to next section (verse ${_currentVerseIndex + 1})');
    _currentVerseIndex++;
    _resetAutoAdvanceTimer();
    _updateSecondaryWindowContent();
    notifyListeners();
  }

  /// Navigate to previous verse/chorus
  void previousSection() {
    if (_currentVerseIndex > 0) {
      print('🎥 [ProjectorService] Moving to previous section (verse ${_currentVerseIndex - 1})');
      _currentVerseIndex--;
      _resetAutoAdvanceTimer();
      _updateSecondaryWindowContent();
      notifyListeners();
    }
  }

  /// Jump to specific verse
  void goToVerse(int verseIndex) {
    print('🎥 [ProjectorService] Jumping to verse $verseIndex');
    _currentVerseIndex = verseIndex;
    _resetAutoAdvanceTimer();
    _updateSecondaryWindowContent();
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
    _updateSecondaryWindowContent();
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
  Future<void> _openSecondaryWindow() async {
    print('🎥 [ProjectorService] Opening secondary window on desktop platform');
    
    try {
      if (_currentHymnId != null) {
        // For now, use clipboard method until we properly configure desktop_multi_window
        await _fallbackToClipboard();
      }
    } catch (e) {
      print('❌ [ProjectorService] Error preparing secondary window: $e');
    }
  }

  /// Fallback method for platforms where desktop_multi_window isn't available
  Future<void> _fallbackToClipboard() async {
    if (_currentHymnId != null) {
      final projectorUrl = 'http://localhost:8080/projector-window?hymn=$_currentHymnId';
      await Clipboard.setData(ClipboardData(text: projectorUrl));
      print('📋 [ProjectorService] Fallback: URL copied to clipboard. Open in browser window on second screen.');
    }
  }

  /// Close secondary window for projector (desktop only)
  Future<void> _closeSecondaryWindow() async {
    try {
      print('🎥 [ProjectorService] Projector mode stopped. Close the browser window/tab manually if needed.');
      _projectorWindowId = null;
    } catch (e) {
      print('❌ [ProjectorService] Error in close secondary window: $e');
      _projectorWindowId = null;
    }
  }

  /// Update content in secondary window
  Future<void> _updateSecondaryWindowContent() async {
    try {
      // The projector window automatically updates via Provider/ChangeNotifier
      // No need for manual content updates since the ProjectorWindowScreen
      // listens to ProjectorService changes
      print('🎥 [ProjectorService] Content updated - projector window will auto-refresh (verse ${_currentVerseIndex + 1})');
    } catch (e) {
      print('❌ [ProjectorService] Error updating secondary window content: $e');
    }
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