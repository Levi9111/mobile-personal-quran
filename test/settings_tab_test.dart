import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:noor_quran/providers/bookmark_provider.dart';
import 'package:noor_quran/providers/theme_provider.dart';
import 'package:noor_quran/screens/settings_tab.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createSettingsTabWidget({ThemeProvider? tProvider, BookmarkProvider? bProvider}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => tProvider ?? ThemeProvider()),
        ChangeNotifierProvider(create: (_) => bProvider ?? BookmarkProvider()),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: SettingsTab(),
        ),
      ),
    );
  }

  testWidgets('SettingsTab renders theme toggle, notification reminders, backup, and learning guides',
      (WidgetTester tester) async {
    final themeProvider = ThemeProvider();
    await tester.pumpWidget(createSettingsTabWidget(tProvider: themeProvider));
    await tester.pumpAndSettle();

    // Verify Title
    expect(find.text('Settings & Preferences'), findsOneWidget);

    // Verify Section Headers
    expect(find.text('APPEARANCE & THEME'), findsOneWidget);
    expect(find.text('READING REMINDERS & NOTIFICATIONS'), findsOneWidget);
    expect(find.text('DATA BACKUP & RESTORE'), findsOneWidget);
    expect(find.text('LEARNING & GUIDES'), findsOneWidget);

    // Verify Theme Switcher works
    expect(find.text('Dark Mode'), findsOneWidget);
    expect(themeProvider.isDarkMode, isTrue);

    // Verify Notification Controls
    expect(find.text('Periodic Reminders'), findsOneWidget);
    expect(find.text('Quiet Hours: 22:00 – 05:00 (Sleep hours preserved)'), findsOneWidget);
    expect(find.text('Send Test Reminder Notification'), findsOneWidget);

    // Verify Backup & Restore
    expect(find.text('Backup & Restore Quran Data'), findsOneWidget);

    // Verify Learning Guides (Tajweed Guide moved from homepage to here)
    expect(find.text('Tajweed Colour Guide'), findsOneWidget);
    expect(find.text('Important Verses & Duas'), findsOneWidget);
    expect(find.text('Ramadan Countdown'), findsOneWidget);
  });
}
