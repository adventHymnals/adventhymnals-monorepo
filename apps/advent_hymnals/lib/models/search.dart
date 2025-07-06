import 'package:json_annotation/json_annotation.dart';
import 'hymn.dart';
import 'hymnal.dart';

part 'search.g.dart';

enum MatchType {
  @JsonValue('title')
  title,
  @JsonValue('author')
  author,
  @JsonValue('lyrics')
  lyrics,
  @JsonValue('tune')
  tune,
  @JsonValue('theme')
  theme,
}

@JsonSerializable()
class SearchResult {
  final Hymn hymn;
  final Hymnal hymnal;
  @JsonKey(name: 'relevance_score')
  final double relevanceScore;
  @JsonKey(name: 'match_type')
  final MatchType matchType;

  const SearchResult({
    required this.hymn,
    required this.hymnal,
    required this.relevanceScore,
    required this.matchType,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) =>
      _$SearchResultFromJson(json);

  Map<String, dynamic> toJson() => _$SearchResultToJson(this);
}

@JsonSerializable()
class YearRange {
  final int? min;
  final int? max;

  const YearRange({this.min, this.max});

  factory YearRange.fromJson(Map<String, dynamic> json) =>
      _$YearRangeFromJson(json);

  Map<String, dynamic> toJson() => _$YearRangeToJson(this);
}

@JsonSerializable()
class SearchFilters {
  final List<String>? hymnals;
  final List<SupportedLanguage>? languages;
  final List<String>? themes;
  final List<String>? composers;
  final List<String>? authors;
  final YearRange? years;
  final List<String>? meters;

  const SearchFilters({
    this.hymnals,
    this.languages,
    this.themes,
    this.composers,
    this.authors,
    this.years,
    this.meters,
  });

  factory SearchFilters.fromJson(Map<String, dynamic> json) =>
      _$SearchFiltersFromJson(json);

  Map<String, dynamic> toJson() => _$SearchFiltersToJson(this);
}

enum SortBy {
  @JsonValue('relevance')
  relevance,
  @JsonValue('title')
  title,
  @JsonValue('number')
  number,
  @JsonValue('year')
  year,
  @JsonValue('author')
  author,
}

enum SortOrder {
  @JsonValue('asc')
  asc,
  @JsonValue('desc')
  desc,
}

@JsonSerializable()
class SearchParams {
  final String? query;
  final SearchFilters? filters;
  final int? page;
  final int? limit;
  @JsonKey(name: 'sortBy')
  final SortBy? sortBy;
  @JsonKey(name: 'sortOrder')
  final SortOrder? sortOrder;

  const SearchParams({
    this.query,
    this.filters,
    this.page,
    this.limit,
    this.sortBy,
    this.sortOrder,
  });

  factory SearchParams.fromJson(Map<String, dynamic> json) =>
      _$SearchParamsFromJson(json);

  Map<String, dynamic> toJson() => _$SearchParamsToJson(this);
}

@JsonSerializable()
class FacetCount {
  final String id;
  final int count;

  const FacetCount({
    required this.id,
    required this.count,
  });

  factory FacetCount.fromJson(Map<String, dynamic> json) =>
      _$FacetCountFromJson(json);

  Map<String, dynamic> toJson() => _$FacetCountToJson(this);
}

@JsonSerializable()
class LanguageFacet {
  final String code;
  final int count;

  const LanguageFacet({
    required this.code,
    required this.count,
  });

  factory LanguageFacet.fromJson(Map<String, dynamic> json) =>
      _$LanguageFacetFromJson(json);

  Map<String, dynamic> toJson() => _$LanguageFacetToJson(this);
}

@JsonSerializable()
class ThemeFacet {
  final String theme;
  final int count;

  const ThemeFacet({
    required this.theme,
    required this.count,
  });

  factory ThemeFacet.fromJson(Map<String, dynamic> json) =>
      _$ThemeFacetFromJson(json);

  Map<String, dynamic> toJson() => _$ThemeFacetToJson(this);
}

@JsonSerializable()
class ComposerFacet {
  final String name;
  final int count;

  const ComposerFacet({
    required this.name,
    required this.count,
  });

  factory ComposerFacet.fromJson(Map<String, dynamic> json) =>
      _$ComposerFacetFromJson(json);

  Map<String, dynamic> toJson() => _$ComposerFacetToJson(this);
}

@JsonSerializable()
class SearchFacets {
  final List<FacetCount>? hymnals;
  final List<LanguageFacet>? languages;
  final List<ThemeFacet>? themes;
  final List<ComposerFacet>? composers;

  const SearchFacets({
    this.hymnals,
    this.languages,
    this.themes,
    this.composers,
  });

  factory SearchFacets.fromJson(Map<String, dynamic> json) =>
      _$SearchFacetsFromJson(json);

  Map<String, dynamic> toJson() => _$SearchFacetsToJson(this);
}

@JsonSerializable()
class SearchResponse {
  final List<SearchResult> results;
  final int total;
  final int page;
  final int limit;
  @JsonKey(name: 'totalPages')
  final int totalPages;
  final SearchFacets? facets;

  const SearchResponse({
    required this.results,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    this.facets,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) =>
      _$SearchResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SearchResponseToJson(this);
}