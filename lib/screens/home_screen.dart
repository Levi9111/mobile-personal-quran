import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/chapter.dart';
import '../providers/theme_provider.dart';
import '../services/quran_service.dart';
import '../theme/app_theme.dart';
import 'important_verses_screen.dart';
import 'surah_screen.dart';
import 'tajweed_guide_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Chapter>> _chaptersFuture;
  List<Chapter> _allChapters = [];
  List<Chapter> _filteredChapters = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadChapters();
    _searchController.addListener(_onSearchChanged);
  }

  void _loadChapters() {
    setState(() {
      _chaptersFuture = QuranService.fetchChapters().then((chapters) {
        if (mounted) {
          setState(() {
            _allChapters = chapters;
            _filteredChapters = chapters;
          });
        }
        return chapters;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredChapters = _allChapters;
      } else {
        _filteredChapters = _allChapters.where((c) {
          final nameMatch = c.nameSimple.toLowerCase().contains(query);
          final transMatch = c.translatedName.toLowerCase().contains(query);
          final idMatch = c.id.toString() == query;
          return nameMatch || transMatch || idMatch;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final theme = Theme.of(context);

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
      body: FutureBuilder<List<Chapter>>(
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
                    Text(
                      'Failed to load Quran surahs',
                      style: theme.textTheme.titleLarge,
                    ),
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

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: isDark
                          ? const LinearGradient(
                              colors: [
                                Color(0xFF131F3A),
                                Color(0xFF0F172A),
                                Color(0xFF080D1A),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            )
                          : const LinearGradient(
                              colors: [
                                Color(0xFFFFFFFF),
                                Color(0xFFF1F6FE),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                      border: Border.all(
                        color: isDark
                            ? AppTheme.celestialBorderIndigo
                            : const Color(0xFFD6E2F0),
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
                        // Luminous Anime Logo Emblem
                        Container(
                          width: 82,
                          height: 82,
                          margin: const EdgeInsets.only(bottom: 12),
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
                                blurRadius: 28,
                                spreadRadius: 3,
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

                        // Sparkle badge & titles
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              size: 13,
                              color: AppTheme.celestialStarGold,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'NOOR QURAN',
                              style: GoogleFonts.karla(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 3.5,
                                color: AppTheme.celestialStarGold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.auto_awesome,
                              size: 13,
                              color: AppTheme.celestialStarGold,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'The Noble Quran',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.darkForeground : const Color(0xFF1E3A8A),
                          ),
                        ),
                        Text(
                          'الْقُرْآنُ الْكَرِيمُ',
                          style: GoogleFonts.scheherazadeNew(
                            fontSize: 22,
                            color: isDark ? AppTheme.celestialStarGold.withOpacity(0.85) : const Color(0xFFB45309),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Indo-Pak script with Tajweed rules, Quranic Duas & verse recitations.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.karla(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface.withOpacity(0.75),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Action Pills
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10,
                          runSpacing: 10,
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
                              icon: const Icon(Icons.stars_rounded, size: 16),
                              label: const Text('Important Verses & Duas'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? AppTheme.celestialStarGold : const Color(0xFF1E3A8A),
                                foregroundColor: isDark ? AppTheme.celestialMidnight : Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
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
                                size: 16,
                                color: AppTheme.celestialStarlightBlue,
                              ),
                              label: const Text('Tajweed guide →'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isDark ? AppTheme.celestialStarlightBlue : const Color(0xFF0284C7),
                                side: BorderSide(
                                  color: isDark ? AppTheme.celestialStarlightBlue.withOpacity(0.6) : const Color(0xFF0284C7),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Sleek Search Field
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
                                    onPressed: () {
                                      _searchController.clear();
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: isDark ? AppTheme.celestialDeepIndigo : Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: isDark ? AppTheme.celestialBorderIndigo : const Color(0xFFCBD5E1),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: isDark ? AppTheme.celestialBorderIndigo : const Color(0xFFCBD5E1),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
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
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                sliver: _filteredChapters.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Center(
                            child: Text(
                              'No surah matches "${_searchController.text}"',
                              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final chapter = _filteredChapters[index];
                            return _SurahCard(chapter: chapter);
                          },
                          childCount: _filteredChapters.length,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
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
                // Diamond number badge with celestial gold accent
                Transform.rotate(
                  angle: 0.785398, // 45 deg
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

                // Surah English Name & Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chapter.nameSimple,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
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

                // Arabic Name with celestial warmth
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
