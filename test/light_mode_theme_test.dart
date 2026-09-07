import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor_quran/theme/app_theme.dart';
import 'package:noor_quran/models/tajweed.dart';
import 'package:noor_quran/widgets/celestial_background.dart';

void main() {
  group('Noor Celestial Dawn Light Mode Tests', () {
    test('Light theme properties reflect warm sacred parchment palette', () {
      final lightTheme = AppTheme.lightTheme;

      expect(lightTheme.brightness, Brightness.light);
      expect(lightTheme.scaffoldBackgroundColor, const Color(0xFFFAF8F5));
      expect(lightTheme.cardColor, Colors.white);
      expect(lightTheme.colorScheme.surface, Colors.white);
    });

    test('Theme helper methods resolve high contrast colors for light mode', () {
      // Light mode contrasts
      expect(AppTheme.getAccentGold(false), const Color(0xFFB45309));
      expect(AppTheme.getStarlightBlue(false), const Color(0xFF0284C7));
      expect(AppTheme.getBorderColor(false), const Color(0xFFEADBCE));

      // Dark mode contrasts
      expect(AppTheme.getAccentGold(true), AppTheme.celestialStarGold);
      expect(AppTheme.getStarlightBlue(true), AppTheme.celestialStarlightBlue);
      expect(AppTheme.getBorderColor(true), AppTheme.celestialBorderIndigo);
    });

    test('Tajweed rules resolve high contrast colors in light mode', () {
      final ghunnaMeta = ruleMetaMap[TajweedRule.ghunna]!;
      final maddMeta = ruleMetaMap[TajweedRule.madd]!;
      final qalqalahMeta = ruleMetaMap[TajweedRule.qalqalah]!;

      // In light mode:
      expect(ghunnaMeta.resolveColor(false), const Color(0xFFD97706));
      expect(maddMeta.resolveColor(false), const Color(0xFFE11D48));
      expect(qalqalahMeta.resolveColor(false), const Color(0xFF0284C7));

      // In dark mode:
      expect(ghunnaMeta.resolveColor(true), AppTheme.ghunnaColor);
      expect(maddMeta.resolveColor(true), AppTheme.maddColor);
      expect(qalqalahMeta.resolveColor(true), AppTheme.qalqalahColor);
    });

    testWidgets('CelestialBackground renders cleanly in Light Mode without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: CelestialBackground(
              child: Center(
                child: Text('Celestial Dawn Light Mode'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Celestial Dawn Light Mode'), findsOneWidget);
      expect(find.byType(CelestialBackground), findsOneWidget);
    });
  });
}
