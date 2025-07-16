import '../models/search_query.dart';

class SearchQueryParser {
  // Common hymnal abbreviations and their variations
  static const Map<String, String> _hymnalAbbreviations = {
    // Seventh-day Adventist Hymnal
    'sdah': 'SDAH',
    'sda': 'SDAH',
    'adventist': 'SDAH',
    
    // Christ in Song
    'ch1941': 'CH1941',
    'ch': 'CH1941',
    'christ': 'CH1941',
    'christinsong': 'CH1941',
    
    // Other common hymnals
    'hymns': 'HYMNS',
    'gospel': 'GOSPEL',
    'praise': 'PRAISE',
    'worship': 'WORSHIP',
    'songs': 'SONGS',
  };

  /// Parses a search query to extract hymnal abbreviation, hymn number, and search text
  /// 
  /// Examples:
  /// - "sdah 125" -> SearchQuery(hymnalAbbreviation: "SDAH", hymnNumber: 125, searchText: "")
  /// - "ch1941 amazing grace" -> SearchQuery(hymnalAbbreviation: "CH1941", hymnNumber: null, searchText: "amazing grace")
  /// - "sdah" -> SearchQuery(hymnalAbbreviation: "SDAH", hymnNumber: null, searchText: "")
  /// - "amazing grace" -> SearchQuery(hymnalAbbreviation: null, hymnNumber: null, searchText: "amazing grace")
  static SearchQuery parse(String query) {
    if (query.trim().isEmpty) {
      return SearchQuery(
        originalQuery: query,
        searchText: '',
        hasHymnalFilter: false,
      );
    }

    final trimmedQuery = query.trim().toLowerCase();
    final parts = trimmedQuery.split(RegExp(r'\s+'));
    
    if (parts.isEmpty) {
      return SearchQuery(
        originalQuery: query,
        searchText: query.trim(),
        hasHymnalFilter: false,
      );
    }

    final firstWord = parts[0];
    
    // Check if first word is a hymnal abbreviation
    final hymnalAbbrev = _hymnalAbbreviations[firstWord];
    
    if (hymnalAbbrev != null) {
      // Found hymnal abbreviation
      if (parts.length == 1) {
        // Only hymnal abbreviation (e.g., "sdah")
        return SearchQuery(
          originalQuery: query,
          hymnalAbbreviation: hymnalAbbrev,
          searchText: '',
          hasHymnalFilter: true,
        );
      }
      
      // Check if second part is a number
      if (parts.length >= 2) {
        final secondWord = parts[1];
        final hymnNumber = int.tryParse(secondWord);
        
        if (hymnNumber != null) {
          // Hymnal abbreviation + number (e.g., "sdah 125")
          final remainingText = parts.length > 2 
              ? parts.sublist(2).join(' ')
              : '';
          
          return SearchQuery(
            originalQuery: query,
            hymnalAbbreviation: hymnalAbbrev,
            hymnNumber: hymnNumber,
            searchText: remainingText,
            hasHymnalFilter: true,
          );
        } else {
          // Hymnal abbreviation + text (e.g., "sdah amazing grace")
          final searchText = parts.sublist(1).join(' ');
          
          return SearchQuery(
            originalQuery: query,
            hymnalAbbreviation: hymnalAbbrev,
            searchText: searchText,
            hasHymnalFilter: true,
          );
        }
      }
    }
    
    // No hymnal abbreviation detected, treat as regular search
    return SearchQuery(
      originalQuery: query,
      searchText: query.trim(),
      hasHymnalFilter: false,
    );
  }

  /// Gets the normalized hymnal abbreviation for a given input
  /// Returns null if the input is not a recognized hymnal abbreviation
  static String? getHymnalAbbreviation(String input) {
    return _hymnalAbbreviations[input.toLowerCase()];
  }

  /// Gets all supported hymnal abbreviations
  static List<String> getSupportedHymnals() {
    return _hymnalAbbreviations.values.toSet().toList()..sort();
  }

  /// Checks if a string is a recognized hymnal abbreviation
  static bool isHymnalAbbreviation(String input) {
    return _hymnalAbbreviations.containsKey(input.toLowerCase());
  }
}