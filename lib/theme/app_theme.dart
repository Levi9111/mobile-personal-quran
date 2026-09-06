import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Celestial Anime Palette (Matching the 2D Anime Star & Crescent Moon Logo)
  static const Color celestialMidnight = Color(0xFF080D1A);
  static const Color celestialDeepIndigo = Color(0xFF0F172A);
  static const Color celestialSurfaceIndigo = Color(0xFF142038);
  static const Color celestialBorderIndigo = Color(0xFF223558);

  // Radiant Celestial Accents
  static const Color celestialStarGold = Color(0xFFFBBF24); // Glowing anime star gold
  static const Color celestialWarmAmber = Color(0xFFF59E0B);
  static const Color celestialMoonYellow = Color(0xFFF6C851);
  static const Color celestialStarlightBlue = Color(0xFF38BDF8); // Anime sky starlight
  static const Color celestialTwilightPurple = Color(0xFFA855F7); // Anime dusk purple
  static const Color primaryEmerald = Color(0xFF10B981); // Emerald accent

  // Compatibility aliases
  static const Color primaryTealLight = Color(0xFF1E3A8A);
  static const Color metallicGold = celestialStarGold;
  static const Color goldLight = celestialMoonYellow;

  // Dark Theme Colors (Celestial Anime Midnight Sky)
  static const Color darkBackground = celestialMidnight;
  static const Color darkCard = celestialDeepIndigo;
  static const Color darkSurface = celestialSurfaceIndigo;
  static const Color darkBorder = celestialBorderIndigo;
  static const Color darkForeground = Color(0xFFF8FAFC);
  static const Color darkMuted = Color(0xFF94A3B8);

  // Light Theme Colors (Celestial Anime Dawn)
  static const Color lightBackground = Color(0xFFF1F5F9);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFE2E8F0);
  static const Color lightBorder = Color(0xFFCBD5E1);
  static const Color lightForeground = Color(0xFF0F172A);
  static const Color lightMuted = Color(0xFF64748B);

  // Tajweed Colors (Vibrant Celestial Hues)
  static const Color ghunnaColor = Color(0xFFF59E0B); // Warm Gold
  static const Color qalqalahColor = Color(0xFF38BDF8); // Starlight Sky Blue
  static const Color maddColor = Color(0xFFF43F5E); // Radiant Rose
  static const Color idghamColor = Color(0xFF10B981); // Celestial Emerald
  static const Color ikhfaColor = Color(0xFFA855F7); // Anime Twilight Purple

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: celestialStarGold,
        onPrimary: celestialMidnight,
        secondary: celestialStarlightBlue,
        onSecondary: celestialMidnight,
        tertiary: celestialTwilightPurple,
        surface: darkCard,
        onSurface: darkForeground,
        outline: darkBorder,
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkForeground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: celestialStarGold,
          foregroundColor: celestialMidnight,
          elevation: 0,
          textStyle: GoogleFonts.karla(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: celestialStarGold,
          side: const BorderSide(color: celestialBorderIndigo, width: 1.2),
          textStyle: GoogleFonts.karla(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: celestialStarGold, width: 1.5),
        ),
        hintStyle: GoogleFonts.karla(
          color: darkMuted,
          fontSize: 14,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      textTheme: TextTheme(
        headlineMedium: GoogleFonts.cormorantGaramond(
          color: celestialStarGold,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.cormorantGaramond(
          color: darkForeground,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: GoogleFonts.karla(
          color: darkForeground,
          fontSize: 14,
        ),
        bodySmall: GoogleFonts.karla(
          color: darkMuted,
          fontSize: 12,
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1E3A8A),
        onPrimary: Colors.white,
        secondary: celestialWarmAmber,
        onSecondary: Colors.white,
        surface: lightCard,
        onSurface: lightForeground,
        outline: lightBorder,
      ),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: lightBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: lightForeground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
          elevation: 0,
          textStyle: GoogleFonts.karla(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1E3A8A),
          side: const BorderSide(color: lightBorder, width: 1.2),
          textStyle: GoogleFonts.karla(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 1.5),
        ),
        hintStyle: GoogleFonts.karla(
          color: lightMuted,
          fontSize: 14,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      textTheme: TextTheme(
        headlineMedium: GoogleFonts.cormorantGaramond(
          color: Color(0xFF1E3A8A),
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.cormorantGaramond(
          color: lightForeground,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: GoogleFonts.karla(
          color: lightForeground,
          fontSize: 14,
        ),
        bodySmall: GoogleFonts.karla(
          color: lightMuted,
          fontSize: 12,
        ),
      ),
    );
  }
}
