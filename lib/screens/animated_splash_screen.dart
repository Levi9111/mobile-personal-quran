import 'package:flutter/material.dart';
import 'home_screen.dart';

/// AnimatedSplashScreen displays a cinematic layer-by-layer assembly
/// of the Noor logo matching the user's specification:
/// 1.1 Background is present first
/// 1.2 Clouds appear floating in
/// 1.3 Stars twinkle in and Crescent Moon appears
/// 1.4 Center star bursts into the center of the moon
/// 1.5 Built from extracted noor_logo.png components
class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Staggered interval animations for the 5 distinct stages
  // 1. Background sky
  late Animation<double> _bgOpacity;
  late Animation<double> _bgScale;

  // 2. Clouds
  late Animation<double> _cloudsOpacity;
  late Animation<Offset> _cloudsSlide;

  // 3. Stars & Moon
  late Animation<double> _starsOpacity;
  late Animation<double> _starsScale;
  late Animation<double> _moonOpacity;
  late Animation<double> _moonScale;

  // 4. Center Star at the center of the moon
  late Animation<double> _starOpacity;
  late Animation<double> _starScale;
  late Animation<double> _starRotation;
  late Animation<double> _flareOpacity;

  // 5. Title & Subtitle text
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;

  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    // 1. Background: 0.00 -> 0.22
    _bgOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.00, 0.20, curve: Curves.easeIn),
      ),
    );
    _bgScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.00, 0.25, curve: Curves.easeOutCubic),
      ),
    );

    // 2. Clouds: 0.16 -> 0.44
    _cloudsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.16, 0.42, curve: Curves.easeInOut),
      ),
    );
    _cloudsSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.16, 0.44, curve: Curves.easeOutCubic),
      ),
    );

    // 3. Stars & Stardust: 0.32 -> 0.60
    _starsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.32, 0.58, curve: Curves.easeIn),
      ),
    );
    _starsScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.32, 0.60, curve: Curves.easeOut),
      ),
    );

    // 3b. Crescent Moon: 0.46 -> 0.72
    _moonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.46, 0.70, curve: Curves.easeIn),
      ),
    );
    _moonScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.46, 0.72, curve: Curves.easeOutBack),
      ),
    );

    // 4. Center Star: 0.66 -> 0.88
    _starOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.66, 0.84, curve: Curves.easeIn),
      ),
    );
    _starScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.66, 0.88, curve: Curves.elasticOut),
      ),
    );
    _starRotation = Tween<double>(begin: -0.25, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.66, 0.86, curve: Curves.easeOutCubic),
      ),
    );
    // Radiant light flare around star
    _flareOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.85)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.85, end: 0.15)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.70, 0.92),
      ),
    );

    // 5. Title Text: 0.78 -> 1.00
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.78, 0.98, curve: Curves.easeIn),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.78, 1.00, curve: Curves.easeOutCubic),
      ),
    );

    // Start animation and navigate when finished
    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 350), () {
        _navigateToHome();
      });
    });
  }

  void _navigateToHome() {
    if (!_navigated && mounted) {
      _navigated = true;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 700),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final emblemSize = (size.width * 0.74).clamp(240.0, 320.0);

    return Scaffold(
      backgroundColor: const Color(0xFF040A18),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _navigateToHome,
        child: Stack(
          children: [
            // Full-screen anime celestial background with ambient glow
            Positioned.fill(
              child: Opacity(
                opacity: 0.45,
                child: Image.asset(
                  'assets/images/anime_celestial_bg.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Top ambient nebula gradient overlay
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -0.1),
                    radius: 0.95,
                    colors: [
                      Color(0x284E75FF),
                      Color(0x10132357),
                      Color(0xDF040A18),
                    ],
                  ),
                ),
              ),
            ),

            // Skip button in top right
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, right: 16.0),
                  child: TextButton.icon(
                    onPressed: _navigateToHome,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                      backgroundColor: Colors.white.withOpacity(0.08),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.18),
                          width: 0.8,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 13),
                    label: const Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Center Logo Assembly Stage
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // The Animated Emblem with the 5 sequential layers
                      Container(
                        width: emblemSize,
                        height: emblemSize,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(44),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD54F)
                                  .withOpacity(0.20 * _starOpacity.value),
                              blurRadius: 40,
                              spreadRadius: 4,
                            ),
                            BoxShadow(
                              color: const Color(0xFF1E3A8A)
                                  .withOpacity(0.35 * _bgOpacity.value),
                              blurRadius: 30,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(44),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // ------------------------------------------
                              // 1.1 BACKGROUND SKY (Present from beginning)
                              // ------------------------------------------
                              Opacity(
                                opacity: _bgOpacity.value,
                                child: Transform.scale(
                                  scale: _bgScale.value,
                                  child: Image.asset(
                                    'assets/images/welcome_sky_bg.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                              // ------------------------------------------
                              // 1.2 CLOUDS (Float into scene)
                              // ------------------------------------------
                              SlideTransition(
                                position: _cloudsSlide,
                                child: Opacity(
                                  opacity: _cloudsOpacity.value,
                                  child: Image.asset(
                                    'assets/images/welcome_clouds.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                              // ------------------------------------------
                              // 1.3 STARS & STARDUST (Twinkling)
                              // ------------------------------------------
                              Opacity(
                                opacity: _starsOpacity.value,
                                child: Transform.scale(
                                  scale: _starsScale.value,
                                  child: Image.asset(
                                    'assets/images/welcome_stars.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                              // ------------------------------------------
                              // 1.3b CRESCENT MOON (Glides and scales up)
                              // ------------------------------------------
                              Opacity(
                                opacity: _moonOpacity.value,
                                child: Transform.scale(
                                  scale: _moonScale.value,
                                  child: Image.asset(
                                    'assets/images/welcome_moon.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                              // ------------------------------------------
                              // 1.4 CENTER STAR (At the center of the moon)
                              // ------------------------------------------
                              Opacity(
                                opacity: _starOpacity.value,
                                child: Transform.scale(
                                  scale: _starScale.value,
                                  alignment: const Alignment(0.068, -0.010),
                                  child: Transform.rotate(
                                    angle: _starRotation.value,
                                    alignment: const Alignment(0.068, -0.010),
                                    child: Image.asset(
                                      'assets/images/welcome_center_star.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),

                              // Radiant Starburst Bloom Flash
                              if (_flareOpacity.value > 0.01)
                                Opacity(
                                  opacity: _flareOpacity.value,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      gradient: RadialGradient(
                                        center: Alignment(0.068, -0.010),
                                        radius: 0.35,
                                        colors: [
                                          Color(0xFFFFF9C4),
                                          Color(0x80FFD54F),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ------------------------------------------
                      // 1.5 TITLE & SUBTITLE
                      // ------------------------------------------
                      SlideTransition(
                        position: _titleSlide,
                        child: Opacity(
                          opacity: _titleOpacity.value,
                          child: Column(
                            children: [
                              // Arabic Calligraphy with golden glow
                              Text(
                                'نُور',
                                style: TextStyle(
                                  fontFamily: 'serif',
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFFFE082),
                                  letterSpacing: 4,
                                  shadows: [
                                    Shadow(
                                      color: const Color(0xFFFFD54F)
                                          .withOpacity(0.6),
                                      blurRadius: 18,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),

                              // English Name
                              Text(
                                'N O O R',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withOpacity(0.95),
                                  letterSpacing: 8,
                                  shadows: [
                                    Shadow(
                                      color: Colors.white.withOpacity(0.3),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Subtitle
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981)
                                      .withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF10B981)
                                        .withOpacity(0.35),
                                    width: 0.8,
                                  ),
                                ),
                                child: const Text(
                                  'My Personal Quran',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF6EE7B7),
                                    letterSpacing: 1.5,
                                  ),
                                ),
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
}
