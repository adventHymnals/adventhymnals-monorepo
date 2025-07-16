import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'projector_window_service.dart';

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
    
    // Close secondary window on desktop
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      _closeSecondaryWindow();
    }
    
    notifyListeners();
  }

  /// Change to a different hymn
  void changeHymn(int hymnId) {
    print('🎥 [ProjectorService] Changing hymn to $hymnId');
    _currentHymnId = hymnId;
    _currentVerseIndex = 0;
    _resetAutoAdvanceTimer();
    _updateSecondaryWindowContent();
    notifyListeners();
  }

  /// Navigate to next verse/chorus
  void nextSection() {
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
      final projectorWindowService = ProjectorWindowService.instance;
      
      // Initialize the service if needed
      if (!projectorWindowService.isInitialized) {
        await projectorWindowService.initialize();
      }
      
      // Get available monitors
      final monitors = await projectorWindowService.getAvailableMonitors();
      print('🎥 [ProjectorService] Found ${monitors.length} monitors');
      
      // Try to open on secondary monitor if available, otherwise use primary
      int targetMonitor = 0;
      if (monitors.length > 1) {
        // Find first non-primary monitor
        for (int i = 0; i < monitors.length; i++) {
          if (!monitors[i].isPrimary) {
            targetMonitor = i;
            break;
          }
        }
      }
      
      // Open the secondary window
      final success = await projectorWindowService.openSecondaryWindow(
        monitorIndex: targetMonitor,
        fullscreen: true,
      );
      
      if (success) {
        print('🎥 [ProjectorService] Secondary window opened successfully on monitor $targetMonitor');
      } else {
        print('❌ [ProjectorService] Failed to open secondary window');
      }
    } catch (e) {
      print('❌ [ProjectorService] Error opening secondary window: $e');
    }
  }

  /// Close secondary window for projector (desktop only)
  Future<void> _closeSecondaryWindow() async {
    try {
      final projectorWindowService = ProjectorWindowService.instance;
      
      if (projectorWindowService.isSecondaryWindowOpen) {
        final success = await projectorWindowService.closeSecondaryWindow();
        if (success) {
          print('🎥 [ProjectorService] Secondary window closed successfully');
        } else {
          print('❌ [ProjectorService] Failed to close secondary window');
        }
      }
    } catch (e) {
      print('❌ [ProjectorService] Error closing secondary window: $e');
    }
  }

  /// Update content in secondary window
  Future<void> _updateSecondaryWindowContent() async {
    try {
      final projectorWindowService = ProjectorWindowService.instance;
      
      if (projectorWindowService.isSecondaryWindowOpen && _currentHymnId != null) {
        final content = {
          'hymnId': _currentHymnId,
          'verseIndex': _currentVerseIndex,
          'theme': _theme.toString(),
          'textSize': _textSize.toString(),
          'showVerseNumbers': _showVerseNumbers,
          'showHymnNumber': _showHymnNumber,
          'showTitle': _showTitle,
          'showMetadata': _showMetadata,
        };
        
        await projectorWindowService.updateContent(content);
      }
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