import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A theme-aware celestial background providing a glowing anime midnight sky in dark mode
/// and a luminous, warm celestial dawn and sacred parchment glow in light mode.
class CelestialBackground extends StatelessWidget {
  final Widget? child;

  const CelestialBackground({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned.fill(
          child: isDark
              ? Stack(
                  children: [
                    Container(color: AppTheme.celestialMidnight),
                    Opacity(
                      opacity: 0.32,
                      child: Image.asset(
                        'assets/images/anime_celestial_bg.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                )
              : Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFFFFDF8), // Luminous pure dawn ivory
                        Color(0xFFFAF6EB), // Warm celestial cream
                        Color(0xFFF6EFE2), // Gentle parchment dawn
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Delicate ambient celestial warm sun/moon glow at top right
                      Positioned(
                        top: -60,
                        right: -60,
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFFFDE68A).withOpacity(0.35),
                                const Color(0xFFFDE68A).withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Soft morning starlight glow at bottom left
                      Positioned(
                        bottom: -40,
                        left: -40,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFFBAE6FD).withOpacity(0.25),
                                const Color(0xFFBAE6FD).withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        if (child != null) child!,
      ],
    );
  }
}
