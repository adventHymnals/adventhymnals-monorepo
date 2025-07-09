import 'package:json_annotation/json_annotation.dart';

part 'media_models.g.dart';

enum MediaType {
  @JsonValue('audio')
  audio,
  @JsonValue('image')
  image,
  @JsonValue('pdf')
  pdf,
  @JsonValue('midi')
  midi,
  @JsonValue('video')
  video,
}

enum MediaFormat {
  @JsonValue('mp3')
  mp3,
  @JsonValue('wav')
  wav,
  @JsonValue('midi')
  midi,
  @JsonValue('mid')
  mid,
  @JsonValue('png')
  png,
  @JsonValue('jpg')
  jpg,
  @JsonValue('jpeg')
  jpeg,
  @JsonValue('svg')
  svg,
  @JsonValue('pdf')
  pdf,
  @JsonValue('mp4')
  mp4,
  @JsonValue('webm')
  webm,
}

enum DownloadStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('downloading')
  downloading,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
  @JsonValue('paused')
  paused,
}

@JsonSerializable()
class MediaFile {
  final String id;
  final String filename;
  final String url;
  final MediaType type;
  final MediaFormat format;
  final int size;
  final Map<String, dynamic> metadata;
  final String? description;
  final int? duration; // in seconds for audio/video
  final String? checksum;
  
  MediaFile({
    required this.id,
    required this.filename,
    required this.url,
    required this.type,
    required this.format,
    required this.size,
    this.metadata = const {},
    this.description,
    this.duration,
    this.checksum,
  });
  
  factory MediaFile.fromJson(Map<String, dynamic> json) => _$MediaFileFromJson(json);
  Map<String, dynamic> toJson() => _$MediaFileToJson(this);
  
  String get displayName => description ?? filename;
  String get extension => format.name;
  
  bool get isAudio => type == MediaType.audio;
  bool get isImage => type == MediaType.image;
  bool get isPdf => type == MediaType.pdf;
  bool get isMidi => type == MediaType.midi;
  bool get isVideo => type == MediaType.video;
  
  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  String? get formattedDuration {
    if (duration == null) return null;
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

@JsonSerializable()
class MediaMetadata {
  final String hymnId;
  final List<MediaFile> files;
  final DateTime lastUpdated;
  final String? version;
  final Map<String, dynamic> additionalData;
  
  MediaMetadata({
    required this.hymnId,
    required this.files,
    required this.lastUpdated,
    this.version,
    this.additionalData = const {},
  });
  
  factory MediaMetadata.fromJson(Map<String, dynamic> json) => _$MediaMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$MediaMetadataToJson(this);
  
  List<MediaFile> getFilesByType(MediaType type) {
    return files.where((f) => f.type == type).toList();
  }
  
  List<MediaFile> getFilesByFormat(MediaFormat format) {
    return files.where((f) => f.format == format).toList();
  }
  
  MediaFile? getFileById(String id) {
    try {
      return files.firstWhere((f) => f.id == id);
    } catch (e) {
      return null;
    }
  }
  
  List<MediaFile> get audioFiles => getFilesByType(MediaType.audio);
  List<MediaFile> get imageFiles => getFilesByType(MediaType.image);
  List<MediaFile> get pdfFiles => getFilesByType(MediaType.pdf);
  List<MediaFile> get midiFiles => getFilesByType(MediaType.midi);
  List<MediaFile> get videoFiles => getFilesByType(MediaType.video);
  
  bool get hasAudio => audioFiles.isNotEmpty;
  bool get hasImages => imageFiles.isNotEmpty;
  bool get hasPdf => pdfFiles.isNotEmpty;
  bool get hasMidi => midiFiles.isNotEmpty;
  bool get hasVideo => videoFiles.isNotEmpty;
  
  int get totalSize => files.fold(0, (sum, file) => sum + file.size);
  String get formattedTotalSize {
    if (totalSize < 1024) return '$totalSize B';
    if (totalSize < 1024 * 1024) return '${(totalSize / 1024).toStringAsFixed(1)} KB';
    if (totalSize < 1024 * 1024 * 1024) return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(totalSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

@JsonSerializable()
class DownloadProgress {
  final String mediaId;
  final double progress; // 0.0 to 1.0
  final DownloadStatus status;
  final int bytesDownloaded;
  final int totalBytes;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? error;
  final double? speed; // bytes per second
  
  DownloadProgress({
    required this.mediaId,
    required this.progress,
    required this.status,
    required this.bytesDownloaded,
    required this.totalBytes,
    this.startTime,
    this.endTime,
    this.error,
    this.speed,
  });
  
  factory DownloadProgress.fromJson(Map<String, dynamic> json) => _$DownloadProgressFromJson(json);
  Map<String, dynamic> toJson() => _$DownloadProgressToJson(this);
  
  factory DownloadProgress.initial(String mediaId) {
    return DownloadProgress(
      mediaId: mediaId,
      progress: 0.0,
      status: DownloadStatus.pending,
      bytesDownloaded: 0,
      totalBytes: 0,
    );
  }
  
  factory DownloadProgress.downloading(
    String mediaId,
    int bytesDownloaded,
    int totalBytes, {
    double? speed,
  }) {
    return DownloadProgress(
      mediaId: mediaId,
      progress: totalBytes > 0 ? bytesDownloaded / totalBytes : 0.0,
      status: DownloadStatus.downloading,
      bytesDownloaded: bytesDownloaded,
      totalBytes: totalBytes,
      speed: speed,
    );
  }
  
  factory DownloadProgress.completed(String mediaId, int totalBytes) {
    return DownloadProgress(
      mediaId: mediaId,
      progress: 1.0,
      status: DownloadStatus.completed,
      bytesDownloaded: totalBytes,
      totalBytes: totalBytes,
      endTime: DateTime.now(),
    );
  }
  
  factory DownloadProgress.failed(String mediaId, String error) {
    return DownloadProgress(
      mediaId: mediaId,
      progress: 0.0,
      status: DownloadStatus.failed,
      bytesDownloaded: 0,
      totalBytes: 0,
      error: error,
      endTime: DateTime.now(),
    );
  }
  
  bool get isCompleted => status == DownloadStatus.completed;
  bool get isFailed => status == DownloadStatus.failed;
  bool get isDownloading => status == DownloadStatus.downloading;
  bool get isPending => status == DownloadStatus.pending;
  bool get isPaused => status == DownloadStatus.paused;
  
  String get formattedProgress => '${(progress * 100).toStringAsFixed(1)}%';
  
  String get formattedSpeed {
    if (speed == null) return 'Unknown';
    if (speed! < 1024) return '${speed!.toStringAsFixed(1)} B/s';
    if (speed! < 1024 * 1024) return '${(speed! / 1024).toStringAsFixed(1)} KB/s';
    return '${(speed! / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }
  
  Duration? get estimatedTimeRemaining {
    if (speed == null || speed! <= 0 || progress >= 1.0) return null;
    final remainingBytes = totalBytes - bytesDownloaded;
    final remainingSeconds = remainingBytes / speed!;
    return Duration(seconds: remainingSeconds.round());
  }
}

@JsonSerializable()
class DownloadResult {
  final bool isSuccess;
  final String? filePath;
  final String? error;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;
  
  DownloadResult({
    required this.isSuccess,
    this.filePath,
    this.error,
    this.metadata = const {},
    required this.timestamp,
  });
  
  factory DownloadResult.fromJson(Map<String, dynamic> json) => _$DownloadResultFromJson(json);
  Map<String, dynamic> toJson() => _$DownloadResultToJson(this);
  
  factory DownloadResult.success(String filePath, {Map<String, dynamic>? metadata}) {
    return DownloadResult(
      isSuccess: true,
      filePath: filePath,
      metadata: metadata ?? {},
      timestamp: DateTime.now(),
    );
  }
  
  factory DownloadResult.error(String error, {Map<String, dynamic>? metadata}) {
    return DownloadResult(
      isSuccess: false,
      error: error,
      metadata: metadata ?? {},
      timestamp: DateTime.now(),
    );
  }
}

@JsonSerializable()
class LocalMediaInfo {
  final String mediaId;
  final String localPath;
  final DateTime downloadDate;
  final int size;
  final String checksum;
  final Map<String, dynamic> metadata;
  final DateTime? lastAccessed;
  
  LocalMediaInfo({
    required this.mediaId,
    required this.localPath,
    required this.downloadDate,
    required this.size,
    required this.checksum,
    this.metadata = const {},
    this.lastAccessed,
  });
  
  factory LocalMediaInfo.fromJson(Map<String, dynamic> json) => _$LocalMediaInfoFromJson(json);
  Map<String, dynamic> toJson() => _$LocalMediaInfoToJson(this);
  
  LocalMediaInfo copyWith({
    String? mediaId,
    String? localPath,
    DateTime? downloadDate,
    int? size,
    String? checksum,
    Map<String, dynamic>? metadata,
    DateTime? lastAccessed,
  }) {
    return LocalMediaInfo(
      mediaId: mediaId ?? this.mediaId,
      localPath: localPath ?? this.localPath,
      downloadDate: downloadDate ?? this.downloadDate,
      size: size ?? this.size,
      checksum: checksum ?? this.checksum,
      metadata: metadata ?? this.metadata,
      lastAccessed: lastAccessed ?? this.lastAccessed,
    );
  }
}