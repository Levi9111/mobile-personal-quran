import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor_quran/widgets/celestial_notification_banner.dart';

void main() {
  testWidgets('CelestialNotificationBanner renders generous mobile notification card',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    CelestialNotificationBanner.show(
                      context: context,
                      title: 'Continue Reading • نُورُ الْقُرْآن',
                      message: '8 hours have passed since your last recitation.',
                      verseReference: 'Surah Al-Baqarah 2:255 • ٢:٢٥٥',
                      actionLabel: 'Resume',
                      onAction: () {},
                      type: NotificationType.reminder8Hour,
                    );
                  },
                  child: const Text('Show Notification'),
                ),
              );
            },
          ),
        ),
      ),
    );

    // Tap button to trigger notification
    await tester.tap(find.text('Show Notification'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Verify notification contents
    expect(find.text('NOOR QURAN'), findsOneWidget);
    expect(find.text('Continue Reading • نُورُ الْقُرْآن'), findsOneWidget);
    expect(find.text('8 hours have passed since your last recitation.'), findsOneWidget);
    expect(find.text('Surah Al-Baqarah 2:255 • ٢:٢٥٥'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
    expect(find.text('Dismiss'), findsOneWidget);

    // Dismiss banner cleanly
    CelestialNotificationBanner.dismiss();
    await tester.pumpAndSettle();
  });
}
