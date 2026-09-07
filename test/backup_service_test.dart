import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noor_quran/services/backup_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BackupService Unit Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'quran_bookmarks': [
          jsonEncode({
            'id': '2:255',
            'surahId': 2,
            'surahNameSimple': 'Al-Baqarah',
            'surahNameArabic': 'البقرة',
            'verseNumber': 255,
            'verseKey': '2:255',
            'arabicText': 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
            'translationText': 'Allah! There is no deity except Him, the Ever-Living, the Sustainer of all existence.',
            'timestamp': '2026-09-07T12:00:00.000Z',
          }),
        ],
        'quran_last_read': jsonEncode({
          'surahId': 2,
          'surahName': 'Al-Baqarah',
          'verseNumber': 255,
        }),
        'quran_last_read_date': '2026-09-07T12:00:00.000Z',
        'fav_important_verses': ['1', '2', '5'],
        'notes_important_verses': jsonEncode({
          '2:255': 'A verse of supreme protection and majesty.',
        }),
        'noor-theme': 'dark',
      });
    });

    test('Generates structured backup map with all expected keys', () async {
      final data = await BackupService.createBackupData();

      expect(data['app'], 'Noor Quran');
      expect(data['schema_version'], 1);
      expect(data.containsKey('exported_at'), isTrue);

      final payload = data['data'] as Map<String, dynamic>;
      expect(payload['bookmarks'], isA<List>());
      expect((payload['bookmarks'] as List).length, 1);
      expect(payload['favorites'], isA<List>());
      expect((payload['favorites'] as List).length, 3);
      expect(payload['personal_notes'], isA<Map>());
      expect(payload['theme'], 'dark');
    });

    test('Exports formatted valid JSON string', () async {
      final jsonStr = await BackupService.exportBackupJson(pretty: true);
      expect(jsonStr.isNotEmpty, isTrue);

      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      expect(decoded['app'], 'Noor Quran');
      expect(decoded['schema_version'], 1);
    });

    test('BackupResult fields behave properly on success and failure', () {
      const success = BackupResult(
        success: true,
        message: 'Data successfully restored!',
        bookmarksCount: 5,
        favoritesCount: 3,
        notesCount: 2,
        lastRead: 'Surah Al-Baqarah : 255',
      );

      expect(success.success, isTrue);
      expect(success.bookmarksCount, 5);
      expect(success.favoritesCount, 3);
      expect(success.notesCount, 2);
      expect(success.lastRead, 'Surah Al-Baqarah : 255');

      const failure = BackupResult(
        success: false,
        message: 'Invalid backup format',
      );
      expect(failure.success, isFalse);
      expect(failure.bookmarksCount, 0);
    });
  });
}
