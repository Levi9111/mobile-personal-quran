import 'package:flutter_test/flutter_test.dart';
import 'package:noor_quran/utils/arabic_numerals.dart';

void main() {
  group('ArabicNumeralHelper Tests', () {
    test('Converts English digits to Eastern Arabic digits', () {
      expect(ArabicNumeralHelper.toArabic(0), '٠');
      expect(ArabicNumeralHelper.toArabic(1), '١');
      expect(ArabicNumeralHelper.toArabic(123), '١٢٣');
      expect(ArabicNumeralHelper.toArabic(255), '٢٥٥');
      expect(ArabicNumeralHelper.toArabic('114'), '١١٤');
    });

    test('Formats dual chapter and verse accurately', () {
      final dual = ArabicNumeralHelper.formatDual(2, 255);
      expect(dual, '2:255 • ٢:٢٥٥');

      final dual1 = ArabicNumeralHelper.formatDual(1, 1);
      expect(dual1, '1:1 • ١:١');

      final dual36 = ArabicNumeralHelper.formatDual(36, 12);
      expect(dual36, '36:12 • ٣٦:١٢');
    });

    test('Formats Arabic-only notation', () {
      expect(ArabicNumeralHelper.formatArabicOnly(2, 255), '٢:٢٥٥');
      expect(ArabicNumeralHelper.formatArabicOnly(114, 6), '١١٤:٦');
    });

    test('Formats dual with parentheses', () {
      expect(ArabicNumeralHelper.formatDualParentheses(2, 255), '2:255 (٢:٢٥٥)');
    });
  });
}
