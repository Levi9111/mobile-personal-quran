import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/ramadan_counter_screen.dart';
import '../theme/app_theme.dart';
import '../utils/arabic_numerals.dart';
import '../utils/ramadan_calculator.dart';

class RamadanCountdownCard extends StatelessWidget {
  const RamadanCountdownCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final countdown = RamadanCalculator.calculateCountdown();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const RamadanCounterScreen(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(
                      colors: [
                        Color(0xFF1E1B4B),
                        Color(0xFF0F172A),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : const LinearGradient(
                      colors: [
                        Color(0xFFFFFBEB),
                        Color(0xFFFEF3C7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark
                    ? AppTheme.celestialStarGold.withOpacity(0.5)
                    : const Color(0xFFF59E0B).withOpacity(0.6),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? AppTheme.celestialStarGold.withOpacity(0.12)
                      : const Color(0xFFF59E0B).withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Glowing crescent badge
                Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        AppTheme.celestialStarGold,
                        AppTheme.celestialWarmAmber,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.celestialStarGold.withOpacity(0.4),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    ),
                    child: const Icon(
                      Icons.nightlight_round,
                      size: 24,
                      color: AppTheme.celestialStarGold,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'RAMADAN COUNTDOWN',
                            style: GoogleFonts.karla(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.8,
                              color: isDark ? AppTheme.celestialStarGold : const Color(0xFFB45309),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'رَمَضَان',
                            style: GoogleFonts.scheherazadeNew(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.celestialStarGold : const Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${countdown.months} Months, ${countdown.remainingDays} Days Left',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${countdown.totalDays} Total Days (${ArabicNumeralHelper.toArabic(countdown.totalDays)} يَوْمًا) · Tap to view counter',
                        style: GoogleFonts.karla(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withOpacity(0.65),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isDark ? AppTheme.celestialStarGold : const Color(0xFFB45309),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
