import '../models/search_query.dart';
import '../data/collections_data_manager.dart';

class SearchQueryParser {
  static Map<String, String>? _cachedAbbreviations;
  static final CollectionsDataManager _collectionsManager = CollectionsDataManager();

  /// Get hymnal abbreviations (cached)
  static Future<Map<String, String>> _getHymnalAbbreviations() async {
    if (_cachedAbbreviations != null) {
      return _cachedAbbreviations!;
    }
    
    _cachedAbbreviations = await _collectionsManager.getHymnalAbbreviations();
    print('🔍 [SearchQueryParser] Cached ${_cachedAbbreviations!.length} abbreviations');
    return _cachedAbbreviations!;
  }

  /// Parses a search query to extract hymnal abbreviation, hymn number, and search text
  /// 
  /// Examples:
  /// - "sdah 125" -> SearchQuery(hymnalAbbreviation: "SDAH", hymnNumber: 125, searchText: "")
  /// - "ch1941 amazing grace" -> SearchQuery(hymnalAbbreviation: "CH1941", hymnNumber: null, searchText: "amazing grace")
  /// - "sdah" -> SearchQuery(hymnalAbbreviation: "SDAH", hymnNumber: null, searchText: "")
  /// - "amazing grace" -> SearchQuery(hymnalAbbreviation: null, hymnNumber: null, searchText: "amazing grace")
  static Future<SearchQuery> parse(String query) async {
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
    
    // Get dynamic hymnal abbreviations
    final hymnalAbbreviations = await _getHymnalAbbreviations();
    
    // Check if first word is a hymnal abbreviation
    final hymnalAbbrev = hymnalAbbreviations[firstWord];
    
    print('🔍 [SearchQueryParser] Checking "$firstWord" against ${hymnalAbbreviations.length} abbreviations. Found: $hymnalAbbrev');
    
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
  static Future<String?> getHymnalAbbreviation(String input) async {
    final abbreviations = await _getHymnalAbbreviations();
    return abbreviations[input.toLowerCase()];
  }

  /// Gets all supported hymnal abbreviations
  static Future<List<String>> getSupportedHymnals() async {
    final abbreviations = await _getHymnalAbbreviations();
    return abbreviations.values.toSet().toList()..sort();
  }

  /// Checks if a string is a recognized hymnal abbreviation
  static Future<bool> isHymnalAbbreviation(String input) async {
    final abbreviations = await _getHymnalAbbreviations();
    return abbreviations.containsKey(input.toLowerCase());
  }

  /// Synchronous parse method using cached abbreviations (for UI contexts)
  /// Returns null if abbreviations not cached yet
  static SearchQuery? parseSync(String query) {
    if (_cachedAbbreviations == null) {
      // No cached abbreviations available, return basic query
      print('⚠️ [SearchQueryParser] parseSync called but no cached abbreviations available');
      return SearchQuery(
        originalQuery: query,
        searchText: query.trim(),
        hasHymnalFilter: false,
      );
    }
    
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
    final hymnalAbbrev = _cachedAbbreviations![firstWord];
    
    print('🔍 [SearchQueryParser] parseSync checking "$firstWord" against cached abbreviations. Found: $hymnalAbbrev');
    
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

  /// Clear cached abbreviations to force reload
  static void clearCache() {
    _cachedAbbreviations = null;
  }
}