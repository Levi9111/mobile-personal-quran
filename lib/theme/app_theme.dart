import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors (Islamic Emerald & Gold Palette)
  static const Color primaryEmerald = Color(0xFF38A385);
  static const Color primaryTealLight = Color(0xFF1B6B58);
  static const Color metallicGold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFC5A059);

  // Dark Theme Colors (Nocturnal Emerald)
  static const Color darkBackground = Color(0xFF0F1A17);
  static const Color darkCard = Color(0xFF162622);
  static const Color darkSurface = Color(0xFF1A2D28);
  static const Color darkBorder = Color(0xFF243A34);
  static const Color darkForeground = Color(0xFFF0F5F3);
  static const Color darkMuted = Color(0xFF8FA89F);

  // Light Theme Colors (Cream & Silk)
  static const Color lightBackground = Color(0xFFF8F6F0);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF1EDE4);
  static const Color lightBorder = Color(0xFFE2DCD0);
  static const Color lightForeground = Color(0xFF1F332C);
  static const Color lightMuted = Color(0xFF637D74);

  // Tajweed Colors
  static const Color ghunnaColor = Color(0xFFE6A15C); // Warm Gold
  static const Color qalqalahColor = Color(0xFF5C9EE6); // Sky Blue
  static const Color maddColor = Color(0xFFE65C5C); // Crimson Red
  static const Color idghamColor = Color(0xFF5CE6A1); // Emerald Green
  static const Color ikhfaColor = Color(0xFFC25CE6); // Purple Violet

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryEmerald,
        onPrimary: darkBackground,
        secondary: metallicGold,
        surface: darkCard,
        onSurface: darkForeground,
        outline: darkBorder,
      ),
      cardTheme: CardTheme(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
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
      textTheme: TextTheme(
        headlineMedium: GoogleFonts.cormorantGaramond(
          color: primaryEmerald,
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
        primary: primaryTealLight,
        onPrimary: Colors.white,
        secondary: goldLight,
        surface: lightCard,
        onSurface: lightForeground,
        outline: lightBorder,
      ),
      cardTheme: CardTheme(
        color: lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
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
      textTheme: TextTheme(
        headlineMedium: GoogleFonts.cormorantGaramond(
          color: primaryTealLight,
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
