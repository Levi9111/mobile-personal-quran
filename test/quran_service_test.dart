import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
}
