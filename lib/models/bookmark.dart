import 'dart:convert';
import '../utils/arabic_numerals.dart';

/// Represents a bookmarked or last-read verse in the Quran.
class Bookmark {
  final String id;
  final int surahId;
  final String surahNameSimple;
  final String surahNameArabic;
  final int verseNumber;
  final String verseKey;
  final String arabicText;
  final String translationText;
  final DateTime timestamp;
  final String? note;
  final bool isLastRead;

  const Bookmark({
    required this.id,
    required this.surahId,
    required this.surahNameSimple,
    required this.surahNameArabic,
    required this.verseNumber,
    required this.verseKey,
    required this.arabicText,
    required this.translationText,
    required this.timestamp,
    this.note,
    this.isLastRead = false,
  });

  /// Dual English and Arabic verse reference (e.g. `2:255 • ٢:٢٥٥`)
  String get dualVerseReference =>
      ArabicNumeralHelper.formatDual(surahId, verseNumber);

  /// Eastern Arabic reference (e.g. `٢:٢٥٥`)
  String get arabicVerseReference =>
      ArabicNumeralHelper.formatArabicOnly(surahId, verseNumber);

  Bookmark copyWith({
    String? id,
    int? surahId,
    String? surahNameSimple,
    String? surahNameArabic,
    int? verseNumber,
    String? verseKey,
    String? arabicText,
    String? translationText,
    DateTime? timestamp,
    String? note,
    bool? isLastRead,
  }) {
    return Bookmark(
      id: id ?? this.id,
      surahId: surahId ?? this.surahId,
      surahNameSimple: surahNameSimple ?? this.surahNameSimple,
      surahNameArabic: surahNameArabic ?? this.surahNameArabic,
      verseNumber: verseNumber ?? this.verseNumber,
      verseKey: verseKey ?? this.verseKey,
      arabicText: arabicText ?? this.arabicText,
      translationText: translationText ?? this.translationText,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
      isLastRead: isLastRead ?? this.isLastRead,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'surah_id': surahId,
      'surah_name_simple': surahNameSimple,
      'surah_name_arabic': surahNameArabic,
      'verse_number': verseNumber,
      'verse_key': verseKey,
      'arabic_text': arabicText,
      'translation_text': translationText,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
      'is_last_read': isLastRead,
    };
  }

  factory Bookmark.fromMap(Map<String, dynamic> map) {
    return Bookmark(
      id: map['id']?.toString() ?? '${map['surah_id']}:${map['verse_number']}',
      surahId: (map['surah_id'] ?? map['surahId'] ?? 1) as int,
      surahNameSimple: (map['surah_name_simple'] ?? map['surahNameSimple'] ?? '') as String,
      surahNameArabic: (map['surah_name_arabic'] ?? map['surahNameArabic'] ?? '') as String,
      verseNumber: (map['verse_number'] ?? map['verseNumber'] ?? 1) as int,
      verseKey: (map['verse_key'] ?? map['verseKey'] ?? '') as String,
      arabicText: (map['arabic_text'] ?? map['arabicText'] ?? '') as String,
      translationText: (map['translation_text'] ?? map['translationText'] ?? '') as String,
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      note: map['note'] as String?,
      isLastRead: (map['is_last_read'] ?? map['isLastRead'] ?? false) as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory Bookmark.fromJson(String source) =>
      Bookmark.fromMap(json.decode(source) as Map<String, dynamic>);
}
