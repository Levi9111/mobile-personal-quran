import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/bookmark_provider.dart';
import '../providers/theme_provider.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../widgets/data_backup_sheet.dart';
import 'important_verses_screen.dart';
import 'ramadan_counter_screen.dart';
import 'tajweed_guide_screen.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);
    final notifService = NotificationService();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.settings_suggest_rounded,
                  color: AppTheme.getAccentGold(isDark),
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  'Settings & Preferences',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 1. APPEARANCE & THEME SECTION
          _buildSectionHeader('APPEARANCE & THEME', isDark),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.celestialDeepIndigo : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppTheme.celestialBorderIndigo : const Color(0xFFEADBCE),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.celestialStarGold.withOpacity(0.15)
                            : const Color(0xFFFEF3C7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                        color: isDark ? AppTheme.celestialStarGold : const Color(0xFFB45309),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isDark ? 'Dark Mode' : 'Light Mode',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          isDark ? 'Celestial Midnight theme' : 'Warm Sacred Parchment theme',
                          style: GoogleFonts.karla(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Switch.adaptive(
                  value: isDark,
                  activeColor: AppTheme.celestialStarGold,
                  activeTrackColor: AppTheme.celestialStarGold.withOpacity(0.4),
                  onChanged: (val) {
                    themeProvider.toggleTheme();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 2. READING REMINDERS & NOTIFICATIONS
          _buildSectionHeader('READING REMINDERS & NOTIFICATIONS', isDark),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.celestialDeepIndigo : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppTheme.celestialBorderIndigo : const Color(0xFFEADBCE),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppTheme.primaryEmerald.withOpacity(0.15)
                                : const Color(0xFFD1FAE5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.notifications_active_rounded,
                            color: isDark ? AppTheme.primaryEmerald : const Color(0xFF047857),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Periodic Reminders',
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'Remind to recite every 8 hours',
                              style: GoogleFonts.karla(
                                fontSize: 12,
                                color: isDark ? Colors.white60 : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Switch.adaptive(
                      value: notifService.reminder8HourEnabled,
                      activeColor: AppTheme.primaryEmerald,
                      activeTrackColor: AppTheme.primaryEmerald.withOpacity(0.4),
                      onChanged: (val) async {
                        await notifService.set8HourReminderEnabled(val);
                        (context as Element).markNeedsBuild();
                      },
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Icon(
                      Icons.bedtime_outlined,
                      size: 16,
                      color: isDark ? AppTheme.celestialStarGold : const Color(0xFFB45309),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Quiet Hours: 22:00 – 05:00 (Sleep hours preserved)',
                        style: GoogleFonts.karla(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    notifService.triggerTestNotification(context, bookmarkProvider);
                  },
                  icon: const Icon(Icons.send_rounded, size: 15),
                  label: const Text('Send Test Reminder Notification'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? AppTheme.celestialStarGold : const Color(0xFFB45309),
                    side: BorderSide(
                      color: isDark
                          ? AppTheme.celestialStarGold.withOpacity(0.5)
                          : const Color(0xFFEADBCE),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 3. DATA BACKUP & PORTABILITY
          _buildSectionHeader('DATA BACKUP & RESTORE', isDark),
          const SizedBox(height: 8),
          Material(
            color: isDark ? AppTheme.celestialDeepIndigo : Colors.white,
            borderRadius: BorderRadius.circular(20),
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppTheme.celestialBorderIndigo : const Color(0xFFEADBCE),
                  width: 1.2,
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.celestialStarlightBlue.withOpacity(0.15)
                            : const Color(0xFFE0F2FE),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.cloud_sync_rounded,
                        color: isDark ? AppTheme.celestialStarlightBlue : const Color(0xFF0284C7),
                        size: 22,
                      ),
                    ),
                    title: Text(
                      'Backup & Restore Quran Data',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    subtitle: Text(
                      'Export bookmarks, notes, and streak to JSON or restore',
                      style: GoogleFonts.karla(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => DataBackupSheet.show(context),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 4. LEARNING & GUIDES SECTION
          _buildSectionHeader('LEARNING & GUIDES', isDark),
          const SizedBox(height: 8),
          Material(
            color: isDark ? AppTheme.celestialDeepIndigo : Colors.white,
            borderRadius: BorderRadius.circular(20),
            elevation: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppTheme.celestialBorderIndigo : const Color(0xFFEADBCE),
                  width: 1.2,
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.celestialStarGold.withOpacity(0.15)
                            : const Color(0xFFFEF3C7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: isDark ? AppTheme.celestialStarGold : const Color(0xFFB45309),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Tajweed Colour Guide',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    subtitle: Text(
                      'Learn the 5 rules: Ghunna, Qalqalah, Madd, Idgham, Ikhfa',
                      style: GoogleFonts.karla(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TajweedGuideScreen(),
                        ),
                      );
                    },
                  ),
                  Divider(
                    height: 1,
                    color: isDark ? AppTheme.celestialBorderIndigo : const Color(0xFFF1E9DE),
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF7C3AED).withOpacity(0.15)
                            : const Color(0xFFF3E8FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.stars_rounded,
                        color: Color(0xFF8B5CF6),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Important Verses & Duas',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    subtitle: Text(
                      'Curated Quranic duas, protection, and prophetic prayers',
                      style: GoogleFonts.karla(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ImportantVersesScreen(),
                        ),
                      );
                    },
                  ),
                  Divider(
                    height: 1,
                    color: isDark ? AppTheme.celestialBorderIndigo : const Color(0xFFF1E9DE),
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.celestialWarmAmber.withOpacity(0.15)
                            : const Color(0xFFFEF3C7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.nightlight_round,
                        color: isDark ? AppTheme.celestialWarmAmber : const Color(0xFFD97706),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Ramadan Countdown',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    subtitle: Text(
                      'Live countdown to Ramadan 1448 AH & Khatm plan',
                      style: GoogleFonts.karla(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RamadanCounterScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 5. ABOUT NOOR
          _buildSectionHeader('ABOUT NOOR', isDark),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.celestialDeepIndigo : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppTheme.celestialBorderIndigo : const Color(0xFFEADBCE),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/noor_logo.png',
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Noor Holy Quran',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Version 1.0.0 • Indo-Pak Script',
                          style: GoogleFonts.karla(
                            fontSize: 12,
                            color: isDark ? AppTheme.celestialStarGold : const Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Designed for serene, distraction-free Quranic recitation with authentic Indo-Pak calligraphy, Tajweed colour rules, and high-fidelity recitation by Sheikh Mishary Rashid Alafasy.',
                  style: GoogleFonts.karla(
                    fontSize: 12,
                    height: 1.5,
                    color: isDark ? Colors.white70 : const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: GoogleFonts.karla(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: isDark ? AppTheme.celestialStarGold : const Color(0xFFB45309),
        ),
      ),
    );
  }
}
