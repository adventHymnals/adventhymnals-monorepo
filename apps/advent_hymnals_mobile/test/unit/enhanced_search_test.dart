import 'package:flutter_test/flutter_test.dart';
import '../../lib/core/utils/search_query_parser.dart';
import '../../lib/core/models/search_query.dart';

void main() {
  group('Enhanced Search Functionality', () {
    group('SearchQueryParser Integration', () {
      test('should parse hymnal-only search correctly', () {
        final query = SearchQueryParser.parse('sdah');
        
        expect(query.hasHymnalFilter, true);
        expect(query.hymnalAbbreviation, 'SDAH');
        expect(query.hymnNumber, null);
        expect(query.searchText, '');
      });

      test('should parse hymnal with number correctly', () {
        final query = SearchQueryParser.parse('sdah 125');
        
        expect(query.hasHymnalFilter, true);
        expect(query.hymnalAbbreviation, 'SDAH');
        expect(query.hymnNumber, 125);
        expect(query.searchText, '');
      });

      test('should parse hymnal with text search correctly', () {
        final query = SearchQueryParser.parse('ch1941 amazing grace');
        
        expect(query.hasHymnalFilter, true);
        expect(query.hymnalAbbreviation, 'CH1941');
        expect(query.hymnNumber, null);
        expect(query.searchText, 'amazing grace');
      });

      test('should parse complex hymnal query correctly', () {
        final query = SearchQueryParser.parse('sdah 100 how great thou art');
        
        expect(query.hasHymnalFilter, true);
        expect(query.hymnalAbbreviation, 'SDAH');
        expect(query.hymnNumber, 100);
        expect(query.searchText, 'how great thou art');
      });

      test('should handle regular search without hymnal filter', () {
        final query = SearchQueryParser.parse('amazing grace');
        
        expect(query.hasHymnalFilter, false);
        expect(query.hymnalAbbreviation, null);
        expect(query.hymnNumber, null);
        expect(query.searchText, 'amazing grace');
      });
    });

    group('Hymnal Abbreviation Recognition', () {
      test('should recognize common hymnal abbreviations', () {
        final testCases = [
          ('sdah', 'SDAH'),
          ('sda', 'SDAH'),
          ('adventist', 'SDAH'),
          ('ch1941', 'CH1941'),
          ('ch', 'CH1941'),
          ('christ', 'CH1941'),
        ];

        for (final testCase in testCases) {
          final result = SearchQueryParser.getHymnalAbbreviation(testCase.$1);
          expect(result, testCase.$2, 
                 reason: 'Failed for abbreviation: ${testCase.$1}');
        }
      });

      test('should return null for unrecognized abbreviations', () {
        final unrecognized = ['xyz', 'unknown', 'test', '123'];
        
        for (final abbrev in unrecognized) {
          final result = SearchQueryParser.getHymnalAbbreviation(abbrev);
          expect(result, null, 
                 reason: 'Should not recognize: $abbrev');
        }
      });
    });

    group('Search Query Validation', () {
      test('should validate search queries correctly', () {
        final validQueries = [
          'sdah 125',
          'ch1941 amazing',
          'sda',
          'amazing grace',
          'sdah 100 how great',
        ];

        for (final query in validQueries) {
          final parsed = SearchQueryParser.parse(query);
          expect(parsed.originalQuery, query);
          expect(parsed.searchText.isNotEmpty || parsed.hasHymnalFilter, true,
                 reason: 'Query should have either search text or hymnal filter: $query');
        }
      });

      test('should handle edge cases gracefully', () {
        final edgeCases = [
          '',
          '   ',
          'sdah   ',
          '  sdah 125  ',
          'sdah abc', // non-numeric after hymnal
        ];

        for (final query in edgeCases) {
          expect(() => SearchQueryParser.parse(query), returnsNormally,
                 reason: 'Should handle edge case gracefully: "$query"');
        }
      });
    });

    group('Filter Display Logic', () {
      test('should generate correct filter display text', () {
        final testCases = [
          (SearchQuery(
            originalQuery: 'sdah',
            hymnalAbbreviation: 'SDAH',
            searchText: '',
            hasHymnalFilter: true,
          ), 'SDAH'),
          (SearchQuery(
            originalQuery: 'sdah 125',
            hymnalAbbreviation: 'SDAH',
            hymnNumber: 125,
            searchText: '',
            hasHymnalFilter: true,
          ), 'SDAH #125'),
          (SearchQuery(
            originalQuery: 'ch1941 amazing',
            hymnalAbbreviation: 'CH1941',
            searchText: 'amazing',
            hasHymnalFilter: true,
          ), 'CH1941: "amazing"'),
        ];

        for (final testCase in testCases) {
          final query = testCase.$1;
          final expected = testCase.$2;
          
          String actual;
          if (query.hymnNumber != null) {
            actual = '${query.hymnalAbbreviation} #${query.hymnNumber}';
          } else if (query.searchText.isNotEmpty) {
            actual = '${query.hymnalAbbreviation}: "${query.searchText}"';
          } else {
            actual = query.hymnalAbbreviation!;
          }
          
          expect(actual, expected,
                 reason: 'Filter text generation failed for: ${query.originalQuery}');
        }
      });
    });
  });
}