import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/hymn.dart';

enum AudioFormat { mp3, midi }
enum AudioAvailability { unknown, checking, available, unavailable }

class AudioFileInfo {
  final String url;
  final AudioFormat format;
  final bool isLocal;
  final String? localPath;
  final int? fileSizeBytes;
  
  AudioFileInfo({
    required this.url,
    required this.format,
    this.isLocal = false,
    this.localPath,
    this.fileSizeBytes,
  });
}

class HymnAudioInfo {
  final Hymn hymn;
  final Map<AudioFormat, AudioAvailability> availability;
  final Map<AudioFormat, AudioFileInfo> audioFiles;
  final DateTime lastChecked;
  
  HymnAudioInfo({
    required this.hymn,
    required this.availability,
    required this.audioFiles,
    required this.lastChecked,
  });
  
  bool get hasAnyAudio => availability.values.any((a) => a == AudioAvailability.available);
  bool get isChecking => availability.values.any((a) => a == AudioAvailability.checking);
  
  List<AudioFormat> get availableFormats => 
    availability.entries
      .where((entry) => entry.value == AudioAvailability.available)
      .map((entry) => entry.key)
      .toList();
      
  AudioFormat? get preferredFormat {
    // Always prefer MP3 as it's more widely supported across platforms
    final available = availableFormats;
    if (available.isEmpty) return null;
    
    // On Windows, only MP3 is supported (MIDI files are not supported)
    if (Platform.isWindows) {
      return available.contains(AudioFormat.mp3) ? AudioFormat.mp3 : null;
    }
    
    // MP3 is supported on all platforms and provides better quality
    return available.contains(AudioFormat.mp3) ? AudioFormat.mp3 : available.first;
  }
}

/// Comprehensive audio service with existence checking, caching, and advanced features
class ComprehensiveAudioService {
  static final ComprehensiveAudioService _instance = ComprehensiveAudioService._internal();
  static ComprehensiveAudioService get instance => _instance;
  ComprehensiveAudioService._internal();

  // Audio availability cache
  final Map<String, HymnAudioInfo> _audioCache = {};
  
  // HTTP client for checking file existence
  final http.Client _httpClient = http.Client();
  
  // Cache settings
  static const Duration _cacheValidDuration = Duration(hours: 24);
  static const String _cacheKey = 'audio_availability_cache';
  
  /// Base URLs for audio files (matching web implementation)
  static const String _primaryAudioBase = 'https://media.adventhymnals.org/audio';
  
  /// Check if an audio format is supported on the current platform
  static bool isFormatSupported(AudioFormat format) {
    switch (format) {
      case AudioFormat.mp3:
        return true; // MP3 is supported on all platforms
      case AudioFormat.midi:
        // MIDI files are not supported on Windows
        return !Platform.isWindows;
    }
  }
  
  /// Get audio URLs for a hymn with fallback support
  List<String> _getAudioUrls(Hymn hymn, AudioFormat format) {
    final hymnalId = hymn.collectionAbbreviation ?? 'SDAH';
    final hymnNumber = hymn.hymnNumber.toString();
    final extension = format == AudioFormat.mp3 ? 'mp3' : 'mid';
    
    return [
      // Primary CDN URL
      '$_primaryAudioBase/$hymnalId/$hymnNumber.$extension',
      // Add fallback URLs here if needed in future
    ];
  }
  
  /// Check if audio file exists at URL using HEAD request
  Future<bool> _checkAudioExists(String url) async {
    try {
      final response = await _httpClient.head(
        Uri.parse(url),
        headers: {
          'User-Agent': 'AdventHymnals-Mobile/1.0',
        },
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [AudioService] Failed to check audio existence for $url: $e');
      }
      return false;
    }
  }
  
  /// Get audio availability for a hymn (with caching)
  Future<HymnAudioInfo> getAudioInfo(Hymn hymn, {Function(HymnAudioInfo)? onComplete}) async {
    final cacheKey = '${hymn.collectionAbbreviation}_${hymn.hymnNumber}';
    
    if (kDebugMode) {
      print('🔍 [AudioService] Getting audio info for $cacheKey');
    }
    
    // Check if we have recent cached data
    if (_audioCache.containsKey(cacheKey)) {
      final cached = _audioCache[cacheKey]!;
      if (DateTime.now().difference(cached.lastChecked) < _cacheValidDuration) {
        if (kDebugMode) {
          print('🔍 [AudioService] Returning cached data for $cacheKey: hasAudio=${cached.hasAnyAudio}, formats=${cached.availableFormats}');
        }
        return cached;
      }
    }
    
    // Create initial info with checking state (only for supported formats)
    final Map<AudioFormat, AudioAvailability> initialAvailability = {};
    for (final format in AudioFormat.values) {
      if (isFormatSupported(format)) {
        initialAvailability[format] = AudioAvailability.checking;
        if (kDebugMode) {
          print('🔍 [AudioService] Format ${format.name} is supported, setting to checking');
        }
      } else {
        initialAvailability[format] = AudioAvailability.unavailable;
        if (kDebugMode) {
          print('🔍 [AudioService] Format ${format.name} is NOT supported on this platform, setting to unavailable');
        }
      }
    }
    
    final initialInfo = HymnAudioInfo(
      hymn: hymn,
      availability: initialAvailability,
      audioFiles: {},
      lastChecked: DateTime.now(),
    );
    
    _audioCache[cacheKey] = initialInfo;
    
    if (kDebugMode) {
      print('🔍 [AudioService] Created initial info, isChecking=${initialInfo.isChecking}');
    }
    
    // Check availability asynchronously
    _checkAudioAvailability(hymn, cacheKey, onComplete: onComplete);
    
    return initialInfo;
  }
  
  /// Check audio availability for all formats
  Future<void> _checkAudioAvailability(Hymn hymn, String cacheKey, {Function(HymnAudioInfo)? onComplete}) async {
    final Map<AudioFormat, AudioAvailability> availability = {};
    final Map<AudioFormat, AudioFileInfo> audioFiles = {};
    
    // Check each format
    for (final format in AudioFormat.values) {
      // Skip unsupported formats on current platform
      if (!isFormatSupported(format)) {
        availability[format] = AudioAvailability.unavailable;
        continue;
      }
      
      final urls = _getAudioUrls(hymn, format);
      bool found = false;
      
      for (final url in urls) {
        if (await _checkAudioExists(url)) {
          availability[format] = AudioAvailability.available;
          audioFiles[format] = AudioFileInfo(
            url: url,
            format: format,
            isLocal: false,
          );
          found = true;
          break;
        }
      }
      
      if (!found) {
        availability[format] = AudioAvailability.unavailable;
      }
    }
    
    // Update cache with results
    final updatedInfo = HymnAudioInfo(
      hymn: hymn,
      availability: availability,
      audioFiles: audioFiles,
      lastChecked: DateTime.now(),
    );
    
    _audioCache[cacheKey] = updatedInfo;
    
    // Save to persistent cache
    await _saveCacheToDisk();
    
    if (kDebugMode) {
      print('✅ [AudioService] Audio availability checked for ${hymn.title}: ${availability.toString()}');
    }
    
    // Notify completion
    if (onComplete != null) {
      onComplete(updatedInfo);
    }
  }
  
  /// Get local file path for cached audio
  Future<String> _getLocalAudioPath(Hymn hymn, AudioFormat format) async {
    final directory = await getApplicationDocumentsDirectory();
    final audioDir = Directory(path.join(directory.path, 'audio_cache'));
    
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    
    final hymnalId = hymn.collectionAbbreviation ?? 'SDAH';
    final hymnNumber = hymn.hymnNumber.toString();
    final extension = format == AudioFormat.mp3 ? 'mp3' : 'mid';
    
    return path.join(audioDir.path, '${hymnalId}_${hymnNumber}.$extension');
  }
  
  /// Download and cache audio file locally
  Future<bool> downloadAudioFile(Hymn hymn, AudioFormat format, {
    Function(double)? onProgress,
  }) async {
    try {
      final audioInfo = await getAudioInfo(hymn);
      final audioFile = audioInfo.audioFiles[format];
      
      if (audioFile == null) {
        if (kDebugMode) {
          print('❌ [AudioService] No audio file available for download');
        }
        return false;
      }
      
      final localPath = await _getLocalAudioPath(hymn, format);
      final response = await _httpClient.get(Uri.parse(audioFile.url));
      
      if (response.statusCode == 200) {
        final file = File(localPath);
        await file.writeAsBytes(response.bodyBytes);
        
        // Update cache with local file info
        final cacheKey = '${hymn.collectionAbbreviation}_${hymn.hymnNumber}';
        if (_audioCache.containsKey(cacheKey)) {
          final currentInfo = _audioCache[cacheKey]!;
          final updatedAudioFiles = Map<AudioFormat, AudioFileInfo>.from(currentInfo.audioFiles);
          
          updatedAudioFiles[format] = AudioFileInfo(
            url: audioFile.url,
            format: format,
            isLocal: true,
            localPath: localPath,
            fileSizeBytes: response.bodyBytes.length,
          );
          
          _audioCache[cacheKey] = HymnAudioInfo(
            hymn: currentInfo.hymn,
            availability: currentInfo.availability,
            audioFiles: updatedAudioFiles,
            lastChecked: currentInfo.lastChecked,
          );
          
          await _saveCacheToDisk();
        }
        
        if (kDebugMode) {
          print('✅ [AudioService] Downloaded audio file: $localPath');
        }
        
        return true;
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [AudioService] Failed to download audio file: $e');
      }
      return false;
    }
  }
  
  /// Get the best audio file for playback (local first, then online)
  Future<AudioFileInfo?> getBestAudioFile(HymnAudioInfo audioInfo, {AudioFormat? preferredFormat}) async {
    final format = preferredFormat ?? audioInfo.preferredFormat;
    if (format == null) return null;
    
    final audioFile = audioInfo.audioFiles[format];
    if (audioFile == null) return null;
    
    // Check if local file exists and is valid
    if (audioFile.isLocal && audioFile.localPath != null) {
      final localFile = File(audioFile.localPath!);
      if (await localFile.exists()) {
        return audioFile;
      }
    }
    
    // Return online file
    return audioFile;
  }
  
  /// Save audio cache to disk for persistence
  Future<void> _saveCacheToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = <String, dynamic>{};
      
      for (final entry in _audioCache.entries) {
        cacheData[entry.key] = {
          'hymn_id': entry.value.hymn.id,
          'hymn_number': entry.value.hymn.hymnNumber,
          'collection': entry.value.hymn.collectionAbbreviation,
          'availability': entry.value.availability.map((k, v) => MapEntry(k.name, v.name)),
          'audio_files': entry.value.audioFiles.map((k, v) => MapEntry(
            k.name,
            {
              'url': v.url,
              'format': v.format.name,
              'is_local': v.isLocal,
              'local_path': v.localPath,
              'file_size': v.fileSizeBytes,
            },
          )),
          'last_checked': entry.value.lastChecked.millisecondsSinceEpoch,
        };
      }
      
      await prefs.setString(_cacheKey, jsonEncode(cacheData));
    } catch (e) {
      if (kDebugMode) {
        print('❌ [AudioService] Failed to save cache to disk: $e');
      }
    }
  }
  
  /// Load audio cache from disk
  Future<void> loadCacheFromDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheJson = prefs.getString(_cacheKey);
      
      if (cacheJson == null) return;
      
      final cacheData = jsonDecode(cacheJson) as Map<String, dynamic>;
      
      for (final entry in cacheData.entries) {
        final data = entry.value as Map<String, dynamic>;
        
        // Reconstruct hymn (simplified)
        final hymn = Hymn(
          id: data['hymn_id'] as int,
          hymnNumber: data['hymn_number'] as int,
          title: 'Cached Hymn', // Will be updated when full hymn data is available
          collectionAbbreviation: data['collection'] as String?,
        );
        
        // Reconstruct availability
        final availability = <AudioFormat, AudioAvailability>{};
        final availabilityData = data['availability'] as Map<String, dynamic>;
        for (final formatEntry in availabilityData.entries) {
          final format = AudioFormat.values.firstWhere((f) => f.name == formatEntry.key);
          final avail = AudioAvailability.values.firstWhere((a) => a.name == formatEntry.value);
          availability[format] = avail;
        }
        
        // Reconstruct audio files
        final audioFiles = <AudioFormat, AudioFileInfo>{};
        final filesData = data['audio_files'] as Map<String, dynamic>;
        for (final fileEntry in filesData.entries) {
          final format = AudioFormat.values.firstWhere((f) => f.name == fileEntry.key);
          final fileData = fileEntry.value as Map<String, dynamic>;
          
          audioFiles[format] = AudioFileInfo(
            url: fileData['url'] as String,
            format: AudioFormat.values.firstWhere((f) => f.name == fileData['format']),
            isLocal: fileData['is_local'] as bool,
            localPath: fileData['local_path'] as String?,
            fileSizeBytes: fileData['file_size'] as int?,
          );
        }
        
        _audioCache[entry.key] = HymnAudioInfo(
          hymn: hymn,
          availability: availability,
          audioFiles: audioFiles,
          lastChecked: DateTime.fromMillisecondsSinceEpoch(data['last_checked'] as int),
        );
      }
      
      if (kDebugMode) {
        print('✅ [AudioService] Loaded ${_audioCache.length} items from cache');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [AudioService] Failed to load cache from disk: $e');
      }
    }
  }
  
  /// Clear all cached audio files
  Future<void> clearCache() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final audioDir = Directory(path.join(directory.path, 'audio_cache'));
      
      if (await audioDir.exists()) {
        await audioDir.delete(recursive: true);
      }
      
      _audioCache.clear();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      
      if (kDebugMode) {
        print('✅ [AudioService] Cache cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [AudioService] Failed to clear cache: $e');
      }
    }
  }
  
  /// Get cache size in bytes
  Future<int> getCacheSize() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final audioDir = Directory(path.join(directory.path, 'audio_cache'));
      
      if (!await audioDir.exists()) return 0;
      
      int totalSize = 0;
      await for (final entity in audioDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      
      return totalSize;
    } catch (e) {
      return 0;
    }
  }
  
  /// Format cache size for display
  String formatCacheSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  /// Dispose resources
  void dispose() {
    _httpClient.close();
  }
}