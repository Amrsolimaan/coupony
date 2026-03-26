// import 'package:flutter/material.dart';
// import 'fade_scale_slide_config.dart';

// /// Fade Scale Slide Transition Builder
// /// 
// /// Creates a smooth transition with:
// /// - Fade in/out
// /// - Scale animation
// /// - Subtle slide from bottom
// /// 
// /// This is the core animation logic. All settings are controlled
// /// from FadeScaleSlideConfig.
// class FadeScaleSlideTransition extends StatelessWidget {
//   final Animation<double> animation;
//   final Animation<double> secondaryAnimation;
//   final Widget child;

//   const FadeScaleSlideTransition({
//     super.key,
//     required this.animation,
//     required this.secondaryAnimation,
//     required this.child,
//   });

//   /// Static builder method for use with AppTransitions
//   static Widget builder(
//     BuildContext context,
//     Animation<double> animation,
//     Animation<double> secondaryAnimation,
//     Widget child,
//   ) {
//     return FadeScaleSlideTransition(
//       animation: animation,
//       secondaryAnimation: secondaryAnimation,
//       child: child,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         // ══════════════════════════════════════════════════════════════════════
//         // OUTGOING PAGE (Previous page fading out and scaling down)
//         // ══════════════════════════════════════════════════════════════════════
//         if (secondaryAnimation.status != AnimationStatus.dismissed)
//           FadeTransition(
//             opacity: Tween<double>(
//               begin: 1.0,
//               end: FadeScaleSlideConfig.outgoingPageFinalOpacity,
//             ).animate(
//               CurvedAnimation(
//                 parent: secondaryAnimation,
//                 curve: FadeScaleSlideConfig.outgoingPageCurve,
//               ),
//             ),
//             child: ScaleTransition(
//               scale: Tween<double>(
//                 begin: 1.0,
//                 end: FadeScaleSlideConfig.outgoingPageFinalScale,
//               ).animate(
//                 CurvedAnimation(
//                   parent: secondaryAnimation,
//                   curve: FadeScaleSlideConfig.outgoingPageCurve,
//                 ),
//               ),
//               child: child,
//             ),
//           ),

//         // ══════════════════════════════════════════════════════════════════════
//         // INCOMING PAGE (New page fading in, scaling up, sliding from bottom)
//         // ══════════════════════════════════════════════════════════════════════
//         SlideTransition(
//           position: Tween<Offset>(
//             begin: Offset(
//               0,
//               FadeScaleSlideConfig.incomingPageVerticalOffset / 
//                 MediaQuery.of(context).size.height,
//             ),
//             end: Offset.zero,
//           ).animate(
//             CurvedAnimation(
//               parent: animation,
//               curve: FadeScaleSlideConfig.incomingPageCurve,
//             ),
//           ),
//           child: FadeTransition(
//             opacity: Tween<double>(
//               begin: FadeScaleSlideConfig.incomingPageInitialOpacity,
//               end: FadeScaleSlideConfig.incomingPageFinalOpacity,
//             ).animate(
//               CurvedAnimation(
//                 parent: animation,
//                 curve: FadeScaleSlideConfig.incomingPageCurve,
//               ),
//             ),
//             child: ScaleTransition(
//               scale: Tween<double>(
//                 begin: FadeScaleSlideConfig.incomingPageInitialScale,
//                 end: FadeScaleSlideConfig.incomingPageFinalScale,
//               ).animate(
//                 CurvedAnimation(
//                   parent: animation,
//                   curve: FadeScaleSlideConfig.incomingPageCurve,
//                 ),
//               ),
//               child: child,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
