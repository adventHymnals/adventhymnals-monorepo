import 'package:json_annotation/json_annotation.dart';
import 'hymn.dart';

part 'projection.g.dart';

enum SlideType {
  @JsonValue('verse')
  verse,
  @JsonValue('chorus')
  chorus,
  @JsonValue('title')
  title,
  @JsonValue('metadata')
  metadata,
}

@JsonSerializable()
class SlideMetadata {
  @JsonKey(name: 'verseNumber')
  final int? verseNumber;
  @JsonKey(name: 'isChorus')
  final bool? isChorus;
  final String? title;
  final String? author;

  const SlideMetadata({
    this.verseNumber,
    this.isChorus,
    this.title,
    this.author,
  });

  factory SlideMetadata.fromJson(Map<String, dynamic> json) =>
      _$SlideMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$SlideMetadataToJson(this);
}

@JsonSerializable()
class ProjectionSlide {
  final String id;
  final SlideType type;
  final String content;
  final int? number;
  final SlideMetadata? metadata;

  const ProjectionSlide({
    required this.id,
    required this.type,
    required this.content,
    this.number,
    this.metadata,
  });

  factory ProjectionSlide.fromJson(Map<String, dynamic> json) =>
      _$ProjectionSlideFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectionSlideToJson(this);
}

enum FontSize {
  @JsonValue('small')
  small,
  @JsonValue('medium')
  medium,
  @JsonValue('large')
  large,
  @JsonValue('extra-large')
  extraLarge,
}

enum ProjectionTheme {
  @JsonValue('light')
  light,
  @JsonValue('dark')
  dark,
  @JsonValue('high-contrast')
  highContrast,
}

@JsonSerializable()
class ProjectionSettings {
  @JsonKey(name: 'showVerseNumbers')
  final bool showVerseNumbers;
  @JsonKey(name: 'showChorusAfterEachVerse')
  final bool showChorusAfterEachVerse;
  final FontSize fontSize;
  final ProjectionTheme theme;
  @JsonKey(name: 'showMetadata')
  final bool showMetadata;
  @JsonKey(name: 'autoAdvance')
  final bool autoAdvance;
  @JsonKey(name: 'autoAdvanceDelay')
  final int? autoAdvanceDelay;

  const ProjectionSettings({
    required this.showVerseNumbers,
    required this.showChorusAfterEachVerse,
    required this.fontSize,
    required this.theme,
    required this.showMetadata,
    required this.autoAdvance,
    this.autoAdvanceDelay,
  });

  factory ProjectionSettings.fromJson(Map<String, dynamic> json) =>
      _$ProjectionSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectionSettingsToJson(this);

  static ProjectionSettings get defaultSettings => const ProjectionSettings(
        showVerseNumbers: true,
        showChorusAfterEachVerse: false,
        fontSize: FontSize.medium,
        theme: ProjectionTheme.light,
        showMetadata: true,
        autoAdvance: false,
      );

  ProjectionSettings copyWith({
    bool? showVerseNumbers,
    bool? showChorusAfterEachVerse,
    FontSize? fontSize,
    ProjectionTheme? theme,
    bool? showMetadata,
    bool? autoAdvance,
    int? autoAdvanceDelay,
  }) {
    return ProjectionSettings(
      showVerseNumbers: showVerseNumbers ?? this.showVerseNumbers,
      showChorusAfterEachVerse: showChorusAfterEachVerse ?? this.showChorusAfterEachVerse,
      fontSize: fontSize ?? this.fontSize,
      theme: theme ?? this.theme,
      showMetadata: showMetadata ?? this.showMetadata,
      autoAdvance: autoAdvance ?? this.autoAdvance,
      autoAdvanceDelay: autoAdvanceDelay ?? this.autoAdvanceDelay,
    );
  }
}

@JsonSerializable()
class ProjectionSession {
  final Hymn hymn;
  final List<ProjectionSlide> slides;
  @JsonKey(name: 'currentSlide')
  final int currentSlide;
  final ProjectionSettings settings;

  const ProjectionSession({
    required this.hymn,
    required this.slides,
    required this.currentSlide,
    required this.settings,
  });

  factory ProjectionSession.fromJson(Map<String, dynamic> json) =>
      _$ProjectionSessionFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectionSessionToJson(this);
}