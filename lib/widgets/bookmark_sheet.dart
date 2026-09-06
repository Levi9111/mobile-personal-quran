import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/bookmark.dart';
import '../providers/bookmark_provider.dart';
import '../screens/surah_screen.dart';
import '../services/quran_service.dart';
import '../theme/app_theme.dart';

class BookmarkSheet extends StatelessWidget {
  const BookmarkSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const BookmarkSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);
    final bookmarks = bookmarkProvider.bookmarks;

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark ? AppTheme.celestialStarGold.withOpacity(0.4) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.celestialStarGold.withOpacity(0.15)
                        : const Color(0xFF1E3A8A).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bookmark_rounded,
                    color: AppTheme.celestialStarGold,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saved Bookmarks',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '${bookmarks.length} verses saved for daily reflection',
                      style: GoogleFonts.karla(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Bookmarks List or Empty State
          Expanded(
            child: bookmarks.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bookmark_border_rounded,
                            size: 56,
                            color: isDark ? AppTheme.celestialStarGold.withOpacity(0.4) : Colors.black26,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Bookmarks Yet',
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'While reciting any Surah, tap the bookmark icon to mark your spot for the day.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.karla(
                              fontSize: 13,
                              color: theme.colorScheme.onSurface.withOpacity(0.65),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      16,
                      12,
                      16,
                      MediaQuery.of(context).padding.bottom + 28,
                    ),
                    itemCount: bookmarks.length,
                    itemBuilder: (context, index) {
                      final bookmark = bookmarks[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF131F3A) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDark ? AppTheme.celestialBorderIndigo : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              Navigator.pop(context);
                              _navigateToBookmark(context, bookmark);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? AppTheme.celestialStarGold.withOpacity(0.15)
                                              : const Color(0xFF1E3A8A).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isDark
                                                ? AppTheme.celestialStarGold.withOpacity(0.5)
                                                : const Color(0xFF1E3A8A).withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          bookmark.dualVerseReference,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        bookmark.surahNameSimple,
                                        style: GoogleFonts.cormorantGaramond(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        bookmark.surahNameArabic,
                                        style: GoogleFonts.scheherazadeNew(
                                          fontSize: 20,
                                          color: isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                        color: Colors.redAccent.withOpacity(0.7),
                                        onPressed: () {
                                          bookmarkProvider.removeBookmark(bookmark.id);
                                        },
                                      ),
                                    ],
                                  ),
                                  if (bookmark.arabicText.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    Text(
                                      bookmark.arabicText,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textDirection: TextDirection.rtl,
                                      style: GoogleFonts.scheherazadeNew(
                                        fontSize: 19,
                                        height: 1.5,
                                        color: isDark ? Colors.white.withOpacity(0.9) : const Color(0xFF1E293B),
                                      ),
                                    ),
                                  ],
                                  if (bookmark.translationText.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      bookmark.translationText,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.karla(
                                        fontSize: 12,
                                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time_rounded,
                                        size: 12,
                                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatBookmarkTime(bookmark.timestamp),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        'Tap to open →',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  static void _navigateToBookmark(BuildContext context, Bookmark bookmark) async {
    try {
      final chapters = await QuranService.fetchChapters();
      final target = chapters.firstWhere(
        (c) => c.id == bookmark.surahId,
        orElse: () => chapters.first,
      );
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SurahScreen(
              chapter: target,
              initialVerseNumber: bookmark.verseNumber,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error navigating to bookmark: $e');
    }
  }

  static String _formatBookmarkTime(DateTime dt) {
    final now = DateTime.now();
    final difference = now.difference(dt);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes.clamp(1, 60)}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
