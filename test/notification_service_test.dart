import 'package:flutter_test/flutter_test.dart';
import 'package:noor_quran/services/notification_service.dart';

void main() {
  group('NotificationService Quiet Hours Tests', () {
    test('Identifies quiet hours between 22:00 and 05:00', () {
      // 22:00 (10:00 PM) -> Quiet hours ON
      expect(NotificationService.isQuietHours(DateTime(2026, 9, 6, 22, 0)), isTrue);
      // 23:30 (11:30 PM) -> Quiet hours ON
      expect(NotificationService.isQuietHours(DateTime(2026, 9, 6, 23, 30)), isTrue);
      // 00:15 (12:15 AM) -> Quiet hours ON
      expect(NotificationService.isQuietHours(DateTime(2026, 9, 6, 0, 15)), isTrue);
      // 04:59 (4:59 AM) -> Quiet hours ON
      expect(NotificationService.isQuietHours(DateTime(2026, 9, 6, 4, 59)), isTrue);

      // 05:00 (5:00 AM) -> Quiet hours OFF
      expect(NotificationService.isQuietHours(DateTime(2026, 9, 6, 5, 0)), isFalse);
      // 09:00 (9:00 AM) -> Quiet hours OFF
      expect(NotificationService.isQuietHours(DateTime(2026, 9, 6, 9, 0)), isFalse);
      // 14:00 (2:00 PM) -> Quiet hours OFF
      expect(NotificationService.isQuietHours(DateTime(2026, 9, 6, 14, 0)), isFalse);
      // 21:59 (9:59 PM) -> Quiet hours OFF
      expect(NotificationService.isQuietHours(DateTime(2026, 9, 6, 21, 59)), isFalse);
    });
  });
}
