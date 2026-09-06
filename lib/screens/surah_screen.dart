import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import '../models/bookmark.dart';
import '../models/chapter.dart';
import '../models/verse.dart';
import '../providers/bookmark_provider.dart';
import '../services/quran_service.dart';
import '../theme/app_theme.dart';
import '../utils/arabic_numerals.dart';
import '../widgets/bookmark_sheet.dart';
import '../widgets/celestial_notification_banner.dart';
import '../widgets/tajweed_legend.dart';
import '../widgets/tajweed_text.dart';

class SurahScreen extends StatefulWidget {
  final Chapter chapter;
  final int? initialVerseNumber;

  const SurahScreen({
    super.key,
    required this.chapter,
    this.initialVerseNumber,
  });

  @override
  State<SurahScreen> createState() => _SurahScreenState();
}

class _SurahScreenState extends State<SurahScreen> {
  late Future<List<Verse>> _versesFuture;
  bool _tajweedEnabled = true;
  String? _playingVerseKey;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ScrollController _scrollController = ScrollController();
  bool _hasAutoScrolled = false;

  static const String bismillahText = "بِسۡمِ اللهِ الرَّحۡمٰنِ الرَّحِيۡمِ";

  @override
  void initState() {
    super.initState();
    _versesFuture = QuranService.fetchVerses(widget.chapter.id);
    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _playingVerseKey = null;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleAudio(String verseKey, String? audioUrl) async {
    if (audioUrl == null || audioUrl.isEmpty) return;

    if (_playingVerseKey == verseKey) {
      await _audioPlayer.pause();
      setState(() {
        _playingVerseKey = null;
      });
    } else {
      await _audioPlayer.stop();
      final fullUrl = '${QuranService.audioBaseUrl}$audioUrl';
      await _audioPlayer.play(UrlSource(fullUrl));
      setState(() {
        _playingVerseKey = verseKey;
      });
    }
  }

  void _scrollToInitialVerse(List<Verse> verses) {
    if (_hasAutoScrolled || widget.initialVerseNumber == null) return;
    _hasAutoScrolled = true;

    final targetIndex = verses.indexWhere(
      (v) => v.verseNumber == widget.initialVerseNumber,
    );

    if (targetIndex > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Approximate verse height estimation for smooth scroll
        final targetOffset = (targetIndex * 240.0).clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        );
        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chapter = widget.chapter;
    final isDark = theme.brightness == Brightness.dark;
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Surah ${chapter.nameSimple}',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Bookmark Sheet action
          IconButton(
            icon: const Icon(Icons.bookmarks_rounded, size: 20),
            color: AppTheme.celestialStarGold,
            tooltip: 'View Bookmarks',
            onPressed: () => BookmarkSheet.show(context),
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
              size: 16,
              color: theme.colorScheme.primary,
            ),
            label: Text(
              _tajweedEnabled ? 'Colours on' : 'Colours off',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.28 : 0.14,
              child: Image.asset(
                'assets/images/celestial_clouds.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          FutureBuilder<List<Verse>>(
            future: _versesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryEmerald,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text('Error loading verses: ${snapshot.error}'),
              ),
            );
          }

          final verses = snapshot.data ?? [];
          _scrollToInitialVerse(verses);

          return CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Celestial Surah Header Banner with image texture
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          children: [
                            // Atmospheric subtle stars and clouds image
                            Positioned.fill(
                              child: Opacity(
                                opacity: isDark ? 0.25 : 0.12,
                                child: Image.asset(
                                  'assets/images/celestial_stars.jpg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                              decoration: BoxDecoration(
                                gradient: isDark
                                    ? LinearGradient(
                                        colors: [
                                          const Color(0xFF131F3A).withOpacity(0.92),
                                          const Color(0xFF0F172A).withOpacity(0.92),
                                          const Color(0xFF080D1A).withOpacity(0.95),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      )
                                    : LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.95),
                                          const Color(0xFFF1F6FE).withOpacity(0.95),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isDark
                                      ? AppTheme.celestialStarGold.withOpacity(0.5)
                                      : const Color(0xFFD6E2F0),
                                  width: 1.2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Glowing anime logo emblem
                                  Container(
                                    width: 48,
                                    height: 48,
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppTheme.celestialStarGold,
                                          AppTheme.celestialStarlightBlue,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.celestialStarGold.withOpacity(0.35),
                                          blurRadius: 14,
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppTheme.celestialMidnight,
                                      ),
                                      padding: const EdgeInsets.all(2),
                                      child: ClipOval(
                                        child: Image.asset(
                                          'assets/images/noor_logo.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    chapter.nameArabic,
                                    style: GoogleFonts.scheherazadeNew(
                                      fontSize: 40,
                                      color: isDark
                                          ? AppTheme.celestialStarGold
                                          : const Color(0xFF1E3A8A),
                                    ),
                                  ),
                                  Text(
                                    chapter.nameSimple,
                                    style: GoogleFonts.cormorantGaramond(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${chapter.translatedName} · ${chapter.versesCount} ayahs · ${chapter.revelationPlace}',
                                    style: GoogleFonts.karla(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurface.withOpacity(0.65),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      const TajweedLegendWidget(),
                      if (chapter.id != 1 && chapter.id != 9) ...[
                        const SizedBox(height: 20),
                        TajweedTextWidget(
                          text: bismillahText,
                          enabled: _tajweedEnabled,
                          fontSize: 28,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Verses List
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  MediaQuery.of(context).padding.bottom + 28,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final verse = verses[index];
                      final isPlaying = _playingVerseKey == verse.verse_key;
                      final isBookmarked = bookmarkProvider.isBookmarked(chapter.id, verse.verseNumber);
                      final isLastRead = bookmarkProvider.lastReadBookmark?.surahId == chapter.id &&
                          bookmarkProvider.lastReadBookmark?.verseNumber == verse.verseNumber;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isPlaying
                              ? (isDark
                                  ? const Color(0xFF16233F)
                                  : const Color(0xFFFEF9C3).withOpacity(0.4))
                              : theme.cardTheme.color,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isPlaying || isLastRead
                                ? AppTheme.celestialStarGold
                                : (isDark
                                    ? AppTheme.celestialBorderIndigo
                                    : AppTheme.lightBorder),
                            width: (isPlaying || isLastRead) ? 1.5 : 1,
                          ),
                          boxShadow: (isPlaying || isLastRead)
                              ? [
                                  BoxShadow(
                                    color: AppTheme.celestialStarGold.withOpacity(0.2),
                                    blurRadius: 14,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Arabic Verse Text
                            TajweedTextWidget(
                              text: verse.textIndopak,
                              enabled: _tajweedEnabled,
                              fontSize: 26,
                            ),
                            const SizedBox(height: 14),

                            // Translation Text
                            Text(
                              verse.translationText,
                              style: GoogleFonts.karla(
                                fontSize: 14,
                                height: 1.5,
                                color: theme.colorScheme.onSurface.withOpacity(0.85),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Action and Info Row
                            Row(
                              children: [
                                // Dual English & Arabic Number Badge: [chapter]:[verse] • [سورة]:[آية]
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppTheme.celestialStarGold.withOpacity(0.12)
                                        : const Color(0xFF1E3A8A).withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isDark
                                          ? AppTheme.celestialStarGold.withOpacity(0.5)
                                          : const Color(0xFF1E3A8A).withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        ArabicNumeralHelper.formatDual(chapter.id, verse.verseNumber),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? AppTheme.celestialStarGold
                                              : const Color(0xFF1E3A8A),
                                        ),
                                      ),
                                      if (isLastRead) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppTheme.celestialStarGold,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'LAST READ',
                                            style: GoogleFonts.karla(
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.celestialMidnight,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const Spacer(),

                                // Bookmark Button
                                IconButton(
                                  icon: Icon(
                                    (isBookmarked || isLastRead)
                                        ? Icons.bookmark_rounded
                                        : Icons.bookmark_border_rounded,
                                    size: 22,
                                    color: (isBookmarked || isLastRead)
                                        ? AppTheme.celestialStarGold
                                        : theme.colorScheme.onSurface.withOpacity(0.4),
                                  ),
                                  tooltip: 'Save Bookmark for Today',
                                  onPressed: () async {
                                    final bookmark = Bookmark(
                                      id: '${chapter.id}:${verse.verseNumber}',
                                      surahId: chapter.id,
                                      surahNameSimple: chapter.nameSimple,
                                      surahNameArabic: chapter.nameArabic,
                                      verseNumber: verse.verseNumber,
                                      verseKey: verse.verse_key,
                                      arabicText: verse.textIndopak,
                                      translationText: verse.translationText,
                                      timestamp: DateTime.now(),
                                    );

                                    final added = await bookmarkProvider.toggleBookmark(bookmark);

                                    if (context.mounted) {
                                      CelestialNotificationBanner.show(
                                        context: context,
                                        title: added ? 'Bookmark Saved • تَمَّ الْحِفْظ' : 'Bookmark Removed',
                                        message: added
                                            ? 'Surah ${chapter.nameSimple} marked as your spot for today.'
                                            : 'Removed from bookmarks.',
                                        verseReference: ArabicNumeralHelper.formatDual(chapter.id, verse.verseNumber),
                                        type: NotificationType.bookmarkSaved,
                                        duration: const Duration(seconds: 4),
                                      );
                                    }
                                  },
                                ),

                                const SizedBox(width: 4),

                                // Audio Play/Pause Button
                                OutlinedButton.icon(
                                  onPressed: () => _toggleAudio(verse.verse_key, verse.audioUrl),
                                  icon: Icon(
                                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                    size: 16,
                                    color: isPlaying
                                        ? (isDark ? AppTheme.celestialMidnight : Colors.white)
                                        : (isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A)),
                                  ),
                                  label: Text(
                                    isPlaying ? 'Pause' : 'Play',
                                    style: TextStyle(
                                      color: isPlaying
                                          ? (isDark ? AppTheme.celestialMidnight : Colors.white)
                                          : (isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A)),
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: isPlaying
                                        ? (isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A))
                                        : Colors.transparent,
                                    side: BorderSide(
                                      color: isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A),
                                      width: 1.2,
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: verses.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
        ],
      ),
    );
  }
}
