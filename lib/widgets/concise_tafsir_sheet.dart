import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/chapter.dart';
import '../models/verse.dart';
import '../services/tafsir_service.dart';
import '../theme/app_theme.dart';
import '../utils/arabic_numerals.dart';
import 'tajweed_text.dart';

class ConciseTafsirSheet extends StatefulWidget {
  final Chapter chapter;
  final Verse verse;

  const ConciseTafsirSheet({
    super.key,
    required this.chapter,
    required this.verse,
  });

  static Future<void> show(
    BuildContext context, {
    required Chapter chapter,
    required Verse verse,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ConciseTafsirSheet(chapter: chapter, verse: verse),
    );
  }

  @override
  State<ConciseTafsirSheet> createState() => _ConciseTafsirSheetState();
}

class _ConciseTafsirSheetState extends State<ConciseTafsirSheet> {
  late Future<TafsirData> _tafsirFuture;
  bool _showClassicalDetails = false;

  @override
  void initState() {
    super.initState();
    _tafsirFuture = TafsirService.fetchConciseTafsir(
      widget.chapter.id,
      widget.verse.verseNumber,
    );
  }

  void _copyToClipboard(TafsirData data) {
    final dualRef = ArabicNumeralHelper.formatDual(widget.chapter.id, widget.verse.verseNumber);
    final text = '''Surah ${widget.chapter.nameSimple} ${widget.verse.verseNumber} ($dualRef)
${widget.verse.textIndopak}

Translation:
"${widget.verse.translationText}"

Concise Explanation:
${data.shortExplanation}
— Source: Noor Quran App''';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppTheme.celestialStarGold, size: 18),
            SizedBox(width: 8),
            Text('Verse & Concise Tafsir copied!'),
          ],
        ),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final maxSheetHeight = MediaQuery.of(context).size.height * 0.88;

    return Container(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1222) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark
              ? AppTheme.celestialStarGold.withOpacity(0.35)
              : const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppTheme.celestialStarGold.withOpacity(0.12)
                : Colors.black12,
            blurRadius: 28,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Drag Handle
            Center(
              child: Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          AppTheme.celestialStarGold,
                          AppTheme.primaryEmerald,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.celestialStarGold.withOpacity(0.35),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(1.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? const Color(0xFF0F172A) : Colors.white,
                      ),
                      child: const Icon(
                        Icons.auto_stories_rounded,
                        size: 18,
                        color: AppTheme.celestialStarGold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Surah ${widget.chapter.nameSimple}',
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              widget.chapter.nameArabic,
                              style: const TextStyle(
                                fontFamily: 'serif',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.celestialStarGold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.celestialStarGold.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.celestialStarGold.withOpacity(0.3),
                              width: 0.6,
                            ),
                          ),
                          child: Text(
                            'Ayah ${widget.verse.verseNumber} • ${ArabicNumeralHelper.formatDual(widget.chapter.id, widget.verse.verseNumber)}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.celestialStarGold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Scrollable Tafsir Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Arabic Ayah Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF131D33) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TajweedTextWidget(
                            text: widget.verse.textIndopak,
                            fontSize: 22,
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '"${widget.verse.translationText}"',
                            style: GoogleFonts.karla(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              height: 1.4,
                              color: theme.colorScheme.onSurface.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 2. FutureBuilder for Concise Tafsir
                    FutureBuilder<TafsirData>(
                      future: _tafsirFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            padding: const EdgeInsets.all(28),
                            alignment: Alignment.center,
                            child: const Column(
                              children: [
                                CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppTheme.celestialStarGold,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Loading concise reflection...',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        }

                        if (snapshot.hasError || !snapshot.hasData) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              'Could not load Tafsir for this verse: ${snapshot.error}',
                              style: const TextStyle(fontSize: 12, color: Colors.redAccent),
                            ),
                          );
                        }

                        final data = snapshot.data!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 3. Concise Tafsir Hero Card
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDark
                                      ? [
                                          const Color(0xFF1E1B4B).withOpacity(0.8),
                                          const Color(0xFF0F172A).withOpacity(0.9),
                                        ]
                                      : [
                                          const Color(0xFFEFF6FF),
                                          const Color(0xFFFAF5FF),
                                        ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: AppTheme.celestialStarGold.withOpacity(0.55),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.celestialStarGold.withOpacity(0.12),
                                    blurRadius: 16,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.lightbulb_outline_rounded,
                                        color: AppTheme.celestialStarGold,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Concise Explanation & Spiritual Takeaway',
                                        style: GoogleFonts.cormorantGaramond(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? AppTheme.celestialStarGold
                                              : const Color(0xFF1E3A8A),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    data.shortExplanation,
                                    style: GoogleFonts.karla(
                                      fontSize: 14.5,
                                      height: 1.55,
                                      fontWeight: FontWeight.w500,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Text(
                                        'Source: ${data.author}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                                        ),
                                      ),
                                      const Spacer(),
                                      TextButton.icon(
                                        onPressed: () => _copyToClipboard(data),
                                        icon: const Icon(Icons.copy_rounded, size: 14),
                                        label: const Text('Copy', style: TextStyle(fontSize: 12)),
                                        style: TextButton.styleFrom(
                                          foregroundColor: AppTheme.celestialStarGold,
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // 4. Expandable Classical Commentary if available
                            if (data.classicalDetails != null && data.classicalDetails!.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _showClassicalDetails = !_showClassicalDetails;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF131D33) : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.menu_book_rounded, size: 16, color: AppTheme.celestialStarGold),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _showClassicalDetails
                                              ? 'Hide Detailed Classical Commentary'
                                              : 'Read More Classical Commentary (Ibn Kathir)',
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        _showClassicalDetails
                                            ? Icons.keyboard_arrow_up_rounded
                                            : Icons.keyboard_arrow_down_rounded,
                                        size: 18,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (_showClassicalDetails) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                                    ),
                                  ),
                                  child: Text(
                                    data.classicalDetails!,
                                    style: GoogleFonts.karla(
                                      fontSize: 13,
                                      height: 1.6,
                                      color: theme.colorScheme.onSurface.withOpacity(0.85),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
