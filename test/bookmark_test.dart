import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noor_quran/models/bookmark.dart';
import 'package:noor_quran/providers/bookmark_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Bookmark Model & Provider Tests', () {
    test('Bookmark serialization and deserialization works correctly', () {
      final bookmark = Bookmark(
        id: '2:255',
        surahId: 2,
        surahNameSimple: 'Al-Baqarah',
        surahNameArabic: 'البقرة',
        verseNumber: 255,
        verseKey: '2:255',
        arabicText: 'الله لا إله إلا هو',
        translationText: 'Allah! There is no deity except Him',
        timestamp: DateTime(2026, 9, 6, 12, 0),
      );

      final jsonStr = bookmark.toJson();
      final restored = Bookmark.fromJson(jsonStr);

      expect(restored.id, '2:255');
      expect(restored.surahId, 2);
      expect(restored.verseNumber, 255);
      expect(restored.dualVerseReference, '2:255 • ٢:٢٥٥');
      expect(restored.surahNameArabic, 'البقرة');
    });

    test('BookmarkProvider sets last read and persists correctly', () async {
      final provider = BookmarkProvider();
      await provider.loadBookmarks();

      expect(provider.lastReadBookmark, isNull);
      expect(provider.hasReadToday(), isFalse);

      final bookmark = Bookmark(
        id: '1:1',
        surahId: 1,
        surahNameSimple: 'Al-Fatihah',
        surahNameArabic: 'الفاتحة',
        verseNumber: 1,
        verseKey: '1:1',
        arabicText: 'بسم الله الرحمن الرحيم',
        translationText: 'In the name of Allah',
        timestamp: DateTime.now(),
      );

      await provider.setLastRead(bookmark);

      expect(provider.lastReadBookmark, isNotNull);
      expect(provider.lastReadBookmark!.surahId, 1);
      expect(provider.lastReadBookmark!.verseNumber, 1);
      expect(provider.hasReadToday(), isTrue);
    });

    test('BookmarkProvider toggles bookmarks in saved list', () async {
      final provider = BookmarkProvider();
      await provider.loadBookmarks();

      final bookmark = Bookmark(
        id: '36:1',
        surahId: 36,
        surahNameSimple: 'Yaseen',
        surahNameArabic: 'يس',
        verseNumber: 1,
        verseKey: '36:1',
        arabicText: 'يس',
        translationText: 'Ya-Seen',
        timestamp: DateTime.now(),
      );

      expect(provider.isBookmarked(36, 1), isFalse);

      final added = await provider.toggleBookmark(bookmark);
      expect(added, isTrue);
      expect(provider.isBookmarked(36, 1), isTrue);
      expect(provider.bookmarks.length, 1);

      // Toggling again should remove it
      final removed = await provider.toggleBookmark(bookmark);
      expect(removed, isFalse);
      expect(provider.isBookmarked(36, 1), isFalse);
      expect(provider.bookmarks.isEmpty, isTrue);
    });
  });
}
