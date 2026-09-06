import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bookmark.dart';

class BookmarkProvider with ChangeNotifier {
  static const String _keyLastRead = 'noor_last_read_bookmark';
  static const String _keyBookmarks = 'noor_saved_bookmarks';
  static const String _keyLastReadDate = 'noor_last_read_date';

  Bookmark? _lastReadBookmark;
  List<Bookmark> _bookmarks = [];
  bool _isLoading = true;
  DateTime? _lastReadDate;

  Bookmark? get lastReadBookmark => _lastReadBookmark;
  List<Bookmark> get bookmarks => List.unmodifiable(_bookmarks);
  bool get isLoading => _isLoading;
  DateTime? get lastReadDate => _lastReadDate;

  BookmarkProvider() {
    loadBookmarks();
  }

  Future<void> loadBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load Last Read
      final lastReadJson = prefs.getString(_keyLastRead);
      if (lastReadJson != null && lastReadJson.isNotEmpty) {
        try {
          _lastReadBookmark = Bookmark.fromJson(lastReadJson);
        } catch (e) {
          debugPrint('Error parsing last read bookmark: $e');
        }
      }

      // Load Saved Bookmarks
      final bookmarksList = prefs.getStringList(_keyBookmarks);
      if (bookmarksList != null) {
        _bookmarks = bookmarksList
            .map((item) {
              try {
                return Bookmark.fromJson(item);
              } catch (e) {
                return null;
              }
            })
            .whereType<Bookmark>()
            .toList();
      }

      // Load last read timestamp
      final dateStr = prefs.getString(_keyLastReadDate);
      if (dateStr != null) {
        _lastReadDate = DateTime.tryParse(dateStr);
      } else if (_lastReadBookmark != null) {
        _lastReadDate = _lastReadBookmark!.timestamp;
      }
    } catch (e) {
      debugPrint('Error loading bookmarks from storage: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Checks whether a specific verse is in saved bookmarks
  bool isBookmarked(int surahId, int verseNumber) {
    final targetId = '$surahId:$verseNumber';
    return _bookmarks.any((b) => b.id == targetId || (b.surahId == surahId && b.verseNumber == verseNumber));
  }

  /// Sets the primary "Last Read" bookmark for the day and records reading activity.
  Future<void> setLastRead(Bookmark bookmark) async {
    final updated = bookmark.copyWith(
      isLastRead: true,
      timestamp: DateTime.now(),
    );
    _lastReadBookmark = updated;
    _lastReadDate = DateTime.now();

    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastRead, updated.toJson());
      await prefs.setString(_keyLastReadDate, _lastReadDate!.toIso8601String());
    } catch (e) {
      debugPrint('Error saving last read bookmark: $e');
    }
  }

  /// Toggles saving a verse to bookmarks list
  Future<bool> toggleBookmark(Bookmark bookmark) async {
    final targetId = '${bookmark.surahId}:${bookmark.verseNumber}';
    final existingIndex = _bookmarks.indexWhere(
      (b) => b.id == targetId || (b.surahId == bookmark.surahId && b.verseNumber == bookmark.verseNumber),
    );

    bool added = false;
    if (existingIndex >= 0) {
      _bookmarks.removeAt(existingIndex);
      added = false;
    } else {
      _bookmarks.insert(
        0,
        bookmark.copyWith(
          id: targetId,
          timestamp: DateTime.now(),
        ),
      );
      added = true;
    }

    // Also update last read when user bookmarks a verse!
    await setLastRead(bookmark);

    notifyListeners();
    await _persistBookmarks();
    return added;
  }

  /// Removes a bookmark by its ID
  Future<void> removeBookmark(String id) async {
    _bookmarks.removeWhere((b) => b.id == id);
    notifyListeners();
    await _persistBookmarks();
  }

  Future<void> _persistBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _bookmarks.map((b) => b.toJson()).toList();
      await prefs.setStringList(_keyBookmarks, list);
    } catch (e) {
      debugPrint('Error persisting bookmarks: $e');
    }
  }

  /// Checks if user has read any verse today
  bool hasReadToday() {
    final checkDate = _lastReadDate ?? _lastReadBookmark?.timestamp;
    if (checkDate == null) return false;
    final now = DateTime.now();
    return checkDate.year == now.year &&
        checkDate.month == now.month &&
        checkDate.day == now.day;
  }
}
