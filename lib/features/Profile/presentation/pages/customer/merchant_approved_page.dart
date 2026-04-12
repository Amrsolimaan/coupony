import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routes/app_router.dart';
import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../auth/presentation/cubit/auth_role_cubit.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MERCHANT APPROVED PAGE
//
// Shown when the customer's store has status 'active' and they tap
// "كن تاجراً" from the profile menu. A success confirmation screen
// with a CTA to go to the merchant dashboard.
// ─────────────────────────────────────────────────────────────────────────────

class MerchantApprovedPage extends StatelessWidget {
  const MerchantApprovedPage({super.key});

  static const _sellerColor = AppColors.primaryOfSeller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context, l10n),
      body: _buildBody(context, l10n),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Text(
        l10n.become_merchant_title,
        style: AppTextStyles.customStyle(
          context,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _sellerColor,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: _sellerColor,
          size: 20.w,
        ),
        onPressed: () => context.pop(),
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────
  Widget _buildBody(BuildContext context, AppLocalizations l10n) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // ── Success icon ────────────────────────────────────────────────
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                size: 64.w,
                color: Colors.green.shade600,
              ),
            ),
            SizedBox(height: 40.h),

            // ── Headline ────────────────────────────────────────────────────
            Text(
              l10n.merchant_approved_headline,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.3,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),

            // ── Subtitle ────────────────────────────────────────────────────
            Text(
              l10n.merchant_approved_subtitle,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.7,
              ),
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            // ── Switch to Merchant button ───────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54.h,
              child: ElevatedButton(
                onPressed: () {
                  // Switch role and navigate to seller dashboard
                  context.read<AuthRoleCubit>().setRole('seller');
                  context.go(AppRouter.sellerWelcome);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _sellerColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  l10n.merchant_approved_switch_button,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // ── Continue as Customer button ─────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54.h,
              child: OutlinedButton(
                onPressed: () => context.go(AppRouter.customerProfile),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _sellerColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  l10n.merchant_approved_continue_button,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _sellerColor,
                  ),
                ),
              ),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}
