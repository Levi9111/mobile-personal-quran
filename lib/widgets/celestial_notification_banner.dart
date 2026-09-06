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

  /// Shows a celestial floating in-app notification banner
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    String? verseReference,
    String? actionLabel,
    VoidCallback? onAction,
    NotificationType type = NotificationType.reminder8Hour,
    Duration duration = const Duration(seconds: 6),
  }) {
    // Dismiss existing notification if any
    dismiss();

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    final entry = OverlayEntry(
      builder: (context) => _BannerWidget(
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
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _BannerWidget extends StatefulWidget {
  final String title;
  final String message;
  final String? verseReference;
  final String? actionLabel;
  final VoidCallback? onAction;
  final NotificationType type;
  final VoidCallback onDismiss;
  final Duration duration;

  const _BannerWidget({
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
  State<_BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<_BannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    // Auto dismiss after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismissWithAnimation();
      }
    });
  }

  void _dismissWithAnimation() {
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
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

  List<Color> _getGradientColors() {
    switch (widget.type) {
      case NotificationType.dailyMissed:
        return [
          const Color(0xFF1E1B4B).withOpacity(0.95),
          const Color(0xFF311042).withOpacity(0.95),
        ];
      case NotificationType.bookmarkSaved:
        return [
          const Color(0xFF064E3B).withOpacity(0.95),
          const Color(0xFF0F172A).withOpacity(0.95),
        ];
      case NotificationType.spiritualTip:
        return [
          const Color(0xFF1E3A8A).withOpacity(0.95),
          const Color(0xFF172554).withOpacity(0.95),
        ];
      case NotificationType.reminder8Hour:
      default:
        return [
          const Color(0xFF0F172A).withOpacity(0.96),
          const Color(0xFF1E1B4B).withOpacity(0.96),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 10,
      left: 14,
      right: 14,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Dismissible(
            key: const Key('celestial_notification_key'),
            direction: DismissDirection.up,
            onDismissed: (_) => widget.onDismiss(),
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getGradientColors(),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: AppTheme.celestialStarGold.withOpacity(0.65),
                        width: 1.4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.celestialStarGold.withOpacity(0.25),
                          blurRadius: 24,
                          spreadRadius: 2,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Luminous Anime Icon Orb
                            Container(
                              width: 42,
                              height: 42,
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    AppTheme.celestialStarGold,
                                    AppTheme.celestialStarlightBlue,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.celestialStarGold.withOpacity(0.5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF0F172A),
                                ),
                                child: Icon(
                                  _getIcon(),
                                  size: 20,
                                  color: AppTheme.celestialStarGold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Content Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        widget.title,
                                        style: GoogleFonts.cormorantGaramond(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const Spacer(),
                                      GestureDetector(
                                        onTap: _dismissWithAnimation,
                                        child: Icon(
                                          Icons.close_rounded,
                                          size: 16,
                                          color: Colors.white.withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.message,
                                    style: GoogleFonts.karla(
                                      fontSize: 13,
                                      color: Colors.white.withOpacity(0.9),
                                      height: 1.3,
                                    ),
                                  ),
                                  if (widget.verseReference != null) ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppTheme.celestialStarGold.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppTheme.celestialStarGold.withOpacity(0.4),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Text(
                                        widget.verseReference!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.celestialStarGold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Action Button if provided
                        if (widget.actionLabel != null && widget.onAction != null) ...[
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: widget.onAction,
                              icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                              label: Text(widget.actionLabel!),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.celestialStarGold,
                                foregroundColor: AppTheme.celestialMidnight,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
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
