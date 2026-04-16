import 'dart:async';

import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HOME COUNTDOWN WIDGET
// "Promo on Going" label on the right + live countdown boxes on the left.
// Uses StatefulWidget with a Timer — no Cubit needed.
// ─────────────────────────────────────────────────────────────────────────────

class HomeCountdownWidget extends StatefulWidget {
  final DateTime endTime;

  const HomeCountdownWidget({super.key, required this.endTime});

  @override
  State<HomeCountdownWidget> createState() => _HomeCountdownWidgetState();
}

class _HomeCountdownWidgetState extends State<HomeCountdownWidget> {
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = _computeRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining = _computeRemaining());
    });
  }

  Duration _computeRemaining() {
    final diff = widget.endTime.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = _remaining.inDays;
    final h = _remaining.inHours % 24;
    final m = _remaining.inMinutes % 60;
    final s = _remaining.inSeconds % 60;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Physical RIGHT (RTL start) ── label
          Skeleton.ignore(
            child: Text(
              AppLocalizations.of(context)!.home_promo_on_going,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // Physical LEFT (RTL end) ── countdown boxes
          Skeleton.leaf(
            child: Row(
              children: [
                _CountBox(value: d),
                _Separator(),
                _CountBox(value: h),
                _Separator(),
                _CountBox(value: m),
                _Separator(),
                _CountBox(value: s),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CountBox extends StatelessWidget {
  final int value;

  const _CountBox({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(7.r),
      ),
      alignment: Alignment.center,
      child: Text(
        value.toString().padLeft(2, '0'),
        style: AppTextStyles.customStyle(
          context,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: Text(
        ':',
        style: AppTextStyles.customStyle(
          context,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
