import 'dart:async';
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
import '../widgets/celestial_background.dart';

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
  final Map<int, GlobalKey> _verseKeys = {};

  List<Verse> _verses = [];
  Verse? _selectedVerse;
  int? _activePlayingVerseNumber;
  String? _playingVerseKey;
  bool _isPlaying = false;
  bool _isContinuousPlay = true;
  bool _tajweedEnabled = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialVerses != null) {
      _verses = widget.initialVerses!;
      for (final v in _verses) {
        _verseKeys[v.verseNumber] = GlobalKey();
      }
      _versesFuture = Future.value(_verses);
      if (widget.initialVerseNumber != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToVerse(widget.initialVerseNumber!);
          final target = _verses.firstWhere(
            (v) => v.verseNumber == widget.initialVerseNumber,
            orElse: () => _verses.first,
          );
          setState(() {
            _selectedVerse = target;
          });
        });
      }
    } else {
      _versesFuture = QuranService.fetchVerses(widget.chapter.id).then((verses) {
        _verses = verses;
        for (final v in verses) {
          _verseKeys[v.verseNumber] = GlobalKey();
        }
        if (widget.initialVerseNumber != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToVerse(widget.initialVerseNumber!);
            final target = verses.firstWhere(
              (v) => v.verseNumber == widget.initialVerseNumber,
              orElse: () => verses.first,
            );
            setState(() {
              _selectedVerse = target;
            });
          });
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

    _audioPlayer.onPlayerComplete.listen((_) {
      if (!mounted) return;
      if (_isContinuousPlay && _activePlayingVerseNumber != null) {
        _playNextVerseInSequence();
      } else {
        setState(() {
          _playingVerseKey = null;
          _activePlayingVerseNumber = null;
          _isPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _scrollToVerse(int verseNumber) {
    final key = _verseKeys[verseNumber];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
        alignment: 0.25,
      );
    }
  }

  Future<void> _playVerse(Verse verse) async {
    if (verse.audioUrl == null || verse.audioUrl!.isEmpty) return;

    await _audioPlayer.stop();

    final parts = verse.verseKey.split(':');
    final surahId = int.tryParse(parts[0]) ?? widget.chapter.id;
    final verseNum = parts.length > 1 ? (int.tryParse(parts[1]) ?? verse.verseNumber) : verse.verseNumber;
    final localPath = await OfflineAudioManager.getLocalVerseAudioPath(surahId, verseNum);

    if (localPath != null) {
      await _audioPlayer.play(DeviceFileSource(localPath));
    } else {
      final fullUrl = '${QuranService.audioBaseUrl}${verse.audioUrl}';
      await _audioPlayer.play(UrlSource(fullUrl));
    }

    if (mounted) {
      setState(() {
        _activePlayingVerseNumber = verse.verseNumber;
        _playingVerseKey = verse.verseKey;
        _isPlaying = true;
      });
      _scrollToVerse(verse.verseNumber);
    }
  }

  void _playNextVerseInSequence() {
    if (_verses.isEmpty || _activePlayingVerseNumber == null) return;
    final currentIndex = _verses.indexWhere((v) => v.verseNumber == _activePlayingVerseNumber);
    if (currentIndex != -1 && currentIndex + 1 < _verses.length) {
      final nextVerse = _verses[currentIndex + 1];
      _playVerse(nextVerse);
    } else {
      // Reached the end of the Surah
      setState(() {
        _playingVerseKey = null;
        _activePlayingVerseNumber = null;
        _isPlaying = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Completed recitation of Surah ${widget.chapter.nameSimple}'),
            backgroundColor: AppTheme.primaryEmerald,
          ),
        );
      }
    }
  }

  void _playPreviousVerse() {
    if (_verses.isEmpty || _activePlayingVerseNumber == null) return;
    final currentIndex = _verses.indexWhere((v) => v.verseNumber == _activePlayingVerseNumber);
    if (currentIndex > 0) {
      final prevVerse = _verses[currentIndex - 1];
      _playVerse(prevVerse);
    }
  }

  void _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (_activePlayingVerseNumber != null) {
        await _audioPlayer.resume();
      } else {
        // Start continuous playback from beginning or selected verse
        final startVerse = _selectedVerse ?? (_verses.isNotEmpty ? _verses.first : null);
        if (startVerse != null) {
          _isContinuousPlay = true;
          _playVerse(startVerse);
        }
      }
    }
  }

  void _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _playingVerseKey = null;
      _activePlayingVerseNumber = null;
      _isPlaying = false;
    });
  }

  void _startContinuousPlayAll({Verse? fromVerse}) {
    final target = fromVerse ?? _selectedVerse ?? (_verses.isNotEmpty ? _verses.first : null);
    if (target != null) {
      setState(() {
        _isContinuousPlay = true;
      });
      _playVerse(target);
    }
  }

  void _playSingleVerse(Verse verse) {
    setState(() {
      _isContinuousPlay = false;
    });
    _playVerse(verse);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final chapter = widget.chapter;
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);

    final isAnyAudioActive = _activePlayingVerseNumber != null;

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
          // Play All / Play Surah One-Tap Button
          IconButton(
            icon: Icon(
              _isPlaying && _isContinuousPlay
                  ? Icons.pause_circle_filled_rounded
                  : Icons.play_circle_fill_rounded,
              color: AppTheme.getAccentGold(isDark),
              size: 24,
            ),
            tooltip: _isPlaying && _isContinuousPlay ? 'Pause Surah' : 'Play All (Continuous Audio)',
            onPressed: () {
              if (_isPlaying && _isContinuousPlay) {
                _audioPlayer.pause();
              } else {
                _startContinuousPlayAll();
              }
            },
          ),
          // Bookmark Sheet action
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
          // Offline Audio Manager
          IconButton(
            icon: const Icon(Icons.download_for_offline_outlined, size: 20),
            color: AppTheme.getStarlightBlue(isDark),
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
              // 1. Theme-aware celestial atmosphere background
              const Positioned.fill(
                child: CelestialBackground(),
              ),

              // 2. Continuous Full-Surah Vertical Scroll View (Single Page, No Overflow)
              ListView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  14,
                  10,
                  14,
                  isAnyAudioActive || _selectedVerse != null
                      ? MediaQuery.of(context).padding.bottom + 140
                      : MediaQuery.of(context).padding.bottom + 40,
                ),
                children: [
                  // Ornate Mushaf Surah Header Frame
                  _buildMushafSurahHeader(chapter, isDark),
                  const SizedBox(height: 12),

                  // Bismillah Header Banner (except for Surah 9 At-Tawbah)
                  if (chapter.id != 9) ...[
                    _buildBismillahBanner(chapter, isDark),
                    const SizedBox(height: 16),
                  ],

                  // Continuous verses in clean, responsive Mushaf layout
                  ...verses.map((verse) {
                    final isSelected = _selectedVerse?.verseNumber == verse.verseNumber;
                    final isPlaying = _activePlayingVerseNumber == verse.verseNumber;

                    return _buildMushafVerseCard(
                      verse: verse,
                      chapter: chapter,
                      isSelected: isSelected,
                      isPlaying: isPlaying,
                      isDark: isDark,
                      bookmarkProvider: bookmarkProvider,
                    );
                  }),

                  const SizedBox(height: 24),

                  // Ornate End of Surah Seal
                  _buildEndOfSurahSeal(chapter, isDark),
                ],
              ),

              // 3. Floating Bottom Audio Controller Bar (When Audio is Active/Paused)
              if (isAnyAudioActive)
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: MediaQuery.of(context).padding.bottom + 12,
                  child: _buildFloatingAudioPlayerBar(
                    chapter: chapter,
                    isDark: isDark,
                  ),
                )
              // 4. Floating Ayah Action Bar (When verse is tapped and audio is not active)
              else if (_selectedVerse != null)
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: MediaQuery.of(context).padding.bottom + 14,
                  child: _buildSelectedAyahActionBar(
                    verse: _selectedVerse!,
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

  /// Ornate Mushaf Surah Header Banner
  Widget _buildMushafSurahHeader(Chapter chapter, bool isDark) {
    final juzNumber = ((chapter.id - 1) ~/ 4) + 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.celestialDeepIndigo : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppTheme.celestialStarGold.withOpacity(0.85)
              : const Color(0xFFEADBCE),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppTheme.celestialStarGold.withOpacity(0.18)
                : const Color(0xFFB45309).withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top margin indicators: Surah Arabic name & Juz
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
          const SizedBox(height: 6),
          Divider(
            color: isDark
                ? AppTheme.celestialStarGold.withOpacity(0.3)
                : const Color(0xFFEADBCE),
            thickness: 0.8,
            height: 12,
          ),
          const SizedBox(height: 4),
          // English info: Surah Name, Ayahs, Revelation Place
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

  /// Bismillah banner with floral arabesque dividers
  Widget _buildBismillahBanner(Chapter chapter, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.celestialSurfaceIndigo.withOpacity(0.6)
            : const Color(0xFFFAF5EC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppTheme.celestialStarGold.withOpacity(0.4)
              : const Color(0xFFEADBCE),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '❁  ',
            style: TextStyle(
              color: isDark
                  ? AppTheme.celestialStarGold.withOpacity(0.8)
                  : const Color(0xFFB45309),
              fontSize: 16,
            ),
          ),
          Text(
            'بِسۡمِ اللهِ الرَّحۡمٰنِ الرَّحِيۡمِ',
            style: GoogleFonts.scheherazadeNew(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.celestialStarGold : const Color(0xFF92400E),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            '  ❁',
            style: TextStyle(
              color: isDark
                  ? AppTheme.celestialStarGold.withOpacity(0.8)
                  : const Color(0xFFB45309),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// Renders a responsive, clean Mushaf verse card that NEVER overflows
  Widget _buildMushafVerseCard({
    required Verse verse,
    required Chapter chapter,
    required bool isSelected,
    required bool isPlaying,
    required bool isDark,
    required BookmarkProvider bookmarkProvider,
  }) {
    final isBookmarked = bookmarkProvider.isBookmarked(chapter.id, verse.verseNumber);

    return Container(
      key: _verseKeys[verse.verseNumber],
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isPlaying
            ? (isDark
                ? const Color(0xFF064E3B).withOpacity(0.38)
                : const Color(0xFFD1FAE5))
            : (isSelected
                ? (isDark
                    ? AppTheme.celestialStarGold.withOpacity(0.18)
                    : const Color(0xFFFEF3C7).withOpacity(0.55))
                : (isDark
                    ? AppTheme.celestialDeepIndigo.withOpacity(0.70)
                    : Colors.white)),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isPlaying
              ? AppTheme.primaryEmerald
              : (isSelected
                  ? (isDark ? AppTheme.celestialStarGold : const Color(0xFFD97706))
                  : (isDark
                      ? AppTheme.celestialBorderIndigo.withOpacity(0.6)
                      : const Color(0xFFEADBCE))),
          width: isPlaying || isSelected ? 1.6 : 1.0,
        ),
        boxShadow: isPlaying || isSelected
            ? [
                BoxShadow(
                  color: (isPlaying
                          ? AppTheme.primaryEmerald
                          : (isDark ? AppTheme.celestialStarGold : const Color(0xFFB45309)))
                      .withOpacity(isDark ? 0.20 : 0.12),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.08 : 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            setState(() {
              _selectedVerse = isSelected ? null : verse;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header Row: Verse Marker badge, bookmark star, playing indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dual Reference Tag: English:Arabic
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.celestialSurfaceIndigo
                            : const Color(0xFFFAF6EE),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? (isDark ? AppTheme.celestialStarGold : const Color(0xFFD97706))
                              : (isDark ? AppTheme.celestialBorderIndigo : const Color(0xFFEADBCE)),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_stories_rounded,
                            size: 13,
                            color: isDark ? AppTheme.celestialStarGold : const Color(0xFFB45309),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            ArabicNumeralHelper.formatDual(chapter.id, verse.verseNumber),
                            style: GoogleFonts.karla(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Right Actions: Playing badge, bookmark icon
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isPlaying)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryEmerald.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.primaryEmerald, width: 0.8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.volume_up_rounded, size: 12, color: AppTheme.primaryEmerald),
                                SizedBox(width: 4),
                                Text(
                                  'Playing',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryEmerald,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (isBookmarked)
                          const Icon(
                            Icons.bookmark_rounded,
                            size: 18,
                            color: AppTheme.celestialStarGold,
                          ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Pure Arabic Quranic Text (Never overflows, wraps naturally across lines)
                SizedBox(
                  width: double.infinity,
                  child: TajweedTextWidget(
                    text: verse.textIndopak,
                    enabled: _tajweedEnabled,
                    fontSize: 25,
                    textAlign: TextAlign.right,
                  ),
                ),

                const SizedBox(height: 10),

                // End of Ayah Ornamental Seal
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(12),
                      color: isDark
                          ? AppTheme.celestialStarGold.withOpacity(0.12)
                          : const Color(0xFFFEF3C7),
                      border: Border.all(
                        color: AppTheme.celestialStarGold.withOpacity(0.6),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '۝ ${ArabicNumeralHelper.toArabicDigits(verse.verseNumber.toString())}',
                      style: GoogleFonts.scheherazadeNew(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.celestialStarGold : const Color(0xFF92400E),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Ornate End of Surah Seal
  Widget _buildEndOfSurahSeal(Chapter chapter, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.celestialDeepIndigo : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppTheme.celestialStarGold.withOpacity(0.7)
              : const Color(0xFFEADBCE),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.verified_rounded,
            size: 32,
            color: isDark ? AppTheme.celestialStarGold : const Color(0xFFB45309),
          ),
          const SizedBox(height: 8),
          Text(
            'تَمَّتْ بِحَمْدِ اللهِ سُورَةُ ${chapter.nameArabic}',
            style: GoogleFonts.scheherazadeNew(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.celestialStarGold : const Color(0xFF92400E),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'All ${chapter.versesCount} Ayahs of Surah ${chapter.nameSimple} Completed',
            style: GoogleFonts.karla(
              fontSize: 12,
              color: isDark ? Colors.white70 : const Color(0xFF78350F),
            ),
          ),
        ],
      ),
    );
  }

  /// Floating Audio Player Dock (Continuous Play All / Single Play Controls)
  Widget _buildFloatingAudioPlayerBar({
    required Chapter chapter,
    required bool isDark,
  }) {
    final currentAyah = _activePlayingVerseNumber ?? 1;
    final totalAyahs = _verses.isNotEmpty ? _verses.length : chapter.versesCount;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
              : [Colors.white, const Color(0xFFFAF8F5)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? AppTheme.celestialStarGold.withOpacity(0.65)
              : const Color(0xFFEADBCE),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top status row: Mode toggle, Ayah info, Tafsir button, Close button
          Row(
            children: [
              // Continuous / Single Play Mode Toggle Badge
              InkWell(
                onTap: () {
                  setState(() {
                    _isContinuousPlay = !_isContinuousPlay;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isContinuousPlay
                        ? AppTheme.primaryEmerald.withOpacity(isDark ? 0.2 : 0.12)
                        : (isDark
                            ? AppTheme.celestialStarGold.withOpacity(0.2)
                            : const Color(0xFFFEF3C7)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isContinuousPlay
                          ? AppTheme.primaryEmerald
                          : (isDark ? AppTheme.celestialStarGold : const Color(0xFFD97706)),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isContinuousPlay ? Icons.repeat_rounded : Icons.repeat_one_rounded,
                        size: 13,
                        color: _isContinuousPlay
                            ? AppTheme.primaryEmerald
                            : (isDark ? AppTheme.celestialStarGold : const Color(0xFFB45309)),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isContinuousPlay ? 'Play All' : 'Single Play',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _isContinuousPlay ? AppTheme.primaryEmerald : AppTheme.celestialStarGold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Title & Ayah counter
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Surah ${chapter.nameSimple}',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Ayah $currentAyah of $totalAyahs (${ArabicNumeralHelper.toArabicDigits(currentAyah.toString())})',
                      style: GoogleFonts.karla(
                        fontSize: 11,
                        color: isDark ? AppTheme.celestialStarGold : const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),

              // Short Tafsir for active verse
              if (_activePlayingVerseNumber != null) ...[
                IconButton(
                  icon: const Icon(Icons.lightbulb_outline_rounded, size: 20),
                  color: AppTheme.celestialStarGold,
                  tooltip: 'Short Tafsir',
                  onPressed: () {
                    final activeVerse = _verses.firstWhere(
                      (v) => v.verseNumber == _activePlayingVerseNumber,
                      orElse: () => _verses.first,
                    );
                    ConciseTafsirSheet.show(
                      context,
                      chapter: chapter,
                      verse: activeVerse,
                    );
                  },
                ),
              ],

              // Close / Stop Player
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: _stopAudio,
                tooltip: 'Stop & Close Player',
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Main Playback Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Previous Ayah
              IconButton(
                icon: const Icon(Icons.skip_previous_rounded, size: 26),
                onPressed: _playPreviousVerse,
                tooltip: 'Previous Ayah',
              ),

              // Play / Pause
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppTheme.celestialStarGold, Color(0xFFD97706)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.celestialStarGold.withOpacity(0.35),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 32,
                    color: AppTheme.celestialMidnight,
                  ),
                  onPressed: _togglePlayPause,
                  tooltip: _isPlaying ? 'Pause' : 'Play',
                ),
              ),

              // Next Ayah
              IconButton(
                icon: const Icon(Icons.skip_next_rounded, size: 26),
                onPressed: _playNextVerseInSequence,
                tooltip: 'Next Ayah',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Floating Action Bar when a verse is tapped (when audio player is not docked)
  Widget _buildSelectedAyahActionBar({
    required Verse verse,
    required Chapter chapter,
    required bool isDark,
    required BookmarkProvider bookmarkProvider,
  }) {
    final isBookmarked = bookmarkProvider.isBookmarked(chapter.id, verse.verseNumber);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.celestialDeepIndigo : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppTheme.celestialStarGold.withOpacity(0.7)
              : const Color(0xFFEADBCE),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ayah Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.celestialStarGold.withOpacity(0.18)
                  : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Ayah ${verse.verseNumber}',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.celestialStarGold : const Color(0xFFB45309),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Single Play
          IconButton(
            icon: const Icon(Icons.play_arrow_rounded),
            color: isDark ? AppTheme.celestialStarGold : const Color(0xFFB45309),
            tooltip: 'Play this ayah',
            onPressed: () => _playSingleVerse(verse),
          ),

          // Play All From Here
          IconButton(
            icon: const Icon(Icons.playlist_play_rounded),
            color: AppTheme.primaryEmerald,
            tooltip: 'Play all from here',
            onPressed: () => _startContinuousPlayAll(fromVerse: verse),
          ),

          // Short Tafsir
          IconButton(
            icon: const Icon(Icons.lightbulb_outline_rounded),
            color: isDark ? AppTheme.celestialStarlightBlue : const Color(0xFF0284C7),
            tooltip: 'Short Tafsir',
            onPressed: () {
              ConciseTafsirSheet.show(
                context,
                chapter: chapter,
                verse: verse,
              );
            },
          ),

          // Bookmark
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined,
              color: isDark ? AppTheme.celestialStarGold : const Color(0xFFB45309),
            ),
            tooltip: isBookmarked ? 'Remove Bookmark' : 'Add Bookmark',
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

          const Spacer(),

          // Dismiss selection
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 18),
            onPressed: () {
              setState(() {
                _selectedVerse = null;
              });
            },
          ),
        ],
      ),
    );
  }
}
