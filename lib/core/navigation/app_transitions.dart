import 'package:coupony/core/navigation/transitions/sharp_reveal/sharp_reveal_transition.dart';
import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// APP TRANSITIONS - وسيط مركزي
/// ═══════════════════════════════════════════════════════════════════════════
///
/// لتغيير الأنيميشن للكل → غيّر السطر الواحد في build() فقط
///
/// ═══════════════════════════════════════════════════════════════════════════
class AppTransitions {
  AppTransitions._();

  static Widget build(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // 🎯 غيّر هنا فقط لتبديل الأنيميشن للكل
    return SharpRevealTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}