import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/chapter.dart';
import '../models/verse.dart';
import '../services/quran_service.dart';
import '../theme/app_theme.dart';
import '../widgets/tajweed_legend.dart';
import '../widgets/tajweed_text.dart';

class SurahScreen extends StatefulWidget {
  final Chapter chapter;

  const SurahScreen({super.key, required this.chapter});

  @override
  State<SurahScreen> createState() => _SurahScreenState();
}

class _SurahScreenState extends State<SurahScreen> {
  late Future<List<Verse>> _versesFuture;
  bool _tajweedEnabled = true;
  String? _playingVerseKey;
  final AudioPlayer _audioPlayer = AudioPlayer();

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chapter = widget.chapter;

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
      body: FutureBuilder<List<Verse>>(
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

          final isDark = theme.brightness == Brightness.dark;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Celestial Surah Header Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                        decoration: BoxDecoration(
                          gradient: isDark
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF131F3A),
                                    Color(0xFF0F172A),
                                    Color(0xFF080D1A),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                )
                              : const LinearGradient(
                                  colors: [
                                    Color(0xFFFFFFFF),
                                    Color(0xFFF1F6FE),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isDark
                                ? AppTheme.celestialStarGold.withOpacity(0.4)
                                : const Color(0xFFD6E2F0),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? const Color(0xFF020617).withOpacity(0.4)
                                  : const Color(0xFF94A3B8).withOpacity(0.12),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.auto_awesome,
                                  size: 12,
                                  color: AppTheme.celestialStarGold,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'SURAH ${chapter.id}',
                                  style: GoogleFonts.karla(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 3,
                                    color: isDark
                                        ? AppTheme.celestialStarGold
                                        : const Color(0xFF1E3A8A),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.auto_awesome,
                                  size: 12,
                                  color: AppTheme.celestialStarGold,
                                ),
                              ],
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final verse = verses[index];
                      final isPlaying = _playingVerseKey == verse.verse_key;

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
                            color: isPlaying
                                ? AppTheme.celestialStarGold
                                : (isDark
                                    ? AppTheme.celestialBorderIndigo
                                    : AppTheme.lightBorder),
                            width: isPlaying ? 1.5 : 1,
                          ),
                          boxShadow: isPlaying
                              ? [
                                  BoxShadow(
                                    color: AppTheme.celestialStarGold.withOpacity(0.25),
                                    blurRadius: 16,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TajweedTextWidget(
                              text: verse.textIndopak,
                              enabled: _tajweedEnabled,
                              fontSize: 26,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              verse.translationText,
                              style: GoogleFonts.karla(
                                fontSize: 14,
                                height: 1.5,
                                color: theme.colorScheme.onSurface.withOpacity(0.85),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                                  child: Text(
                                    '${chapter.id}:${verse.verseNumber}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppTheme.celestialStarGold
                                          : const Color(0xFF1E3A8A),
                                    ),
                                  ),
                                ),
                                const Spacer(),
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
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
    );
  }
}
