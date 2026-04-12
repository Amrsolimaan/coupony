import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routes/app_router.dart';
import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../features/auth/data/models/user_store_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MERCHANT REJECTED PAGE
//
// Shown when the customer's store has status 'rejected'.
// Matches screenshot 4: "تعذر استكمال تفعيل المتجر" with "عرض حالة الطلب".
// ─────────────────────────────────────────────────────────────────────────────

class MerchantRejectedPage extends StatelessWidget {
  final String storeId;
  final List<String> rejectionReasons;
  final UserStoreModel? store;

  const MerchantRejectedPage({
    super.key,
    required this.storeId,
    this.rejectionReasons = const [],
    this.store,
  });

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

            // ── Error icon ──────────────────────────────────────────────────
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cancel_outlined,
                size: 52.w,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: 40.h),

            // ── Headline ────────────────────────────────────────────────────
            Text(
              l10n.merchant_rejected_title,
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
              l10n.merchant_rejected_subtitle,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.7,
              ),
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            // ── View Status button ──────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54.h,
              child: ElevatedButton(
                onPressed: () => context.push(
                  AppRouter.merchantStatus,
                  extra: MerchantStatusArgs(
                    storeId: storeId,
                    reasons: rejectionReasons,
                    store: store,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _sellerColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  l10n.merchant_rejected_view_status_button,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
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

// ── Shared route args for MerchantStatusPage ──────────────────────────────────

class MerchantStatusArgs {
  final String storeId;
  final List<String> reasons;
  /// Full store snapshot — carried through so MerchantStatusPage can
  /// pre-fill CreateStoreScreen in edit mode.
  final UserStoreModel? store;

  const MerchantStatusArgs({
    required this.storeId,
    required this.reasons,
    this.store,
  });
}
