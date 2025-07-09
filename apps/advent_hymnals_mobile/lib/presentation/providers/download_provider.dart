import 'package:flutter/foundation.dart';
import '../../core/database/database_helper.dart';
import '../../core/constants/app_constants.dart';

enum DownloadState {
  idle,
  downloading,
  completed,
  failed,
  paused,
}

enum DownloadLoadingState {
  initial,
  loading,
  loaded,
  error,
}

class DownloadItem {
  final int hymnId;
  final String hymnTitle;
  final String fileType;
  final String? quality;
  final DownloadState state;
  final double progress;
  final String? errorMessage;
  final DateTime? startTime;
  final DateTime? completedTime;
  final int? fileSize;
  final String? filePath;

  const DownloadItem({
    required this.hymnId,
    required this.hymnTitle,
    required this.fileType,
    this.quality,
    this.state = DownloadState.idle,
    this.progress = 0.0,
    this.errorMessage,
    this.startTime,
    this.completedTime,
    this.fileSize,
    this.filePath,
  });

  DownloadItem copyWith({
    int? hymnId,
    String? hymnTitle,
    String? fileType,
    String? quality,
    DownloadState? state,
    double? progress,
    String? errorMessage,
    DateTime? startTime,
    DateTime? completedTime,
    int? fileSize,
    String? filePath,
  }) {
    return DownloadItem(
      hymnId: hymnId ?? this.hymnId,
      hymnTitle: hymnTitle ?? this.hymnTitle,
      fileType: fileType ?? this.fileType,
      quality: quality ?? this.quality,
      state: state ?? this.state,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
      startTime: startTime ?? this.startTime,
      completedTime: completedTime ?? this.completedTime,
      fileSize: fileSize ?? this.fileSize,
      filePath: filePath ?? this.filePath,
    );
  }

  String get downloadKey => '${hymnId}_${fileType}_${quality ?? 'default'}';
}

class DownloadProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  
  List<DownloadItem> _downloadQueue = [];
  List<DownloadItem> _activeDownloads = [];
  List<DownloadItem> _completedDownloads = [];
  List<Map<String, dynamic>> _downloadCache = [];
  
  DownloadLoadingState _loadingState = DownloadLoadingState.initial;
  String? _errorMessage;
  int _totalDownloadedSize = 0;
  int _maxConcurrentDownloads = AppConstants.maxConcurrentDownloads;

  // Getters
  List<DownloadItem> get downloadQueue => _downloadQueue;
  List<DownloadItem> get activeDownloads => _activeDownloads;
  List<DownloadItem> get completedDownloads => _completedDownloads;
  List<Map<String, dynamic>> get downloadCache => _downloadCache;
  DownloadLoadingState get loadingState => _loadingState;
  String? get errorMessage => _errorMessage;
  int get totalDownloadedSize => _totalDownloadedSize;
  bool get isLoading => _loadingState == DownloadLoadingState.loading;
  bool get hasError => _loadingState == DownloadLoadingState.error;
  bool get hasActiveDownloads => _activeDownloads.isNotEmpty;
  bool get hasQueuedDownloads => _downloadQueue.isNotEmpty;
  int get queuedCount => _downloadQueue.length;
  int get activeCount => _activeDownloads.length;
  int get completedCount => _completedDownloads.length;

  // Load download cache from database
  Future<void> loadDownloadCache() async {
    _setLoadingState(DownloadLoadingState.loading);
    
    try {
      _downloadCache = await _db.getDownloadCache();
      _calculateTotalSize();
      _setLoadingState(DownloadLoadingState.loaded);
    } catch (e) {
      _setError('Failed to load download cache: ${e.toString()}');
    }
  }

  // Check if media is downloaded
  Future<bool> isMediaDownloaded(int hymnId, String fileType) async {
    try {
      return await _db.isMediaDownloaded(hymnId, fileType);
    } catch (e) {
      _setError('Failed to check download status: ${e.toString()}');
      return false;
    }
  }

  // Add download to queue
  Future<bool> addToDownloadQueue(
    int hymnId,
    String hymnTitle,
    String fileType, {
    String? quality,
  }) async {
    try {
      // Check if already downloaded
      if (await isMediaDownloaded(hymnId, fileType)) {
        _setError('Media already downloaded');
        return false;
      }

      // Check if already in queue or downloading
      final downloadKey = '${hymnId}_${fileType}_${quality ?? 'default'}';
      if (_downloadQueue.any((item) => item.downloadKey == downloadKey) ||
          _activeDownloads.any((item) => item.downloadKey == downloadKey)) {
        _setError('Download already in progress');
        return false;
      }

      final downloadItem = DownloadItem(
        hymnId: hymnId,
        hymnTitle: hymnTitle,
        fileType: fileType,
        quality: quality,
        state: DownloadState.idle,
      );

      _downloadQueue.add(downloadItem);
      notifyListeners();

      // Start download if possible
      await _processDownloadQueue();
      
      return true;
    } catch (e) {
      _setError('Failed to add to download queue: ${e.toString()}');
      return false;
    }
  }

  // Start download
  Future<void> startDownload(DownloadItem item) async {
    try {
      // Move from queue to active
      _downloadQueue.removeWhere((queueItem) => queueItem.downloadKey == item.downloadKey);
      
      final activeItem = item.copyWith(
        state: DownloadState.downloading,
        startTime: DateTime.now(),
      );
      
      _activeDownloads.add(activeItem);
      notifyListeners();

      // Simulate download process
      await _performDownload(activeItem);
      
    } catch (e) {
      _setError('Failed to start download: ${e.toString()}');
      await _handleDownloadError(item, e.toString());
    }
  }

  // Pause download
  Future<void> pauseDownload(String downloadKey) async {
    final index = _activeDownloads.indexWhere((item) => item.downloadKey == downloadKey);
    if (index != -1) {
      _activeDownloads[index] = _activeDownloads[index].copyWith(
        state: DownloadState.paused,
      );
      notifyListeners();
    }
  }

  // Resume download
  Future<void> resumeDownload(String downloadKey) async {
    final index = _activeDownloads.indexWhere((item) => item.downloadKey == downloadKey);
    if (index != -1) {
      _activeDownloads[index] = _activeDownloads[index].copyWith(
        state: DownloadState.downloading,
      );
      notifyListeners();
    }
  }

  // Cancel download
  Future<void> cancelDownload(String downloadKey) async {
    // Remove from queue
    _downloadQueue.removeWhere((item) => item.downloadKey == downloadKey);
    
    // Remove from active downloads
    _activeDownloads.removeWhere((item) => item.downloadKey == downloadKey);
    
    notifyListeners();
    
    // Process next in queue
    await _processDownloadQueue();
  }

  // Remove completed download
  Future<void> removeCompletedDownload(String downloadKey) async {
    try {
      final item = _completedDownloads.firstWhere((item) => item.downloadKey == downloadKey);
      
      // Remove from database
      // Note: We would need to implement a method to remove from download_cache
      
      // Remove from completed list
      _completedDownloads.removeWhere((item) => item.downloadKey == downloadKey);
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to remove download: ${e.toString()}');
    }
  }

  // Clear all downloads
  Future<void> clearAllDownloads() async {
    try {
      _downloadQueue.clear();
      _activeDownloads.clear();
      _completedDownloads.clear();
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear downloads: ${e.toString()}');
    }
  }

  // Get download progress for hymn
  double getDownloadProgress(int hymnId, String fileType) {
    final downloadKey = '${hymnId}_${fileType}_default';
    
    final activeItem = _activeDownloads.firstWhere(
      (item) => item.downloadKey == downloadKey,
      orElse: () => const DownloadItem(hymnId: 0, hymnTitle: '', fileType: ''),
    );
    
    return activeItem.hymnId != 0 ? activeItem.progress : 0.0;
  }

  // Get download state for hymn
  DownloadState getDownloadState(int hymnId, String fileType) {
    final downloadKey = '${hymnId}_${fileType}_default';
    
    // Check active downloads
    final activeItem = _activeDownloads.firstWhere(
      (item) => item.downloadKey == downloadKey,
      orElse: () => const DownloadItem(hymnId: 0, hymnTitle: '', fileType: ''),
    );
    
    if (activeItem.hymnId != 0) return activeItem.state;
    
    // Check completed downloads
    final completedItem = _completedDownloads.firstWhere(
      (item) => item.downloadKey == downloadKey,
      orElse: () => const DownloadItem(hymnId: 0, hymnTitle: '', fileType: ''),
    );
    
    if (completedItem.hymnId != 0) return completedItem.state;
    
    // Check queue
    final queuedItem = _downloadQueue.firstWhere(
      (item) => item.downloadKey == downloadKey,
      orElse: () => const DownloadItem(hymnId: 0, hymnTitle: '', fileType: ''),
    );
    
    return queuedItem.hymnId != 0 ? queuedItem.state : DownloadState.idle;
  }

  // Get download statistics
  Map<String, dynamic> getDownloadStats() {
    return {
      'total_downloads': _completedDownloads.length,
      'total_size': _totalDownloadedSize,
      'active_downloads': _activeDownloads.length,
      'queued_downloads': _downloadQueue.length,
      'failed_downloads': _completedDownloads.where((item) => item.state == DownloadState.failed).length,
    };
  }

  // Private methods
  Future<void> _processDownloadQueue() async {
    while (_activeDownloads.length < _maxConcurrentDownloads && _downloadQueue.isNotEmpty) {
      final nextItem = _downloadQueue.first;
      await startDownload(nextItem);
    }
  }

  Future<void> _performDownload(DownloadItem item) async {
    try {
      // Simulate download with progress updates
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 100));
        
        final index = _activeDownloads.indexWhere((activeItem) => activeItem.downloadKey == item.downloadKey);
        if (index != -1) {
          _activeDownloads[index] = _activeDownloads[index].copyWith(
            progress: i / 100.0,
          );
          notifyListeners();
        }
      }

      // Simulate successful completion
      await _handleDownloadSuccess(item);
      
    } catch (e) {
      await _handleDownloadError(item, e.toString());
    }
  }

  Future<void> _handleDownloadSuccess(DownloadItem item) async {
    try {
      // Remove from active downloads
      _activeDownloads.removeWhere((activeItem) => activeItem.downloadKey == item.downloadKey);
      
      // Add to completed downloads
      final completedItem = item.copyWith(
        state: DownloadState.completed,
        progress: 1.0,
        completedTime: DateTime.now(),
        fileSize: 1024 * 1024, // Simulate 1MB file
        filePath: '/path/to/downloaded/file',
      );
      
      _completedDownloads.add(completedItem);
      
      // Add to database
      await _db.addDownloadCache(
        item.hymnId,
        item.fileType,
        '/path/to/downloaded/file',
        item.quality,
        1024 * 1024,
      );
      
      notifyListeners();
      
      // Process next in queue
      await _processDownloadQueue();
      
    } catch (e) {
      await _handleDownloadError(item, e.toString());
    }
  }

  Future<void> _handleDownloadError(DownloadItem item, String error) async {
    // Remove from active downloads
    _activeDownloads.removeWhere((activeItem) => activeItem.downloadKey == item.downloadKey);
    
    // Add to completed with error state
    final errorItem = item.copyWith(
      state: DownloadState.failed,
      errorMessage: error,
      completedTime: DateTime.now(),
    );
    
    _completedDownloads.add(errorItem);
    notifyListeners();
    
    // Process next in queue
    await _processDownloadQueue();
  }

  void _calculateTotalSize() {
    _totalDownloadedSize = _downloadCache.fold<int>(
      0,
      (sum, item) => sum + (item['file_size'] as int? ?? 0),
    );
  }

  void _setLoadingState(DownloadLoadingState state) {
    _loadingState = state;
    if (state != DownloadLoadingState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String error) {
    _loadingState = DownloadLoadingState.error;
    _errorMessage = error;
    notifyListeners();
  }
}