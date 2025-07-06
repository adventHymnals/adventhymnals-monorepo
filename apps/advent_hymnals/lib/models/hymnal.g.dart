// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hymnal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HymnalEntry _$HymnalEntryFromJson(Map<String, dynamic> json) => HymnalEntry(
      number: (json['number'] as num).toInt(),
      hymnId: json['hymn_id'] as String,
      title: json['title'] as String?,
      page: (json['page'] as num?)?.toInt(),
    );

Map<String, dynamic> _$HymnalEntryToJson(HymnalEntry instance) =>
    <String, dynamic>{
      'number': instance.number,
      'hymn_id': instance.hymnId,
      'title': instance.title,
      'page': instance.page,
    };

PublicationInfo _$PublicationInfoFromJson(Map<String, dynamic> json) =>
    PublicationInfo(
      publisher: json['publisher'] as String?,
      place: json['place'] as String?,
      isbn: json['isbn'] as String?,
    );

Map<String, dynamic> _$PublicationInfoToJson(PublicationInfo instance) =>
    <String, dynamic>{
      'publisher': instance.publisher,
      'place': instance.place,
      'isbn': instance.isbn,
    };

HymnalMetadata _$HymnalMetadataFromJson(Map<String, dynamic> json) =>
    HymnalMetadata(
      totalHymns: (json['total_hymns'] as num).toInt(),
      languages:
          (json['languages'] as List<dynamic>).map((e) => e as String).toList(),
      themes:
          (json['themes'] as List<dynamic>).map((e) => e as String).toList(),
      publicationInfo: json['publication_info'] == null
          ? null
          : PublicationInfo.fromJson(
              json['publication_info'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$HymnalMetadataToJson(HymnalMetadata instance) =>
    <String, dynamic>{
      'total_hymns': instance.totalHymns,
      'languages': instance.languages,
      'themes': instance.themes,
      'publication_info': instance.publicationInfo,
    };

Hymnal _$HymnalFromJson(Map<String, dynamic> json) => Hymnal(
      id: json['id'] as String,
      title: json['title'] as String,
      language: json['language'] as String,
      year: (json['year'] as num).toInt(),
      hymns: (json['hymns'] as List<dynamic>)
          .map((e) => HymnalEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata:
          HymnalMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
      publisher: json['publisher'] as String?,
    );

Map<String, dynamic> _$HymnalToJson(Hymnal instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'language': instance.language,
      'year': instance.year,
      'publisher': instance.publisher,
      'hymns': instance.hymns,
      'metadata': instance.metadata,
    };

HymnalPart _$HymnalPartFromJson(Map<String, dynamic> json) => HymnalPart(
      type: json['type'] as String,
      songs: (json['songs'] as num).toInt(),
    );

Map<String, dynamic> _$HymnalPartToJson(HymnalPart instance) =>
    <String, dynamic>{
      'type': instance.type,
      'songs': instance.songs,
    };

HymnalResources _$HymnalResourcesFromJson(Map<String, dynamic> json) =>
    HymnalResources(
      pdf: json['pdf'] as String?,
      html: json['html'] as String?,
      images: json['images'] as String?,
    );

Map<String, dynamic> _$HymnalResourcesToJson(HymnalResources instance) =>
    <String, dynamic>{
      'pdf': instance.pdf,
      'html': instance.html,
      'images': instance.images,
    };

HymnalMusic _$HymnalMusicFromJson(Map<String, dynamic> json) => HymnalMusic(
      midi: json['midi'],
      mp3: json['mp3'] as String?,
    );

Map<String, dynamic> _$HymnalMusicToJson(HymnalMusic instance) =>
    <String, dynamic>{
      'midi': instance.midi,
      'mp3': instance.mp3,
    };

HymnalReference _$HymnalReferenceFromJson(Map<String, dynamic> json) =>
    HymnalReference(
      id: json['id'] as String,
      name: json['name'] as String,
      abbreviation: json['abbreviation'] as String,
      year: (json['year'] as num).toInt(),
      totalSongs: (json['total_songs'] as num).toInt(),
      language: $enumDecode(_$SupportedLanguageEnumMap, json['language']),
      languageName: json['language_name'] as String,
      siteName: json['site_name'] as String,
      urlSlug: json['url_slug'] as String,
      compiler: json['compiler'] as String?,
      parts: (json['parts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, HymnalPart.fromJson(e as Map<String, dynamic>)),
      ),
      separateParts: (json['separate_parts'] as num?)?.toInt(),
      githubLink: json['github_link'] as String?,
      resources: json['resources'] == null
          ? null
          : HymnalResources.fromJson(json['resources'] as Map<String, dynamic>),
      music: json['music'] == null
          ? null
          : HymnalMusic.fromJson(json['music'] as Map<String, dynamic>),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$HymnalReferenceToJson(HymnalReference instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'abbreviation': instance.abbreviation,
      'year': instance.year,
      'total_songs': instance.totalSongs,
      'language': _$SupportedLanguageEnumMap[instance.language]!,
      'language_name': instance.languageName,
      'compiler': instance.compiler,
      'site_name': instance.siteName,
      'url_slug': instance.urlSlug,
      'parts': instance.parts,
      'separate_parts': instance.separateParts,
      'github_link': instance.githubLink,
      'resources': instance.resources,
      'music': instance.music,
      'note': instance.note,
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

DateRange _$DateRangeFromJson(Map<String, dynamic> json) => DateRange(
      earliest: (json['earliest'] as num).toInt(),
      latest: (json['latest'] as num).toInt(),
    );

Map<String, dynamic> _$DateRangeToJson(DateRange instance) => <String, dynamic>{
      'earliest': instance.earliest,
      'latest': instance.latest,
    };

CollectionMetadata _$CollectionMetadataFromJson(Map<String, dynamic> json) =>
    CollectionMetadata(
      totalHymnals: (json['total_hymnals'] as num).toInt(),
      dateRange: DateRange.fromJson(json['date_range'] as Map<String, dynamic>),
      languagesSupported: (json['languages_supported'] as List<dynamic>)
          .map((e) => $enumDecode(_$SupportedLanguageEnumMap, e))
          .toList(),
      totalEstimatedSongs: (json['total_estimated_songs'] as num).toInt(),
      source: json['source'] as String,
      generatedDate: json['generated_date'] as String,
    );

Map<String, dynamic> _$CollectionMetadataToJson(CollectionMetadata instance) =>
    <String, dynamic>{
      'total_hymnals': instance.totalHymnals,
      'date_range': instance.dateRange,
      'languages_supported': instance.languagesSupported
          .map((e) => _$SupportedLanguageEnumMap[e]!)
          .toList(),
      'total_estimated_songs': instance.totalEstimatedSongs,
      'source': instance.source,
      'generated_date': instance.generatedDate,
    };

HymnalCollection _$HymnalCollectionFromJson(Map<String, dynamic> json) =>
    HymnalCollection(
      hymnals: (json['hymnals'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, HymnalReference.fromJson(e as Map<String, dynamic>)),
      ),
      languages: Map<String, String>.from(json['languages'] as Map),
      metadata:
          CollectionMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$HymnalCollectionToJson(HymnalCollection instance) =>
    <String, dynamic>{
      'hymnals': instance.hymnals,
      'languages': instance.languages,
      'metadata': instance.metadata,
    };
