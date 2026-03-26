import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';

enum SnackBarType { success, error, warning, info }

class AppSnackBar {
  AppSnackBar._();

  static void show(
    BuildContext context, {
    required String message,
    required SnackBarType type,
    Duration duration = const Duration(seconds: 3),
  }) {
    final config = _getConfig(type);
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => _AnimatedSnackBar(
        message: message,
        config: config,
        duration: duration,
        onDismiss: () => overlayEntry.remove(),
      ),
    );
    
    overlay.insert(overlayEntry);
  }

  static _SnackBarConfig _getConfig(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return _SnackBarConfig(
          backgroundColor: AppColors.success,
          icon: Icons.check_circle_rounded,
          iconColor: Colors.white,
          textColor: Colors.white,
        );
      case SnackBarType.error:
        return _SnackBarConfig(
          backgroundColor: AppColors.error,
          icon: Icons.error_rounded,
          iconColor: Colors.white,
          textColor: Colors.white,
        );
      case SnackBarType.warning:
        return _SnackBarConfig(
          backgroundColor: AppColors.warning,
          icon: Icons.warning_rounded,
          iconColor: const Color(0xFF1A1A1A),
          textColor: const Color(0xFF1A1A1A),
        );
      case SnackBarType.info:
        return _SnackBarConfig(
          backgroundColor: AppColors.info,
          icon: Icons.info_rounded,
          iconColor: Colors.white,
          textColor: Colors.white,
        );
    }
  }
}

class _SnackBarConfig {
  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;
  final Color textColor;

  _SnackBarConfig({
    required this.backgroundColor,
    required this.icon,
    required this.iconColor,
    required this.textColor,
  });
}

class _AnimatedSnackBar extends StatefulWidget {
  final String message;
  final _SnackBarConfig config;
  final Duration duration;
  final VoidCallback onDismiss;

  const _AnimatedSnackBar({
    required this.message,
    required this.config,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_AnimatedSnackBar> createState() => _AnimatedSnackBarState();
}

class _AnimatedSnackBarState extends State<_AnimatedSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Positioned(
      left: 20.w,
      right: 20.w,
      bottom: bottomPadding + 20.h,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity! < -500) {
                    _dismiss();
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    color: widget.config.backgroundColor,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: widget.config.backgroundColor.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Icon with pulse animation
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                widget.config.icon,
                                color: widget.config.iconColor,
                                size: 24.sp,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(width: 12.w),
                      // Message
                      Expanded(
                        child: Text(
                          widget.message,
                          style: TextStyle(
                            color: widget.config.textColor,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // Close button
                      GestureDetector(
                        onTap: _dismiss,
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: widget.config.iconColor,
                            size: 18.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
