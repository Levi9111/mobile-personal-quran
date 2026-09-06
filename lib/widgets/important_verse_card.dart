import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import '../models/chapter.dart';
import '../models/important_verse.dart';
import '../providers/important_verses_provider.dart';
import '../screens/surah_screen.dart';
import '../services/quran_service.dart';
import '../theme/app_theme.dart';
import 'tajweed_text.dart';

class ImportantVerseCard extends StatefulWidget {
  final ImportantVerse verse;
  final bool isPlaying;
  final VoidCallback onTogglePlay;
  final bool tajweedEnabled;
  final Function(String occasion)? onSelectOccasion;

  const ImportantVerseCard({
    super.key,
    required this.verse,
    required this.isPlaying,
    required this.onTogglePlay,
    this.tajweedEnabled = true,
    this.onSelectOccasion,
  });

  @override
  State<ImportantVerseCard> createState() => _ImportantVerseCardState();
}

class _ImportantVerseCardState extends State<ImportantVerseCard> {
  bool _isExpanded = false;

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Protection & Safety':
        return AppTheme.primaryEmerald; // Celestial Emerald
      case 'Tawheed & Faith':
        return AppTheme.celestialStarGold; // Glowing Anime Star Gold
      case 'Patience & Perseverance':
        return AppTheme.celestialStarlightBlue; // Starlight Sky
      case 'Mercy & Forgiveness':
        return AppTheme.celestialTwilightPurple; // Twilight Violet
      case 'Daily Recitation':
        return const Color(0xFF06B6D4); // Cyan Starlight
      case 'Quranic Duas':
      case 'Prophetic Prayers':
        return AppTheme.celestialWarmAmber; // Radiant Amber
      case 'Family & Parents':
        return const Color(0xFFFB7185); // Celestial Rose
      case 'Knowledge & Wisdom':
        return const Color(0xFF60A5FA); // Celestial Azure
      default:
        return AppTheme.celestialStarGold;
    }
  }

  void _showNoteDialog(BuildContext context, ImportantVersesProvider provider) {
    final existingNote = provider.getPersonalNote(widget.verse.verseKey) ?? '';
    final textController = TextEditingController(text: existingNote);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.celestialDeepIndigo : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              size: 14,
                              color: AppTheme.celestialStarGold,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Personal Reflections',
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${widget.verse.surahName} (${widget.verse.verseKey})',
                          style: GoogleFonts.karla(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.celestialStarGold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                maxLines: 5,
                autofocus: true,
                decoration: InputDecoration(
                  hintText:
                      'Write your personal reflections, insights, or du\'a intentions for this verse…',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  filled: true,
                  fillColor: isDark ? AppTheme.celestialMidnight : const Color(0xFFF8FAFC),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (existingNote.isNotEmpty) ...[
                    TextButton.icon(
                      onPressed: () {
                        provider.removePersonalNote(widget.verse.verseKey);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Note deleted')),
                        );
                      },
                      icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                      label: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                    ),
                    const Spacer(),
                  ],
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      final text = textController.text.trim();
                      if (text.isEmpty) {
                        provider.removePersonalNote(widget.verse.verseKey);
                      } else {
                        provider.savePersonalNote(widget.verse.verseKey, text);
                      }
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reflection saved')),
                      );
                    },
                    icon: const Icon(Icons.save_rounded, size: 16),
                    label: const Text('Save Reflection'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A),
                      foregroundColor: isDark ? AppTheme.celestialMidnight : Colors.white,
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
    );
  }

  void _navigateToSurah(BuildContext context) {
    final chapter = Chapter(
      id: widget.verse.surahNumber,
      nameSimple: widget.verse.surahName,
      nameArabic: '',
      versesCount: 0,
      revelationPlace: '',
      translatedName: widget.verse.surahName,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SurahScreen(chapter: chapter),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = Provider.of<ImportantVersesProvider>(context);
    final isFav = provider.isFavorite(widget.verse.id);
    final hasNote = provider.hasPersonalNote(widget.verse.verseKey);
    final personalNote = provider.getPersonalNote(widget.verse.verseKey);
    final categoryColor = _getCategoryColor(widget.verse.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: widget.isPlaying
            ? (isDark ? const Color(0xFF16233F) : const Color(0xFFFEF9C3).withOpacity(0.4))
            : theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isPlaying
              ? AppTheme.celestialStarGold
              : isFav
                  ? (isDark ? AppTheme.celestialStarGold.withOpacity(0.7) : const Color(0xFF1E3A8A).withOpacity(0.5))
                  : (isDark ? AppTheme.celestialBorderIndigo : AppTheme.lightBorder),
          width: widget.isPlaying ? 1.5 : 1,
        ),
        boxShadow: widget.isPlaying
            ? [
                BoxShadow(
                  color: AppTheme.celestialStarGold.withOpacity(0.25),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ]
            : [
                BoxShadow(
                  color: isDark
                      ? const Color(0xFF020617).withOpacity(0.4)
                      : Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Badges Row
            Row(
              children: [
                // Category Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: categoryColor.withOpacity(0.5), width: 1),
                  ),
                  child: Text(
                    widget.verse.category,
                    style: GoogleFonts.karla(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: categoryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Surah & Ayah Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.celestialStarGold.withOpacity(0.12)
                        : const Color(0xFF1E3A8A).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? AppTheme.celestialStarGold.withOpacity(0.5)
                          : const Color(0xFF1E3A8A).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${widget.verse.surahName} ${widget.verse.verseKey}',
                    style: GoogleFonts.karla(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A),
                    ),
                  ),
                ),
                const Spacer(),
                // Favorite Heart Button
                IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFav ? const Color(0xFFF43F5E) : theme.colorScheme.onSurface.withOpacity(0.4),
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => provider.toggleFavorite(widget.verse.id),
                  tooltip: isFav ? 'Remove from favorites' : 'Add to favorites',
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              widget.verse.title,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 14),

            // Arabic Text (Indo-Pak Script with Tajweed colors)
            TajweedTextWidget(
              text: widget.verse.textIndopak,
              enabled: widget.tajweedEnabled,
              fontSize: 26,
            ),
            const SizedBox(height: 12),

            // English Translation
            Text(
              widget.verse.translation,
              style: GoogleFonts.karla(
                fontSize: 14,
                height: 1.55,
                color: theme.colorScheme.onSurface.withOpacity(0.85),
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons Row (Play, Note, Expand, Read in Surah)
            Row(
              children: [
                // Audio Play/Pause Button
                OutlinedButton.icon(
                  onPressed: widget.onTogglePlay,
                  icon: Icon(
                    widget.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 16,
                    color: widget.isPlaying
                        ? (isDark ? AppTheme.celestialMidnight : Colors.white)
                        : (isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A)),
                  ),
                  label: Text(
                    widget.isPlaying ? 'Pause' : 'Recitation',
                    style: TextStyle(
                      color: widget.isPlaying
                          ? (isDark ? AppTheme.celestialMidnight : Colors.white)
                          : (isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A)),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: widget.isPlaying
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
                const SizedBox(width: 8),

                // Note Reflection Button
                IconButton.outlined(
                  onPressed: () => _showNoteDialog(context, provider),
                  icon: Icon(
                    hasNote ? Icons.edit_note_rounded : Icons.note_add_outlined,
                    size: 18,
                    color: hasNote
                        ? AppTheme.celestialStarGold
                        : theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  tooltip: hasNote ? 'View / Edit Note' : 'Add Note',
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: hasNote
                          ? AppTheme.celestialStarGold
                          : (isDark ? AppTheme.celestialBorderIndigo : AppTheme.lightBorder),
                    ),
                    padding: const EdgeInsets.all(8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const Spacer(),

                // Expand / Collapse Details Button
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  icon: Icon(
                    _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                  ),
                  label: Text(
                    _isExpanded ? 'Hide Details' : 'Significance',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),

            // Expandable Details Section
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Divider(height: 24),

                  // Occasions for Recitation
                  if (widget.verse.occasions.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 15, color: AppTheme.metallicGold),
                        const SizedBox(width: 6),
                        Text(
                          'RECOMMENDED OCCASIONS',
                          style: GoogleFonts.karla(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: widget.verse.occasions.map((occ) {
                        return ActionChip(
                          label: Text(occ),
                          labelStyle: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.primary,
                          ),
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
                          side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.25)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                          onPressed: () {
                            if (widget.onSelectOccasion != null) {
                              widget.onSelectOccasion!(occ);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Theological Significance
                  Row(
                    children: [
                      Icon(Icons.auto_stories_rounded, size: 15, color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        'THEOLOGICAL SIGNIFICANCE',
                        style: GoogleFonts.karla(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.verse.significance,
                    style: GoogleFonts.karla(
                      fontSize: 13,
                      height: 1.55,
                      color: theme.colorScheme.onSurface.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Virtues and Blessings
                  if (widget.verse.blessings.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.stars_rounded, size: 15, color: AppTheme.metallicGold),
                        const SizedBox(width: 6),
                        Text(
                          'BLESSINGS & VIRTUES',
                          style: GoogleFonts.karla(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.verse.blessings,
                      style: GoogleFonts.karla(
                        fontSize: 13,
                        height: 1.5,
                        color: theme.colorScheme.onSurface.withOpacity(0.85),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Authentic Reference Source
                  if (widget.verse.reference.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.verified_rounded, size: 14, color: theme.colorScheme.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Reference: ${widget.verse.reference}',
                              style: GoogleFonts.karla(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Personal Reflection Note (if saved)
                  if (hasNote && personalNote != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.metallicGold.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.metallicGold.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.bookmark_rounded, size: 14, color: AppTheme.metallicGold),
                              const SizedBox(width: 6),
                              Text(
                                'My Reflection Note',
                                style: GoogleFonts.karla(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.metallicGold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            personalNote,
                            style: GoogleFonts.karla(
                              fontSize: 12,
                              height: 1.4,
                              color: theme.colorScheme.onSurface.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // "Read in Surah →" Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _navigateToSurah(context),
                      icon: const Icon(Icons.menu_book_rounded, size: 16),
                      label: Text('Read in Surah ${widget.verse.surahName} →'),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
              crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }
}
