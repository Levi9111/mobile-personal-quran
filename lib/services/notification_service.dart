import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bookmark.dart';
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
  FlutterLocalNotificationsPlugin? _localNotifications;

  bool get reminder8HourEnabled => _reminder8HourEnabled;
  int get intervalHours => _intervalHours;
  FlutterLocalNotificationsPlugin? get localNotifications => _localNotifications;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _reminder8HourEnabled = prefs.getBool(_key8HourReminder) ?? true;
      _intervalHours = prefs.getInt(_keyIntervalHours) ?? 8;

      _localNotifications = FlutterLocalNotificationsPlugin();
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
        linux: LinuxInitializationSettings(defaultActionName: 'Open Noor'),
      );

      await _localNotifications?.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('Notification clicked with payload: ${response.payload}');
        },
      );

      final androidImpl = _localNotifications
          ?.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        await androidImpl.requestNotificationsPermission();
      }
    } catch (e) {
      debugPrint('Error initializing notification preferences/service: $e');
    }
  }

  /// Sends a real system notification directly to the mobile device notification shade
  Future<void> showSystemNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      final bigTextStyle = BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: 'Noor Quran',
      );
      final androidDetails = AndroidNotificationDetails(
        'noor_reminders_channel',
        'Noor Quran Reminders',
        channelDescription: 'Daily reflection and reading reminders from Noor Quran',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'Noor Quran Reminder',
        color: const Color(0xFFFBBF24),
        styleInformation: bigTextStyle,
        playSound: true,
        enableVibration: true,
      );
      final details = NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _localNotifications?.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payload,
      );
    } catch (e) {
      debugPrint('NotificationService: System notification post error: $e');
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

    // 1. Post real system notification to Android/iOS status bar
    showSystemNotification(
      id: 101,
      title: 'Daily Noor Reflection',
      body: "You haven't read any Quran verse today yet. Illuminate your heart with even a single ayah.",
      payload: lastRead?.verseKey,
    );

    // 2. Display generous in-app notification card
    CelestialNotificationBanner.show(
      context: context,
      title: 'Daily Noor Reflection',
      message: "You haven't read any Quran verse today yet. Illuminate your heart with even a single ayah.",
      verseReference: lastRead != null ? 'Last read: ${lastRead.dualVerseReference}' : null,
      actionLabel: lastRead != null ? 'Resume (${lastRead.surahNameSimple})' : 'Read Quran',
      type: NotificationType.dailyMissed,
      duration: const Duration(seconds: 9),
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

    final sysBody = lastRead != null
        ? 'Resume your recitation: Surah ${lastRead.surahNameSimple} Ayah ${lastRead.verseNumber} (${lastRead.dualVerseReference})'
        : message;

    // 1. Post real system notification to Android/iOS status bar
    showSystemNotification(
      id: 102,
      title: title,
      body: sysBody,
      payload: lastRead?.verseKey,
    );

    // 2. Display generous in-app notification card
    CelestialNotificationBanner.show(
      context: context,
      title: title,
      message: message,
      verseReference: lastRead != null
          ? 'Surah ${lastRead.surahNameSimple} ${lastRead.dualVerseReference}'
          : null,
      actionLabel: lastRead != null ? 'Resume' : 'Start Reading',
      type: NotificationType.reminder8Hour,
      duration: const Duration(seconds: 9),
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
