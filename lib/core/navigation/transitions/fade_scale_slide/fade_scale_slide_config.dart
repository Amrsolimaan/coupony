// import 'package:flutter/widgets.dart';

// /// Page Transition Configuration
// ///
// /// This file contains all transition settings in one place.
// /// Change values here to update transitions across the entire app.
// class PageTransitionConfig {
//   PageTransitionConfig._();

//   // ══════════════════════════════════════════════════════════════════════════
//   // FADE SCALE SLIDE TRANSITION SETTINGS
//   // ══════════════════════════════════════════════════════════════════════════

//   /// Total animation duration
//   static const Duration duration = Duration(milliseconds: 280);

//   /// Reverse animation duration (when going back)
//   static const Duration reverseDuration = Duration(milliseconds: 250);

//   // ── Scale Settings ────────────────────────────────────────────────────────

//   /// Initial scale of incoming page (0.92 = 92% of original size)
//   static const double incomingPageInitialScale = 0.92;

//   /// Final scale of incoming page (always 1.0 = 100%)
//   static const double incomingPageFinalScale = 1.0;

//   /// Final scale of outgoing page (0.97 = 97% - slightly smaller)
//   static const double outgoingPageFinalScale = 0.97;

//   // ── Slide Settings ────────────────────────────────────────────────────────

//   /// Vertical offset for incoming page (in logical pixels)
//   /// Positive = from bottom, Negative = from top
//   static const double incomingPageVerticalOffset = 30.0;

//   // ── Fade Settings ─────────────────────────────────────────────────────────

//   /// Initial opacity of incoming page (0.0 = fully transparent)
//   static const double incomingPageInitialOpacity = 0.0;

//   /// Final opacity of incoming page (1.0 = fully opaque)
//   static const double incomingPageFinalOpacity = 1.0;

//   /// Final opacity of outgoing page (0.0 = fully transparent)
//   static const double outgoingPageFinalOpacity = 0.0;

//   // ── Curve Settings ────────────────────────────────────────────────────────

//   /// Animation curve for incoming page
//   /// Options: Curves.easeOutCubic, Curves.easeOut, Curves.fastOutSlowIn
//   static const Curve incomingPageCurve = Curves.easeOutCubic;

//   /// Animation curve for outgoing page
//   static const Curve outgoingPageCurve = Curves.easeInCubic;

//   // ══════════════════════════════════════════════════════════════════════════
//   // BARRIER SETTINGS (for modal routes)
//   // ══════════════════════════════════════════════════════════════════════════

//   /// Whether to show a barrier (dark overlay) behind the page
//   static const bool barrierDismissible = false;

//   /// Barrier color (null = no barrier)
//   static const String? barrierLabel = null;

//   // ══════════════════════════════════════════════════════════════════════════
//   // PERFORMANCE SETTINGS
//   // ══════════════════════════════════════════════════════════════════════════

//   /// Whether to maintain state of the previous route
//   static const bool maintainState = true;

//   /// Whether the route is full screen
//   static const bool fullscreenDialog = false;

//   /// Whether to allow snapshotting for better performance
//   static const bool allowSnapshotting = true;
// }
