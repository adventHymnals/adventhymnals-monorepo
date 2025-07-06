import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_preferences.dart';
import '../models/hymnal.dart';

class PreferencesService {
  static const String _prefsKey = 'user_preferences';
  static const String _favoritesKey = 'favorites';
  static const String _recentlyViewedKey = 'recently_viewed';

  static PreferencesService? _instance;
  static PreferencesService get instance => _instance ??= PreferencesService._();

  PreferencesService._();

  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  Future<UserPreferences> getUserPreferences() async {
    await initialize();
    
    final prefsJson = _prefs.getString(_prefsKey);
    if (prefsJson != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(prefsJson);
        return UserPreferences.fromJson(json);
      } catch (e) {
        print('Error loading user preferences: $e');
        return UserPreferences.defaultPreferences;
      }
    }
    
    return UserPreferences.defaultPreferences;
  }

  Future<void> saveUserPreferences(UserPreferences preferences) async {
    await initialize();
    
    try {
      final prefsJson = jsonEncode(preferences.toJson());
      await _prefs.setString(_prefsKey, prefsJson);
    } catch (e) {
      print('Error saving user preferences: $e');
    }
  }

  Future<List<String>> getFavorites() async {
    await initialize();
    return _prefs.getStringList(_favoritesKey) ?? [];
  }

  Future<void> addToFavorites(String hymnId) async {
    await initialize();
    
    final favorites = await getFavorites();
    if (!favorites.contains(hymnId)) {
      favorites.add(hymnId);
      await _prefs.setStringList(_favoritesKey, favorites);
    }
  }

  Future<void> removeFromFavorites(String hymnId) async {
    await initialize();
    
    final favorites = await getFavorites();
    favorites.remove(hymnId);
    await _prefs.setStringList(_favoritesKey, favorites);
  }

  Future<bool> isFavorite(String hymnId) async {
    final favorites = await getFavorites();
    return favorites.contains(hymnId);
  }

  Future<List<String>> getRecentlyViewed() async {
    await initialize();
    return _prefs.getStringList(_recentlyViewedKey) ?? [];
  }

  Future<void> addToRecentlyViewed(String hymnId) async {
    await initialize();
    
    final recentlyViewed = await getRecentlyViewed();
    
    // Remove if already exists to avoid duplicates
    recentlyViewed.remove(hymnId);
    
    // Add to beginning
    recentlyViewed.insert(0, hymnId);
    
    // Keep only the last 50 items
    if (recentlyViewed.length > 50) {
      recentlyViewed.removeRange(50, recentlyViewed.length);
    }
    
    await _prefs.setStringList(_recentlyViewedKey, recentlyViewed);
  }

  Future<void> clearRecentlyViewed() async {
    await initialize();
    await _prefs.remove(_recentlyViewedKey);
  }

  Future<void> clearAllData() async {
    await initialize();
    await _prefs.clear();
  }

  // Theme-specific helpers
  Future<ThemeMode> getThemeMode() async {
    final prefs = await getUserPreferences();
    return prefs.theme;
  }

  Future<void> setThemeMode(ThemeMode theme) async {
    final prefs = await getUserPreferences();
    await saveUserPreferences(prefs.copyWith(theme: theme));
  }

  // Language-specific helpers
  Future<SupportedLanguage> getLanguage() async {
    final prefs = await getUserPreferences();
    return prefs.language;
  }

  Future<void> setLanguage(SupportedLanguage language) async {
    final prefs = await getUserPreferences();
    await saveUserPreferences(prefs.copyWith(language: language));
  }

  // Font size helpers
  Future<FontSizePreference> getFontSize() async {
    final prefs = await getUserPreferences();
    return prefs.fontSize;
  }

  Future<void> setFontSize(FontSizePreference fontSize) async {
    final prefs = await getUserPreferences();
    await saveUserPreferences(prefs.copyWith(fontSize: fontSize));
  }

  // Display options
  Future<bool> getCompactMode() async {
    final prefs = await getUserPreferences();
    return prefs.compactMode;
  }

  Future<void> setCompactMode(bool compactMode) async {
    final prefs = await getUserPreferences();
    await saveUserPreferences(prefs.copyWith(compactMode: compactMode));
  }

  Future<bool> getShowNumbers() async {
    final prefs = await getUserPreferences();
    return prefs.showNumbers;
  }

  Future<void> setShowNumbers(bool showNumbers) async {
    final prefs = await getUserPreferences();
    await saveUserPreferences(prefs.copyWith(showNumbers: showNumbers));
  }
}