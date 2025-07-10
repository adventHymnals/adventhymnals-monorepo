import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/hymn.dart';
import '../constants/app_constants.dart';

class DataManager {
  static const String _baseDataPath = 'assets/data';
  static const String _hymnalsReference = '$_baseDataPath/hymnals-reference.json';
  static const String _versionKey = 'data_version';
  static const String _lastUpdateKey = 'last_update_check';
  
  final Dio _dio = Dio();
  SharedPreferences? _prefs;
  Map<String, dynamic>? _hymnalsReference;
  
  // Singleton pattern
  static final DataManager _instance = DataManager._internal();
  factory DataManager() => _instance;
  DataManager._internal();

  /// Initialize the data manager
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadHymnalsReference();
    await _checkForUpdates();
  }

  /// Load the hymnals reference data
  Future<void> _loadHymnalsReference() async {
    try {
      // Try to load from assets first
      final String referenceData = await rootBundle.loadString(_hymnalsReference);
      _hymnalsReference = json.decode(referenceData);
    } catch (e) {
      print('Error loading hymnals reference: $e');
      // Fallback to empty structure
      _hymnalsReference = {
        'hymnals': {},
        'languages': {},
        'metadata': {'total_hymnals': 0}
      };
    }
  }

  /// Get list of available hymnals
  List<HymnalInfo> getAvailableHymnals() {
    if (_hymnalsReference == null) return [];
    
    final hymnals = _hymnalsReference!['hymnals'] as Map<String, dynamic>;
    return hymnals.entries.map((entry) {
      final data = entry.value as Map<String, dynamic>;
      return HymnalInfo.fromJson(data);
    }).toList();
  }

  /// Get hymnal by ID
  Future<HymnalCollection?> getHymnal(String hymnalId) async {
    try {
      // Check if bundled with app
      final bundledPath = '$_baseDataPath/hymnals/$hymnalId-collection.json';
      String? jsonData;
      
      try {
        jsonData = await rootBundle.loadString(bundledPath);
      } catch (_) {
        // Not bundled, check downloaded cache
        jsonData = await _getDownloadedHymnal(hymnalId);
      }
      
      if (jsonData != null) {
        final data = json.decode(jsonData);
        return HymnalCollection.fromJson(data);
      }
      
      return null;
    } catch (e) {
      print('Error loading hymnal $hymnalId: $e');
      return null;
    }
  }

  /// Get specific hymn content
  Future<Hymn?> getHymn(String hymnId) async {
    try {
      // Extract collection ID from hymn ID (e.g., "SDAH-en-001" -> "SDAH")
      final parts = hymnId.split('-');
      if (parts.length < 3) return null;
      
      final collectionId = parts[0];
      final hymnPath = '$_baseDataPath/hymns/$collectionId/$hymnId.json';
      
      String? jsonData;
      try {
        jsonData = await rootBundle.loadString(hymnPath);
      } catch (_) {
        // Not bundled, check downloaded cache
        jsonData = await _getDownloadedHymn(hymnId);
      }
      
      if (jsonData != null) {
        final data = json.decode(jsonData);
        return Hymn.fromJsonData(data);
      }
      
      return null;
    } catch (e) {
      print('Error loading hymn $hymnId: $e');
      return null;
    }
  }

  /// Download hymnal collection on-demand
  Future<bool> downloadHymnal(String hymnalId) async {
    try {
      final info = _getHymnalInfo(hymnalId);
      if (info == null) return false;

      // Download collection metadata
      final collectionUrl = '${AppConstants.apiBaseUrl}/collections/$hymnalId.json';
      final response = await _dio.get(collectionUrl);
      
      if (response.statusCode == 200) {
        await _saveDownloadedData('hymnals/$hymnalId-collection.json', response.data);
        
        // Download hymns in batches
        await _downloadHymnBatch(hymnalId, info.totalSongs ?? 0);
        
        // Mark as downloaded
        await _markHymnalDownloaded(hymnalId);
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error downloading hymnal $hymnalId: $e');
      return false;
    }
  }

  /// Check for data updates
  Future<void> _checkForUpdates() async {
    final lastCheck = _prefs?.getInt(_lastUpdateKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Check for updates every 24 hours
    if (now - lastCheck < 24 * 60 * 60 * 1000) return;
    
    try {
      final versionUrl = '${AppConstants.apiBaseUrl}/version.json';
      final response = await _dio.get(versionUrl);
      
      if (response.statusCode == 200) {
        final remoteVersion = response.data['version'];
        final localVersion = _prefs?.getString(_versionKey) ?? '0.0.0';
        
        if (_isVersionNewer(remoteVersion, localVersion)) {
          await _downloadUpdates(response.data);
        }
        
        await _prefs?.setInt(_lastUpdateKey, now);
      }
    } catch (e) {
      print('Error checking for updates: $e');
    }
  }

  /// Search hymns across all downloaded collections
  Future<List<Hymn>> searchHymns(String query, {
    List<String>? collections,
    List<String>? languages,
    List<String>? themes,
  }) async {
    final results = <Hymn>[];
    final searchTerms = query.toLowerCase().split(' ');
    
    final availableHymnals = getAvailableHymnals();
    for (final hymnal in availableHymnals) {
      if (collections != null && !collections.contains(hymnal.id)) continue;
      if (languages != null && !languages.contains(hymnal.language)) continue;
      
      try {
        final collection = await getHymnal(hymnal.id);
        if (collection == null) continue;
        
        for (final hymnRef in collection.hymns) {
          final hymn = await getHymn(hymnRef.hymnId);
          if (hymn == null) continue;
          
          // Search in title, author, and themes
          final searchableText = [
            hymn.title,
            hymn.author ?? '',
            ...hymn.themeTags ?? [],
          ].join(' ').toLowerCase();
          
          final matches = searchTerms.every(
            (term) => searchableText.contains(term)
          );
          
          if (matches) {
            // Filter by themes if specified
            if (themes != null && themes.isNotEmpty) {
              final hymnThemes = hymn.themeTags ?? [];
              if (!themes.any((theme) => hymnThemes.contains(theme))) {
                continue;
              }
            }
            
            results.add(hymn);
          }
        }
      } catch (e) {
        print('Error searching in hymnal ${hymnal.id}: $e');
      }
    }
    
    return results;
  }

  /// Get statistics about data usage
  Map<String, dynamic> getDataStats() {
    final downloaded = _getDownloadedHymnals();
    final totalSize = _calculateDataSize();
    
    return {
      'downloaded_hymnals': downloaded.length,
      'total_hymnals': _hymnalsReference?['metadata']['total_hymnals'] ?? 0,
      'storage_used_mb': (totalSize / (1024 * 1024)).toStringAsFixed(1),
      'last_update': _prefs?.getInt(_lastUpdateKey),
      'version': _prefs?.getString(_versionKey) ?? '0.0.0',
    };
  }

  // Private helper methods
  HymnalInfo? _getHymnalInfo(String hymnalId) {
    final hymnals = _hymnalsReference?['hymnals'] as Map<String, dynamic>?;
    final data = hymnals?[hymnalId] as Map<String, dynamic>?;
    return data != null ? HymnalInfo.fromJson(data) : null;
  }

  Future<String?> _getDownloadedHymnal(String hymnalId) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/data/hymnals/$hymnalId-collection.json');
      if (await file.exists()) {
        return await file.readAsString();
      }
    } catch (e) {
      print('Error reading downloaded hymnal: $e');
    }
    return null;
  }

  Future<String?> _getDownloadedHymn(String hymnId) async {
    try {
      final parts = hymnId.split('-');
      final collectionId = parts[0];
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/data/hymns/$collectionId/$hymnId.json');
      if (await file.exists()) {
        return await file.readAsString();
      }
    } catch (e) {
      print('Error reading downloaded hymn: $e');
    }
    return null;
  }

  Future<void> _saveDownloadedData(String path, dynamic data) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/data/$path');
      await file.parent.create(recursive: true);
      
      final jsonString = data is String ? data : json.encode(data);
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error saving downloaded data: $e');
    }
  }

  Future<void> _downloadHymnBatch(String hymnalId, int totalHymns) async {
    // Download hymns in batches to avoid overwhelming the server
    const batchSize = 50;
    for (int i = 1; i <= totalHymns; i += batchSize) {
      final end = (i + batchSize - 1).clamp(1, totalHymns);
      await _downloadHymnRange(hymnalId, i, end);
    }
  }

  Future<void> _downloadHymnRange(String hymnalId, int start, int end) async {
    for (int i = start; i <= end; i++) {
      try {
        final hymnId = '$hymnalId-en-${i.toString().padLeft(3, '0')}';
        final hymnUrl = '${AppConstants.apiBaseUrl}/hymns/$hymnalId/$hymnId.json';
        
        final response = await _dio.get(hymnUrl);
        if (response.statusCode == 200) {
          await _saveDownloadedData('hymns/$hymnalId/$hymnId.json', response.data);
        }
      } catch (e) {
        // Continue with next hymn if one fails
        print('Error downloading hymn $hymnalId-$i: $e');
      }
    }
  }

  Future<void> _markHymnalDownloaded(String hymnalId) async {
    final downloaded = _getDownloadedHymnals();
    downloaded.add(hymnalId);
    await _prefs?.setStringList('downloaded_hymnals', downloaded);
  }

  List<String> _getDownloadedHymnals() {
    return _prefs?.getStringList('downloaded_hymnals') ?? [];
  }

  bool _isVersionNewer(String remote, String local) {
    final remoteParts = remote.split('.').map(int.parse).toList();
    final localParts = local.split('.').map(int.parse).toList();
    
    for (int i = 0; i < 3; i++) {
      if (remoteParts[i] > localParts[i]) return true;
      if (remoteParts[i] < localParts[i]) return false;
    }
    return false;
  }

  Future<void> _downloadUpdates(Map<String, dynamic> versionData) async {
    // Download incremental updates
    final updates = versionData['updates'] as List<dynamic>?;
    if (updates != null) {
      for (final update in updates) {
        try {
          final updateUrl = update['url'];
          final response = await _dio.get(updateUrl);
          if (response.statusCode == 200) {
            await _applyUpdate(update, response.data);
          }
        } catch (e) {
          print('Error applying update: $e');
        }
      }
    }
    
    await _prefs?.setString(_versionKey, versionData['version']);
  }

  Future<void> _applyUpdate(Map<String, dynamic> update, dynamic data) async {
    final type = update['type'];
    final path = update['path'];
    
    switch (type) {
      case 'replace':
        await _saveDownloadedData(path, data);
        break;
      case 'merge':
        // Merge with existing data
        final existing = await _getDownloadedData(path);
        final merged = _mergeData(existing, data);
        await _saveDownloadedData(path, merged);
        break;
    }
  }

  Future<dynamic> _getDownloadedData(String path) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/data/$path');
      if (await file.exists()) {
        final content = await file.readAsString();
        return json.decode(content);
      }
    } catch (e) {
      print('Error reading data: $e');
    }
    return null;
  }

  dynamic _mergeData(dynamic existing, dynamic update) {
    if (existing is Map && update is Map) {
      final merged = Map<String, dynamic>.from(existing);
      update.forEach((key, value) {
        merged[key] = value;
      });
      return merged;
    }
    return update; // Replace if not maps
  }

  int _calculateDataSize() {
    // Calculate storage used by downloaded data
    // This would need to be implemented to scan the download directory
    return 0; // Placeholder
  }
}

// Data models
class HymnalInfo {
  final String id;
  final String name;
  final String abbreviation;
  final int year;
  final int? totalSongs;
  final String language;
  final String languageName;
  final String compiler;
  final String siteName;
  final String? urlSlug;
  final Map<String, dynamic>? resources;
  final Map<String, dynamic>? music;

  HymnalInfo({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.year,
    this.totalSongs,
    required this.language,
    required this.languageName,
    required this.compiler,
    required this.siteName,
    this.urlSlug,
    this.resources,
    this.music,
  });

  factory HymnalInfo.fromJson(Map<String, dynamic> json) {
    return HymnalInfo(
      id: json['id'],
      name: json['name'],
      abbreviation: json['abbreviation'],
      year: json['year'],
      totalSongs: json['total_songs'],
      language: json['language'],
      languageName: json['language_name'],
      compiler: json['compiler'],
      siteName: json['site_name'],
      urlSlug: json['url_slug'],
      resources: json['resources'],
      music: json['music'],
    );
  }
}

class HymnalCollection {
  final String id;
  final String title;
  final String language;
  final int year;
  final String publisher;
  final List<HymnReference> hymns;

  HymnalCollection({
    required this.id,
    required this.title,
    required this.language,
    required this.year,
    required this.publisher,
    required this.hymns,
  });

  factory HymnalCollection.fromJson(Map<String, dynamic> json) {
    return HymnalCollection(
      id: json['id'],
      title: json['title'],
      language: json['language'],
      year: json['year'],
      publisher: json['publisher'],
      hymns: (json['hymns'] as List)
          .map((e) => HymnReference.fromJson(e))
          .toList(),
    );
  }
}

class HymnReference {
  final int number;
  final String hymnId;
  final String title;

  HymnReference({
    required this.number,
    required this.hymnId,
    required this.title,
  });

  factory HymnReference.fromJson(Map<String, dynamic> json) {
    return HymnReference(
      number: json['number'],
      hymnId: json['hymn_id'],
      title: json['title'],
    );
  }
}