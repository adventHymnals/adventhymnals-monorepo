import 'package:flutter/material.dart';
import '../models/user_preferences.dart' as prefs;
import '../services/preferences_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final preferences = await PreferencesService.instance.getUserPreferences();
      _themeMode = _mapToFlutterThemeMode(preferences.theme);
      notifyListeners();
    } catch (e) {
      print('Error loading theme mode: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_themeMode != themeMode) {
      _themeMode = themeMode;
      notifyListeners();
      
      try {
        final prefsThemeMode = _mapFromFlutterThemeMode(themeMode);
        await PreferencesService.instance.setThemeMode(prefsThemeMode);
      } catch (e) {
        print('Error saving theme mode: $e');
      }
    }
  }

  ThemeMode _mapToFlutterThemeMode(prefs.ThemeMode prefsThemeMode) {
    switch (prefsThemeMode) {
      case prefs.ThemeMode.light:
        return ThemeMode.light;
      case prefs.ThemeMode.dark:
        return ThemeMode.dark;
      case prefs.ThemeMode.system:
        return ThemeMode.system;
    }
  }

  prefs.ThemeMode _mapFromFlutterThemeMode(ThemeMode flutterThemeMode) {
    switch (flutterThemeMode) {
      case ThemeMode.light:
        return prefs.ThemeMode.light;
      case ThemeMode.dark:
        return prefs.ThemeMode.dark;
      case ThemeMode.system:
        return prefs.ThemeMode.system;
    }
  }

  bool get isDarkMode {
    return _themeMode == ThemeMode.dark ||
        (_themeMode == ThemeMode.system &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark);
  }

  bool get isLightMode {
    return _themeMode == ThemeMode.light ||
        (_themeMode == ThemeMode.system &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.light);
  }

  bool get isSystemMode => _themeMode == ThemeMode.system;
}