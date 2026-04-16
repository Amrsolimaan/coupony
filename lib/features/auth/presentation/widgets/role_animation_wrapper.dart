import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/auth/presentation/cubit/persona_cubit.dart';
import '../../../../features/auth/domain/entities/user_persona.dart';

/// Role-Switch Animation Wrapper
///
/// Provides a smooth transition when switching between Customer and Seller
/// personas. Driven exclusively by [PersonaCubit] — the single source of
/// truth for role state across the app.
class RoleAnimationWrapper extends StatefulWidget {
  final Widget child;
  final Duration animationDuration;

  const RoleAnimationWrapper({
    super.key,
    required this.child,
    this.animationDuration = const Duration(milliseconds: 700),
  });

  @override
  State<RoleAnimationWrapper> createState() => _RoleAnimationWrapperState();
}

class _RoleAnimationWrapperState extends State<RoleAnimationWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _blurAnimation;
  late Animation<Color?> _colorAnimation;

  bool _isSeller = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _blurAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 5.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 5.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    _colorAnimation = ColorTween(
      begin: AppColors.primary,
      end: AppColors.primaryOfSeller,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      final persona = context.read<PersonaCubit>().state;
      _isSeller = persona is SellerPersona;
      _controller.value = _isSeller ? 1.0 : 0.0;
      _isInitialized = true;
    }
  }

  void _updateRoleAnimation(bool isSeller) {
    if (_isInitialized && isSeller != _isSeller) {
      _isSeller = isSeller;
      if (_isSeller) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PersonaCubit, UserPersona>(
      builder: (context, persona) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateRoleAnimation(persona is SellerPersona);
        });

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: _blurAnimation.value,
                sigmaY: _blurAnimation.value,
              ),
              child: AnimatedTheme(
                data: Theme.of(context).copyWith(
                  primaryColor: _colorAnimation.value ?? AppColors.primary,
                ),
                child: child!,
              ),
            );
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Animated Logo Switcher — morphs between Customer and Seller logos.
class AnimatedLogoSwitcher extends StatelessWidget {
  final double size;
  final Duration duration;

  const AnimatedLogoSwitcher({
    super.key,
    this.size = 80,
    this.duration = const Duration(milliseconds: 700),
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PersonaCubit, UserPersona>(
      builder: (context, persona) {
        final isSeller = persona is SellerPersona;

        return SizedBox(
          width: size.w,
          height: size.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedOpacity(
                opacity: isSeller ? 0.0 : 1.0,
                duration: duration,
                curve: Curves.easeInOut,
                child: AnimatedScale(
                  scale: isSeller ? 0.5 : 1.0,
                  duration: duration,
                  curve: Curves.easeInOut,
                  child: Image.asset(
                    'assets/icons/icon7.jpg',
                    width: size.w,
                    height: size.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              AnimatedOpacity(
                opacity: isSeller ? 1.0 : 0.0,
                duration: duration,
                curve: Curves.easeInOut,
                child: AnimatedScale(
                  scale: isSeller ? 1.0 : 0.5,
                  duration: duration,
                  curve: Curves.easeInOut,
                  child: Image.asset(
                    'assets/icons/seller_coupouny.png',
                    width: size.w,
                    height: size.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Animated Primary Color — interpolates orange ↔ blue on persona toggle.
class AnimatedPrimaryColor extends StatefulWidget {
  final Duration duration;
  final Widget Function(BuildContext context, Color primaryColor) builder;

  const AnimatedPrimaryColor({
    super.key,
    required this.builder,
    this.duration = const Duration(milliseconds: 700),
  });

  @override
  State<AnimatedPrimaryColor> createState() => _AnimatedPrimaryColorState();
}

class _AnimatedPrimaryColorState extends State<AnimatedPrimaryColor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _colorAnimation = ColorTween(
      begin: AppColors.primary,
      end: AppColors.primaryOfSeller,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      final persona = context.read<PersonaCubit>().state;
      _controller.value = persona is SellerPersona ? 1.0 : 0.0;
      _isInitialized = true;
    }
  }

  void _updateColorAnimation(bool isSeller) {
    if (_isInitialized) {
      if (isSeller) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PersonaCubit, UserPersona>(
      builder: (context, persona) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateColorAnimation(persona is SellerPersona);
        });

        return AnimatedBuilder(
          animation: _colorAnimation,
          builder: (context, child) {
            return widget.builder(
              context,
              _colorAnimation.value ?? AppColors.primary,
            );
          },
        );
      },
    );
  }
}
