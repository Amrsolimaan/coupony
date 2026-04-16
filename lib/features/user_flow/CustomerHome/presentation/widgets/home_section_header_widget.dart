import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HOME SECTION HEADER (reusable)
// Title on the right (RTL start) + "عرض الكل" on the left (RTL end).
// ─────────────────────────────────────────────────────────────────────────────

class HomeSectionHeaderWidget extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const HomeSectionHeaderWidget({
    super.key,
    required this.title,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Skeleton.ignore(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Physical RIGHT (RTL start) ── title
            Text(
              title,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            // Physical LEFT (RTL end) ── see all
            GestureDetector(
              onTap: onSeeAll,
              child: Text(
                AppLocalizations.of(context)!.home_see_all,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
