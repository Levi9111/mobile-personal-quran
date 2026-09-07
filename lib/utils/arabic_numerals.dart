/// Helper utility to convert Western Arabic digits (0-9) to Eastern Arabic-Indic digits (٠-٩)
/// and format verse reference markers with dual English and Arabic numbering.
class ArabicNumeralHelper {
  static const Map<String, String> _digitMap = {
    '0': '٠',
    '1': '١',
    '2': '٢',
    '3': '٣',
    '4': '٤',
    '5': '٥',
    '6': '٦',
    '7': '٧',
    '8': '٨',
    '9': '٩',
  };

  /// Converts an integer or numeric string into Eastern Arabic numerals (٠-٩).
  static String toArabicDigits(dynamic value) => toArabic(value);

  /// Converts an integer or numeric string into Eastern Arabic numerals (٠-٩).
  static String toArabic(dynamic value) {
    final str = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final char = str[i];
      buffer.write(_digitMap[char] ?? char);
    }
    return buffer.toString();
  }

  /// Formats chapter and verse as dual: `[chapter]:[verse] • [سورة]:[آية]`
  /// Example: `formatDual(2, 255)` -> `"2:255 • ٢:٢٥٥"`
  static String formatDual(dynamic chapterId, dynamic verseNumber, {String separator = ' • '}) {
    final eng = '$chapterId:$verseNumber';
    final arb = '${toArabic(chapterId)}:${toArabic(verseNumber)}';
    return '$eng$separator$arb';
  }

  /// Formats only the Eastern Arabic representation: e.g. `٢:٢٥٥`
  static String formatArabicOnly(dynamic chapterId, dynamic verseNumber) {
    return '${toArabic(chapterId)}:${toArabic(verseNumber)}';
  }

  /// Formats dual with parentheses: e.g. `2:255 (٢:٢٥٥)`
  static String formatDualParentheses(dynamic chapterId, dynamic verseNumber) {
    return '$chapterId:$verseNumber (${toArabic(chapterId)}:${toArabic(verseNumber)})';
  }
}
