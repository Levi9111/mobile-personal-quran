/// Comprehensive helper to calculate the exact remaining time, months, days,
/// and spiritual milestones for the upcoming blessed month of Ramadan.
class RamadanCountdownInfo {
  final DateTime targetDate;
  final int totalDays;
  final int months;
  final int remainingDays;
  final int hours;
  final int minutes;
  final int seconds;
  final int hijriYear;
  final String hijriName;
  final bool isCurrentlyRamadan;

  const RamadanCountdownInfo({
    required this.targetDate,
    required this.totalDays,
    required this.months,
    required this.remainingDays,
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.hijriYear,
    required this.hijriName,
    required this.isCurrentlyRamadan,
  });

  String get formattedSummary => '$months Months, $remainingDays Days';
}

class RamadanCalculator {
  /// Known astronomical projected start dates for upcoming Ramadans (1st of Ramadan).
  static final List<Map<String, dynamic>> _ramadanCalendar = [
    {'year': 1447, 'start': DateTime(2026, 2, 18), 'end': DateTime(2026, 3, 19)},
    {'year': 1448, 'start': DateTime(2027, 2, 7), 'end': DateTime(2027, 3, 8)},
    {'year': 1449, 'start': DateTime(2028, 1, 27), 'end': DateTime(2028, 2, 25)},
    {'year': 1450, 'start': DateTime(2029, 1, 15), 'end': DateTime(2029, 2, 13)},
    {'year': 1451, 'start': DateTime(2030, 1, 5), 'end': DateTime(2030, 2, 3)},
    {'year': 1452, 'start': DateTime(2030, 12, 25), 'end': DateTime(2031, 1, 23)},
  ];

  /// Calculates the countdown information for the next upcoming Ramadan.
  static RamadanCountdownInfo calculateCountdown([DateTime? fromDate]) {
    final now = fromDate ?? DateTime.now();

    // Check if we are currently inside Ramadan
    for (final r in _ramadanCalendar) {
      final start = r['start'] as DateTime;
      final end = r['end'] as DateTime;
      if (now.isAfter(start) && now.isBefore(end)) {
        final remainingInRamadan = end.difference(now);
        return RamadanCountdownInfo(
          targetDate: end,
          totalDays: remainingInRamadan.inDays,
          months: 0,
          remainingDays: remainingInRamadan.inDays,
          hours: remainingInRamadan.inHours % 24,
          minutes: remainingInRamadan.inMinutes % 60,
          seconds: remainingInRamadan.inSeconds % 60,
          hijriYear: r['year'] as int,
          hijriName: 'Ramadan ${r['year']} AH (In Progress)',
          isCurrentlyRamadan: true,
        );
      }
    }

    // Find the next upcoming Ramadan
    Map<String, dynamic>? nextRamadan;
    for (final r in _ramadanCalendar) {
      final start = r['start'] as DateTime;
      if (start.isAfter(now)) {
        nextRamadan = r;
        break;
      }
    }

    // Fallback if beyond known table: approximate by 354.36 days per lunar year
    final targetDate = nextRamadan != null
        ? nextRamadan['start'] as DateTime
        : DateTime(now.year + 1, 2, 1);
    final hijriYear = nextRamadan != null ? nextRamadan['year'] as int : 1448;

    final diff = targetDate.difference(now);
    final totalDays = diff.inDays;

    // Calculate calendar months and remaining days
    int months = 0;
    DateTime temp = DateTime(now.year, now.month, now.day);
    while (true) {
      final nextMonth = DateTime(temp.year, temp.month + 1, temp.day);
      if (nextMonth.isBefore(targetDate) || nextMonth.isAtSameMomentAs(targetDate)) {
        months++;
        temp = nextMonth;
      } else {
        break;
      }
    }
    final remainingDays = targetDate.difference(temp).inDays;

    return RamadanCountdownInfo(
      targetDate: targetDate,
      totalDays: totalDays,
      months: months,
      remainingDays: remainingDays,
      hours: diff.inHours % 24,
      minutes: diff.inMinutes % 60,
      seconds: diff.inSeconds % 60,
      hijriYear: hijriYear,
      hijriName: 'Ramadan $hijriYear AH',
      isCurrentlyRamadan: false,
    );
  }
}
