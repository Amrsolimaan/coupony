import 'package:flutter/material.dart';
import 'spatial_reveal_config.dart';

/// ═══════════════════════════════════════════════════════════════════
/// SPATIAL REVEAL TRANSITION — Coupony Exclusive
/// ═══════════════════════════════════════════════════════════════════
///
/// A 3D perspective navigation transition unlike anything in Flutter.
///
/// ╔══════════════════════════════════════════════════════════════════╗
/// ║  Incoming  → tilted flat card flies toward you from depth       ║
/// ║  Outgoing  → retreats backward and tilts away into space        ║
/// ╚══════════════════════════════════════════════════════════════════╝
///
/// Technique: Matrix4.identity()..setEntry(3,2, perspective)..rotateX/Y
/// This is the same technique used in Apple's Spatial Computing UI.
/// Fully GPU-accelerated — zero performance cost.
/// ═══════════════════════════════════════════════════════════════════
class SpatialRevealTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  const SpatialRevealTransition({
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
        // OUTGOING — page being pushed over (secondaryAnimation > 0)
        // ────────────────────────────────────────────────────────────
        if (secondaryAnimation.value > 0.0) {
          return _buildOutgoing(secondaryAnimation.value, childWidget!);
        }

        // ────────────────────────────────────────────────────────────
        // POPPING — page replaced via context.go
        // ────────────────────────────────────────────────────────────
        if (animation.status == AnimationStatus.reverse) {
          final reverseT = 1.0 - animation.value;
          return _buildOutgoing(reverseT, childWidget!);
        }

        // ────────────────────────────────────────────────────────────
        // INCOMING — page entering (the 3D magic)
        // ────────────────────────────────────────────────────────────
        return _buildIncoming(animation.value, childWidget!);
      },
      child: child,
    );
  }

  /// Incoming: page flies toward the user from depth.
  /// X-rotation creates the "card coming at you" illusion.
  Widget _buildIncoming(double raw, Widget childWidget) {
    final t = SpatialRevealConfig.incomingCurve.transform(raw);

    final xAngle = SpatialRevealConfig.incomingInitialXRotation * (1.0 - t);
    final scale  = SpatialRevealConfig.incomingInitialScale +
        t * (SpatialRevealConfig.incomingFinalScale - SpatialRevealConfig.incomingInitialScale);
    final opacity = (SpatialRevealConfig.incomingInitialOpacity +
        t * (SpatialRevealConfig.incomingFinalOpacity - SpatialRevealConfig.incomingInitialOpacity))
        .clamp(0.0, 1.0);

    final matrix = Matrix4.identity()
      ..setEntry(3, 2, SpatialRevealConfig.perspective)
      ..rotateX(xAngle)
      ..scale(scale);

    return Opacity(
      opacity: opacity,
      child: Transform(
        alignment: Alignment.center,
        transform: matrix,
        child: childWidget,
      ),
    );
  }

  /// Outgoing: page retreats back into Z-space and tilts away.
  /// Y-rotation gives a gentle "pushed aside" feeling.
  Widget _buildOutgoing(double raw, Widget childWidget) {
    final t = SpatialRevealConfig.outgoingCurve.transform(raw.clamp(0.0, 1.0));

    final yAngle  = t * SpatialRevealConfig.outgoingFinalYRotation;
    final scale   = 1.0 - t * (1.0 - SpatialRevealConfig.outgoingFinalScale);
    final opacity = (1.0 - t * (1.0 - SpatialRevealConfig.outgoingFinalOpacity))
        .clamp(0.0, 1.0);

    final matrix = Matrix4.identity()
      ..setEntry(3, 2, SpatialRevealConfig.perspective)
      ..rotateY(yAngle)
      ..scale(scale);

    return Opacity(
      opacity: opacity,
      child: Transform(
        alignment: Alignment.center,
        transform: matrix,
        child: childWidget,
      ),
    );
  }
}
