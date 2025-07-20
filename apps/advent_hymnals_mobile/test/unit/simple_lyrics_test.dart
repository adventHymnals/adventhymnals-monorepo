import 'package:flutter_test/flutter_test.dart';
import '../../lib/core/utils/lyrics_parser.dart';

void main() {
  test('LyricsSection should create verse correctly', () {
    final section = LyricsSection.verse(1, 'Amazing grace');
    expect(section.type, equals('verse'));
    expect(section.number, equals(1));
    expect(section.content, equals('Amazing grace'));
  });
}