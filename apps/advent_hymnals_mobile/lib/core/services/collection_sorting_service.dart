import 'package:shared_preferences/shared_preferences.dart';
import '../data/collections_data_manager.dart';

enum CollectionSortBy {
  title,
  year,
  language,
  hymnCount,
  alphabetical,
}

extension CollectionSortByExtension on CollectionSortBy {
  String get displayName {
    switch (this) {
      case CollectionSortBy.title:
        return 'Title';
      case CollectionSortBy.year:
        return 'Year';
      case CollectionSortBy.language:
        return 'Language';
      case CollectionSortBy.hymnCount:
        return 'Hymn Count';
      case CollectionSortBy.alphabetical:
        return 'Alphabetical';
    }
  }

  String get key {
    switch (this) {
      case CollectionSortBy.title:
        return 'title';
      case CollectionSortBy.year:
        return 'year';
      case CollectionSortBy.language:
        return 'language';
      case CollectionSortBy.hymnCount:
        return 'hymn_count';
      case CollectionSortBy.alphabetical:
        return 'alphabetical';
    }
  }
}

class CollectionSortingService {
  static const String _sortPreferenceKey = 'collection_sort_preference';
  static const CollectionSortBy _defaultSortBy = CollectionSortBy.title;

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
      case CollectionSortBy.title:
        sortedCollections.sort((a, b) => a.title.compareTo(b.title));
        break;
        
      case CollectionSortBy.year:
        sortedCollections.sort((a, b) {
          final yearComparison = b.year.compareTo(a.year); // Newest first
          return yearComparison != 0 ? yearComparison : a.title.compareTo(b.title);
        });
        break;
        
      case CollectionSortBy.language:
        sortedCollections.sort((a, b) {
          final languageComparison = a.language.compareTo(b.language);
          return languageComparison != 0 ? languageComparison : a.title.compareTo(b.title);
        });
        break;
        
      case CollectionSortBy.hymnCount:
        sortedCollections.sort((a, b) {
          final countComparison = b.hymnCount.compareTo(a.hymnCount); // Highest first
          return countComparison != 0 ? countComparison : a.title.compareTo(b.title);
        });
        break;
        
      case CollectionSortBy.alphabetical:
        sortedCollections.sort((a, b) => a.id.compareTo(b.id));
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