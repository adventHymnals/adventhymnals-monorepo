import 'package:flutter/foundation.dart';
import '../../domain/entities/hymn.dart';
import '../../core/database/database_helper.dart';

enum HymnLoadingState {
  initial,
  loading,
  loaded,
  error,
}

class HymnProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  
  List<Hymn> _hymns = [];
  List<Hymn> _searchResults = [];
  HymnLoadingState _loadingState = HymnLoadingState.initial;
  String? _errorMessage;
  String _searchQuery = '';

  // Getters
  List<Hymn> get hymns => _hymns;
  List<Hymn> get searchResults => _searchResults;
  HymnLoadingState get loadingState => _loadingState;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get isLoading => _loadingState == HymnLoadingState.loading;
  bool get hasError => _loadingState == HymnLoadingState.error;

  // Load hymns from database
  Future<void> loadHymns({
    int? limit,
    int? offset,
    String? orderBy,
  }) async {
    _setLoadingState(HymnLoadingState.loading);
    
    try {
      final hymnsData = await _db.getHymns(
        limit: limit,
        offset: offset,
        orderBy: orderBy,
      );
      
      _hymns = hymnsData.map((data) => _mapToHymn(data)).toList();
      _setLoadingState(HymnLoadingState.loaded);
    } catch (e) {
      _setError('Failed to load hymns: ${e.toString()}');
    }
  }

  // Search hymns
  Future<void> searchHymns(String query) async {
    _searchQuery = query;
    
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _setLoadingState(HymnLoadingState.loading);
    
    try {
      final searchData = await _db.searchHymns(query);
      _searchResults = searchData.map((data) => _mapToHymn(data)).toList();
      
      // Add to search history
      await _db.addSearchHistory(query, _searchResults.length);
      
      _setLoadingState(HymnLoadingState.loaded);
    } catch (e) {
      _setError('Search failed: ${e.toString()}');
    }
  }

  // Get hymn by ID
  Future<Hymn?> getHymnById(int id) async {
    try {
      final hymnData = await _db.getHymnById(id);
      if (hymnData != null) {
        return _mapToHymn(hymnData);
      }
      return null;
    } catch (e) {
      _setError('Failed to get hymn: ${e.toString()}');
      return null;
    }
  }

  // Get hymns by collection
  Future<List<Hymn>> getHymnsByCollection(int collectionId) async {
    try {
      final hymnsData = await _db.getHymnsByCollection(collectionId);
      return hymnsData.map((data) => _mapToHymn(data)).toList();
    } catch (e) {
      _setError('Failed to get hymns by collection: ${e.toString()}');
      return [];
    }
  }

  // Get hymns by author
  Future<List<Hymn>> getHymnsByAuthor(int authorId) async {
    try {
      final hymnsData = await _db.getHymnsByAuthor(authorId);
      return hymnsData.map((data) => _mapToHymn(data)).toList();
    } catch (e) {
      _setError('Failed to get hymns by author: ${e.toString()}');
      return [];
    }
  }

  // Get hymns by topic
  Future<List<Hymn>> getHymnsByTopic(int topicId) async {
    try {
      final hymnsData = await _db.getHymnsByTopic(topicId);
      return hymnsData.map((data) => _mapToHymn(data)).toList();
    } catch (e) {
      _setError('Failed to get hymns by topic: ${e.toString()}');
      return [];
    }
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }

  // Refresh hymns
  Future<void> refreshHymns() async {
    await loadHymns();
  }

  // Private methods
  void _setLoadingState(HymnLoadingState state) {
    _loadingState = state;
    if (state != HymnLoadingState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String error) {
    _loadingState = HymnLoadingState.error;
    _errorMessage = error;
    notifyListeners();
  }

  Hymn _mapToHymn(Map<String, dynamic> data) {
    return Hymn(
      id: data['id'] as int,
      hymnNumber: data['hymn_number'] as int,
      title: data['title'] as String,
      author: data['author_name'] as String?,
      composer: data['composer'] as String?,
      tuneName: data['tune_name'] as String?,
      meter: data['meter'] as String?,
      collectionId: data['collection_id'] as int?,
      lyrics: data['lyrics'] as String?,
      themeTags: data['theme_tags'] != null 
          ? (data['theme_tags'] as String).split(',').map((e) => e.trim()).toList()
          : null,
      scriptureRefs: data['scripture_refs'] != null
          ? (data['scripture_refs'] as String).split(',').map((e) => e.trim()).toList()
          : null,
      firstLine: data['first_line'] as String?,
      createdAt: data['created_at'] != null 
          ? DateTime.tryParse(data['created_at'] as String)
          : null,
      updatedAt: data['updated_at'] != null
          ? DateTime.tryParse(data['updated_at'] as String)
          : null,
      isFavorite: data['is_favorite'] == 1,
      viewCount: data['view_count'] as int?,
      lastViewed: data['last_viewed'] != null
          ? DateTime.tryParse(data['last_viewed'] as String)
          : null,
      lastPlayed: data['last_played'] != null
          ? DateTime.tryParse(data['last_played'] as String)
          : null,
      playCount: data['play_count'] as int?,
    );
  }
}