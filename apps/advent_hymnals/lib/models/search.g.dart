// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchResult _$SearchResultFromJson(Map<String, dynamic> json) => SearchResult(
      hymn: Hymn.fromJson(json['hymn'] as Map<String, dynamic>),
      hymnal: Hymnal.fromJson(json['hymnal'] as Map<String, dynamic>),
      relevanceScore: (json['relevance_score'] as num).toDouble(),
      matchType: $enumDecode(_$MatchTypeEnumMap, json['match_type']),
    );

Map<String, dynamic> _$SearchResultToJson(SearchResult instance) =>
    <String, dynamic>{
      'hymn': instance.hymn,
      'hymnal': instance.hymnal,
      'relevance_score': instance.relevanceScore,
      'match_type': _$MatchTypeEnumMap[instance.matchType]!,
    };

const _$MatchTypeEnumMap = {
  MatchType.title: 'title',
  MatchType.author: 'author',
  MatchType.lyrics: 'lyrics',
  MatchType.tune: 'tune',
  MatchType.theme: 'theme',
};

YearRange _$YearRangeFromJson(Map<String, dynamic> json) => YearRange(
      min: (json['min'] as num?)?.toInt(),
      max: (json['max'] as num?)?.toInt(),
    );

Map<String, dynamic> _$YearRangeToJson(YearRange instance) => <String, dynamic>{
      'min': instance.min,
      'max': instance.max,
    };

SearchFilters _$SearchFiltersFromJson(Map<String, dynamic> json) =>
    SearchFilters(
      hymnals:
          (json['hymnals'] as List<dynamic>?)?.map((e) => e as String).toList(),
      languages: (json['languages'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$SupportedLanguageEnumMap, e))
          .toList(),
      themes:
          (json['themes'] as List<dynamic>?)?.map((e) => e as String).toList(),
      composers: (json['composers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      authors:
          (json['authors'] as List<dynamic>?)?.map((e) => e as String).toList(),
      years: json['years'] == null
          ? null
          : YearRange.fromJson(json['years'] as Map<String, dynamic>),
      meters:
          (json['meters'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$SearchFiltersToJson(SearchFilters instance) =>
    <String, dynamic>{
      'hymnals': instance.hymnals,
      'languages': instance.languages
          ?.map((e) => _$SupportedLanguageEnumMap[e]!)
          .toList(),
      'themes': instance.themes,
      'composers': instance.composers,
      'authors': instance.authors,
      'years': instance.years,
      'meters': instance.meters,
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

SearchParams _$SearchParamsFromJson(Map<String, dynamic> json) => SearchParams(
      query: json['query'] as String?,
      filters: json['filters'] == null
          ? null
          : SearchFilters.fromJson(json['filters'] as Map<String, dynamic>),
      page: (json['page'] as num?)?.toInt(),
      limit: (json['limit'] as num?)?.toInt(),
      sortBy: $enumDecodeNullable(_$SortByEnumMap, json['sortBy']),
      sortOrder: $enumDecodeNullable(_$SortOrderEnumMap, json['sortOrder']),
    );

Map<String, dynamic> _$SearchParamsToJson(SearchParams instance) =>
    <String, dynamic>{
      'query': instance.query,
      'filters': instance.filters,
      'page': instance.page,
      'limit': instance.limit,
      'sortBy': _$SortByEnumMap[instance.sortBy],
      'sortOrder': _$SortOrderEnumMap[instance.sortOrder],
    };

const _$SortByEnumMap = {
  SortBy.relevance: 'relevance',
  SortBy.title: 'title',
  SortBy.number: 'number',
  SortBy.year: 'year',
  SortBy.author: 'author',
};

const _$SortOrderEnumMap = {
  SortOrder.asc: 'asc',
  SortOrder.desc: 'desc',
};

FacetCount _$FacetCountFromJson(Map<String, dynamic> json) => FacetCount(
      id: json['id'] as String,
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$FacetCountToJson(FacetCount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'count': instance.count,
    };

LanguageFacet _$LanguageFacetFromJson(Map<String, dynamic> json) =>
    LanguageFacet(
      code: json['code'] as String,
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$LanguageFacetToJson(LanguageFacet instance) =>
    <String, dynamic>{
      'code': instance.code,
      'count': instance.count,
    };

ThemeFacet _$ThemeFacetFromJson(Map<String, dynamic> json) => ThemeFacet(
      theme: json['theme'] as String,
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$ThemeFacetToJson(ThemeFacet instance) =>
    <String, dynamic>{
      'theme': instance.theme,
      'count': instance.count,
    };

ComposerFacet _$ComposerFacetFromJson(Map<String, dynamic> json) =>
    ComposerFacet(
      name: json['name'] as String,
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$ComposerFacetToJson(ComposerFacet instance) =>
    <String, dynamic>{
      'name': instance.name,
      'count': instance.count,
    };

SearchFacets _$SearchFacetsFromJson(Map<String, dynamic> json) => SearchFacets(
      hymnals: (json['hymnals'] as List<dynamic>?)
          ?.map((e) => FacetCount.fromJson(e as Map<String, dynamic>))
          .toList(),
      languages: (json['languages'] as List<dynamic>?)
          ?.map((e) => LanguageFacet.fromJson(e as Map<String, dynamic>))
          .toList(),
      themes: (json['themes'] as List<dynamic>?)
          ?.map((e) => ThemeFacet.fromJson(e as Map<String, dynamic>))
          .toList(),
      composers: (json['composers'] as List<dynamic>?)
          ?.map((e) => ComposerFacet.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SearchFacetsToJson(SearchFacets instance) =>
    <String, dynamic>{
      'hymnals': instance.hymnals,
      'languages': instance.languages,
      'themes': instance.themes,
      'composers': instance.composers,
    };

SearchResponse _$SearchResponseFromJson(Map<String, dynamic> json) =>
    SearchResponse(
      results: (json['results'] as List<dynamic>)
          .map((e) => SearchResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      facets: json['facets'] == null
          ? null
          : SearchFacets.fromJson(json['facets'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SearchResponseToJson(SearchResponse instance) =>
    <String, dynamic>{
      'results': instance.results,
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
      'totalPages': instance.totalPages,
      'facets': instance.facets,
    };
