import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../../lib/core/services/collection_sorting_service.dart';
import '../../lib/core/data/collections_data_manager.dart';

void main() {
  group('CollectionSortingService', () {
    late List<CollectionInfo> testCollections;

    setUp(() {
      testCollections = [
        CollectionInfo(
          id: 'SDAH',
          title: 'Seventh-day Adventist Hymnal',
          subtitle: 'Official SDA Hymnal',
          description: 'The official hymnal of the Seventh-day Adventist Church',
          color: Colors.blue,
          language: 'English',
          hymnCount: 695,
          isAvailable: true,
          bundled: true,
          year: 1985,
        ),
        CollectionInfo(
          id: 'CH1941',
          title: 'Christ in Song',
          subtitle: 'Historic Hymnal',
          description: 'Historic Adventist hymnal from 1941',
          color: Colors.green,
          language: 'English',
          hymnCount: 640,
          isAvailable: true,
          bundled: false,
          year: 1941,
        ),
        CollectionInfo(
          id: 'GOSPEL',
          title: 'Gospel Songs',
          subtitle: 'Contemporary Collection',
          description: 'Modern gospel songs collection',
          color: Colors.orange,
          language: 'English',
          hymnCount: 200,
          isAvailable: true,
          bundled: true,
          year: 2020,
        ),
        CollectionInfo(
          id: 'KISWAHILI',
          title: 'Nyimbo za Kristo',
          subtitle: 'Swahili Hymnal',
          description: 'Swahili language hymnal',
          color: Colors.purple,
          language: 'Kiswahili',
          hymnCount: 450,
          isAvailable: true,
          bundled: false,
          year: 1995,
        ),
      ];
    });

    group('Sorting by Title', () {
      test('should sort collections by title alphabetically', () {
        final sorted = CollectionSortingService.sortCollections(
          testCollections,
          CollectionSortBy.title,
        );

        expect(sorted[0].title, 'Christ in Song');
        expect(sorted[1].title, 'Gospel Songs');
        expect(sorted[2].title, 'Nyimbo za Kristo');
        expect(sorted[3].title, 'Seventh-day Adventist Hymnal');
      });
    });

    group('Sorting by Year', () {
      test('should sort collections by year (newest first)', () {
        final sorted = CollectionSortingService.sortCollections(
          testCollections,
          CollectionSortBy.year,
        );

        expect(sorted[0].year, 2020); // Gospel Songs
        expect(sorted[1].year, 1995); // Nyimbo za Kristo
        expect(sorted[2].year, 1985); // SDAH
        expect(sorted[3].year, 1941); // Christ in Song
      });

      test('should use title as secondary sort for same year', () {
        // Add another collection with same year as SDAH
        final collectionsWithSameYear = [
          ...testCollections,
          CollectionInfo(
            id: 'TEST',
            title: 'Another 1985 Hymnal',
            subtitle: 'Test',
            description: 'Test hymnal',
            color: Colors.red,
            language: 'English',
            hymnCount: 100,
            isAvailable: true,
            bundled: true,
            year: 1985,
          ),
        ];

        final sorted = CollectionSortingService.sortCollections(
          collectionsWithSameYear,
          CollectionSortBy.year,
        );

        // Find the 1985 collections
        final year1985Collections = sorted.where((c) => c.year == 1985).toList();
        expect(year1985Collections[0].title, 'Another 1985 Hymnal');
        expect(year1985Collections[1].title, 'Seventh-day Adventist Hymnal');
      });
    });

    group('Sorting by Language', () {
      test('should sort collections by language alphabetically', () {
        final sorted = CollectionSortingService.sortCollections(
          testCollections,
          CollectionSortBy.language,
        );

        // English collections should come first, then Kiswahili
        final englishCollections = sorted.where((c) => c.language == 'English').toList();
        final kiswahiliCollections = sorted.where((c) => c.language == 'Kiswahili').toList();

        expect(englishCollections.length, 3);
        expect(kiswahiliCollections.length, 1);
        expect(sorted.indexOf(englishCollections[0]) < sorted.indexOf(kiswahiliCollections[0]), true);
      });
    });

    group('Sorting by Hymn Count', () {
      test('should sort collections by hymn count (highest first)', () {
        final sorted = CollectionSortingService.sortCollections(
          testCollections,
          CollectionSortBy.hymnCount,
        );

        expect(sorted[0].hymnCount, 695); // SDAH
        expect(sorted[1].hymnCount, 640); // Christ in Song
        expect(sorted[2].hymnCount, 450); // Nyimbo za Kristo
        expect(sorted[3].hymnCount, 200); // Gospel Songs
      });
    });

    group('Sorting by Alphabetical (ID)', () {
      test('should sort collections by ID alphabetically', () {
        final sorted = CollectionSortingService.sortCollections(
          testCollections,
          CollectionSortBy.alphabetical,
        );

        expect(sorted[0].id, 'CH1941');
        expect(sorted[1].id, 'GOSPEL');
        expect(sorted[2].id, 'KISWAHILI');
        expect(sorted[3].id, 'SDAH');
      });
    });

    group('Sort Options', () {
      test('should return all available sort options', () {
        final options = CollectionSortingService.getAllSortOptions();
        
        expect(options.length, 5);
        expect(options, contains(CollectionSortBy.title));
        expect(options, contains(CollectionSortBy.year));
        expect(options, contains(CollectionSortBy.language));
        expect(options, contains(CollectionSortBy.hymnCount));
        expect(options, contains(CollectionSortBy.alphabetical));
      });

      test('should return correct default sort option', () {
        final defaultSort = CollectionSortingService.getDefaultSortBy();
        expect(defaultSort, CollectionSortBy.title);
      });
    });

    group('Sort Display Names', () {
      test('should return correct display names for sort options', () {
        expect(CollectionSortBy.title.displayName, 'Title');
        expect(CollectionSortBy.year.displayName, 'Year');
        expect(CollectionSortBy.language.displayName, 'Language');
        expect(CollectionSortBy.hymnCount.displayName, 'Hymn Count');
        expect(CollectionSortBy.alphabetical.displayName, 'Alphabetical');
      });

      test('should return correct keys for sort options', () {
        expect(CollectionSortBy.title.key, 'title');
        expect(CollectionSortBy.year.key, 'year');
        expect(CollectionSortBy.language.key, 'language');
        expect(CollectionSortBy.hymnCount.key, 'hymn_count');
        expect(CollectionSortBy.alphabetical.key, 'alphabetical');
      });
    });

    group('Edge Cases', () {
      test('should handle empty collection list', () {
        final sorted = CollectionSortingService.sortCollections(
          [],
          CollectionSortBy.title,
        );

        expect(sorted, isEmpty);
      });

      test('should handle single collection', () {
        final singleCollection = [testCollections[0]];
        final sorted = CollectionSortingService.sortCollections(
          singleCollection,
          CollectionSortBy.title,
        );

        expect(sorted.length, 1);
        expect(sorted[0], testCollections[0]);
      });

      test('should not modify original list', () {
        final originalOrder = List<CollectionInfo>.from(testCollections);
        
        CollectionSortingService.sortCollections(
          testCollections,
          CollectionSortBy.year,
        );

        // Original list should remain unchanged
        for (int i = 0; i < testCollections.length; i++) {
          expect(testCollections[i].id, originalOrder[i].id);
        }
      });
    });
  });
}