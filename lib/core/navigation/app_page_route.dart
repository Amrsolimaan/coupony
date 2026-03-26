import 'package:coupony/core/navigation/transitions/sharp_reveal/sharp_reveal_config.dart';
import 'package:flutter/material.dart';
import 'app_transitions.dart';

/// للاستخدام مع Navigator.push
class AppPageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;

  AppPageRoute({required this.builder, RouteSettings? settings})
    : super(settings: settings);

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => SharpRevealConfig.barrierLabel;

  @override
  bool get barrierDismissible => SharpRevealConfig.barrierDismissible;

  @override
  bool get maintainState => SharpRevealConfig.maintainState;

  @override
  bool get fullscreenDialog => SharpRevealConfig.fullscreenDialog;

  @override
  bool get allowSnapshotting => SharpRevealConfig.allowSnapshotting;

  @override
  Duration get transitionDuration => SharpRevealConfig.duration;

  @override
  Duration get reverseTransitionDuration => SharpRevealConfig.reverseDuration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return AppTransitions.build(context, animation, secondaryAnimation, child);
  }
}
