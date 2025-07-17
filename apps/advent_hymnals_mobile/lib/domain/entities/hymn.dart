class Hymn {
  final int id;
  final int hymnNumber;
  final String title;
  final String? author;
  final String? composer;
  final String? tuneName;
  final String? meter;
  final int? collectionId;
  final String? collectionAbbreviation; // Added for displaying hymnal abbreviation
  final String? lyrics;
  final List<String>? themeTags;
  final List<String>? scriptureRefs;
  final String? firstLine;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Runtime properties
  final bool isFavorite;
  final int? viewCount;
  final DateTime? lastViewed;
  final DateTime? lastPlayed;
  final int? playCount;

  const Hymn({
    required this.id,
    required this.hymnNumber,
    required this.title,
    this.author,
    this.composer,
    this.tuneName,
    this.meter,
    this.collectionId,
    this.collectionAbbreviation,
    this.lyrics,
    this.themeTags,
    this.scriptureRefs,
    this.firstLine,
    this.createdAt,
    this.updatedAt,
    this.isFavorite = false,
    this.viewCount,
    this.lastViewed,
    this.lastPlayed,
    this.playCount,
  });

  Hymn copyWith({
    int? id,
    int? hymnNumber,
    String? title,
    String? author,
    String? composer,
    String? tuneName,
    String? meter,
    int? collectionId,
    String? collectionAbbreviation,
    String? lyrics,
    List<String>? themeTags,
    List<String>? scriptureRefs,
    String? firstLine,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    int? viewCount,
    DateTime? lastViewed,
    DateTime? lastPlayed,
    int? playCount,
  }) {
    return Hymn(
      id: id ?? this.id,
      hymnNumber: hymnNumber ?? this.hymnNumber,
      title: title ?? this.title,
      author: author ?? this.author,
      composer: composer ?? this.composer,
      tuneName: tuneName ?? this.tuneName,
      meter: meter ?? this.meter,
      collectionId: collectionId ?? this.collectionId,
      collectionAbbreviation: collectionAbbreviation ?? this.collectionAbbreviation,
      lyrics: lyrics ?? this.lyrics,
      themeTags: themeTags ?? this.themeTags,
      scriptureRefs: scriptureRefs ?? this.scriptureRefs,
      firstLine: firstLine ?? this.firstLine,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      viewCount: viewCount ?? this.viewCount,
      lastViewed: lastViewed ?? this.lastViewed,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      playCount: playCount ?? this.playCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Hymn &&
      other.id == id &&
      other.hymnNumber == hymnNumber &&
      other.title == title;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      hymnNumber.hashCode ^
      title.hashCode;
  }

  /// Create Hymn from processed JSON data format
  factory Hymn.fromJsonData(Map<String, dynamic> json) {
    // Extract hymn number from ID (e.g., "SDAH-en-001" -> 1)
    final hymnId = json['id'] as String;
    final idParts = hymnId.split('-');
    final numberPart = idParts.isNotEmpty ? idParts.last : '0';
    final hymnNumber = int.tryParse(numberPart) ?? 0;
    
    // Convert verses array to a single lyrics string
    String? lyrics;
    if (json['verses'] != null) {
      final verses = json['verses'] as List<dynamic>;
      final verseTexts = verses.map((verse) => verse['text'] as String).toList();
      
      // Add chorus if present
      if (json['chorus'] != null) {
        final chorus = json['chorus']['text'] as String;
        verseTexts.add('\nChorus:\n$chorus');
      }
      
      // Add refrain if present (legacy support)
      if (json['refrain'] != null) {
        final refrain = json['refrain']['text'] as String;
        verseTexts.add('\nRefrain:\n$refrain');
      }
      
      lyrics = verseTexts.join('\n\n');
    }
    
    // Get first line from first verse
    String? firstLine;
    if (json['verses'] != null && (json['verses'] as List).isNotEmpty) {
      final firstVerse = (json['verses'] as List).first;
      final verseText = firstVerse['text'] as String;
      // Extract first line (up to first period or newline)
      firstLine = verseText.split(RegExp(r'[.\n]')).first.trim();
    }
    
    // Extract metadata
    final metadata = json['metadata'] as Map<String, dynamic>?;
    final themes = metadata?['themes'] as List<dynamic>?;
    final scriptureRefs = metadata?['scripture_references'] as List<dynamic>?;
    
    return Hymn(
      id: hymnNumber, // Use hymn number as ID for now
      hymnNumber: hymnNumber,
      title: json['title'] as String,
      author: json['author'] as String?,
      composer: json['composer'] as String?,
      tuneName: json['tune'] as String?,
      meter: json['meter'] as String?,
      lyrics: lyrics,
      firstLine: firstLine,
      themeTags: themes?.cast<String>(),
      scriptureRefs: scriptureRefs?.cast<String>(),
      createdAt: metadata?['year'] != null 
          ? DateTime(metadata!['year'] as int)
          : null,
    );
  }

  /// Alias for fromJsonData to support DataImportService
  factory Hymn.fromJson(Map<String, dynamic> json) => Hymn.fromJsonData(json);

  @override
  String toString() {
    return 'Hymn(id: $id, hymnNumber: $hymnNumber, title: $title, author: $author)';
  }
}

class Author {
  final int id;
  final String name;
  final int? birthYear;
  final int? deathYear;
  final String? nationality;
  final String? biography;
  final DateTime? createdAt;
  final int? hymnCount;

  const Author({
    required this.id,
    required this.name,
    this.birthYear,
    this.deathYear,
    this.nationality,
    this.biography,
    this.createdAt,
    this.hymnCount,
  });

  Author copyWith({
    int? id,
    String? name,
    int? birthYear,
    int? deathYear,
    String? nationality,
    String? biography,
    DateTime? createdAt,
    int? hymnCount,
  }) {
    return Author(
      id: id ?? this.id,
      name: name ?? this.name,
      birthYear: birthYear ?? this.birthYear,
      deathYear: deathYear ?? this.deathYear,
      nationality: nationality ?? this.nationality,
      biography: biography ?? this.biography,
      createdAt: createdAt ?? this.createdAt,
      hymnCount: hymnCount ?? this.hymnCount,
    );
  }

  String get displayName => name;
  
  String get lifeSpan {
    if (birthYear != null && deathYear != null) {
      return '$birthYear-$deathYear';
    } else if (birthYear != null) {
      return '$birthYear-';
    } else if (deathYear != null) {
      return '-$deathYear';
    }
    return '';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Author &&
      other.id == id &&
      other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() => 'Author(id: $id, name: $name)';
}

class Collection {
  final int id;
  final String name;
  final String abbreviation;
  final int? year;
  final String language;
  final int totalHymns;
  final String? colorHex;
  final String? description;
  final DateTime? createdAt;

  const Collection({
    required this.id,
    required this.name,
    required this.abbreviation,
    this.year,
    this.language = 'English',
    this.totalHymns = 0,
    this.colorHex,
    this.description,
    this.createdAt,
  });

  Collection copyWith({
    int? id,
    String? name,
    String? abbreviation,
    int? year,
    String? language,
    int? totalHymns,
    String? colorHex,
    String? description,
    DateTime? createdAt,
  }) {
    return Collection(
      id: id ?? this.id,
      name: name ?? this.name,
      abbreviation: abbreviation ?? this.abbreviation,
      year: year ?? this.year,
      language: language ?? this.language,
      totalHymns: totalHymns ?? this.totalHymns,
      colorHex: colorHex ?? this.colorHex,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Collection &&
      other.id == id &&
      other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() => 'Collection(id: $id, name: $name, abbreviation: $abbreviation)';
}

class Topic {
  final int id;
  final String name;
  final String? description;
  final String? category;
  final DateTime? createdAt;
  final int? hymnCount;

  const Topic({
    required this.id,
    required this.name,
    this.description,
    this.category,
    this.createdAt,
    this.hymnCount,
  });

  Topic copyWith({
    int? id,
    String? name,
    String? description,
    String? category,
    DateTime? createdAt,
    int? hymnCount,
  }) {
    return Topic(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      hymnCount: hymnCount ?? this.hymnCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Topic &&
      other.id == id &&
      other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() => 'Topic(id: $id, name: $name)';
}

enum MediaType {
  audio,
  midi,
  image,
  pdf,
}

enum AudioQuality {
  high,
  standard,
  low,
}

class MediaFile {
  final int id;
  final int hymnId;
  final MediaType type;
  final String filePath;
  final int? fileSize;
  final AudioQuality? quality;
  final DateTime? downloadDate;
  final DateTime? lastAccessed;
  final bool isOfflineAvailable;

  const MediaFile({
    required this.id,
    required this.hymnId,
    required this.type,
    required this.filePath,
    this.fileSize,
    this.quality,
    this.downloadDate,
    this.lastAccessed,
    this.isOfflineAvailable = true,
  });

  MediaFile copyWith({
    int? id,
    int? hymnId,
    MediaType? type,
    String? filePath,
    int? fileSize,
    AudioQuality? quality,
    DateTime? downloadDate,
    DateTime? lastAccessed,
    bool? isOfflineAvailable,
  }) {
    return MediaFile(
      id: id ?? this.id,
      hymnId: hymnId ?? this.hymnId,
      type: type ?? this.type,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      quality: quality ?? this.quality,
      downloadDate: downloadDate ?? this.downloadDate,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      isOfflineAvailable: isOfflineAvailable ?? this.isOfflineAvailable,
    );
  }

  String get displaySize {
    if (fileSize == null) return 'Unknown';
    
    final size = fileSize!;
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is MediaFile &&
      other.id == id &&
      other.hymnId == hymnId &&
      other.type == type;
  }

  @override
  int get hashCode => id.hashCode ^ hymnId.hashCode ^ type.hashCode;

  @override
  String toString() => 'MediaFile(id: $id, hymnId: $hymnId, type: $type)';
}