import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HOME SEARCH BAR
// White pill-shaped search field.
// RTL: mic on physical LEFT (END), search icon on physical RIGHT (START).
// ─────────────────────────────────────────────────────────────────────────────

class HomeSearchBarWidget extends StatelessWidget {
  final VoidCallback? onMicTap;
  final VoidCallback? onTap;

  const HomeSearchBarWidget({super.key, this.onMicTap, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Skeleton.leaf(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 46.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Physical RIGHT (RTL start) ── Search icon
                SizedBox(width: 12.w),
                Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                  size: 20.w,
                ),
                SizedBox(width: 8.w),

                // Hint text
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.home_search_hint,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                  ),
                ),

                // Physical LEFT (RTL end) ── Mic button
                GestureDetector(
                  onTap: onMicTap,
                  child: Container(
                    width: 34.w,
                    height: 34.w,
                    margin: EdgeInsets.only(left: 6.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.mic_rounded,
                      color: AppColors.primary,
                      size: 20.w,
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
