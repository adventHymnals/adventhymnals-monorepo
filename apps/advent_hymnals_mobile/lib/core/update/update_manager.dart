import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

class UpdateManager {
  static const String _currentVersionKey = 'data_version';
  static const String _lastCheckKey = 'last_update_check';
  static const String _updateServerUrl = '${AppConstants.apiBaseUrl}/updates';
  
  final Dio _dio = Dio();
  SharedPreferences? _prefs;
  
  // Singleton pattern
  static final UpdateManager _instance = UpdateManager._internal();
  factory UpdateManager() => _instance;
  UpdateManager._internal();

  /// Initialize the update manager
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Check if updates are available
  Future<UpdateCheckResult> checkForUpdates({bool force = false}) async {
    try {
      final lastCheck = _prefs?.getInt(_lastCheckKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // Check at most once per day unless forced
      if (!force && (now - lastCheck) < (24 * 60 * 60 * 1000)) {
        return UpdateCheckResult(
          hasUpdates: false,
          message: 'Already checked today',
        );
      }
      
      final currentVersion = await _getCurrentDataVersion();
      final response = await _dio.get('$_updateServerUrl/version');
      
      if (response.statusCode == 200) {
        final serverData = response.data;
        final serverVersion = serverData['data_version'] as String;
        final minAppVersion = serverData['app_min_version'] as String;
        
        // Check if app version is compatible
        if (!_isAppVersionCompatible(minAppVersion)) {
          return UpdateCheckResult(
            hasUpdates: false,
            requiresAppUpdate: true,
            message: 'App update required',
          );
        }
        
        // Check if data update is available
        if (_isVersionNewer(serverVersion, currentVersion)) {
          final updates = await _getAvailableUpdates(currentVersion, serverVersion);
          
          await _prefs?.setInt(_lastCheckKey, now);
          
          return UpdateCheckResult(
            hasUpdates: true,
            updates: updates,
            newVersion: serverVersion,
            message: 'Updates available',
          );
        }
        
        await _prefs?.setInt(_lastCheckKey, now);
        return UpdateCheckResult(
          hasUpdates: false,
          message: 'Data is up to date',
        );
      }
      
      return UpdateCheckResult(
        hasUpdates: false,
        message: 'Failed to check for updates',
        error: 'Failed to check for updates',
      );
      
    } catch (e) {
      print('Error checking for updates: $e');
      return UpdateCheckResult(
        hasUpdates: false,
        message: 'Error checking for updates',
        error: e.toString(),
      );
    }
  }

  /// Download and apply available updates
  Future<UpdateResult> downloadUpdates(List<DataUpdate> updates, {
    Function(double)? onProgress,
  }) async {
    try {
      final tempDir = await _getTempUpdateDirectory();
      final downloadedFiles = <String>[];
      final deletedCollections = <String>[];
      final addedCollections = <String>[];
      
      double totalProgress = 0.0;
      
      for (int i = 0; i < updates.length; i++) {
        final update = updates[i];
        
        try {
          if (update.action == 'delete') {
            // Handle collection deletion
            await _deleteCollectionData(update.collection);
            deletedCollections.add(update.collection);
          } else {
            // Handle normal download (add/update)
            await _downloadUpdate(update, tempDir);
            downloadedFiles.add(update.filePath);
            
            if (update.action == 'add' && update.filePath.contains('collections/')) {
              addedCollections.add(update.collection);
            }
          }
          
          totalProgress = (i + 1) / updates.length;
          onProgress?.call(totalProgress);
          
        } catch (e) {
          print('Failed to process update ${update.id}: $e');
          // Continue with other updates
        }
      }
      
      // Apply all downloaded updates atomically
      if (downloadedFiles.isNotEmpty || deletedCollections.isNotEmpty) {
        if (downloadedFiles.isNotEmpty) {
          await _applyUpdates(downloadedFiles, tempDir);
        }
        await _updateDataVersion(updates.first.toVersion);
        
        // Cleanup temp files
        await _cleanupTempDirectory(tempDir);
        
        // Generate user-friendly summary
        String summary = 'Updates applied successfully';
        if (addedCollections.isNotEmpty) {
          summary += '\n• Added ${addedCollections.length} new collection(s): ${addedCollections.join(', ')}';
        }
        if (deletedCollections.isNotEmpty) {
          summary += '\n• Removed ${deletedCollections.length} collection(s): ${deletedCollections.join(', ')}';
        }
        
        return UpdateResult(
          success: true,
          appliedUpdates: downloadedFiles.length + deletedCollections.length,
          message: summary,
        );
      }
      
      return UpdateResult(
        success: false,
        message: 'No updates could be downloaded',
      );
      
    } catch (e) {
      print('Error downloading updates: $e');
      return UpdateResult(
        success: false,
        message: 'Error downloading updates',
        error: e.toString(),
      );
    }
  }

  /// Delete collection data when collection is removed
  Future<void> _deleteCollectionData(String collectionId) async {
    try {
      final dataDir = await _getOptimalDataDirectory();
      final collectionFile = File('${dataDir.path}/hymnal_data/collections/${collectionId}-collection.json');
      
      if (await collectionFile.exists()) {
        await collectionFile.delete();
        print('Deleted collection data for $collectionId');
      }
      
      // Also delete any cached hymns for this collection
      final hymnsDir = Directory('${dataDir.path}/hymnal_data/hymns/$collectionId');
      if (await hymnsDir.exists()) {
        await hymnsDir.delete(recursive: true);
        print('Deleted hymn data for collection $collectionId');
      }
    } catch (e) {
      print('Error deleting collection data for $collectionId: $e');
    }
  }

  /// Get data with fallback to bundled assets
  Future<String?> getDataWithFallback(String assetPath) async {
    try {
      // First try to load from downloaded/cached data
      final dataDir = await _getOptimalDataDirectory();
      final cachedFile = File('${dataDir.path}/hymnal_data/$assetPath');
      
      if (await cachedFile.exists()) {
        return await cachedFile.readAsString();
      }
      
      // Fallback to bundled assets
      try {
        return await rootBundle.loadString('assets/data/$assetPath');
      } catch (e) {
        print('Asset not found: assets/data/$assetPath');
        return null;
      }
      
    } catch (e) {
      print('Error loading data: $e');
      return null;
    }
  }

  /// Check if cached data exists for a path
  Future<bool> hasCachedData(String path) async {
    try {
      final dataDir = await _getOptimalDataDirectory();
      final cachedFile = File('${dataDir.path}/hymnal_data/$path');
      return await cachedFile.exists();
    } catch (e) {
      return false;
    }
  }

  /// Get current data version
  Future<String> _getCurrentDataVersion() async {
    // Try to get from preferences first
    final savedVersion = _prefs?.getString(_currentVersionKey);
    if (savedVersion != null) {
      return savedVersion;
    }
    
    // Fallback to bundled app config
    try {
      final configData = await rootBundle.loadString('assets/data/app-config.json');
      final config = json.decode(configData);
      return config['data_version'] ?? '1.0.0';
    } catch (e) {
      return '1.0.0'; // Default version
    }
  }

  /// Get available updates between versions
  Future<List<DataUpdate>> _getAvailableUpdates(String fromVersion, String toVersion) async {
    try {
      final response = await _dio.get('$_updateServerUrl/updates/$fromVersion');
      
      if (response.statusCode == 200) {
        final updatesData = response.data['updates'] as List<dynamic>;
        return updatesData.map((data) => DataUpdate.fromJson(data)).toList();
      }
      
      return [];
    } catch (e) {
      print('Error fetching updates: $e');
      return [];
    }
  }

  /// Download a single update
  Future<void> _downloadUpdate(DataUpdate update, Directory tempDir) async {
    final response = await _dio.get(
      update.fileUrl,
      options: Options(responseType: ResponseType.bytes),
    );
    
    if (response.statusCode == 200) {
      final file = File('${tempDir.path}/${update.fileName}');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(response.data);
    } else {
      throw Exception('Failed to download ${update.fileUrl}');
    }
  }

  /// Apply downloaded updates
  Future<void> _applyUpdates(List<String> updateFiles, Directory tempDir) async {
    final baseDir = await _getOptimalDataDirectory();
    final dataDir = Directory('${baseDir.path}/hymnal_data');
    
    for (final fileName in updateFiles) {
      final tempFile = File('${tempDir.path}/$fileName');
      final targetPath = '${dataDir.path}/$fileName';
      
      // Ensure target directory exists
      final targetFile = File(targetPath);
      await targetFile.parent.create(recursive: true);
      
      // Move file from temp to final location
      await tempFile.copy(targetPath);
    }
  }

  /// Get the optimal data directory based on platform best practices
  Future<Directory> _getOptimalDataDirectory() async {
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

  /// Helper methods
  Future<Directory> _getTempUpdateDirectory() async {
    final tempDir = await getTemporaryDirectory();
    final updateTempDir = Directory('${tempDir.path}/hymnal_updates');
    await updateTempDir.create(recursive: true);
    return updateTempDir;
  }

  Future<void> _cleanupTempDirectory(Directory tempDir) async {
    try {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    } catch (e) {
      print('Error cleaning up temp directory: $e');
    }
  }

  Future<void> _updateDataVersion(String newVersion) async {
    await _prefs?.setString(_currentVersionKey, newVersion);
  }

  bool _isVersionNewer(String remote, String local) {
    // Simple version comparison - you might want to use a package like version
    final remoteParts = remote.split('.').map(int.tryParse).where((v) => v != null).cast<int>().toList();
    final localParts = local.split('.').map(int.tryParse).where((v) => v != null).cast<int>().toList();
    
    for (int i = 0; i < 3; i++) {
      final remoteVersion = i < remoteParts.length ? remoteParts[i] : 0;
      final localVersion = i < localParts.length ? localParts[i] : 0;
      
      if (remoteVersion > localVersion) return true;
      if (remoteVersion < localVersion) return false;
    }
    return false;
  }

  bool _isAppVersionCompatible(String minVersion) {
    // Check if current app version meets minimum requirement
    // For now, assume compatible
    return true;
  }
}

// Data models
class UpdateCheckResult {
  final bool hasUpdates;
  final bool requiresAppUpdate;
  final List<DataUpdate> updates;
  final String? newVersion;
  final String message;
  final String? error;

  UpdateCheckResult({
    required this.hasUpdates,
    this.requiresAppUpdate = false,
    this.updates = const [],
    this.newVersion,
    required this.message,
    this.error,
  });
}

class UpdateResult {
  final bool success;
  final int appliedUpdates;
  final String message;
  final String? error;

  UpdateResult({
    required this.success,
    this.appliedUpdates = 0,
    required this.message,
    this.error,
  });
}

class DataUpdate {
  final String id;
  final String action; // 'add', 'update', 'delete'
  final String collection;
  final String? hymnId;
  final String fileUrl;
  final String filePath;
  final String fromVersion;
  final String toVersion;
  final int? fileSizeBytes;

  DataUpdate({
    required this.id,
    required this.action,
    required this.collection,
    this.hymnId,
    required this.fileUrl,
    required this.filePath,
    required this.fromVersion,
    required this.toVersion,
    this.fileSizeBytes,
  });

  factory DataUpdate.fromJson(Map<String, dynamic> json) {
    return DataUpdate(
      id: json['id'] ?? '',
      action: json['action'] ?? 'update',
      collection: json['collection'] ?? '',
      hymnId: json['hymn_id'],
      fileUrl: json['file_url'] ?? '',
      filePath: json['file_path'] ?? json['file_url']?.split('/').last ?? '',
      fromVersion: json['from_version'] ?? '',
      toVersion: json['to_version'] ?? '',
      fileSizeBytes: json['file_size_bytes'],
    );
  }

  String get fileName => filePath.split('/').last;
}