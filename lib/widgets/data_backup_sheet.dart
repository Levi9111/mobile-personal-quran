import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/backup_service.dart';
import '../theme/app_theme.dart';

class DataBackupSheet extends StatefulWidget {
  const DataBackupSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DataBackupSheet(),
    );
  }

  @override
  State<DataBackupSheet> createState() => _DataBackupSheetState();
}

class _DataBackupSheetState extends State<DataBackupSheet> {
  final TextEditingController _restoreTextController = TextEditingController();
  bool _isExporting = false;
  bool _isRestoring = false;
  String? _statusMessage;
  bool _isSuccess = true;

  @override
  void dispose() {
    _restoreTextController.dispose();
    super.dispose();
  }

  Future<void> _shareBackup() async {
    setState(() {
      _isExporting = true;
      _statusMessage = null;
    });

    try {
      await BackupService.shareBackup();
      if (mounted) {
        setState(() {
          _isExporting = false;
          _statusMessage = 'Backup file exported & shared successfully!';
          _isSuccess = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isExporting = false;
          _statusMessage = 'Share error: $e';
          _isSuccess = false;
        });
      }
    }
  }

  Future<void> _copyBackupJson() async {
    try {
      final jsonStr = await BackupService.exportBackupJson(pretty: true);
      await Clipboard.setData(ClipboardData(text: jsonStr));
      if (mounted) {
        setState(() {
          _statusMessage = 'Backup JSON copied to clipboard!';
          _isSuccess = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup JSON copied to clipboard!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Copy error: $e';
          _isSuccess = false;
        });
      }
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      _restoreTextController.text = data.text!;
      setState(() {});
    }
  }

  Future<void> _restoreData() async {
    final text = _restoreTextController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _statusMessage = 'Please paste or enter your backup JSON text first.';
        _isSuccess = false;
      });
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore Backup?'),
        content: const Text(
          'Restoring will merge and update your bookmarks, reading progress, and settings with the backup file.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.celestialStarGold),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Restore Now', style: TextStyle(color: AppTheme.celestialMidnight)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() {
      _isRestoring = true;
      _statusMessage = null;
    });

    final result = await BackupService.restoreFromJson(text, context);

    if (mounted) {
      setState(() {
        _isRestoring = false;
        _isSuccess = result.success;
        if (result.success) {
          _statusMessage = 'Success! Restored ${result.bookmarksCount} bookmarks, '
              '${result.favoritesCount} favorites, and ${result.notesCount} personal notes.';
          _restoreTextController.clear();
        } else {
          _statusMessage = result.message;
        }
      });

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_statusMessage!),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
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
              color: Colors.black.withOpacity(0.3),
              blurRadius: 28,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SingleChildScrollView(
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
                      gradient: const LinearGradient(
                        colors: [AppTheme.celestialStarGold, Color(0xFFD97706)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.cloud_sync_rounded,
                      color: AppTheme.celestialMidnight,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data Backup & Portability',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Export, share, or restore your Quran progress',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark ? AppTheme.celestialStarlightBlue : const Color(0xFF64748B),
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

              // Status message
              if (_statusMessage != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: _isSuccess
                        ? const Color(0xFF10B981).withOpacity(0.12)
                        : Colors.redAccent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isSuccess ? const Color(0xFF10B981) : Colors.redAccent,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                        color: _isSuccess ? const Color(0xFF10B981) : Colors.redAccent,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _statusMessage!,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _isSuccess
                                ? (isDark ? const Color(0xFF34D399) : const Color(0xFF065F46))
                                : Colors.redAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Section 1: Export
              Text(
                'EXPORT DATA',
                style: GoogleFonts.karla(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: isDark ? AppTheme.celestialStarGold : const Color(0xFFB45309),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isExporting ? null : _shareBackup,
                      icon: _isExporting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.share_rounded, size: 18),
                      label: const Text('Export & Share Backup'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A),
                        foregroundColor: isDark ? AppTheme.celestialMidnight : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.outlined(
                    tooltip: 'Copy JSON to clipboard',
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    onPressed: _copyBackupJson,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isDark ? AppTheme.celestialBorderIndigo : const Color(0xFFCBD5E1),
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Section 2: Restore
              Text(
                'RESTORE DATA',
                style: GoogleFonts.karla(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: isDark ? AppTheme.celestialStarGold : const Color(0xFFB45309),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _restoreTextController,
                maxLines: 3,
                style: GoogleFonts.firaCode(fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Paste backup JSON here to restore…',
                  hintStyle: GoogleFonts.inter(fontSize: 12),
                  filled: true,
                  fillColor: isDark ? AppTheme.celestialSurfaceIndigo : const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark ? AppTheme.celestialBorderIndigo : const Color(0xFFCBD5E1),
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.paste_rounded, size: 18),
                    tooltip: 'Paste from clipboard',
                    onPressed: _pasteFromClipboard,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _isRestoring ? null : _restoreData,
                icon: _isRestoring
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.restore_page_rounded, size: 18),
                label: const Text('Restore from Backup'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF10B981),
                  side: const BorderSide(color: Color(0xFF10B981)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
