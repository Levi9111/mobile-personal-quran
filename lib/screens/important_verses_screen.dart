import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import '../models/important_verse.dart';
import '../providers/important_verses_provider.dart';
import '../services/quran_service.dart';
import '../theme/app_theme.dart';
import '../widgets/celestial_background.dart';
import '../widgets/important_verse_card.dart';

class ImportantVersesScreen extends StatefulWidget {
  final String? initialCategory;
  final String? initialOccasion;

  const ImportantVersesScreen({
    super.key,
    this.initialCategory,
    this.initialOccasion,
  });

  @override
  State<ImportantVersesScreen> createState() => _ImportantVersesScreenState();
}

class _ImportantVersesScreenState extends State<ImportantVersesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? _playingVerseId;
  bool _tajweedEnabled = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _playingVerseId = null;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ImportantVersesProvider>(context, listen: false);
      if (widget.initialCategory != null) {
        provider.setCategory(widget.initialCategory!);
      }
      if (widget.initialOccasion != null) {
        provider.setOccasion(widget.initialOccasion!);
      }
    });
  }

  void _onSearchChanged() {
    final provider = Provider.of<ImportantVersesProvider>(context, listen: false);
    provider.setSearchQuery(_searchController.text);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _toggleAudio(ImportantVerse verse) async {
    final audioUrl = verse.audioUrl;
    if (audioUrl == null || audioUrl.isEmpty) return;

    if (_playingVerseId == verse.id) {
      await _audioPlayer.pause();
      setState(() {
        _playingVerseId = null;
      });
    } else {
      await _audioPlayer.stop();
      final fullUrl = '${QuranService.audioBaseUrl}$audioUrl';
      await _audioPlayer.play(UrlSource(fullUrl));
      setState(() {
        _playingVerseId = verse.id;
      });
    }
  }

  void _showOccasionFilterModal(BuildContext context, ImportantVersesProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter by Occasion',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: provider.occasions.map((occ) {
                  final isSelected = provider.selectedOccasion == occ;
                  return ChoiceChip(
                    label: Text(occ),
                    selected: isSelected,
                    selectedColor: Theme.of(context).colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      provider.setOccasion(selected ? occ : 'All');
                      Navigator.pop(ctx);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<ImportantVersesProvider>(context);
    final verses = provider.filteredVerses;
    final dailyVerse = provider.dailyVerse;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Important Verses & Duas',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Favorites toggle action
          IconButton(
            icon: Icon(
              provider.showFavoritesOnly
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: provider.showFavoritesOnly ? Colors.redAccent : null,
            ),
            tooltip: provider.showFavoritesOnly ? 'Show all verses' : 'Show favorites only',
            onPressed: () => provider.toggleFavoritesOnly(),
          ),
          // Tajweed Colors Toggle
          TextButton.icon(
            onPressed: () {
              setState(() {
                _tajweedEnabled = !_tajweedEnabled;
              });
            },
            icon: Icon(
              _tajweedEnabled ? Icons.remove_red_eye_outlined : Icons.visibility_off_outlined,
              size: 15,
              color: theme.colorScheme.primary,
            ),
            label: Text(
              _tajweedEnabled ? 'Colours on' : 'Colours off',
              style: TextStyle(fontSize: 11, color: theme.colorScheme.primary),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CelestialBackground(
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryEmerald))
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Top Search & Hero Section
                  SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Search Bar
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search by verse, surah, keyword, or occasion…',
                            prefixIcon: const Icon(Icons.search_rounded, size: 20),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      provider.setSearchQuery('');
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: theme.cardTheme.color,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: theme.colorScheme.outline),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: theme.colorScheme.outline),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Occasion Selector Row
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _showOccasionFilterModal(context, provider),
                              icon: Icon(
                                Icons.tune_rounded,
                                size: 16,
                                color: theme.brightness == Brightness.dark
                                    ? AppTheme.celestialStarGold
                                    : const Color(0xFFB45309),
                              ),
                              label: Text(
                                provider.selectedOccasion == 'All'
                                    ? 'Filter Occasions'
                                    : 'Occasion: ${provider.selectedOccasion}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: provider.selectedOccasion != 'All'
                                      ? (theme.brightness == Brightness.dark
                                          ? AppTheme.celestialStarGold
                                          : const Color(0xFFD97706))
                                      : (theme.brightness == Brightness.dark
                                          ? AppTheme.celestialBorderIndigo
                                          : const Color(0xFFEADBCE)),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              ),
                            ),
                            if (provider.selectedOccasion != 'All' ||
                                provider.selectedCategory != 'All' ||
                                provider.showFavoritesOnly ||
                                provider.searchQuery.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () {
                                  _searchController.clear();
                                  provider.clearFilters();
                                },
                                child: Text(
                                  'Reset',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.brightness == Brightness.dark
                                        ? AppTheme.celestialStarlightBlue
                                        : const Color(0xFF0284C7),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Category Filter Horizontal Scroll
                        SizedBox(
                          height: 38,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: provider.categories.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final cat = provider.categories[index];
                              final isSelected = provider.selectedCategory == cat;
                              final isDark = theme.brightness == Brightness.dark;
                              return ChoiceChip(
                                label: Text(cat),
                                selected: isSelected,
                                selectedColor: isDark
                                    ? AppTheme.celestialStarGold
                                    : const Color(0xFFFEF3C7),
                                backgroundColor: isDark
                                    ? AppTheme.celestialDeepIndigo
                                    : Colors.white,
                                side: BorderSide(
                                  color: isSelected
                                      ? (isDark ? AppTheme.celestialStarGold : const Color(0xFFD97706))
                                      : (isDark ? AppTheme.celestialBorderIndigo : const Color(0xFFEADBCE)),
                                ),
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? (isDark ? AppTheme.celestialMidnight : const Color(0xFF92400E))
                                      : (isDark ? Colors.white70 : const Color(0xFF475569)),
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                onSelected: (selected) {
                                  provider.setCategory(selected ? cat : 'All');
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Daily Verse Spotlight Banner (only if no active search or filters)
                        if (dailyVerse != null &&
                            provider.searchQuery.isEmpty &&
                            provider.selectedCategory == 'All' &&
                            provider.selectedOccasion == 'All' &&
                            !provider.showFavoritesOnly) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: theme.brightness == Brightness.dark
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFF16233F),
                                        Color(0xFF0F172A),
                                        Color(0xFF080D1A),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : const LinearGradient(
                                      colors: [
                                        Colors.white,
                                        Color(0xFFFAF6EE),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: theme.brightness == Brightness.dark
                                    ? AppTheme.celestialStarGold.withOpacity(0.5)
                                    : const Color(0xFFEADBCE),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (theme.brightness == Brightness.dark
                                          ? AppTheme.celestialStarGold
                                          : const Color(0xFFB45309))
                                      .withOpacity(theme.brightness == Brightness.dark ? 0.12 : 0.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppTheme.celestialStarGold,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.auto_awesome,
                                            size: 10,
                                            color: AppTheme.celestialMidnight,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'DAILY SPOTLIGHT',
                                            style: GoogleFonts.karla(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.2,
                                              color: AppTheme.celestialMidnight,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${dailyVerse.surahName} ${dailyVerse.verseKey}',
                                      style: GoogleFonts.karla(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.celestialStarGold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  dailyVerse.title,
                                  style: GoogleFonts.cormorantGaramond(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dailyVerse.translation,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.karla(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurface.withOpacity(0.75),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Results Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              provider.showFavoritesOnly
                                  ? 'FAVORITE VERSES (${verses.length})'
                                  : 'ALL VERSES (${verses.length})',
                              style: GoogleFonts.karla(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: theme.colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                            if (provider.notesCount > 0)
                              Text(
                                '${provider.notesCount} personal reflections',
                                style: GoogleFonts.karla(
                                  fontSize: 11,
                                  color: AppTheme.metallicGold,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),

                // Verses List or Empty State
                verses.isEmpty
                    ? SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  provider.showFavoritesOnly
                                      ? Icons.favorite_border_rounded
                                      : Icons.search_off_rounded,
                                  size: 48,
                                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  provider.showFavoritesOnly
                                      ? 'No favorite verses yet'
                                      : 'No verses found',
                                  style: GoogleFonts.cormorantGaramond(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  provider.showFavoritesOnly
                                      ? 'Tap the heart icon on any verse card to save it here for quick daily recitation.'
                                      : 'Try adjusting your search keywords, category, or occasion filters.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    provider.clearFilters();
                                  },
                                  child: const Text('Reset All Filters'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          4,
                          16,
                          MediaQuery.of(context).padding.bottom + 28,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final verse = verses[index];
                              return ImportantVerseCard(
                                key: ValueKey(verse.id),
                                verse: verse,
                                isPlaying: _playingVerseId == verse.id,
                                onTogglePlay: () => _toggleAudio(verse),
                                tajweedEnabled: _tajweedEnabled,
                                onSelectOccasion: (occ) => provider.setOccasion(occ),
                              );
                            },
                            childCount: verses.length,
                          ),
                        ),
                      ),
              ],
            ),
      ),
    );
  }
}
