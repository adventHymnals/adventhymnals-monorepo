import 'package:flutter/foundation.dart';
import '../../domain/entities/hymn.dart';
import '../../core/database/database_helper.dart';

enum RecentlyViewedLoadingState {
  initial,
  loading,
  loaded,
  error,
}

class RecentlyViewedProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  
  List<Hymn> _recentlyViewed = [];
  RecentlyViewedLoadingState _loadingState = RecentlyViewedLoadingState.initial;
  String? _errorMessage;
  int _totalCount = 0;

  // Getters
  List<Hymn> get recentlyViewed => _recentlyViewed;
  RecentlyViewedLoadingState get loadingState => _loadingState;
  String? get errorMessage => _errorMessage;
  int get totalCount => _totalCount;
  bool get isLoading => _loadingState == RecentlyViewedLoadingState.loading;
  bool get hasError => _loadingState == RecentlyViewedLoadingState.error;
  bool get isEmpty => _recentlyViewed.isEmpty;

  // Load recently viewed from database
  Future<void> loadRecentlyViewed({
    String userId = 'default',
    int limit = 50,
  }) async {
    _setLoadingState(RecentlyViewedLoadingState.loading);
    
    try {
      final recentData = await _db.getRecentlyViewed(
        userId: userId,
        limit: limit,
      );
      _recentlyViewed = recentData.map((data) => _mapToHymn(data)).toList();
      _totalCount = _recentlyViewed.length;
      _setLoadingState(RecentlyViewedLoadingState.loaded);
    } catch (e) {
      _setError('Failed to load recently viewed: ${e.toString()}');
    }
  }

  // Add hymn to recently viewed
  Future<bool> addRecentlyViewed(int hymnId, {String userId = 'default'}) async {
    try {
      await _db.addRecentlyViewed(hymnId, userId: userId);
      
      // Reload recently viewed to get updated list
      await loadRecentlyViewed(userId: userId);
      
      return true;
    } catch (e) {
      _setError('Failed to add recently viewed: ${e.toString()}');
      return false;
    }
  }

  // Clear all recently viewed
  Future<bool> clearRecentlyViewed({String userId = 'default'}) async {
    try {
      await _db.clearRecentlyViewed(userId: userId);
      
      // Clear local list
      _recentlyViewed.clear();
      _totalCount = 0;
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to clear recently viewed: ${e.toString()}');
      return false;
    }
  }

  // Remove specific hymn from recently viewed
  Future<bool> removeRecentlyViewed(int hymnId, {String userId = 'default'}) async {
    try {
      // Since there's no direct remove method, we'll need to implement this
      // For now, we'll remove from local list and notify
      _recentlyViewed.removeWhere((hymn) => hymn.id == hymnId);
      _totalCount = _recentlyViewed.length;
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to remove recently viewed: ${e.toString()}');
      return false;
    }
  }

  // Search within recently viewed
  List<Hymn> searchRecentlyViewed(String query) {
    if (query.isEmpty) return _recentlyViewed;
    
    final lowercaseQuery = query.toLowerCase();
    return _recentlyViewed.where((hymn) {
      return hymn.title.toLowerCase().contains(lowercaseQuery) ||
             (hymn.author?.toLowerCase().contains(lowercaseQuery) ?? false) ||
             (hymn.firstLine?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  // Sort recently viewed
  void sortRecentlyViewed(String sortBy) {
    switch (sortBy) {
      case 'title':
        _recentlyViewed.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'author':
        _recentlyViewed.sort((a, b) => 
          (a.author ?? '').compareTo(b.author ?? ''));
        break;
      case 'hymn_number':
        _recentlyViewed.sort((a, b) => a.hymnNumber.compareTo(b.hymnNumber));
        break;
      case 'view_count':
        _recentlyViewed.sort((a, b) => 
          (b.viewCount ?? 0).compareTo(a.viewCount ?? 0));
        break;
      case 'last_viewed':
      default:
        // Default sort by last viewed (newest first)
        _recentlyViewed.sort((a, b) => 
          (b.lastViewed ?? DateTime.now()).compareTo(a.lastViewed ?? DateTime.now()));
    }
    notifyListeners();
  }

  // Get most viewed hymns
  List<Hymn> getMostViewed({int limit = 10}) {
    final sortedByViewCount = List<Hymn>.from(_recentlyViewed);
    sortedByViewCount.sort((a, b) => 
      (b.viewCount ?? 0).compareTo(a.viewCount ?? 0));
    
    return sortedByViewCount.take(limit).toList();
  }

  // Get recently viewed hymns by date range
  List<Hymn> getRecentlyViewedByDateRange({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _recentlyViewed.where((hymn) {
      final lastViewed = hymn.lastViewed;
      if (lastViewed == null) return false;
      
      if (startDate != null && lastViewed.isBefore(startDate)) return false;
      if (endDate != null && lastViewed.isAfter(endDate)) return false;
      
      return true;
    }).toList();
  }

  // Get viewing statistics
  Map<String, dynamic> getViewingStats() {
    if (_recentlyViewed.isEmpty) {
      return {
        'total_hymns': 0,
        'total_views': 0,
        'average_views': 0.0,
        'most_viewed': null,
        'recent_activity': [],
      };
    }

    final totalViews = _recentlyViewed.fold<int>(
      0, 
      (sum, hymn) => sum + (hymn.viewCount ?? 0)
    );

    final mostViewed = _recentlyViewed.reduce((a, b) => 
      (a.viewCount ?? 0) > (b.viewCount ?? 0) ? a : b);

    // Get recent activity (last 7 days)
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final recentActivity = getRecentlyViewedByDateRange(startDate: weekAgo);

    return {
      'total_hymns': _recentlyViewed.length,
      'total_views': totalViews,
      'average_views': totalViews / _recentlyViewed.length,
      'most_viewed': mostViewed,
      'recent_activity': recentActivity,
    };
  }

  // Refresh recently viewed
  Future<void> refreshRecentlyViewed({String userId = 'default'}) async {
    await loadRecentlyViewed(userId: userId);
  }

  // Remove specific hymn from recently viewed (used by UI)
  Future<void> removeFromRecent(Hymn hymn, {String userId = 'default'}) async {
    await removeRecentlyViewed(hymn.id, userId: userId);
  }

  // Clear all recently viewed (used by UI)
  Future<void> clearAll({String userId = 'default'}) async {
    await clearRecentlyViewed(userId: userId);
  }

  // Private methods
  void _setLoadingState(RecentlyViewedLoadingState state) {
    _loadingState = state;
    if (state != RecentlyViewedLoadingState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String error) {
    _loadingState = RecentlyViewedLoadingState.error;
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
      collectionAbbreviation: data['collection_abbr'] as String? ?? 
                             data['collection_abbreviation'] as String? ??
                             data['collection_name'] as String?, // Fallback to collection name if abbreviation not available
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