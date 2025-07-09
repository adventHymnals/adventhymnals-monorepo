import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import '../models/media_models.dart';

class LocalStorageService {
  static const String _mediaStorageKey = 'downloaded_media';
  static const String _mediaMetadataKey = 'media_metadata';
  static const String _downloadQueueKey = 'download_queue';
  static const String _storageStatsKey = 'storage_stats';
  
  static LocalStorageService? _instance;
  SharedPreferences? _prefs;
  
  LocalStorageService._();
  
  static LocalStorageService get instance {
    _instance ??= LocalStorageService._();
    return _instance!;
  }
  
  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
  
  Future<Directory> get _mediaDirectory async {
    final appDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${appDir.path}/media');
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }
    return mediaDir;
  }
  
  Future<Directory> get _tempDirectory async {
    final tempDir = await getTemporaryDirectory();
    final mediaTemp = Directory('${tempDir.path}/media_temp');
    if (!await mediaTemp.exists()) {
      await mediaTemp.create(recursive: true);
    }
    return mediaTemp;
  }
  
  Future<Directory> get _cacheDirectory async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }
  
  Future<String> getTempPath(String filename) async {
    final tempDir = await _tempDirectory;
    return '${tempDir.path}/$filename';
  }
  
  Future<String> getMediaPath(String mediaId) async {
    final mediaDir = await _mediaDirectory;
    return '${mediaDir.path}/$mediaId';
  }
  
  Future<String> getCachePath(String key) async {
    final cacheDir = await _cacheDirectory;
    return '${cacheDir.path}/$key';
  }
  
  Future<String> storeMedia(String mediaId, String tempPath) async {
    final tempFile = File(tempPath);
    if (!await tempFile.exists()) {
      throw Exception('Temporary file does not exist: $tempPath');
    }
    
    final finalPath = await getMediaPath(mediaId);
    final finalFile = File(finalPath);
    
    await tempFile.copy(finalPath);
    await tempFile.delete();
    
    return finalPath;
  }
  
  Future<void> saveMediaMetadata(String mediaId, Map<String, dynamic> metadata) async {
    await _initPrefs();
    
    final allMetadata = await getAllMediaMetadata();
    allMetadata[mediaId] = metadata;
    
    await _prefs!.setString(_mediaMetadataKey, jsonEncode(allMetadata));
    
    await _updateStorageStats();
  }
  
  Future<Map<String, dynamic>> getAllMediaMetadata() async {
    await _initPrefs();
    
    final metadataJson = _prefs!.getString(_mediaMetadataKey);
    if (metadataJson == null) return {};
    
    try {
      return Map<String, dynamic>.from(jsonDecode(metadataJson));
    } catch (e) {
      return {};
    }
  }
  
  Future<Map<String, dynamic>?> getMediaMetadata(String mediaId) async {
    final allMetadata = await getAllMediaMetadata();
    return allMetadata[mediaId];
  }
  
  Future<void> saveLocalMediaInfo(LocalMediaInfo info) async {
    await _initPrefs();
    
    final allInfos = await getAllLocalMediaInfo();
    allInfos[info.mediaId] = info.toJson();
    
    await _prefs!.setString(_mediaStorageKey, jsonEncode(allInfos));
  }
  
  Future<Map<String, dynamic>> getAllLocalMediaInfo() async {
    await _initPrefs();
    
    final infoJson = _prefs!.getString(_mediaStorageKey);
    if (infoJson == null) return {};
    
    try {
      return Map<String, dynamic>.from(jsonDecode(infoJson));
    } catch (e) {
      return {};
    }
  }
  
  Future<LocalMediaInfo?> getLocalMediaInfo(String mediaId) async {
    final allInfos = await getAllLocalMediaInfo();
    final infoJson = allInfos[mediaId];
    
    if (infoJson == null) return null;
    
    try {
      return LocalMediaInfo.fromJson(infoJson);
    } catch (e) {
      return null;
    }
  }
  
  Future<List<String>> getDownloadedMediaIds() async {
    final allInfos = await getAllLocalMediaInfo();
    return allInfos.keys.toList();
  }
  
  Future<bool> isMediaDownloaded(String mediaId) async {
    final info = await getLocalMediaInfo(mediaId);
    if (info == null) return false;
    
    final file = File(info.localPath);
    return await file.exists();
  }
  
  Future<void> deleteMedia(String mediaId) async {
    final info = await getLocalMediaInfo(mediaId);
    if (info != null) {
      final file = File(info.localPath);
      if (await file.exists()) {
        await file.delete();
      }
    }
    
    await _removeFromLocalStorage(mediaId);
    await _removeFromMetadata(mediaId);
    await _updateStorageStats();
  }
  
  Future<void> _removeFromLocalStorage(String mediaId) async {
    await _initPrefs();
    
    final allInfos = await getAllLocalMediaInfo();
    allInfos.remove(mediaId);
    
    await _prefs!.setString(_mediaStorageKey, jsonEncode(allInfos));
  }
  
  Future<void> _removeFromMetadata(String mediaId) async {
    await _initPrefs();
    
    final allMetadata = await getAllMediaMetadata();
    allMetadata.remove(mediaId);
    
    await _prefs!.setString(_mediaMetadataKey, jsonEncode(allMetadata));
  }
  
  Future<String> calculateFileChecksum(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File does not exist: $filePath');
    }
    
    final bytes = await file.readAsBytes();
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  Future<bool> verifyFileIntegrity(String mediaId, String expectedChecksum) async {
    final info = await getLocalMediaInfo(mediaId);
    if (info == null) return false;
    
    try {
      final actualChecksum = await calculateFileChecksum(info.localPath);
      return actualChecksum == expectedChecksum;
    } catch (e) {
      return false;
    }
  }
  
  Future<void> updateLastAccessed(String mediaId) async {
    final info = await getLocalMediaInfo(mediaId);
    if (info != null) {
      final updatedInfo = info.copyWith(lastAccessed: DateTime.now());
      await saveLocalMediaInfo(updatedInfo);
    }
  }
  
  Future<StorageStats> getStorageStats() async {
    await _initPrefs();
    
    final statsJson = _prefs!.getString(_storageStatsKey);
    if (statsJson == null) {
      return await _calculateStorageStats();
    }
    
    try {
      return StorageStats.fromJson(jsonDecode(statsJson));
    } catch (e) {
      return await _calculateStorageStats();
    }
  }
  
  Future<StorageStats> _calculateStorageStats() async {
    final allInfos = await getAllLocalMediaInfo();
    int totalSize = 0;
    int totalFiles = 0;
    final Map<MediaType, int> sizeByType = {};
    final Map<MediaType, int> countByType = {};
    
    for (final infoJson in allInfos.values) {
      try {
        final info = LocalMediaInfo.fromJson(infoJson);
        final file = File(info.localPath);
        
        if (await file.exists()) {
          totalSize += info.size;
          totalFiles++;
          
          final mediaType = _getMediaTypeFromPath(info.localPath);
          sizeByType[mediaType] = (sizeByType[mediaType] ?? 0) + info.size;
          countByType[mediaType] = (countByType[mediaType] ?? 0) + 1;
        }
      } catch (e) {
        // Skip invalid entries
      }
    }
    
    return StorageStats(
      totalSize: totalSize,
      totalFiles: totalFiles,
      sizeByType: sizeByType,
      countByType: countByType,
      lastCalculated: DateTime.now(),
    );
  }
  
  Future<void> _updateStorageStats() async {
    final stats = await _calculateStorageStats();
    await _prefs!.setString(_storageStatsKey, jsonEncode(stats.toJson()));
  }
  
  MediaType _getMediaTypeFromPath(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'mp3':
      case 'wav':
      case 'ogg':
        return MediaType.audio;
      case 'mid':
      case 'midi':
        return MediaType.midi;
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'svg':
        return MediaType.image;
      case 'pdf':
        return MediaType.pdf;
      case 'mp4':
      case 'webm':
        return MediaType.video;
      default:
        return MediaType.image; // Default fallback
    }
  }
  
  Future<void> cleanupOldFiles({int maxAgeInDays = 30}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: maxAgeInDays));
    final allInfos = await getAllLocalMediaInfo();
    
    for (final entry in allInfos.entries) {
      try {
        final info = LocalMediaInfo.fromJson(entry.value);
        final lastAccessed = info.lastAccessed ?? info.downloadDate;
        
        if (lastAccessed.isBefore(cutoffDate)) {
          await deleteMedia(entry.key);
        }
      } catch (e) {
        // Skip invalid entries
      }
    }
  }
  
  Future<void> clearAllCache() async {
    final cacheDir = await _cacheDirectory;
    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
    }
  }
  
  Future<void> clearAllMedia() async {
    final mediaDir = await _mediaDirectory;
    if (await mediaDir.exists()) {
      await mediaDir.delete(recursive: true);
    }
    
    await _initPrefs();
    await _prefs!.remove(_mediaStorageKey);
    await _prefs!.remove(_mediaMetadataKey);
    await _prefs!.remove(_storageStatsKey);
  }
  
  Future<void> clearTemporaryFiles() async {
    final tempDir = await _tempDirectory;
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  }
}

class StorageStats {
  final int totalSize;
  final int totalFiles;
  final Map<MediaType, int> sizeByType;
  final Map<MediaType, int> countByType;
  final DateTime lastCalculated;
  
  StorageStats({
    required this.totalSize,
    required this.totalFiles,
    required this.sizeByType,
    required this.countByType,
    required this.lastCalculated,
  });
  
  factory StorageStats.fromJson(Map<String, dynamic> json) {
    return StorageStats(
      totalSize: json['totalSize'],
      totalFiles: json['totalFiles'],
      sizeByType: Map<MediaType, int>.from(
        json['sizeByType'].map((k, v) => MapEntry(MediaType.values.firstWhere((e) => e.name == k), v)),
      ),
      countByType: Map<MediaType, int>.from(
        json['countByType'].map((k, v) => MapEntry(MediaType.values.firstWhere((e) => e.name == k), v)),
      ),
      lastCalculated: DateTime.parse(json['lastCalculated']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'totalSize': totalSize,
      'totalFiles': totalFiles,
      'sizeByType': sizeByType.map((k, v) => MapEntry(k.name, v)),
      'countByType': countByType.map((k, v) => MapEntry(k.name, v)),
      'lastCalculated': lastCalculated.toIso8601String(),
    };
  }
  
  String get formattedTotalSize {
    if (totalSize < 1024) return '$totalSize B';
    if (totalSize < 1024 * 1024) return '${(totalSize / 1024).toStringAsFixed(1)} KB';
    if (totalSize < 1024 * 1024 * 1024) return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(totalSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}