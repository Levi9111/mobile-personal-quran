import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bookmark.dart';
import '../models/chapter.dart';
import '../providers/bookmark_provider.dart';
import '../screens/surah_screen.dart';
import '../services/quran_service.dart';
import '../widgets/celestial_notification_banner.dart';

class NotificationService with ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _key8HourReminder = 'noor_reminder_8hour_enabled';
  static const String _keyIntervalHours = 'noor_reminder_interval_hours';
  static const String _keyLastReminderTime = 'noor_last_reminder_time';
  static const String _keyLastDailyNotifDate = 'noor_last_daily_notif_date';

  bool _reminder8HourEnabled = true;
  int _intervalHours = 8;
  Timer? _periodicCheckTimer;

  bool get reminder8HourEnabled => _reminder8HourEnabled;
  int get intervalHours => _intervalHours;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _reminder8HourEnabled = prefs.getBool(_key8HourReminder) ?? true;
      _intervalHours = prefs.getInt(_keyIntervalHours) ?? 8;
    } catch (e) {
      debugPrint('Error initializing notification preferences: $e');
    }
  }

  Future<void> set8HourReminderEnabled(bool enabled) async {
    _reminder8HourEnabled = enabled;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key8HourReminder, enabled);
    } catch (e) {
      debugPrint('Error saving reminder preference: $e');
    }
  }

  Future<void> setIntervalHours(int hours) async {
    _intervalHours = hours;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyIntervalHours, hours);
    } catch (e) {
      debugPrint('Error saving reminder interval: $e');
    }
  }

  /// Starts a periodic in-app timer to check reading reminders
  void startPeriodicChecks(BuildContext context, BookmarkProvider bookmarkProvider) {
    _periodicCheckTimer?.cancel();
    // Check every 15 minutes while app is running
    _periodicCheckTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      evaluateReminders(context, bookmarkProvider);
    });
  }

  void stopPeriodicChecks() {
    _periodicCheckTimer?.cancel();
    _periodicCheckTimer = null;
  }

  /// Checks whether the given time falls within quiet hours (22:00 to 05:00).
  static bool isQuietHours([DateTime? time]) {
    final now = time ?? DateTime.now();
    final hour = now.hour;
    // Muted from 22:00 (10 PM) to 05:00 (5 AM)
    return hour >= 22 || hour < 5;
  }

  /// Evaluates whether daily missed pop or 8-hour reminder should be triggered.
  Future<void> evaluateReminders(
    BuildContext context,
    BookmarkProvider bookmarkProvider,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    // 1. Check Daily Missed Reading
    final lastDailyNotifDateStr = prefs.getString(_keyLastDailyNotifDate);
    final todayStr = '${now.year}-${now.month}-${now.day}';

    if (!bookmarkProvider.hasReadToday() && lastDailyNotifDateStr != todayStr) {
      // User hasn't read today and we haven't prompted them yet today!
      await prefs.setString(_keyLastDailyNotifDate, todayStr);
      if (context.mounted) {
        showDailyMissedPop(context, bookmarkProvider);
      }
      return;
    }

    // 2. Check 8-Hour Periodic Reading Reminder (muted during quiet hours: 22:00 to 05:00)
    if (_reminder8HourEnabled && !isQuietHours(now)) {
      final lastReminderTimeStr = prefs.getString(_keyLastReminderTime);
      final lastReminderTime = lastReminderTimeStr != null
          ? DateTime.tryParse(lastReminderTimeStr)
          : null;

      final lastReadBookmark = bookmarkProvider.lastReadBookmark;
      final referenceTime = lastReminderTime ?? lastReadBookmark?.timestamp;

      if (referenceTime != null) {
        final difference = now.difference(referenceTime);
        if (difference.inHours >= _intervalHours) {
          await prefs.setString(_keyLastReminderTime, now.toIso8601String());
          if (context.mounted) {
            show8HourReminder(context, bookmarkProvider);
          }
        }
      }
    }
  }

  /// Shows the custom pop notification if no verse was read today
  void showDailyMissedPop(
    BuildContext context,
    BookmarkProvider bookmarkProvider,
  ) {
    final lastRead = bookmarkProvider.lastReadBookmark;

    CelestialNotificationBanner.show(
      context: context,
      title: 'Daily Noor Reflection',
      message: "You haven't read any Quran verse today yet. Illuminate your heart with even a single ayah.",
      verseReference: lastRead != null ? 'Last read: ${lastRead.dualVerseReference}' : null,
      actionLabel: lastRead != null ? 'Resume (${lastRead.surahNameSimple})' : 'Read Quran',
      type: NotificationType.dailyMissed,
      duration: const Duration(seconds: 8),
      onAction: () => _navigateToSurah(context, lastRead),
    );
  }

  /// Shows the 8-hour reminder notification displaying the exact last verse read
  void show8HourReminder(
    BuildContext context,
    BookmarkProvider bookmarkProvider,
  ) {
    final lastRead = bookmarkProvider.lastReadBookmark;

    final title = 'Continue Reading • نُورُ الْقُرْآن';
    final message = lastRead != null
        ? '8 hours have passed since your last recitation. Resume where you left off:'
        : 'Continue your Quran recitation journey today with heartfelt contemplation.';

    CelestialNotificationBanner.show(
      context: context,
      title: title,
      message: message,
      verseReference: lastRead != null
          ? 'Surah ${lastRead.surahNameSimple} ${lastRead.dualVerseReference}'
          : null,
      actionLabel: lastRead != null ? 'Resume' : 'Start Reading',
      type: NotificationType.reminder8Hour,
      duration: const Duration(seconds: 8),
      onAction: () => _navigateToSurah(context, lastRead),
    );
  }

  /// Helper to launch the target Surah
  static void _navigateToSurah(BuildContext context, Bookmark? lastRead) async {
    final surahId = lastRead?.surahId ?? 1;
    try {
      final chapters = await QuranService.fetchChapters();
      final target = chapters.firstWhere(
        (c) => c.id == surahId,
        orElse: () => chapters.first,
      );
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SurahScreen(chapter: target),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error navigating to surah: $e');
    }
  }

  /// Immediate preview trigger for testing and visual demonstration
  void triggerTestNotification(
    BuildContext context,
    BookmarkProvider bookmarkProvider, {
    bool isDaily = false,
  }) {
    if (isDaily) {
      showDailyMissedPop(context, bookmarkProvider);
    } else {
      show8HourReminder(context, bookmarkProvider);
    }
  }
}
