import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/chapter.dart';
import '../models/verse.dart';
import '../services/offline_audio_manager.dart';
import '../theme/app_theme.dart';

class OfflineAudioSheet extends StatefulWidget {
  final Chapter chapter;
  final List<Verse> verses;
  final VoidCallback? onStatusChanged;

  const OfflineAudioSheet({
    super.key,
    required this.chapter,
    required this.verses,
    this.onStatusChanged,
  });

  static void show(
    BuildContext context, {
    required Chapter chapter,
    required List<Verse> verses,
    VoidCallback? onStatusChanged,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OfflineAudioSheet(
        chapter: chapter,
        verses: verses,
        onStatusChanged: onStatusChanged,
      ),
    );
  }

  @override
  State<OfflineAudioSheet> createState() => _OfflineAudioSheetState();
}

class _OfflineAudioSheetState extends State<OfflineAudioSheet> {
  bool _isLoading = true;
  bool _isDownloading = false;
  int _downloadedCount = 0;
  int _surahSizeBytes = 0;
  int _totalAudioBytes = 0;
  double _downloadFraction = 0.0;
  String? _statusMessage;
  StreamSubscription<DownloadProgress>? _downloadSub;

  @override
  void initState() {
    super.initState();
    _refreshStats();
  }

  @override
  void dispose() {
    _downloadSub?.cancel();
    super.dispose();
  }

  Future<void> _refreshStats() async {
    setState(() => _isLoading = true);
    final count = await OfflineAudioManager.getDownloadedVerseCount(widget.chapter.id);
    final surahBytes = await OfflineAudioManager.getSurahDiskSizeBytes(widget.chapter.id);
    final totalBytes = await OfflineAudioManager.getTotalAudioDiskSizeBytes();

    if (mounted) {
      setState(() {
        _downloadedCount = count;
        _surahSizeBytes = surahBytes;
        _totalAudioBytes = totalBytes;
        _downloadFraction = widget.verses.isNotEmpty ? count / widget.verses.length : 0.0;
        _isLoading = false;
      });
    }
  }

  void _startDownload() {
    setState(() {
      _isDownloading = true;
      _statusMessage = 'Downloading recitations…';
    });

    _downloadSub?.cancel();
    _downloadSub = OfflineAudioManager.downloadSurah(
      chapter: widget.chapter,
      verses: widget.verses,
    ).listen(
      (progress) {
        if (!mounted) return;
        setState(() {
          _downloadedCount = progress.completedVerses;
          _downloadFraction = progress.fraction;
          if (progress.error != null) {
            _statusMessage = progress.error;
            _isDownloading = false;
          } else if (progress.isDone) {
            _statusMessage = 'All ${progress.totalVerses} verses downloaded for offline listening!';
            _isDownloading = false;
            widget.onStatusChanged?.call();
          }
        });
        if (progress.isDone) {
          _refreshStats();
        }
      },
      onError: (err) {
        if (mounted) {
          setState(() {
            _isDownloading = false;
            _statusMessage = 'Download error: $err';
          });
        }
      },
    );
  }

  void _cancelDownload() {
    OfflineAudioManager.cancelDownload(widget.chapter.id);
    setState(() {
      _isDownloading = false;
      _statusMessage = 'Download stopped.';
    });
  }

  Future<void> _deleteSurahAudio() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Offline Audio?'),
        content: Text('Remove offline recitations for Surah ${widget.chapter.nameSimple}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await OfflineAudioManager.deleteSurahAudio(widget.chapter.id);
      await _refreshStats();
      widget.onStatusChanged?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Offline audio deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalVerses = widget.verses.isNotEmpty ? widget.verses.length : widget.chapter.versesCount;
    final isFullyDownloaded = _downloadedCount >= totalVerses && totalVerses > 0;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.celestialDeepIndigo : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark ? AppTheme.celestialBorderIndigo : AppTheme.celestialStarlightBlue.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 28,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.celestialBorderIndigo : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isFullyDownloaded
                        ? [const Color(0xFF10B981), const Color(0xFF059669)]
                        : [AppTheme.celestialStarGold, const Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isFullyDownloaded ? Icons.cloud_done_rounded : Icons.offline_pin_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Offline Audio Manager',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Surah ${widget.chapter.nameSimple} (${widget.chapter.nameArabic})',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: isDark ? AppTheme.celestialStarGold : const Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 18),

          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(),
              ),
            )
          else ...[
            // Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.celestialSurfaceIndigo : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? AppTheme.celestialBorderIndigo : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Offline Storage Status',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : const Color(0xFF475569),
                        ),
                      ),
                      Text(
                        isFullyDownloaded
                            ? 'Ready Offline ✓'
                            : '$_downloadedCount / $totalVerses downloaded',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isFullyDownloaded
                              ? const Color(0xFF10B981)
                              : (isDark ? AppTheme.celestialStarGold : const Color(0xFFD97706)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _downloadFraction.clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: isDark ? AppTheme.celestialBorderIndigo : const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isFullyDownloaded ? const Color(0xFF10B981) : AppTheme.celestialStarGold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'This Surah: ${OfflineAudioManager.formatBytes(_surahSizeBytes)}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        'Total App Cache: ${OfflineAudioManager.formatBytes(_totalAudioBytes)}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            if (_statusMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _statusMessage!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppTheme.celestialStarlightBlue : const Color(0xFF0284C7),
                  ),
                ),
              ),

            // Action Buttons
            if (_isDownloading)
              ElevatedButton.icon(
                onPressed: _cancelDownload,
                icon: const Icon(Icons.pause_circle_outline_rounded),
                label: const Text('Pause Download'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              )
            else if (!isFullyDownloaded)
              ElevatedButton.icon(
                onPressed: _startDownload,
                icon: const Icon(Icons.download_rounded),
                label: Text(
                  _downloadedCount > 0
                      ? 'Resume Download (${totalVerses - _downloadedCount} remaining)'
                      : 'Download Surah Audio (${totalVerses} Verses)',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A),
                  foregroundColor: isDark ? AppTheme.celestialMidnight : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _deleteSurahAudio,
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                      label: const Text('Delete Audio', style: TextStyle(color: Colors.redAccent)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.check_circle_rounded, size: 18),
                      label: const Text('Ready to Listen'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }
}
