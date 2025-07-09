import 'package:flutter/foundation.dart';
import '../../domain/entities/hymn.dart';
import '../../core/database/database_helper.dart';

enum FavoritesLoadingState {
  initial,
  loading,
  loaded,
  error,
}

class FavoritesProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  
  List<Hymn> _favorites = [];
  FavoritesLoadingState _loadingState = FavoritesLoadingState.initial;
  String? _errorMessage;
  int _totalCount = 0;

  // Getters
  List<Hymn> get favorites => _favorites;
  FavoritesLoadingState get loadingState => _loadingState;
  String? get errorMessage => _errorMessage;
  int get totalCount => _totalCount;
  bool get isLoading => _loadingState == FavoritesLoadingState.loading;
  bool get hasError => _loadingState == FavoritesLoadingState.error;
  bool get isEmpty => _favorites.isEmpty;

  // Load favorites from database
  Future<void> loadFavorites({String userId = 'default'}) async {
    _setLoadingState(FavoritesLoadingState.loading);
    
    try {
      final favoritesData = await _db.getFavorites(userId: userId);
      _favorites = favoritesData.map((data) => _mapToHymn(data)).toList();
      _totalCount = _favorites.length;
      _setLoadingState(FavoritesLoadingState.loaded);
    } catch (e) {
      _setError('Failed to load favorites: ${e.toString()}');
    }
  }

  // Add hymn to favorites
  Future<bool> addFavorite(int hymnId, {String userId = 'default'}) async {
    try {
      await _db.addFavorite(hymnId, userId: userId);
      
      // Update the hymn in current lists if it exists
      _updateHymnFavoriteStatus(hymnId, true);
      
      // Reload favorites to get updated list
      await loadFavorites(userId: userId);
      
      return true;
    } catch (e) {
      _setError('Failed to add favorite: ${e.toString()}');
      return false;
    }
  }

  // Remove hymn from favorites
  Future<bool> removeFavorite(int hymnId, {String userId = 'default'}) async {
    try {
      await _db.removeFavorite(hymnId, userId: userId);
      
      // Update the hymn in current lists if it exists
      _updateHymnFavoriteStatus(hymnId, false);
      
      // Remove from favorites list
      _favorites.removeWhere((hymn) => hymn.id == hymnId);
      _totalCount = _favorites.length;
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to remove favorite: ${e.toString()}');
      return false;
    }
  }

  // Check if hymn is favorite
  Future<bool> isFavorite(int hymnId, {String userId = 'default'}) async {
    try {
      return await _db.isFavorite(hymnId, userId: userId);
    } catch (e) {
      _setError('Failed to check favorite status: ${e.toString()}');
      return false;
    }
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(int hymnId, {String userId = 'default'}) async {
    final isCurrentlyFavorite = await isFavorite(hymnId, userId: userId);
    
    if (isCurrentlyFavorite) {
      return await removeFavorite(hymnId, userId: userId);
    } else {
      return await addFavorite(hymnId, userId: userId);
    }
  }

  // Clear all favorites
  Future<bool> clearAllFavorites({String userId = 'default'}) async {
    try {
      // Remove all favorites from database
      for (final hymn in _favorites) {
        await _db.removeFavorite(hymn.id, userId: userId);
      }
      
      // Clear local list
      _favorites.clear();
      _totalCount = 0;
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to clear favorites: ${e.toString()}');
      return false;
    }
  }

  // Get favorites count
  Future<int> getFavoritesCount() async {
    try {
      return await _db.getFavoritesCount();
    } catch (e) {
      _setError('Failed to get favorites count: ${e.toString()}');
      return 0;
    }
  }

  // Search within favorites
  List<Hymn> searchFavorites(String query) {
    if (query.isEmpty) return _favorites;
    
    final lowercaseQuery = query.toLowerCase();
    return _favorites.where((hymn) {
      return hymn.title.toLowerCase().contains(lowercaseQuery) ||
             (hymn.author?.toLowerCase().contains(lowercaseQuery) ?? false) ||
             (hymn.firstLine?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  // Sort favorites
  void sortFavorites(String sortBy) {
    switch (sortBy) {
      case 'title':
        _favorites.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'author':
        _favorites.sort((a, b) => 
          (a.author ?? '').compareTo(b.author ?? ''));
        break;
      case 'hymn_number':
        _favorites.sort((a, b) => a.hymnNumber.compareTo(b.hymnNumber));
        break;
      case 'date_added':
        _favorites.sort((a, b) => 
          (b.lastViewed ?? DateTime.now()).compareTo(a.lastViewed ?? DateTime.now()));
        break;
      default:
        // Default sort by date added (newest first)
        _favorites.sort((a, b) => 
          (b.lastViewed ?? DateTime.now()).compareTo(a.lastViewed ?? DateTime.now()));
    }
    notifyListeners();
  }

  // Refresh favorites
  Future<void> refreshFavorites({String userId = 'default'}) async {
    await loadFavorites(userId: userId);
  }

  // Private methods
  void _setLoadingState(FavoritesLoadingState state) {
    _loadingState = state;
    if (state != FavoritesLoadingState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String error) {
    _loadingState = FavoritesLoadingState.error;
    _errorMessage = error;
    notifyListeners();
  }

  void _updateHymnFavoriteStatus(int hymnId, bool isFavorite) {
    // Update hymn in favorites list
    final index = _favorites.indexWhere((hymn) => hymn.id == hymnId);
    if (index != -1) {
      _favorites[index] = _favorites[index].copyWith(isFavorite: isFavorite);
    }
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
      isFavorite: true, // All items in favorites are favorites
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