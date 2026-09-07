import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:noor_quran/providers/theme_provider.dart';
import 'package:noor_quran/providers/important_verses_provider.dart';
import 'package:noor_quran/providers/bookmark_provider.dart';
import 'package:noor_quran/screens/animated_splash_screen.dart';
import 'package:noor_quran/screens/home_screen.dart';

void main() {
  Widget createSplashWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ImportantVersesProvider()),
        ChangeNotifierProvider(create: (_) => BookmarkProvider()),
      ],
      child: const MaterialApp(
        home: AnimatedSplashScreen(),
      ),
    );
  }

  testWidgets('AnimatedSplashScreen renders all 5 logo layers and anime background', (WidgetTester tester) async {
    await tester.pumpWidget(createSplashWidget());

    // Initially pumped
    expect(find.byType(AnimatedSplashScreen), findsOneWidget);

    // Verify all 5 layer image assets and anime background are present in the widget tree
    final imageFinders = find.byType(Image);
    expect(imageFinders, findsWidgets);

    final images = tester.widgetList<Image>(imageFinders).map((img) {
      if (img.image is AssetImage) {
        return (img.image as AssetImage).assetName;
      }
      return '';
    }).toList();

    expect(images.contains('assets/images/anime_celestial_bg.jpg'), isTrue);
    expect(images.contains('assets/images/logo_background.png'), isTrue);
    expect(images.contains('assets/images/logo_clouds.png'), isTrue);
    expect(images.contains('assets/images/logo_stars.png'), isTrue);
    expect(images.contains('assets/images/logo_moon.png'), isTrue);
    expect(images.contains('assets/images/logo_center_star.png'), isTrue);

    // Verify Title and Subtitle are present
    expect(find.text('نُور'), findsOneWidget);
    expect(find.text('N O O R'), findsOneWidget);
    expect(find.text('My Personal Quran'), findsOneWidget);

    // Verify Skip button is present
    expect(find.text('Skip'), findsOneWidget);

    // Pump some frames to advance animation
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 1500));
  });

  testWidgets('Tapping Skip navigates immediately to HomeScreen', (WidgetTester tester) async {
    await tester.pumpWidget(createSplashWidget());

    final skipButton = find.text('Skip');
    expect(skipButton, findsOneWidget);

    await tester.tap(skipButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800)); // allow transition animation

    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
