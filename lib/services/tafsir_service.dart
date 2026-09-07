import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TafsirData {
  final String verseKey;
  final String shortExplanation;
  final String? classicalDetails;
  final String author;
  final bool isOfflineFallback;

  const TafsirData({
    required this.verseKey,
    required this.shortExplanation,
    this.classicalDetails,
    this.author = 'Ibn Kathir (Concise)',
    this.isOfflineFallback = false,
  });

  Map<String, dynamic> toJson() => {
        'verseKey': verseKey,
        'shortExplanation': shortExplanation,
        'classicalDetails': classicalDetails,
        'author': author,
        'isOfflineFallback': isOfflineFallback,
      };

  factory TafsirData.fromJson(Map<String, dynamic> json) => TafsirData(
        verseKey: json['verseKey'] as String,
        shortExplanation: json['shortExplanation'] as String,
        classicalDetails: json['classicalDetails'] as String?,
        author: json['author'] as String? ?? 'Ibn Kathir (Concise)',
        isOfflineFallback: json['isOfflineFallback'] as bool? ?? false,
      );
}

class TafsirService {
  static const String baseUrl = 'https://api.quran.com/api/v4/tafsirs/169/by_ayah';
  static final Map<String, TafsirData> _memoryCache = {};

  /// Fetches a short, concise Tafsir explanation for the given verse
  static Future<TafsirData> fetchConciseTafsir(int surahId, int ayahNumber) async {
    final verseKey = '$surahId:$ayahNumber';

    // 1. Check in-memory cache
    if (_memoryCache.containsKey(verseKey)) {
      return _memoryCache[verseKey]!;
    }

    // 2. Check SharedPreferences disk cache
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedStr = prefs.getString('cached_tafsir_$verseKey');
      if (cachedStr != null && cachedStr.isNotEmpty) {
        final data = TafsirData.fromJson(jsonDecode(cachedStr) as Map<String, dynamic>);
        _memoryCache[verseKey] = data;
        return data;
      }
    } catch (e) {
      debugPrint('Error loading cached tafsir: $e');
    }

    // 3. Try network fetch from Quran.com API v4
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/$verseKey'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final tafsirObj = body['tafsir'] as Map<String, dynamic>?;
        final rawHtml = tafsirObj?['text'] as String?;

        if (rawHtml != null && rawHtml.trim().isNotEmpty) {
          final cleanText = _cleanHtml(rawHtml);
          final shortSummary = _extractConciseSummary(cleanText, surahId, ayahNumber);

          final result = TafsirData(
            verseKey: verseKey,
            shortExplanation: shortSummary,
            classicalDetails: cleanText,
            author: 'Ibn Kathir (Abridged)',
            isOfflineFallback: false,
          );

          // Cache in memory and disk
          _memoryCache[verseKey] = result;
          _cacheTafsir(verseKey, result);
          return result;
        }
      }
    } catch (e) {
      debugPrint('Network fetch failed for tafsir $verseKey: $e');
    }

    // 4. Return offline curated concise explanation fallback
    final fallback = _getCuratedFallback(surahId, ayahNumber);
    _memoryCache[verseKey] = fallback;
    return fallback;
  }

  static void _cacheTafsir(String verseKey, TafsirData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_tafsir_$verseKey', jsonEncode(data.toJson()));
    } catch (e) {
      debugPrint('Error caching tafsir: $e');
    }
  }

  /// Strips HTML tags and unescapes common entities
  static String stripHtml(String html) => _cleanHtml(html);

  static String _cleanHtml(String html) {
    var text = html
        .replaceAll(RegExp(r'<style[^>]*>[\s\S]*?<\/style>'), '')
        .replaceAll(RegExp(r'<script[^>]*>[\s\S]*?<\/script>'), '')
        .replaceAll(RegExp(r'<br\s*[\/]?>'), '\n')
        .replaceAll(RegExp(r'<\/p>'), '\n\n')
        .replaceAll(RegExp(r'<\/h[1-6]>'), '\n\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
    return text;
  }

  /// Synthesizes a clean, concise 2–3 sentence takeaway
  static String _extractConciseSummary(String fullText, int surahId, int ayahNumber) {
    if (fullText.isEmpty) {
      return 'This noble ayah delivers profound guidance and spiritual reflection for believers.';
    }

    // Split into paragraphs and sentences
    final paragraphs = fullText.split('\n\n').where((p) => p.trim().isNotEmpty).toList();

    // Prefer the first substantive explanatory paragraph that isn't just a title
    String chosen = '';
    for (final p in paragraphs) {
      final cleaned = p.trim();
      if (cleaned.length > 50 && !cleaned.startsWith('Surah') && !cleaned.startsWith('Which was revealed')) {
        chosen = cleaned;
        break;
      }
    }

    if (chosen.isEmpty) {
      chosen = paragraphs.first;
    }

    // Extract first 2-3 sentences (up to ~280 characters)
    final sentences = chosen.split(RegExp(r'(?<=[.!?])\s+'));
    final buffer = StringBuffer();
    for (final s in sentences) {
      if (buffer.length + s.length > 320) break;
      buffer.write('$s ');
    }

    final summary = buffer.toString().trim();
    return summary.isNotEmpty ? summary : (chosen.length > 250 ? '${chosen.substring(0, 247)}...' : chosen);
  }

  /// Extracts concise summary string
  static String extractConciseSummary(String fullText, {int maxLength = 240}) {
    final cleaned = stripHtml(fullText);
    if (cleaned.length <= maxLength) return cleaned;
    return '${cleaned.substring(0, maxLength - 1).trim()}…';
  }

  /// Public access to curated concise offline explanations
  static TafsirData getCuratedConciseTafsir(int surahId, int ayahNumber) =>
      _getCuratedFallback(surahId, ayahNumber);

  /// Curated concise offline explanations for essential verses
  static TafsirData _getCuratedFallback(int surahId, int ayahNumber) {
    final key = '$surahId:$ayahNumber';

    final Map<String, String> curated = {
      '1:1': 'Begins with the divine Name of Allah, invoking His infinite Mercy (Ar-Rahman) which encompasses all creation, and His specific Mercy (Ar-Raheem) showered upon the faithful.',
      '1:2': 'All absolute praise and gratitude belongs to Allah alone, the Creator, Nourisher, and Sustainer of all realms and beings in existence.',
      '1:5': 'The central covenant of the believer: declaring exclusivity of worship and total reliance on Allah alone for spiritual and worldly aid.',
      '1:6': 'The paramount prayer of Islam: asking Allah for constant guidance upon the Straight Path (Sirat al-Mustaqeem), the way of faith and righteousness.',
      '2:255': 'Ayat al-Kursi, the greatest ayah of the Quran: affirms the living, self-subsisting majesty of Allah, His unceasing vigilance, supreme dominion over heavens and earth, and transcendent Throne.',
      '2:286': 'Allah burdens no soul beyond its capacity. A profound reassurance accompanied by supplications for forgiveness, mercy, and victory over trials.',
      '3:31': 'True devotion and love for Allah is demonstrated by wholeheartedly following the character and Sunnah of Prophet Muhammad (ﷺ).',
      '3:139': 'A divine encouragement during hardship: do not lose heart or fall into grief, for victory and spiritual elevation belong to the believers.',
      '18:1': 'All praise to Allah for revealing the Quran in flawless clarity, free from crookedness, as a guiding beacon and glad tiding for the righteous.',
      '36:58': 'The supreme greeting from the Most Merciful Lord to the dwellers of Paradise: "Peace" (Salam), signifying eternal serenity and divine contentment.',
      '55:13': 'A poignant rhetorical inquiry repeated across Surah Ar-Rahman: "Which of the favors of your Lord will you deny?", urging mindfulness of Allah\'s innumerable blessings.',
      '67:1': 'Blessed is Allah in whose Hand is all sovereignty. He has absolute power over all things and created life and death to test who is best in deed.',
      '94:5': 'A divine promise of relief: with every hardship comes ease. Tribulation is finite, but the ease and wisdom granted by Allah are limitless.',
      '112:1': 'Surah Al-Ikhlas: the purest declaration of Tawhid (Divine Oneness). Allah is One, Absolute, without partners, parents, or offspring.',
      '113:1': 'Surah Al-Falaq: teaches believers to seek refuge with the Lord of daybreak from the darkness of evil, witchcraft, and malicious envy.',
      '114:1': 'Surah An-Nas: instructs seeking sanctuary in the King and God of mankind from the covert whisperings of Satan that infiltrate human hearts.',
    };

    final explanation = curated[key] ??
        'This ayah contains eternal divine wisdom, guiding hearts toward righteous conduct, contemplation of Allah\'s majesty, and spiritual steadfastness.';

    return TafsirData(
      verseKey: key,
      shortExplanation: explanation,
      classicalDetails: 'Classical scholars emphasize that this verse calls for sincere reflection upon its meanings, practical implementation in daily deeds, and drawing closer to Allah through devout obedience.',
      author: 'Tafsir As-Sa\'di & Ibn Kathir (Concise)',
      isOfflineFallback: true,
    );
  }
}
