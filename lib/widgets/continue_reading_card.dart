import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/bookmark.dart';
import '../models/chapter.dart';
import '../providers/bookmark_provider.dart';
import '../screens/surah_screen.dart';
import '../services/quran_service.dart';
import '../theme/app_theme.dart';
import 'bookmark_sheet.dart';

class ContinueReadingCard extends StatelessWidget {
  const ContinueReadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);
    final lastRead = bookmarkProvider.lastReadBookmark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: isDark
                ? const LinearGradient(
                    colors: [
                      Color(0xFF131F3A),
                      Color(0xFF0F172A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [
                      Color(0xFFFFFFFF),
                      Color(0xFFF8FAFC),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            border: Border.all(
              color: isDark
                  ? AppTheme.celestialStarGold.withOpacity(0.4)
                  : const Color(0xFFCBD5E1),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Celestial Bookmark Ribbon Tab (Top-Right)
              Positioned(
                top: 0,
                right: 24,
                child: Container(
                  width: 32,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppTheme.celestialStarGold,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(6),
                      bottomRight: Radius.circular(6),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.celestialStarGold.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.bookmark_rounded,
                      size: 20,
                      color: AppTheme.celestialMidnight,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header label
                    Row(
                      children: [
                        const Icon(
                          Icons.history_rounded,
                          size: 15,
                          color: AppTheme.celestialStarGold,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'CONTINUE READING',
                          style: GoogleFonts.karla(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (lastRead != null) ...[
                      // Surah & Ayah info
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lastRead.surahNameSimple,
                                  style: GoogleFonts.cormorantGaramond(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Ayah ${lastRead.verseNumber} (${lastRead.dualVerseReference})',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            lastRead.surahNameArabic,
                            style: GoogleFonts.scheherazadeNew(
                              fontSize: 26,
                              color: isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A),
                            ),
                          ),
                          const SizedBox(width: 40), // Spacing for ribbon
                        ],
                      ),

                      if (lastRead.arabicText.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF0F172A).withOpacity(0.6)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark ? AppTheme.celestialBorderIndigo : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Text(
                            lastRead.arabicText,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textDirection: TextDirection.rtl,
                            style: GoogleFonts.scheherazadeNew(
                              fontSize: 19,
                              height: 1.6,
                              color: isDark ? Colors.white.withOpacity(0.9) : const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 14),

                      // Action Buttons
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _resumeReading(context, lastRead),
                            icon: const Icon(Icons.play_arrow_rounded, size: 18),
                            label: const Text('Resume Reading'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A),
                              foregroundColor: isDark ? AppTheme.celestialMidnight : Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: () => BookmarkSheet.show(context),
                            icon: const Icon(Icons.bookmarks_rounded, size: 16),
                            label: Text('All (${bookmarkProvider.bookmarks.length})'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A),
                              side: BorderSide(
                                color: isDark
                                    ? AppTheme.celestialStarGold.withOpacity(0.5)
                                    : const Color(0xFF1E3A8A).withOpacity(0.4),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Blank State invitation
                      Text(
                        'Start Reading Quran',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bookmark verses anytime while reading to resume smoothly each day.',
                        style: GoogleFonts.karla(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        onPressed: () => _resumeReading(context, null),
                        icon: const Icon(Icons.menu_book_rounded, size: 16),
                        label: const Text('Open Surah Al-Fatihah'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A),
                          foregroundColor: isDark ? AppTheme.celestialMidnight : Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _resumeReading(BuildContext context, Bookmark? bookmark) async {
    final surahId = bookmark?.surahId ?? 1;
    try {
      final chapters = await QuranService.fetchChapters();
      final target = chapters.firstWhere(
        (c) => c.id == surahId,
        orElse: () => chapters.first,
      );
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SurahScreen(
              chapter: target,
              initialVerseNumber: bookmark?.verseNumber,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error resuming reading: $e');
    }
  }
}
