import 'package:flutter_test/flutter_test.dart';
import 'package:noor_quran/services/tafsir_service.dart';

void main() {
  group('TafsirService Unit Tests', () {
    test('Cleans HTML tags and removes citations correctly', () {
      const sampleHtml =
          '<p>In the Name of Allah, the Most Gracious. <b>He is the Eternal</b>.</p><p>Second paragraph.</p>';
      final clean = TafsirService.stripHtml(sampleHtml);
      expect(clean.contains('<p>'), isFalse);
      expect(clean.contains('<b>'), isFalse);
      expect(clean.contains('In the Name of Allah'), isTrue);
      expect(clean.contains('He is the Eternal'), isTrue);
    });

    test('Extracts concise spiritual explanation from lengthy text', () {
      final lengthy =
          'Allah is the Light of the heavens and the earth. The parable of His light is a niche wherein is a lamp. '
          'The lamp is in a glass, the glass as it were a brilliant star, lit from a blessed tree, an olive, '
          'neither of the east nor of the west, whose oil would almost glow forth of itself, though no fire touched it. '
          'Light upon light! Allah guides unto His light whom He wills. And Allah sets forth parables for mankind, '
          'and Allah is Knower of all things. Extensive theological discussions follow here.';

      final concise = TafsirService.extractConciseSummary(lengthy, maxLength: 160);
      expect(concise.length, lessThanOrEqualTo(165));
      expect(concise.endsWith('…') || concise.endsWith('.'), isTrue);
      expect(concise.contains('Allah is the Light of the heavens'), isTrue);
    });

    test('Returns curated concise spiritual takeaways for prominent verses', () {
      final kursi = TafsirService.getCuratedConciseTafsir(2, 255);
      expect(kursi, isNotNull);
      expect(kursi.author.contains('Concise'), isTrue);
      expect(kursi.shortExplanation.contains('Ayat al-Kursi') || kursi.shortExplanation.contains('majesty'), isTrue);

      final ikhlas = TafsirService.getCuratedConciseTafsir(112, 1);
      expect(ikhlas, isNotNull);
      expect(ikhlas.shortExplanation.contains('Tawhid') || ikhlas.shortExplanation.contains('Oneness'), isTrue);
    });

    test('TafsirData JSON round-trip serialization works accurately', () {
      const data = TafsirData(
        verseKey: '2:255',
        shortExplanation: 'Allah is the Ever-Living, the Sustainer of all existence.',
        classicalDetails: '<p>Complete classical commentary details.</p>',
        author: 'Ibn Kathir (Abridged)',
      );

      final json = data.toJson();
      final restored = TafsirData.fromJson(json);

      expect(restored.verseKey, data.verseKey);
      expect(restored.shortExplanation, data.shortExplanation);
      expect(restored.classicalDetails, data.classicalDetails);
      expect(restored.author, data.author);
    });
  });
}
