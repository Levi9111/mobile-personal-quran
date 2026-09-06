import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noor_quran/models/important_verse.dart';
import 'package:noor_quran/providers/important_verses_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ImportantVersesProvider & Model Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Loads 24 curated important verses and duas', () async {
      final provider = ImportantVersesProvider();
      await provider.loadVerses();

      expect(provider.allVerses.length, equals(24));
      expect(provider.isLoading, isFalse);
      expect(provider.categories, contains('All'));
      expect(provider.categories, contains('Quranic Duas'));
      expect(provider.categories, contains('Protection & Safety'));
      expect(provider.occasions, contains('All'));
      expect(provider.occasions, contains('Morning & Evening'));
    });

    test('ImportantVerse model correctly deserializes JSON', () {
      final sampleJson = {
        "id": 1,
        "surah_number": 2,
        "verse_number": 255,
        "verse_key": "2:255",
        "surah_name": "Al-Baqarah",
        "title": "Ayat al-Kursi (The Throne Verse)",
        "category": "Tawheed & Faith",
        "occasions": ["Morning & Evening", "After Obligatory Prayers", "Before Sleep"],
        "significance": "The greatest verse in the Quran.",
        "blessings": "Recitation after each obligatory prayer protects until the next prayer.",
        "reference": "Sahih Muslim 810",
        "text_indopak": "اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ",
        "translation": "Allah - there is no deity except Him, the Ever-Living, the Sustainer of all existence.",
        "audio_url": "Alafasy/mp3/002255.mp3"
      };

      final verse = ImportantVerse.fromJson(sampleJson);
      expect(verse.id, equals(1));
      expect(verse.verseKey, equals('2:255'));
      expect(verse.title, equals('Ayat al-Kursi (The Throne Verse)'));
      expect(verse.category, equals('Tawheed & Faith'));
      expect(verse.occasions.length, equals(3));
      expect(verse.reference, equals('Sahih Muslim 810'));
    });

    test('Filters verses by category correctly', () async {
      final provider = ImportantVersesProvider();
      await provider.loadVerses();

      provider.setCategory('Quranic Duas');
      expect(provider.filteredVerses, isNotEmpty);
      for (final v in provider.filteredVerses) {
        expect(v.category, equals('Quranic Duas'));
      }
    });

    test('Filters verses by occasion correctly', () async {
      final provider = ImportantVersesProvider();
      await provider.loadVerses();

      provider.setOccasion('Before Sleeping');
      expect(provider.filteredVerses, isNotEmpty);
      for (final v in provider.filteredVerses) {
        expect(v.occasions.contains('Before Sleeping'), isTrue);
      }
    });

    test('Searches verses by keyword, title, and translation', () async {
      final provider = ImportantVersesProvider();
      await provider.loadVerses();

      provider.setSearchQuery('Throne');
      expect(provider.filteredVerses, isNotEmpty);
      expect(provider.filteredVerses.any((v) => v.title.contains('Throne')), isTrue);

      provider.setSearchQuery('Yunus');
      expect(provider.filteredVerses, isNotEmpty);
      expect(provider.filteredVerses.first.title, contains('Yunus'));
    });

    test('Toggles and persists favorites', () async {
      final provider = ImportantVersesProvider();
      await provider.loadVerses();

      expect(provider.isFavorite(1), isFalse);

      await provider.toggleFavorite(1);
      expect(provider.isFavorite(1), isTrue);

      provider.toggleFavoritesOnly();
      expect(provider.showFavoritesOnly, isTrue);
      expect(provider.filteredVerses.length, equals(1));
      expect(provider.filteredVerses.first.id, equals(1));

      // Re-load provider to check persistence in SharedPreferences
      final newProvider = ImportantVersesProvider();
      await newProvider.loadVerses();
      expect(newProvider.isFavorite(1), isTrue);
    });

    test('Saves, retrieves, and removes personal reflections', () async {
      final provider = ImportantVersesProvider();
      await provider.loadVerses();

      const verseKey = '2:255';
      expect(provider.hasPersonalNote(verseKey), isFalse);

      await provider.savePersonalNote(verseKey, 'Recite this after every Salah.');
      expect(provider.hasPersonalNote(verseKey), isTrue);
      expect(provider.getPersonalNote(verseKey), equals('Recite this after every Salah.'));

      await provider.removePersonalNote(verseKey);
      expect(provider.hasPersonalNote(verseKey), isFalse);
      expect(provider.getPersonalNote(verseKey), isNull);
    });

    test('Provides a valid daily spotlight verse', () async {
      final provider = ImportantVersesProvider();
      await provider.loadVerses();

      expect(provider.dailyVerse, isNotNull);
      expect(provider.dailyVerse!.id, isPositive);
    });
  });
}
