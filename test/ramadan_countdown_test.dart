import 'package:flutter_test/flutter_test.dart';
import 'package:noor_quran/utils/ramadan_calculator.dart';

void main() {
  group('RamadanCalculator Tests', () {
    test('Calculates countdown to Ramadan 1448 AH from September 2026', () {
      final testDate = DateTime(2026, 9, 6, 12, 0);
      final countdown = RamadanCalculator.calculateCountdown(testDate);

      expect(countdown.hijriYear, 1448);
      expect(countdown.hijriName, contains('1448'));
      expect(countdown.isCurrentlyRamadan, isFalse);
      expect(countdown.totalDays, greaterThan(140));
      expect(countdown.months, greaterThanOrEqualTo(5));
      expect(countdown.remainingDays, greaterThanOrEqualTo(0));
    });

    test('Identifies when currently inside Ramadan', () {
      final testDate = DateTime(2027, 2, 15, 12, 0); // During Ramadan 1448 AH
      final countdown = RamadanCalculator.calculateCountdown(testDate);

      expect(countdown.isCurrentlyRamadan, isTrue);
      expect(countdown.hijriYear, 1448);
      expect(countdown.hijriName, contains('In Progress'));
    });
  });
}
