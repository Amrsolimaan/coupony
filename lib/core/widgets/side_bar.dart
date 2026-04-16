import 'dart:ui';

import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SELLER SIDE BAR
// Premium full-screen overlay sidebar with staggered entrance animations.
//
// Usage:
//   showSellerSideBar(
//     context,
//     userName: 'M Brand',
//     userSubtitle: 'بائع نشط',
//     items: [...],
//   );
// ─────────────────────────────────────────────────────────────────────────────

/// Data model for a single sidebar navigation item.
class SideBarItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const SideBarItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });
}

/// Opens the premium seller sidebar as a full-screen overlay.
///
/// All navigation/action callbacks are closures — no providers are read inside
/// the overlay itself, keeping it fully portable.
void showSellerSideBar(
  BuildContext context, {
  required String userName,
  required String userSubtitle,
  required List<SideBarItem> items,
}) {
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _SideBarOverlay(
      userName: userName,
      userSubtitle: userSubtitle,
      items: items,
      onDismiss: () => entry.remove(),
    ),
  );
  Overlay.of(context).insert(entry);
}

// ─────────────────────────────────────────────────────────────────────────────
// OVERLAY WIDGET (private)
// ─────────────────────────────────────────────────────────────────────────────

class _SideBarOverlay extends StatefulWidget {
  final String userName;
  final String userSubtitle;
  final List<SideBarItem> items;
  final VoidCallback onDismiss;

  const _SideBarOverlay({
    required this.userName,
    required this.userSubtitle,
    required this.items,
    required this.onDismiss,
  });

  @override
  State<_SideBarOverlay> createState() => _SideBarOverlayState();
}

class _SideBarOverlayState extends State<_SideBarOverlay>
    with TickerProviderStateMixin {
  // ── Controllers ────────────────────────────────────────────────────────────

  late final AnimationController _ctrl;

  // ── Named animations ───────────────────────────────────────────────────────

  late final Animation<double> _backdropFade;
  late final Animation<Offset> _panelSlide;
  late final Animation<double> _panelFade;
  late final List<Animation<double>> _itemFades;

  // ── Constants ──────────────────────────────────────────────────────────────

  static const _panelFraction = 0.70; // panel width = 70 % of screen
  static const _enterDuration = Duration(milliseconds: 400);
  static const _exitDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(vsync: this, duration: _enterDuration);

    // Backdrop dims over the first half of the animation
    _backdropFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );

    // Panel slides in from the right edge with a cubic ease
    _panelSlide = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.70, curve: Curves.easeOutCubic),
    ));

    // Panel itself fades in slightly (prevents hard pop)
    _panelFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.40, curve: Curves.easeIn),
    );

    // Per-item staggered fades — header (i=0) then each item
    final count = widget.items.length + 1;
    _itemFades = List.generate(count, (i) {
      final start = (0.28 + i * 0.07).clamp(0.0, 0.88);
      final end = (start + 0.28).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _ctrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      );
    });

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── Dismiss (plays reverse before removing) ────────────────────────────────

  Future<void> _dismiss() async {
    _ctrl.duration = _exitDuration;
    await _ctrl.reverse();
    widget.onDismiss();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final panelW = screenSize.width * _panelFraction;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        children: [
          // ── Blurred backdrop ───────────────────────────────────────────────
          FadeTransition(
            opacity: _backdropFade,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _dismiss,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  width: screenSize.width,
                  height: screenSize.height,
                  color: Colors.black.withValues(alpha: 0.50),
                ),
              ),
            ),
          ),

          // ── Side panel (slides from right = RTL start) ─────────────────────
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            child: SlideTransition(
              position: _panelSlide,
              child: FadeTransition(
                opacity: _panelFade,
                child: _buildPanel(context, panelW),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Panel shell ────────────────────────────────────────────────────────────

  Widget _buildPanel(BuildContext context, double panelW) {
    const radius = BorderRadius.only(
      topLeft: Radius.circular(30),
      bottomLeft: Radius.circular(30),
    );

    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: Container(
        width: panelW,
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.60),
              blurRadius: 56,
              offset: const Offset(-8, 0),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF081830).withValues(alpha: 0.90),
                    const Color(0xFF0D2252).withValues(alpha: 0.88),
                    const Color(0xFF091C3E).withValues(alpha: 0.92),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: const Border(
                  left: BorderSide(
                    color: Color(0x1AFFFFFF), // subtle white edge
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Header ─────────────────────────────────────────────────
                    FadeTransition(
                      opacity: _itemFades[0],
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.08, 0),
                          end: Offset.zero,
                        ).animate(_itemFades[0]),
                        child: _buildHeader(context),
                      ),
                    ),

                    // ── Section divider ───────────────────────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.0),
                              Colors.white.withValues(alpha: 0.12),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),

                    // ── Navigation items ──────────────────────────────────────
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        itemCount: widget.items.length,
                        itemBuilder: (_, i) {
                          final fadeIdx = (i + 1).clamp(0, _itemFades.length - 1);
                          final fade = _itemFades[fadeIdx];

                          return FadeTransition(
                            opacity: fade,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.10, 0),
                                end: Offset.zero,
                              ).animate(fade),
                              child: _SideBarTile(
                                item: widget.items[i],
                                onTap: () async {
                                  await _dismiss();
                                  widget.items[i].onTap();
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // ── Footer ────────────────────────────────────────────────
                    Padding(
                      padding: EdgeInsets.only(bottom: 18.h),
                      child: Center(
                        child: Text(
                          'Coupony  •  v1.0.0',
                          style: AppTextStyles.customStyle(
                            context,
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.20),
                          ),
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
    );
  }

  // ── Header section ─────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final initial = widget.userName.isNotEmpty
        ? widget.userName.characters.first.toUpperCase()
        : 'S';

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 22.h, 16.w, 18.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Avatar ─────────────────────────────────────────────────────────
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF3A7BD5), Color(0xFF215194)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.20),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryOfSeller.withValues(alpha: 0.50),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initial,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // ── Name + subtitle ────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.userName,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFF34D399), // green dot — active
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      widget.userSubtitle,
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.50),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Close ──────────────────────────────────────────────────────────
          GestureDetector(
            onTap: _dismiss,
            child: Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.10),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.close_rounded,
                color: Colors.white.withValues(alpha: 0.60),
                size: 15.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SIDEBAR TILE (private)
// ─────────────────────────────────────────────────────────────────────────────

class _SideBarTile extends StatefulWidget {
  final SideBarItem item;
  final VoidCallback onTap;

  const _SideBarTile({required this.item, required this.onTap});

  @override
  State<_SideBarTile> createState() => _SideBarTileState();
}

class _SideBarTileState extends State<_SideBarTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDestructive = widget.item.isDestructive;

    final iconBg = isDestructive
        ? const Color(0xFFEF4444).withValues(alpha: 0.14)
        : Colors.white.withValues(alpha: 0.07);

    final iconColor = isDestructive
        ? const Color(0xFFEF4444)
        : Colors.white.withValues(alpha: 0.85);

    final labelColor = isDestructive
        ? const Color(0xFFEF4444)
        : Colors.white.withValues(alpha: 0.85);

    final tileColor = _pressed
        ? Colors.white.withValues(alpha: isDestructive ? 0.04 : 0.06)
        : Colors.transparent;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: EdgeInsets.only(bottom: 2.h),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 11.h),
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            // ── Icon container ───────────────────────────────────────────────
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: isDestructive
                      ? const Color(0xFFEF4444).withValues(alpha: 0.20)
                      : Colors.white.withValues(alpha: 0.06),
                  width: 1,
                ),
              ),
              child: Icon(widget.item.icon, color: iconColor, size: 17.w),
            ),

            SizedBox(width: 14.w),

            // ── Label ─────────────────────────────────────────────────────────
            Expanded(
              child: Text(
                widget.item.label,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: labelColor,
                ),
              ),
            ),

            // ── Chevron (non-destructive items only) ──────────────────────────
            if (!isDestructive)
              Icon(
                Icons.chevron_left_rounded, // RTL: left = forward direction
                color: Colors.white.withValues(alpha: 0.22),
                size: 18.w,
              ),
          ],
        ),
      ),
    );
  }
}
