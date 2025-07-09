import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/media_models.dart';
import 'local_storage_service.dart';

class MediaDownloadService {
  final Dio _dio;
  final LocalStorageService _localStorage;
  final Map<String, StreamController<DownloadProgress>> _progressControllers = {};
  final Map<String, CancelToken> _cancelTokens = {};
  final Queue<DownloadTask> _downloadQueue = Queue<DownloadTask>();
  bool _isProcessingQueue = false;
  static const int _maxConcurrentDownloads = 3;
  int _activeDownloads = 0;
  
  MediaDownloadService({LocalStorageService? localStorage}) 
    : _dio = Dio(BaseOptions(
        baseUrl: ApiConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(minutes: 5),
      )),
      _localStorage = localStorage ?? LocalStorageService.instance {
    
    _dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
      logPrint: (obj) {
        if (kDebugMode) {
          print('[MediaDownloadService] $obj');
        }
      },
    ));
  }
  
  Future<MediaMetadata> getHymnMedia(String hymnId) async {
    try {
      final response = await _dio.get(ApiConfig.getApiUrl('/hymns/$hymnId/media'));
      return MediaMetadata.fromJson(response.data);
    } on DioException catch (e) {
      throw MediaDownloadException._fromDioException(e);
    }
  }
  
  Future<List<MediaFile>> getAvailableMedia(String hymnId, MediaType type) async {
    final media = await getHymnMedia(hymnId);
    return media.getFilesByType(type);
  }
  
  Stream<DownloadProgress> downloadMedia(MediaFile mediaFile, {
    bool addToQueue = true,
    int priority = 0,
  }) {
    final controller = StreamController<DownloadProgress>.broadcast();
    _progressControllers[mediaFile.id] = controller;
    
    if (addToQueue) {
      _addToDownloadQueue(DownloadTask(
        mediaFile: mediaFile,
        controller: controller,
        priority: priority,
      ));
    } else {
      _downloadMediaInternal(mediaFile, controller);
    }
    
    return controller.stream;
  }
  
  void _addToDownloadQueue(DownloadTask task) {
    _downloadQueue.add(task);
    _downloadQueue.sort((a, b) => b.priority.compareTo(a.priority));
    
    if (!_isProcessingQueue) {
      _processDownloadQueue();
    }
  }
  
  Future<void> _processDownloadQueue() async {
    if (_isProcessingQueue) return;
    
    _isProcessingQueue = true;
    
    while (_downloadQueue.isNotEmpty && _activeDownloads < _maxConcurrentDownloads) {
      final task = _downloadQueue.removeFirst();
      _activeDownloads++;
      
      _downloadMediaInternal(task.mediaFile, task.controller).then((_) {
        _activeDownloads--;
        if (_downloadQueue.isNotEmpty) {
          _processDownloadQueue();
        }
      });
    }
    
    if (_downloadQueue.isEmpty && _activeDownloads == 0) {
      _isProcessingQueue = false;
    }
  }
  
  Future<void> _downloadMediaInternal(MediaFile mediaFile, StreamController<DownloadProgress> controller) async {
    final cancelToken = CancelToken();
    _cancelTokens[mediaFile.id] = cancelToken;
    
    try {
      final alreadyDownloaded = await isMediaDownloaded(mediaFile.id);
      if (alreadyDownloaded) {
        final progress = DownloadProgress.completed(mediaFile.id, mediaFile.size);
        controller.add(progress);
        controller.close();
        return;
      }
      
      controller.add(DownloadProgress.initial(mediaFile.id));
      
      final tempPath = await _localStorage.getTempPath(mediaFile.filename);
      final tempFile = File(tempPath);
      
      // Ensure temp directory exists
      await tempFile.parent.create(recursive: true);
      
      final startTime = DateTime.now();
      int lastBytesReceived = 0;
      DateTime lastUpdateTime = startTime;
      
      final response = await _dio.download(
        mediaFile.url,
        tempPath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          final now = DateTime.now();
          final timeDiff = now.difference(lastUpdateTime).inMilliseconds;
          
          // Update progress at most every 100ms
          if (timeDiff >= 100 || received == total) {
            double? speed;
            if (timeDiff > 0) {
              final bytesDiff = received - lastBytesReceived;
              speed = (bytesDiff / timeDiff) * 1000; // bytes per second
            }
            
            final progress = DownloadProgress.downloading(
              mediaFile.id,
              received,
              total > 0 ? total : mediaFile.size,
              speed: speed,
            );
            
            controller.add(progress);
            
            lastBytesReceived = received;
            lastUpdateTime = now;
          }
        },
      );
      
      if (response.statusCode == 200) {
        // Verify file integrity if checksum is available
        if (mediaFile.checksum != null) {
          final actualChecksum = await _localStorage.calculateFileChecksum(tempPath);
          if (actualChecksum != mediaFile.checksum) {
            throw MediaDownloadException('File integrity check failed');
          }
        }
        
        // Move to permanent location
        final finalPath = await _localStorage.storeMedia(mediaFile.id, tempPath);
        
        // Save local media info
        final localInfo = LocalMediaInfo(
          mediaId: mediaFile.id,
          localPath: finalPath,
          downloadDate: DateTime.now(),
          size: mediaFile.size,
          checksum: mediaFile.checksum ?? await _localStorage.calculateFileChecksum(finalPath),
          metadata: {
            'filename': mediaFile.filename,
            'type': mediaFile.type.name,
            'format': mediaFile.format.name,
            'url': mediaFile.url,
            'description': mediaFile.description,
            'duration': mediaFile.duration,
          },
        );
        
        await _localStorage.saveLocalMediaInfo(localInfo);
        
        final progress = DownloadProgress.completed(mediaFile.id, mediaFile.size);
        controller.add(progress);
      } else {
        throw MediaDownloadException('Download failed with status: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        // Download was cancelled
        controller.add(DownloadProgress(
          mediaId: mediaFile.id,
          progress: 0.0,
          status: DownloadStatus.paused,
          bytesDownloaded: 0,
          totalBytes: mediaFile.size,
        ));
      } else {
        final progress = DownloadProgress.failed(mediaFile.id, e.toString());
        controller.add(progress);
      }
    } finally {
      _cancelTokens.remove(mediaFile.id);
      _progressControllers.remove(mediaFile.id);
      controller.close();
    }
  }
  
  Future<bool> isMediaDownloaded(String mediaId) async {
    return await _localStorage.isMediaDownloaded(mediaId);
  }
  
  Future<LocalMediaInfo?> getLocalMediaInfo(String mediaId) async {
    return await _localStorage.getLocalMediaInfo(mediaId);
  }
  
  Future<String?> getLocalMediaPath(String mediaId) async {
    final info = await getLocalMediaInfo(mediaId);
    return info?.localPath;
  }
  
  Future<void> deleteDownloadedMedia(String mediaId) async {
    await _localStorage.deleteMedia(mediaId);
  }
  
  Future<List<String>> getDownloadedMediaIds() async {
    return await _localStorage.getDownloadedMediaIds();
  }
  
  Future<StorageStats> getStorageStats() async {
    return await _localStorage.getStorageStats();
  }
  
  void pauseDownload(String mediaId) {
    final cancelToken = _cancelTokens[mediaId];
    if (cancelToken != null) {
      cancelToken.cancel('Download paused by user');
    }
  }
  
  void cancelDownload(String mediaId) {
    final cancelToken = _cancelTokens[mediaId];
    if (cancelToken != null) {
      cancelToken.cancel('Download cancelled by user');
    }
    
    // Remove from queue if not started
    _downloadQueue.removeWhere((task) => task.mediaFile.id == mediaId);
  }
  
  void pauseAllDownloads() {
    for (final cancelToken in _cancelTokens.values) {
      cancelToken.cancel('All downloads paused by user');
    }
  }
  
  void clearDownloadQueue() {
    _downloadQueue.clear();
  }
  
  int get queueLength => _downloadQueue.length;
  int get activeDownloads => _activeDownloads;
  
  List<DownloadTask> get downloadQueue => List.unmodifiable(_downloadQueue._items);
  
  Future<void> retryFailedDownload(String mediaId, MediaFile mediaFile) async {
    final controller = StreamController<DownloadProgress>.broadcast();
    _progressControllers[mediaId] = controller;
    
    await _downloadMediaInternal(mediaFile, controller);
  }
  
  Future<void> updateLastAccessed(String mediaId) async {
    await _localStorage.updateLastAccessed(mediaId);
  }
  
  Future<bool> verifyFileIntegrity(String mediaId, String expectedChecksum) async {
    return await _localStorage.verifyFileIntegrity(mediaId, expectedChecksum);
  }
  
  Future<void> cleanupOldFiles({int maxAgeInDays = 30}) async {
    await _localStorage.cleanupOldFiles(maxAgeInDays: maxAgeInDays);
  }
  
  Future<void> clearAllMedia() async {
    pauseAllDownloads();
    clearDownloadQueue();
    await _localStorage.clearAllMedia();
  }
  
  Future<void> clearTemporaryFiles() async {
    await _localStorage.clearTemporaryFiles();
  }
  
  void dispose() {
    for (final controller in _progressControllers.values) {
      controller.close();
    }
    _progressControllers.clear();
    
    for (final cancelToken in _cancelTokens.values) {
      cancelToken.cancel();
    }
    _cancelTokens.clear();
    
    _downloadQueue.clear();
  }
}

class DownloadTask {
  final MediaFile mediaFile;
  final StreamController<DownloadProgress> controller;
  final int priority;
  final DateTime createdAt;
  
  DownloadTask({
    required this.mediaFile,
    required this.controller,
    this.priority = 0,
  }) : createdAt = DateTime.now();
}

class Queue<T> {
  final List<T> _items = [];
  
  void add(T item) => _items.add(item);
  T removeFirst() => _items.removeAt(0);
  bool get isNotEmpty => _items.isNotEmpty;
  bool get isEmpty => _items.isEmpty;
  int get length => _items.length;
  void clear() => _items.clear();
  void removeWhere(bool Function(T) test) => _items.removeWhere(test);
  void sort(int Function(T, T) compare) => _items.sort(compare);
}

class MediaDownloadException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;
  
  MediaDownloadException(this.message, {this.statusCode, this.code});
  
  factory MediaDownloadException._fromDioException(DioException dioException) {
    String message;
    int? statusCode;
    String? code;
    
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Send timeout. Please try again.';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Receive timeout. Please try again.';
        break;
      case DioExceptionType.badResponse:
        statusCode = dioException.response?.statusCode;
        if (statusCode == 404) {
          message = 'Media file not found.';
        } else if (statusCode == 500) {
          message = 'Server error. Please try again later.';
        } else {
          message = 'HTTP ${statusCode}: ${dioException.response?.statusMessage ?? 'Unknown error'}';
        }
        break;
      case DioExceptionType.cancel:
        message = 'Download was cancelled.';
        break;
      case DioExceptionType.connectionError:
        message = 'Connection error. Please check your internet connection.';
        break;
      case DioExceptionType.badCertificate:
        message = 'Bad certificate. Connection is not secure.';
        break;
      case DioExceptionType.unknown:
      default:
        message = 'An unexpected error occurred: ${dioException.message}';
        break;
    }
    
    return MediaDownloadException(message, statusCode: statusCode, code: code);
  }
  
  @override
  String toString() {
    return 'MediaDownloadException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
  }
}