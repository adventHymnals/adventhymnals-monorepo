import 'dart:convert';
import 'package:flutter/services.dart';
import '../database/database_helper.dart';
import '../data/collections_data_manager.dart';
import '../data/hymn_data_manager.dart';
import '../../domain/entities/hymn.dart';

class DataImportService {
  static const String _dataVersionKey = 'data_version';
  static const String _currentDataVersion = '1.0.0';
  
  final DatabaseHelper _db = DatabaseHelper.instance;
  final CollectionsDataManager _collectionsManager = CollectionsDataManager();
  final HymnDataManager _hymnManager = HymnDataManager();

  /// Check if data import is needed
  Future<bool> isImportNeeded() async {
    try {
      // Check if database is available
      final isDbAvailable = await _db.isDatabaseAvailable();
      if (!isDbAvailable) {
        print('📦 [DataImport] Database not available, import needed');
        return true;
      }

      // Check if hymns table has data
      final hymnCount = await _db.getHymnCount();
      if (hymnCount == 0) {
        print('📦 [DataImport] No hymns in database, import needed');
        return true;
      }

      // Check data version
      final storedVersion = await _db.getMetadata(_dataVersionKey);
      if (storedVersion != _currentDataVersion) {
        print('📦 [DataImport] Data version mismatch (stored: $storedVersion, current: $_currentDataVersion), import needed');
        return true;
      }

      print('📦 [DataImport] Database up to date with $hymnCount hymns');
      return false;
    } catch (e) {
      print('❌ [DataImport] Error checking import status: $e');
      return true; // Import on error to be safe
    }
  }

  /// Import all JSON data into database
  Future<ImportResult> importAllData({
    Function(String)? onProgress,
  }) async {
    final result = ImportResult();
    
    try {
      onProgress?.call('Initializing database...');
      
      // Ensure database is initialized
      await _db.initDatabase();
      
      // Clear existing data
      onProgress?.call('Clearing existing data...');
      await _db.clearAllData();
      
      // Import collections
      onProgress?.call('Loading collections...');
      result.collectionsImported = await _importCollections();
      
      // Import hymns
      onProgress?.call('Loading hymns...');
      result.hymnsImported = await _importHymns(onProgress);
      
      // Set data version
      onProgress?.call('Finalizing import...');
      await _db.setMetadata(_dataVersionKey, _currentDataVersion);
      
      result.success = true;
      onProgress?.call('Import complete!');
      
      print('✅ [DataImport] Import completed successfully: ${result.hymnsImported} hymns, ${result.collectionsImported} collections');
      
    } catch (e, stackTrace) {
      print('❌ [DataImport] Import failed: $e');
      print('Stack trace: $stackTrace');
      result.success = false;
      result.error = e.toString();
    }
    
    return result;
  }

  /// Import collections from JSON
  Future<int> _importCollections() async {
    try {
      final collections = await _collectionsManager.getCollectionsList();
      int imported = 0;
      
      for (final collection in collections) {
        await _db.insertCollection({
          'name': collection.title,
          'abbreviation': collection.id, // Use ID as abbreviation
          'description': collection.description,
          'language': collection.language,
          'total_hymns': collection.hymnCount,
          'year': collection.year,
          'color_hex': '#${collection.color.value.toRadixString(16).padLeft(8, '0')}',
        });
        imported++;
      }
      
      print('📚 [DataImport] Imported $imported collections');
      return imported;
    } catch (e) {
      print('❌ [DataImport] Failed to import collections: $e');
      rethrow;
    }
  }

  /// Import hymns from JSON files
  Future<int> _importHymns(Function(String)? onProgress) async {
    try {
      // Load bundled hymns index
      final String indexContent = await rootBundle.loadString(
        'assets/data/bundled-hymns-index.json'
      );
      final Map<String, dynamic> bundledIndex = json.decode(indexContent);
      
      int totalImported = 0;
      int totalToImport = 0;
      
      // Count total hymns to import
      for (final entry in bundledIndex.entries) {
        final List<dynamic> hymnIds = entry.value;
        totalToImport += hymnIds.length;
      }
      
      print('📖 [DataImport] Found $totalToImport hymns to import');
      
      // Import hymns for each collection
      for (final entry in bundledIndex.entries) {
        final String collectionId = entry.key;
        final List<dynamic> hymnIds = entry.value;
        
        onProgress?.call('Loading $collectionId hymns (${totalImported + 1}/$totalToImport)...');
        
        for (final hymnId in hymnIds) {
          try {
            final hymn = await _loadHymnFromAssets(hymnId as String);
            if (hymn != null) {
              await _insertHymnToDatabase(hymn, collectionId);
              totalImported++;
              
              // Update progress every 10 hymns
              if (totalImported % 10 == 0) {
                onProgress?.call('Loading hymns ($totalImported/$totalToImport)...');
              }
            }
          } catch (e) {
            print('⚠️ [DataImport] Failed to import hymn $hymnId: $e');
            // Continue with other hymns
          }
        }
      }
      
      print('📖 [DataImport] Imported $totalImported hymns');
      return totalImported;
    } catch (e) {
      print('❌ [DataImport] Failed to import hymns: $e');
      rethrow;
    }
  }

  /// Load individual hymn from assets
  Future<Hymn?> _loadHymnFromAssets(String hymnId) async {
    try {
      // Extract collection from hymn ID (e.g., "SDAH-en-001" -> "SDAH")
      final parts = hymnId.split('-');
      if (parts.length < 3) return null;
      
      final collectionId = parts[0];
      final filePath = 'assets/data/hymns/$collectionId/$hymnId.json';
      
      final String content = await rootBundle.loadString(filePath);
      final Map<String, dynamic> data = json.decode(content);
      
      return Hymn.fromJson(data);
    } catch (e) {
      print('⚠️ [DataImport] Failed to load hymn $hymnId: $e');
      return null;
    }
  }

  /// Insert hymn into database
  Future<void> _insertHymnToDatabase(Hymn hymn, String collectionId) async {
    // Get collection ID from database by matching the abbreviation (id field) with collectionId
    final collections = await _db.getCollections();
    int? dbCollectionId;
    
    // Find collection by matching the title or abbreviation with collectionId
    for (final collection in collections) {
      if (collection['abbreviation'] == collectionId || 
          collection['name']?.toString().toUpperCase() == collectionId ||
          collection['id']?.toString() == collectionId) {
        dbCollectionId = collection['id'] as int?;
        break;
      }
    }
    
    await _db.insertHymn({
      'hymn_number': hymn.hymnNumber,
      'title': hymn.title,
      'author_name': hymn.author, // Using author_name field that exists in schema
      'composer': hymn.composer,
      'tune_name': hymn.tuneName,
      'meter': hymn.meter,
      'collection_id': dbCollectionId,
      'lyrics': hymn.lyrics,
      'theme_tags': hymn.themeTags?.join(','),
      'scripture_refs': hymn.scriptureRefs?.join(','),
      'first_line': hymn.firstLine,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_favorite': 0,
      'view_count': 0,
      'play_count': 0,
    });
  }
}

class ImportResult {
  bool success = false;
  int hymnsImported = 0;
  int collectionsImported = 0;
  String? error;
  
  @override
  String toString() {
    if (success) {
      return 'Import successful: $hymnsImported hymns, $collectionsImported collections';
    } else {
      return 'Import failed: $error';
    }
  }
}