import '../utils/arabic_numerals.dart';

class Verse {
  final int id;
  final int verseNumber;
  final String verseKey;
  final String textIndopak;
  final String translationText;
  final String? audioUrl;

  String get verse_key => verseKey;
  String get textUthmani => textIndopak;
  String get dualVerseReference {
    final parts = verseKey.split(':');
    final ch = parts.isNotEmpty ? parts[0] : '';
    return ArabicNumeralHelper.formatDual(ch, verseNumber);
  }

  Verse({
    required this.id,
    required this.verseNumber,
    required this.verseKey,
    required this.textIndopak,
    required this.translationText,
    this.audioUrl,
  });

  static String cleanArabicText(String text) {
    return text
        .replaceAll(RegExp(r'[\uE000-\uF8FF]'), '') // private-use area glyphs
        .replaceAll(RegExp(r'[\u200B-\u200F\u202A-\u202E\uFEFF]'), '') // zero-width & bidi marks
        .replaceAll('\u2002', ' ') // en-space -> normal space
        .trim();
  }

  static String stripFootnotes(String html) {
    return html
        .replaceAll(RegExp(r'<sup[^>]*>.*?<\/sup>'), '')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .trim();
  }

  factory Verse.fromJson(Map<String, dynamic> json) {
    final translationsList = json['translations'] as List<dynamic>?;
    String translation = '';
    if (translationsList != null && translationsList.isNotEmpty) {
      final firstTrans = translationsList.first as Map<String, dynamic>;
      translation = stripFootnotes(firstTrans['text'] as String? ?? '');
    } else if (json['translation'] is String) {
      translation = stripFootnotes(json['translation'] as String);
    }

    final audioObj = json['audio'] as Map<String, dynamic>?;
    final audioUrl = audioObj?['url'] as String?;

    return Verse(
      id: json['id'] as int,
      verseNumber: json['verse_number'] as int? ?? 0,
      verseKey: json['verse_key'] as String? ?? '',
      textIndopak: cleanArabicText(json['text_indopak'] as String? ?? ''),
      translationText: translation,
      audioUrl: audioUrl,
    );
  }
}
