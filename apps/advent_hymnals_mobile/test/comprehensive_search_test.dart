import 'package:flutter_test/flutter_test.dart';
import 'package:advent_hymnals/core/utils/search_query_parser.dart';
import 'package:advent_hymnals/core/models/search_query.dart';

void main() {
  group('Comprehensive Search Tests - Based on User Issues', () {
    
    // Initialize Flutter binding before each test
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });
    
    // Clear cache before each test to ensure fresh state
    setUp(() {
      SearchQueryParser.clearCache();
    });

    group('🚨 Critical Abbreviation Recognition Tests', () {
      test('SDAH abbreviation should work (WORKING)', () async {
        final result = await SearchQueryParser.parse('sdah 125');
        
        expect(result.hymnalAbbreviation, equals('SDAH'));
        expect(result.hymnNumber, equals(125));
        expect(result.hasHymnalFilter, isTrue);
        expect(result.searchText, equals(''));
      });

      test('CH1941 abbreviation should work (WORKING)', () async {
        final result = await SearchQueryParser.parse('ch 200');
        
        expect(result.hymnalAbbreviation, equals('CH1941'));
        expect(result.hymnNumber, equals(200));
        expect(result.hasHymnalFilter, isTrue);
        expect(result.searchText, equals(''));
      });

      test('🚨 CS1900 abbreviation should work (CRITICAL - NEEDS FIX)', () async {
        // This is the specific case that was reported as not working
        final result = await SearchQueryParser.parse('cs1900 50');
        
        expect(result.hymnalAbbreviation, equals('CS1900'));
        expect(result.hymnNumber, equals(50));
        expect(result.hasHymnalFilter, isTrue);
        expect(result.searchText, equals(''));
      });

      test('CS short form should work', () async {
        final result = await SearchQueryParser.parse('cs 50');
        
        expect(result.hymnalAbbreviation, equals('CS1900'));
        expect(result.hymnNumber, equals(50));
        expect(result.hasHymnalFilter, isTrue);
        expect(result.searchText, equals(''));
      });

      test('All hymnal abbreviations should be recognized', () async {
        final testCases = [
          ('ht1869', 'HT1869'),
          ('ht1876', 'HT1876'),
          ('ht1886', 'HT1886'),
          ('cm2000', 'CM2000'),
          ('nzk', 'NZK'),
          ('wn', 'WN'),
          ('hfpf1838', 'HfPF1838'),
          ('mh1843', 'MH1843'),
          ('hgpp', 'HGPP'),
          ('hsab', 'HSAB'),
        ];

        for (final testCase in testCases) {
          final result = await SearchQueryParser.parse('${testCase.$1} 100');
          expect(result.hymnalAbbreviation, equals(testCase.$2), 
                 reason: 'Failed for ${testCase.$1} -> should be ${testCase.$2}');
          expect(result.hasHymnalFilter, isTrue);
          expect(result.hymnNumber, equals(100));
        }
      });

      test('Short form abbreviations should work', () async {
        final shortFormTests = [
          ('sda', 'SDAH'),
          ('ch', 'CH1941'),
          ('cs', 'CS1900'),
          ('ht', 'HT1886'), // Should map to the last one found
          ('cm', 'CM2000'),
        ];

        for (final testCase in shortFormTests) {
          final result = await SearchQueryParser.parse('${testCase.$1} 100');
          expect(result.hymnalAbbreviation, equals(testCase.$2), 
                 reason: 'Short form ${testCase.$1} should map to ${testCase.$2}');
          expect(result.hasHymnalFilter, isTrue);
          expect(result.hymnNumber, equals(100));
        }
      });

      test('Hymnal abbreviation only (no number) should work', () async {
        final result = await SearchQueryParser.parse('cs1900');
        
        expect(result.hymnalAbbreviation, equals('CS1900'));
        expect(result.hymnNumber, isNull);
        expect(result.hasHymnalFilter, isTrue);
        expect(result.searchText, equals(''));
      });

      test('Hymnal abbreviation with search text should work', () async {
        final result = await SearchQueryParser.parse('cs1900 amazing grace');
        
        expect(result.hymnalAbbreviation, equals('CS1900'));
        expect(result.hymnNumber, isNull);
        expect(result.hasHymnalFilter, isTrue);
        expect(result.searchText, equals('amazing grace'));
      });
    });

    group('🔍 Search Query Parsing Tests', () {
      test('Basic search without hymnal filter', () async {
        final result = await SearchQueryParser.parse('amazing grace');
        
        expect(result.originalQuery, equals('amazing grace'));
        expect(result.searchText, equals('amazing grace'));
        expect(result.hasHymnalFilter, isFalse);
        expect(result.hymnalAbbreviation, isNull);
        expect(result.hymnNumber, isNull);
      });

      test('Empty search query', () async {
        final result = await SearchQueryParser.parse('');
        
        expect(result.originalQuery, equals(''));
        expect(result.searchText, equals(''));
        expect(result.hasHymnalFilter, isFalse);
        expect(result.hymnalAbbreviation, isNull);
        expect(result.hymnNumber, isNull);
      });

      test('Whitespace-only query', () async {
        final result = await SearchQueryParser.parse('   ');
        
        expect(result.originalQuery, equals('   '));
        expect(result.searchText, equals(''));
        expect(result.hasHymnalFilter, isFalse);
        expect(result.hymnalAbbreviation, isNull);
        expect(result.hymnNumber, isNull);
      });

      test('Case insensitive abbreviation parsing', () async {
        final testCases = [
          'SDAH 125',
          'sdah 125',
          'Sdah 125',
          'SdAh 125',
        ];

        for (final testCase in testCases) {
          final result = await SearchQueryParser.parse(testCase);
          expect(result.hymnalAbbreviation, equals('SDAH'), 
                 reason: 'Case insensitive test failed for: $testCase');
          expect(result.hymnNumber, equals(125));
          expect(result.hasHymnalFilter, isTrue);
        }
      });

      test('Complex search queries with multiple parts', () async {
        final result = await SearchQueryParser.parse('sdah 125 amazing grace how sweet the sound');
        
        expect(result.hymnalAbbreviation, equals('SDAH'));
        expect(result.hymnNumber, equals(125));
        expect(result.searchText, equals('amazing grace how sweet the sound'));
        expect(result.hasHymnalFilter, isTrue);
      });

      test('Extra whitespace handling', () async {
        final result = await SearchQueryParser.parse('  sdah   125   amazing grace  ');
        
        expect(result.hymnalAbbreviation, equals('SDAH'));
        expect(result.hymnNumber, equals(125));
        expect(result.searchText, equals('amazing grace'));
        expect(result.hasHymnalFilter, isTrue);
      });
    });

    group('🔄 Synchronous Parser Tests', () {
      test('parseSync should work after caching', () async {
        // First, populate cache with async call
        await SearchQueryParser.parse('sdah 125');
        
        // Now test sync method
        final result = SearchQueryParser.parseSync('sdah 200');
        
        expect(result, isNotNull);
        expect(result!.hymnalAbbreviation, equals('SDAH'));
        expect(result.hymnNumber, equals(200));
        expect(result.hasHymnalFilter, isTrue);
      });

      test('parseSync should handle non-cached abbreviations gracefully', () {
        // Clear cache to test behavior without cache
        SearchQueryParser.clearCache();
        
        final result = SearchQueryParser.parseSync('sdah 125');
        
        // Without cache, should return basic query
        expect(result, isNotNull);
        expect(result!.searchText, equals('sdah 125'));
        expect(result.hasHymnalFilter, isFalse);
      });

      test('parseSync should handle empty query', () {
        final result = SearchQueryParser.parseSync('');
        
        expect(result, isNotNull);
        expect(result!.searchText, equals(''));
        expect(result.hasHymnalFilter, isFalse);
      });
    });

    group('📚 Hymnal Abbreviation Helper Methods', () {
      test('getHymnalAbbreviation should return correct abbreviation', () async {
        final abbreviations = [
          ('sdah', 'SDAH'),
          ('cs1900', 'CS1900'),
          ('ch1941', 'CH1941'),
          ('ch', 'CH1941'),
          ('cs', 'CS1900'),
          ('sda', 'SDAH'),
          ('invalid', null),
        ];

        for (final testCase in abbreviations) {
          final result = await SearchQueryParser.getHymnalAbbreviation(testCase.$1);
          expect(result, equals(testCase.$2), 
                 reason: 'getHymnalAbbreviation failed for ${testCase.$1}');
        }
      });

      test('isHymnalAbbreviation should correctly identify abbreviations', () async {
        final testCases = [
          ('sdah', true),
          ('SDAH', true),
          ('cs1900', true),
          ('CS1900', true),
          ('ch', true),
          ('cs', true),
          ('sda', true),
          ('invalid', false),
          ('amazing', false),
          ('grace', false),
          ('123', false),
        ];

        for (final testCase in testCases) {
          final result = await SearchQueryParser.isHymnalAbbreviation(testCase.$1);
          expect(result, equals(testCase.$2), 
                 reason: 'isHymnalAbbreviation failed for ${testCase.$1}');
        }
      });

      test('getSupportedHymnals should return all supported hymnals', () async {
        final hymnals = await SearchQueryParser.getSupportedHymnals();
        
        expect(hymnals, contains('SDAH'));
        expect(hymnals, contains('CS1900'));
        expect(hymnals, contains('CH1941'));
        expect(hymnals, contains('HT1869'));
        expect(hymnals, contains('HT1876'));
        expect(hymnals, contains('HT1886'));
        expect(hymnals, contains('CM2000'));
        expect(hymnals, contains('NZK'));
        expect(hymnals, contains('WN'));
        
        // Should be sorted
        final sortedHymnals = List<String>.from(hymnals)..sort();
        expect(hymnals, equals(sortedHymnals));
      });
    });

    group('⚡ Performance Tests', () {
      test('Search query parsing should be fast', () async {
        final stopwatch = Stopwatch()..start();
        
        // Parse 100 queries
        for (int i = 0; i < 100; i++) {
          await SearchQueryParser.parse('sdah $i amazing grace');
        }
        
        stopwatch.stop();
        
        // Should complete in less than 1 second
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });

      test('Sync parsing should be very fast', () async {
        // First populate cache
        await SearchQueryParser.parse('sdah 1');
        
        final stopwatch = Stopwatch()..start();
        
        // Parse 1000 queries synchronously
        for (int i = 0; i < 1000; i++) {
          SearchQueryParser.parseSync('sdah $i');
        }
        
        stopwatch.stop();
        
        // Should complete in less than 100ms
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });

      test('Abbreviation loading should be cached', () async {
        // First call should load from data
        final stopwatch1 = Stopwatch()..start();
        await SearchQueryParser.parse('sdah 1');
        stopwatch1.stop();
        
        // Second call should use cache
        final stopwatch2 = Stopwatch()..start();
        await SearchQueryParser.parse('sdah 2');
        stopwatch2.stop();
        
        // Second call should be faster (cached)
        expect(stopwatch2.elapsedMilliseconds, lessThanOrEqualTo(stopwatch1.elapsedMilliseconds));
      });
    });

    group('🐛 Edge Cases and Error Handling', () {
      test('Invalid hymn numbers should be handled gracefully', () async {
        final result = await SearchQueryParser.parse('sdah abc');
        
        expect(result.hymnalAbbreviation, equals('SDAH'));
        expect(result.hymnNumber, isNull);
        expect(result.searchText, equals('abc'));
        expect(result.hasHymnalFilter, isTrue);
      });

      test('Very long search queries should be handled', () async {
        final longQuery = 'sdah 125 ' + 'amazing grace ' * 50;
        final result = await SearchQueryParser.parse(longQuery);
        
        expect(result.hymnalAbbreviation, equals('SDAH'));
        expect(result.hymnNumber, equals(125));
        expect(result.hasHymnalFilter, isTrue);
        expect(result.searchText, isNotEmpty);
      });

      test('Special characters in search should be handled', () async {
        final result = await SearchQueryParser.parse('sdah 125 amazing grace!@#\$%^&*()');
        
        expect(result.hymnalAbbreviation, equals('SDAH'));
        expect(result.hymnNumber, equals(125));
        expect(result.searchText, equals('amazing grace!@#\$%^&*()'));
        expect(result.hasHymnalFilter, isTrue);
      });

      test('Unicode characters should be handled', () async {
        final result = await SearchQueryParser.parse('sdah 125 ámázing grácé');
        
        expect(result.hymnalAbbreviation, equals('SDAH'));
        expect(result.hymnNumber, equals(125));
        expect(result.searchText, equals('ámázing grácé'));
        expect(result.hasHymnalFilter, isTrue);
      });

      test('Numbers in search text should not be confused with hymn numbers', () async {
        final result = await SearchQueryParser.parse('sdah psalm 23');
        
        expect(result.hymnalAbbreviation, equals('SDAH'));
        expect(result.hymnNumber, isNull);
        expect(result.searchText, equals('psalm 23'));
        expect(result.hasHymnalFilter, isTrue);
      });
    });

    group('🎯 Specific User-Reported Issues', () {
      test('🚨 CRITICAL: cs1900 should work in search (User Issue)', () async {
        // This is the specific case reported by user
        final result = await SearchQueryParser.parse('cs1900');
        
        expect(result.hymnalAbbreviation, equals('CS1900'));
        expect(result.hasHymnalFilter, isTrue);
        expect(result.searchText, equals(''));
      });

      test('🚨 CRITICAL: cs1900 with hymn number should work (User Issue)', () async {
        final result = await SearchQueryParser.parse('cs1900 50');
        
        expect(result.hymnalAbbreviation, equals('CS1900'));
        expect(result.hymnNumber, equals(50));
        expect(result.hasHymnalFilter, isTrue);
        expect(result.searchText, equals(''));
      });

      test('Favorites only + search should work (User Issue)', () async {
        // This should be tested in integration with favorites filter
        final result = await SearchQueryParser.parse('19');
        
        expect(result.searchText, equals('19'));
        expect(result.hasHymnalFilter, isFalse);
        // The favorites filter should be applied separately in the search logic
      });

      test('Author search should be supported (User Requirement)', () async {
        // This tests that author names are treated as regular search text
        final result = await SearchQueryParser.parse('John Newton');
        
        expect(result.searchText, equals('John Newton'));
        expect(result.hasHymnalFilter, isFalse);
        expect(result.hymnalAbbreviation, isNull);
      });

      test('Dynamic abbreviation loading should work (User Requirement)', () async {
        // Test that abbreviations are loaded dynamically, not hardcoded
        final allAbbreviations = await SearchQueryParser.getSupportedHymnals();
        
        // Should contain all 13 hymnals mentioned in collections data
        expect(allAbbreviations.length, greaterThanOrEqualTo(13));
        
        // Should contain all the specific ones mentioned
        final expectedHymnals = [
          'SDAH', 'CS1900', 'CH1941', 'HT1869', 'HT1876', 'HT1886',
          'CM2000', 'NZK', 'WN', 'HfPF1838', 'MH1843', 'HGPP', 'HSAB'
        ];
        
        for (final hymnal in expectedHymnals) {
          expect(allAbbreviations, contains(hymnal), 
                 reason: 'Missing hymnal: $hymnal');
        }
      });

      test('Case insensitive abbreviation matching (User Requirement)', () async {
        final testCases = [
          'sdah',
          'SDAH',
          'Sdah',
          'SdAh',
          'cs1900',
          'CS1900',
          'Cs1900',
          'ch1941',
          'CH1941',
          'Ch1941',
        ];

        for (final testCase in testCases) {
          final result = await SearchQueryParser.parse(testCase);
          expect(result.hasHymnalFilter, isTrue, 
                 reason: 'Case insensitive test failed for: $testCase');
        }
      });
    });

    group('🧪 Integration Tests', () {
      test('Cache clearing should work correctly', () async {
        // Load abbreviations
        await SearchQueryParser.parse('sdah 1');
        
        // Clear cache
        SearchQueryParser.clearCache();
        
        // Sync parsing should fail without cache
        final result = SearchQueryParser.parseSync('sdah 1');
        expect(result!.hasHymnalFilter, isFalse);
      });

      test('Multiple async calls should work correctly', () async {
        final futures = <Future<SearchQuery>>[];
        
        for (int i = 0; i < 10; i++) {
          futures.add(SearchQueryParser.parse('sdah $i'));
        }
        
        final results = await Future.wait(futures);
        
        for (int i = 0; i < 10; i++) {
          expect(results[i].hymnalAbbreviation, equals('SDAH'));
          expect(results[i].hymnNumber, equals(i));
          expect(results[i].hasHymnalFilter, isTrue);
        }
      });
    });
  });
}