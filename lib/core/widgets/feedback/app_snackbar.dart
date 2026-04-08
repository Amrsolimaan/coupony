import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import '../../theme/app_colors.dart';

enum SnackBarType { success, error, warning, info, networkSlow }

class AppSnackBar {
  AppSnackBar._();
  
  // مدير مركزي للـ snackbars النشطة
  static OverlayEntry? _currentOverlay;
  static bool _isShowing = false;

  static void show(
    BuildContext context, {
    required String message,
    required SnackBarType type,
    Duration duration = const Duration(seconds: 4),
    bool enableHaptic = true,
  }) {
    final config = _getConfig(type);
    
    // إخفاء أي snackbar حالي فوراً
    _hideCurrentSnackBar();
    
    // Haptic feedback for better UX
    if (enableHaptic) {
      switch (type) {
        case SnackBarType.success:
          HapticFeedback.lightImpact();
          break;
        case SnackBarType.error:
          HapticFeedback.heavyImpact();
          break;
        case SnackBarType.warning:
        case SnackBarType.info:
        case SnackBarType.networkSlow:
          HapticFeedback.selectionClick();
          break;
      }
    }
    
    // إنشاء snackbar جديد
    _showNewSnackBar(context, message, config, duration);
  }

  // إخفاء الـ snackbar الحالي فوراً
  static void _hideCurrentSnackBar() {
    if (_currentOverlay != null && _isShowing) {
      _currentOverlay!.remove();
      _currentOverlay = null;
      _isShowing = false;
    }
  }

  // عرض snackbar جديد
  static void _showNewSnackBar(
    BuildContext context,
    String message,
    _SnackBarConfig config,
    Duration duration,
  ) {
    // Guard: context might be detached from the tree if the screen was
    // navigated away from before the BlocListener callback fired.
    if (!context.mounted) return;

    final overlay = Overlay.of(context, rootOverlay: true);
    
    _currentOverlay = OverlayEntry(
      builder: (context) => _GlassmorphicSnackBar(
        message: message,
        config: config,
        duration: duration,
        onDismiss: () {
          _hideCurrentSnackBar();
        },
      ),
    );
    
    _isShowing = true;
    overlay.insert(_currentOverlay!);
  }

  // إخفاء جميع الـ snackbars (للاستخدام الخارجي)
  static void hideAll() {
    _hideCurrentSnackBar();
  }

  static _SnackBarConfig _getConfig(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return _SnackBarConfig(
          primaryColor: AppColors.success,
          softColor: AppColors.successSoft,
          icon: Icons.check_circle_rounded,
          glowIntensity: 0.6,
        );
      case SnackBarType.error:
        return _SnackBarConfig(
          primaryColor: AppColors.error,
          softColor: AppColors.errorSoft,
          icon: Icons.error_rounded,
          glowIntensity: 0.8,
        );
      case SnackBarType.warning:
        return _SnackBarConfig(
          primaryColor: AppColors.warning,
          softColor: AppColors.warningSoft,
          icon: Icons.warning_rounded,
          glowIntensity: 0.5,
        );
      case SnackBarType.info:
        return _SnackBarConfig(
          primaryColor: AppColors.info,
          softColor: AppColors.infoSoft,
          icon: Icons.info_rounded,
          glowIntensity: 0.4,
        );
      case SnackBarType.networkSlow:
        return _SnackBarConfig(
          primaryColor: AppColors.networkSlow,
          softColor: AppColors.networkSlowSoft,
          icon: Icons.signal_wifi_bad,
          glowIntensity: 0.5,
        );
    }
  }
}

class _SnackBarConfig {
  final Color primaryColor;
  final Color softColor;
  final IconData icon;
  final double glowIntensity;

  _SnackBarConfig({
    required this.primaryColor,
    required this.softColor,
    required this.icon,
    required this.glowIntensity,
  });
}

class _GlassmorphicSnackBar extends StatefulWidget {
  final String message;
  final _SnackBarConfig config;
  final Duration duration;
  final VoidCallback onDismiss;

  const _GlassmorphicSnackBar({
    required this.message,
    required this.config,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_GlassmorphicSnackBar> createState() => _GlassmorphicSnackBarState();
}

class _GlassmorphicSnackBarState extends State<_GlassmorphicSnackBar>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _glowController;
  late AnimationController _progressController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // أسرع قليلاً
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // أبطأ للنبض
    );

    _progressController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // Slide animation with smooth curve
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0), // أقل مبالغة
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic, // منحنى أنعم
    ));

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    // Scale animation with subtle bounce
    _scaleAnimation = Tween<double>(
      begin: 0.9, // أقل مبالغة
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    // Glow pulse animation
    _glowAnimation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Progress animation
    _progressAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.linear,
    ));

    // Start animations
    _slideController.forward();
    _glowController.repeat(reverse: true);
    _progressController.forward();

    // Auto dismiss
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _dismiss();
      }
    });
  }

  Future<void> _dismiss() async {
    _glowController.stop();
    _progressController.stop();
    
    // إخفاء سريع وناعم
    await _slideController.reverse();
    
    if (mounted) {
      widget.onDismiss();
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _glowController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Positioned(
      left: 16.w,
      right: 16.w,
      bottom: bottomPadding + 24.h,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: _GlassContainer(
              config: widget.config,
              glowAnimation: _glowAnimation,
              progressAnimation: _progressAnimation,
              onDismiss: _dismiss,
              child: _SnackBarContent(
                message: widget.message,
                config: widget.config,
                onDismiss: _dismiss,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassContainer extends StatelessWidget {
  final _SnackBarConfig config;
  final Animation<double> glowAnimation;
  final Animation<double> progressAnimation;
  final VoidCallback onDismiss;
  final Widget child;

  const _GlassContainer({
    required this.config,
    required this.glowAnimation,
    required this.progressAnimation,
    required this.onDismiss,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([glowAnimation, progressAnimation]),
      builder: (context, _) {
        return GestureDetector(
          onVerticalDragEnd: (details) {
            // سحب لأعلى للإخفاء (أقل حساسية)
            if (details.primaryVelocity! < -200) {
              onDismiss();
            }
          },
          onTap: () {
            // لمسة للإخفاء (اختياري)
            // onDismiss();
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                // Colored glow shadow
                BoxShadow(
                  color: config.primaryColor.withValues(
                    alpha: 0.3 * config.glowIntensity * glowAnimation.value,
                  ),
                  blurRadius: 24 * glowAnimation.value,
                  spreadRadius: 2 * glowAnimation.value,
                  offset: const Offset(0, 8),
                ),
                // Depth shadow
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
                // Subtle inner glow
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.1),
                  blurRadius: 1,
                  spreadRadius: 0,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.glassWhite,
                        AppColors.glassWhite.withValues(alpha: 0.8),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.glassBorder,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Stack(
                    children: [
                      // Progress indicator
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 3.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20.r),
                              bottomRight: Radius.circular(20.r),
                            ),
                          ),
                          child: LinearProgressIndicator(
                            value: progressAnimation.value,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              config.primaryColor.withValues(alpha: 0.6),
                            ),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20.r),
                              bottomRight: Radius.circular(20.r),
                            ),
                          ),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 16.h, 16.w, 19.h),
                        child: child,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SnackBarContent extends StatelessWidget {
  final String message;
  final _SnackBarConfig config;
  final VoidCallback onDismiss;

  const _SnackBarContent({
    required this.message,
    required this.config,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Animated icon with glassmorphic background
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      config.primaryColor.withValues(alpha: 0.2),
                      config.softColor.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: config.primaryColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  config.icon,
                  color: config.primaryColor,
                  size: 24.sp,
                ),
              ),
            );
          },
        ),
        SizedBox(width: 16.w),
        // Message text with clean styling
        Expanded(
          child: Material(
            color: Colors.transparent,
            textStyle: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              height: 1.4,
              letterSpacing: -0.2,
              decoration: TextDecoration.none,
              decorationColor: Colors.transparent,
            ),
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                height: 1.4,
                letterSpacing: -0.2,
                decoration: TextDecoration.none,
                decorationColor: Colors.transparent,
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        // Close button with glassmorphic effect
        GestureDetector(
          onTap: onDismiss,
          child: Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: AppColors.glassOverlay,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: AppColors.glassBorder,
                width: 1,
              ),
            ),
            child: Icon(
              Icons.close_rounded,
              color: AppColors.textSecondary,
              size: 18.sp,
            ),
          ),
        ),
      ],
    );
  }
}
