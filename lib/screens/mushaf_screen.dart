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
import '../widgets/concise_tafsir_sheet.dart';
import '../widgets/tajweed_text.dart';
import '../services/offline_audio_manager.dart';
import '../widgets/offline_audio_sheet.dart';

class MushafScreen extends StatefulWidget {
  final Chapter chapter;
  final int? initialVerseNumber;

  const MushafScreen({
    super.key,
    required this.chapter,
    this.initialVerseNumber,
  });

  @override
  State<MushafScreen> createState() => _MushafScreenState();
}

class _MushafScreenState extends State<MushafScreen> {
  late Future<List<Verse>> _versesFuture;
  late PageController _pageController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  int _currentPageIndex = 0;
  List<List<Verse>> _pages = [];
  Verse? _selectedVerse;
  String? _playingVerseKey;
  bool _tajweedEnabled = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _versesFuture = QuranService.fetchVerses(widget.chapter.id).then((verses) {
      _paginate(verses);
      _jumpToInitialVerse(verses);
      return verses;
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _playingVerseKey = null;
        });
      }
    });
  }

  void _paginate(List<Verse> verses) {
    // 15-line Madani mushaf contains roughly 75 to 90 words per page
    const int targetWordsPerPage = 80;
    final List<List<Verse>> result = [];
    List<Verse> currentPage = [];
    int currentWordCount = 0;

    for (final verse in verses) {
      final int words = verse.textIndopak.trim().split(RegExp(r'\s+')).length;
      if (currentWordCount + words > targetWordsPerPage && currentPage.isNotEmpty) {
        result.add(List.from(currentPage));
        currentPage = [verse];
        currentWordCount = words;
      } else {
        currentPage.add(verse);
        currentWordCount += words;
      }
    }

    if (currentPage.isNotEmpty) {
      result.add(currentPage);
    }

    setState(() {
      _pages = result.isEmpty ? [verses] : result;
    });
  }

  void _jumpToInitialVerse(List<Verse> verses) {
    if (widget.initialVerseNumber == null || _pages.isEmpty) return;
    for (int p = 0; p < _pages.length; p++) {
      final found = _pages[p].any((v) => v.verseNumber == widget.initialVerseNumber);
      if (found) {
        _currentPageIndex = p;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients) {
            _pageController.jumpToPage(p);
          }
          final v = verses.firstWhere(
            (item) => item.verseNumber == widget.initialVerseNumber,
            orElse: () => verses.first,
          );
          setState(() {
            _selectedVerse = v;
          });
        });
        break;
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _audioPlayer.dispose();
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

      // Check if verse audio is stored offline locally
      final parts = verseKey.split(':');
      final surahId = int.tryParse(parts[0]) ?? widget.chapter.id;
      final verseNum = parts.length > 1 ? int.tryParse(parts[1]) ?? 1 : 1;
      final localPath = await OfflineAudioManager.getLocalVerseAudioPath(surahId, verseNum);

      if (localPath != null) {
        await _audioPlayer.play(DeviceFileSource(localPath));
      } else {
        final fullUrl = '${QuranService.audioBaseUrl}$audioUrl';
        await _audioPlayer.play(UrlSource(fullUrl));
      }

      setState(() {
        _playingVerseKey = verseKey;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final chapter = widget.chapter;
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF070D1A) : const Color(0xFFFFFDF8),
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'Surah ${chapter.nameSimple}',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Traditional Madani Mushaf Mode',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 0.8,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
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
          IconButton(
            icon: Icon(
              _tajweedEnabled ? Icons.visibility_rounded : Icons.visibility_off_outlined,
              size: 20,
              color: _tajweedEnabled ? AppTheme.primaryEmerald : Colors.grey,
            ),
            tooltip: _tajweedEnabled ? 'Tajweed colours enabled' : 'Tajweed colours disabled',
            onPressed: () {
              setState(() {
                _tajweedEnabled = !_tajweedEnabled;
              });
            },
          ),
          // Offline Audio Manager
          IconButton(
            icon: const Icon(Icons.download_for_offline_outlined, size: 20),
            color: AppTheme.celestialStarlightBlue,
            tooltip: 'Offline Audio Manager',
            onPressed: () async {
              final verses = await _versesFuture;
              if (!mounted) return;
              OfflineAudioSheet.show(
                context,
                chapter: chapter,
                verses: verses,
                onStatusChanged: () => setState(() {}),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Verse>>(
        future: _versesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryEmerald),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text('Error loading Mushaf pages: ${snapshot.error}'),
              ),
            );
          }

          if (_pages.isEmpty) {
            return const Center(child: Text('No verses available.'));
          }

          return Stack(
            children: [
              // 1. Anime celestial subtle background texture
              Positioned.fill(
                child: Opacity(
                  opacity: isDark ? 0.22 : 0.08,
                  child: Image.asset(
                    'assets/images/anime_celestial_bg.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // 2. Horizontal PageView mimicking a physical printed Quran
              // Right-to-Left natural Arabic book swiping
              Positioned.fill(
                child: PageView.builder(
                  controller: _pageController,
                  reverse: true, // Natural Arabic RTL swipe: swipe right for next page!
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPageIndex = index;
                    });
                  },
                  itemBuilder: (context, pageIdx) {
                    final pageVerses = _pages[pageIdx];
                    final isFirstPage = pageIdx == 0;

                    return _buildMushafPage(
                      context,
                      pageVerses: pageVerses,
                      pageNumber: pageIdx + 1,
                      totalPages: _pages.length,
                      isFirstPage: isFirstPage,
                      chapter: chapter,
                      isDark: isDark,
                    );
                  },
                ),
              ),

              // 3. Floating Selected Ayah Action Bar (when an ayah is tapped)
              if (_selectedVerse != null)
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: MediaQuery.of(context).padding.bottom + 12,
                  child: _buildAyahActionBar(
                    context,
                    verse: _selectedVerse!,
                    chapter: chapter,
                    bookmarkProvider: bookmarkProvider,
                    isDark: isDark,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Builds a single physical-style Mushaf page with top and bottom borders
  Widget _buildMushafPage(
    BuildContext context, {
    required List<Verse> pageVerses,
    required int pageNumber,
    required int totalPages,
    required bool isFirstPage,
    required Chapter chapter,
    required bool isDark,
  }) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A).withOpacity(0.92) : const Color(0xFFFFFDF5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? AppTheme.celestialStarGold.withOpacity(0.4)
                  : const Color(0xFFD4AF37).withOpacity(0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? AppTheme.celestialStarGold.withOpacity(0.12)
                    : const Color(0xFFD4AF37).withOpacity(0.18),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            children: [
              // Top Mushaf Margin: Surah Name & Juz Name
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark
                          ? AppTheme.celestialStarGold.withOpacity(0.25)
                          : const Color(0xFFD4AF37).withOpacity(0.35),
                      width: 0.8,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'سُورَةُ ${chapter.nameArabic}',
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.celestialStarGold,
                      ),
                    ),
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: AppTheme.celestialStarGold,
                    ),
                    Text(
                      'الجزء ${ArabicNumeralHelper.toArabicDigits(((chapter.id - 1) ~/ 4 + 1).toString())}',
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.celestialStarGold,
                      ),
                    ),
                  ],
                ),
              ),

              // Mushaf Page Body: Continuous Flowing Quranic Text
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    children: [
                      // Surah Header Banner if it's the very first page of the Surah
                      if (isFirstPage) ...[
                        _buildSurahHeaderBanner(chapter, isDark),
                        const SizedBox(height: 12),
                        if (chapter.id != 1 && chapter.id != 9) ...[
                          const Text(
                            'بِسۡمِ اللهِ الرَّحۡمٰنِ الرَّحِيۡمِ',
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.celestialStarGold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 14),
                        ],
                      ],

                      // Flowing Quranic text with interactive verse taps and end-ayah stops
                      _buildContinuousPageText(pageVerses, isDark),
                    ],
                  ),
                ),
              ),

              // Bottom Mushaf Margin: Page Number
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? AppTheme.celestialStarGold.withOpacity(0.25)
                          : const Color(0xFFD4AF37).withOpacity(0.35),
                      width: 0.8,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'صفحة ${ArabicNumeralHelper.toArabicDigits(pageNumber.toString())} • Page $pageNumber of $totalPages',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: isDark ? AppTheme.celestialStarGold : const Color(0xFF854D0E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Surah start decorative frame
  Widget _buildSurahHeaderBanner(Chapter chapter, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.celestialStarGold.withOpacity(0.15)
            : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.celestialStarGold,
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          Text(
            'سُورَةُ ${chapter.nameArabic}',
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.celestialStarGold,
            ),
          ),
          Text(
            '${chapter.nameSimple} • ${chapter.versesCount} Ayahs • ${chapter.revelationPlace.toUpperCase()}',
            style: GoogleFonts.karla(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  /// Renders continuous flowing Arabic text with tap-to-select and inline ayah stop symbols
  Widget _buildContinuousPageText(List<Verse> verses, bool isDark) {
    return Wrap(
      alignment: WrapAlignment.end,
      textDirection: TextDirection.rtl,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      runSpacing: 10,
      children: verses.map((verse) {
        final isSelected = _selectedVerse?.verseNumber == verse.verseNumber;
        final isPlaying = _playingVerseKey == verse.verse_key;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedVerse = isSelected ? null : verse;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.celestialStarGold.withOpacity(0.25)
                  : (isPlaying
                      ? AppTheme.primaryEmerald.withOpacity(0.20)
                      : Colors.transparent),
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(color: AppTheme.celestialStarGold, width: 1)
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              textDirection: TextDirection.rtl,
              children: [
                // Arabic verse words
                TajweedTextWidget(
                  text: verse.textIndopak,
                  enabled: _tajweedEnabled,
                  fontSize: 23,
                  textAlign: TextAlign.right,
                ),
                const SizedBox(width: 6),

                // Decorative Circular Ayah End Stop Symbol ۝ with Arabic verse numeral
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? AppTheme.celestialStarGold.withOpacity(0.18)
                        : const Color(0xFFFEF3C7),
                    border: Border.all(
                      color: AppTheme.celestialStarGold,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    ArabicNumeralHelper.toArabicDigits(verse.verseNumber.toString()),
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.celestialStarGold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Floating Action Bar when an Ayah is selected in Mushaf mode
  Widget _buildAyahActionBar(
    BuildContext context, {
    required Verse verse,
    required Chapter chapter,
    required BookmarkProvider bookmarkProvider,
    required bool isDark,
  }) {
    final isPlaying = _playingVerseKey == verse.verse_key;
    final isBookmarked = bookmarkProvider.isBookmarked(chapter.id, verse.verseNumber);

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppTheme.celestialStarGold,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.celestialStarGold.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 16,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                // Ayah dual reference badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.celestialStarGold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.celestialStarGold.withOpacity(0.5)),
                  ),
                  child: Text(
                    '${chapter.nameSimple} ${ArabicNumeralHelper.formatDual(chapter.id, verse.verseNumber)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.celestialStarGold,
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedVerse = null;
                    });
                  },
                  child: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Short translation preview
            Text(
              '"${verse.translationText}"',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.karla(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Actions: Play Audio, Short Tafsir, Bookmark
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 1. Play Audio
                ElevatedButton.icon(
                  onPressed: () => _toggleAudio(verse.verse_key, verse.audioUrl),
                  icon: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 16,
                  ),
                  label: Text(isPlaying ? 'Pause' : 'Play'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.celestialStarGold,
                    foregroundColor: AppTheme.celestialMidnight,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),

                // 2. Short Tafsir
                OutlinedButton.icon(
                  onPressed: () {
                    ConciseTafsirSheet.show(
                      context,
                      chapter: chapter,
                      verse: verse,
                    );
                  },
                  icon: const Icon(Icons.lightbulb_outline_rounded, size: 16),
                  label: const Text('Short Tafsir'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.celestialStarGold,
                    side: const BorderSide(color: AppTheme.celestialStarGold),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),

                // 3. Bookmark
                IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: AppTheme.celestialStarGold,
                    size: 22,
                  ),
                  tooltip: 'Bookmark',
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
                    await bookmarkProvider.toggleBookmark(bookmark);
                    if (context.mounted) {
                      CelestialNotificationBanner.show(
                        context: context,
                        title: isBookmarked ? 'Bookmark Removed' : 'Bookmark Saved',
                        message: 'Surah ${chapter.nameSimple} • Ayah ${verse.verseNumber}',
                        verseReference: ArabicNumeralHelper.formatDual(chapter.id, verse.verseNumber),
                        type: NotificationType.bookmarkSaved,
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
