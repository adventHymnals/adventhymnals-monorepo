// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hymn.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HymnVerse _$HymnVerseFromJson(Map<String, dynamic> json) => HymnVerse(
      number: (json['number'] as num).toInt(),
      text: json['text'] as String,
    );

Map<String, dynamic> _$HymnVerseToJson(HymnVerse instance) => <String, dynamic>{
      'number': instance.number,
      'text': instance.text,
    };

HymnChorus _$HymnChorusFromJson(Map<String, dynamic> json) => HymnChorus(
      text: json['text'] as String,
    );

Map<String, dynamic> _$HymnChorusToJson(HymnChorus instance) =>
    <String, dynamic>{
      'text': instance.text,
    };

HymnMetadata _$HymnMetadataFromJson(Map<String, dynamic> json) => HymnMetadata(
      year: (json['year'] as num?)?.toInt(),
      copyright: json['copyright'] as String?,
      themes:
          (json['themes'] as List<dynamic>?)?.map((e) => e as String).toList(),
      scriptureReferences: (json['scripture_references'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      tuneSource: json['tune_source'] as String?,
      originalLanguage: json['original_language'] as String?,
      translator: json['translator'] as String?,
    );

Map<String, dynamic> _$HymnMetadataToJson(HymnMetadata instance) =>
    <String, dynamic>{
      'year': instance.year,
      'copyright': instance.copyright,
      'themes': instance.themes,
      'scripture_references': instance.scriptureReferences,
      'tune_source': instance.tuneSource,
      'original_language': instance.originalLanguage,
      'translator': instance.translator,
    };

HymnNotation _$HymnNotationFromJson(Map<String, dynamic> json) => HymnNotation(
      format: $enumDecode(_$NotationFormatEnumMap, json['format']),
      content: json['content'] as String,
      source: json['source'] as String?,
      quality: $enumDecodeNullable(_$NotationQualityEnumMap, json['quality']),
    );

Map<String, dynamic> _$HymnNotationToJson(HymnNotation instance) =>
    <String, dynamic>{
      'format': _$NotationFormatEnumMap[instance.format]!,
      'content': instance.content,
      'source': instance.source,
      'quality': _$NotationQualityEnumMap[instance.quality],
    };

const _$NotationFormatEnumMap = {
  NotationFormat.lyrics: 'lyrics',
  NotationFormat.solfa: 'solfa',
  NotationFormat.staff: 'staff',
  NotationFormat.chord: 'chord',
};

const _$NotationQualityEnumMap = {
  NotationQuality.high: 'high',
  NotationQuality.medium: 'medium',
  NotationQuality.low: 'low',
};

Hymn _$HymnFromJson(Map<String, dynamic> json) => Hymn(
      id: json['id'] as String,
      number: (json['number'] as num).toInt(),
      title: json['title'] as String,
      language: json['language'] as String,
      verses: (json['verses'] as List<dynamic>)
          .map((e) => HymnVerse.fromJson(e as Map<String, dynamic>))
          .toList(),
      author: json['author'] as String?,
      composer: json['composer'] as String?,
      tune: json['tune'] as String?,
      meter: json['meter'] as String?,
      chorus: json['chorus'] == null
          ? null
          : HymnChorus.fromJson(json['chorus'] as Map<String, dynamic>),
      metadata: json['metadata'] == null
          ? null
          : HymnMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
      notations: (json['notations'] as List<dynamic>?)
          ?.map((e) => HymnNotation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$HymnToJson(Hymn instance) => <String, dynamic>{
      'id': instance.id,
      'number': instance.number,
      'title': instance.title,
      'author': instance.author,
      'composer': instance.composer,
      'tune': instance.tune,
      'meter': instance.meter,
      'language': instance.language,
      'verses': instance.verses,
      'chorus': instance.chorus,
      'metadata': instance.metadata,
      'notations': instance.notations,
    };
