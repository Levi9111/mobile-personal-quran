import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/chapter.dart';
import '../providers/theme_provider.dart';
import '../services/quran_service.dart';
import '../theme/app_theme.dart';
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
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryEmerald.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.metallicGold.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                size: 18,
                color: AppTheme.primaryEmerald,
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    children: [
                      Text(
                        'NOOR QURAN',
                        style: GoogleFonts.karla(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 3,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'The Noble Quran',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Indo-Pak script with Saheeh International English translation and verse recitation.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.karla(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TajweedGuideScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.auto_awesome_rounded, size: 16, color: AppTheme.metallicGold),
                        label: const Text('Colour-coded tajweed guide →'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          side: BorderSide(
                            color: AppTheme.metallicGold.withOpacity(0.5),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search surah by name or number…',
                          prefixIcon: const Icon(Icons.search_rounded, size: 18),
                          filled: true,
                          fillColor: theme.cardTheme.color,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: theme.colorScheme.outline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: theme.colorScheme.outline),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
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
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outline, width: 1),
            ),
            child: Row(
              children: [
                // Diamond number badge
                Transform.rotate(
                  angle: 0.785398, // 45 deg
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppTheme.metallicGold.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.metallicGold.withOpacity(0.5),
                        width: 1,
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
                            color: theme.colorScheme.primary,
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
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${chapter.translatedName} · ${chapter.versesCount} ayahs',
                        style: GoogleFonts.karla(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),

                // Arabic Name
                Text(
                  chapter.nameArabic,
                  style: GoogleFonts.scheherazadeNew(
                    fontSize: 24,
                    color: theme.colorScheme.primary.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
