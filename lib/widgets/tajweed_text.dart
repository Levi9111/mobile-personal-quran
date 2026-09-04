import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/tajweed.dart';

class TajweedTextWidget extends StatelessWidget {
  final String text;
  final bool enabled;
  final double fontSize;
  final TextAlign textAlign;

  const TajweedTextWidget({
    super.key,
    required this.text,
    this.enabled = true,
    this.fontSize = 24.0,
    this.textAlign = TextAlign.right,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultColor = theme.colorScheme.onSurface;
    final arabicStyle = GoogleFonts.scheherazadeNew(
      fontSize: fontSize,
      height: 2.2,
      color: defaultColor,
      fontWeight: FontWeight.normal,
    );

    if (!enabled) {
      return Text(
        text,
        style: arabicStyle,
        textAlign: textAlign,
        textDirection: TextDirection.rtl,
      );
    }

    final segments = TajweedParser.parse(text);
    final spans = segments.map((seg) {
      final color = seg.rule != null ? ruleMetaMap[seg.rule]!.color : defaultColor;
      return TextSpan(
        text: seg.text,
        style: arabicStyle.copyWith(color: color),
      );
    }).toList();

    return RichText(
      textAlign: textAlign,
      textDirection: TextDirection.rtl,
      text: TextSpan(children: spans),
    );
  }
}
