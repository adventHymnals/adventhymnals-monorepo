import 'package:flutter_test/flutter_test.dart';
import 'package:advent_hymnals/core/database/database_helper.dart';

void main() {
  group('Database Tests', () {
    test('Database initialization should work', () async {
      final db = DatabaseHelper.instance;
      
      try {
        // This should trigger the database initialization
        final database = await db.database;
        expect(database, isNotNull);
        
        // Close the database after test
        await db.closeDatabase();
      } catch (e) {
        print('Database error: $e');
        fail('Database initialization failed: $e');
      }
    });
  });
}