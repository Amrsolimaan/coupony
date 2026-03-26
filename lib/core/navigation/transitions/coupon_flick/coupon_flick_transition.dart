import 'package:flutter/material.dart';
import 'coupon_flick_config.dart';

/// ═══════════════════════════════════════════════════════════════════
/// COUPON FLICK TRANSITION
/// ═══════════════════════════════════════════════════════════════════
///
/// Coupony's signature transition — designed to feel like flicking
/// through coupons. Fast, warm, alive, and unmistakably unique.
///
/// ╔══════════════════════════════════════════════════════════════════╗
/// ║  Incoming page  → diagonal spring from bottom-right             ║
/// ║  Outgoing page  → shrinks, fades, and tilts slightly away       ║
/// ╚══════════════════════════════════════════════════════════════════╝
/// ═══════════════════════════════════════════════════════════════════
class CouponFlickTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  const CouponFlickTransition({
    super.key,
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([animation, secondaryAnimation]),
      builder: (context, childWidget) {
        // ────────────────────────────────────────────────────────────
        // OUTGOING: This page is being covered by a push
        // ────────────────────────────────────────────────────────────
        if (secondaryAnimation.value > 0.0) {
          final t = CouponFlickConfig.outgoingCurve
              .transform(secondaryAnimation.value);

          final scale   = 1.0 - t * (1.0 - CouponFlickConfig.outgoingFinalScale);
          final opacity = 1.0 - t * (1.0 - CouponFlickConfig.outgoingFinalOpacity);
          final angle   = t * CouponFlickConfig.outgoingFinalRotation;

          return Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Transform(
              alignment: Alignment.centerLeft, // rotates from the left edge
              transform: Matrix4.identity()
                ..scale(scale)
                ..rotateZ(angle),
              child: childWidget,
            ),
          );
        }

        // ────────────────────────────────────────────────────────────
        // POPPING: This page is being replaced via context.go
        // ────────────────────────────────────────────────────────────
        if (animation.status == AnimationStatus.reverse) {
          final reverseT = 1.0 - animation.value;
          final t = CouponFlickConfig.outgoingCurve.transform(reverseT);

          final scale   = 1.0 - t * (1.0 - CouponFlickConfig.outgoingFinalScale);
          final opacity = 1.0 - t * (1.0 - CouponFlickConfig.outgoingFinalOpacity);
          final angle   = t * CouponFlickConfig.outgoingFinalRotation;

          return Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Transform(
              alignment: Alignment.centerLeft,
              transform: Matrix4.identity()
                ..scale(scale)
                ..rotateZ(angle),
              child: childWidget,
            ),
          );
        }

        // ────────────────────────────────────────────────────────────
        // INCOMING: This page is entering the screen
        // ────────────────────────────────────────────────────────────
        final t = CouponFlickConfig.incomingCurve.transform(animation.value);

        final scale   = CouponFlickConfig.incomingInitialScale +
            t * (CouponFlickConfig.incomingFinalScale - CouponFlickConfig.incomingInitialScale);
        final opacity = CouponFlickConfig.incomingInitialOpacity +
            t * (CouponFlickConfig.incomingFinalOpacity - CouponFlickConfig.incomingInitialOpacity);
        final dx      = CouponFlickConfig.incomingDx * (1.0 - t);
        final dy      = CouponFlickConfig.incomingDy * (1.0 - t);

        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: FractionalTranslation(
            translation: Offset(dx, dy),
            child: Transform.scale(
              scale: scale,
              child: childWidget,
            ),
          ),
        );
      },
      child: child,
    );
  }
}
