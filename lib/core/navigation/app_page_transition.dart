import 'package:coupony/core/navigation/transitions/sharp_reveal/sharp_reveal_config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_transitions.dart';

/// للاستخدام مع GoRouter
class AppPageTransition {
  AppPageTransition._();

  static Page<T> build<T>({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
    String? name,
    Object? arguments,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      name: name ?? state.path,
      arguments: arguments,
      child: child,
      transitionDuration: SharpRevealConfig.duration,
      reverseTransitionDuration: SharpRevealConfig.reverseDuration,
      maintainState: SharpRevealConfig.maintainState,
      fullscreenDialog: SharpRevealConfig.fullscreenDialog,
      barrierDismissible: SharpRevealConfig.barrierDismissible,
      barrierColor: null,
      barrierLabel: SharpRevealConfig.barrierLabel,
      transitionsBuilder: AppTransitions.build,
    );
  }

  /// بدون أنيميشن (فوري)
  static Page<T> buildNoTransition<T>({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
    String? name,
  }) {
    return NoTransitionPage<T>(
      key: state.pageKey,
      name: name ?? state.path,
      child: child,
    );
  }
}