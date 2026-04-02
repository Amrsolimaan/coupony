import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/auth/presentation/cubit/auth_role_cubit.dart';
import '../../../../features/auth/presentation/cubit/auth_role_state.dart';

/// Magical Role-Switch Animation Wrapper
/// 
/// Provides a smooth transition when switching between Customer and Seller roles:
/// - Step 1: Blur background
/// - Step 2: Morph logo (fade + scale)
/// - Step 3: Interpolate theme colors
/// 
/// NOW USES GLOBAL AuthRoleCubit FOR PERSISTENCE ACROSS ALL AUTH SCREENS
/// 
/// Usage:
/// ```dart
/// RoleAnimationWrapper(
///   child: YourContent(),
/// )
/// ```
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

    // Blur animation: 0 → 5 → 0 (peaks in the middle)
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

    // Color animation: Orange ↔ Blue
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
    
    // Initialize from current role on first build without animation
    if (!_isInitialized) {
      final roleState = context.read<AuthRoleCubit>().state;
      _isSeller = roleState.isMerchant;
      
      // Set controller to correct position without animating
      _controller.value = _isSeller ? 1.0 : 0.0;
      
      _isInitialized = true;
    }
  }

  void _updateRoleAnimation(bool isSeller) {
    // Only animate if initialized AND role actually changed
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
    return BlocBuilder<AuthRoleCubit, AuthRoleState>(
      builder: (context, roleState) {
        // Schedule animation update after build completes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateRoleAnimation(roleState.isMerchant);
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

/// Animated Logo Switcher
/// 
/// Morphs between Customer and Seller logos with fade + scale animation
/// NOW USES GLOBAL AuthRoleCubit
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
    return BlocBuilder<AuthRoleCubit, AuthRoleState>(
      builder: (context, roleState) {
        final isSeller = roleState.isMerchant;
        
        return SizedBox(
          width: size.w,
          height: size.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Customer Logo
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
              
              // Seller Logo
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

/// Animated Primary Color Provider
/// 
/// Provides the current interpolated primary color based on role
/// NOW USES GLOBAL AuthRoleCubit
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
    
    // Initialize from current role on first build without animation
    if (!_isInitialized) {
      final roleState = context.read<AuthRoleCubit>().state;
      
      // Set controller to correct position without animating
      _controller.value = roleState.isMerchant ? 1.0 : 0.0;
      
      _isInitialized = true;
    }
  }

  void _updateColorAnimation(bool isMerchant) {
    // Only animate if initialized
    if (_isInitialized) {
      if (isMerchant) {
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
    return BlocBuilder<AuthRoleCubit, AuthRoleState>(
      builder: (context, roleState) {
        // Schedule animation update after build completes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateColorAnimation(roleState.isMerchant);
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

