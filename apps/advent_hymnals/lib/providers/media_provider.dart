import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/media_models.dart';
import '../services/api_service.dart';
import '../services/media_download_service.dart';

class MediaProvider extends ChangeNotifier {
  final ApiService _apiService;
  final MediaDownloadService _downloadService;
  
  final Map<String, MediaMetadata> _mediaCache = {};
  final Map<String, DownloadProgress> _downloadProgress = {};
  final Map<String, StreamSubscription> _downloadSubscriptions = {};
  final Map<String, LocalMediaInfo> _localMediaInfo = {};
  
  StorageStats? _storageStats;
  bool _isLoadingStats = false;
  
  MediaProvider({
    required ApiService apiService,
    required MediaDownloadService downloadService,
  }) : _apiService = apiService, 
       _downloadService = downloadService {
    _initializeProvider();
  }
  
  Future<void> _initializeProvider() async {
    await _loadStorageStats();
    await _loadLocalMediaInfo();
  }
  
  // Getters
  MediaMetadata? getHymnMedia(String hymnId) => _mediaCache[hymnId];
  DownloadProgress? getDownloadProgress(String mediaId) => _downloadProgress[mediaId];
  LocalMediaInfo? getLocalMediaInfo(String mediaId) => _localMediaInfo[mediaId];
  StorageStats? get storageStats => _storageStats;
  bool get isLoadingStats => _isLoadingStats;
  
  Map<String, MediaMetadata> get mediaCache => Map.unmodifiable(_mediaCache);
  Map<String, DownloadProgress> get downloadProgress => Map.unmodifiable(_downloadProgress);
  Map<String, LocalMediaInfo> get localMediaInfo => Map.unmodifiable(_localMediaInfo);
  
  List<String> get downloadedMediaIds => _localMediaInfo.keys.toList();
  
  int get downloadQueueLength => _apiService.downloadQueueLength;
  int get activeDownloads => _apiService.activeDownloads;
  
  // Media loading
  Future<void> loadHymnMedia(String hymnId, {bool forceRefresh = false}) async {
    if (_mediaCache.containsKey(hymnId) && !forceRefresh) return;
    
    try {
      final media = await _apiService.getHymnMedia(hymnId);
      _mediaCache[hymnId] = media;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load media for $hymnId: $e');
      }
      rethrow;
    }
  }
  
  Future<List<MediaFile>> getAvailableMedia(String hymnId, MediaType type) async {
    await loadHymnMedia(hymnId);
    final media = _mediaCache[hymnId];
    return media?.getFilesByType(type) ?? [];
  }
  
  // Download management
  Future<void> downloadMedia(String hymnId, MediaFile mediaFile, {int priority = 0}) async {
    if (_downloadSubscriptions.containsKey(mediaFile.id)) {
      return; // Already downloading
    }
    
    _downloadProgress[mediaFile.id] = DownloadProgress.initial(mediaFile.id);
    notifyListeners();
    
    final subscription = _apiService.downloadMedia(
      mediaFile,
      addToQueue: true,
      priority: priority,
    ).listen(
      (progress) {
        _downloadProgress[mediaFile.id] = progress;
        notifyListeners();
        
        if (progress.isCompleted) {
          _onDownloadCompleted(mediaFile.id);
        } else if (progress.isFailed) {
          _onDownloadFailed(mediaFile.id);
        }
      },
      onError: (error) {
        _downloadProgress[mediaFile.id] = DownloadProgress.failed(mediaFile.id, error.toString());
        notifyListeners();
        _onDownloadFailed(mediaFile.id);
      },
      onDone: () {
        _downloadSubscriptions.remove(mediaFile.id);
      },
    );
    
    _downloadSubscriptions[mediaFile.id] = subscription;
  }
  
  void _onDownloadCompleted(String mediaId) {
    _loadLocalMediaInfo(); // Refresh local media info
    _loadStorageStats(); // Refresh storage stats
  }
  
  void _onDownloadFailed(String mediaId) {
    _downloadSubscriptions.remove(mediaId);
  }
  
  Future<void> retryFailedDownload(String mediaId, MediaFile mediaFile) async {
    await _apiService.retryFailedDownload(mediaId, mediaFile);
    await downloadMedia(mediaFile.id, mediaFile);
  }
  
  void pauseDownload(String mediaId) {
    _apiService.pauseDownload(mediaId);
    _downloadSubscriptions[mediaId]?.cancel();
    _downloadSubscriptions.remove(mediaId);
    
    final currentProgress = _downloadProgress[mediaId];
    if (currentProgress != null) {
      _downloadProgress[mediaId] = DownloadProgress(
        mediaId: mediaId,
        progress: currentProgress.progress,
        status: DownloadStatus.paused,
        bytesDownloaded: currentProgress.bytesDownloaded,
        totalBytes: currentProgress.totalBytes,
      );
      notifyListeners();
    }
  }
  
  void cancelDownload(String mediaId) {
    _apiService.cancelDownload(mediaId);
    _downloadSubscriptions[mediaId]?.cancel();
    _downloadSubscriptions.remove(mediaId);
    _downloadProgress.remove(mediaId);
    notifyListeners();
  }
  
  void pauseAllDownloads() {
    _apiService.pauseAllDownloads();
    
    for (final subscription in _downloadSubscriptions.values) {
      subscription.cancel();
    }
    _downloadSubscriptions.clear();
    
    // Update all download progress to paused
    for (final entry in _downloadProgress.entries) {
      if (entry.value.isDownloading) {
        _downloadProgress[entry.key] = DownloadProgress(
          mediaId: entry.key,
          progress: entry.value.progress,
          status: DownloadStatus.paused,
          bytesDownloaded: entry.value.bytesDownloaded,
          totalBytes: entry.value.totalBytes,
        );
      }
    }
    
    notifyListeners();
  }
  
  void clearDownloadQueue() {
    _apiService.clearDownloadQueue();
    notifyListeners();
  }
  
  // Local media management
  Future<void> _loadLocalMediaInfo() async {
    try {
      final mediaIds = await _apiService.getDownloadedMediaIds();
      _localMediaInfo.clear();
      
      for (final mediaId in mediaIds) {
        final info = await _apiService.getLocalMediaInfo(mediaId);
        if (info != null) {
          _localMediaInfo[mediaId] = info;
        }
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load local media info: $e');
      }
    }
  }
  
  Future<bool> isMediaDownloaded(String mediaId) async {
    return await _apiService.isMediaDownloaded(mediaId);
  }
  
  Future<String?> getLocalMediaPath(String mediaId) async {
    return await _apiService.getLocalMediaPath(mediaId);
  }
  
  Future<void> deleteDownloadedMedia(String mediaId) async {
    await _apiService.deleteDownloadedMedia(mediaId);
    _localMediaInfo.remove(mediaId);
    _downloadProgress.remove(mediaId);
    await _loadStorageStats();
    notifyListeners();
  }
  
  Future<void> updateLastAccessed(String mediaId) async {
    await _apiService.updateLastAccessed(mediaId);
    await _loadLocalMediaInfo();
  }
  
  Future<bool> verifyFileIntegrity(String mediaId, String expectedChecksum) async {
    return await _apiService.verifyFileIntegrity(mediaId, expectedChecksum);
  }
  
  // Storage management
  Future<void> _loadStorageStats() async {
    if (_isLoadingStats) return;
    
    _isLoadingStats = true;
    notifyListeners();
    
    try {
      _storageStats = await _apiService.getStorageStats();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load storage stats: $e');
      }
    } finally {
      _isLoadingStats = false;
      notifyListeners();
    }
  }
  
  Future<void> refreshStorageStats() async {
    await _loadStorageStats();
  }
  
  Future<void> cleanupOldFiles({int maxAgeInDays = 30}) async {
    await _apiService.cleanupOldFiles(maxAgeInDays: maxAgeInDays);
    await _loadLocalMediaInfo();
    await _loadStorageStats();
  }
  
  Future<void> clearAllMedia() async {
    await _apiService.clearAllMedia();
    _localMediaInfo.clear();
    _downloadProgress.clear();
    _storageStats = null;
    
    // Cancel all active downloads
    for (final subscription in _downloadSubscriptions.values) {
      subscription.cancel();
    }
    _downloadSubscriptions.clear();
    
    notifyListeners();
  }
  
  Future<void> clearTemporaryFiles() async {
    await _apiService.clearTemporaryFiles();
  }
  
  // Utility methods
  List<MediaFile> getDownloadedMediaFiles(String hymnId) {
    final media = _mediaCache[hymnId];
    if (media == null) return [];
    
    return media.files.where((file) => _localMediaInfo.containsKey(file.id)).toList();
  }
  
  List<MediaFile> getAvailableMediaFiles(String hymnId) {
    final media = _mediaCache[hymnId];
    if (media == null) return [];
    
    return media.files.where((file) => !_localMediaInfo.containsKey(file.id)).toList();
  }
  
  bool isDownloadInProgress(String mediaId) {
    final progress = _downloadProgress[mediaId];
    return progress != null && progress.isDownloading;
  }
  
  bool isDownloadCompleted(String mediaId) {
    final progress = _downloadProgress[mediaId];
    return progress != null && progress.isCompleted;
  }
  
  bool isDownloadFailed(String mediaId) {
    final progress = _downloadProgress[mediaId];
    return progress != null && progress.isFailed;
  }
  
  bool isDownloadPaused(String mediaId) {
    final progress = _downloadProgress[mediaId];
    return progress != null && progress.isPaused;
  }
  
  double getTotalDownloadProgress() {
    if (_downloadProgress.isEmpty) return 0.0;
    
    double totalProgress = 0.0;
    for (final progress in _downloadProgress.values) {
      totalProgress += progress.progress;
    }
    
    return totalProgress / _downloadProgress.length;
  }
  
  int get totalDownloadedFiles => _localMediaInfo.length;
  
  String get formattedTotalSize => _storageStats?.formattedTotalSize ?? '0 B';
  
  // Statistics
  Map<MediaType, int> get downloadedMediaCountByType {
    final counts = <MediaType, int>{};
    
    for (final info in _localMediaInfo.values) {
      final type = _getMediaTypeFromMetadata(info.metadata);
      counts[type] = (counts[type] ?? 0) + 1;
    }
    
    return counts;
  }
  
  MediaType _getMediaTypeFromMetadata(Map<String, dynamic> metadata) {
    final typeString = metadata['type'] as String?;
    if (typeString == null) return MediaType.image;
    
    try {
      return MediaType.values.firstWhere((e) => e.name == typeString);
    } catch (e) {
      return MediaType.image;
    }
  }
  
  @override
  void dispose() {
    for (final subscription in _downloadSubscriptions.values) {
      subscription.cancel();
    }
    _downloadSubscriptions.clear();
    
    _apiService.dispose();
    super.dispose();
  }
}