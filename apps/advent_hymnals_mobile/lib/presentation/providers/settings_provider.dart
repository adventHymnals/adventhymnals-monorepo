import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/church_mode_service.dart';
import 'dart:convert';

enum AppThemeMode {
  light,
  dark,
  system,
}

enum FontSizePreference {
  small,
  medium,
  large,
  extraLarge,
}

enum SupportedLanguage {
  en,
  sw,
  luo,
  fr,
  es,
  de,
  pt,
  it,
}

class UserSettings {
  final AppThemeMode theme;
  final SupportedLanguage language;
  final FontSizePreference fontSize;
  final bool compactMode;
  final bool showNumbers;
  final bool autoDownload;
  final bool offlineMode;
  final bool vibrationEnabled;
  final bool soundEnabled;
  final double playbackSpeed;
  final int autoLockTimeout;
  final bool keepScreenOn;
  final bool showChords;
  final bool showMetadata;
  final bool largeTextMode;
  final bool churchModeEnabled;

  const UserSettings({
    required this.theme,
    required this.language,
    required this.fontSize,
    required this.compactMode,
    required this.showNumbers,
    required this.autoDownload,
    required this.offlineMode,
    required this.vibrationEnabled,
    required this.soundEnabled,
    required this.playbackSpeed,
    required this.autoLockTimeout,
    required this.keepScreenOn,
    required this.showChords,
    required this.showMetadata,
    required this.largeTextMode,
    required this.churchModeEnabled,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      theme: AppThemeMode.values.firstWhere(
        (e) => e.name == json['theme'],
        orElse: () => AppThemeMode.system,
      ),
      language: SupportedLanguage.values.firstWhere(
        (e) => e.name == json['language'],
        orElse: () => SupportedLanguage.en,
      ),
      fontSize: FontSizePreference.values.firstWhere(
        (e) => e.name == json['fontSize'],
        orElse: () => FontSizePreference.medium,
      ),
      compactMode: json['compactMode'] ?? false,
      showNumbers: json['showNumbers'] ?? true,
      autoDownload: json['autoDownload'] ?? false,
      offlineMode: json['offlineMode'] ?? false,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
      soundEnabled: json['soundEnabled'] ?? true,
      playbackSpeed: json['playbackSpeed']?.toDouble() ?? 1.0,
      autoLockTimeout: json['autoLockTimeout'] ?? 30,
      keepScreenOn: json['keepScreenOn'] ?? false,
      showChords: json['showChords'] ?? true,
      showMetadata: json['showMetadata'] ?? true,
      largeTextMode: json['largeTextMode'] ?? false,
      churchModeEnabled: json['churchModeEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme.name,
      'language': language.name,
      'fontSize': fontSize.name,
      'compactMode': compactMode,
      'showNumbers': showNumbers,
      'autoDownload': autoDownload,
      'offlineMode': offlineMode,
      'vibrationEnabled': vibrationEnabled,
      'soundEnabled': soundEnabled,
      'playbackSpeed': playbackSpeed,
      'autoLockTimeout': autoLockTimeout,
      'keepScreenOn': keepScreenOn,
      'showChords': showChords,
      'showMetadata': showMetadata,
      'largeTextMode': largeTextMode,
      'churchModeEnabled': churchModeEnabled,
    };
  }

  static UserSettings get defaultSettings => const UserSettings(
    theme: AppThemeMode.system,
    language: SupportedLanguage.en,
    fontSize: FontSizePreference.medium,
    compactMode: false,
    showNumbers: true,
    autoDownload: false,
    offlineMode: false,
    vibrationEnabled: true,
    soundEnabled: true,
    playbackSpeed: 1.0,
    autoLockTimeout: 30,
    keepScreenOn: false,
    showChords: true,
    showMetadata: true,
    largeTextMode: false,
    churchModeEnabled: false,
  );

  UserSettings copyWith({
    AppThemeMode? theme,
    SupportedLanguage? language,
    FontSizePreference? fontSize,
    bool? compactMode,
    bool? showNumbers,
    bool? autoDownload,
    bool? offlineMode,
    bool? vibrationEnabled,
    bool? soundEnabled,
    double? playbackSpeed,
    int? autoLockTimeout,
    bool? keepScreenOn,
    bool? showChords,
    bool? showMetadata,
    bool? largeTextMode,
    bool? churchModeEnabled,
  }) {
    return UserSettings(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      fontSize: fontSize ?? this.fontSize,
      compactMode: compactMode ?? this.compactMode,
      showNumbers: showNumbers ?? this.showNumbers,
      autoDownload: autoDownload ?? this.autoDownload,
      offlineMode: offlineMode ?? this.offlineMode,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      autoLockTimeout: autoLockTimeout ?? this.autoLockTimeout,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      showChords: showChords ?? this.showChords,
      showMetadata: showMetadata ?? this.showMetadata,
      largeTextMode: largeTextMode ?? this.largeTextMode,
      churchModeEnabled: churchModeEnabled ?? this.churchModeEnabled,
    );
  }
}

class SettingsProvider extends ChangeNotifier {
  static const String _settingsKey = 'user_settings';
  
  UserSettings _settings = UserSettings.defaultSettings;
  bool _isInitialized = false;
  
  UserSettings get settings => _settings;
  bool get isInitialized => _isInitialized;

  // Theme getters
  ThemeMode get themeMode {
    switch (_settings.theme) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  bool get isDarkMode {
    return _settings.theme == AppThemeMode.dark ||
        (_settings.theme == AppThemeMode.system &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark);
  }

  // Font size multiplier
  double get fontSizeMultiplier {
    switch (_settings.fontSize) {
      case FontSizePreference.small:
        return 0.85;
      case FontSizePreference.medium:
        return 1.0;
      case FontSizePreference.large:
        return 1.15;
      case FontSizePreference.extraLarge:
        return 1.3;
    }
  }

  // Language display names
  String get languageDisplayName {
    switch (_settings.language) {
      case SupportedLanguage.en:
        return 'English';
      case SupportedLanguage.sw:
        return 'Kiswahili';
      case SupportedLanguage.luo:
        return 'Luo';
      case SupportedLanguage.fr:
        return 'Français';
      case SupportedLanguage.es:
        return 'Español';
      case SupportedLanguage.de:
        return 'Deutsch';
      case SupportedLanguage.pt:
        return 'Português';
      case SupportedLanguage.it:
        return 'Italiano';
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _loadSettings();
      _isInitialized = true;
    } catch (e) {
      print('Error initializing settings: $e');
      _settings = UserSettings.defaultSettings;
      _isInitialized = true;
    }
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);
    
    if (settingsJson != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(settingsJson);
        _settings = UserSettings.fromJson(json);
      } catch (e) {
        print('Error loading settings: $e');
        _settings = UserSettings.defaultSettings;
      }
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = jsonEncode(_settings.toJson());
      await prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  // Theme settings
  Future<void> setTheme(AppThemeMode theme) async {
    if (_settings.theme != theme) {
      _settings = _settings.copyWith(theme: theme);
      await _saveSettings();
      notifyListeners();
    }
  }

  // Language settings
  Future<void> setLanguage(SupportedLanguage language) async {
    if (_settings.language != language) {
      _settings = _settings.copyWith(language: language);
      await _saveSettings();
      notifyListeners();
    }
  }

  // Font size settings
  Future<void> setFontSize(FontSizePreference fontSize) async {
    if (_settings.fontSize != fontSize) {
      _settings = _settings.copyWith(fontSize: fontSize);
      await _saveSettings();
      notifyListeners();
    }
  }

  // Display settings
  Future<void> setCompactMode(bool compactMode) async {
    if (_settings.compactMode != compactMode) {
      _settings = _settings.copyWith(compactMode: compactMode);
      await _saveSettings();
      notifyListeners();
    }
  }

  Future<void> setShowNumbers(bool showNumbers) async {
    if (_settings.showNumbers != showNumbers) {
      _settings = _settings.copyWith(showNumbers: showNumbers);
      await _saveSettings();
      notifyListeners();
    }
  }

  Future<void> setLargeTextMode(bool largeTextMode) async {
    if (_settings.largeTextMode != largeTextMode) {
      _settings = _settings.copyWith(largeTextMode: largeTextMode);
      await _saveSettings();
      notifyListeners();
    }
  }

  // Church mode settings
  Future<void> setChurchMode(bool churchModeEnabled) async {
    if (_settings.churchModeEnabled != churchModeEnabled) {
      _settings = _settings.copyWith(churchModeEnabled: churchModeEnabled);
      await _saveSettings();
      
      // Sync with church mode service
      await ChurchModeService().setChurchMode(churchModeEnabled);
      
      notifyListeners();
    }
  }

  Future<void> setShowChords(bool showChords) async {
    if (_settings.showChords != showChords) {
      _settings = _settings.copyWith(showChords: showChords);
      await _saveSettings();
      notifyListeners();
    }
  }

  Future<void> setShowMetadata(bool showMetadata) async {
    if (_settings.showMetadata != showMetadata) {
      _settings = _settings.copyWith(showMetadata: showMetadata);
      await _saveSettings();
      notifyListeners();
    }
  }

  // Download settings
  Future<void> setAutoDownload(bool autoDownload) async {
    if (_settings.autoDownload != autoDownload) {
      _settings = _settings.copyWith(autoDownload: autoDownload);
      await _saveSettings();
      notifyListeners();
    }
  }

  Future<void> setOfflineMode(bool offlineMode) async {
    if (_settings.offlineMode != offlineMode) {
      _settings = _settings.copyWith(offlineMode: offlineMode);
      await _saveSettings();
      notifyListeners();
    }
  }

  // Audio settings
  Future<void> setSoundEnabled(bool soundEnabled) async {
    if (_settings.soundEnabled != soundEnabled) {
      _settings = _settings.copyWith(soundEnabled: soundEnabled);
      await _saveSettings();
      notifyListeners();
    }
  }

  Future<void> setVibrationEnabled(bool vibrationEnabled) async {
    if (_settings.vibrationEnabled != vibrationEnabled) {
      _settings = _settings.copyWith(vibrationEnabled: vibrationEnabled);
      await _saveSettings();
      notifyListeners();
    }
  }

  Future<void> setPlaybackSpeed(double playbackSpeed) async {
    if (_settings.playbackSpeed != playbackSpeed) {
      _settings = _settings.copyWith(playbackSpeed: playbackSpeed);
      await _saveSettings();
      notifyListeners();
    }
  }

  // Screen settings
  Future<void> setKeepScreenOn(bool keepScreenOn) async {
    if (_settings.keepScreenOn != keepScreenOn) {
      _settings = _settings.copyWith(keepScreenOn: keepScreenOn);
      await _saveSettings();
      notifyListeners();
    }
  }

  Future<void> setAutoLockTimeout(int autoLockTimeout) async {
    if (_settings.autoLockTimeout != autoLockTimeout) {
      _settings = _settings.copyWith(autoLockTimeout: autoLockTimeout);
      await _saveSettings();
      notifyListeners();
    }
  }

  // Reset settings
  Future<void> resetToDefaults() async {
    _settings = UserSettings.defaultSettings;
    await _saveSettings();
    notifyListeners();
  }

  // Clear all data
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _settings = UserSettings.defaultSettings;
      notifyListeners();
    } catch (e) {
      print('Error clearing data: $e');
    }
  }
}