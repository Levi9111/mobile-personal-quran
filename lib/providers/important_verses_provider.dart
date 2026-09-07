import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/important_verse.dart';

class ImportantVersesProvider extends ChangeNotifier {
  List<ImportantVerse> _allVerses = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedOccasion = 'All';
  bool _showFavoritesOnly = false;
  Set<int> _favoriteIds = {};
  Map<String, String> _personalNotes = {};

  static const String _favoritesKey = 'favorite_important_verses_v1';
  static const String _notesKey = 'personal_verse_notes_v1';

  ImportantVersesProvider() {
    loadData();
  }

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedOccasion => _selectedOccasion;
  bool get showFavoritesOnly => _showFavoritesOnly;
  int get favoritesCount => _favoriteIds.length;
  int get notesCount => _personalNotes.length;

  List<ImportantVerse> get allVerses => _allVerses;

  List<String> get categories {
    final set = <String>{'All'};
    for (final v in _allVerses) {
      if (v.category.isNotEmpty) set.add(v.category);
    }
    return set.toList();
  }

  List<String> get occasions {
    final set = <String>{'All'};
    for (final v in _allVerses) {
      for (final occ in v.occasions) {
        if (occ.isNotEmpty) set.add(occ);
      }
    }
    return set.toList();
  }

  ImportantVerse? get dailyVerse {
    if (_allVerses.isEmpty) return null;
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final index = dayOfYear % _allVerses.length;
    return _allVerses[index];
  }

  List<ImportantVerse> get filteredVerses {
    return _allVerses.where((verse) {
      if (_showFavoritesOnly && !_favoriteIds.contains(verse.id)) {
        return false;
      }
      if (_selectedCategory != 'All' && verse.category != _selectedCategory) {
        return false;
      }
      if (_selectedOccasion != 'All' && !verse.occasions.contains(_selectedOccasion)) {
        return false;
      }
      if (_searchQuery.isNotEmpty && !verse.matchesQuery(_searchQuery)) {
        return false;
      }
      return true;
    }).toList();
  }

  bool isFavorite(int id) => _favoriteIds.contains(id);

  String? getPersonalNote(String verseKey) => _personalNotes[verseKey];

  bool hasPersonalNote(String verseKey) {
    final note = _personalNotes[verseKey];
    return note != null && note.trim().isNotEmpty;
  }

  Future<void>? _loadFuture;

  Future<void> reload() async {
    _loadFuture = null;
    await _performLoadData();
  }

  Future<void> loadData() {
    _loadFuture ??= _performLoadData();
    return _loadFuture!;
  }

  Future<void> _performLoadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Load local JSON asset
      final jsonString = await rootBundle.loadString('assets/data/important_verses.json');
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final list = data['verses'] as List<dynamic>;
      _allVerses = list
          .map((item) => ImportantVerse.fromJson(item as Map<String, dynamic>))
          .toList();

      // 2. Load favorites from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final favList = prefs.getStringList(_favoritesKey) ?? [];
      _favoriteIds = favList.map((e) => int.tryParse(e) ?? -1).where((e) => e != -1).toSet();

      // 3. Load personal notes from SharedPreferences
      final notesRaw = prefs.getString(_notesKey);
      if (notesRaw != null && notesRaw.isNotEmpty) {
        final decoded = jsonDecode(notesRaw) as Map<String, dynamic>;
        _personalNotes = decoded.map((k, v) => MapEntry(k, v.toString()));
      }
    } catch (e) {
      debugPrint('ImportantVersesProvider: Error loading data ($e)');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setOccasion(String occasion) {
    _selectedOccasion = occasion;
    notifyListeners();
  }

  void toggleFavoritesOnly() {
    _showFavoritesOnly = !_showFavoritesOnly;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'All';
    _selectedOccasion = 'All';
    _showFavoritesOnly = false;
    notifyListeners();
  }

  Future<void> toggleFavorite(int id) async {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _favoritesKey,
        _favoriteIds.map((e) => e.toString()).toList(),
      );
    } catch (e) {
      debugPrint('ImportantVersesProvider: Error saving favorites ($e)');
    }
  }

  Future<void> savePersonalNote(String verseKey, String note) async {
    final trimmed = note.trim();
    if (trimmed.isEmpty) {
      _personalNotes.remove(verseKey);
    } else {
      _personalNotes[verseKey] = trimmed;
    }
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_notesKey, jsonEncode(_personalNotes));
    } catch (e) {
      debugPrint('ImportantVersesProvider: Error saving notes ($e)');
    }
  }

  Future<void> deletePersonalNote(String verseKey) async {
    if (_personalNotes.containsKey(verseKey)) {
      _personalNotes.remove(verseKey);
      notifyListeners();

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_notesKey, jsonEncode(_personalNotes));
      } catch (e) {
        debugPrint('ImportantVersesProvider: Error deleting note ($e)');
      }
    }
  }

  Future<void> removePersonalNote(String verseKey) => deletePersonalNote(verseKey);
  Future<void> loadVerses() => loadData();
}
