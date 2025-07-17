import 'package:shared_preferences/shared_preferences.dart';
import '../data/collections_data_manager.dart';

enum CollectionSortBy {
  titleAsc,
  titleDesc,
  yearAsc,
  yearDesc,
  languageAsc,
  languageDesc,
  hymnCountAsc,
  hymnCountDesc,
  abbreviationAsc,
  abbreviationDesc,
}

extension CollectionSortByExtension on CollectionSortBy {
  String get displayName {
    switch (this) {
      case CollectionSortBy.titleAsc:
        return 'Title (A-Z)';
      case CollectionSortBy.titleDesc:
        return 'Title (Z-A)';
      case CollectionSortBy.yearAsc:
        return 'Year (Oldest first)';
      case CollectionSortBy.yearDesc:
        return 'Year (Newest first)';
      case CollectionSortBy.languageAsc:
        return 'Language (A-Z)';
      case CollectionSortBy.languageDesc:
        return 'Language (Z-A)';
      case CollectionSortBy.hymnCountAsc:
        return 'Hymn Count (Fewest first)';
      case CollectionSortBy.hymnCountDesc:
        return 'Hymn Count (Most first)';
      case CollectionSortBy.abbreviationAsc:
        return 'Abbreviation (A-Z)';
      case CollectionSortBy.abbreviationDesc:
        return 'Abbreviation (Z-A)';
    }
  }

  String get key {
    switch (this) {
      case CollectionSortBy.titleAsc:
        return 'title_asc';
      case CollectionSortBy.titleDesc:
        return 'title_desc';
      case CollectionSortBy.yearAsc:
        return 'year_asc';
      case CollectionSortBy.yearDesc:
        return 'year_desc';
      case CollectionSortBy.languageAsc:
        return 'language_asc';
      case CollectionSortBy.languageDesc:
        return 'language_desc';
      case CollectionSortBy.hymnCountAsc:
        return 'hymn_count_asc';
      case CollectionSortBy.hymnCountDesc:
        return 'hymn_count_desc';
      case CollectionSortBy.abbreviationAsc:
        return 'abbreviation_asc';
      case CollectionSortBy.abbreviationDesc:
        return 'abbreviation_desc';
    }
  }
}

class CollectionSortingService {
  static const String _sortPreferenceKey = 'collection_sort_preference';
  static const CollectionSortBy _defaultSortBy = CollectionSortBy.titleAsc;

  /// Saves the user's sorting preference
  static Future<void> saveSortPreference(CollectionSortBy sortBy) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sortPreferenceKey, sortBy.key);
    } catch (e) {
      print('❌ [CollectionSortingService] Failed to save sort preference: $e');
    }
  }

  /// Loads the user's sorting preference
  static Future<CollectionSortBy> loadSortPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sortKey = prefs.getString(_sortPreferenceKey);
      
      if (sortKey != null) {
        return CollectionSortBy.values.firstWhere(
          (sortBy) => sortBy.key == sortKey,
          orElse: () => _defaultSortBy,
        );
      }
    } catch (e) {
      print('❌ [CollectionSortingService] Failed to load sort preference: $e');
    }
    
    return _defaultSortBy;
  }

  /// Sorts a list of collections based on the specified criteria
  static List<CollectionInfo> sortCollections(
    List<CollectionInfo> collections,
    CollectionSortBy sortBy,
  ) {
    final sortedCollections = List<CollectionInfo>.from(collections);
    
    switch (sortBy) {
      case CollectionSortBy.titleAsc:
        sortedCollections.sort((a, b) => a.title.compareTo(b.title));
        break;
      case CollectionSortBy.titleDesc:
        sortedCollections.sort((a, b) => b.title.compareTo(a.title));
        break;
        
      case CollectionSortBy.yearAsc:
        sortedCollections.sort((a, b) {
          final yearComparison = a.year.compareTo(b.year); // Oldest first
          return yearComparison != 0 ? yearComparison : a.title.compareTo(b.title);
        });
        break;
      case CollectionSortBy.yearDesc:
        sortedCollections.sort((a, b) {
          final yearComparison = b.year.compareTo(a.year); // Newest first
          return yearComparison != 0 ? yearComparison : a.title.compareTo(b.title);
        });
        break;
        
      case CollectionSortBy.languageAsc:
        sortedCollections.sort((a, b) {
          final languageComparison = a.language.compareTo(b.language);
          return languageComparison != 0 ? languageComparison : a.title.compareTo(b.title);
        });
        break;
      case CollectionSortBy.languageDesc:
        sortedCollections.sort((a, b) {
          final languageComparison = b.language.compareTo(a.language);
          return languageComparison != 0 ? languageComparison : a.title.compareTo(b.title);
        });
        break;
        
      case CollectionSortBy.hymnCountAsc:
        sortedCollections.sort((a, b) {
          final countComparison = a.hymnCount.compareTo(b.hymnCount); // Fewest first
          return countComparison != 0 ? countComparison : a.title.compareTo(b.title);
        });
        break;
      case CollectionSortBy.hymnCountDesc:
        sortedCollections.sort((a, b) {
          final countComparison = b.hymnCount.compareTo(a.hymnCount); // Most first
          return countComparison != 0 ? countComparison : a.title.compareTo(b.title);
        });
        break;
        
      case CollectionSortBy.abbreviationAsc:
        sortedCollections.sort((a, b) => a.id.compareTo(b.id));
        break;
      case CollectionSortBy.abbreviationDesc:
        sortedCollections.sort((a, b) => b.id.compareTo(a.id));
        break;
    }
    
    return sortedCollections;
  }

  /// Gets all available sorting options
  static List<CollectionSortBy> getAllSortOptions() {
    return CollectionSortBy.values;
  }

  /// Gets the default sorting option
  static CollectionSortBy getDefaultSortBy() {
    return _defaultSortBy;
  }
}