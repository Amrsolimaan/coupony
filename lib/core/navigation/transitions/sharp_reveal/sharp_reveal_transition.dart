import 'package:flutter/material.dart';
import 'sharp_reveal_config.dart';

/// Sharp Reveal Transition
///
/// الصفحة الجديدة تدخل من اليمين بـ scale + fade
/// الصفحة القديمة تتراجع للخلف وتختفي بسرعة
class SharpRevealTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  const SharpRevealTransition({
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
        // 1. Outgoing (Page being covered by a newly pushed page)
        if (secondaryAnimation.value > 0.0) {
          final t = SharpRevealConfig.outgoingCurve.transform(secondaryAnimation.value);
          final scale = 1.0 - (t * (1.0 - SharpRevealConfig.outgoingFinalScale));
          final opacity = 1.0 - (t * (1.0 - SharpRevealConfig.outgoingFinalOpacity));
          return Transform.scale(
            scale: scale,
            child: Opacity(opacity: opacity.clamp(0.0, 1.0), child: childWidget),
          );
        }

        // 2. Erasing/Popping (Page being Replaced via context.go)
        if (animation.status == AnimationStatus.reverse) {
          final reverseVal = 1.0 - animation.value;
          final t = SharpRevealConfig.outgoingCurve.transform(reverseVal);
          final scale = 1.0 - (t * (1.0 - SharpRevealConfig.outgoingFinalScale));
          final opacity = 1.0 - (t * (1.0 - SharpRevealConfig.outgoingFinalOpacity));
          return Transform.scale(
            scale: scale,
            child: Opacity(opacity: opacity.clamp(0.0, 1.0), child: childWidget),
          );
        }

        // 3. Incoming (Page entering normally)
        final inVal = animation.value;
        final t = SharpRevealConfig.incomingCurve.transform(inVal);
        final scale = SharpRevealConfig.incomingInitialScale +
            (t * (SharpRevealConfig.incomingFinalScale - SharpRevealConfig.incomingInitialScale));
        final opacity = SharpRevealConfig.incomingInitialOpacity +
            (t * (SharpRevealConfig.incomingFinalOpacity - SharpRevealConfig.incomingInitialOpacity));
        final dx = SharpRevealConfig.incomingHorizontalOffset * (1.0 - t);

        return FractionalTranslation(
          translation: Offset(dx, 0.0),
          child: Transform.scale(
            scale: scale,
            child: Opacity(opacity: opacity.clamp(0.0, 1.0), child: childWidget),
          ),
        );
      },
      child: child,
    );
  }
}
