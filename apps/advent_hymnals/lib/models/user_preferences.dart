import 'package:json_annotation/json_annotation.dart';
import 'hymnal.dart';

part 'user_preferences.g.dart';

enum ThemeMode {
  @JsonValue('light')
  light,
  @JsonValue('dark')
  dark,
  @JsonValue('system')
  system,
}

enum FontSizePreference {
  @JsonValue('small')
  small,
  @JsonValue('medium')
  medium,
  @JsonValue('large')
  large,
}

@JsonSerializable()
class UserPreferences {
  final ThemeMode theme;
  final SupportedLanguage language;
  final FontSizePreference fontSize;
  final bool compactMode;
  final bool showNumbers;
  final List<String> favorites;
  final List<String> recentlyViewed;

  const UserPreferences({
    required this.theme,
    required this.language,
    required this.fontSize,
    required this.compactMode,
    required this.showNumbers,
    required this.favorites,
    required this.recentlyViewed,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$UserPreferencesToJson(this);

  static UserPreferences get defaultPreferences => const UserPreferences(
        theme: ThemeMode.system,
        language: SupportedLanguage.en,
        fontSize: FontSizePreference.medium,
        compactMode: false,
        showNumbers: true,
        favorites: [],
        recentlyViewed: [],
      );

  UserPreferences copyWith({
    ThemeMode? theme,
    SupportedLanguage? language,
    FontSizePreference? fontSize,
    bool? compactMode,
    bool? showNumbers,
    List<String>? favorites,
    List<String>? recentlyViewed,
  }) {
    return UserPreferences(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      fontSize: fontSize ?? this.fontSize,
      compactMode: compactMode ?? this.compactMode,
      showNumbers: showNumbers ?? this.showNumbers,
      favorites: favorites ?? this.favorites,
      recentlyViewed: recentlyViewed ?? this.recentlyViewed,
    );
  }
}