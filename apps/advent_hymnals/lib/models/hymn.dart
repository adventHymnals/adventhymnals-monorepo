import 'package:json_annotation/json_annotation.dart';

part 'hymn.g.dart';

@JsonSerializable()
class HymnVerse {
  final int number;
  final String text;

  const HymnVerse({
    required this.number,
    required this.text,
  });

  factory HymnVerse.fromJson(Map<String, dynamic> json) =>
      _$HymnVerseFromJson(json);

  Map<String, dynamic> toJson() => _$HymnVerseToJson(this);
}

@JsonSerializable()
class HymnChorus {
  final String text;

  const HymnChorus({required this.text});

  factory HymnChorus.fromJson(Map<String, dynamic> json) =>
      _$HymnChorusFromJson(json);

  Map<String, dynamic> toJson() => _$HymnChorusToJson(this);
}

@JsonSerializable()
class HymnMetadata {
  final int? year;
  final String? copyright;
  final List<String>? themes;
  @JsonKey(name: 'scripture_references')
  final List<String>? scriptureReferences;
  @JsonKey(name: 'tune_source')
  final String? tuneSource;
  @JsonKey(name: 'original_language')
  final String? originalLanguage;
  final String? translator;

  const HymnMetadata({
    this.year,
    this.copyright,
    this.themes,
    this.scriptureReferences,
    this.tuneSource,
    this.originalLanguage,
    this.translator,
  });

  factory HymnMetadata.fromJson(Map<String, dynamic> json) =>
      _$HymnMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$HymnMetadataToJson(this);
}

enum NotationFormat {
  @JsonValue('lyrics')
  lyrics,
  @JsonValue('solfa')
  solfa,
  @JsonValue('staff')
  staff,
  @JsonValue('chord')
  chord,
}

enum NotationQuality {
  @JsonValue('high')
  high,
  @JsonValue('medium')
  medium,
  @JsonValue('low')
  low,
}

@JsonSerializable()
class HymnNotation {
  final NotationFormat format;
  final String content;
  final String? source;
  final NotationQuality? quality;

  const HymnNotation({
    required this.format,
    required this.content,
    this.source,
    this.quality,
  });

  factory HymnNotation.fromJson(Map<String, dynamic> json) =>
      _$HymnNotationFromJson(json);

  Map<String, dynamic> toJson() => _$HymnNotationToJson(this);
}

@JsonSerializable()
class Hymn {
  final String id;
  final int number;
  final String title;
  final String? author;
  final String? composer;
  final String? tune;
  final String? meter;
  final String language;
  final List<HymnVerse> verses;
  final HymnChorus? chorus;
  final HymnMetadata? metadata;
  final List<HymnNotation>? notations;

  const Hymn({
    required this.id,
    required this.number,
    required this.title,
    required this.language,
    required this.verses,
    this.author,
    this.composer,
    this.tune,
    this.meter,
    this.chorus,
    this.metadata,
    this.notations,
  });

  factory Hymn.fromJson(Map<String, dynamic> json) => _$HymnFromJson(json);

  Map<String, dynamic> toJson() => _$HymnToJson(this);
}