import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routes/app_router.dart';
import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../features/seller_flow/CreateStore/presentation/pages/create_store_screen.dart'
    show CreateStoreMode, CreateStoreArgs;

// ─────────────────────────────────────────────────────────────────────────────
// MERCHANT INCOMPLETE PAGE
//
// Shown when the customer's store has status 'incomplete'.
// Matches screenshot: "يرجى استكمال بيانات متجرك" with "استكمال البيانات" button.
// ─────────────────────────────────────────────────────────────────────────────

class MerchantIncompletePage extends StatelessWidget {
  final String storeId;

  const MerchantIncompletePage({super.key, required this.storeId});

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

            // ── Warning icon ────────────────────────────────────────────────
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assignment_late_outlined,
                size: 52.w,
                color: Colors.orange.shade700,
              ),
            ),
            SizedBox(height: 40.h),

            // ── Headline ────────────────────────────────────────────────────
            Text(
              l10n.merchant_incomplete_title,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.3,
                letterSpacing: -0.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 14.h),

            // ── Subtitle ────────────────────────────────────────────────────
            Text(
              l10n.merchant_incomplete_subtitle,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.7,
              ),
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            // ── Complete Data button ────────────────────────────────────────
            _SellerPrimaryButton(
              label: l10n.merchant_incomplete_button,
              onPressed: () => context.push(
                AppRouter.createStore,
                extra: CreateStoreArgs(
                  mode: CreateStoreMode.edit,
                  storeId: storeId,
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // ── Contact footnote ────────────────────────────────────────────
            _ContactFootnote(l10n: l10n),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}

// ── Seller Primary Button ─────────────────────────────────────────────────────

class _SellerPrimaryButton extends StatelessWidget {
  const _SellerPrimaryButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryOfSeller,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.customStyle(
            context,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ── Contact footnote ──────────────────────────────────────────────────────────

class _ContactFootnote extends StatelessWidget {
  const _ContactFootnote({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.merchant_review_contact_prompt,
          style: TextStyle(
            fontSize: 13.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(width: 4.w),
        GestureDetector(
          onTap: () {/* navigate to contact support */},
          child: Text(
            l10n.merchant_review_contact_link,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.primaryOfSeller,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primaryOfSeller,
            ),
          ),
        ),
      ],
    );
  }
}

