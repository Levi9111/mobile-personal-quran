import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chapter.dart';
import '../models/verse.dart';

class QuranService {
  static const String baseUrl = 'https://api.quran.com/api/v4';
  static const String audioBaseUrl = 'https://verses.quran.com/';

  static const Map<String, String> headers = {
    'Accept': 'application/json',
    'User-Agent': 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Mobile Safari/537.36',
  };

  static Future<List<Chapter>> fetchChapters() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chapters?language=en'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final chaptersList = data['chapters'] as List<dynamic>;
        return chaptersList.map((json) => Chapter.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Server returned status code ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<Verse>> fetchVerses(int chapterId) async {
    try {
      final url = '$baseUrl/verses/by_chapter/$chapterId?language=en&words=false&translations=131&fields=text_indopak&audio=7&per_page=300';
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final versesList = data['verses'] as List<dynamic>;
        return versesList.map((json) => Verse.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Server returned status code ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
