import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor_quran/widgets/tajweed_text.dart';
import 'package:noor_quran/widgets/tajweed_legend.dart';

void main() {
  testWidgets('Tajweed text widget renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TajweedTextWidget(
            text: 'بِسۡمِ اللهِ الرَّحۡمٰنِ الرَّحِيۡمِ',
          ),
        ),
      ),
    );
    expect(find.byType(TajweedTextWidget), findsOneWidget);
  });

  testWidgets('Tajweed legend widget renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TajweedLegendWidget(),
        ),
      ),
    );
    expect(find.byType(TajweedLegendWidget), findsOneWidget);
  });
}
