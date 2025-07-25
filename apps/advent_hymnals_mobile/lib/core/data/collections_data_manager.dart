import 'dart:convert';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import '../update/update_manager.dart';

class CollectionsDataManager {
  static final CollectionsDataManager _instance = CollectionsDataManager._internal();
  factory CollectionsDataManager() => _instance;
  CollectionsDataManager._internal();

  Map<String, dynamic>? _cachedCollectionsData;
  List<CollectionInfo>? _cachedCollectionsList;
  
  /// Load collections data with UpdateManager fallback to assets
  Future<Map<String, dynamic>> loadCollectionsData() async {
    if (_cachedCollectionsData != null) {
      print('✅ [CollectionsDataManager] Using cached collections data');
      return _cachedCollectionsData!;
    }

    try {
      print('🔍 [CollectionsDataManager] Loading collections data...');
      
      // First try to load from update system (database/cached data)
      final updateManager = UpdateManager();
      await updateManager.initialize();
      
      String? collectionsJson = await updateManager.getDataWithFallback('collections-index.json');
      
      // If update system doesn't have it, fallback to bundled assets
      if (collectionsJson == null) {
        try {
          collectionsJson = await rootBundle.loadString('assets/data/collections-index.json');
          print('✅ [CollectionsDataManager] Loaded collections from bundled assets (fallback)');
        } catch (e) {
          print('❌ [CollectionsDataManager] Failed to load from assets: $e');
          collectionsJson = '{}';
        }
      } else {
        print('✅ [CollectionsDataManager] Loaded collections from update system');
      }
      
      final collectionsData = json.decode(collectionsJson) as Map<String, dynamic>;
      print('📊 [CollectionsDataManager] Loaded ${collectionsData.keys.length} collections: ${collectionsData.keys.toList()}');
      
      _cachedCollectionsData = collectionsData;
      return collectionsData;
    } catch (e) {
      print('❌ [CollectionsDataManager] Error loading collections: $e');
      return {};
    }
  }

  /// Get collections as a list of CollectionInfo objects
  Future<List<CollectionInfo>> getCollectionsList({bool sortByYear = true}) async {
    if (_cachedCollectionsList != null) {
      return _cachedCollectionsList!;
    }

    final collectionsData = await loadCollectionsData();
    final collections = <CollectionInfo>[];
    
    final colorMap = {
      'SDAH': const Color(AppColors.primaryBlue),
      'CS1900': const Color(AppColors.successGreen), 
      'CH1941': const Color(AppColors.purple),
      'HT1869': const Color(AppColors.warningOrange),
      'HT1876': const Color(AppColors.infoBlue),
      'HT1886': const Color(AppColors.darkPurple),
      'CM2000': const Color(AppColors.gray600),
      'NZK': const Color(AppColors.errorRed),
      'WN': const Color(AppColors.gray700),
    };
    
    collectionsData.forEach((id, data) {
      final name = data['name'] as String;
      final year = data['year'] as int? ?? 0;
      final totalSongs = data['total_songs'] as int? ?? 0;
      final language = data['language'] as String;
      final bundled = data['bundled'] as bool? ?? false;
      
      // Format language names
      String languageName;
      switch (language) {
        case 'en':
          languageName = 'English';
          break;
        case 'swa':
          languageName = 'Kiswahili';
          break;
        case 'luo':
          languageName = 'Dholuo';
          break;
        default:
          languageName = language.toUpperCase();
      }
      
      collections.add(CollectionInfo(
        id: id,
        title: name,
        subtitle: '${data['abbreviation']} • ${totalSongs > 0 ? '$totalSongs hymns' : 'Hymn count unknown'} • $languageName${bundled ? ' • Downloaded' : ''}',
        description: bundled 
            ? 'Available offline with $totalSongs hymns in $languageName. Published in $year.'
            : 'Collection with $totalSongs hymns in $languageName. Published in $year. Download required.',
        color: colorMap[id] ?? const Color(AppColors.primaryBlue),
        language: languageName,
        hymnCount: totalSongs,
        isAvailable: true,
        bundled: bundled,
        year: year,
      ));
    });
    
    if (sortByYear) {
      // Sort by year (newest first) 
      collections.sort((a, b) => b.year.compareTo(a.year));
    }
    
    _cachedCollectionsList = collections;
    return collections;
  }

  /// Get a specific collection by ID
  Future<CollectionInfo?> getCollectionById(String collectionId) async {
    final collections = await getCollectionsList();
    final normalizedId = collectionId.toUpperCase();
    
    try {
      return collections.firstWhere(
        (collection) => collection.id.toUpperCase() == normalizedId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get hymnal abbreviations for use in search query parsing
  Future<Map<String, String>> getHymnalAbbreviations() async {
    final collectionsData = await loadCollectionsData();
    final abbreviations = <String, String>{};
    
    collectionsData.forEach((id, data) {
      final abbreviation = data['abbreviation'] as String;
      
      // Add the main abbreviation (e.g., "SDAH" -> "SDAH")
      abbreviations[abbreviation.toLowerCase()] = abbreviation;
      
      // Add the full ID as an alternative (e.g., "cs1900" -> "CS1900")
      abbreviations[id.toLowerCase()] = abbreviation;
      
      // Add common short forms and variations
      switch (abbreviation) {
        case 'SDAH':
          abbreviations['sda'] = abbreviation;
          abbreviations['adventist'] = abbreviation;
          break;
        case 'CH1941':
          abbreviations['ch'] = abbreviation;
          abbreviations['christ'] = abbreviation;
          abbreviations['christinsong'] = abbreviation;
          break;
        case 'CS1900':
          abbreviations['cs'] = abbreviation;
          abbreviations['christinsong'] = abbreviation;
          break;
        case 'HT1869':
        case 'HT1876':
        case 'HT1886':
          abbreviations['ht'] = abbreviation; // Will use the last one found
          abbreviations['hymnstunes'] = abbreviation;
          break;
        case 'CM2000':
          abbreviations['cm'] = abbreviation;
          abbreviations['campus'] = abbreviation;
          break;
        case 'NZK':
          abbreviations['nyimbo'] = abbreviation;
          break;
        case 'WN':
          abbreviations['wende'] = abbreviation;
          break;
      }
    });
    
    print('🔍 [CollectionsDataManager] Loaded ${abbreviations.length} abbreviations: ${abbreviations.keys.take(10).join(', ')}${abbreviations.length > 10 ? '...' : ''}');
    
    return abbreviations;
  }

  /// Clear cache to force reload
  void clearCache() {
    _cachedCollectionsData = null;
    _cachedCollectionsList = null;
    print('🔄 [CollectionsDataManager] Cache cleared');
  }
}

class CollectionInfo {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final Color color;
  final String language;
  final int hymnCount;
  final bool isAvailable;
  final bool bundled;
  final int year;

  CollectionInfo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
    required this.language,
    required this.hymnCount,
    required this.isAvailable,
    required this.bundled,
    required this.year,
  });
}