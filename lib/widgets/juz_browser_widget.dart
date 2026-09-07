import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/chapter.dart';
import '../models/juz.dart';
import '../screens/surah_screen.dart';
import '../services/quran_service.dart';
import '../theme/app_theme.dart';
import '../utils/arabic_numerals.dart';

class JuzBrowserWidget extends StatelessWidget {
  final List<Chapter> chapters;

  const JuzBrowserWidget({super.key, required this.chapters});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: JuzInfo.all30Juz.length,
      itemBuilder: (context, index) {
        final juz = JuzInfo.all30Juz[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => _openJuz(context, juz),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? AppTheme.celestialBorderIndigo : AppTheme.lightBorder,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Juz Number Star Badge
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.celestialStarGold.withOpacity(0.12)
                            : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppTheme.celestialStarGold.withOpacity(0.6)
                              : const Color(0xFFF59E0B),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'JUZ',
                            style: GoogleFonts.karla(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: isDark ? AppTheme.celestialStarGold : AppTheme.lightStarGold,
                            ),
                          ),
                          Text(
                            '${juz.juzNumber}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.celestialStarGold : AppTheme.lightStarGold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Transliteration & Surah Range
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                juz.nameTransliteration,
                                style: GoogleFonts.cormorantGaramond(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '(${ArabicNumeralHelper.toArabic(juz.juzNumber)})',
                                style: GoogleFonts.scheherazadeNew(
                                  fontSize: 14,
                                  color: AppTheme.getAccentGold(isDark),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            juz.rangeDescription,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.karla(
                              fontSize: 11,
                              color: theme.colorScheme.onSurface.withOpacity(0.65),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Arabic Name
                    Text(
                      juz.nameArabic,
                      style: GoogleFonts.scheherazadeNew(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.celestialStarGold : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: theme.colorScheme.onSurface.withOpacity(0.35),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openJuz(BuildContext context, JuzInfo juz) async {
    try {
      final target = chapters.firstWhere(
        (c) => c.id == juz.startSurahId,
        orElse: () => chapters.first,
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SurahScreen(
            chapter: target,
            initialVerseNumber: juz.startVerseNumber,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error opening juz: $e');
    }
  }
}
