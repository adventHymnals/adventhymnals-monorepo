import 'package:flutter/foundation.dart';
import '../../domain/entities/hymn.dart';
import '../../core/database/database_helper.dart';
import '../../core/data/hymn_data_manager.dart';
import '../../core/data/collections_data_manager.dart';
import '../../core/utils/search_query_parser.dart';
import '../../core/models/search_query.dart';

enum HymnLoadingState {
  initial,
  loading,
  loaded,
  error,
}

class HymnProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final HymnDataManager _hymnDataManager = HymnDataManager();
  
  List<Hymn> _hymns = [];
  List<Hymn> _searchResults = [];
  HymnLoadingState _loadingState = HymnLoadingState.initial;
  String? _errorMessage;
  String _searchQuery = '';
  String _sortBy = 'relevance';
  List<String> _selectedCollections = [];
  List<Map<String, dynamic>> _availableCollections = [];

  // Getters
  List<Hymn> get hymns => _hymns;
  List<Hymn> get searchResults => _searchResults;
  HymnLoadingState get loadingState => _loadingState;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  List<String> get selectedCollections => _selectedCollections;
  List<Map<String, dynamic>> get availableCollections => _availableCollections;
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

  // Load available collections for filtering
  Future<void> loadAvailableCollections() async {
    try {
      final collectionsDataManager = CollectionsDataManager();
      final collections = await collectionsDataManager.getCollectionsList();
      
      _availableCollections = collections.map((collection) => {
        'id': collection.id,
        'name': collection.title,
        'abbreviation': collection.id, // Use ID as abbreviation since it's typically the abbreviation
        'language': collection.language,
        'language_name': _getLanguageName(collection.language),
      }).toList();
      
      notifyListeners();
    } catch (e) {
      print('⚠️ [HymnProvider] Failed to load collections: $e');
    }
  }

  // Set search sorting
  void setSortBy(String sortBy) {
    if (_sortBy != sortBy) {
      _sortBy = sortBy;
      if (_searchResults.isNotEmpty) {
        _sortSearchResults();
      }
      notifyListeners();
    }
  }

  // Set selected collections for filtering
  void setSelectedCollections(List<String> collections) {
    _selectedCollections = collections;
    if (_searchQuery.isNotEmpty) {
      searchHymns(_searchQuery);
    }
    notifyListeners();
  }

  // Search hymns with enhanced hymnal filtering support
  Future<void> searchHymns(String query) async {
    _searchQuery = query;
    
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _setLoadingState(HymnLoadingState.loading);
    
    try {
      // Parse the search query to extract hymnal filter and search text
      final parsedQuery = SearchQueryParser.parse(query);
      print('🔍 [HymnProvider] Parsed query: $parsedQuery');
      
      List<Hymn> results = [];
      
      if (parsedQuery.hasHymnalFilter && parsedQuery.hymnalAbbreviation != null) {
        // Search within specific hymnal
        await _searchInHymnal(parsedQuery, results);
      } else if (_selectedCollections.isNotEmpty) {
        // Search within selected collections only
        await _searchInSelectedCollections(parsedQuery.searchText, results);
      } else {
        // Search all hymns
        await _searchAllHymns(parsedQuery.searchText, results);
      }
      
      print('✅ [HymnProvider] Found ${results.length} results from database');
      
      _searchResults = results;
      _sortSearchResults();
      _setLoadingState(HymnLoadingState.loaded);
    } catch (e) {
      print('❌ [HymnProvider] Search failed: $e');
      _setError('Search failed: ${e.toString()}');
    }
  }

  // Search within a specific hymnal based on parsed query
  Future<void> _searchInHymnal(SearchQuery parsedQuery, List<Hymn> results) async {
    final hymnalAbbrev = parsedQuery.hymnalAbbreviation!;
    
    // Get collection data by abbreviation
    final collectionData = await _db.getCollectionByAbbreviation(hymnalAbbrev);
    if (collectionData == null) {
      print('⚠️ [HymnProvider] Hymnal "$hymnalAbbrev" not found in database');
      return;
    }
    
    final dbCollectionId = collectionData['id'] as int;
    
    if (parsedQuery.hymnNumber != null) {
      // Search for specific hymn number in the hymnal
      final hymnData = await _db.getHymnByNumberInCollection(
        parsedQuery.hymnNumber!, 
        dbCollectionId
      );
      if (hymnData != null) {
        results.add(_mapToHymn(hymnData));
      }
    } else if (parsedQuery.searchText.isNotEmpty) {
      // Search for text within the specific hymnal
      final collectionResults = await _db.searchHymnsInCollection(
        parsedQuery.searchText, 
        dbCollectionId
      );
      results.addAll(collectionResults.map((data) => _mapToHymn(data)).toList());
    } else {
      // Just hymnal abbreviation - return all hymns from that hymnal
      final collectionResults = await _db.getHymnsByCollection(dbCollectionId);
      results.addAll(collectionResults.map((data) => _mapToHymn(data)).toList());
    }
  }

  // Search within selected collections
  Future<void> _searchInSelectedCollections(String searchText, List<Hymn> results) async {
    for (final collectionId in _selectedCollections) {
      final collectionData = await _db.getCollectionByAbbreviation(collectionId);
      if (collectionData != null) {
        final dbCollectionId = collectionData['id'] as int;
        final collectionResults = await _db.searchHymnsInCollection(searchText, dbCollectionId);
        results.addAll(collectionResults.map((data) => _mapToHymn(data)).toList());
      }
    }
  }

  // Search all hymns
  Future<void> _searchAllHymns(String searchText, List<Hymn> results) async {
    final hymnsData = await _db.searchHymns(searchText);
    results.addAll(hymnsData.map((data) => _mapToHymn(data)).toList());
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

  // Get hymns by collection abbreviation
  Future<void> loadHymnsByCollectionAbbreviation(String abbreviation) async {
    _setLoadingState(HymnLoadingState.loading);
    
    try {
      print('🔍 [HymnProvider] Starting hymn loading for collection "$abbreviation"');
      
      // Check if database is available
      final isDbAvailable = await _db.isDatabaseAvailable();
      if (!isDbAvailable) {
        print('⚠️ [HymnProvider] Database not available, falling back to JSON data');
        _hymns = await _hymnDataManager.getHymnsForCollection(abbreviation);
        _setLoadingState(HymnLoadingState.loaded);
        return;
      }
      
      print('✅ [HymnProvider] Database is available, attempting to load from DB first');
      
      // First get the collection by abbreviation
      final collectionData = await _db.getCollectionByAbbreviation(abbreviation);
      
      if (collectionData != null) {
        final collectionId = collectionData['id'] as int;
        print('🎯 [HymnProvider] Found collection ID $collectionId for abbreviation "$abbreviation"');
        
        // Now try to get hymns for this collection from database
        final hymnsData = await _db.getHymnsByCollection(collectionId);
        
        if (hymnsData.isNotEmpty) {
          // SUCCESS: Found hymns in database
          _hymns = hymnsData.map((data) => _mapToHymn(data)).toList();
          print('✅ [HymnProvider] Loaded ${_hymns.length} hymns from DATABASE for collection "$abbreviation"');
          _setLoadingState(HymnLoadingState.loaded);
        } else {
          // FALLBACK: Collection exists but no hymns in database
          print('⚠️ [HymnProvider] Collection "$abbreviation" found but no hymns in database, falling back to JSON');
          _hymns = await _hymnDataManager.getHymnsForCollection(abbreviation);
          print('✅ [HymnProvider] Loaded ${_hymns.length} hymns from JSON for collection "$abbreviation"');
          _setLoadingState(HymnLoadingState.loaded);
        }
      } else {
        print('⚠️ [HymnProvider] Collection "$abbreviation" not found in database');
        
        // Check if database is empty (no collections at all)
        final collections = await _db.getCollections();
        if (collections.isEmpty) {
          print('📋 [HymnProvider] Database is empty, using JSON data');
          _hymns = await _hymnDataManager.getHymnsForCollection(abbreviation);
          _setLoadingState(HymnLoadingState.loaded);
        } else {
          print('📋 [HymnProvider] Database has ${collections.length} collections but "$abbreviation" not found, trying JSON fallback');
          _hymns = await _hymnDataManager.getHymnsForCollection(abbreviation);
          _setLoadingState(HymnLoadingState.loaded);
        }
      }
    } catch (e) {
      print('❌ [HymnProvider] Error loading hymns for collection "$abbreviation": $e');
      
      // Fallback to JSON data if there's an error
      print('🔄 [HymnProvider] Falling back to JSON data due to error');
      _hymns = await _hymnDataManager.getHymnsForCollection(abbreviation);
      _setLoadingState(HymnLoadingState.loaded);
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

  // Sort search results based on current sort option
  void _sortSearchResults() {
    switch (_sortBy) {
      case 'title':
        _searchResults.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'author':
        _searchResults.sort((a, b) {
          final aAuthor = a.author ?? '';
          final bAuthor = b.author ?? '';
          final authorComparison = aAuthor.compareTo(bAuthor);
          return authorComparison != 0 ? authorComparison : a.title.compareTo(b.title);
        });
        break;
      case 'hymn_number':
        _searchResults.sort((a, b) {
          final numberComparison = a.hymnNumber.compareTo(b.hymnNumber);
          return numberComparison != 0 ? numberComparison : a.title.compareTo(b.title);
        });
        break;
      case 'hymnal':
        _searchResults.sort((a, b) {
          final aHymnal = a.collectionAbbreviation ?? '';
          final bHymnal = b.collectionAbbreviation ?? '';
          final hymnalComparison = aHymnal.compareTo(bHymnal);
          if (hymnalComparison != 0) return hymnalComparison;
          // If same hymnal, sort by hymn number
          final numberComparison = a.hymnNumber.compareTo(b.hymnNumber);
          return numberComparison != 0 ? numberComparison : a.title.compareTo(b.title);
        });
        break;
      case 'relevance':
      default:
        // Already sorted by relevance in search, no need to re-sort
        break;
    }
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    _sortBy = 'relevance';
    notifyListeners();
  }

  // Refresh hymns
  Future<void> refreshHymns() async {
    await loadHymns();
  }

  // Check if database is available
  Future<bool> isDatabaseAvailable() async {
    return await _db.isDatabaseAvailable();
  }

  // Initialize with fallback if database is not available
  Future<void> initializeWithFallback() async {
    final dbAvailable = await isDatabaseAvailable();
    if (!dbAvailable) {
      // Database not available - wait for data import to complete
      _hymns = [];
      _setLoadingState(HymnLoadingState.loaded);
    } else {
      await loadHymns();
    }
  }

  // Get language display name
  String _getLanguageName(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'en':
        return 'English';
      case 'es':
        return 'Spanish';
      case 'fr':
        return 'French';
      case 'de':
        return 'German';
      case 'pt':
        return 'Portuguese';
      case 'it':
        return 'Italian';
      case 'nl':
        return 'Dutch';
      case 'da':
        return 'Danish';
      case 'sv':
        return 'Swedish';
      case 'no':
        return 'Norwegian';
      case 'fi':
        return 'Finnish';
      case 'pl':
        return 'Polish';
      case 'ru':
        return 'Russian';
      case 'zh':
        return 'Chinese';
      case 'ja':
        return 'Japanese';
      case 'ko':
        return 'Korean';
      case 'hi':
        return 'Hindi';
      case 'ar':
        return 'Arabic';
      default:
        return languageCode.toUpperCase();
    }
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