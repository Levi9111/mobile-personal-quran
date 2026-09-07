import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/chapter.dart';
import '../models/verse.dart';
import 'quran_service.dart';

class DownloadProgress {
  final int surahId;
  final int completedVerses;
  final int totalVerses;
  final double fraction;
  final bool isDone;
  final String? error;

  const DownloadProgress({
    required this.surahId,
    required this.completedVerses,
    required this.totalVerses,
    required this.fraction,
    this.isDone = false,
    this.error,
  });
}

class OfflineAudioManager {
  static final Map<int, bool> _activeCancellations = {};

  /// Base directory for offline Noor audio storage
  static Future<Directory> _getAudioBaseDir() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${docsDir.path}/noor_audio');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return audioDir;
  }

  /// Directory for a specific Surah
  static Future<Directory> getSurahAudioDir(int surahId) async {
    final baseDir = await _getAudioBaseDir();
    final surahDir = Directory('${baseDir.path}/surah_$surahId');
    if (!await surahDir.exists()) {
      await surahDir.create(recursive: true);
    }
    return surahDir;
  }

  /// Local file path for an individual verse
  static Future<String> getVerseFilePath(int surahId, int verseNumber) async {
    final surahDir = await getSurahAudioDir(surahId);
    return '${surahDir.path}/verse_${surahId}_$verseNumber.mp3';
  }

  /// Check if local audio file exists and is non-empty for this verse
  static Future<String?> getLocalVerseAudioPath(int surahId, int verseNumber) async {
    try {
      final path = await getVerseFilePath(surahId, verseNumber);
      final file = File(path);
      if (await file.exists() && (await file.length()) > 1024) {
        return path;
      }
    } catch (e) {
      debugPrint('OfflineAudioManager: Check verse audio error: $e');
    }
    return null;
  }

  /// Check how many verses of a Surah are downloaded locally
  static Future<int> getDownloadedVerseCount(int surahId) async {
    try {
      final surahDir = await getSurahAudioDir(surahId);
      if (!await surahDir.exists()) return 0;
      final files = surahDir.listSync().whereType<File>();
      int count = 0;
      for (final f in files) {
        if (f.path.endsWith('.mp3') && (await f.length()) > 1024) {
          count++;
        }
      }
      return count;
    } catch (e) {
      return 0;
    }
  }

  /// Check if Surah is completely downloaded
  static Future<bool> isSurahFullyDownloaded(int surahId, int totalVerses) async {
    if (totalVerses <= 0) return false;
    final downloaded = await getDownloadedVerseCount(surahId);
    return downloaded >= totalVerses;
  }

  /// Size of downloaded audio for a specific Surah in bytes
  static Future<int> getSurahDiskSizeBytes(int surahId) async {
    try {
      final surahDir = await getSurahAudioDir(surahId);
      if (!await surahDir.exists()) return 0;
      int bytes = 0;
      for (final f in surahDir.listSync().whereType<File>()) {
        bytes += await f.length();
      }
      return bytes;
    } catch (e) {
      return 0;
    }
  }

  /// Total size of all downloaded Noor Quran audio files in bytes
  static Future<int> getTotalAudioDiskSizeBytes() async {
    try {
      final baseDir = await _getAudioBaseDir();
      if (!await baseDir.exists()) return 0;
      int bytes = 0;
      for (final f in baseDir.listSync(recursive: true).whereType<File>()) {
        bytes += await f.length();
      }
      return bytes;
    } catch (e) {
      return 0;
    }
  }

  /// Human-readable formatting of byte count (e.g. "4.2 MB")
  static String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Delete all audio files for a single Surah
  static Future<void> deleteSurahAudio(int surahId) async {
    try {
      final surahDir = await getSurahAudioDir(surahId);
      if (await surahDir.exists()) {
        await surahDir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('OfflineAudioManager: Delete surah error: $e');
    }
  }

  /// Delete all downloaded audio files across all Surahs
  static Future<void> deleteAllAudio() async {
    try {
      final baseDir = await _getAudioBaseDir();
      if (await baseDir.exists()) {
        await baseDir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('OfflineAudioManager: Delete all audio error: $e');
    }
  }

  /// Request cancellation of an ongoing Surah download
  static void cancelDownload(int surahId) {
    _activeCancellations[surahId] = true;
  }

  /// Download all verses of a Surah with progress reporting
  static Stream<DownloadProgress> downloadSurah({
    required Chapter chapter,
    required List<Verse> verses,
  }) async* {
    _activeCancellations[chapter.id] = false;
    final total = verses.length;
    if (total == 0) {
      yield DownloadProgress(
        surahId: chapter.id,
        completedVerses: 0,
        totalVerses: 0,
        fraction: 1.0,
        isDone: true,
      );
      return;
    }

    final surahDir = await getSurahAudioDir(chapter.id);
    int completed = 0;

    // Check pre-existing files to avoid re-downloading
    for (final verse in verses) {
      final filePath = '${surahDir.path}/verse_${chapter.id}_${verse.verseNumber}.mp3';
      final file = File(filePath);
      if (await file.exists() && (await file.length()) > 1024) {
        completed++;
      }
    }

    yield DownloadProgress(
      surahId: chapter.id,
      completedVerses: completed,
      totalVerses: total,
      fraction: completed / total,
    );

    final client = http.Client();
    try {
      for (final verse in verses) {
        if (_activeCancellations[chapter.id] == true) {
          yield DownloadProgress(
            surahId: chapter.id,
            completedVerses: completed,
            totalVerses: total,
            fraction: completed / total,
            error: 'Download paused/cancelled.',
          );
          return;
        }

        final filePath = '${surahDir.path}/verse_${chapter.id}_${verse.verseNumber}.mp3';
        final file = File(filePath);

        if (await file.exists() && (await file.length()) > 1024) {
          continue;
        }

        if (verse.audioUrl != null && verse.audioUrl!.isNotEmpty) {
          final audioUrl = '${QuranService.audioBaseUrl}${verse.audioUrl}';
          try {
            final response = await client
                .get(Uri.parse(audioUrl), headers: QuranService.headers)
                .timeout(const Duration(seconds: 15));

            if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
              await file.writeAsBytes(response.bodyBytes, flush: true);
              completed++;
            }
          } catch (e) {
            debugPrint('OfflineAudioManager: Failed to download verse ${verse.verseNumber}: $e');
          }
        }

        yield DownloadProgress(
          surahId: chapter.id,
          completedVerses: completed,
          totalVerses: total,
          fraction: completed / total,
        );
      }

      yield DownloadProgress(
        surahId: chapter.id,
        completedVerses: completed,
        totalVerses: total,
        fraction: 1.0,
        isDone: true,
      );
    } finally {
      client.close();
      _activeCancellations.remove(chapter.id);
    }
  }
}
