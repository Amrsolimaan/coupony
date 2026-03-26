import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════════
/// COUPON FLICK CONFIG
/// ═══════════════════════════════════════════════════════════════════
///
/// A bespoke navigation system designed for Coupony.
/// Personality: fast, alive, warm — like flicking through coupons.
///
/// ═══════════════════════════════════════════════════════════════════
class CouponFlickConfig {
  CouponFlickConfig._();

  // ── Timing ─────────────────────────────────────────────────────────
  /// Snappy forward — feels instant but is visually clear
  static const Duration duration = Duration(milliseconds: 290);

  /// Slightly quicker on reverse — popping feels lighter
  static const Duration reverseDuration = Duration(milliseconds: 240);

  // ── Incoming Page ──────────────────────────────────────────────────

  /// Diagonal entry: subtle horizontal + tiny vertical nudge
  /// Creates depth — not a flat slide.
  static const double incomingDx = 0.22;  // 22% from the right
  static const double incomingDy = 0.025; // 2.5% from the bottom

  /// Scale: starts "just behind" the screen, springs into place
  static const double incomingInitialScale = 0.91;
  static const double incomingFinalScale   = 1.0;

  /// Full opacity reveal — crisp, confident
  static const double incomingInitialOpacity = 0.0;
  static const double incomingFinalOpacity   = 1.0;

  /// 🎯 The signature curve:
  /// Accelerates sharply then glides to rest — energetic yet calm.
  /// fastEaseInToSlowEaseOut = Material 3 standard Expressive curve
  static const Curve incomingCurve = Curves.fastEaseInToSlowEaseOut;

  // ── Outgoing Page ──────────────────────────────────────────────────

  /// Shrinks noticeably — creates real depth/parallax
  static const double outgoingFinalScale = 0.88;

  /// Slight rotation — THE signature move.
  /// Like tossing a coupon aside. Unique. Subtle. Memorable.
  static const double outgoingFinalRotation = -0.018; // radians ≈ -1°

  /// Fades completely — new page takes full ownership
  static const double outgoingFinalOpacity = 0.0;

  /// Eases in sharply — commitment, no hesitation
  static const Curve outgoingCurve = Curves.easeInQuart;

  // ── Route Settings ─────────────────────────────────────────────────
  static const bool maintainState       = true;
  static const bool fullscreenDialog    = false;
  static const bool barrierDismissible  = false;
  static const String? barrierLabel     = null;
}
