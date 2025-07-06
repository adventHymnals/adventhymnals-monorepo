import 'package:json_annotation/json_annotation.dart';

part 'hymnal.g.dart';

@JsonSerializable()
class HymnalEntry {
  final int number;
  @JsonKey(name: 'hymn_id')
  final String hymnId;
  final String? title;
  final int? page;

  const HymnalEntry({
    required this.number,
    required this.hymnId,
    this.title,
    this.page,
  });

  factory HymnalEntry.fromJson(Map<String, dynamic> json) =>
      _$HymnalEntryFromJson(json);

  Map<String, dynamic> toJson() => _$HymnalEntryToJson(this);
}

@JsonSerializable()
class PublicationInfo {
  final String? publisher;
  final String? place;
  final String? isbn;

  const PublicationInfo({
    this.publisher,
    this.place,
    this.isbn,
  });

  factory PublicationInfo.fromJson(Map<String, dynamic> json) =>
      _$PublicationInfoFromJson(json);

  Map<String, dynamic> toJson() => _$PublicationInfoToJson(this);
}

@JsonSerializable()
class HymnalMetadata {
  @JsonKey(name: 'total_hymns')
  final int totalHymns;
  final List<String> languages;
  final List<String> themes;
  @JsonKey(name: 'publication_info')
  final PublicationInfo? publicationInfo;

  const HymnalMetadata({
    required this.totalHymns,
    required this.languages,
    required this.themes,
    this.publicationInfo,
  });

  factory HymnalMetadata.fromJson(Map<String, dynamic> json) =>
      _$HymnalMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$HymnalMetadataToJson(this);
}

@JsonSerializable()
class Hymnal {
  final String id;
  final String title;
  final String language;
  final int year;
  final String? publisher;
  final List<HymnalEntry> hymns;
  final HymnalMetadata metadata;

  const Hymnal({
    required this.id,
    required this.title,
    required this.language,
    required this.year,
    required this.hymns,
    required this.metadata,
    this.publisher,
  });

  factory Hymnal.fromJson(Map<String, dynamic> json) =>
      _$HymnalFromJson(json);

  Map<String, dynamic> toJson() => _$HymnalToJson(this);
}

enum SupportedLanguage {
  @JsonValue('en')
  en,
  @JsonValue('sw')
  sw,
  @JsonValue('luo')
  luo,
  @JsonValue('fr')
  fr,
  @JsonValue('es')
  es,
  @JsonValue('de')
  de,
  @JsonValue('pt')
  pt,
  @JsonValue('it')
  it,
}

@JsonSerializable()
class HymnalPart {
  final String type;
  final int songs;

  const HymnalPart({
    required this.type,
    required this.songs,
  });

  factory HymnalPart.fromJson(Map<String, dynamic> json) =>
      _$HymnalPartFromJson(json);

  Map<String, dynamic> toJson() => _$HymnalPartToJson(this);
}

@JsonSerializable()
class HymnalResources {
  final String? pdf;
  final String? html;
  final String? images;

  const HymnalResources({
    this.pdf,
    this.html,
    this.images,
  });

  factory HymnalResources.fromJson(Map<String, dynamic> json) =>
      _$HymnalResourcesFromJson(json);

  Map<String, dynamic> toJson() => _$HymnalResourcesToJson(this);
}

@JsonSerializable()
class HymnalMusic {
  final dynamic midi; // Can be String or List<String>
  final String? mp3;

  const HymnalMusic({
    this.midi,
    this.mp3,
  });

  factory HymnalMusic.fromJson(Map<String, dynamic> json) =>
      _$HymnalMusicFromJson(json);

  Map<String, dynamic> toJson() => _$HymnalMusicToJson(this);
}

@JsonSerializable()
class HymnalReference {
  final String id;
  final String name;
  final String abbreviation;
  final int year;
  @JsonKey(name: 'total_songs')
  final int totalSongs;
  final SupportedLanguage language;
  @JsonKey(name: 'language_name')
  final String languageName;
  final String? compiler;
  @JsonKey(name: 'site_name')
  final String siteName;
  @JsonKey(name: 'url_slug')
  final String urlSlug;
  final Map<String, HymnalPart>? parts;
  @JsonKey(name: 'separate_parts')
  final int? separateParts;
  @JsonKey(name: 'github_link')
  final String? githubLink;
  final HymnalResources? resources;
  final HymnalMusic? music;
  final String? note;

  const HymnalReference({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.year,
    required this.totalSongs,
    required this.language,
    required this.languageName,
    required this.siteName,
    required this.urlSlug,
    this.compiler,
    this.parts,
    this.separateParts,
    this.githubLink,
    this.resources,
    this.music,
    this.note,
  });

  factory HymnalReference.fromJson(Map<String, dynamic> json) =>
      _$HymnalReferenceFromJson(json);

  Map<String, dynamic> toJson() => _$HymnalReferenceToJson(this);
}

@JsonSerializable()
class DateRange {
  final int earliest;
  final int latest;

  const DateRange({
    required this.earliest,
    required this.latest,
  });

  factory DateRange.fromJson(Map<String, dynamic> json) =>
      _$DateRangeFromJson(json);

  Map<String, dynamic> toJson() => _$DateRangeToJson(this);
}

@JsonSerializable()
class CollectionMetadata {
  @JsonKey(name: 'total_hymnals')
  final int totalHymnals;
  @JsonKey(name: 'date_range')
  final DateRange dateRange;
  @JsonKey(name: 'languages_supported')
  final List<SupportedLanguage> languagesSupported;
  @JsonKey(name: 'total_estimated_songs')
  final int totalEstimatedSongs;
  final String source;
  @JsonKey(name: 'generated_date')
  final String generatedDate;

  const CollectionMetadata({
    required this.totalHymnals,
    required this.dateRange,
    required this.languagesSupported,
    required this.totalEstimatedSongs,
    required this.source,
    required this.generatedDate,
  });

  factory CollectionMetadata.fromJson(Map<String, dynamic> json) =>
      _$CollectionMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$CollectionMetadataToJson(this);
}

@JsonSerializable()
class HymnalCollection {
  final Map<String, HymnalReference> hymnals;
  final Map<String, String> languages;
  final CollectionMetadata metadata;

  const HymnalCollection({
    required this.hymnals,
    required this.languages,
    required this.metadata,
  });

  factory HymnalCollection.fromJson(Map<String, dynamic> json) =>
      _$HymnalCollectionFromJson(json);

  Map<String, dynamic> toJson() => _$HymnalCollectionToJson(this);
}