import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../../config/routes/app_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GUEST SELLER VIEW WIDGET (Content only - no Scaffold, no bottom bar)
// ─────────────────────────────────────────────────────────────────────────────

class GuestSellerViewWidget extends StatelessWidget {
  final IconData icon;

  const GuestSellerViewWidget({
    super.key,
    this.icon = FontAwesomeIcons.store,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Column(
      children: [
        // ── Top Bar ──────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button on the left (LTR) or right (RTL)
                if (!isRTL)
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12.r),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12.r),
                      onTap: () => context.go(AppRouter.login),
                      child: Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20.w,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                
                // Title and Icon together
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isRTL) ...[
                      // LTR: Icon first, then text
                      CircleAvatar(
                        radius: 20.r,
                        backgroundColor: AppColors.grey200,
                        child: SvgPicture.asset(
                          'assets/icons/ghost.svg',
                          width: 24.w,
                          height: 24.w,
                          colorFilter: ColorFilter.mode(
                            AppColors.textSecondary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        l10n.guest_seller_mode_title,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ] else ...[
                      // RTL: Text first, then icon
                      Text(
                        l10n.guest_seller_mode_title,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      CircleAvatar(
                        radius: 20.r,
                        backgroundColor: AppColors.grey200,
                        child: SvgPicture.asset(
                          'assets/icons/ghost.svg',
                          width: 24.w,
                          height: 24.w,
                          colorFilter: ColorFilter.mode(
                            AppColors.textSecondary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                
                // Back button on the right (RTL) or left (LTR)
                if (isRTL)
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12.r),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12.r),
                      onTap: () => context.go(AppRouter.login),
                      child: Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 20.w,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(width: 40.w), // Balance for LTR
              ],
            ),
          ),
        ),

        // ── Content ──────────────────────────────────────────────────
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    color: AppColors.primaryOfSeller.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: FaIcon(
                      icon,
                      size: 48.sp,
                      color: AppColors.primaryOfSeller,
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
                Text(
                  l10n.guest_seller_welcome_title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  l10n.guest_seller_welcome_subtitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
                SizedBox(height: 32.h),
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: () => context.go(AppRouter.login),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOfSeller,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      l10n.guest_seller_login_button,
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
