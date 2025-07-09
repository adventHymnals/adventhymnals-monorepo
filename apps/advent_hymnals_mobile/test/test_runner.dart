import 'package:flutter_test/flutter_test.dart';

// Import all test files
import 'widget_test.dart' as widget_test;
import 'integration_test.dart' as integration_test;
import 'browse_screens_test.dart' as browse_screens_test;
import 'navigation_test.dart' as navigation_test;
import 'search_test.dart' as search_test;

void main() {
  group('All Tests', () {
    group('Widget Tests', () {
      widget_test.main();
    });

    group('Integration Tests', () {
      integration_test.main();
    });

    group('Browse Screens Tests', () {
      browse_screens_test.main();
    });

    group('Navigation Tests', () {
      navigation_test.main();
    });

    group('Search Tests', () {
      search_test.main();
    });
  });
}