import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:noor_quran/models/chapter.dart';
import 'package:noor_quran/models/verse.dart';
import 'package:noor_quran/providers/bookmark_provider.dart';
import 'package:noor_quran/providers/theme_provider.dart';
import 'package:noor_quran/screens/mushaf_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testChapter = Chapter(
    id: 1,
    nameSimple: 'Al-Fatihah',
    nameArabic: 'الفاتحة',
    versesCount: 7,
    revelationPlace: 'makkah',
    translatedName: 'The Opener',
  );

  final testVerses = [
    Verse(
      id: 1,
      verseNumber: 1,
      verseKey: '1:1',
      textIndopak: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
      translationText: 'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
      audioUrl: 'https://example.com/audio/1.mp3',
    ),
    Verse(
      id: 2,
      verseNumber: 2,
      verseKey: '1:2',
      textIndopak: 'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ',
      translationText: '[All] praise is [due] to Allah, Lord of the worlds -',
      audioUrl: 'https://example.com/audio/2.mp3',
    ),
  ];

  Widget createMushafWidget({BookmarkProvider? bProvider, int? initialVerseNumber}) {
    return MultiProvider(
      key: UniqueKey(),
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => bProvider ?? BookmarkProvider()),
      ],
      child: MaterialApp(
        home: MushafScreen(
          chapter: testChapter,
          initialVerses: testVerses,
          initialVerseNumber: initialVerseNumber,
        ),
      ),
    );
  }

  testWidgets('MushafScreen renders continuous scrollable single-card layout with full audio button',
      (WidgetTester tester) async {
    await tester.pumpWidget(createMushafWidget());

    // Verify screen mounts
    expect(find.byType(MushafScreen), findsOneWidget);

    // Verify AppBar contains title and Play Full Surah button
    expect(find.text('Surah Al-Fatihah'), findsOneWidget);
    expect(find.byIcon(Icons.play_circle_fill_rounded), findsOneWidget);
    expect(find.byIcon(Icons.bookmarks_rounded), findsOneWidget);
    expect(find.byIcon(Icons.visibility_rounded), findsOneWidget);

    // Advance frame to complete FutureBuilder
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify ListView is used for single-page scrolling (no horizontal PageView)
    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(PageView), findsNothing);

    // Verify Surah header and Bismillah banner are rendered
    expect(find.text('سُورَةُ الفاتحة'), findsWidgets);
    expect(find.text('بِسۡمِ اللهِ الرَّحۡمٰنِ الرَّحِيۡمِ'), findsOneWidget);

    // Verify Full Audio recitation button is present
    expect(find.text('Play Full Audio'), findsOneWidget);
    expect(find.text('Mishary Rashid Alafasy'), findsOneWidget);

    // Verify End of Surah seal is rendered
    expect(find.textContaining('خَتْمُ سُورَةِ الفاتحة'), findsOneWidget);
  });

  testWidgets('MushafScreen bookmarking a verse syncs with BookmarkProvider across modes',
      (WidgetTester tester) async {
    final bProvider = BookmarkProvider();
    await tester.pumpWidget(createMushafWidget(bProvider: bProvider, initialVerseNumber: 1));
    await tester.pumpAndSettle();

    // Initially verse 1:1 is not bookmarked
    expect(bProvider.isBookmarked(1, 1), isFalse);

    // Ayah Bookmark Bar should appear
    expect(find.text('Ayah 1:1'), findsOneWidget);
    expect(find.text('Bookmark'), findsOneWidget);

    // Tap Bookmark button
    await tester.tap(find.text('Bookmark'));
    await tester.pumpAndSettle();

    // Verify it is now bookmarked in BookmarkProvider (syncing with non-Mushaf mode)
    expect(bProvider.isBookmarked(1, 1), isTrue);
    expect(find.text('Bookmarked'), findsOneWidget);
  });
}
