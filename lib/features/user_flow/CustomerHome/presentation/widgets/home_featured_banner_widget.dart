import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HOME FEATURED BANNER (البحر الأحمر style)
// Full-width coloured card with title, subtitle, and CTA button.
// ─────────────────────────────────────────────────────────────────────────────

class HomeFeaturedBannerWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String ctaLabel;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const HomeFeaturedBannerWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    this.backgroundColor = const Color(0xFF1A1A2E),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Skeleton.leaf(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16.r),
              gradient: LinearGradient(
                colors: [
                  backgroundColor,
                  backgroundColor.withValues(alpha: 0.80),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Physical RIGHT (RTL start) ── text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        subtitle,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 12.h),
                      GestureDetector(
                        onTap: onTap,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 7.h),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            ctaLabel,
                            style: AppTextStyles.customStyle(
                              context,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Physical LEFT (RTL end) ── decorative icon
                Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: Icon(
                    Icons.waves_rounded,
                    color: Colors.white.withValues(alpha: 0.20),
                    size: 60.w,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
