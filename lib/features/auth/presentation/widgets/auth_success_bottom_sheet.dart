import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/buttons/app_primary_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AUTH SUCCESS BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────

class AuthSuccessBottomSheet extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadiusDirectional.only(
            topStart: Radius.circular(24.r),
            topEnd: Radius.circular(24.r),
          ),
        ),
        padding: EdgeInsetsDirectional.only(
          start: 24.w,
          end: 24.w,
          top: 40.h,
          bottom: 32.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SuccessIcon(),
            SizedBox(height: 24.h),
            Text(
              title,
              style: TextStyle(
                fontFamily: AppTextStyles.Main_Font_arabic,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            AppPrimaryButton(
              text: buttonText,
              onPressed: onContinue,
              height: 56.h,
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUCCESS ICON WITH RANDOM SCATTERED DOTS
// ─────────────────────────────────────────────────────────────────────────────

class _SuccessIcon extends StatelessWidget {
  const _SuccessIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200.w,
      height: 200.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ..._buildScatteredDots(),
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              size: 56.w,
              color: AppColors.surface,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildScatteredDots() {
    // [x, y, size] — container is 200×200, center (100,100)
    // Positions hand-tuned to match the organic scattered reference image.
    // Dots are NOT on a uniform ring — distances and sizes vary intentionally.
    final dots = [
      // ── top-left cluster ──────────────────────────────────────────────────
      [28.0,  18.0,  5.0],
      [44.0,   8.0, 10.0],
      [62.0,   4.0,  4.0],
      [18.0,  40.0,  8.0],

      // ── top center ────────────────────────────────────────────────────────
      [82.0,  10.0,  6.0],
      [100.0,  2.0, 12.0],
      [118.0,  8.0,  5.0],

      // ── top-right cluster ─────────────────────────────────────────────────
      [140.0,  5.0,  9.0],
      [158.0, 16.0,  4.0],
      [172.0, 32.0, 11.0],

      // ── right side ────────────────────────────────────────────────────────
      [186.0, 56.0,  6.0],
      [192.0, 78.0, 10.0],
      [188.0,100.0,  4.0],
      [191.0,122.0,  8.0],
      [180.0,144.0,  5.0],

      // ── bottom-right cluster ──────────────────────────────────────────────
      [164.0,162.0, 11.0],
      [144.0,176.0,  5.0],
      [124.0,185.0,  8.0],

      // ── bottom center ─────────────────────────────────────────────────────
      [100.0,192.0,  4.0],
      [78.0, 186.0, 10.0],

      // ── bottom-left cluster ───────────────────────────────────────────────
      [56.0, 178.0,  6.0],
      [36.0, 164.0, 12.0],
      [18.0, 148.0,  4.0],

      // ── left side ─────────────────────────────────────────────────────────
      [8.0,  126.0,  9.0],
      [4.0,  102.0,  5.0],
      [10.0,  78.0, 11.0],
      [6.0,   56.0,  4.0],

      // ── extra mid-distance fill (breaks the ring feeling) ─────────────────
      [52.0,  28.0,  4.0],
      [152.0, 52.0,  4.0],
      [38.0, 150.0,  5.0],
      [158.0,148.0,  4.0],
    ];

    return dots.map((d) {
      final x = d[0];
      final y = d[1];
      final s = d[2];
      return Positioned(
        left: x.w - (s / 2).w,
        top: y.w - (s / 2).w,
        child: Container(
          width: s.w,
          height: s.w,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
        ),
      );
    }).toList();
  }
}