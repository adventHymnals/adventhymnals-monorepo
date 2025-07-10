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
      // Try database first, fall back to mock data if database fails
      try {
        final hymnsData = await _db.searchHymns(query);
        _searchResults = hymnsData.map((data) => _mapToHymn(data)).toList();
      } catch (dbError) {
        // Database not available, use mock data
        print('Database search failed, using mock data: $dbError');
        _searchResults = _getMockSearchResults(query);
      }
      
      _setLoadingState(HymnLoadingState.loaded);
    } catch (e) {
      _setError('Search failed: ${e.toString()}');
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

  // Mock hymns for specific collection
  List<Hymn> _getMockHymnsForCollection(String abbreviation) {
    print('🎭 [HymnProvider] Generating mock hymns for collection "$abbreviation"');
    
    // Different mock hymns based on collection
    if (abbreviation.toUpperCase() == 'SDAH') {
      return [
        Hymn(
          id: 1,
          hymnNumber: 1,
          title: 'Holy, Holy, Holy',
          author: 'Reginald Heber',
          composer: 'John B. Dykes',
          tuneName: 'Nicaea',
          meter: '11.12.12.10',
          collectionId: 1,
          lyrics: 'Holy, holy, holy! Lord God Almighty!\nEarly in the morning our song shall rise to Thee;\nHoly, holy, holy! Merciful and mighty!\nGod in three Persons, blessed Trinity!',
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
          title: 'Come, Thou Almighty King',
          author: 'Unknown',
          composer: 'Felice de Giardini',
          tuneName: 'Italian Hymn',
          meter: '664.6664',
          collectionId: 1,
          lyrics: 'Come, Thou Almighty King,\nHelp us Thy name to sing,\nHelp us to praise!\nFather all glorious,\nO\'er all victorious,\nCome and reign over us,\nAncient of Days!',
          firstLine: 'Come, Thou Almighty King',
          themeTags: ['worship', 'trinity', 'praise'],
          scriptureRefs: ['1 Timothy 1:17'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isFavorite: false,
        ),
        Hymn(
          id: 3,
          hymnNumber: 3,
          title: 'Great Is Thy Faithfulness',
          author: 'Thomas O. Chisholm',
          composer: 'William M. Runyan',
          tuneName: 'Faithfulness',
          meter: '11.10.11.10',
          collectionId: 1,
          lyrics: 'Great is Thy faithfulness, O God my Father;\nThere is no shadow of turning with Thee;\nThou changest not, Thy compassions, they fail not;\nAs Thou hast been, Thou forever wilt be.',
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
          title: 'Praise to the Lord, the Almighty',
          author: 'Joachim Neander',
          composer: 'Traditional German Melody',
          tuneName: 'Lobe Den Herren',
          meter: '14.14.4.78',
          collectionId: 1,
          lyrics: 'Praise to the Lord, the Almighty, the King of creation!\nO my soul, praise Him, for He is thy health and salvation!\nAll ye who hear,\nNow to His temple draw near;\nPraise Him in glad adoration.',
          firstLine: 'Praise to the Lord, the Almighty, the King of creation!',
          themeTags: ['praise', 'worship', 'creation'],
          scriptureRefs: ['Psalm 103:1-5'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isFavorite: false,
        ),
        Hymn(
          id: 5,
          hymnNumber: 5,
          title: 'A Mighty Fortress Is Our God',
          author: 'Martin Luther',
          composer: 'Martin Luther',
          tuneName: 'Ein Feste Burg',
          meter: '87.87.66.667',
          collectionId: 1,
          lyrics: 'A mighty fortress is our God,\nA bulwark never failing;\nOur helper He, amid the flood\nOf mortal ills prevailing:\nFor still our ancient foe\nDoth seek to work us woe;\nHis craft and power are great,\nAnd, armed with cruel hate,\nOn earth is not his equal.',
          firstLine: 'A mighty fortress is our God',
          themeTags: ['strength', 'protection', 'God'],
          scriptureRefs: ['Psalm 46:1'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isFavorite: false,
        ),
      ];
    } else {
      // Generic mock hymns for other collections
      return [
        Hymn(
          id: 10,
          hymnNumber: 1,
          title: 'Amazing Grace ($abbreviation Collection)',
          author: 'John Newton',
          composer: 'Traditional American Melody',
          tuneName: 'New Britain',
          meter: 'CM',
          collectionId: 1,
          lyrics: 'Amazing grace! how sweet the sound\nThat saved a wretch like me!\nI once was lost, but now am found,\nWas blind, but now I see.',
          firstLine: 'Amazing grace! how sweet the sound',
          themeTags: ['grace', 'salvation', 'testimony'],
          scriptureRefs: ['Ephesians 2:8-9'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isFavorite: false,
        ),
        Hymn(
          id: 11,
          hymnNumber: 2,
          title: 'How Great Thou Art ($abbreviation Collection)',
          author: 'Carl Boberg',
          composer: 'Traditional Swedish Melody',
          tuneName: 'O Store Gud',
          meter: '11.10.11.10',
          collectionId: 1,
          lyrics: 'O Lord my God, when I in awesome wonder\nConsider all the worlds Thy hands have made;\nI see the stars, I hear the rolling thunder,\nThy power throughout the universe displayed.',
          firstLine: 'O Lord my God, when I in awesome wonder',
          themeTags: ['praise', 'creation', 'worship'],
          scriptureRefs: ['Psalm 8:3-4'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isFavorite: false,
        ),
      ];
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

  // Get hymns by collection abbreviation
  Future<void> loadHymnsByCollectionAbbreviation(String abbreviation) async {
    _setLoadingState(HymnLoadingState.loading);
    
    try {
      // Check if database is available
      final isDbAvailable = await _db.isDatabaseAvailable();
      if (!isDbAvailable) {
        print('⚠️ [HymnProvider] Database not available, falling back to mock data');
        _hymns = _getMockHymnsForCollection(abbreviation); // Return collection-specific mock hymns
        _setLoadingState(HymnLoadingState.loaded);
        return;
      }
      
      // First get the collection by abbreviation
      final collectionData = await _db.getCollectionByAbbreviation(abbreviation);
      
      if (collectionData != null) {
        final collectionId = collectionData['id'] as int;
        print('🎯 [HymnProvider] Found collection ID $collectionId for abbreviation "$abbreviation"');
        
        // Now get hymns for this collection
        final hymnsData = await _db.getHymnsByCollection(collectionId);
        _hymns = hymnsData.map((data) => _mapToHymn(data)).toList();
        
        print('✅ [HymnProvider] Loaded ${_hymns.length} hymns for collection "$abbreviation"');
        _setLoadingState(HymnLoadingState.loaded);
      } else {
        print('⚠️ [HymnProvider] Collection "$abbreviation" not found in database');
        
        // Check if database is empty (no collections at all)
        final collections = await _db.getCollections();
        if (collections.isEmpty) {
          print('📋 [HymnProvider] Database is empty, using mock data for demonstration');
          _hymns = _getMockHymnsForCollection(abbreviation); // Return collection-specific mock hymns
          _setLoadingState(HymnLoadingState.loaded);
        } else {
          print('📋 [HymnProvider] Database has ${collections.length} collections but "$abbreviation" not found');
          _hymns = [];
          _setLoadingState(HymnLoadingState.loaded);
        }
      }
    } catch (e) {
      print('❌ [HymnProvider] Error loading hymns for collection "$abbreviation": $e');
      
      // Fallback to mock data if there's an error
      print('🔄 [HymnProvider] Falling back to mock data due to error');
      _hymns = _getMockHymnsForCollection(abbreviation);
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