// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'projection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SlideMetadata _$SlideMetadataFromJson(Map<String, dynamic> json) =>
    SlideMetadata(
      verseNumber: (json['verseNumber'] as num?)?.toInt(),
      isChorus: json['isChorus'] as bool?,
      title: json['title'] as String?,
      author: json['author'] as String?,
    );

Map<String, dynamic> _$SlideMetadataToJson(SlideMetadata instance) =>
    <String, dynamic>{
      'verseNumber': instance.verseNumber,
      'isChorus': instance.isChorus,
      'title': instance.title,
      'author': instance.author,
    };

ProjectionSlide _$ProjectionSlideFromJson(Map<String, dynamic> json) =>
    ProjectionSlide(
      id: json['id'] as String,
      type: $enumDecode(_$SlideTypeEnumMap, json['type']),
      content: json['content'] as String,
      number: (json['number'] as num?)?.toInt(),
      metadata: json['metadata'] == null
          ? null
          : SlideMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProjectionSlideToJson(ProjectionSlide instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$SlideTypeEnumMap[instance.type]!,
      'content': instance.content,
      'number': instance.number,
      'metadata': instance.metadata,
    };

const _$SlideTypeEnumMap = {
  SlideType.verse: 'verse',
  SlideType.chorus: 'chorus',
  SlideType.title: 'title',
  SlideType.metadata: 'metadata',
};

ProjectionSettings _$ProjectionSettingsFromJson(Map<String, dynamic> json) =>
    ProjectionSettings(
      showVerseNumbers: json['showVerseNumbers'] as bool,
      showChorusAfterEachVerse: json['showChorusAfterEachVerse'] as bool,
      fontSize: $enumDecode(_$FontSizeEnumMap, json['fontSize']),
      theme: $enumDecode(_$ProjectionThemeEnumMap, json['theme']),
      showMetadata: json['showMetadata'] as bool,
      autoAdvance: json['autoAdvance'] as bool,
      autoAdvanceDelay: (json['autoAdvanceDelay'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ProjectionSettingsToJson(ProjectionSettings instance) =>
    <String, dynamic>{
      'showVerseNumbers': instance.showVerseNumbers,
      'showChorusAfterEachVerse': instance.showChorusAfterEachVerse,
      'fontSize': _$FontSizeEnumMap[instance.fontSize]!,
      'theme': _$ProjectionThemeEnumMap[instance.theme]!,
      'showMetadata': instance.showMetadata,
      'autoAdvance': instance.autoAdvance,
      'autoAdvanceDelay': instance.autoAdvanceDelay,
    };

const _$FontSizeEnumMap = {
  FontSize.small: 'small',
  FontSize.medium: 'medium',
  FontSize.large: 'large',
  FontSize.extraLarge: 'extra-large',
};

const _$ProjectionThemeEnumMap = {
  ProjectionTheme.light: 'light',
  ProjectionTheme.dark: 'dark',
  ProjectionTheme.highContrast: 'high-contrast',
};

ProjectionSession _$ProjectionSessionFromJson(Map<String, dynamic> json) =>
    ProjectionSession(
      hymn: Hymn.fromJson(json['hymn'] as Map<String, dynamic>),
      slides: (json['slides'] as List<dynamic>)
          .map((e) => ProjectionSlide.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentSlide: (json['currentSlide'] as num).toInt(),
      settings:
          ProjectionSettings.fromJson(json['settings'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProjectionSessionToJson(ProjectionSession instance) =>
    <String, dynamic>{
      'hymn': instance.hymn,
      'slides': instance.slides,
      'currentSlide': instance.currentSlide,
      'settings': instance.settings,
    };
