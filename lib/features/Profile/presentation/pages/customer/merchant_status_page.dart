import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routes/app_router.dart';
import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../features/auth/data/models/user_store_model.dart'
    show UserStoreModel;
import '../../../../../features/seller_flow/CreateStore/presentation/pages/create_store_screen.dart'
    show CreateStoreArgs, CreateStoreMode;
import 'merchant_rejected_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MERCHANT STATUS PAGE
//
// Shows the list of rejection reasons from the review team.
// Matches screenshots 1-3: "حالة الطلب" / "نحتاج بعض التعديلات" with
// "تعديل البيانات" and "تواصل مع الدعم" buttons.
// ─────────────────────────────────────────────────────────────────────────────

class MerchantStatusPage extends StatelessWidget {
  final MerchantStatusArgs args;

  const MerchantStatusPage({super.key, required this.args});

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
        l10n.merchant_status_title,
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
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header card ─────────────────────────────────────────────────
            _HeaderCard(l10n: l10n),
            SizedBox(height: 24.h),

            // ── Rejection reason (single or list) ───────────────────────────
            if (args.reasons.isNotEmpty) ...[
              ...args.reasons.map((reason) => _ReasonTile(reason: reason)),
              SizedBox(height: 24.h),
            ] else if (args.store?.rejectionReason != null) ...[
              _ReasonTile(reason: args.store!.rejectionReason!),
              SizedBox(height: 24.h),
            ],

            const Spacer(),

            // ── Edit Data button ─────────────────────────────────────────────
            _SellerPrimaryButton(
              label: l10n.merchant_status_edit_button,
              onPressed: () => context.push(
                AppRouter.createStore,
                extra: CreateStoreArgs(
                  mode: CreateStoreMode.edit,
                  storeId: args.storeId,
                  initialStore: args.store,
                  onSuccess: () {
                    if (context.mounted) context.go(AppRouter.merchantPending);
                  },
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // ── Contact Support button ───────────────────────────────────────
            _SellerOutlinedButton(
              label: l10n.merchant_status_support_button,
              onPressed: () => context.push(AppRouter.contactUsPage),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}

// ── Header card ───────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.l10n});

  final AppLocalizations l10n;
  static const _sellerColor = AppColors.primaryOfSeller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: _sellerColor.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: _sellerColor.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            l10n.merchant_status_headline,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.merchant_status_subtitle,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Reason tile ───────────────────────────────────────────────────────────────

class _ReasonTile extends StatelessWidget {
  const _ReasonTile({required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exclamation icon
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.info_outline_rounded,
              size: 16.w,
              color: AppColors.error,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                reason,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Buttons ───────────────────────────────────────────────────────────────────

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

class _SellerOutlinedButton extends StatelessWidget {
  const _SellerOutlinedButton({
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
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primaryOfSeller, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.customStyle(
            context,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryOfSeller,
          ),
        ),
      ),
    );
  }
}

