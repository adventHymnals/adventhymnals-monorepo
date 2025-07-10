import 'dart:convert';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import '../update/update_manager.dart';
import '../../domain/entities/hymn.dart';

class HymnDataManager {
  static final HymnDataManager _instance = HymnDataManager._internal();
  factory HymnDataManager() => _instance;
  HymnDataManager._internal();

  Map<String, dynamic>? _cachedBundledIndex;
  Map<String, Hymn>? _cachedHymns;
  
  /// Load bundled hymns index
  Future<Map<String, dynamic>> loadBundledHymnsIndex() async {
    if (_cachedBundledIndex != null) {
      print('✅ [HymnDataManager] Using cached bundled hymns index');
      return _cachedBundledIndex!;
    }

    try {
      print('🔍 [HymnDataManager] Loading bundled hymns index...');
      
      // First try to load from update system (database/cached data)
      final updateManager = UpdateManager();
      await updateManager.initialize();
      
      String? indexJson = await updateManager.getDataWithFallback('bundled-hymns-index.json');
      
      // If update system doesn't have it, fallback to bundled assets
      if (indexJson == null) {
        try {
          indexJson = await rootBundle.loadString('assets/data/bundled-hymns-index.json');
          print('✅ [HymnDataManager] Loaded bundled hymns index from assets (fallback)');
        } catch (e) {
          print('❌ [HymnDataManager] Failed to load bundled hymns index from assets: $e');
          indexJson = '{}';
        }
      } else {
        print('✅ [HymnDataManager] Loaded bundled hymns index from update system');
      }
      
      final indexData = json.decode(indexJson) as Map<String, dynamic>;
      print('📊 [HymnDataManager] Loaded hymn index for ${indexData.keys.length} collections: ${indexData.keys.toList()}');
      
      _cachedBundledIndex = indexData;
      return indexData;
    } catch (e) {
      print('❌ [HymnDataManager] Error loading bundled hymns index: $e');
      return {};
    }
  }

  /// Load hymn data from JSON file
  Future<Hymn?> loadHymnFromJson(String hymnId) async {
    try {
      // Check cache first
      if (_cachedHymns != null && _cachedHymns!.containsKey(hymnId)) {
        return _cachedHymns![hymnId];
      }

      print('🔍 [HymnDataManager] Loading hymn $hymnId from JSON...');
      
      // Extract collection from hymn ID (e.g., "SDAH-en-003" -> "SDAH")
      final parts = hymnId.split('-');
      if (parts.length < 3) {
        print('❌ [HymnDataManager] Invalid hymn ID format: $hymnId');
        return null;
      }
      
      final collection = parts[0];
      final assetPath = 'assets/data/hymns/$collection/$hymnId.json';
      
      String? hymnJson;
      
      // Try update system first
      final updateManager = UpdateManager();
      await updateManager.initialize();
      hymnJson = await updateManager.getDataWithFallback('hymns/$collection/$hymnId.json');
      
      // Fallback to bundled assets
      if (hymnJson == null) {
        try {
          hymnJson = await rootBundle.loadString(assetPath);
          print('✅ [HymnDataManager] Loaded hymn $hymnId from assets (fallback)');
        } catch (e) {
          print('❌ [HymnDataManager] Failed to load hymn $hymnId from assets: $e');
          return null;
        }
      } else {
        print('✅ [HymnDataManager] Loaded hymn $hymnId from update system');
      }
      
      final hymnData = json.decode(hymnJson) as Map<String, dynamic>;
      final hymn = _parseHymnFromJson(hymnData);
      
      // Cache the hymn
      _cachedHymns ??= {};
      _cachedHymns![hymnId] = hymn;
      
      return hymn;
    } catch (e) {
      print('❌ [HymnDataManager] Error loading hymn $hymnId: $e');
      return null;
    }
  }

  /// Get hymns for a specific collection
  Future<List<Hymn>> getHymnsForCollection(String collectionAbbreviation) async {
    try {
      print('🎵 [HymnDataManager] Loading hymns for collection "$collectionAbbreviation"');
      
      final bundledIndex = await loadBundledHymnsIndex();
      final hymnIds = bundledIndex[collectionAbbreviation.toUpperCase()] as List<dynamic>?;
      
      if (hymnIds == null || hymnIds.isEmpty) {
        print('⚠️ [HymnDataManager] No hymns found for collection "$collectionAbbreviation"');
        return [];
      }
      
      print('📋 [HymnDataManager] Found ${hymnIds.length} hymns for collection "$collectionAbbreviation"');
      
      final hymns = <Hymn>[];
      
      // Sort hymn IDs by number first to ensure we get hymns 1, 2, 3, etc.
      final sortedHymnIds = hymnIds.cast<String>().toList();
      sortedHymnIds.sort((a, b) {
        final numA = int.tryParse(a.split('-').last) ?? 0;
        final numB = int.tryParse(b.split('-').last) ?? 0;
        return numA.compareTo(numB);
      });
      
      // Load a subset of hymns for performance (first 30 hymns by number)
      final hymnIdsToLoad = sortedHymnIds.take(30);
      
      for (final hymnId in hymnIdsToLoad) {
        final hymn = await loadHymnFromJson(hymnId);
        if (hymn != null) {
          hymns.add(hymn);
        }
      }
      
      // Final sort by hymn number (should already be sorted, but just to be sure)
      hymns.sort((a, b) => a.hymnNumber.compareTo(b.hymnNumber));
      
      print('✅ [HymnDataManager] Successfully loaded ${hymns.length} hymns for collection "$collectionAbbreviation"');
      return hymns;
    } catch (e) {
      print('❌ [HymnDataManager] Error loading hymns for collection "$collectionAbbreviation": $e');
      return [];
    }
  }

  /// Parse hymn from JSON data
  Hymn _parseHymnFromJson(Map<String, dynamic> data) {
    final verses = data['verses'] as List<dynamic>? ?? [];
    final metadata = data['metadata'] as Map<String, dynamic>? ?? {};
    
    // Combine verses into lyrics
    final lyrics = verses
        .map((verse) => verse['text'] as String? ?? '')
        .where((text) => text.isNotEmpty)
        .join('\n\n');
    
    // Get first line from first verse
    final firstLine = verses.isNotEmpty 
        ? (verses[0]['text'] as String? ?? '').split('\n').first 
        : '';
    
    // Extract hymn number from ID (e.g., "SDAH-en-003" -> 3)
    final hymnId = data['id'] as String;
    final numberMatch = RegExp(r'-(\d+)$').firstMatch(hymnId);
    final hymnNumber = numberMatch != null 
        ? int.tryParse(numberMatch.group(1)!) ?? 0
        : 0;
    
    return Hymn(
      id: hymnNumber, // Use numeric ID for compatibility
      hymnNumber: hymnNumber,
      title: data['title'] as String? ?? 'Unknown Title',
      author: data['author'] as String?,
      composer: data['composer'] as String?,
      tuneName: data['tune'] as String?,
      meter: data['meter'] as String?,
      collectionId: 1, // Default collection ID
      lyrics: lyrics.isNotEmpty ? lyrics : null,
      firstLine: firstLine.isNotEmpty ? firstLine : null,
      themeTags: (metadata['themes'] as List<dynamic>?)?.cast<String>(),
      scriptureRefs: (metadata['scripture_references'] as List<dynamic>?)?.cast<String>(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isFavorite: false,
    );
  }

  /// Clear cache to force reload
  void clearCache() {
    _cachedBundledIndex = null;
    _cachedHymns = null;
    print('🔄 [HymnDataManager] Cache cleared');
  }
}