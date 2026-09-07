import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ArabicScriptType {
  uthmani, // Madani / Medina classic Hafs script
  indopak, // Indo-Pak / Nastaliq Subcontinent script
  naskh,   // Modern clean Naskh
}

class QuranTypographyProvider with ChangeNotifier {
  static const String _keyScriptType = 'noor_arabic_script_type';
  static const String _keyFontSize = 'noor_arabic_font_size';

  ArabicScriptType _scriptType = ArabicScriptType.uthmani;
  double _fontSize = 24.0;

  static const double minFontSize = 18.0;
  static const double maxFontSize = 38.0;
  static const double defaultFontSize = 24.0;

  ArabicScriptType get scriptType => _scriptType;
  double get fontSize => _fontSize;

  QuranTypographyProvider() {
    _loadPreferences();
  }

  Future<void> reload() => _loadPreferences();

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scriptIndex = prefs.getInt(_keyScriptType);
      if (scriptIndex != null && scriptIndex < ArabicScriptType.values.length) {
        _scriptType = ArabicScriptType.values[scriptIndex];
      }
      _fontSize = prefs.getDouble(_keyFontSize) ?? defaultFontSize;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading typography preferences: $e');
    }
  }

  Future<void> setScriptType(ArabicScriptType type) async {
    if (_scriptType == type) return;
    _scriptType = type;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyScriptType, type.index);
    } catch (e) {
      debugPrint('Error saving script type: $e');
    }
  }

  Future<void> setFontSize(double size) async {
    final clamped = size.clamp(minFontSize, maxFontSize);
    if ((_fontSize - clamped).abs() < 0.1) return;
    _fontSize = clamped;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_keyFontSize, clamped);
    } catch (e) {
      debugPrint('Error saving font size: $e');
    }
  }

  Future<void> increaseFontSize() async {
    await setFontSize(_fontSize + 2.0);
  }

  Future<void> decreaseFontSize() async {
    await setFontSize(_fontSize - 2.0);
  }

  Future<void> resetDefaults() async {
    _scriptType = ArabicScriptType.uthmani;
    _fontSize = defaultFontSize;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyScriptType, _scriptType.index);
      await prefs.setDouble(_keyFontSize, _fontSize);
    } catch (e) {
      debugPrint('Error resetting typography: $e');
    }
  }

  String get scriptName {
    switch (_scriptType) {
      case ArabicScriptType.uthmani:
        return 'Uthmani (Madani)';
      case ArabicScriptType.indopak:
        return 'Indo-Pak (Nastaliq)';
      case ArabicScriptType.naskh:
        return 'Modern Naskh';
    }
  }

  String get scriptDescription {
    switch (_scriptType) {
      case ArabicScriptType.uthmani:
        return 'Traditional Medina Mushaf Hafs script';
      case ArabicScriptType.indopak:
        return 'South Asian Subcontinent Nastaliq style';
      case ArabicScriptType.naskh:
        return 'Crisp contemporary Arabic typography';
    }
  }

  double get lineHeight {
    switch (_scriptType) {
      case ArabicScriptType.indopak:
        return 2.5;
      case ArabicScriptType.uthmani:
        return 2.2;
      case ArabicScriptType.naskh:
        return 2.0;
    }
  }

  TextStyle getArabicTextStyle({
    Color? color,
    double? customSize,
    FontWeight? fontWeight,
    double? height,
  }) {
    final size = customSize ?? _fontSize;
    final effectiveHeight = height ?? lineHeight;

    switch (_scriptType) {
      case ArabicScriptType.indopak:
        return GoogleFonts.notoNastaliqUrdu(
          fontSize: size * 0.90, // Nastaliq has larger glyph height
          height: effectiveHeight,
          color: color,
          fontWeight: fontWeight ?? FontWeight.w500,
        );
      case ArabicScriptType.naskh:
        return GoogleFonts.notoNaskhArabic(
          fontSize: size,
          height: effectiveHeight,
          color: color,
          fontWeight: fontWeight ?? FontWeight.normal,
        );
      case ArabicScriptType.uthmani:
      default:
        return GoogleFonts.scheherazadeNew(
          fontSize: size,
          height: effectiveHeight,
          color: color,
          fontWeight: fontWeight ?? FontWeight.normal,
        );
    }
  }
}
