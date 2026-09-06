import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chapter.dart';
import '../models/verse.dart';

class QuranService {
  static const String baseUrl = 'https://api.quran.com/api/v4';
  static const String audioBaseUrl = 'https://verses.quran.com/';

  static Map<String, String> get headers {
    if (kIsWeb) {
      return {'Accept': 'application/json'};
    }
    return {
      'Accept': 'application/json',
      'User-Agent': 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Mobile Safari/537.36',
    };
  }

  static Future<List<Chapter>> fetchChapters() async {
    // 1. Try fetching live data from api.quran.com with timeout
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/chapters?language=en'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 7));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final chaptersList = data['chapters'] as List<dynamic>;
        final chapters = chaptersList
            .map((json) => Chapter.fromJson(json as Map<String, dynamic>))
            .toList();

        // Cache response in SharedPreferences
        await _cacheChapters(response.body);

        return chapters;
      }
    } catch (e) {
      debugPrint('QuranService: Network fetch failed ($e). Attempting fallback.');
    }

    // 2. Try loading cached chapters from SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString('cached_chapters');
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final data = jsonDecode(cachedJson) as Map<String, dynamic>;
        final chaptersList = data['chapters'] as List<dynamic>;
        return chaptersList
            .map((json) => Chapter.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('QuranService: Cache load failed: $e');
    }

    // 3. Fallback to bundled asset file assets/data/surahs.json
    try {
      final jsonString = await rootBundle.loadString('assets/data/surahs.json');
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final chaptersList = data['chapters'] as List<dynamic>;
      return chaptersList
          .map((json) => Chapter.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('QuranService: Local asset fallback failed: $e');
      throw Exception('Could not load surahs from network or local storage: $e');
    }
  }

  static Future<void> _cacheChapters(String jsonString) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_chapters', jsonString);
    } catch (e) {
      debugPrint('QuranService: Failed to cache chapters: $e');
    }
  }

  static Future<List<Verse>> fetchVerses(int chapterId) async {
    // 1. Try network with primary translation: 20 (Saheeh International, identical to web app)
    final translationIds = ['20', '131'];

    for (final transId in translationIds) {
      try {
        final url =
            '$baseUrl/verses/by_chapter/$chapterId?translations=$transId&fields=text_indopak&audio=7&per_page=300';
        final response = await http
            .get(
              Uri.parse(url),
              headers: headers,
            )
            .timeout(const Duration(seconds: 12));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final versesList = data['verses'] as List<dynamic>;
          final verses = versesList
              .map((json) => Verse.fromJson(json as Map<String, dynamic>))
              .toList();

          if (verses.isNotEmpty && verses.any((v) => v.translationText.isNotEmpty)) {
            await _cacheVerses(chapterId, response.body);
            return verses;
          }
        }
      } catch (e) {
        debugPrint('QuranService: Verse fetch error for trans $transId: $e');
      }
    }

    // 2. Offline fallback: check SharedPreferences cache
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString('cached_verses_$chapterId');
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final data = jsonDecode(cachedJson) as Map<String, dynamic>;
        final versesList = data['verses'] as List<dynamic>;
        return versesList
            .map((json) => Verse.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('QuranService: Cache load failed for surah $chapterId: $e');
    }

    throw Exception('Failed to load verses for surah $chapterId. Please check your internet connection.');
  }

  static Future<void> _cacheVerses(int chapterId, String jsonString) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_verses_$chapterId', jsonString);
    } catch (e) {
      debugPrint('QuranService: Failed to cache verses for surah $chapterId: $e');
    }
  }
}

