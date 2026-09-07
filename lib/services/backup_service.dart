import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/bookmark_provider.dart';
import '../providers/important_verses_provider.dart';
import '../providers/quran_typography_provider.dart';
import '../providers/theme_provider.dart';

class BackupResult {
  final bool success;
  final String message;
  final int bookmarksCount;
  final int notesCount;
  final int favoritesCount;
  final String? lastRead;

  const BackupResult({
    required this.success,
    required this.message,
    this.bookmarksCount = 0,
    this.notesCount = 0,
    this.favoritesCount = 0,
    this.lastRead,
  });
}

class BackupService {
  static const String appIdentifier = 'Noor Quran';
  static const int schemaVersion = 1;

  // SharedPreferences Keys matching providers
  static const String _keyBookmarks = 'quran_bookmarks';
  static const String _keyLastRead = 'quran_last_read';
  static const String _keyLastReadDate = 'quran_last_read_date';
  static const String _keyFavorites = 'fav_important_verses';
  static const String _keyNotes = 'notes_important_verses';
  static const String _keyScriptType = 'quran_arabic_script_type';
  static const String _keyFontSize = 'quran_arabic_font_size';
  static const String _key8HourReminder = 'reminder_8hour_enabled';
  static const String _keyIntervalHours = 'reminder_interval_hours';
  static const String _keyTheme = 'noor-theme';

  /// Collects all current user data into a structured JSON-serializable Map
  static Future<Map<String, dynamic>> createBackupData() async {
    final prefs = await SharedPreferences.getInstance();

    final bookmarks = prefs.getStringList(_keyBookmarks) ?? [];
    final lastRead = prefs.getString(_keyLastRead);
    final lastReadDate = prefs.getString(_keyLastReadDate);
    final favorites = prefs.getStringList(_keyFavorites) ?? [];
    final notesRaw = prefs.getString(_keyNotes);
    Map<String, dynamic> notes = {};
    if (notesRaw != null && notesRaw.isNotEmpty) {
      try {
        notes = jsonDecode(notesRaw) as Map<String, dynamic>;
      } catch (_) {}
    }

    final scriptType = prefs.getInt(_keyScriptType) ?? 0;
    final fontSize = prefs.getDouble(_keyFontSize) ?? 24.0;
    final notifEnabled = prefs.getBool(_key8HourReminder) ?? true;
    final notifInterval = prefs.getInt(_keyIntervalHours) ?? 8;
    final theme = prefs.getString(_keyTheme) ?? 'dark';

    return {
      'app': appIdentifier,
      'schema_version': schemaVersion,
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'data': {
        'bookmarks': bookmarks,
        'last_read': lastRead,
        'last_read_date': lastReadDate,
        'favorites': favorites,
        'personal_notes': notes,
        'typography': {
          'script_type': scriptType,
          'font_size': fontSize,
        },
        'notifications': {
          'enabled': notifEnabled,
          'interval_hours': notifInterval,
        },
        'theme': theme,
      },
    };
  }

  /// Exports backup data as a formatted JSON String
  static Future<String> exportBackupJson({bool pretty = true}) async {
    final data = await createBackupData();
    if (pretty) {
      return const JsonEncoder.withIndent('  ').convert(data);
    }
    return jsonEncode(data);
  }

  /// Writes the backup JSON into a temporary file and triggers the system share sheet
  static Future<File> exportBackupToFile() async {
    final jsonStr = await exportBackupJson(pretty: true);
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${tempDir.path}/noor_quran_backup_$timestamp.json');
    await file.writeAsString(jsonStr, flush: true);
    return file;
  }

  /// Share backup file via standard OS share dialog
  static Future<void> shareBackup() async {
    final file = await exportBackupToFile();
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/json')],
      subject: 'Noor Quran Data Backup',
      text: 'Noor Quran Data Backup (${DateTime.now().toLocal().toString().split('.')[0]})',
    );
  }

  /// Restores user data from a JSON string and updates all active providers
  static Future<BackupResult> restoreFromJson(
    String rawJson,
    BuildContext context,
  ) async {
    try {
      final trimmed = rawJson.trim();
      if (trimmed.isEmpty) {
        return const BackupResult(
          success: false,
          message: 'Backup data is empty.',
        );
      }

      final dynamic parsed = jsonDecode(trimmed);
      if (parsed is! Map<String, dynamic>) {
        return const BackupResult(
          success: false,
          message: 'Invalid backup format (expected JSON object).',
        );
      }

      // Check if wrapped in { app: "Noor Quran", data: { ... } } or direct map
      final Map<String, dynamic> data =
          parsed['data'] is Map<String, dynamic>
              ? parsed['data'] as Map<String, dynamic>
              : parsed;

      final prefs = await SharedPreferences.getInstance();

      // 1. Restore Bookmarks
      int bookmarksCount = 0;
      if (data.containsKey('bookmarks') && data['bookmarks'] is List) {
        final rawBookmarks = (data['bookmarks'] as List)
            .map((e) => e.toString())
            .toList();
        await prefs.setStringList(_keyBookmarks, rawBookmarks);
        bookmarksCount = rawBookmarks.length;
      }

      // 2. Restore Last Read
      String? lastReadVerse;
      if (data.containsKey('last_read') && data['last_read'] != null) {
        final lastReadStr = data['last_read'].toString();
        await prefs.setString(_keyLastRead, lastReadStr);
        try {
          final lrMap = jsonDecode(lastReadStr) as Map<String, dynamic>;
          lastReadVerse = 'Surah ${lrMap['surahName'] ?? lrMap['surahId']} : ${lrMap['verseNumber']}';
        } catch (_) {
          lastReadVerse = 'Restored';
        }
      }
      if (data.containsKey('last_read_date') && data['last_read_date'] != null) {
        await prefs.setString(_keyLastReadDate, data['last_read_date'].toString());
      }

      // 3. Restore Favorites
      int favoritesCount = 0;
      if (data.containsKey('favorites') && data['favorites'] is List) {
        final rawFavs = (data['favorites'] as List).map((e) => e.toString()).toList();
        await prefs.setStringList(_keyFavorites, rawFavs);
        favoritesCount = rawFavs.length;
      }

      // 4. Restore Personal Notes
      int notesCount = 0;
      if (data.containsKey('personal_notes') && data['personal_notes'] is Map) {
        final rawNotes = data['personal_notes'] as Map<String, dynamic>;
        await prefs.setString(_keyNotes, jsonEncode(rawNotes));
        notesCount = rawNotes.length;
      }

      // 5. Restore Typography
      if (data.containsKey('typography') && data['typography'] is Map) {
        final typo = data['typography'] as Map<String, dynamic>;
        if (typo['script_type'] is int) {
          await prefs.setInt(_keyScriptType, typo['script_type'] as int);
        }
        if (typo['font_size'] != null) {
          await prefs.setDouble(_keyFontSize, (typo['font_size'] as num).toDouble());
        }
      }

      // 6. Restore Notifications
      if (data.containsKey('notifications') && data['notifications'] is Map) {
        final notif = data['notifications'] as Map<String, dynamic>;
        if (notif['enabled'] is bool) {
          await prefs.setBool(_key8HourReminder, notif['enabled'] as bool);
        }
        if (notif['interval_hours'] is int) {
          await prefs.setInt(_keyIntervalHours, notif['interval_hours'] as int);
        }
      }

      // 7. Restore Theme
      if (data.containsKey('theme') && data['theme'] is String) {
        await prefs.setString(_keyTheme, data['theme'] as String);
      }

      // Reload providers in context
      try {
        await context.read<BookmarkProvider>().loadBookmarks();
        await context.read<ImportantVersesProvider>().reload();
        await context.read<QuranTypographyProvider>().reload();
        await context.read<ThemeProvider>().reload();
      } catch (e) {
        debugPrint('BackupService: Note during provider reload: $e');
      }

      return BackupResult(
        success: true,
        message: 'Data successfully restored!',
        bookmarksCount: bookmarksCount,
        notesCount: notesCount,
        favoritesCount: favoritesCount,
        lastRead: lastReadVerse,
      );
    } catch (e) {
      return BackupResult(
        success: false,
        message: 'Failed to restore backup: $e',
      );
    }
  }
}
