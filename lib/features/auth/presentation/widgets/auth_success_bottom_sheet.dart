import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/buttons/app_primary_button.dart';

class AuthSuccessBottomSheet extends StatefulWidget {
  final String title;
  final String buttonText;
  final VoidCallback onContinue;

  const AuthSuccessBottomSheet({
    super.key,
    required this.title,
    required this.buttonText,
    required this.onContinue,
  });

  @override
  State<AuthSuccessBottomSheet> createState() => _AuthSuccessBottomSheetState();
}

class _AuthSuccessBottomSheetState extends State<AuthSuccessBottomSheet>
    with TickerProviderStateMixin {
  late final AnimationController _circleCtrl;
  late final AnimationController _checkCtrl;
  late final AnimationController _burstCtrl; // Wave 1 — main burst
  late final AnimationController _burst2Ctrl; // Wave 2 — second shower
  late final AnimationController _burst3Ctrl; // Wave 3 — slow lingering drift
  late final AnimationController _pulseCtrl;
  late final AnimationController _shimmerCtrl;
  late final AnimationController _contentCtrl;
  late final AnimationController _repeatShimmerCtrl; // Repeating shimmer

  late final Animation<double> _circleScale;
  late final Animation<double> _checkProgress;
  late final Animation<double> _burstProgress;
  late final Animation<double> _burst2Progress;
  late final Animation<double> _burst3Progress;
  late final Animation<double> _pulseScale;
  late final Animation<double> _shimmerProgress;
  late final Animation<double> _repeatShimmerProgress;
  late final Animation<double> _contentOpacity;
  late final Animation<Offset> _contentSlide;

  late final List<_ConfettiParticle> _particles; // Wave 1
  late final List<_ConfettiParticle> _particles2; // Wave 2
  late final List<_ConfettiParticle> _particles3; // Wave 3 — floaters

  static const _extraColors = [
    Color(0xFFFF6B35),
    Color(0xFFFFD700),
    Color(0xFF4ECDC4),
    Color(0xFFFF6B9D),
    Color(0xFFFFE66D),
    Color(0xFF7C3AED),
    Color(0xFF34D399),
    Color(0xFFFBBF24),
    Color(0xFFEF4444),
    Color(0xFF06B6D4),
    Color(0xFFF97316),
    Color(0xFFEC4899),
  ];

  // ── Init ───────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _generateParticles();
    _initControllers();
    _runSequence();
  }

  void _generateParticles() {
    final rng = math.Random(42);

    // Wave 1 — 48 particles, sharp burst outward
    _particles = List.generate(48, (i) {
      final color = i % 3 == 0
          ? AppColors.primary
          : _extraColors[i % _extraColors.length];
      return _ConfettiParticle(
        angle: (i / 48) * 2 * math.pi + (rng.nextDouble() - .5) * .3,
        speed: .55 + rng.nextDouble() * .55,
        size: 3.5 + rng.nextDouble() * 6.0,
        color: color,
        shape: _ParticleShape.values[i % _ParticleShape.values.length],
        rotSpeed: (rng.nextDouble() - .5) * 12,
        initialRot: rng.nextDouble() * math.pi * 2,
        drift: (rng.nextDouble() - .5) * .06,
      );
    });

    // Wave 2 — 36 particles, slightly delayed, different angles
    _particles2 = List.generate(36, (i) {
      final color = _extraColors[(i + 3) % _extraColors.length];
      return _ConfettiParticle(
        angle: (i / 36) * 2 * math.pi + .09 + (rng.nextDouble() - .5) * .4,
        speed: .40 + rng.nextDouble() * .65,
        size: 3.0 + rng.nextDouble() * 5.0,
        color: color,
        shape: _ParticleShape.values[rng.nextInt(_ParticleShape.values.length)],
        rotSpeed: (rng.nextDouble() - .5) * 14,
        initialRot: rng.nextDouble() * math.pi * 2,
        drift: (rng.nextDouble() - .5) * .08,
      );
    });

    // Wave 3 — 24 slow floaters that linger and sway
    _particles3 = List.generate(24, (i) {
      final color = i % 2 == 0
          ? AppColors.primary
          : _extraColors[i % _extraColors.length];
      return _ConfettiParticle(
        angle: (i / 24) * 2 * math.pi + (rng.nextDouble() - .5) * .5,
        speed: .25 + rng.nextDouble() * .35,
        size: 4.0 + rng.nextDouble() * 4.5,
        color: color,
        shape: _ParticleShape.values[rng.nextInt(_ParticleShape.values.length)],
        rotSpeed: (rng.nextDouble() - .5) * 6,
        initialRot: rng.nextDouble() * math.pi * 2,
        drift: (rng.nextDouble() - .5) * .14,
      );
    });
  }

  void _initControllers() {
    // 1. Circle slams in
    _circleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _circleScale = CurvedAnimation(
      parent: _circleCtrl,
      curve: Curves.bounceOut,
    );

    // 2. Check draws fast
    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 230),
    );
    _checkProgress = CurvedAnimation(parent: _checkCtrl, curve: Curves.easeOut);

    // 3a. Wave 1 — 1100ms, easeOut
    _burstCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _burstProgress = CurvedAnimation(parent: _burstCtrl, curve: Curves.easeOut);

    // 3b. Wave 2 — 1400ms, delayed start
    _burst2Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _burst2Progress = CurvedAnimation(
      parent: _burst2Ctrl,
      curve: Curves.easeOut,
    );

    // 3c. Wave 3 — long slow floaters, 2800ms
    _burst3Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _burst3Progress = CurvedAnimation(
      parent: _burst3Ctrl,
      curve: Curves.easeOut,
    );

    // 4. Circle pulse
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _pulseScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.13), weight: 42),
      TweenSequenceItem(tween: Tween(begin: 1.13, end: 1.0), weight: 58),
    ]).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    // 5. One-shot shimmer
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _shimmerProgress = CurvedAnimation(
      parent: _shimmerCtrl,
      curve: Curves.easeInOut,
    );

    // 5b. Repeating shimmer — loops every 2.2s with a pause
    _repeatShimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _repeatShimmerProgress = CurvedAnimation(
      parent: _repeatShimmerCtrl,
      curve: const Interval(0.0, 0.35, curve: Curves.easeInOut),
    );

    // 6. Content slides up
    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _contentOpacity = CurvedAnimation(
      parent: _contentCtrl,
      curve: Curves.easeIn,
    );
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic),
        );
  }

  Future<void> _runSequence() async {
    await _circleCtrl.forward(); // t=0→420ms
    await Future.delayed(const Duration(milliseconds: 40));
    _checkCtrl.forward(); // t=460ms
    await Future.delayed(const Duration(milliseconds: 210));
    _burstCtrl.forward(); // t=670ms — Wave 1
    _pulseCtrl.forward();
    _shimmerCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 230));
    _burst2Ctrl.forward(); // t=900ms — Wave 2
    await Future.delayed(const Duration(milliseconds: 180));
    _contentCtrl.forward(); // t=1080ms
    await Future.delayed(const Duration(milliseconds: 320));
    _burst3Ctrl.forward(); // t=1400ms — Wave 3 slow floaters
    await Future.delayed(const Duration(milliseconds: 600));
    _repeatShimmerCtrl.repeat(); // t=2000ms — repeating shimmer
  }

  // ── Dispose ────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _circleCtrl.dispose();
    _checkCtrl.dispose();
    _burstCtrl.dispose();
    _burst2Ctrl.dispose();
    _burst3Ctrl.dispose();
    _pulseCtrl.dispose();
    _shimmerCtrl.dispose();
    _repeatShimmerCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          SystemNavigator.pop();
        }
      },
      child: SafeArea(
        child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadiusDirectional.only(
            topStart: Radius.circular(28.r),
            topEnd: Radius.circular(28.r),
          ),
        ),
        padding: EdgeInsetsDirectional.only(
          start: 24.w,
          end: 24.w,
          top: 12.h,
          bottom: 28.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // handle
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.textPrimary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 32.h),

            // ── Icon area ────────────────────────────────────────────────────
            AnimatedBuilder(
              animation: Listenable.merge([
                _circleCtrl,
                _checkCtrl,
                _burstCtrl,
                _burst2Ctrl,
                _burst3Ctrl,
                _pulseCtrl,
                _shimmerCtrl,
                _repeatShimmerCtrl,
              ]),
              builder: (_, __) {
                final sz = 180.w; // slightly bigger canvas for more spread
                return SizedBox(
                  width: sz,
                  height: sz,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Wave 3 — slow lingering floaters (behind everything)
                      CustomPaint(
                        size: Size(sz, sz),
                        painter: _ConfettiPainter(
                          particles: _particles3,
                          progress: _burst3Progress.value,
                          radiusMultiplier: 0.60,
                          gravityStrength: 18,
                          fadeStart: 0.70,
                        ),
                      ),
                      // Wave 1 — main burst
                      CustomPaint(
                        size: Size(sz, sz),
                        painter: _ConfettiPainter(
                          particles: _particles,
                          progress: _burstProgress.value,
                          radiusMultiplier: 0.56,
                          gravityStrength: 22,
                          fadeStart: 0.68,
                        ),
                      ),
                      // Wave 2 — secondary shower
                      CustomPaint(
                        size: Size(sz, sz),
                        painter: _ConfettiPainter(
                          particles: _particles2,
                          progress: _burst2Progress.value,
                          radiusMultiplier: 0.52,
                          gravityStrength: 25,
                          fadeStart: 0.65,
                        ),
                      ),
                      // Circle + shimmer + check
                      Transform.scale(
                        scale: _circleScale.value * _pulseScale.value,
                        child: _CircleCore(
                          size: 82.w,
                          shimmerProgress: _shimmerProgress.value,
                          repeatShimmerProgress: _repeatShimmerProgress.value,
                          checkProgress: _checkProgress.value,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            SizedBox(height: 20.h),

            // ── Content ──────────────────────────────────────────────────────
            SlideTransition(
              position: _contentSlide,
              child: FadeTransition(
                opacity: _contentOpacity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontFamily: AppTextStyles.Main_Font_arabic,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.h),
                    AppPrimaryButton(
                      text: widget.buttonText,
                      onPressed: widget.onContinue,
                      height: 52.h,
                      backgroundColor: AppColors.primary,
                      textStyle: TextStyle(
                        fontFamily: AppTextStyles.Main_Font_arabic,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.surface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CIRCLE CORE
// ─────────────────────────────────────────────────────────────────────────────

class _CircleCore extends StatelessWidget {
  final double size;
  final double shimmerProgress;
  final double repeatShimmerProgress;
  final double checkProgress;

  const _CircleCore({
    required this.size,
    required this.shimmerProgress,
    required this.repeatShimmerProgress,
    required this.checkProgress,
  });

  @override
  Widget build(BuildContext context) {
    // Blend one-shot shimmer with the repeating one
    final effectiveShimmer = shimmerProgress > 0 && shimmerProgress < 1
        ? shimmerProgress
        : repeatShimmerProgress;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  Color.lerp(AppColors.primary, Colors.black, 0.22)!,
                ],
              ),
            ),
          ),
          if (effectiveShimmer > 0 && effectiveShimmer < 1)
            ClipOval(
              child: CustomPaint(
                size: Size(size, size),
                painter: _ShimmerPainter(progress: effectiveShimmer),
              ),
            ),
          CustomPaint(
            size: Size(size, size),
            painter: _CheckPainter(
              progress: checkProgress,
              color: AppColors.surface,
              strokeWidth: 3.8.w,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHIMMER PAINTER
// ─────────────────────────────────────────────────────────────────────────────

class _ShimmerPainter extends CustomPainter {
  final double progress;
  const _ShimmerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width * (progress * 1.8 - 0.4);
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withOpacity(0),
          Colors.white.withOpacity(0.30),
          Colors.white.withOpacity(0),
        ],
        stops: const [0, .5, 1],
      ).createShader(Rect.fromLTWH(x - 36, 0, 72, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_ShimmerPainter o) => o.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// CONFETTI
// ─────────────────────────────────────────────────────────────────────────────

enum _ParticleShape { square, circle, triangle, star }

class _ConfettiParticle {
  final double angle, speed, size, rotSpeed, initialRot, drift;
  final Color color;
  final _ParticleShape shape;

  const _ConfettiParticle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
    required this.shape,
    required this.rotSpeed,
    required this.initialRot,
    required this.drift,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;
  final double radiusMultiplier;
  final double gravityStrength;
  final double fadeStart; // opacity starts dropping after this progress value

  const _ConfettiPainter({
    required this.particles,
    required this.progress,
    this.radiusMultiplier = 0.54,
    this.gravityStrength = 22,
    this.fadeStart = 0.65,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxR = size.width * radiusMultiplier;
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      final t = (progress * p.speed).clamp(0.0, 1.0);
      final dist = maxR * t;
      final grav = gravityStrength * progress * progress;
      // lateral drift adds a swaying feel
      final sway =
          math.sin(progress * math.pi * 2.5 + p.initialRot) * dist * p.drift;
      final x = cx + math.cos(p.angle) * dist + sway;
      final y = cy + math.sin(p.angle) * dist + grav;

      // Smooth fade starting at fadeStart
      final op = progress < fadeStart
          ? 1.0
          : (1.0 - progress) / (1.0 - fadeStart);

      paint.color = p.color.withOpacity(op.clamp(0.0, 1.0));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.initialRot + p.rotSpeed * progress);
      _drawShape(canvas, paint, p.shape, p.size);
      canvas.restore();
    }
  }

  void _drawShape(
    Canvas canvas,
    Paint paint,
    _ParticleShape shape,
    double size,
  ) {
    final half = size / 2;
    switch (shape) {
      case _ParticleShape.square:
        canvas.drawRect(Rect.fromLTWH(-half, -half, size, size), paint);
      case _ParticleShape.circle:
        canvas.drawCircle(Offset.zero, half, paint);
      case _ParticleShape.triangle:
        final path = Path()
          ..moveTo(0, -half)
          ..lineTo(half, half)
          ..lineTo(-half, half)
          ..close();
        canvas.drawPath(path, paint);
      case _ParticleShape.star:
        _drawStar(canvas, paint, half);
    }
  }

  void _drawStar(Canvas canvas, Paint paint, double r) {
    const points = 5;
    const innerRatio = 0.42;
    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final angle = (math.pi / points) * i - math.pi / 2;
      final radius = i.isEven ? r : r * innerRatio;
      final x = math.cos(angle) * radius;
      final y = math.sin(angle) * radius;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ConfettiPainter o) => o.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// CHECK PAINTER
// ─────────────────────────────────────────────────────────────────────────────

class _CheckPainter extends CustomPainter {
  final double progress, strokeWidth;
  final Color color;

  const _CheckPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final p1 = Offset(size.width * .26, size.height * .50);
    final p2 = Offset(size.width * .44, size.height * .66);
    final p3 = Offset(size.width * .74, size.height * .36);

    final seg1 = (p2 - p1).distance;
    final seg2 = (p3 - p2).distance;
    final drawn = (seg1 + seg2) * progress;

    final path = Path()..moveTo(p1.dx, p1.dy);
    if (drawn <= seg1) {
      final t = drawn / seg1;
      path.lineTo(p1.dx + (p2.dx - p1.dx) * t, p1.dy + (p2.dy - p1.dy) * t);
    } else {
      final t = math.min((drawn - seg1) / seg2, 1.0);
      path
        ..lineTo(p2.dx, p2.dy)
        ..lineTo(p2.dx + (p3.dx - p2.dx) * t, p2.dy + (p3.dy - p2.dy) * t);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter o) => o.progress != progress;
}
