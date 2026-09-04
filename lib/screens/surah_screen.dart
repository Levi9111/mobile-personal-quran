import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
              _tajweedEnabled ? LucideIcons.eye : LucideIcons.eyeOff,
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

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Surah Header Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        decoration: BoxDecoration(
                          color: theme.cardTheme.color,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.metallicGold.withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'SURAH ${chapter.id}',
                              style: GoogleFonts.karla(
                                fontSize: 11,
                                letterSpacing: 2,
                                color: theme.colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              chapter.nameArabic,
                              style: GoogleFonts.scheherazadeNew(
                                fontSize: 38,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            Text(
                              chapter.nameSimple,
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${chapter.translatedName} · ${chapter.versesCount} ayahs · ${chapter.revelationPlace}',
                              style: GoogleFonts.karla(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
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
                              ? theme.colorScheme.primary.withOpacity(0.08)
                              : theme.cardTheme.color,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isPlaying
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline,
                            width: isPlaying ? 1.5 : 1,
                          ),
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
                                color: theme.colorScheme.onSurface.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.secondary.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${chapter.id}:${verse.verseNumber}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.secondary,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                OutlinedButton.icon(
                                  onPressed: () => _toggleAudio(verse.verse_key, verse.audioUrl),
                                  icon: Icon(
                                    isPlaying ? LucideIcons.pause : LucideIcons.play,
                                    size: 14,
                                  ),
                                  label: Text(isPlaying ? 'Pause' : 'Play'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: isPlaying
                                        ? Colors.white
                                        : theme.colorScheme.primary,
                                    backgroundColor: isPlaying
                                        ? theme.colorScheme.primary
                                        : Colors.transparent,
                                    side: BorderSide(
                                      color: theme.colorScheme.primary,
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
