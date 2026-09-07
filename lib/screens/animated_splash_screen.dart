import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

/// AnimatedSplashScreen displays a clean, elegant, and harmonious welcoming animation:
/// - Soft celestial anime midnight background with radial glow
/// - Smooth fade and scale-in of the iconic Noor logo
/// - Gentle starlight aura pulse and subtle shimmer
/// - Golden Arabic calligraphy 'نُور' with spaced 'N O O R'
/// - Fast and non-intrusive: 2.2s total duration with instant tap-to-skip
class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;

  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // Smooth logo fade-in: 0.0 -> 0.5
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
      ),
    );

    // Subtle scale-up from 0.88 to 1.0
    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );

    // Soft celestial starlight glow pulse
    _glowAnimation = Tween<double>(begin: 0.2, end: 0.8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.85, curve: Curves.easeInOut),
      ),
    );

    // Typography fade and subtle slide up
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.40, 0.80, curve: Curves.easeIn),
      ),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.40, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToHome();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    if (_navigated || !mounted) return;
    _navigated = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.celestialMidnight,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _navigateToHome,
        child: Stack(
          children: [
            // 1. Full-screen celestial anime background with dark overlay
            Positioned.fill(
              child: Opacity(
                opacity: 0.45,
                child: Image.asset(
                  'assets/images/anime_celestial_bg.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // 2. Radial midnight vignette gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.1,
                    colors: [
                      Colors.transparent,
                      AppTheme.celestialMidnight.withOpacity(0.55),
                      AppTheme.celestialMidnight.withOpacity(0.92),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),

            // 3. Skip Button (Top-Right)
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, right: 16.0),
                  child: TextButton.icon(
                    onPressed: _navigateToHome,
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: AppTheme.celestialStarGold,
                    ),
                    label: Text(
                      'Skip',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.celestialStarGold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: AppTheme.celestialDeepIndigo.withOpacity(0.65),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: AppTheme.celestialStarGold.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 4. Centered Logo and Calligraphy
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Glowing Aura & Logo
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Celestial glowing ambient pulse
                          Opacity(
                            opacity: _glowAnimation.value,
                            child: Container(
                              width: 210,
                              height: 210,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    AppTheme.celestialStarGold.withOpacity(0.35),
                                    AppTheme.celestialStarlightBlue.withOpacity(0.18),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.55, 1.0],
                                ),
                              ),
                            ),
                          ),

                          // Noor Anime Logo
                          Opacity(
                            opacity: _fadeAnimation.value,
                            child: Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Container(
                                width: 154,
                                height: 154,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.celestialStarGold.withOpacity(0.28),
                                      blurRadius: 28,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/noor_logo.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Typography: Arabic Calligraphy & Subtitles
                      Opacity(
                        opacity: _textFadeAnimation.value,
                        child: SlideTransition(
                          position: _textSlideAnimation,
                          child: Column(
                            children: [
                              // Arabic Calligraphy
                              Text(
                                'نُور',
                                style: GoogleFonts.amiri(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.celestialStarGold,
                                  letterSpacing: 2,
                                  shadows: [
                                    Shadow(
                                      color: AppTheme.celestialStarGold.withOpacity(0.6),
                                      blurRadius: 16,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 4),

                              // Spaced Latin Subtitle
                              Text(
                                'N O O R',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 6,
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Tagline
                              Text(
                                'My Personal Quran',
                                style: GoogleFonts.karla(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 1.2,
                                  color: AppTheme.celestialStarlightBlue.withOpacity(0.9),
                                ),
                              ),

                              const SizedBox(height: 18),

                              // Delicate spiritual dots
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildDot(AppTheme.celestialStarGold, 4),
                                  const SizedBox(width: 8),
                                  _buildDot(AppTheme.celestialStarlightBlue, 6),
                                  const SizedBox(width: 8),
                                  _buildDot(AppTheme.celestialStarGold, 4),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.6),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }
}
