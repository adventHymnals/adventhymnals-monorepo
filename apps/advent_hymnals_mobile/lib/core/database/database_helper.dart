import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../constants/app_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static DatabaseHelper get instance => _instance;
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final directory = await _getOptimalDatabaseDirectory();
      final path = join(directory.path, AppConstants.databaseName);

      // Ensure directory exists
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      print('Database location: $path');

      return await openDatabase(
        path,
        version: AppConstants.databaseVersion,
        onCreate: _createDatabase,
        onUpgrade: _upgradeDatabase,
      );
    } catch (e) {
      print('Failed to initialize database with optimal directory: $e');
      
      // Fallback: Try with a temporary database in memory
      try {
        print('Falling back to in-memory database');
        return await openDatabase(
          inMemoryDatabasePath,
          version: AppConstants.databaseVersion,
          onCreate: _createDatabase,
          onUpgrade: _upgradeDatabase,
        );
      } catch (fallbackError) {
        print('Failed to create in-memory database: $fallbackError');
        throw Exception('Database initialization failed: $e');
      }
    }
  }

  /// Get the optimal database directory based on platform best practices
  Future<Directory> _getOptimalDatabaseDirectory() async {
    if (Platform.isAndroid || Platform.isIOS) {
      // Mobile platforms: Use Documents directory (backed up on iOS, private on Android)
      return await getApplicationDocumentsDirectory();
    } else {
      // Desktop platforms: Use Application Support directory
      // This follows platform conventions:
      // - Linux: ~/.local/share/advent_hymnals_mobile/
      // - Windows: %APPDATA%\advent_hymnals_mobile\
      // - macOS: ~/Library/Application Support/advent_hymnals_mobile/
      try {
        return await getApplicationSupportDirectory();
      } catch (e) {
        print('Application support directory not available, falling back to documents: $e');
        return await getApplicationDocumentsDirectory();
      }
    }
  }

  /// Check if database is available and working
  Future<bool> isDatabaseAvailable() async {
    try {
      final db = await database;
      await db.rawQuery('SELECT 1');
      return true;
    } catch (e) {
      print('Database availability check failed: $e');
      return false;
    }
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Collections table
    await db.execute('''
      CREATE TABLE collections (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        abbreviation TEXT NOT NULL,
        year INTEGER,
        language TEXT DEFAULT 'English',
        total_hymns INTEGER DEFAULT 0,
        color_hex TEXT,
        description TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Authors table
    await db.execute('''
      CREATE TABLE authors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        birth_year INTEGER,
        death_year INTEGER,
        nationality TEXT,
        biography TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Composers table
    await db.execute('''
      CREATE TABLE composers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        birth_year INTEGER,
        death_year INTEGER,
        nationality TEXT,
        biography TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Topics table
    await db.execute('''
      CREATE TABLE topics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        category TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Hymns table
    await db.execute('''
      CREATE TABLE hymns (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hymn_number INTEGER NOT NULL,
        title TEXT NOT NULL,
        author_id INTEGER,
        author_name TEXT,
        composer_id INTEGER,
        composer TEXT,
        tune_name TEXT,
        meter TEXT,
        collection_id INTEGER,
        lyrics TEXT,
        theme_tags TEXT,
        scripture_refs TEXT,
        first_line TEXT,
        is_favorite INTEGER DEFAULT 0,
        view_count INTEGER DEFAULT 0,
        last_viewed TEXT,
        last_played TEXT,
        play_count INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (author_id) REFERENCES authors(id),
        FOREIGN KEY (composer_id) REFERENCES composers(id),
        FOREIGN KEY (collection_id) REFERENCES collections(id)
      )
    ''');

    // Hymn-topic mapping
    await db.execute('''
      CREATE TABLE hymn_topics (
        hymn_id INTEGER NOT NULL,
        topic_id INTEGER NOT NULL,
        PRIMARY KEY (hymn_id, topic_id),
        FOREIGN KEY (hymn_id) REFERENCES hymns(id),
        FOREIGN KEY (topic_id) REFERENCES topics(id)
      )
    ''');

    // Favorites table
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hymn_id INTEGER NOT NULL,
        user_id TEXT DEFAULT 'default',
        date_added TEXT DEFAULT CURRENT_TIMESTAMP,
        play_count INTEGER DEFAULT 0,
        last_played TEXT,
        FOREIGN KEY (hymn_id) REFERENCES hymns(id),
        UNIQUE(hymn_id, user_id)
      )
    ''');

    // Recently viewed table
    await db.execute('''
      CREATE TABLE recently_viewed (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hymn_id INTEGER NOT NULL,
        user_id TEXT DEFAULT 'default',
        last_viewed TEXT DEFAULT CURRENT_TIMESTAMP,
        view_count INTEGER DEFAULT 1,
        session_duration INTEGER DEFAULT 0,
        FOREIGN KEY (hymn_id) REFERENCES hymns(id),
        UNIQUE(hymn_id, user_id)
      )
    ''');

    // Download cache table
    await db.execute('''
      CREATE TABLE download_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hymn_id INTEGER NOT NULL,
        file_type TEXT NOT NULL,
        file_path TEXT NOT NULL,
        file_size INTEGER,
        quality TEXT,
        download_date TEXT DEFAULT CURRENT_TIMESTAMP,
        last_accessed TEXT DEFAULT CURRENT_TIMESTAMP,
        is_offline_available INTEGER DEFAULT 1,
        FOREIGN KEY (hymn_id) REFERENCES hymns(id)
      )
    ''');

    // Search history table
    await db.execute('''
      CREATE TABLE search_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        query TEXT NOT NULL,
        result_count INTEGER DEFAULT 0,
        searched_at TEXT DEFAULT CURRENT_TIMESTAMP,
        user_id TEXT DEFAULT 'default'
      )
    ''');

    // Metadata table for versioning and app state
    await db.execute('''
      CREATE TABLE metadata (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create indexes for performance
    await db.execute('CREATE INDEX idx_hymns_title ON hymns(title)');
    await db.execute('CREATE INDEX idx_hymns_author ON hymns(author_id)');
    await db.execute('CREATE INDEX idx_hymns_collection ON hymns(collection_id)');
    await db.execute('CREATE INDEX idx_hymns_first_line ON hymns(first_line)');
    await db.execute('CREATE INDEX idx_favorites_hymn_id ON favorites(hymn_id)');
    await db.execute('CREATE INDEX idx_recently_viewed_hymn_id ON recently_viewed(hymn_id)');
    await db.execute('CREATE INDEX idx_download_cache_hymn_id ON download_cache(hymn_id)');
  }

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations in future versions
    if (oldVersion < 2) {
      // Add migration logic here
    }
  }

  // Hymn operations
  Future<int> insertHymn(Map<String, dynamic> hymn) async {
    final db = await database;
    return await db.insert(
      'hymns', 
      hymn,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getHymns({
    int? limit,
    int? offset,
    String? orderBy,
  }) async {
    final db = await database;
    return await db.query(
      'hymns',
      limit: limit,
      offset: offset,
      orderBy: orderBy ?? 'hymn_number ASC',
    );
  }

  Future<Map<String, dynamic>?> getHymnById(int id) async {
    final db = await database;
    final result = await db.query(
      'hymns',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> searchHymns(String query) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT h.*, a.name as author_name, c.name as collection_name, c.abbreviation as collection_abbr
      FROM hymns h
      LEFT JOIN authors a ON h.author_id = a.id
      LEFT JOIN collections c ON h.collection_id = c.id
      WHERE h.title LIKE ? OR h.first_line LIKE ? OR a.name LIKE ? OR h.lyrics LIKE ?
      ORDER BY 
        CASE 
          WHEN h.title LIKE ? THEN 1
          WHEN h.first_line LIKE ? THEN 2
          WHEN a.name LIKE ? THEN 3
          ELSE 4
        END,
        h.title ASC
    ''', [
      '%$query%', '%$query%', '%$query%', '%$query%',
      '$query%', '$query%', '$query%'
    ]);
  }

  Future<List<Map<String, dynamic>>> getHymnsByCollection(int collectionId) async {
    final db = await database;
    return await db.query(
      'hymns',
      where: 'collection_id = ?',
      whereArgs: [collectionId],
      orderBy: 'hymn_number ASC',
    );
  }

  Future<Map<String, dynamic>?> getHymnByNumberInCollection(int hymnNumber, int collectionId) async {
    final db = await database;
    final result = await db.query(
      'hymns',
      where: 'hymn_number = ? AND collection_id = ?',
      whereArgs: [hymnNumber, collectionId],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getHymnsByAuthor(int authorId) async {
    final db = await database;
    return await db.query(
      'hymns',
      where: 'author_id = ?',
      whereArgs: [authorId],
      orderBy: 'title ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getHymnsByTopic(int topicId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT h.*, a.name as author_name, c.name as collection_name
      FROM hymns h
      LEFT JOIN authors a ON h.author_id = a.id
      LEFT JOIN collections c ON h.collection_id = c.id
      INNER JOIN hymn_topics ht ON h.id = ht.hymn_id
      WHERE ht.topic_id = ?
      ORDER BY h.title ASC
    ''', [topicId]);
  }

  // Favorites operations
  Future<int> addFavorite(int hymnId, {String userId = 'default'}) async {
    final db = await database;
    
    // First check if hymn exists
    final hymn = await getHymnById(hymnId);
    if (hymn == null) {
      print('⚠️ [DatabaseHelper] Cannot add favorite: Hymn $hymnId does not exist in database');
      throw Exception('Hymn $hymnId not found in database');
    }
    
    print('💖 [DatabaseHelper] Adding hymn $hymnId to favorites for user $userId');
    final result = await db.insert(
      'favorites',
      {
        'hymn_id': hymnId,
        'user_id': userId,
        'date_added': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    print('✅ [DatabaseHelper] Successfully added favorite with ID: $result');
    return result;
  }

  Future<int> removeFavorite(int hymnId, {String userId = 'default'}) async {
    final db = await database;
    return await db.delete(
      'favorites',
      where: 'hymn_id = ? AND user_id = ?',
      whereArgs: [hymnId, userId],
    );
  }

  Future<List<Map<String, dynamic>>> getFavorites({String userId = 'default'}) async {
    final db = await database;
    print('🔍 [DatabaseHelper] Querying favorites for user: $userId');
    
    final result = await db.rawQuery('''
      SELECT h.*, f.date_added, f.play_count, f.last_played,
             a.name as author_name, c.name as collection_name, c.abbreviation as collection_abbr
      FROM hymns h
      INNER JOIN favorites f ON h.id = f.hymn_id
      LEFT JOIN authors a ON h.author_id = a.id
      LEFT JOIN collections c ON h.collection_id = c.id
      WHERE f.user_id = ?
      ORDER BY f.date_added DESC
    ''', [userId]);
    
    print('📊 [DatabaseHelper] Found ${result.length} favorites from database query');
    return result;
  }

  Future<bool> isFavorite(int hymnId, {String userId = 'default'}) async {
    final db = await database;
    final result = await db.query(
      'favorites',
      where: 'hymn_id = ? AND user_id = ?',
      whereArgs: [hymnId, userId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // Recently viewed operations
  Future<int> addRecentlyViewed(int hymnId, {String userId = 'default'}) async {
    final db = await database;
    
    // First check if hymn exists
    final hymn = await getHymnById(hymnId);
    if (hymn == null) {
      print('⚠️ [DatabaseHelper] Cannot add recently viewed: Hymn $hymnId does not exist in database');
      throw Exception('Hymn $hymnId not found in database');
    }
    
    print('📚 [DatabaseHelper] Adding hymn $hymnId to recently viewed for user $userId');
    
    // Check if already exists
    final existing = await db.query(
      'recently_viewed',
      where: 'hymn_id = ? AND user_id = ?',
      whereArgs: [hymnId, userId],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      // Update existing record
      print('🔄 [DatabaseHelper] Updating existing recently viewed record for hymn $hymnId');
      final result = await db.update(
        'recently_viewed',
        {
          'last_viewed': DateTime.now().toIso8601String(),
          'view_count': (existing.first['view_count'] as int) + 1,
        },
        where: 'hymn_id = ? AND user_id = ?',
        whereArgs: [hymnId, userId],
      );
      print('✅ [DatabaseHelper] Successfully updated recently viewed record: $result');
      return result;
    } else {
      // Insert new record
      print('➕ [DatabaseHelper] Inserting new recently viewed record for hymn $hymnId');
      final result = await db.insert(
        'recently_viewed',
        {
          'hymn_id': hymnId,
          'user_id': userId,
          'last_viewed': DateTime.now().toIso8601String(),
          'view_count': 1,
        },
      );
      print('✅ [DatabaseHelper] Successfully inserted recently viewed record with ID: $result');
      return result;
    }
  }

  Future<List<Map<String, dynamic>>> getRecentlyViewed({
    String userId = 'default',
    int limit = 50,
  }) async {
    final db = await database;
    print('🔍 [DatabaseHelper] Querying recently viewed for user: $userId (limit: $limit)');
    
    final result = await db.rawQuery('''
      SELECT h.*, rv.last_viewed, rv.view_count,
             a.name as author_name, c.name as collection_name, c.abbreviation as collection_abbr
      FROM hymns h
      INNER JOIN recently_viewed rv ON h.id = rv.hymn_id
      LEFT JOIN authors a ON h.author_id = a.id
      LEFT JOIN collections c ON h.collection_id = c.id
      WHERE rv.user_id = ?
      ORDER BY rv.last_viewed DESC
      LIMIT ?
    ''', [userId, limit]);
    
    print('📊 [DatabaseHelper] Found ${result.length} recently viewed hymns from database query');
    if (result.isNotEmpty) {
      for (final hymn in result.take(3)) {
        print('  - Hymn ${hymn['hymn_number']}: ${hymn['title']} (last viewed: ${hymn['last_viewed']})');
      }
    }
    return result;
  }

  Future<int> clearRecentlyViewed({String userId = 'default'}) async {
    final db = await database;
    return await db.delete(
      'recently_viewed',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // Download cache operations
  Future<int> addDownloadCache(
    int hymnId,
    String fileType,
    String filePath,
    String? quality,
    int? fileSize,
  ) async {
    final db = await database;
    return await db.insert(
      'download_cache',
      {
        'hymn_id': hymnId,
        'file_type': fileType,
        'file_path': filePath,
        'quality': quality,
        'file_size': fileSize,
        'download_date': DateTime.now().toIso8601String(),
        'last_accessed': DateTime.now().toIso8601String(),
        'is_offline_available': 1,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getDownloadCache({
    int? hymnId,
    String? fileType,
  }) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (hymnId != null) {
      whereClause = 'hymn_id = ?';
      whereArgs.add(hymnId);
    }

    if (fileType != null) {
      if (whereClause.isNotEmpty) {
        whereClause += ' AND ';
      }
      whereClause += 'file_type = ?';
      whereArgs.add(fileType);
    }

    return await db.query(
      'download_cache',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'download_date DESC',
    );
  }

  Future<bool> isMediaDownloaded(int hymnId, String fileType) async {
    final db = await database;
    final result = await db.query(
      'download_cache',
      where: 'hymn_id = ? AND file_type = ? AND is_offline_available = 1',
      whereArgs: [hymnId, fileType],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // Collection operations
  Future<int> insertCollection(Map<String, dynamic> collection) async {
    final db = await database;
    return await db.insert(
      'collections', 
      collection,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getCollections() async {
    final db = await database;
    return await db.query('collections', orderBy: 'name ASC');
  }

  Future<Map<String, dynamic>?> getCollectionByAbbreviation(String abbreviation) async {
    final db = await database;
    final result = await db.query(
      'collections',
      where: 'abbreviation = ?',
      whereArgs: [abbreviation],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Author operations
  Future<int> insertAuthor(Map<String, dynamic> author) async {
    final db = await database;
    return await db.insert('authors', author);
  }

  Future<List<Map<String, dynamic>>> getAuthors() async {
    final db = await database;
    return await db.query('authors', orderBy: 'name ASC');
  }

  // Topic operations
  Future<int> insertTopic(Map<String, dynamic> topic) async {
    final db = await database;
    return await db.insert('topics', topic);
  }

  Future<List<Map<String, dynamic>>> getTopics() async {
    final db = await database;
    return await db.query('topics', orderBy: 'name ASC');
  }

  // Search history operations
  Future<int> addSearchHistory(String query, int resultCount) async {
    final db = await database;
    return await db.insert(
      'search_history',
      {
        'query': query,
        'result_count': resultCount,
        'searched_at': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<List<Map<String, dynamic>>> getSearchHistory({int limit = 10}) async {
    final db = await database;
    return await db.query(
      'search_history',
      orderBy: 'searched_at DESC',
      limit: limit,
    );
  }

  // Utility methods
  Future<int> getHymnCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM hymns');
    return result.first['count'] as int;
  }

  Future<int> getFavoritesCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM favorites');
    return result.first['count'] as int;
  }

  Future<void> clearAllData() async {
    try {
      final db = await database;
      await db.delete('hymns');
      await db.delete('favorites');
      await db.delete('recently_viewed');
      await db.delete('download_cache');
      await db.delete('search_history');
      await db.delete('collections');
      await db.delete('authors');
      await db.delete('topics');
      await db.delete('hymn_topics');
      
      // Try to delete metadata, but don't fail if table doesn't exist
      try {
        await db.delete('metadata');
      } catch (e) {
        print('Warning: Could not clear metadata table (may not exist): $e');
      }
    } catch (e) {
      print('Error clearing database: $e');
      rethrow;
    }
  }

  Future<void> closeDatabase() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  // Metadata methods for data versioning
  Future<String?> getMetadata(String key) async {
    try {
      final db = await database;
      final result = await db.query(
        'metadata',
        where: 'key = ?',
        whereArgs: [key],
      );
      if (result.isNotEmpty) {
        return result.first['value'] as String?;
      }
      return null;
    } catch (e) {
      print('❌ [DatabaseHelper] Error getting metadata for key $key: $e');
      return null;
    }
  }

  Future<void> setMetadata(String key, String value) async {
    try {
      final db = await database;
      await db.insert(
        'metadata',
        {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('❌ [DatabaseHelper] Error setting metadata for key $key: $e');
      rethrow;
    }
  }


  // Initialize database method (public)
  Future<void> initDatabase() async {
    await database; // This will trigger initialization
  }

  // Search hymns within a specific collection
  Future<List<Map<String, dynamic>>> searchHymnsInCollection(String query, int collectionId) async {
    try {
      final db = await database;
      
      // Create the WHERE clause for full-text search within collection
      const whereClause = '''
        collection_id = ? AND (
          title LIKE ? OR 
          author_name LIKE ? OR 
          composer LIKE ? OR 
          tune_name LIKE ? OR 
          meter LIKE ? OR 
          first_line LIKE ? OR 
          lyrics LIKE ? OR 
          CAST(hymn_number AS TEXT) LIKE ?
        )
      ''';
      
      final searchTerm = '%$query%';
      final whereArgs = [
        collectionId,
        searchTerm, searchTerm, searchTerm, searchTerm, 
        searchTerm, searchTerm, searchTerm, searchTerm
      ];
      
      final result = await db.query(
        'hymns',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'hymn_number ASC',
      );
      
      print('🔍 [DatabaseHelper] Collection search found ${result.length} results for "$query" in collection $collectionId');
      return result;
    } catch (e) {
      print('❌ [DatabaseHelper] Collection search failed: $e');
      return [];
    }
  }
}