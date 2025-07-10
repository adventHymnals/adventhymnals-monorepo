import 'package:flutter/foundation.dart';
import '../../domain/entities/hymn.dart';
import '../../core/database/database_helper.dart';
import '../../core/data/hymn_data_manager.dart';
import '../../core/data/collections_data_manager.dart';

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
      // Try database first
      List<Hymn> results = [];
      
      try {
        final hymnsData = await _db.searchHymns(query);
        results = hymnsData.map((data) => _mapToHymn(data)).toList();
        print('✅ [HymnProvider] Found ${results.length} results from database');
      } catch (dbError) {
        print('⚠️ [HymnProvider] Database search failed, using JSON fallback: $dbError');
        // Fallback to JSON search
        results = await _searchHymnsFromJson(query);
        print('✅ [HymnProvider] Found ${results.length} results from JSON');
      }
      
      _searchResults = results;
      _sortSearchResults();
      _setLoadingState(HymnLoadingState.loaded);
    } catch (e) {
      print('❌ [HymnProvider] Search failed: $e');
      _setError('Search failed: ${e.toString()}');
    }
  }

  // Search hymns from JSON data as fallback
  Future<List<Hymn>> _searchHymnsFromJson(String query) async {
    final queryLower = query.toLowerCase();
    final allHymns = <Hymn>[];
    
    try {
      // Load available collections and search in them
      final collectionsDataManager = CollectionsDataManager();
      final collections = await collectionsDataManager.getCollectionsList();
      
      // Filter collections based on selected collections
      final collectionsToSearch = _selectedCollections.isEmpty 
          ? collections.take(5).toList() // Default: search first 5 collections
          : collections.where((c) => _selectedCollections.contains(c.id)).toList();
      
      for (final collection in collectionsToSearch) {
        try {
          final hymns = await _hymnDataManager.getHymnsForCollection(collection.id);
          allHymns.addAll(hymns);
        } catch (e) {
          print('⚠️ [HymnProvider] Failed to load collection ${collection.id}: $e');
        }
      }
      
      // Search through all loaded hymns
      final searchResults = allHymns.where((hymn) {
        final searchableText = [
          hymn.title.toLowerCase(),
          hymn.author?.toLowerCase() ?? '',
          hymn.composer?.toLowerCase() ?? '',
          hymn.tuneName?.toLowerCase() ?? '',
          hymn.meter?.toLowerCase() ?? '',
          hymn.firstLine?.toLowerCase() ?? '',
          hymn.lyrics?.toLowerCase() ?? '',
          hymn.hymnNumber.toString(),
        ].join(' ');
        
        return searchableText.contains(queryLower);
      }).toList();
      
      // Initial relevance sort (title matches first)
      searchResults.sort((a, b) {
        final aTitle = a.title.toLowerCase().contains(queryLower);
        final bTitle = b.title.toLowerCase().contains(queryLower);
        
        if (aTitle && !bTitle) return -1;
        if (!aTitle && bTitle) return 1;
        
        return a.title.compareTo(b.title);
      });
      
      return searchResults.take(50).toList(); // Limit results for performance
    } catch (e) {
      print('❌ [HymnProvider] JSON search failed: $e');
      return [];
    }
  }

  // Mock search results for demo purposes
  List<Hymn> _getMockSearchResults(String query) {
    final mockHymns = [
      Hymn(
        id: 1,
        hymnNumber: 1,
        title: 'Holy, Holy, Holy',
        author: 'Reginald Heber',
        composer: 'John B. Dykes',
        tuneName: 'Nicaea',
        meter: '11.12.12.10',
        collectionId: 1,
        lyrics: 'Holy, holy, holy! Lord God Almighty!\nEarly in the morning our song shall rise to Thee;',
        firstLine: 'Holy, holy, holy! Lord God Almighty!',
        themeTags: ['worship', 'trinity', 'holiness'],
        scriptureRefs: ['Revelation 4:8', 'Isaiah 6:3'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFavorite: false,
      ),
      Hymn(
        id: 2,
        hymnNumber: 2,
        title: 'Amazing Grace',
        author: 'John Newton',
        composer: 'Traditional American Melody',
        tuneName: 'New Britain',
        meter: 'CM',
        collectionId: 1,
        lyrics: 'Amazing grace! how sweet the sound\nThat saved a wretch like me!',
        firstLine: 'Amazing grace! how sweet the sound',
        themeTags: ['grace', 'salvation', 'testimony'],
        scriptureRefs: ['Ephesians 2:8-9'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFavorite: false,
      ),
      Hymn(
        id: 3,
        hymnNumber: 3,
        title: 'Great Is Thy Faithfulness',
        author: 'Thomas Chisholm',
        composer: 'William M. Runyan',
        tuneName: 'Faithfulness',
        meter: '11.10.11.10',
        collectionId: 1,
        lyrics: 'Great is Thy faithfulness, O God my Father;\nThere is no shadow of turning with Thee;',
        firstLine: 'Great is Thy faithfulness, O God my Father',
        themeTags: ['faithfulness', 'God', 'trust'],
        scriptureRefs: ['Lamentations 3:22-23'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFavorite: false,
      ),
      Hymn(
        id: 4,
        hymnNumber: 4,
        title: 'How Great Thou Art',
        author: 'Carl Boberg',
        composer: 'Traditional Swedish Melody',
        tuneName: 'O Store Gud',
        meter: '11.10.11.10',
        collectionId: 1,
        lyrics: 'O Lord my God, when I in awesome wonder\nConsider all the worlds Thy hands have made;',
        firstLine: 'O Lord my God, when I in awesome wonder',
        themeTags: ['praise', 'creation', 'worship'],
        scriptureRefs: ['Psalm 8:3-4'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFavorite: false,
      ),
      Hymn(
        id: 5,
        hymnNumber: 5,
        title: 'Jesus Loves Me',
        author: 'Anna B. Warner',
        composer: 'William B. Bradbury',
        tuneName: 'Jesus Loves Me',
        meter: '77.77',
        collectionId: 1,
        lyrics: 'Jesus loves me! This I know,\nFor the Bible tells me so;',
        firstLine: 'Jesus loves me! This I know',
        themeTags: ['love', 'children', 'Jesus'],
        scriptureRefs: ['John 3:16'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFavorite: false,
      ),
    ];

    // Filter mock hymns based on query
    if (query.isEmpty) {
      return mockHymns; // Return all hymns for empty query
    }
    
    final lowerQuery = query.toLowerCase();
    return mockHymns.where((hymn) {
      return hymn.title.toLowerCase().contains(lowerQuery) ||
             (hymn.author?.toLowerCase().contains(lowerQuery) ?? false) ||
             (hymn.firstLine?.toLowerCase().contains(lowerQuery) ?? false) ||
             (hymn.lyrics?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  // Note: Mock hymns functionality removed - now using real JSON hymn data via HymnDataManager

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

  // Initialize with mock data if database is not available
  Future<void> initializeWithFallback() async {
    final dbAvailable = await isDatabaseAvailable();
    if (!dbAvailable) {
      // Load some default mock data for better UX
      _hymns = _getMockSearchResults(''); // Empty query returns all mock hymns
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