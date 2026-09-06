import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noor_quran/models/verse.dart';
import 'package:noor_quran/services/quran_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('QuranService.fetchChapters returns 114 chapters from network or fallback', () async {
    SharedPreferences.setMockInitialValues({});
    final chapters = await QuranService.fetchChapters();
    expect(chapters, isNotEmpty);
    expect(chapters.length, equals(114));
    expect(chapters.first.nameSimple, equals('Al-Fatihah'));
    expect(chapters.last.nameSimple, equals('An-Nas'));
  });

  test('Verse.fromJson correctly parses Saheeh International translation and strips footnotes', () {
    final sampleJson = {
      "id": 1,
      "verse_number": 1,
      "verse_key": "1:1",
      "text_indopak": "بِسۡمِ اللهِ الرَّحۡمٰنِ الرَّحِيۡمِ",
      "translations": [
        {
          "id": 96343,
          "resource_id": 20,
          "text": "In the name of Allāh,<sup foot_note=195932>1</sup> the Entirely Merciful, the Especially Merciful.<sup foot_note=195931>2</sup>"
        }
      ],
      "audio": {
        "url": "Alafasy/mp3/001001.mp3"
      }
    };

    final verse = Verse.fromJson(sampleJson);
    expect(verse.translationText, equals("In the name of Allāh, the Entirely Merciful, the Especially Merciful."));
    expect(verse.verseKey, equals("1:1"));
    expect(verse.textIndopak, equals("بِسۡمِ اللهِ الرَّحۡمٰنِ الرَّحِيۡمِ"));
  });

  test('QuranService.fetchVerses loads from cache when offline', () async {
    final sampleResponse = jsonEncode({
      "verses": [
        {
          "id": 1,
          "verse_number": 1,
          "verse_key": "1:1",
          "text_indopak": "بِسۡمِ اللهِ الرَّحۡمٰنِ الرَّحِيۡمِ",
          "translations": [
            {
              "id": 96343,
              "resource_id": 20,
              "text": "In the name of Allāh,<sup foot_note=195932>1</sup> the Entirely Merciful, the Especially Merciful.<sup foot_note=195931>2</sup>"
            }
          ]
        }
      ]
    });
    SharedPreferences.setMockInitialValues({'cached_verses_1': sampleResponse});
    final verses = await QuranService.fetchVerses(1);
    expect(verses.length, equals(1));
    expect(verses.first.translationText, equals("In the name of Allāh, the Entirely Merciful, the Especially Merciful."));
  });
}
