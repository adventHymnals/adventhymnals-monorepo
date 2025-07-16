import 'package:flutter_test/flutter_test.dart';
import '../../lib/core/utils/search_query_parser.dart';
import '../../lib/core/models/search_query.dart';

void main() {
  group('SearchQueryParser', () {
    test('should parse hymnal abbreviation only', () {
      final result = SearchQueryParser.parse('sdah');
      
      expect(result.originalQuery, 'sdah');
      expect(result.hymnalAbbreviation, 'SDAH');
      expect(result.hymnNumber, null);
      expect(result.searchText, '');
      expect(result.hasHymnalFilter, true);
    });

    test('should parse hymnal abbreviation with number', () {
      final result = SearchQueryParser.parse('sdah 125');
      
      expect(result.originalQuery, 'sdah 125');
      expect(result.hymnalAbbreviation, 'SDAH');
      expect(result.hymnNumber, 125);
      expect(result.searchText, '');
      expect(result.hasHymnalFilter, true);
    });

    test('should parse hymnal abbreviation with number and text', () {
      final result = SearchQueryParser.parse('sdah 125 amazing grace');
      
      expect(result.originalQuery, 'sdah 125 amazing grace');
      expect(result.hymnalAbbreviation, 'SDAH');
      expect(result.hymnNumber, 125);
      expect(result.searchText, 'amazing grace');
      expect(result.hasHymnalFilter, true);
    });

    test('should parse hymnal abbreviation with text only', () {
      final result = SearchQueryParser.parse('ch1941 amazing grace');
      
      expect(result.originalQuery, 'ch1941 amazing grace');
      expect(result.hymnalAbbreviation, 'CH1941');
      expect(result.hymnNumber, null);
      expect(result.searchText, 'amazing grace');
      expect(result.hasHymnalFilter, true);
    });

    test('should parse regular search without hymnal filter', () {
      final result = SearchQueryParser.parse('amazing grace');
      
      expect(result.originalQuery, 'amazing grace');
      expect(result.hymnalAbbreviation, null);
      expect(result.hymnNumber, null);
      expect(result.searchText, 'amazing grace');
      expect(result.hasHymnalFilter, false);
    });

    test('should handle empty query', () {
      final result = SearchQueryParser.parse('');
      
      expect(result.originalQuery, '');
      expect(result.hymnalAbbreviation, null);
      expect(result.hymnNumber, null);
      expect(result.searchText, '');
      expect(result.hasHymnalFilter, false);
    });

    test('should handle whitespace-only query', () {
      final result = SearchQueryParser.parse('   ');
      
      expect(result.originalQuery, '   ');
      expect(result.hymnalAbbreviation, null);
      expect(result.hymnNumber, null);
      expect(result.searchText, '');
      expect(result.hasHymnalFilter, false);
    });

    test('should be case insensitive for hymnal abbreviations', () {
      final result1 = SearchQueryParser.parse('SDAH 125');
      final result2 = SearchQueryParser.parse('sdah 125');
      final result3 = SearchQueryParser.parse('Sdah 125');
      
      expect(result1.hymnalAbbreviation, 'SDAH');
      expect(result2.hymnalAbbreviation, 'SDAH');
      expect(result3.hymnalAbbreviation, 'SDAH');
    });

    test('should handle different hymnal abbreviations', () {
      final testCases = [
        ('sda 100', 'SDAH'),
        ('ch 200', 'CH1941'),
        ('christ 300', 'CH1941'),
        ('adventist 400', 'SDAH'),
      ];

      for (final testCase in testCases) {
        final result = SearchQueryParser.parse(testCase.$1);
        expect(result.hymnalAbbreviation, testCase.$2, 
               reason: 'Failed for input: ${testCase.$1}');
      }
    });

    test('should get hymnal abbreviation correctly', () {
      expect(SearchQueryParser.getHymnalAbbreviation('sdah'), 'SDAH');
      expect(SearchQueryParser.getHymnalAbbreviation('ch1941'), 'CH1941');
      expect(SearchQueryParser.getHymnalAbbreviation('unknown'), null);
    });

    test('should check if string is hymnal abbreviation', () {
      expect(SearchQueryParser.isHymnalAbbreviation('sdah'), true);
      expect(SearchQueryParser.isHymnalAbbreviation('ch1941'), true);
      expect(SearchQueryParser.isHymnalAbbreviation('unknown'), false);
      expect(SearchQueryParser.isHymnalAbbreviation('amazing'), false);
    });

    test('should get supported hymnals', () {
      final hymnals = SearchQueryParser.getSupportedHymnals();
      expect(hymnals, contains('SDAH'));
      expect(hymnals, contains('CH1941'));
      expect(hymnals.length, greaterThan(0));
    });

    test('should handle extra whitespace', () {
      final result = SearchQueryParser.parse('  sdah   125   amazing grace  ');
      
      expect(result.hymnalAbbreviation, 'SDAH');
      expect(result.hymnNumber, 125);
      expect(result.searchText, 'amazing grace');
      expect(result.hasHymnalFilter, true);
    });
  });
}