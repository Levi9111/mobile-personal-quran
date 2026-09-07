import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

enum NotificationType {
  reminder8Hour,
  dailyMissed,
  bookmarkSaved,
  spiritualTip,
}

class CelestialNotificationBanner {
  static OverlayEntry? _currentEntry;

  /// Shows a generous, beautifully styled mobile notification card
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    String? verseReference,
    String? actionLabel,
    VoidCallback? onAction,
    NotificationType type = NotificationType.reminder8Hour,
    Duration duration = const Duration(seconds: 8),
  }) {
    // Dismiss any existing notification card first
    dismiss();

    // Use rootOverlay: true so it displays on top of all modal bottom sheets & routes
    OverlayState? overlay;
    try {
      overlay = Overlay.of(context, rootOverlay: true);
    } catch (_) {
      overlay = Overlay.maybeOf(context);
    }

    if (overlay == null) {
      debugPrint('Warning: No Overlay found to display CelestialNotificationBanner');
      return;
    }

    final entry = OverlayEntry(
      builder: (ctx) => _GenerousMobileNotificationCard(
        key: ValueKey('celestial_notif_${DateTime.now().microsecondsSinceEpoch}'),
        title: title,
        message: message,
        verseReference: verseReference,
        actionLabel: actionLabel,
        onAction: () {
          dismiss();
          onAction?.call();
        },
        type: type,
        onDismiss: dismiss,
        duration: duration,
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }

  static void dismiss() {
    if (_currentEntry != null) {
      try {
        _currentEntry?.remove();
      } catch (e) {
        debugPrint('Error dismissing notification overlay: $e');
      }
      _currentEntry = null;
    }
  }
}

class _GenerousMobileNotificationCard extends StatefulWidget {
  final String title;
  final String message;
  final String? verseReference;
  final String? actionLabel;
  final VoidCallback? onAction;
  final NotificationType type;
  final VoidCallback onDismiss;
  final Duration duration;

  const _GenerousMobileNotificationCard({
    super.key,
    required this.title,
    required this.message,
    this.verseReference,
    this.actionLabel,
    this.onAction,
    required this.type,
    required this.onDismiss,
    required this.duration,
  });

  @override
  State<_GenerousMobileNotificationCard> createState() =>
      _GenerousMobileNotificationCardState();
}

class _GenerousMobileNotificationCardState
    extends State<_GenerousMobileNotificationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    // Auto dismiss after duration
    _dismissTimer = Timer(widget.duration, () {
      if (mounted) {
        _dismissWithAnimation();
      }
    });
  }

  void _dismissWithAnimation() {
    _dismissTimer?.cancel();
    if (!mounted) return;
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  IconData _getIcon() {
    switch (widget.type) {
      case NotificationType.dailyMissed:
        return Icons.wb_twilight_rounded;
      case NotificationType.bookmarkSaved:
        return Icons.bookmark_added_rounded;
      case NotificationType.spiritualTip:
        return Icons.auto_awesome_rounded;
      case NotificationType.reminder8Hour:
      default:
        return Icons.nightlight_round;
    }
  }

  String _getTypeLabel() {
    switch (widget.type) {
      case NotificationType.dailyMissed:
        return 'Daily Reflection';
      case NotificationType.bookmarkSaved:
        return 'Bookmark Saved';
      case NotificationType.spiritualTip:
        return 'Spiritual Insight';
      case NotificationType.reminder8Hour:
      default:
        return 'Reading Reminder';
    }
  }

  List<Color> _getGradientColors() {
    switch (widget.type) {
      case NotificationType.dailyMissed:
        return const [
          Color(0xF51E1B4B),
          Color(0xF52A123D),
        ];
      case NotificationType.bookmarkSaved:
        return const [
          Color(0xF5064E3B),
          Color(0xF50F172A),
        ];
      case NotificationType.spiritualTip:
        return const [
          Color(0xF51E3A8A),
          Color(0xF5172554),
        ];
      case NotificationType.reminder8Hour:
      default:
        return const [
          Color(0xF50A1128),
          Color(0xF51E1B4B),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 8,
      left: 14,
      right: 14,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Dismissible(
            key: widget.key ?? const Key('celestial_notif_banner'),
            direction: DismissDirection.up,
            onDismissed: (_) => widget.onDismiss(),
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getGradientColors(),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: AppTheme.celestialStarGold.withOpacity(0.55),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.celestialStarGold.withOpacity(0.22),
                          blurRadius: 20,
                          spreadRadius: 1,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.55),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Mobile App Notification Header (like native iOS/Android heads-up)
                        Row(
                          children: [
                            // App Icon Emblem
                            Container(
                              width: 26,
                              height: 26,
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    AppTheme.celestialStarGold,
                                    AppTheme.celestialStarlightBlue,
                                  ],
                                ),
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/noor_logo.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // App Name and Type
                            Text(
                              'NOOR QURAN',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: AppTheme.celestialStarGold,
                              ),
                            ),
                            Text(
                              ' • ${_getTypeLabel()}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.white70,
                              ),
                            ),

                            const Spacer(),

                            // Time Ago Pill
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Just now',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: Colors.white60,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),

                            // Close Icon
                            GestureDetector(
                              onTap: _dismissWithAnimation,
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.08),
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // 2. Notification Body with Generous Sizing
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Glowing status icon
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.celestialStarGold.withOpacity(0.18),
                                border: Border.all(
                                  color: AppTheme.celestialStarGold.withOpacity(0.4),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                _getIcon(),
                                size: 20,
                                color: AppTheme.celestialStarGold,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Title and Message
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title,
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1.25,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    widget.message,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: const Color(0xFFE2E8F0),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // 3. Verse Reference Banner (if present)
                        if (widget.verseReference != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.celestialSurfaceIndigo.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.celestialStarGold.withOpacity(0.35),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.auto_stories_rounded,
                                  size: 15,
                                  color: AppTheme.celestialStarGold,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.verseReference!,
                                    style: GoogleFonts.karla(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.celestialStarGold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // 4. Action Row with Generous Buttons
                        if (widget.actionLabel != null && widget.onAction != null) ...[
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: _dismissWithAnimation,
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white70,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                ),
                                child: const Text('Dismiss'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  _dismissWithAnimation();
                                  widget.onAction?.call();
                                },
                                icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                                label: Text(widget.actionLabel!),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.celestialStarGold,
                                  foregroundColor: AppTheme.celestialMidnight,
                                  elevation: 4,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
