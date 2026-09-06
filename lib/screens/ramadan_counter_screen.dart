import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../utils/arabic_numerals.dart';
import '../utils/ramadan_calculator.dart';

class RamadanCounterScreen extends StatefulWidget {
  const RamadanCounterScreen({super.key});

  @override
  State<RamadanCounterScreen> createState() => _RamadanCounterScreenState();
}

class _RamadanCounterScreenState extends State<RamadanCounterScreen> {
  late Timer _timer;
  late RamadanCountdownInfo _countdown;

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        _updateCountdown();
      }
    });
  }

  void _updateCountdown() {
    setState(() {
      _countdown = RamadanCalculator.calculateCountdown();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A).withOpacity(0.7) : Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? AppTheme.celestialStarGold.withOpacity(0.5) : const Color(0xFFCBD5E1),
              ),
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ramadan Countdown',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background celestial atmosphere image
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.35 : 0.18,
              child: Image.asset(
                'assets/images/celestial_clouds.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero Header Card with Crescent & Lantern Glow
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: isDark
                          ? const LinearGradient(
                              colors: [
                                Color(0xFF172554),
                                Color(0xFF0F172A),
                                Color(0xFF1E1B4B),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : const LinearGradient(
                              colors: [
                                Color(0xFFFFFFFF),
                                Color(0xFFF1F6FE),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      border: Border.all(
                        color: AppTheme.celestialStarGold.withOpacity(0.7),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.celestialStarGold.withOpacity(0.25),
                          blurRadius: 28,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Crescent emblem
                        Container(
                          width: 84,
                          height: 84,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                AppTheme.celestialStarGold,
                                AppTheme.celestialStarlightBlue,
                                AppTheme.celestialWarmAmber,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.celestialStarGold.withOpacity(0.5),
                                blurRadius: 24,
                              ),
                            ],
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.celestialMidnight,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.nightlight_round,
                                size: 44,
                                color: AppTheme.celestialStarGold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        Text(
                          'رَمَضَانُ الْمُبَارَك',
                          style: GoogleFonts.scheherazadeNew(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.celestialStarGold : const Color(0xFFB45309),
                          ),
                        ),
                        Text(
                          _countdown.hijriName,
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Anticipated start: ${_formatDate(_countdown.targetDate)}',
                          style: GoogleFonts.karla(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Highlight Banner: Total Months and Days
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppTheme.celestialStarGold.withOpacity(0.15)
                                : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark
                                  ? AppTheme.celestialStarGold.withOpacity(0.6)
                                  : const Color(0xFFD97706),
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${_countdown.months} Months, ${_countdown.remainingDays} Days Left',
                                style: GoogleFonts.cormorantGaramond(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppTheme.celestialStarGold : const Color(0xFF92400E),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_countdown.totalDays} Total Days (${ArabicNumeralHelper.toArabic(_countdown.totalDays)} يَوْمًا)',
                                style: GoogleFonts.karla(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.white.withOpacity(0.85)
                                      : const Color(0xFF78350F),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Real-Time Live Ticker Cards
                  Text(
                    'LIVE TIME REMAINING',
                    style: GoogleFonts.karla(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      _buildTimerCard(
                        value: '${_countdown.months}',
                        arabicValue: ArabicNumeralHelper.toArabic(_countdown.months),
                        label: 'MONTHS',
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildTimerCard(
                        value: '${_countdown.remainingDays}',
                        arabicValue: ArabicNumeralHelper.toArabic(_countdown.remainingDays),
                        label: 'DAYS',
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildTimerCard(
                        value: '${_countdown.hours}'.padLeft(2, '0'),
                        arabicValue: ArabicNumeralHelper.toArabic('${_countdown.hours}'.padLeft(2, '0')),
                        label: 'HOURS',
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildTimerCard(
                        value: '${_countdown.minutes}'.padLeft(2, '0'),
                        arabicValue: ArabicNumeralHelper.toArabic('${_countdown.minutes}'.padLeft(2, '0')),
                        label: 'MIN',
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildTimerCard(
                        value: '${_countdown.seconds}'.padLeft(2, '0'),
                        arabicValue: ArabicNumeralHelper.toArabic('${_countdown.seconds}'.padLeft(2, '0')),
                        label: 'SEC',
                        isDark: isDark,
                        isSeconds: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Spiritual Preparation & Quran Khatm Milestones
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isDark ? AppTheme.celestialBorderIndigo : AppTheme.lightBorder,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.auto_stories_rounded,
                              color: AppTheme.celestialStarGold,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Ramadan Quran Plan',
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildPlanItem(
                          icon: Icons.bookmark_added_rounded,
                          title: '1 Quran Khatm (30 Days)',
                          subtitle: 'Read 1 Juz per day (approx. 4 pages after each of the 5 daily prayers).',
                          isDark: isDark,
                        ),
                        const Divider(height: 20),
                        _buildPlanItem(
                          icon: Icons.schedule_rounded,
                          title: 'Daily Consistent Habit',
                          subtitle: 'Use Noor bookmarks to never lose your spot. 15 minutes morning & evening.',
                          isDark: isDark,
                        ),
                        const Divider(height: 20),
                        _buildPlanItem(
                          icon: Icons.favorite_rounded,
                          title: 'Preparation Dua',
                          subtitle: 'اللَّهُمَّ بَلِّغْنَا رَمَضَانَ\n"Allahumma ballighna Ramadan" (O Allah, let us reach Ramadan).',
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCard({
    required String value,
    required String arabicValue,
    required String label,
    required bool isDark,
    bool isSeconds = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131F3A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSeconds
                ? AppTheme.celestialStarGold
                : (isDark ? AppTheme.celestialBorderIndigo : const Color(0xFFCBD5E1)),
            width: isSeconds ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isSeconds
                    ? AppTheme.celestialStarGold
                    : (isDark ? Colors.white : const Color(0xFF1E3A8A)),
              ),
            ),
            Text(
              arabicValue,
              style: GoogleFonts.scheherazadeNew(
                fontSize: 14,
                color: AppTheme.celestialStarGold.withOpacity(0.85),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.karla(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.celestialStarGold.withOpacity(0.12)
                : const Color(0xFF1E3A8A).withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.karla(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.karla(
                  fontSize: 12,
                  height: 1.4,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
