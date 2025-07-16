import 'package:flutter_test/flutter_test.dart';
import '../../lib/core/utils/lyrics_parser.dart';

void main() {
  group('LyricsSection', () {
    test('should create verse section correctly', () {
      final section = LyricsSection.verse(1, 'Amazing grace, how sweet the sound');
      
      expect(section.type, equals('verse'));
      expect(section.number, equals(1));
      expect(section.content, equals('Amazing grace, how sweet the sound'));
      expect(section.repeatAfterVerse, isFalse);
      expect(section.displayLabel, equals('Verse 1'));
      expect(section.isVerse, isTrue);
      expect(section.isChorus, isFalse);
    });

    test('should create chorus section correctly', () {
      final section = LyricsSection.chorus('Praise the Lord, praise the Lord');
      
      expect(section.type, equals('chorus'));
      expect(section.number, equals(1));
      expect(section.content, equals('Praise the Lord, praise the Lord'));
      expect(section.repeatAfterVerse, isTrue);
      expect(section.displayLabel, equals('Chorus'));
      expect(section.isChorus, isTrue);
      expect(section.isVerse, isFalse);
    });

    test('should create refrain section correctly', () {
      final section = LyricsSection.refrain('Holy, holy, holy');
      
      expect(section.type, equals('refrain'));
      expect(section.displayLabel, equals('Refrain'));
      expect(section.isRefrain, isTrue);
    });

    test('should create bridge section correctly', () {
      final section = LyricsSection.bridge('When we all get to heaven');
      
      expect(section.type, equals('bridge'));
      expect(section.displayLabel, equals('Bridge'));
      expect(section.isBridge, isTrue);
    });
  });

  group('LyricsParser', () {
    test('should parse simple verse-only lyrics', () {
      const lyrics = '''Amazing grace, how sweet the sound
That saved a wretch like me

I once was lost, but now am found
Was blind, but now I see''';

      final sections = LyricsParser.parseLyrics(lyrics);
      
      expect(sections.length, equals(2));
      expect(sections[0].isVerse, isTrue);
      expect(sections[0].number, equals(1));
      expect(sections[0].content, contains('Amazing grace'));
      expect(sections[1].isVerse, isTrue);
      expect(sections[1].number, equals(2));
      expect(sections[1].content, contains('I once was lost'));
    });

    test('should parse lyrics with explicit verse labels', () {
      const lyrics = '''Verse 1:
Amazing grace, how sweet the sound
That saved a wretch like me

Verse 2:
I once was lost, but now am found
Was blind, but now I see''';

      final sections = LyricsParser.parseLyrics(lyrics);
      
      expect(sections.length, equals(2));
      expect(sections[0].isVerse, isTrue);
      expect(sections[0].content, equals('Amazing grace, how sweet the sound\nThat saved a wretch like me'));
      expect(sections[1].isVerse, isTrue);
      expect(sections[1].content, equals('I once was lost, but now am found\nWas blind, but now I see'));
    });

    test('should parse lyrics with chorus', () {
      const lyrics = '''Amazing grace, how sweet the sound
That saved a wretch like me

Chorus:
Praise the Lord, praise the Lord
Let the earth hear His voice

I once was lost, but now am found
Was blind, but now I see''';

      final sections = LyricsParser.parseLyrics(lyrics);
      
      expect(sections.length, equals(3));
      expect(sections[0].isVerse, isTrue);
      expect(sections[1].isChorus, isTrue);
      expect(sections[1].content, equals('Praise the Lord, praise the Lord\nLet the earth hear His voice'));
      expect(sections[2].isVerse, isTrue);
    });

    test('should parse lyrics with refrain', () {
      const lyrics = '''Holy, holy, holy! Lord God Almighty!
Early in the morning our song shall rise to Thee

Refrain:
Holy, holy, holy! merciful and mighty!
God in three Persons, blessed Trinity!

Holy, holy, holy! All the saints adore Thee
Casting down their golden crowns around the glassy sea''';

      final sections = LyricsParser.parseLyrics(lyrics);
      
      expect(sections.length, equals(3));
      expect(sections[0].isVerse, isTrue);
      expect(sections[1].isRefrain, isTrue);
      expect(sections[1].content, contains('merciful and mighty'));
      expect(sections[2].isVerse, isTrue);
    });

    test('should detect likely chorus without explicit label', () {
      const lyrics = '''Amazing grace, how sweet the sound
That saved a wretch like me
I once was lost, but now am found
Was blind, but now I see

Praise Him, praise Him
Jesus our blessed Redeemer

Through many dangers, toils and snares
I have already come
'Tis grace that brought me safe thus far
And grace will lead me home''';

      final sections = LyricsParser.parseLyrics(lyrics);
      
      expect(sections.length, equals(3));
      expect(sections[0].isVerse, isTrue);
      expect(sections[1].isChorus, isTrue);
      expect(sections[1].content, equals('Praise Him, praise Him\nJesus our blessed Redeemer'));
      expect(sections[2].isVerse, isTrue);
    });

    test('should handle numbered verse format', () {
      const lyrics = '''1. Amazing grace, how sweet the sound
That saved a wretch like me

2. I once was lost, but now am found
Was blind, but now I see

3. Through many dangers, toils and snares
I have already come''';

      final sections = LyricsParser.parseLyrics(lyrics);
      
      expect(sections.length, equals(3));
      expect(sections[0].isVerse, isTrue);
      expect(sections[0].number, equals(1));
      expect(sections[0].content, equals('Amazing grace, how sweet the sound\nThat saved a wretch like me'));
      expect(sections[1].isVerse, isTrue);
      expect(sections[1].number, equals(2));
      expect(sections[2].isVerse, isTrue);
      expect(sections[2].number, equals(3));
    });

    test('should handle bridge sections', () {
      const lyrics = '''Amazing grace, how sweet the sound
That saved a wretch like me

Bridge:
When we've been there ten thousand years
Bright shining as the sun

I once was lost, but now am found
Was blind, but now I see''';

      final sections = LyricsParser.parseLyrics(lyrics);
      
      expect(sections.length, equals(3));
      expect(sections[0].isVerse, isTrue);
      expect(sections[1].isBridge, isTrue);
      expect(sections[1].content, contains('ten thousand years'));
      expect(sections[2].isVerse, isTrue);
    });

    test('should handle empty or whitespace-only lyrics', () {
      expect(LyricsParser.parseLyrics(''), isEmpty);
      expect(LyricsParser.parseLyrics('   \n\n  '), isEmpty);
    });

    test('should clean section content properly', () {
      const lyrics = '''Verse 1:
Amazing grace, how sweet the sound


Chorus:
Praise the Lord

Verse 2:
I once was lost''';

      final sections = LyricsParser.parseLyrics(lyrics);
      
      expect(sections.length, equals(3));
      expect(sections[0].content, equals('Amazing grace, how sweet the sound'));
      expect(sections[1].content, equals('Praise the Lord'));
      expect(sections[2].content, equals('I once was lost'));
    });
  });

  group('LyricsParser.parseStructuredLyrics', () {
    test('should parse structured hymn data with verses and refrain', () {
      final hymnData = {
        'verses': [
          {'text': 'Amazing grace, how sweet the sound\nThat saved a wretch like me'},
          {'text': 'I once was lost, but now am found\nWas blind, but now I see'},
        ],
        'refrain': {
          'text': 'Praise the Lord, praise the Lord\nLet the earth hear His voice'
        }
      };

      final sections = LyricsParser.parseStructuredLyrics(hymnData);
      
      expect(sections.length, equals(3));
      expect(sections[0].isVerse, isTrue);
      expect(sections[0].number, equals(1));
      expect(sections[1].isVerse, isTrue);
      expect(sections[1].number, equals(2));
      expect(sections[2].isRefrain, isTrue);
      expect(sections[2].content, contains('Praise the Lord'));
    });

    test('should handle hymn data with chorus', () {
      final hymnData = {
        'verses': [
          {'text': 'Amazing grace, how sweet the sound'},
        ],
        'chorus': {
          'text': 'Holy, holy, holy'
        }
      };

      final sections = LyricsParser.parseStructuredLyrics(hymnData);
      
      expect(sections.length, equals(2));
      expect(sections[0].isVerse, isTrue);
      expect(sections[1].isChorus, isTrue);
      expect(sections[1].content, equals('Holy, holy, holy'));
    });

    test('should handle empty structured data', () {
      final sections = LyricsParser.parseStructuredLyrics({});
      expect(sections, isEmpty);
    });

    test('should skip empty verses and refrains', () {
      final hymnData = {
        'verses': [
          {'text': 'Amazing grace'},
          {'text': ''},
          {'text': 'I once was lost'},
        ],
        'refrain': {
          'text': ''
        }
      };

      final sections = LyricsParser.parseStructuredLyrics(hymnData);
      
      expect(sections.length, equals(2));
      expect(sections[0].content, equals('Amazing grace'));
      expect(sections[1].content, equals('I once was lost'));
    });
  });
}