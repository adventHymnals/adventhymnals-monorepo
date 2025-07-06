import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/hymn.dart';
import '../models/hymnal.dart';
import '../models/search.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  late final Dio _dio;
  bool _useMockData = false;

  ApiService({String? customBaseUrl}) {
    _dio = Dio(BaseOptions(
      baseUrl: customBaseUrl ?? baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print(obj),
    ));
  }

  // Hymnals endpoints
  Future<HymnalCollection> getHymnals() async {
    try {
      final response = await _dio.get('/hymnals');
      return HymnalCollection.fromJson(response.data);
    } on DioException catch (e) {
      print('API Error: ${e.message}. Falling back to mock data.');
      return _getMockHymnalCollection();
    }
  }

  HymnalCollection _getMockHymnalCollection() {
    return HymnalCollection(
      hymnals: {
        'sdah': HymnalReference(
          id: 'sdah',
          name: 'Seventh-day Adventist Hymnal',
          abbreviation: 'SDAH',
          year: 1985,
          totalSongs: 695,
          language: SupportedLanguage.en,
          languageName: 'English',
          siteName: 'Advent Hymnals',
          urlSlug: 'seventh-day-adventist-hymnal',
        ),
        'church-hymnal': HymnalReference(
          id: 'church-hymnal',
          name: 'The Church Hymnal',
          abbreviation: 'CH',
          year: 1941,
          totalSongs: 600,
          language: SupportedLanguage.en,
          languageName: 'English',
          siteName: 'Advent Hymnals',
          urlSlug: 'church-hymnal',
        ),
      },
      languages: {
        'en': 'English',
        'sw': 'Kiswahili',
      },
      metadata: CollectionMetadata(
        totalHymnals: 2,
        dateRange: DateRange(earliest: 1941, latest: 1985),
        languagesSupported: [SupportedLanguage.en, SupportedLanguage.sw],
        totalEstimatedSongs: 1295,
        source: 'Mock Data',
        generatedDate: DateTime.now().toIso8601String(),
      ),
    );
  }

  Future<Hymnal> getHymnal(String hymnalId) async {
    try {
      final response = await _dio.get('/hymnals/$hymnalId');
      return Hymnal.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException._fromDioException(e);
    }
  }

  Future<List<Hymn>> getHymnalHymns(
    String hymnalId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _dio.get(
        '/hymnals/$hymnalId/hymns',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      final List<dynamic> hymnsJson = response.data['hymns'];
      return hymnsJson.map((json) => Hymn.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException._fromDioException(e);
    }
  }

  // Hymns endpoints
  Future<Hymn> getHymn(String hymnId) async {
    try {
      final response = await _dio.get('/hymns/$hymnId');
      return Hymn.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException._fromDioException(e);
    }
  }

  Future<List<Hymn>> getRelatedHymns(String hymnId) async {
    try {
      final response = await _dio.get('/hymns/$hymnId/related');
      final List<dynamic> hymnsJson = response.data;
      return hymnsJson.map((json) => Hymn.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException._fromDioException(e);
    }
  }

  // Search endpoint
  Future<SearchResponse> searchHymns(SearchParams searchParams) async {
    try {
      final response = await _dio.get(
        '/search',
        queryParameters: _searchParamsToQueryParams(searchParams),
      );
      return SearchResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException._fromDioException(e);
    }
  }

  // Browse endpoints
  Future<List<AuthorData>> getAuthors() async {
    try {
      final response = await _dio.get('/authors');
      final List<dynamic> authorsJson = response.data;
      return authorsJson.map((json) => AuthorData.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException._fromDioException(e);
    }
  }

  Future<List<ComposerData>> getComposers() async {
    try {
      final response = await _dio.get('/composers');
      final List<dynamic> composersJson = response.data;
      return composersJson.map((json) => ComposerData.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException._fromDioException(e);
    }
  }

  Future<List<ThemeDataModel>> getThemes() async {
    try {
      final response = await _dio.get('/themes');
      final List<dynamic> themesJson = response.data;
      return themesJson.map((json) => ThemeDataModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException._fromDioException(e);
    }
  }

  Future<List<TuneData>> getTunes() async {
    try {
      final response = await _dio.get('/tunes');
      final List<dynamic> tunesJson = response.data;
      return tunesJson.map((json) => TuneData.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException._fromDioException(e);
    }
  }

  Future<List<MeterData>> getMeters() async {
    try {
      final response = await _dio.get('/meters');
      final List<dynamic> metersJson = response.data;
      return metersJson.map((json) => MeterData.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException._fromDioException(e);
    }
  }

  // Health check
  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Map<String, dynamic> _searchParamsToQueryParams(SearchParams params) {
    final Map<String, dynamic> queryParams = {};

    if (params.query != null && params.query!.isNotEmpty) {
      queryParams['query'] = params.query;
    }

    if (params.page != null) {
      queryParams['page'] = params.page;
    }

    if (params.limit != null) {
      queryParams['limit'] = params.limit;
    }

    if (params.sortBy != null) {
      queryParams['sortBy'] = params.sortBy!.name;
    }

    if (params.sortOrder != null) {
      queryParams['sortOrder'] = params.sortOrder!.name;
    }

    if (params.filters != null) {
      final filters = params.filters!;

      if (filters.hymnals != null) {
        queryParams['hymnals'] = filters.hymnals!.join(',');
      }

      if (filters.languages != null) {
        queryParams['languages'] = filters.languages!.map((l) => l.name).join(',');
      }

      if (filters.themes != null) {
        queryParams['themes'] = filters.themes!.join(',');
      }

      if (filters.composers != null) {
        queryParams['composers'] = filters.composers!.join(',');
      }

      if (filters.authors != null) {
        queryParams['authors'] = filters.authors!.join(',');
      }

      if (filters.meters != null) {
        queryParams['meters'] = filters.meters!.join(',');
      }

      if (filters.years != null) {
        if (filters.years!.min != null) {
          queryParams['minYear'] = filters.years!.min;
        }
        if (filters.years!.max != null) {
          queryParams['maxYear'] = filters.years!.max;
        }
      }
    }

    return queryParams;
  }
}

// Browse data models
class AuthorData {
  final String author;
  final int count;
  final List<dynamic> hymns;

  AuthorData({
    required this.author,
    required this.count,
    required this.hymns,
  });

  factory AuthorData.fromJson(Map<String, dynamic> json) {
    return AuthorData(
      author: json['author'],
      count: json['count'],
      hymns: json['hymns'],
    );
  }
}

class ComposerData {
  final String composer;
  final int count;
  final List<dynamic> hymns;

  ComposerData({
    required this.composer,
    required this.count,
    required this.hymns,
  });

  factory ComposerData.fromJson(Map<String, dynamic> json) {
    return ComposerData(
      composer: json['composer'],
      count: json['count'],
      hymns: json['hymns'],
    );
  }
}

class ThemeDataModel {
  final String theme;
  final int count;
  final List<dynamic> hymns;

  ThemeDataModel({
    required this.theme,
    required this.count,
    required this.hymns,
  });

  factory ThemeDataModel.fromJson(Map<String, dynamic> json) {
    return ThemeDataModel(
      theme: json['theme'],
      count: json['count'],
      hymns: json['hymns'],
    );
  }
}

class TuneData {
  final String tune;
  final int count;
  final List<dynamic> hymns;

  TuneData({
    required this.tune,
    required this.count,
    required this.hymns,
  });

  factory TuneData.fromJson(Map<String, dynamic> json) {
    return TuneData(
      tune: json['tune'],
      count: json['count'],
      hymns: json['hymns'],
    );
  }
}

class MeterData {
  final String meter;
  final int count;
  final List<dynamic> hymns;

  MeterData({
    required this.meter,
    required this.count,
    required this.hymns,
  });

  factory MeterData.fromJson(Map<String, dynamic> json) {
    return MeterData(
      meter: json['meter'],
      count: json['count'],
      hymns: json['hymns'],
    );
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  ApiException(this.message, {this.statusCode, this.code});

  factory ApiException._fromDioException(DioException dioException) {
    String message;
    int? statusCode;
    String? code;

    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Send timeout. Please try again.';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Receive timeout. Please try again.';
        break;
      case DioExceptionType.badResponse:
        statusCode = dioException.response?.statusCode;
        if (statusCode == 404) {
          message = 'Resource not found.';
        } else if (statusCode == 500) {
          message = 'Server error. Please try again later.';
        } else {
          message = 'HTTP ${statusCode}: ${dioException.response?.statusMessage ?? 'Unknown error'}';
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
        break;
      case DioExceptionType.connectionError:
        message = 'Connection error. Please check your internet connection.';
        break;
      case DioExceptionType.badCertificate:
        message = 'Bad certificate. Connection is not secure.';
        break;
      case DioExceptionType.unknown:
      default:
        message = 'An unexpected error occurred: ${dioException.message}';
        break;
    }

    return ApiException(message, statusCode: statusCode, code: code);
  }

  @override
  String toString() {
    return 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
  }
}