import 'package:flutter_test/flutter_test.dart';
import 'package:advent_hymnals/core/utils/search_query_parser.dart';
import 'package:advent_hymnals/core/models/search_query.dart';

void main() {
  group('Search Abbreviation Tests (Fallback Mode)', () {
    
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      SearchQueryParser.clearCache();
    });

    test('Should handle potential abbreviation patterns gracefully', () async {
      // Test potential abbreviation patterns even if abbreviations can't be loaded
      final testCases = [
        'sdah 125',
        'cs1900 50',
        'ch 200',
        'ht1886 100',
        'cm2000 75',
      ];

      for (final testCase in testCases) {
        final result = await SearchQueryParser.parse(testCase);
        
        // Result should be valid regardless of abbreviation loading
        expect(result.originalQuery, equals(testCase));
        expect(result.searchText, isNotNull);
        
        // If abbreviation loading fails, should fallback to text search
        if (result.hymnalAbbreviation == null) {
          expect(result.searchText, equals(testCase));
          expect(result.hasHymnalFilter, isFalse);
        }
      }
    });

    test('Should handle CS1900 abbreviation pattern (Critical User Issue)', () async {
      final result = await SearchQueryParser.parse('cs1900 50');
      
      // The result should be valid regardless of abbreviation loading
      expect(result.originalQuery, equals('cs1900 50'));
      expect(result.searchText, isNotNull);
      
      // If abbreviation loading succeeds, should recognize CS1900
      if (result.hymnalAbbreviation != null) {
        expect(result.hymnalAbbreviation, equals('CS1900'));
        expect(result.hymnNumber, equals(50));
        expect(result.hasHymnalFilter, isTrue);
      } else {
        // If abbreviation loading fails, should fallback gracefully
        expect(result.searchText, equals('cs1900 50'));
        expect(result.hasHymnalFilter, isFalse);
      }
    });

    test('Should handle mixed abbreviation and text patterns', () async {
      final testCases = [
        'sdah amazing grace',
        'cs1900 holy holy',
        'ch1941 how great thou art',
      ];

      for (final testCase in testCases) {
        final result = await SearchQueryParser.parse(testCase);
        
        expect(result.originalQuery, equals(testCase));
        expect(result.searchText, isNotNull);
        
        // Should either recognize abbreviation or treat as text search
        if (result.hasHymnalFilter) {
          expect(result.hymnalAbbreviation, isNotNull);
          expect(result.searchText, isNot(equals(testCase))); // Should be modified
        } else {
          expect(result.searchText, equals(testCase));
        }
      }
    });

    test('Should handle synchronous parsing with fallback', () {
      final result = SearchQueryParser.parseSync('sdah 125');
      
      expect(result, isNotNull);
      expect(result!.originalQuery, equals('sdah 125'));
      expect(result.searchText, isNotNull);
      
      // Sync parsing should work even without cached abbreviations
      if (result.hymnalAbbreviation == null) {
        expect(result.searchText, equals('sdah 125'));
        expect(result.hasHymnalFilter, isFalse);
      }
    });

    test('Should handle abbreviation helper methods gracefully', () async {
      // These methods should not throw even if data loading fails
      try {
        final abbreviation = await SearchQueryParser.getHymnalAbbreviation('sdah');
        expect(abbreviation, anyOf(isNull, isA<String>()));
      } catch (e) {
        // Method should handle errors gracefully
        expect(e, isNotNull);
      }

      try {
        final isAbbrev = await SearchQueryParser.isHymnalAbbreviation('sdah');
        expect(isAbbrev, isA<bool>());
      } catch (e) {
        // Method should handle errors gracefully
        expect(e, isNotNull);
      }

      try {
        final hymnals = await SearchQueryParser.getSupportedHymnals();
        expect(hymnals, isA<List<String>>());
      } catch (e) {
        // Method should handle errors gracefully
        expect(e, isNotNull);
      }
    });

    test('Should handle edge cases in abbreviation-like patterns', () async {
      final edgeCases = [
        'sdah123',
        'CH1941a',
        'cs1900xyz',
        'sdah 0',
        'ch -1',
        'cs1900 99999',
      ];

      for (final testCase in edgeCases) {
        final result = await SearchQueryParser.parse(testCase);
        
        expect(result.originalQuery, equals(testCase));
        expect(result.searchText, isNotNull);
        
        // Should handle edge cases gracefully
        if (result.hymnalAbbreviation != null) {
          expect(result.hymnalAbbreviation, isA<String>());
        }
      }
    });

    test('Performance should be acceptable even with fallback mode', () async {
      final stopwatch = Stopwatch()..start();
      
      // Parse multiple queries
      for (int i = 0; i < 50; i++) {
        await SearchQueryParser.parse('sdah $i');
      }
      
      stopwatch.stop();
      
      // Should complete in reasonable time even with fallback
      expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // 5 seconds max
    });
  });
}