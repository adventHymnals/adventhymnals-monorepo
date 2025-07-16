/// Model representing a structured section of hymn lyrics
class LyricsSection {
  final String type; // "verse", "chorus", "bridge", "refrain"
  final int number; // verse number (1, 2, 3, etc.)
  final String content; // the actual text content
  final bool repeatAfterVerse; // whether this section should repeat after each verse

  const LyricsSection({
    required this.type,
    required this.number,
    required this.content,
    this.repeatAfterVerse = false,
  });

  /// Creates a verse section
  factory LyricsSection.verse(int number, String content) {
    return LyricsSection(
      type: 'verse',
      number: number,
      content: content,
    );
  }

  /// Creates a chorus section
  factory LyricsSection.chorus(String content, {bool repeatAfterVerse = true}) {
    return LyricsSection(
      type: 'chorus',
      number: 1,
      content: content,
      repeatAfterVerse: repeatAfterVerse,
    );
  }

  /// Creates a refrain section
  factory LyricsSection.refrain(String content, {bool repeatAfterVerse = true}) {
    return LyricsSection(
      type: 'refrain',
      number: 1,
      content: content,
      repeatAfterVerse: repeatAfterVerse,
    );
  }

  /// Creates a bridge section
  factory LyricsSection.bridge(String content) {
    return LyricsSection(
      type: 'bridge',
      number: 1,
      content: content,
    );
  }

  /// Gets the display label for this section
  String get displayLabel {
    switch (type.toLowerCase()) {
      case 'verse':
        return 'Verse $number';
      case 'chorus':
        return 'Chorus';
      case 'refrain':
        return 'Refrain';
      case 'bridge':
        return 'Bridge';
      default:
        return type;
    }
  }

  /// Whether this is a verse section
  bool get isVerse => type.toLowerCase() == 'verse';

  /// Whether this is a chorus section
  bool get isChorus => type.toLowerCase() == 'chorus';

  /// Whether this is a refrain section
  bool get isRefrain => type.toLowerCase() == 'refrain';

  /// Whether this is a bridge section
  bool get isBridge => type.toLowerCase() == 'bridge';

  @override
  String toString() {
    return 'LyricsSection(type: $type, number: $number, content: ${content.substring(0, content.length > 50 ? 50 : content.length)}...)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LyricsSection &&
        other.type == type &&
        other.number == number &&
        other.content == content &&
        other.repeatAfterVerse == repeatAfterVerse;
  }

  @override
  int get hashCode {
    return type.hashCode ^
        number.hashCode ^
        content.hashCode ^
        repeatAfterVerse.hashCode;
  }
}

/// Parser for hymn lyrics that converts raw text into structured sections
class LyricsParser {
  /// Parses raw lyrics text into structured sections
  static List<LyricsSection> parseLyrics(String lyrics) {
    if (lyrics.trim().isEmpty) {
      return [];
    }

    final sections = <LyricsSection>[];
    
    // Split by double newlines to get potential sections
    final rawSections = lyrics.split(RegExp(r'\n\s*\n')).where((s) => s.trim().isNotEmpty).toList();
    
    int verseNumber = 1;
    LyricsSection? chorusSection;
    
    for (final rawSection in rawSections) {
      final trimmedSection = rawSection.trim();
      if (trimmedSection.isEmpty) continue;
      
      final sectionType = _detectSectionType(trimmedSection);
      
      switch (sectionType) {
        case 'chorus':
        case 'refrain':
          // Store chorus/refrain for later repetition
          final cleanContent = _cleanSectionContent(trimmedSection, sectionType);
          chorusSection = sectionType == 'chorus' 
              ? LyricsSection.chorus(cleanContent)
              : LyricsSection.refrain(cleanContent);
          sections.add(chorusSection);
          break;
          
        case 'bridge':
          final cleanContent = _cleanSectionContent(trimmedSection, sectionType);
          sections.add(LyricsSection.bridge(cleanContent));
          break;
          
        case 'verse':
        default:
          // Treat as verse
          final cleanContent = _cleanSectionContent(trimmedSection, 'verse');
          sections.add(LyricsSection.verse(verseNumber, cleanContent));
          
          // Add chorus after verse if it exists and should repeat
          if (chorusSection != null && chorusSection.repeatAfterVerse && verseNumber > 1) {
            sections.add(chorusSection);
          }
          
          verseNumber++;
          break;
      }
    }
    
    return sections;
  }

  /// Detects the type of a lyrics section based on its content
  static String _detectSectionType(String section) {
    final firstLine = section.split('\n').first.toLowerCase().trim();
    
    // Check for explicit labels
    if (firstLine.startsWith('chorus') || 
        firstLine.contains('chorus:')) {
      return 'chorus';
    }
    
    if (firstLine.startsWith('refrain') ||
        firstLine.contains('refrain:')) {
      return 'refrain';
    }
    
    // Check for bridge indicators
    if (firstLine.startsWith('bridge') || firstLine.contains('bridge:')) {
      return 'bridge';
    }
    
    // Check for verse indicators
    if (firstLine.startsWith('verse') || 
        firstLine.contains('verse') ||
        RegExp(r'^\d+\.?\s').hasMatch(firstLine)) {
      return 'verse';
    }
    
    // Check for common chorus/refrain patterns
    if (_isLikelyChorus(section)) {
      return 'chorus';
    }
    
    // Default to verse
    return 'verse';
  }

  /// Determines if a section is likely a chorus based on content patterns
  static bool _isLikelyChorus(String section) {
    final lines = section.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    
    // Short sections are more likely to be choruses
    if (lines.length <= 4) {
      // Check for repetitive patterns common in choruses
      final words = section.toLowerCase().split(RegExp(r'\W+'));
      final wordCounts = <String, int>{};
      
      for (final word in words) {
        if (word.length > 2) { // Ignore short words
          wordCounts[word] = (wordCounts[word] ?? 0) + 1;
        }
      }
      
      // If there are repeated words, it might be a chorus
      final hasRepeatedWords = wordCounts.values.any((count) => count > 1);
      if (hasRepeatedWords && lines.length <= 6) {
        return true;
      }
    }
    
    return false;
  }

  /// Cleans section content by removing labels and extra whitespace
  static String _cleanSectionContent(String section, String sectionType) {
    final lines = section.split('\n').map((l) => l.trim()).toList();
    final cleanedLines = <String>[];
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.isEmpty) continue;
      
      // Skip the first line if it's just a label
      if (i == 0 && _isLabelLine(line, sectionType)) {
        continue;
      }
      
      cleanedLines.add(line);
    }
    
    return cleanedLines.join('\n').trim();
  }

  /// Checks if a line is just a section label
  static bool _isLabelLine(String line, String sectionType) {
    final lowerLine = line.toLowerCase().trim();
    
    // Remove punctuation for comparison
    final cleanLine = lowerLine.replaceAll(RegExp(r'[^\w\s]'), '').trim();
    
    switch (sectionType) {
      case 'chorus':
        return cleanLine == 'chorus' || cleanLine.startsWith('chorus ');
      case 'refrain':
        return cleanLine == 'refrain' || cleanLine.startsWith('refrain ');
      case 'bridge':
        return cleanLine == 'bridge' || cleanLine.startsWith('bridge ');
      case 'verse':
        return RegExp(r'^verse\s*\d*$').hasMatch(cleanLine) ||
               RegExp(r'^\d+\.?\s*$').hasMatch(cleanLine);
      default:
        return false;
    }
  }

  /// Parses lyrics with explicit structure information (for JSON data)
  static List<LyricsSection> parseStructuredLyrics(Map<String, dynamic> hymnData) {
    final sections = <LyricsSection>[];
    
    // Handle verses
    if (hymnData['verses'] != null) {
      final verses = hymnData['verses'] as List<dynamic>;
      for (int i = 0; i < verses.length; i++) {
        final verse = verses[i];
        final text = verse['text'] as String? ?? '';
        if (text.isNotEmpty) {
          sections.add(LyricsSection.verse(i + 1, text));
        }
      }
    }
    
    // Handle refrain/chorus
    if (hymnData['refrain'] != null) {
      final refrain = hymnData['refrain'];
      final text = refrain['text'] as String? ?? '';
      if (text.isNotEmpty) {
        sections.add(LyricsSection.refrain(text));
      }
    }
    
    // Handle chorus (separate from refrain)
    if (hymnData['chorus'] != null) {
      final chorus = hymnData['chorus'];
      final text = chorus['text'] as String? ?? '';
      if (text.isNotEmpty) {
        sections.add(LyricsSection.chorus(text));
      }
    }
    
    return sections;
  }
}