import 'package:flutter_test/flutter_test.dart';
import 'package:advent_hymnals/core/utils/search_query_parser.dart';
import 'package:advent_hymnals/core/models/search_query.dart';

void main() {
  group('Basic Search Query Parser Tests', () {
    
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      SearchQueryParser.clearCache();
    });

    test('Should handle empty query', () async {
      final result = await SearchQueryParser.parse('');
      
      expect(result.originalQuery, equals(''));
      expect(result.searchText, equals(''));
      expect(result.hasHymnalFilter, isFalse);
      expect(result.hymnalAbbreviation, isNull);
      expect(result.hymnNumber, isNull);
    });

    test('Should handle regular text search', () async {
      final result = await SearchQueryParser.parse('amazing grace');
      
      expect(result.originalQuery, equals('amazing grace'));
      expect(result.searchText, equals('amazing grace'));
      expect(result.hasHymnalFilter, isFalse);
      expect(result.hymnalAbbreviation, isNull);
      expect(result.hymnNumber, isNull);
    });

    test('Should handle number-only search', () async {
      final result = await SearchQueryParser.parse('125');
      
      expect(result.originalQuery, equals('125'));
      expect(result.searchText, equals('125'));
      expect(result.hasHymnalFilter, isFalse);
      expect(result.hymnalAbbreviation, isNull);
      expect(result.hymnNumber, isNull);
    });

    test('Should handle whitespace-only query', () async {
      final result = await SearchQueryParser.parse('   ');
      
      expect(result.originalQuery, equals('   '));
      expect(result.searchText, equals(''));
      expect(result.hasHymnalFilter, isFalse);
      expect(result.hymnalAbbreviation, isNull);
      expect(result.hymnNumber, isNull);
    });

    test('Should handle complex search terms', () async {
      final result = await SearchQueryParser.parse('holy holy holy');
      
      expect(result.originalQuery, equals('holy holy holy'));
      expect(result.searchText, equals('holy holy holy'));
      expect(result.hasHymnalFilter, isFalse);
      expect(result.hymnalAbbreviation, isNull);
      expect(result.hymnNumber, isNull);
    });

    test('Should handle special characters', () async {
      final result = await SearchQueryParser.parse('grace!@#\$%');
      
      expect(result.originalQuery, equals('grace!@#\$%'));
      expect(result.searchText, equals('grace!@#\$%'));
      expect(result.hasHymnalFilter, isFalse);
      expect(result.hymnalAbbreviation, isNull);
      expect(result.hymnNumber, isNull);
    });

    test('Should handle sync parser with empty cache', () {
      final result = SearchQueryParser.parseSync('test query');
      
      expect(result, isNotNull);
      expect(result!.originalQuery, equals('test query'));
      expect(result.searchText, equals('test query'));
      expect(result.hasHymnalFilter, isFalse);
      expect(result.hymnalAbbreviation, isNull);
      expect(result.hymnNumber, isNull);
    });

    test('Cache clearing should work', () async {
      // This should work regardless of whether data can be loaded
      SearchQueryParser.clearCache();
      
      final result = await SearchQueryParser.parse('test');
      expect(result.originalQuery, equals('test'));
    });
  });
}