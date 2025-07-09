import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'local_storage_service.dart';

class CacheService {
  static const String _cacheMetadataKey = 'cache_metadata';
  static const Duration _defaultCacheDuration = Duration(hours: 24);
  
  static CacheService? _instance;
  SharedPreferences? _prefs;
  late final Directory _cacheDir;
  bool _initialized = false;
  
  CacheService._();
  
  static CacheService get instance {
    _instance ??= CacheService._();
    return _instance!;
  }
  
  Future<void> _initialize() async {
    if (_initialized) return;
    
    _prefs = await SharedPreferences.getInstance();
    _cacheDir = await LocalStorageService.instance._cacheDirectory;
    _initialized = true;
  }
  
  Future<void> set<T>(
    String key,
    T value, {
    Duration? duration,
    String? version,
  }) async {
    await _initialize();
    
    try {
      final cacheItem = CacheItem<T>(
        key: key,
        value: value,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(duration ?? _defaultCacheDuration),
        version: version,
      );
      
      // Save to file system for larger objects
      if (_shouldUseFileSystem<T>(value)) {
        await _saveToFile(key, cacheItem);
      } else {
        // Save to shared preferences for smaller objects
        await _saveToPrefs(key, cacheItem);
      }
      
      // Update metadata
      await _updateCacheMetadata(key, cacheItem);
      
      if (kDebugMode) {
        print('[CacheService] Cached "$key" until ${cacheItem.expiresAt}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[CacheService] Failed to cache "$key": $e');
      }
    }
  }
  
  Future<T?> get<T>(
    String key, {
    String? version,
  }) async {
    await _initialize();
    
    try {
      final metadata = await _getCacheMetadata(key);
      if (metadata == null) return null;
      
      // Check if expired
      if (metadata.expiresAt.isBefore(DateTime.now())) {
        await remove(key);
        return null;
      }
      
      // Check version if specified
      if (version != null && metadata.version != version) {
        await remove(key);
        return null;
      }
      
      CacheItem<T>? cacheItem;
      
      // Load from appropriate storage
      if (metadata.isFileSystem) {
        cacheItem = await _loadFromFile<T>(key);
      } else {
        cacheItem = await _loadFromPrefs<T>(key);
      }
      
      if (cacheItem == null) {
        // Remove stale metadata
        await _removeCacheMetadata(key);
        return null;
      }
      
      // Update access time
      await _updateAccessTime(key);
      
      if (kDebugMode) {
        print('[CacheService] Retrieved "$key" from cache');
      }
      
      return cacheItem.value;
    } catch (e) {
      if (kDebugMode) {
        print('[CacheService] Failed to get "$key": $e');
      }
      return null;
    }
  }
  
  Future<bool> has(String key) async {
    await _initialize();
    
    final metadata = await _getCacheMetadata(key);
    if (metadata == null) return false;
    
    if (metadata.expiresAt.isBefore(DateTime.now())) {
      await remove(key);
      return false;
    }
    
    return true;
  }
  
  Future<void> remove(String key) async {
    await _initialize();
    
    try {
      final metadata = await _getCacheMetadata(key);
      if (metadata == null) return;
      
      // Remove from appropriate storage
      if (metadata.isFileSystem) {
        await _removeFromFile(key);
      } else {
        await _removeFromPrefs(key);
      }
      
      // Remove metadata
      await _removeCacheMetadata(key);
      
      if (kDebugMode) {
        print('[CacheService] Removed "$key" from cache');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[CacheService] Failed to remove "$key": $e');
      }
    }
  }
  
  Future<void> clear() async {
    await _initialize();
    
    try {
      // Clear all cache files
      if (await _cacheDir.exists()) {
        await _cacheDir.delete(recursive: true);
      }
      
      // Clear cache metadata
      await _prefs!.remove(_cacheMetadataKey);
      
      if (kDebugMode) {
        print('[CacheService] Cleared all cache');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[CacheService] Failed to clear cache: $e');
      }
    }
  }
  
  Future<void> cleanupExpired() async {
    await _initialize();
    
    try {
      final allMetadata = await _getAllCacheMetadata();
      final now = DateTime.now();
      int removedCount = 0;
      
      for (final entry in allMetadata.entries) {
        if (entry.value.expiresAt.isBefore(now)) {
          await remove(entry.key);
          removedCount++;
        }
      }
      
      if (kDebugMode) {
        print('[CacheService] Removed $removedCount expired cache items');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[CacheService] Failed to cleanup expired cache: $e');
      }
    }
  }
  
  Future<void> cleanupOldest(int maxItems) async {
    await _initialize();
    
    try {
      final allMetadata = await _getAllCacheMetadata();
      
      if (allMetadata.length <= maxItems) return;
      
      // Sort by last access time (oldest first)
      final sortedEntries = allMetadata.entries.toList()
        ..sort((a, b) => a.value.lastAccessedAt.compareTo(b.value.lastAccessedAt));
      
      final itemsToRemove = sortedEntries.take(allMetadata.length - maxItems);
      
      for (final entry in itemsToRemove) {
        await remove(entry.key);
      }
      
      if (kDebugMode) {
        print('[CacheService] Removed ${itemsToRemove.length} oldest cache items');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[CacheService] Failed to cleanup oldest cache: $e');
      }
    }
  }
  
  Future<CacheStats> getStats() async {
    await _initialize();
    
    try {
      final allMetadata = await _getAllCacheMetadata();
      final now = DateTime.now();
      
      int validItems = 0;
      int expiredItems = 0;
      int totalSize = 0;
      int oldestAccess = 0;
      int newestAccess = 0;
      
      for (final metadata in allMetadata.values) {
        if (metadata.expiresAt.isBefore(now)) {
          expiredItems++;
        } else {
          validItems++;
        }
        
        totalSize += metadata.size;
        
        final accessTime = metadata.lastAccessedAt.millisecondsSinceEpoch;
        if (oldestAccess == 0 || accessTime < oldestAccess) {
          oldestAccess = accessTime;
        }
        if (newestAccess == 0 || accessTime > newestAccess) {
          newestAccess = accessTime;
        }
      }
      
      return CacheStats(
        totalItems: allMetadata.length,
        validItems: validItems,
        expiredItems: expiredItems,
        totalSize: totalSize,
        oldestAccess: oldestAccess > 0 ? DateTime.fromMillisecondsSinceEpoch(oldestAccess) : null,
        newestAccess: newestAccess > 0 ? DateTime.fromMillisecondsSinceEpoch(newestAccess) : null,
      );
    } catch (e) {
      if (kDebugMode) {
        print('[CacheService] Failed to get cache stats: $e');
      }
      return CacheStats(
        totalItems: 0,
        validItems: 0,
        expiredItems: 0,
        totalSize: 0,
      );
    }
  }
  
  // Private methods
  
  bool _shouldUseFileSystem<T>(T value) {
    if (value is String) {
      return value.length > 1000; // Use file system for strings longer than 1KB
    }
    if (value is List || value is Map) {
      return jsonEncode(value).length > 1000; // Use file system for large objects
    }
    return false;
  }
  
  Future<void> _saveToFile<T>(String key, CacheItem<T> cacheItem) async {
    final file = File('${_cacheDir.path}/$key.cache');
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(cacheItem.toJson()));
  }
  
  Future<void> _saveToPrefs<T>(String key, CacheItem<T> cacheItem) async {
    await _prefs!.setString('cache_$key', jsonEncode(cacheItem.toJson()));
  }
  
  Future<CacheItem<T>?> _loadFromFile<T>(String key) async {
    try {
      final file = File('${_cacheDir.path}/$key.cache');
      if (!await file.exists()) return null;
      
      final content = await file.readAsString();
      final json = jsonDecode(content);
      return CacheItem<T>.fromJson(json);
    } catch (e) {
      if (kDebugMode) {
        print('[CacheService] Failed to load "$key" from file: $e');
      }
      return null;
    }
  }
  
  Future<CacheItem<T>?> _loadFromPrefs<T>(String key) async {
    try {
      final content = _prefs!.getString('cache_$key');
      if (content == null) return null;
      
      final json = jsonDecode(content);
      return CacheItem<T>.fromJson(json);
    } catch (e) {
      if (kDebugMode) {
        print('[CacheService] Failed to load "$key" from prefs: $e');
      }
      return null;
    }
  }
  
  Future<void> _removeFromFile(String key) async {
    final file = File('${_cacheDir.path}/$key.cache');
    if (await file.exists()) {
      await file.delete();
    }
  }
  
  Future<void> _removeFromPrefs(String key) async {
    await _prefs!.remove('cache_$key');
  }
  
  Future<void> _updateCacheMetadata(String key, CacheItem cacheItem) async {
    final allMetadata = await _getAllCacheMetadata();
    
    final size = await _calculateItemSize(key, cacheItem);
    
    allMetadata[key] = CacheMetadata(
      key: key,
      createdAt: cacheItem.createdAt,
      expiresAt: cacheItem.expiresAt,
      lastAccessedAt: DateTime.now(),
      size: size,
      version: cacheItem.version,
      isFileSystem: _shouldUseFileSystem(cacheItem.value),
    );
    
    await _prefs!.setString(_cacheMetadataKey, jsonEncode(
      allMetadata.map((k, v) => MapEntry(k, v.toJson())),
    ));
  }
  
  Future<CacheMetadata?> _getCacheMetadata(String key) async {
    final allMetadata = await _getAllCacheMetadata();
    return allMetadata[key];
  }
  
  Future<Map<String, CacheMetadata>> _getAllCacheMetadata() async {
    try {
      final metadataJson = _prefs!.getString(_cacheMetadataKey);
      if (metadataJson == null) return {};
      
      final decoded = jsonDecode(metadataJson) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, CacheMetadata.fromJson(v)));
    } catch (e) {
      if (kDebugMode) {
        print('[CacheService] Failed to get cache metadata: $e');
      }
      return {};
    }
  }
  
  Future<void> _removeCacheMetadata(String key) async {
    final allMetadata = await _getAllCacheMetadata();
    allMetadata.remove(key);
    
    await _prefs!.setString(_cacheMetadataKey, jsonEncode(
      allMetadata.map((k, v) => MapEntry(k, v.toJson())),
    ));
  }
  
  Future<void> _updateAccessTime(String key) async {
    final allMetadata = await _getAllCacheMetadata();
    final metadata = allMetadata[key];
    
    if (metadata != null) {
      allMetadata[key] = metadata.copyWith(lastAccessedAt: DateTime.now());
      
      await _prefs!.setString(_cacheMetadataKey, jsonEncode(
        allMetadata.map((k, v) => MapEntry(k, v.toJson())),
      ));
    }
  }
  
  Future<int> _calculateItemSize(String key, CacheItem cacheItem) async {
    try {
      final json = jsonEncode(cacheItem.toJson());
      return json.length;
    } catch (e) {
      return 0;
    }
  }
}

class CacheItem<T> {
  final String key;
  final T value;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String? version;
  
  CacheItem({
    required this.key,
    required this.value,
    required this.createdAt,
    required this.expiresAt,
    this.version,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'version': version,
    };
  }
  
  factory CacheItem.fromJson(Map<String, dynamic> json) {
    return CacheItem<T>(
      key: json['key'],
      value: json['value'] as T,
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
      version: json['version'],
    );
  }
}

class CacheMetadata {
  final String key;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime lastAccessedAt;
  final int size;
  final String? version;
  final bool isFileSystem;
  
  CacheMetadata({
    required this.key,
    required this.createdAt,
    required this.expiresAt,
    required this.lastAccessedAt,
    required this.size,
    this.version,
    required this.isFileSystem,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'lastAccessedAt': lastAccessedAt.toIso8601String(),
      'size': size,
      'version': version,
      'isFileSystem': isFileSystem,
    };
  }
  
  factory CacheMetadata.fromJson(Map<String, dynamic> json) {
    return CacheMetadata(
      key: json['key'],
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
      lastAccessedAt: DateTime.parse(json['lastAccessedAt']),
      size: json['size'],
      version: json['version'],
      isFileSystem: json['isFileSystem'] ?? false,
    );
  }
  
  CacheMetadata copyWith({
    String? key,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? lastAccessedAt,
    int? size,
    String? version,
    bool? isFileSystem,
  }) {
    return CacheMetadata(
      key: key ?? this.key,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      size: size ?? this.size,
      version: version ?? this.version,
      isFileSystem: isFileSystem ?? this.isFileSystem,
    );
  }
}

class CacheStats {
  final int totalItems;
  final int validItems;
  final int expiredItems;
  final int totalSize;
  final DateTime? oldestAccess;
  final DateTime? newestAccess;
  
  CacheStats({
    required this.totalItems,
    required this.validItems,
    required this.expiredItems,
    required this.totalSize,
    this.oldestAccess,
    this.newestAccess,
  });
  
  String get formattedTotalSize {
    if (totalSize < 1024) return '$totalSize B';
    if (totalSize < 1024 * 1024) return '${(totalSize / 1024).toStringAsFixed(1)} KB';
    if (totalSize < 1024 * 1024 * 1024) return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(totalSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  double get hitRate {
    if (totalItems == 0) return 0.0;
    return validItems / totalItems;
  }
}