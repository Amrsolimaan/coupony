import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';

/// Coupony Loading Indicator
///
/// A beautiful, reusable loading widget with:
/// - Circular progress with gradient
/// - Smooth rotation animation
/// - Pulse effect for center icon
/// - Fade transitions for messages
/// - Optimized performance with RepaintBoundary
class CouponyLoadingIndicator extends StatefulWidget {
  /// Progress value from 0.0 to 1.0
  final double progress;

  /// Size of the circular indicator
  final double size;

  /// Primary color for gradient (defaults to AppColors.primary)
  final Color? primaryColor;

  /// Secondary color for gradient (defaults to lighter primary)
  final Color? secondaryColor;

  /// Center icon (defaults to check_circle_outline)
  final IconData? centerIcon;

  /// Show percentage text
  final bool showPercentage;

  /// Optional message below the indicator
  final String? message;

  /// Stroke width of the circular progress
  final double strokeWidth;

  /// Animation duration
  final Duration animationDuration;

  const CouponyLoadingIndicator({
    super.key,
    this.progress = 0.0,
    this.size = 120.0,
    this.primaryColor,
    this.secondaryColor,
    this.centerIcon,
    this.showPercentage = true,
    this.message,
    this.strokeWidth = 8.0,
    this.animationDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<CouponyLoadingIndicator> createState() =>
      _CouponyLoadingIndicatorState();
}

class _CouponyLoadingIndicatorState extends State<CouponyLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;

  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Rotation Animation (continuous)
    _rotationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    // Pulse Animation (for center icon)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Fade Animation (for message)
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CouponyLoadingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Restart fade animation when message changes
    if (oldWidget.message != widget.message) {
      _fadeController.reset();
      _fadeController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.primaryColor ?? AppColors.primary;
    final secondaryColor = widget.secondaryColor ??
        Color.lerp(primaryColor, Colors.white, 0.3)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Circular Progress with Animations
        RepaintBoundary(
          child: SizedBox(
            width: widget.size.w,
            height: widget.size.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Rotating Gradient Circle
                AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: CustomPaint(
                        size: Size(widget.size.w, widget.size.w),
                        painter: CircularProgressPainter(
                          progress: widget.progress,
                          strokeWidth: widget.strokeWidth.w,
                          gradientColors: [primaryColor, secondaryColor],
                          backgroundColor: AppColors.grey200,
                        ),
                      ),
                    );
                  },
                ),

                // Center Icon with Pulse Effect
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Icon(
                        widget.centerIcon ?? Icons.check_circle_outline,
                        size: (widget.size * 0.35).w,
                        color: primaryColor,
                      ),
                    );
                  },
                ),

                // Percentage Text (if enabled)
                if (widget.showPercentage)
                  Positioned(
                    bottom: (widget.size * 0.15).h,
                    child: Text(
                      '${(widget.progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: (widget.size * 0.12).sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Message with Fade Animation
        if (widget.message != null) ...[
          SizedBox(height: 16.h),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              widget.message!,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }
}

/// Custom Painter for Circular Progress with Gradient
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final List<Color> gradientColors;
  final Color backgroundColor;

  CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.gradientColors,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc with gradient
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);

      final gradientPaint = Paint()
        ..shader = SweepGradient(
          colors: gradientColors,
          startAngle: 0.0,
          endAngle: 2 * math.pi,
        ).createShader(rect)
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      // Draw arc from top (270 degrees) clockwise
      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        rect,
        -math.pi / 2, // Start from top
        sweepAngle,
        false,
        gradientPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gradientColors != gradientColors ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
