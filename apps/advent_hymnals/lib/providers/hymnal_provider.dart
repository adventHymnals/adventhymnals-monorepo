import 'package:flutter/material.dart';
import '../models/hymn.dart';
import '../models/hymnal.dart';
import '../models/search.dart';
import '../services/api_service.dart';

class HymnalProvider extends ChangeNotifier {
  final ApiService _apiService;

  HymnalProvider({required ApiService apiService}) : _apiService = apiService;

  // Hymnals state
  HymnalCollection? _hymnalCollection;
  bool _isLoadingHymnals = false;
  String? _hymnalsError;

  // Current hymnal state
  Hymnal? _currentHymnal;
  List<Hymn> _currentHymnalHymns = [];
  bool _isLoadingHymns = false;
  String? _hymnsError;

  // Current hymn state
  Hymn? _currentHymn;
  bool _isLoadingHymn = false;
  String? _hymnError;

  // Search state
  SearchResponse? _searchResponse;
  bool _isSearching = false;
  String? _searchError;

  // Browse data state
  List<AuthorData> _authors = [];
  List<ComposerData> _composers = [];
  List<ThemeDataModel> _themes = [];
  List<TuneData> _tunes = [];
  List<MeterData> _meters = [];
  bool _isLoadingBrowseData = false;
  String? _browseDataError;

  // Getters
  HymnalCollection? get hymnalCollection => _hymnalCollection;
  bool get isLoadingHymnals => _isLoadingHymnals;
  String? get hymnalsError => _hymnalsError;

  Hymnal? get currentHymnal => _currentHymnal;
  List<Hymn> get currentHymnalHymns => _currentHymnalHymns;
  bool get isLoadingHymns => _isLoadingHymns;
  String? get hymnsError => _hymnsError;

  Hymn? get currentHymn => _currentHymn;
  bool get isLoadingHymn => _isLoadingHymn;
  String? get hymnError => _hymnError;

  SearchResponse? get searchResponse => _searchResponse;
  bool get isSearching => _isSearching;
  String? get searchError => _searchError;

  List<AuthorData> get authors => _authors;
  List<ComposerData> get composers => _composers;
  List<ThemeDataModel> get themes => _themes;
  List<TuneData> get tunes => _tunes;
  List<MeterData> get meters => _meters;
  bool get isLoadingBrowseData => _isLoadingBrowseData;
  String? get browseDataError => _browseDataError;

  // Computed getters
  List<HymnalReference> get hymnalsList {
    if (_hymnalCollection == null) return [];
    return _hymnalCollection!.hymnals.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  bool get hasData => _hymnalCollection != null;

  // Methods
  Future<void> loadHymnals() async {
    if (_isLoadingHymnals) return;

    _isLoadingHymnals = true;
    _hymnalsError = null;
    notifyListeners();

    try {
      _hymnalCollection = await _apiService.getHymnals();
      _hymnalsError = null;
    } catch (e) {
      _hymnalsError = e.toString();
      print('Error loading hymnals: $e');
    } finally {
      _isLoadingHymnals = false;
      notifyListeners();
    }
  }

  Future<void> loadHymnal(String hymnalId) async {
    if (_isLoadingHymns) return;

    _isLoadingHymns = true;
    _hymnsError = null;
    notifyListeners();

    try {
      _currentHymnal = await _apiService.getHymnal(hymnalId);
      _currentHymnalHymns = await _apiService.getHymnalHymns(hymnalId);
      _hymnsError = null;
    } catch (e) {
      _hymnsError = e.toString();
      print('Error loading hymnal: $e');
    } finally {
      _isLoadingHymns = false;
      notifyListeners();
    }
  }

  Future<void> loadHymnalHymns(String hymnalId, {int page = 1, int limit = 100}) async {
    if (_isLoadingHymns) return;

    _isLoadingHymns = true;
    _hymnsError = null;
    notifyListeners();

    try {
      final hymns = await _apiService.getHymnalHymns(hymnalId, page: page, limit: limit);
      if (page == 1) {
        _currentHymnalHymns = hymns;
      } else {
        _currentHymnalHymns.addAll(hymns);
      }
      _hymnsError = null;
    } catch (e) {
      _hymnsError = e.toString();
      print('Error loading hymnal hymns: $e');
    } finally {
      _isLoadingHymns = false;
      notifyListeners();
    }
  }

  Future<void> loadHymn(String hymnId) async {
    if (_isLoadingHymn) return;

    _isLoadingHymn = true;
    _hymnError = null;
    notifyListeners();

    try {
      _currentHymn = await _apiService.getHymn(hymnId);
      _hymnError = null;
    } catch (e) {
      _hymnError = e.toString();
      print('Error loading hymn: $e');
    } finally {
      _isLoadingHymn = false;
      notifyListeners();
    }
  }

  Future<void> searchHymns(SearchParams searchParams) async {
    if (_isSearching) return;

    _isSearching = true;
    _searchError = null;
    notifyListeners();

    try {
      _searchResponse = await _apiService.searchHymns(searchParams);
      _searchError = null;
    } catch (e) {
      _searchError = e.toString();
      print('Error searching hymns: $e');
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  Future<void> loadBrowseData() async {
    if (_isLoadingBrowseData) return;

    _isLoadingBrowseData = true;
    _browseDataError = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _apiService.getAuthors(),
        _apiService.getComposers(),
        _apiService.getThemes(),
        _apiService.getTunes(),
        _apiService.getMeters(),
      ]);

      _authors = results[0] as List<AuthorData>;
      _composers = results[1] as List<ComposerData>;
      _themes = results[2] as List<ThemeDataModel>;
      _tunes = results[3] as List<TuneData>;
      _meters = results[4] as List<MeterData>;
      _browseDataError = null;
    } catch (e) {
      _browseDataError = e.toString();
      print('Error loading browse data: $e');
    } finally {
      _isLoadingBrowseData = false;
      notifyListeners();
    }
  }

  // Utility methods
  HymnalReference? getHymnalReference(String hymnalId) {
    if (_hymnalCollection == null) return null;
    return _hymnalCollection!.hymnals[hymnalId];
  }

  Hymn? getHymnById(String hymnId) {
    return _currentHymnalHymns.cast<Hymn?>().firstWhere(
      (hymn) => hymn?.id == hymnId,
      orElse: () => null,
    );
  }

  List<Hymn> getHymnsByAuthor(String author) {
    return _currentHymnalHymns.where((hymn) => hymn.author == author).toList();
  }

  List<Hymn> getHymnsByComposer(String composer) {
    return _currentHymnalHymns.where((hymn) => hymn.composer == composer).toList();
  }

  List<Hymn> getHymnsByTheme(String theme) {
    return _currentHymnalHymns
        .where((hymn) => hymn.metadata?.themes?.contains(theme) == true)
        .toList();
  }

  void clearSearch() {
    _searchResponse = null;
    _searchError = null;
    notifyListeners();
  }

  void clearCurrentHymnal() {
    _currentHymnal = null;
    _currentHymnalHymns = [];
    _hymnsError = null;
    notifyListeners();
  }

  void clearCurrentHymn() {
    _currentHymn = null;
    _hymnError = null;
    notifyListeners();
  }
}