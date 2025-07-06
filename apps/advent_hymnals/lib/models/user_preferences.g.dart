// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) =>
    UserPreferences(
      theme: $enumDecode(_$ThemeModeEnumMap, json['theme']),
      language: $enumDecode(_$SupportedLanguageEnumMap, json['language']),
      fontSize: $enumDecode(_$FontSizePreferenceEnumMap, json['fontSize']),
      compactMode: json['compactMode'] as bool,
      showNumbers: json['showNumbers'] as bool,
      favorites:
          (json['favorites'] as List<dynamic>).map((e) => e as String).toList(),
      recentlyViewed: (json['recentlyViewed'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$UserPreferencesToJson(UserPreferences instance) =>
    <String, dynamic>{
      'theme': _$ThemeModeEnumMap[instance.theme]!,
      'language': _$SupportedLanguageEnumMap[instance.language]!,
      'fontSize': _$FontSizePreferenceEnumMap[instance.fontSize]!,
      'compactMode': instance.compactMode,
      'showNumbers': instance.showNumbers,
      'favorites': instance.favorites,
      'recentlyViewed': instance.recentlyViewed,
    };

const _$ThemeModeEnumMap = {
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
  ThemeMode.system: 'system',
};

const _$SupportedLanguageEnumMap = {
  SupportedLanguage.en: 'en',
  SupportedLanguage.sw: 'sw',
  SupportedLanguage.luo: 'luo',
  SupportedLanguage.fr: 'fr',
  SupportedLanguage.es: 'es',
  SupportedLanguage.de: 'de',
  SupportedLanguage.pt: 'pt',
  SupportedLanguage.it: 'it',
};

const _$FontSizePreferenceEnumMap = {
  FontSizePreference.small: 'small',
  FontSizePreference.medium: 'medium',
  FontSizePreference.large: 'large',
};
