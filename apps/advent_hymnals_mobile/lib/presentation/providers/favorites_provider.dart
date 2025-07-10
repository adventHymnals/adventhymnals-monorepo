import 'package:flutter/foundation.dart';
import '../../domain/entities/hymn.dart';
import '../../core/database/database_helper.dart';
import '../../core/data/hymn_data_manager.dart';
import '../../core/data/collections_data_manager.dart';

enum FavoritesLoadingState {
  initial,
  loading,
  loaded,
  error,
}

class FavoritesProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final HymnDataManager _hymnDataManager = HymnDataManager();
  
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
      print('🔍 [FavoritesProvider] Loading favorites for user: $userId');
      
      // First try to get favorites from database
      final favoritesData = await _db.getFavorites(userId: userId);
      print('📊 [FavoritesProvider] Found ${favoritesData.length} favorites in database');
      
      if (favoritesData.isNotEmpty) {
        // We have favorites in the database
        _favorites = favoritesData.map((data) => _mapToHymn(data)).toList();
      } else {
        // No favorites yet, or database doesn't have hymn data
        // Check if we have any favorites at all
        final favoriteIds = await _getFavoriteIds(userId: userId);
        print('📊 [FavoritesProvider] Found ${favoriteIds.length} favorite IDs');
        
        if (favoriteIds.isNotEmpty) {
          // We have favorite IDs but couldn't join with hymns data
          // This means hymns are not in database, need to load from JSON
          _favorites = await _loadFavoritesFromJson(favoriteIds);
          print('✅ [FavoritesProvider] Loaded ${_favorites.length} favorites from JSON fallback');
        } else {
          // No favorites at all
          _favorites = [];
          print('ℹ️ [FavoritesProvider] No favorites found');
        }
      }
      
      _totalCount = _favorites.length;
      print('✅ [FavoritesProvider] Final favorites count: ${_favorites.length}');
      _setLoadingState(FavoritesLoadingState.loaded);
    } catch (e) {
      print('❌ [FavoritesProvider] Error loading favorites: $e');
      _setError('Failed to load favorites: ${e.toString()}');
    }
  }

  // Add hymn to favorites
  Future<bool> addFavorite(int hymnId, {String userId = 'default'}) async {
    try {
      print('💖 [FavoritesProvider] Adding hymn $hymnId to favorites');
      
      // Try to add favorite directly to database
      try {
        await _db.addFavorite(hymnId, userId: userId);
        print('✅ [FavoritesProvider] Added favorite to database successfully');
      } catch (dbError) {
        // If database insertion fails (hymn doesn't exist in DB), 
        // still add to favorites table without foreign key constraint
        print('⚠️ [FavoritesProvider] Database insertion failed, adding to favorites table only: $dbError');
        final db = await _db.database;
        await db.insert(
          'favorites',
          {
            'hymn_id': hymnId,
            'user_id': userId,
            'date_added': DateTime.now().toIso8601String(),
          },
        );
        print('✅ [FavoritesProvider] Added favorite ID to database without hymn validation');
      }
      
      // Update the hymn in current lists if it exists
      _updateHymnFavoriteStatus(hymnId, true);
      
      // Reload favorites to get updated list
      await loadFavorites(userId: userId);
      
      print('✅ [FavoritesProvider] Successfully added hymn $hymnId to favorites');
      return true;
    } catch (e) {
      print('❌ [FavoritesProvider] Failed to add hymn $hymnId to favorites: $e');
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

  // Get favorite hymn IDs only (without joining hymns table)
  Future<List<int>> _getFavoriteIds({String userId = 'default'}) async {
    try {
      final db = await _db.database;
      final result = await db.query(
        'favorites',
        columns: ['hymn_id'],
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'date_added DESC',
      );
      return result.map((row) => row['hymn_id'] as int).toList();
    } catch (e) {
      print('❌ [FavoritesProvider] Error getting favorite IDs: $e');
      return [];
    }
  }

  // Load favorite hymns from JSON files using hymn IDs
  Future<List<Hymn>> _loadFavoritesFromJson(List<int> hymnIds) async {
    final favorites = <Hymn>[];
    
    try {
      // Load collections to search through
      final collectionsDataManager = CollectionsDataManager();
      final collections = await collectionsDataManager.getCollectionsList();
      
      for (final hymnId in hymnIds) {
        // Search for the hymn across all collections
        Hymn? foundHymn;
        
        for (final collection in collections) {
          try {
            final hymns = await _hymnDataManager.getHymnsForCollection(collection.id);
            foundHymn = hymns.firstWhere(
              (hymn) => hymn.hymnNumber == hymnId,
              orElse: () => throw StateError('Not found'),
            );
            break; // Found the hymn, stop searching
          } catch (e) {
            // Continue searching in next collection
            continue;
          }
        }
        
        if (foundHymn != null) {
          // Mark as favorite and add to list
          final favoriteHymn = foundHymn.copyWith(isFavorite: true);
          favorites.add(favoriteHymn);
          print('✅ [FavoritesProvider] Found hymn ${foundHymn.hymnNumber}: ${foundHymn.title}');
        } else {
          print('⚠️ [FavoritesProvider] Could not find hymn with ID $hymnId in any collection');
        }
      }
    } catch (e) {
      print('❌ [FavoritesProvider] Error loading favorites from JSON: $e');
    }
    
    return favorites;
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
      lastViewed: data['date_added'] != null
          ? DateTime.tryParse(data['date_added'] as String)
          : null,
      lastPlayed: data['last_played'] != null
          ? DateTime.tryParse(data['last_played'] as String)
          : null,
      playCount: data['play_count'] as int?,
    );
  }
}