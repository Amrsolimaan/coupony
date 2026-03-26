import 'package:flutter/material.dart';

/// Sharp Reveal Transition — Configuration
///
/// انتقال جريء ومختلف مناسب لتطبيقات الشوبينج
/// الصفحة الجديدة تدخل من اليمين بثقة، القديمة تتراجع للخلف
class SharpRevealConfig {
  SharpRevealConfig._();

  // ── Timing ────────────────────────────────────────────────────────────────

  /// سريع ومتجاوب — إحساس بالتطبيق الاحترافي
  static const Duration duration = Duration(milliseconds: 240);
  static const Duration reverseDuration = Duration(milliseconds: 220);

  // ── Incoming Page (الصفحة الجديدة) ────────────────────────────────────────

  /// تدخل من اليمين — 7% من عرض الشاشة فقط (مش كثير، مش قليل)
  static const double incomingHorizontalOffset = 0.07;

  /// scale خفيف جداً — عصري 2025
  static const double incomingInitialScale = 0.97;
  static const double incomingFinalScale = 1.0;

  /// تبدأ شفافة تماماً
  static const double incomingInitialOpacity = 0.0;
  static const double incomingFinalOpacity = 1.0;

  /// حاد في البداية، يهدأ بنعومة = إحساس بالثقة والسرعة
  static const Curve incomingCurve = Curves.easeOutQuint;

  // ── Outgoing Page (الصفحة القديمة) ────────────────────────────────────────

  /// تتراجع للخلف وتختفي بسرعة
  static const double outgoingFinalScale = 0.93;
  static const double outgoingFinalOpacity = 0.0;

  /// تختفي بحسم — مش بتتردد
  static const Curve outgoingCurve = Curves.easeInQuart;

  // ── Route Settings ─────────────────────────────────────────────────────────
  static const bool maintainState = true;
  static const bool fullscreenDialog = false;
  static const bool barrierDismissible = false;
  static const bool allowSnapshotting = true;
  static const String? barrierLabel = null;
}