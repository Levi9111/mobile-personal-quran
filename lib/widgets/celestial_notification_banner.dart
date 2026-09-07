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

  /// Shows a sleek, compact celestial floating in-app notification banner
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
    // Dismiss any existing notification banner first
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
      builder: (ctx) => _CompactBannerWidget(
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

class _CompactBannerWidget extends StatefulWidget {
  final String title;
  final String message;
  final String? verseReference;
  final String? actionLabel;
  final VoidCallback? onAction;
  final NotificationType type;
  final VoidCallback onDismiss;
  final Duration duration;

  const _CompactBannerWidget({
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
  State<_CompactBannerWidget> createState() => _CompactBannerWidgetState();
}

class _CompactBannerWidgetState extends State<_CompactBannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
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
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismissWithAnimation();
      }
    });
  }

  void _dismissWithAnimation() {
    if (!mounted) return;
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
        return const [
          Color(0xF01E1B4B),
          Color(0xF0311042),
        ];
      case NotificationType.bookmarkSaved:
        return const [
          Color(0xF0064E3B),
          Color(0xF00F172A),
        ];
      case NotificationType.spiritualTip:
        return const [
          Color(0xF01E3A8A),
          Color(0xF0172554),
        ];
      case NotificationType.reminder8Hour:
      default:
        return const [
          Color(0xF00A1128),
          Color(0xF01E1B4B),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 6,
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
              child: GestureDetector(
                onTap: widget.onAction ?? widget.onDismiss,
                behavior: HitTestBehavior.opaque,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _getGradientColors(),
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppTheme.celestialStarGold.withOpacity(0.55),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.celestialStarGold.withOpacity(0.20),
                            blurRadius: 16,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 1. Compact Glowing Anime Emblem
                          Container(
                            width: 32,
                            height: 32,
                            padding: const EdgeInsets.all(1.5),
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
                                  color: AppTheme.celestialStarGold
                                      .withOpacity(0.4),
                                  blurRadius: 8,
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
                                size: 16,
                                color: AppTheme.celestialStarGold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // 2. Compact Title & Single-Line Info
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        widget.title,
                                        style: GoogleFonts.cormorantGaramond(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.3,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (widget.verseReference != null) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 1.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.celestialStarGold
                                              .withOpacity(0.18),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: AppTheme.celestialStarGold
                                                .withOpacity(0.4),
                                            width: 0.6,
                                          ),
                                        ),
                                        child: Text(
                                          widget.verseReference!,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.celestialStarGold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.message,
                                  style: GoogleFonts.karla(
                                    fontSize: 11.5,
                                    color: Colors.white.withOpacity(0.85),
                                    height: 1.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // 3. Mini Action Pill Button
                          if (widget.actionLabel != null)
                            InkWell(
                              onTap: widget.onAction,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.celestialStarGold,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.celestialStarGold
                                          .withOpacity(0.3),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      widget.actionLabel!,
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.celestialMidnight,
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 11,
                                      color: AppTheme.celestialMidnight,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // 4. Quick Close Icon
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: _dismissWithAnimation,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.close_rounded,
                                size: 15,
                                color: Colors.white.withOpacity(0.55),
                              ),
                            ),
                          ),
                        ],
                      ),
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
