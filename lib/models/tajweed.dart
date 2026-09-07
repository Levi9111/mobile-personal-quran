import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum TajweedRule { ghunna, qalqalah, madd, idgham, ikhfa }

class TajweedMeta {
  final String label;
  final String description;
  final Color color;
  final Color? lightColor;

  const TajweedMeta({
    required this.label,
    required this.description,
    required this.color,
    this.lightColor,
  });

  Color resolveColor(bool isDark) => isDark ? color : (lightColor ?? color);
}

const Map<TajweedRule, TajweedMeta> ruleMetaMap = {
  TajweedRule.ghunna: TajweedMeta(
    label: "Ghunna",
    description: "Nasal hum held 2 counts",
    color: AppTheme.ghunnaColor,
    lightColor: Color(0xFFD97706), // Rich deep amber
  ),
  TajweedRule.qalqalah: TajweedMeta(
    label: "Qalqalah",
    description: "Bounced, echoing letter",
    color: AppTheme.qalqalahColor,
    lightColor: Color(0xFF0284C7), // Vibrant royal azure (high contrast)
  ),
  TajweedRule.madd: TajweedMeta(
    label: "Madd",
    description: "Elongated 4–6 counts",
    color: AppTheme.maddColor,
    lightColor: Color(0xFFE11D48), // Deep crimson rose
  ),
  TajweedRule.idgham: TajweedMeta(
    label: "Idgham",
    description: "Merged into the next letter",
    color: AppTheme.idghamColor,
    lightColor: Color(0xFF059669), // Deep celestial emerald
  ),
  TajweedRule.ikhfa: TajweedMeta(
    label: "Ikhfa",
    description: "Hidden, nasalised noon/meem",
    color: AppTheme.ikhfaColor,
    lightColor: Color(0xFF7C3AED), // Deep dusk amethyst
  ),
};

class TajweedSegment {
  final String text;
  final TajweedRule? rule;

  TajweedSegment({required this.text, this.rule});
}

class TajweedParser {
  static const String shadda = "\u0651";
  static const String sukun = "\u0652";
  static const String maddah = "\u0653";
  static final Set<String> tanween = {"\u064B", "\u064C", "\u064D"};
  static final Set<String> sukunLike = {sukun, "\u06E1", "\u06DF", "\u06E0"};

  static final RegExp letterRegExp = RegExp(r'[\u0621-\u064A\u066E-\u06D3]');
  static final RegExp diacriticRegExp = RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED\u0640\u0615-\u061A]');

  static final Set<String> qalqalahSet = {"ق", "ط", "ب", "ج", "د"};
  static final Set<String> idghamSet = {"ي", "ر", "م", "ل", "و", "ن"};
  static final Set<String> ikhfaSet = {
    "ت", "ث", "ج", "د", "ذ", "ز", "س", "ش", "ص", "ض", "ط", "ظ", "ف", "ق", "ك"
  };

  static List<TajweedSegment> parse(String text) {
    final clusters = _clusterize(text);
    final List<TajweedSegment> segments = [];

    for (int i = 0; i < clusters.length; i++) {
      final c = clusters[i];
      final rule = _classify(clusters, i);
      final chunk = text.substring(c.start, c.end);

      if (segments.isNotEmpty && segments.last.rule == rule) {
        segments[segments.length - 1] = TajweedSegment(
          text: segments.last.text + chunk,
          rule: rule,
        );
      } else {
        segments.add(TajweedSegment(text: chunk, rule: rule));
      }
    }

    return segments;
  }

  static List<_Cluster> _clusterize(String text) {
    final List<_Cluster> clusters = [];
    int i = 0;
    while (i < text.length) {
      final start = i;
      final base = text[i];
      i++;
      String marks = "";
      while (i < text.length && diacriticRegExp.hasMatch(text[i])) {
        marks += text[i];
        i++;
      }
      clusters.add(_Cluster(
        start: start,
        end: i,
        base: base,
        marks: marks,
        isLetter: letterRegExp.hasMatch(base),
      ));
    }
    return clusters;
  }

  static _Cluster? _nextLetter(List<_Cluster> clusters, int from) {
    for (int i = from; i < clusters.length; i++) {
      if (clusters[i].isLetter) return clusters[i];
    }
    return null;
  }

  static _Cluster? _nextSoundedLetter(List<_Cluster> clusters, int from) {
    for (int i = from; i < clusters.length; i++) {
      final c = clusters[i];
      if (!c.isLetter) continue;
      if (c.marks.isEmpty && (c.base == "ا" || c.base == "ى")) continue;
      return c;
    }
    return null;
  }

  static bool _hasSukun(String marks) {
    for (var m in marks.codeUnits) {
      if (sukunLike.contains(String.fromCharCode(m))) return true;
    }
    return false;
  }

  static bool _hasTanween(String marks) {
    for (var m in marks.codeUnits) {
      if (tanween.contains(String.fromCharCode(m))) return true;
    }
    return false;
  }

  static TajweedRule? _classify(List<_Cluster> clusters, int index) {
    final c = clusters[index];
    if (!c.isLetter) return null;
    final base = c.base;
    final marks = c.marks;

    if (marks.contains(maddah) || base == "آ") return TajweedRule.madd;
    if (marks.contains(shadda) && (base == "ن" || base == "م")) return TajweedRule.ghunna;

    final nl = _nextLetter(clusters, index + 1);

    final isNoonSakin = base == "ن" && _hasSukun(marks);
    if (isNoonSakin || _hasTanween(marks)) {
      final target = _nextSoundedLetter(clusters, index + 1);
      if (target != null) {
        if (idghamSet.contains(target.base)) return TajweedRule.idgham;
        if (ikhfaSet.contains(target.base)) return TajweedRule.ikhfa;
      }
    }

    if (base == "م" && _hasSukun(marks) && nl != null) {
      if (nl.base == "ب") return TajweedRule.ikhfa;
      if (nl.base == "م") return TajweedRule.idgham;
    }

    if (qalqalahSet.contains(base)) {
      if (_hasSukun(marks)) return TajweedRule.qalqalah;
      if (nl == null && !marks.contains(shadda)) return TajweedRule.qalqalah;
    }

    return null;
  }
}

class _Cluster {
  final int start;
  final int end;
  final String base;
  final String marks;
  final bool isLetter;

  _Cluster({
    required this.start,
    required this.end,
    required this.base,
    required this.marks,
    required this.isLetter,
  });
}
