import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════════
/// SPATIAL REVEAL CONFIG — Coupony Exclusive
/// ═══════════════════════════════════════════════════════════════════
///
/// A 3D perspective-based transition inspired by spatial computing.
/// Uses only Matrix4 transforms + Opacity — fully GPU-accelerated.
///
/// Visual concept:
///   INCOMING  → flies toward you from depth (X-tilt 15° → 0°)
///   OUTGOING  → falls back into space (Y-tilt 0° → -5°, shrinks)
///
/// Nobody does this in Flutter navigation. This is Coupony's signature.
/// ═══════════════════════════════════════════════════════════════════
class SpatialRevealConfig {
  SpatialRevealConfig._();

  // ── Timing ─────────────────────────────────────────────────────────

  /// Long enough to feel premium, short enough to feel snappy
  static const Duration duration = Duration(milliseconds: 380);
  static const Duration reverseDuration = Duration(milliseconds: 320);

  // ── Curves ─────────────────────────────────────────────────────────

  /// 🎯 Incoming: explosive start, silky landing — the 2025 standard
  static const Curve incomingCurve = Curves.fastEaseInToSlowEaseOut;

  /// 🎯 Outgoing: accelerates quickly, page is gone with conviction
  static const Curve outgoingCurve = Curves.easeInQuart;

  // ── 3D Perspective ─────────────────────────────────────────────────

  /// Perspective intensity. 0.0008–0.0015 is the sweet spot.
  /// Too high = fisheye distortion. Too low = unnoticeable.
  static const double perspective = 0.0010;

  // ── Incoming Page: FLIES TOWARD YOU ────────────────────────────────

  /// X-rotation start: page leans "back" like a card viewed from above
  /// 0.26 radians ≈ 15 degrees — dramatic but realistic
  static const double incomingInitialXRotation = 0.26;
  static const double incomingFinalXRotation = 0.0;

  /// Starts slightly small (coming from "behind" the screen)
  static const double incomingInitialScale = 0.88;
  static const double incomingFinalScale = 1.0;

  /// Fade in with the 3D arrival
  static const double incomingInitialOpacity = 0.0;
  static const double incomingFinalOpacity = 1.0;

  // ── Outgoing Page: FALLS BACK INTO SPACE ───────────────────────────

  /// Y-rotation end: page tilts slightly as it retreats — like a card
  /// being pushed back into a deck. 0.08 radians ≈ 4.5 degrees
  static const double outgoingFinalYRotation = -0.08;

  /// Shrinks as it retreats into the depth
  static const double outgoingFinalScale = 0.82;

  /// Vanishes as it falls back
  static const double outgoingFinalOpacity = 0.0;

  // ── Route Settings ─────────────────────────────────────────────────
  static const bool maintainState = true;
  static const bool fullscreenDialog = false;
  static const bool barrierDismissible = false;
  static const String? barrierLabel = null;
}
