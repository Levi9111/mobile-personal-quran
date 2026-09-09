import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import '../models/bookmark.dart';
import '../models/chapter.dart';
import '../models/tajweed.dart';
import '../models/verse.dart';
import '../providers/bookmark_provider.dart';
import '../services/quran_service.dart';
import '../theme/app_theme.dart';
import '../utils/arabic_numerals.dart';
import '../widgets/bookmark_sheet.dart';
import '../widgets/celestial_background.dart';
import '../widgets/celestial_notification_banner.dart';

class MushafScreen extends StatefulWidget {
  final Chapter chapter;
  final int? initialVerseNumber;
  final List<Verse>? initialVerses;

  const MushafScreen({
    super.key,
    required this.chapter,
    this.initialVerseNumber,
    this.initialVerses,
  });

  @override
  State<MushafScreen> createState() => _MushafScreenState();
}

class _MushafScreenState extends State<MushafScreen> {
  late Future<List<Verse>> _versesFuture;
  final ScrollController _scrollController = ScrollController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Map<int, TapGestureRecognizer> _recognizers = {};

  List<Verse> _verses = [];
  Verse? _selectedVerse;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _tajweedEnabled = true;

  @override
  void initState() {
    super.initState();

    if (widget.initialVerses != null) {
      _verses = widget.initialVerses!;
      _initRecognizers(_verses);
      _versesFuture = Future.value(_verses);
      if (widget.initialVerseNumber != null) {
        _selectInitialVerse(widget.initialVerseNumber!);
      }
    } else {
      _versesFuture = QuranService.fetchVerses(widget.chapter.id).then((verses) {
        _verses = verses;
        _initRecognizers(verses);
        if (widget.initialVerseNumber != null) {
          _selectInitialVerse(widget.initialVerseNumber!);
        }
        return verses;
      });
    }

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((pos) {
      if (mounted) {
        setState(() {
          _currentPosition = pos;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((dur) {
      if (mounted) {
        setState(() {
          _totalDuration = dur;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _currentPosition = Duration.zero;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Completed recitation of Surah ${widget.chapter.nameSimple}'),
            backgroundColor: AppTheme.primaryEmerald,
          ),
        );
      }
    });
  }

  void _initRecognizers(List<Verse> verses) {
    for (final r in _recognizers.values) {
      r.dispose();
    }
    _recognizers.clear();

    for (final verse in verses) {
      _recognizers[verse.verseNumber] = TapGestureRecognizer()
        ..onTap = () => _handleVerseTap(verse);
    }
  }

  void _selectInitialVerse(int verseNumber) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_verses.isNotEmpty) {
        final target = _verses.firstWhere(
          (v) => v.verseNumber == verseNumber,
          orElse: () => _verses.first,
        );
        setState(() {
          _selectedVerse = target;
        });
      }
    });
  }

  void _handleVerseTap(Verse verse) {
    setState(() {
      if (_selectedVerse?.verseNumber == verse.verseNumber) {
        _selectedVerse = null;
      } else {
        _selectedVerse = verse;
      }
    });
  }

  Future<void> _toggleFullSurahAudio() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (_audioPlayer.state == PlayerState.paused) {
        await _audioPlayer.resume();
      } else {
        final fullAudioUrl =
            'https://download.quranicaudio.com/qdc/mishari_al_afasy/murattal/${widget.chapter.id}.mp3';
        try {
          await _audioPlayer.play(UrlSource(fullAudioUrl));
        } catch (_) {
          final fallbackUrl =
              'https://server8.mp3quran.net/afs/${widget.chapter.id.toString().padLeft(3, '0')}.mp3';
          await _audioPlayer.play(UrlSource(fallbackUrl));
        }
      }
    }
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    if (mounted) {
      setState(() {
        _isPlaying = false;
        _currentPosition = Duration.zero;
      });
    }
  }

  Future<void> _toggleBookmark(Verse verse) async {
    final bookmarkProvider = Provider.of<BookmarkProvider>(context, listen: false);
    final bookmark = Bookmark(
      id: '${widget.chapter.id}:${verse.verseNumber}',
      surahId: widget.chapter.id,
      surahNameSimple: widget.chapter.nameSimple,
      surahNameArabic: widget.chapter.nameArabic,
      verseNumber: verse.verseNumber,
      verseKey: verse.verseKey,
      arabicText: verse.textIndopak,
      translationText: verse.translationText,
      timestamp: DateTime.now(),
    );

    final added = await bookmarkProvider.toggleBookmark(bookmark);
    setState(() {});

    if (mounted) {
      CelestialNotificationBanner.show(
        context: context,
        title: added ? 'Bookmark Saved • تَمَّ الْحِفْظ' : 'Bookmark Removed',
        message: added
            ? 'Ayah ${widget.chapter.id}:${verse.verseNumber} marked as your spot for today.'
            : 'Removed from bookmarks.',
        verseReference: ArabicNumeralHelper.formatDual(widget.chapter.id, verse.verseNumber),
        type: NotificationType.bookmarkSaved,
        duration: const Duration(seconds: 3),
      );
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    for (final r in _recognizers.values) {
      r.dispose();
    }
    _recognizers.clear();
    _scrollController.dispose();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final chapter = widget.chapter;
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF070D1A) : const Color(0xFFFAF7F0),
      appBar: AppBar(
        elevation: 0,
        title: Column(
          children: [
            Text(
              'Surah ${chapter.nameSimple}',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Mushaf Mode • سُورَةُ ${chapter.nameArabic}',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 0.8,
                color: theme.colorScheme.onSurface.withOpacity(0.65),
              ),
            ),
          ],
        ),
        actions: [
          // Play Full Surah Audio Button in AppBar
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
              color: AppTheme.getAccentGold(isDark),
              size: 24,
            ),
            tooltip: _isPlaying ? 'Pause Full Surah Recitation' : 'Play Full Surah Recitation',
            onPressed: _toggleFullSurahAudio,
          ),
          // View Bookmarks
          IconButton(
            icon: const Icon(Icons.bookmarks_rounded, size: 20),
            color: AppTheme.getAccentGold(isDark),
            tooltip: 'View Bookmarks',
            onPressed: () => BookmarkSheet.show(context),
          ),
          // Tajweed Colors Toggle
          IconButton(
            icon: Icon(
              _tajweedEnabled ? Icons.visibility_rounded : Icons.visibility_off_outlined,
              size: 20,
              color: _tajweedEnabled
                  ? (isDark ? AppTheme.primaryEmerald : AppTheme.lightEmerald)
                  : Colors.grey,
            ),
            tooltip: _tajweedEnabled ? 'Tajweed colours enabled' : 'Tajweed colours disabled',
            onPressed: () {
              setState(() {
                _tajweedEnabled = !_tajweedEnabled;
              });
            },
          ),
          const SizedBox(width: 4),
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
                child: Text('Error loading Mushaf: ${snapshot.error}'),
              ),
            );
          }

          final verses = snapshot.data ?? [];
          if (verses.isEmpty) {
            return const Center(child: Text('No verses available.'));
          }

          return Stack(
            children: [
              // 1. Persistent Anime Celestial Background
              const Positioned.fill(
                child: CelestialBackground(),
              ),

              // 2. Single Continuous Vertical Scroll View
              ListView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  14,
                  10,
                  14,
                  MediaQuery.of(context).padding.bottom + 85,
                ),
                children: [
                  // SINGLE SOLID OPAQUE CARD CONTAINING ALL VERSES (Like Surah Al-Falaq & An-Nas)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : Colors.white, // Solid opaque background
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isDark ? AppTheme.celestialBorderIndigo : const Color(0xFFE2E8F0),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.35 : 0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Ornate Surah Header Frame
                        _buildMushafSurahHeader(chapter, isDark),

                        // 2. Bismillah Banner (except Surah 9 At-Tawbah)
                        if (chapter.id != 9) ...[
                          const SizedBox(height: 10),
                          _buildBismillahBanner(chapter, isDark),
                        ],

                        // 3. CONTINUOUS MUSHAF TEXT (All verses laid out sequentially inside one card)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: Text.rich(
                              TextSpan(
                                children: _buildContinuousVerseSpans(
                                  verses: verses,
                                  chapter: chapter,
                                  isDark: isDark,
                                  bookmarkProvider: bookmarkProvider,
                                ),
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                        ),

                        // 4. Ornate End of Surah Rosette / Seal
                        _buildEndOfSurahSeal(chapter, isDark),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ],
              ),

              // 3. DOCKED BOTTOM CARD (Houses Play button with Play/Pause text + Ayah Bookmark feature)
              Positioned(
                left: 14,
                right: 14,
                bottom: MediaQuery.of(context).padding.bottom + 12,
                child: _buildBottomDockedBar(
                  chapter: chapter,
                  isDark: isDark,
                  bookmarkProvider: bookmarkProvider,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 1. Ornate Surah Header Frame
  Widget _buildMushafSurahHeader(Chapter chapter, bool isDark) {
    final juzNumber = ((chapter.id - 1) ~/ 4) + 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131F3A) : const Color(0xFFFAF7F0),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.celestialBorderIndigo : const Color(0xFFEADBCE),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الجزء ${ArabicNumeralHelper.toArabicDigits(juzNumber.toString())}',
                style: GoogleFonts.scheherazadeNew(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.celestialStarGold : const Color(0xFF92400E),
                ),
              ),
              Icon(
                Icons.auto_awesome_rounded,
                size: 15,
                color: isDark ? AppTheme.celestialStarGold : const Color(0xFFB45309),
              ),
              Text(
                'سُورَةُ ${chapter.nameArabic}',
                style: GoogleFonts.scheherazadeNew(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.celestialStarGold : const Color(0xFF92400E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Surah ${chapter.nameSimple} • ${chapter.versesCount} Ayahs • ${chapter.revelationPlace.toUpperCase()}',
            style: GoogleFonts.karla(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: isDark ? Colors.white70 : const Color(0xFF78350F),
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Bismillah Banner
  Widget _buildBismillahBanner(Chapter chapter, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111E38) : const Color(0xFFFAF5EC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? AppTheme.celestialStarGold.withOpacity(0.35)
              : const Color(0xFFEADBCE),
          width: 0.8,
        ),
      ),
      child: Center(
        child: Text(
          'بِسۡمِ اللهِ الرَّحۡمٰنِ الرَّحِيۡمِ',
          style: GoogleFonts.scheherazadeNew(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.celestialStarGold : const Color(0xFF92400E),
          ),
        ),
      ),
    );
  }

  /// 3. CONTINUOUS MUSHAF SPANS (All verses flowing in one card with delicate small bookmark stars)
  List<InlineSpan> _buildContinuousVerseSpans({
    required List<Verse> verses,
    required Chapter chapter,
    required bool isDark,
    required BookmarkProvider bookmarkProvider,
  }) {
    final spans = <InlineSpan>[];
    final defaultColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final highlightBg = isDark
        ? AppTheme.celestialStarGold.withOpacity(0.22)
        : const Color(0xFFFEF3C7);

    for (final verse in verses) {
      final isSelected = _selectedVerse?.verseNumber == verse.verseNumber;
      final isBookmarked = bookmarkProvider.isBookmarked(chapter.id, verse.verseNumber);

      final recognizer = _recognizers[verse.verseNumber];

      // Parse Tajweed rules or default text
      if (_tajweedEnabled) {
        final segments = TajweedParser.parse(verse.textIndopak);
        for (final seg in segments) {
          final color = seg.rule != null
              ? ruleMetaMap[seg.rule]!.resolveColor(isDark)
              : defaultColor;

          spans.add(
            TextSpan(
              text: seg.text,
              recognizer: recognizer,
              style: GoogleFonts.scheherazadeNew(
                fontSize: 25,
                height: 2.2,
                color: color,
                backgroundColor: isSelected ? highlightBg : null,
              ),
            ),
          );
        }
      } else {
        spans.add(
          TextSpan(
            text: verse.textIndopak,
            recognizer: recognizer,
            style: GoogleFonts.scheherazadeNew(
              fontSize: 25,
              height: 2.2,
              color: defaultColor,
              backgroundColor: isSelected ? highlightBg : null,
            ),
          ),
        );
      }

      // Traditional Ayah End Symbol ۝ with Arabic Number
      final arabicNumber = ArabicNumeralHelper.toArabicDigits(verse.verseNumber.toString());

      spans.add(
        TextSpan(
          text: ' ۝$arabicNumber ',
          recognizer: recognizer,
          style: GoogleFonts.scheherazadeNew(
            fontSize: 22,
            height: 2.2,
            fontWeight: FontWeight.bold,
            color: isBookmarked
                ? AppTheme.celestialStarGold
                : (isDark
                    ? AppTheme.celestialStarGold.withOpacity(0.85)
                    : const Color(0xFF92400E)),
            backgroundColor: isSelected ? highlightBg : null,
          ),
        ),
      );

      // Delicate smaller bookmark star (Requirement 4)
      if (isBookmarked) {
        spans.add(
          TextSpan(
            text: '⭐ ',
            recognizer: recognizer,
            style: TextStyle(
              fontSize: 10, // Small, delicate golden star accent
              color: AppTheme.celestialStarGold,
              backgroundColor: isSelected ? highlightBg : null,
            ),
          ),
        );
      }
    }

    return spans;
  }

  /// 4. Ornate End of Surah Seal
  Widget _buildEndOfSurahSeal(Chapter chapter, bool isDark) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131F3A) : const Color(0xFFFAF5EC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? AppTheme.celestialStarGold.withOpacity(0.5)
                : const Color(0xFFEADBCE),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.stars_rounded,
              size: 14,
              color: isDark ? AppTheme.celestialStarGold : const Color(0xFFB45309),
            ),
            const SizedBox(width: 8),
            Text(
              'خَتْمُ سُورَةِ ${chapter.nameArabic} • ${chapter.versesCount} آيَاتٍ',
              style: GoogleFonts.scheherazadeNew(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.celestialStarGold : const Color(0xFF92400E),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.stars_rounded,
              size: 14,
              color: isDark ? AppTheme.celestialStarGold : const Color(0xFFB45309),
            ),
          ],
        ),
      ),
    );
  }

  /// 5. DOCKED BOTTOM CARD: Contains Play button with Play/Pause text + Bookmark Feature (Requirements 2, 3, 8)
  Widget _buildBottomDockedBar({
    required Chapter chapter,
    required bool isDark,
    required BookmarkProvider bookmarkProvider,
  }) {
    final selected = _selectedVerse;
    final isBookmarked = selected != null
        ? bookmarkProvider.isBookmarked(chapter.id, selected.verseNumber)
        : false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white, // Solid opaque
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? AppTheme.celestialStarGold.withOpacity(0.5)
              : const Color(0xFFD97706),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.45 : 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Play / Pause Full Audio Button (Requirements 2 & 3)
          ElevatedButton.icon(
            onPressed: _toggleFullSurahAudio,
            icon: Icon(
              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 18,
            ),
            label: Text(
              _isPlaying ? 'Pause' : 'Play',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A),
              foregroundColor: isDark ? AppTheme.celestialMidnight : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
          ),
          const SizedBox(width: 10),

          // Context display: Selected Ayah details or Full recitation indicator
          Expanded(
            child: selected != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ayah ${chapter.id}:${selected.verseNumber}',
                        style: GoogleFonts.karla(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: isDark ? AppTheme.celestialStarGold : const Color(0xFFB45309),
                        ),
                      ),
                      Text(
                        selected.translationText.isNotEmpty
                            ? selected.translationText
                            : chapter.nameSimple,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.karla(
                          fontSize: 11,
                          color: isDark ? Colors.white60 : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isPlaying ? 'Mishary Rashid Alafasy' : 'Full Surah Recitation',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.karla(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        _isPlaying
                            ? '${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration)}'
                            : 'Tap any ayah to bookmark',
                        style: GoogleFonts.karla(
                          fontSize: 11,
                          color: isDark ? Colors.white60 : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(width: 8),

          // Bookmark Action Button (Synced with non-Mushaf mode)
          if (selected != null) ...[
            ElevatedButton.icon(
              onPressed: () => _toggleBookmark(selected),
              icon: Icon(
                isBookmarked ? Icons.bookmark_added_rounded : Icons.bookmark_border_rounded,
                size: 14,
              ),
              label: Text(
                isBookmarked ? 'Bookmarked' : 'Bookmark',
                style: const TextStyle(fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isBookmarked
                    ? (isDark ? AppTheme.celestialStarGold : const Color(0xFFD97706))
                    : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                foregroundColor: isBookmarked
                    ? (isDark ? AppTheme.celestialMidnight : Colors.white)
                    : (isDark ? Colors.white : const Color(0xFF1E293B)),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                setState(() {
                  _selectedVerse = null;
                });
              },
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.bookmarks_rounded, size: 20),
              color: AppTheme.getAccentGold(isDark),
              tooltip: 'View Bookmarks',
              onPressed: () => BookmarkSheet.show(context),
            ),
          ],
        ],
      ),
    );
  }
}
