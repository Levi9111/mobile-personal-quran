import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/bookmark.dart';
import '../models/chapter.dart';
import '../providers/bookmark_provider.dart';
import '../providers/theme_provider.dart';
import '../services/notification_service.dart';
import '../services/quran_service.dart';
import '../theme/app_theme.dart';
import '../utils/arabic_numerals.dart';
import '../widgets/bookmark_sheet.dart';
import '../widgets/juz_browser_widget.dart';
import '../widgets/ramadan_countdown_card.dart';
import 'important_verses_screen.dart';
import 'mushaf_screen.dart';
import 'surah_screen.dart';
import 'tajweed_guide_screen.dart';
import '../widgets/data_backup_sheet.dart';

enum SurahFilter { all, popular, makki, madani, juzAmma }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late Future<List<Chapter>> _chaptersFuture;
  List<Chapter> _allChapters = [];
  List<Chapter> _filteredChapters = [];
  final TextEditingController _searchController = TextEditingController();

  late TabController _tabController;
  SurahFilter _activeFilter = SurahFilter.all;
  bool _isGridView = false;

  static const List<int> _popularSurahIds = [1, 2, 18, 36, 55, 56, 67, 112, 113, 114];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadChapters();
    _searchController.addListener(_applyFilters);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookmarkProvider = Provider.of<BookmarkProvider>(context, listen: false);
      final notifService = NotificationService();
      notifService.init().then((_) {
        // Delay slightly so HomeScreen is fully painted before evaluating pop alerts
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) {
            notifService.evaluateReminders(context, bookmarkProvider);
          }
        });
        notifService.startPeriodicChecks(context, bookmarkProvider);
      });
    });
  }

  void _loadChapters() {
    setState(() {
      _chaptersFuture = QuranService.fetchChapters().then((chapters) {
        if (mounted) {
          setState(() {
            _allChapters = chapters;
            _applyFilters();
          });
        }
        return chapters;
      });
    });
  }

  @override
  void dispose() {
    NotificationService().stopPeriodicChecks();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      List<Chapter> list = _allChapters;

      switch (_activeFilter) {
        case SurahFilter.popular:
          list = list.where((c) => _popularSurahIds.contains(c.id)).toList();
          break;
        case SurahFilter.makki:
          list = list.where((c) => c.revelationPlace.toLowerCase().contains('mak')).toList();
          break;
        case SurahFilter.madani:
          list = list.where((c) => c.revelationPlace.toLowerCase().contains('mad')).toList();
          break;
        case SurahFilter.juzAmma:
          list = list.where((c) => c.id >= 78).toList();
          break;
        case SurahFilter.all:
        default:
          break;
      }

      if (query.isNotEmpty) {
        list = list.where((c) {
          final nameMatch = c.nameSimple.toLowerCase().contains(query);
          final transMatch = c.translatedName.toLowerCase().contains(query);
          final idMatch = c.id.toString() == query;
          return nameMatch || transMatch || idMatch;
        }).toList();
      }

      _filteredChapters = list;
    });
  }

  void _showNotificationSettingsModal() {
    final notifService = NotificationService();
    final bookmarkProvider = Provider.of<BookmarkProvider>(context, listen: false);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => SafeArea(
          bottom: true,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              22,
              20,
              22,
              MediaQuery.of(ctx).padding.bottom + 20,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(
                color: isDark ? AppTheme.celestialStarGold.withOpacity(0.4) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.notifications_active_rounded, color: AppTheme.celestialStarGold),
                    const SizedBox(width: 10),
                    Text(
                      'Reading Reminders & Alerts',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Receive recitation reminders every 8 hours, and a daily pop notification if no verse was read today.',
                  style: GoogleFonts.karla(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 12),

                // Quiet hours badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1B4B).withOpacity(0.7) : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.celestialStarGold.withOpacity(0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.nightlight_round, size: 16, color: AppTheme.celestialStarGold),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Quiet Hours: 10:00 PM – 5:00 AM (reminders muted automatically)',
                          style: GoogleFonts.karla(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('8-Hour Reminder to Continue'),
                  subtitle: const Text('Displays the exact last verse read (e.g. 2:255 • ٢:٢٥٥)'),
                  value: notifService.reminder8HourEnabled,
                  activeColor: AppTheme.celestialStarGold,
                  onChanged: (val) async {
                    await notifService.set8HourReminderEnabled(val);
                    setModalState(() {});
                  },
                ),
                const SizedBox(height: 14),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Future.delayed(const Duration(milliseconds: 280), () {
                          if (context.mounted) {
                            notifService.triggerTestNotification(context, bookmarkProvider, isDaily: false);
                          }
                        });
                      },
                      icon: const Icon(Icons.notifications_none_rounded, size: 16),
                      label: const Text('Test 8-Hour Alert'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A),
                        foregroundColor: isDark ? AppTheme.celestialMidnight : Colors.white,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Future.delayed(const Duration(milliseconds: 280), () {
                          if (context.mounted) {
                            notifService.triggerTestNotification(context, bookmarkProvider, isDaily: true);
                          }
                        });
                      },
                      icon: const Icon(Icons.wb_twilight_rounded, size: 16),
                      label: const Text('Test Daily Alert'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final theme = Theme.of(context);
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/noor_logo.png',
                width: 28,
                height: 28,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Noor',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.darkForeground : AppTheme.lightForeground,
                  ),
                ),
                Text(
                  'INDO-PAK QURAN',
                  style: GoogleFonts.karla(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppTheme.celestialStarGold),
            tooltip: 'Reading Reminders',
            onPressed: _showNotificationSettingsModal,
          ),
          IconButton(
            icon: const Icon(Icons.stars_rounded, color: AppTheme.metallicGold),
            tooltip: 'Important Verses & Duas',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ImportantVersesScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.cloud_sync_rounded, color: AppTheme.celestialStarGold),
            tooltip: 'Backup & Restore Data',
            onPressed: () => DataBackupSheet.show(context),
          ),
          IconButton(
            icon: Icon(
              isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
              color: isDark ? AppTheme.metallicGold : AppTheme.primaryTealLight,
            ),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Toggle Dark Mode',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Full-screen persistent anime celestial background
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.32 : 0.16,
              child: Image.asset(
                'assets/images/anime_celestial_bg.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Main Scroll Content
          FutureBuilder<List<Chapter>>(
            future: _chaptersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryEmerald,
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                        const SizedBox(height: 12),
                        Text('Failed to load Quran surahs', style: theme.textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text(
                          '${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadChapters,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return NestedScrollView(
                physics: const BouncingScrollPhysics(),
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  // COMBINED HERO MASTER CARD: Header + Continue Reading (Unified into One)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                      child: _buildUnifiedHeroMasterCard(context, isDark, theme, bookmarkProvider),
                    ),
                  ),

                  // Ramadan Countdown Banner
                  const SliverToBoxAdapter(
                    child: RamadanCountdownCard(),
                  ),

                  // Clean, un-cramped TabBar Header: Surahs | 30 Juz | Bookmarks
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF131F3A) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? AppTheme.celestialBorderIndigo : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          indicator: BoxDecoration(
                            color: isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? AppTheme.celestialStarGold.withOpacity(0.25)
                                    : const Color(0xFF1E3A8A).withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          labelColor: isDark ? AppTheme.celestialMidnight : Colors.white,
                          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
                          labelStyle: GoogleFonts.karla(fontWeight: FontWeight.bold, fontSize: 13),
                          tabs: const [
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.menu_book_rounded, size: 15),
                                  SizedBox(width: 6),
                                  Text('Surahs'),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.auto_stories_rounded, size: 15),
                                  SizedBox(width: 6),
                                  Text('30 Juz'),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.bookmark_rounded, size: 15),
                                  SizedBox(width: 6),
                                  Text('Bookmarks'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    // TAB 1: 114 Surahs
                    Column(
                      children: [
                        // Category Chips Bar & Grid Toggle
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  child: Row(
                                    children: [
                                      _buildFilterChip('All (114)', SurahFilter.all),
                                      const SizedBox(width: 6),
                                      _buildFilterChip('Popular ⭐', SurahFilter.popular),
                                      const SizedBox(width: 6),
                                      _buildFilterChip('Makki (86)', SurahFilter.makki),
                                      const SizedBox(width: 6),
                                      _buildFilterChip('Madani (28)', SurahFilter.madani),
                                      const SizedBox(width: 6),
                                      _buildFilterChip('Juz \'Amma (78-114)', SurahFilter.juzAmma),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: Icon(
                                  _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                                  size: 20,
                                  color: isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A),
                                ),
                                tooltip: _isGridView ? 'Switch to list view' : 'Switch to grid view',
                                onPressed: () {
                                  setState(() {
                                    _isGridView = !_isGridView;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),

                        // Surahs List or Grid
                        Expanded(
                          child: _filteredChapters.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Text(
                                      'No surah matches "${_searchController.text}"',
                                      style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                                    ),
                                  ),
                                )
                              : _isGridView
                                  ? GridView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      padding: EdgeInsets.fromLTRB(
                                        16,
                                        8,
                                        16,
                                        MediaQuery.of(context).padding.bottom + 28,
                                      ),
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 1.25,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                      ),
                                      itemCount: _filteredChapters.length,
                                      itemBuilder: (context, index) {
                                        final chapter = _filteredChapters[index];
                                        return _SurahGridCard(chapter: chapter);
                                      },
                                    )
                                  : ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      padding: EdgeInsets.fromLTRB(
                                        16,
                                        4,
                                        16,
                                        MediaQuery.of(context).padding.bottom + 28,
                                      ),
                                      itemCount: _filteredChapters.length,
                                      itemBuilder: (context, index) {
                                        final chapter = _filteredChapters[index];
                                        return _SurahCard(chapter: chapter);
                                      },
                                    ),
                        ),
                      ],
                    ),

                    // TAB 2: 30 Juz Browser
                    JuzBrowserWidget(chapters: _allChapters),

                    // TAB 3: Saved Bookmarks Tab
                    Consumer<BookmarkProvider>(
                      builder: (context, bProvider, _) {
                        final bookmarks = bProvider.bookmarks;
                        if (bookmarks.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.bookmark_border_rounded,
                                    size: 56,
                                    color: isDark ? AppTheme.celestialStarGold.withOpacity(0.4) : Colors.black26,
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'No Bookmarks Yet',
                                    style: GoogleFonts.cormorantGaramond(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Tap the bookmark ribbon on any verse to keep track of your daily spot.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.karla(
                                      fontSize: 13,
                                      color: theme.colorScheme.onSurface.withOpacity(0.65),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            16,
                            8,
                            16,
                            MediaQuery.of(context).padding.bottom + 28,
                          ),
                          itemCount: bookmarks.length,
                          itemBuilder: (context, index) {
                            final b = bookmarks[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: Material(
                                color: theme.cardTheme.color,
                                borderRadius: BorderRadius.circular(18),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(18),
                                  onTap: () async {
                                    final target = _allChapters.firstWhere(
                                      (c) => c.id == b.surahId,
                                      orElse: () => _allChapters.first,
                                    );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => SurahScreen(
                                          chapter: target,
                                          initialVerseNumber: b.verseNumber,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: isDark ? AppTheme.celestialBorderIndigo : AppTheme.lightBorder,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? AppTheme.celestialStarGold.withOpacity(0.12)
                                                : const Color(0xFF1E3A8A).withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            b.dualVerseReference,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                b.surahNameSimple,
                                                style: GoogleFonts.cormorantGaramond(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (b.translationText.isNotEmpty)
                                                Text(
                                                  b.translationText,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: GoogleFonts.karla(
                                                    fontSize: 11,
                                                    color: theme.colorScheme.onSurface.withOpacity(0.65),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          b.surahNameArabic,
                                          style: GoogleFonts.scheherazadeNew(
                                            fontSize: 20,
                                            color: isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                          color: Colors.redAccent.withOpacity(0.7),
                                          onPressed: () => bProvider.removeBookmark(b.id),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// COMBINED MASTER CARD: Merges Hero Header + Continue Reading into ONE sleek, cohesive card
  Widget _buildUnifiedHeroMasterCard(
    BuildContext context,
    bool isDark,
    ThemeData theme,
    BookmarkProvider bookmarkProvider,
  ) {
    final lastRead = bookmarkProvider.lastReadBookmark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: isDark
            ? LinearGradient(
                colors: [
                  const Color(0xFF131F3A).withOpacity(0.95),
                  const Color(0xFF0F172A).withOpacity(0.95),
                  const Color(0xFF080D1A).withOpacity(0.97),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.96),
                  const Color(0xFFF1F6FE).withOpacity(0.96),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
        border: Border.all(
          color: isDark ? AppTheme.celestialBorderIndigo : const Color(0xFFD6E2F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color(0xFF020617).withOpacity(0.5)
                : const Color(0xFF94A3B8).withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // TOP HERO SECTION
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: Column(
              children: [
                // Anime Logo Emblem
                Container(
                  width: 72,
                  height: 72,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        AppTheme.celestialStarGold,
                        AppTheme.celestialStarlightBlue,
                        AppTheme.celestialWarmAmber,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.celestialStarGold.withOpacity(0.4),
                        blurRadius: 22,
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.celestialMidnight,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/noor_logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, size: 11, color: AppTheme.celestialStarGold),
                    const SizedBox(width: 5),
                    Text(
                      'NOOR QURAN',
                      style: GoogleFonts.karla(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.5,
                        color: AppTheme.celestialStarGold,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(Icons.auto_awesome, size: 11, color: AppTheme.celestialStarGold),
                  ],
                ),
                Text(
                  'The Noble Quran',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.darkForeground : const Color(0xFF1E3A8A),
                  ),
                ),
                Text(
                  'الْقُرْآنُ الْكَرِيمُ',
                  style: GoogleFonts.scheherazadeNew(
                    fontSize: 18,
                    color: isDark ? AppTheme.celestialStarGold.withOpacity(0.85) : const Color(0xFFB45309),
                  ),
                ),
                const SizedBox(height: 10),

                // Quick Navigation Pills
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ImportantVersesScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.stars_rounded, size: 14),
                      label: const Text('Important Verses'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A),
                        foregroundColor: isDark ? AppTheme.celestialMidnight : Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TajweedGuideScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.auto_awesome_rounded,
                        size: 14,
                        color: AppTheme.celestialStarlightBlue,
                      ),
                      label: const Text('Tajweed guide'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? AppTheme.celestialStarlightBlue : const Color(0xFF0284C7),
                        side: BorderSide(
                          color: isDark ? AppTheme.celestialStarlightBlue.withOpacity(0.6) : const Color(0xFF0284C7),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        final lastRead = context.read<BookmarkProvider>().lastReadBookmark;
                        final targetChapter = _allChapters.isNotEmpty
                            ? _allChapters.firstWhere(
                                (c) => lastRead != null && c.id == lastRead.surahId,
                                orElse: () => _allChapters.first,
                              )
                            : Chapter(
                                id: 1,
                                nameSimple: 'Al-Fatihah',
                                nameArabic: 'الفاتحة',
                                versesCount: 7,
                                revelationPlace: 'makkah',
                                translatedName: 'The Opener',
                              );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MushafScreen(
                              chapter: targetChapter,
                              initialVerseNumber: lastRead?.verseNumber,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.menu_book_rounded,
                        size: 14,
                        color: AppTheme.celestialStarGold,
                      ),
                      label: const Text('Mushaf Mode'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? AppTheme.celestialStarGold : const Color(0xFFB45309),
                        side: BorderSide(
                          color: isDark ? AppTheme.celestialStarGold.withOpacity(0.6) : const Color(0xFFB45309),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => DataBackupSheet.show(context),
                      icon: const Icon(
                        Icons.cloud_sync_rounded,
                        size: 14,
                        color: Color(0xFF10B981),
                      ),
                      label: const Text('Backup & Restore'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
                        side: BorderSide(
                          color: isDark ? const Color(0xFF34D399).withOpacity(0.6) : const Color(0xFF059669),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Sleek Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search surah by name or number…',
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: 18,
                      color: isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    filled: true,
                    fillColor: isDark ? AppTheme.celestialDeepIndigo : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDark ? AppTheme.celestialBorderIndigo : const Color(0xFFCBD5E1),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDark ? AppTheme.celestialBorderIndigo : const Color(0xFFCBD5E1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // INTEGRATED "CONTINUE READING" PORTAL
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0A1020).withOpacity(0.7)
                  : const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(25)),
              border: Border(
                top: BorderSide(
                  color: isDark ? AppTheme.celestialBorderIndigo : const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.celestialStarGold.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.bookmark_rounded,
                        size: 14,
                        color: AppTheme.celestialStarGold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'CONTINUE READING',
                      style: GoogleFonts.karla(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.8,
                        color: isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A),
                      ),
                    ),
                    const Spacer(),
                    if (lastRead != null)
                      TextButton.icon(
                        onPressed: () => BookmarkSheet.show(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(Icons.bookmarks_rounded, size: 14),
                        label: Text(
                          'All (${bookmarkProvider.bookmarks.length})',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                if (lastRead != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lastRead.surahNameSimple,
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              'Ayah ${lastRead.verseNumber} (${lastRead.dualVerseReference})',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        lastRead.surahNameArabic,
                        style: GoogleFonts.scheherazadeNew(
                          fontSize: 22,
                          color: isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A),
                        ),
                      ),
                    ],
                  ),
                  if (lastRead.arabicText.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF131F3A).withOpacity(0.5)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? AppTheme.celestialBorderIndigo : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Text(
                        lastRead.arabicText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.scheherazadeNew(
                          fontSize: 17,
                          color: isDark ? Colors.white.withOpacity(0.9) : const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () => _resumeReading(context, lastRead),
                    icon: const Icon(Icons.play_arrow_rounded, size: 16),
                    label: const Text('Resume Reading'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A),
                      foregroundColor: isDark ? AppTheme.celestialMidnight : Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start Reading Quran',
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Bookmark verses while reading to resume seamlessly.',
                              style: GoogleFonts.karla(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface.withOpacity(0.65),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _resumeReading(context, null),
                        icon: const Icon(Icons.menu_book_rounded, size: 14),
                        label: const Text('Read Now'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A),
                          foregroundColor: isDark ? AppTheme.celestialMidnight : Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _resumeReading(BuildContext context, Bookmark? bookmark) async {
    final surahId = bookmark?.surahId ?? 1;
    try {
      final chapters = await QuranService.fetchChapters();
      final target = chapters.firstWhere(
        (c) => c.id == surahId,
        orElse: () => chapters.first,
      );
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SurahScreen(
              chapter: target,
              initialVerseNumber: bookmark?.verseNumber,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error resuming reading: $e');
    }
  }

  Widget _buildFilterChip(String label, SurahFilter filter) {
    final isSelected = _activeFilter == filter;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _activeFilter = filter;
          _applyFilters();
        });
      },
      backgroundColor: isDark ? const Color(0xFF131F3A) : const Color(0xFFF1F5F9),
      selectedColor: isDark
          ? AppTheme.celestialStarGold.withOpacity(0.2)
          : const Color(0xFF1E3A8A).withOpacity(0.12),
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected
            ? (isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A))
            : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
      ),
      side: BorderSide(
        color: isSelected
            ? (isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A))
            : (isDark ? AppTheme.celestialBorderIndigo : const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    );
  }
}

class _SurahCard extends StatelessWidget {
  final Chapter chapter;

  const _SurahCard({required this.chapter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SurahScreen(chapter: chapter),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? AppTheme.celestialBorderIndigo : AppTheme.lightBorder,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Transform.rotate(
                  angle: 0.785398,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.celestialStarGold.withOpacity(0.12)
                          : const Color(0xFF1E3A8A).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? AppTheme.celestialStarGold.withOpacity(0.7)
                            : const Color(0xFF1E3A8A).withOpacity(0.4),
                        width: 1.2,
                      ),
                    ),
                    child: Transform.rotate(
                      angle: -0.785398,
                      child: Center(
                        child: Text(
                          '${chapter.id}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            chapter.nameSimple,
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(${ArabicNumeralHelper.toArabic(chapter.id)})',
                            style: GoogleFonts.scheherazadeNew(
                              fontSize: 14,
                              color: AppTheme.celestialStarGold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${chapter.translatedName} · ${chapter.versesCount} ayahs',
                        style: GoogleFonts.karla(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.65),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  chapter.nameArabic,
                  style: GoogleFonts.scheherazadeNew(
                    fontSize: 25,
                    color: isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SurahGridCard extends StatelessWidget {
  final Chapter chapter;

  const _SurahGridCard({required this.chapter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: theme.cardTheme.color,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SurahScreen(chapter: chapter),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? AppTheme.celestialBorderIndigo : AppTheme.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.celestialStarGold.withOpacity(0.12)
                          : const Color(0xFF1E3A8A).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${chapter.id} · ${ArabicNumeralHelper.toArabic(chapter.id)}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A),
                      ),
                    ),
                  ),
                  Text(
                    chapter.nameArabic,
                    style: GoogleFonts.scheherazadeNew(
                      fontSize: 20,
                      color: isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chapter.nameSimple,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '${chapter.versesCount} ayahs',
                    style: GoogleFonts.karla(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
