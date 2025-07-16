import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChurchModeService {
  static const String _churchModeKey = 'church_mode_enabled';
  static const String _lastChurchModePromptKey = 'last_church_mode_prompt';
  static const String _churchModeDeclinedKey = 'church_mode_declined_count';
  
  static final ChurchModeService _instance = ChurchModeService._internal();
  factory ChurchModeService() => _instance;
  ChurchModeService._internal();

  SharedPreferences? _prefs;
  bool _isChurchModeEnabled = false;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  BuildContext? _currentContext;

  /// Initialize the service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _isChurchModeEnabled = _prefs?.getBool(_churchModeKey) ?? false;
    
    // Listen for connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_onConnectivityChanged);
  }

  /// Check if church mode is enabled
  bool get isChurchModeEnabled => _isChurchModeEnabled;

  /// Set the current context for showing dialogs
  void setContext(BuildContext context) {
    _currentContext = context;
  }

  /// Handle connectivity changes
  void _onConnectivityChanged(ConnectivityResult result) {
    if (result != ConnectivityResult.none && _currentContext != null) {
      // Only show prompt on mobile platforms
      if (Platform.isAndroid || Platform.isIOS) {
        _considerShowingChurchModePrompt();
      }
    }
  }

  /// Consider showing church mode prompt based on various factors
  Future<void> _considerShowingChurchModePrompt() async {
    if (_prefs == null || _currentContext == null) return;
    
    // Don't prompt if already in church mode
    if (_isChurchModeEnabled) return;
    
    // Check if we should show the prompt
    final lastPrompt = _prefs!.getInt(_lastChurchModePromptKey) ?? 0;
    final declinedCount = _prefs!.getInt(_churchModeDeclinedKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Don't prompt too frequently
    const oneDayMs = 24 * 60 * 60 * 1000;
    const oneWeekMs = 7 * oneDayMs;
    
    int promptInterval;
    if (declinedCount == 0) {
      promptInterval = 0; // First time, show immediately
    } else if (declinedCount < 3) {
      promptInterval = oneDayMs; // Once per day for first 3 declines
    } else {
      promptInterval = oneWeekMs; // Once per week after that
    }
    
    if ((now - lastPrompt) < promptInterval) return;
    
    // Check if it's likely church time (weekend mornings)
    final currentTime = DateTime.now();
    final isWeekend = currentTime.weekday == DateTime.saturday || currentTime.weekday == DateTime.sunday;
    final isChurchTime = currentTime.hour >= 7 && currentTime.hour <= 12;
    
    // Show prompt more readily during potential church times
    if (isWeekend && isChurchTime) {
      _showChurchModePrompt();
    } else if (declinedCount == 0 || (now - lastPrompt) > (oneWeekMs * 2)) {
      // Show occasionally even outside church times for first-time users
      // or if it's been a long time
      _showChurchModePrompt();
    }
  }

  /// Show the church mode prompt dialog
  void _showChurchModePrompt() {
    if (_currentContext == null) return;
    
    showDialog(
      context: _currentContext!,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.church,
              color: Theme.of(context).primaryColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Worship Focus Mode',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you using this app for worship or church service?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            const Text(
              'When enabled, Worship Focus Mode will:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            _buildFeatureItem('🔕', 'Reduce notifications and distractions'),
            _buildFeatureItem('⛪', 'Optimize interface for worship settings'),
            _buildFeatureItem('📱', 'Minimize data usage and background activity'),
            _buildFeatureItem('🎵', 'Prioritize hymnal content over other features'),
            const SizedBox(height: 12),
            Text(
              'You can change this setting anytime in the app settings.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleChurchModeResponse(false);
            },
            child: Text(
              'Not now',
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _handleChurchModeResponse(true);
            },
            icon: const Icon(Icons.church, size: 18),
            label: const Text('Enable Focus Mode'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  /// Handle user response to church mode prompt
  Future<void> _handleChurchModeResponse(bool enabled) async {
    if (_prefs == null) return;
    
    _isChurchModeEnabled = enabled;
    await _prefs!.setBool(_churchModeKey, enabled);
    await _prefs!.setInt(_lastChurchModePromptKey, DateTime.now().millisecondsSinceEpoch);
    
    if (!enabled) {
      final declinedCount = _prefs!.getInt(_churchModeDeclinedKey) ?? 0;
      await _prefs!.setInt(_churchModeDeclinedKey, declinedCount + 1);
    }
    
    if (_currentContext != null && enabled) {
      // Show confirmation snackbar
      ScaffoldMessenger.of(_currentContext!).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.church, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Worship Focus Mode enabled for a distraction-free experience',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green[700],
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Settings',
            textColor: Colors.white,
            onPressed: () {
              // Navigate to settings - implement based on your routing
            },
          ),
        ),
      );
    }
  }

  /// Manually enable/disable church mode
  Future<void> setChurchMode(bool enabled) async {
    if (_prefs == null) return;
    
    _isChurchModeEnabled = enabled;
    await _prefs!.setBool(_churchModeKey, enabled);
  }

  /// Force show the church mode prompt (for testing or manual trigger)
  void showPromptNow() {
    _showChurchModePrompt();
  }

  /// Clean up resources
  void dispose() {
    _connectivitySubscription?.cancel();
  }
}