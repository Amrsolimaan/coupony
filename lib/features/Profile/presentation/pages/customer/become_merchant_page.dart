import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routes/app_router.dart';
import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../features/seller_flow/CreateStore/presentation/pages/create_store_screen.dart'
    show CreateStoreArgs;

// ─────────────────────────────────────────────────────────────────────────────
// BECOME MERCHANT PAGE
//
// Screen 1 of the merchant registration flow.
// Shown when the customer taps "كن تاجراً" and has no existing store.
// ─────────────────────────────────────────────────────────────────────────────

/// Route args for [BecomeMerchantPage].
/// [onStoreCreated] is called (before navigation) when the store is
/// successfully created so the caller can refresh its state.
class BecomeMerchantArgs {
  final VoidCallback? onStoreCreated;
  const BecomeMerchantArgs({this.onStoreCreated});
}

class BecomeMerchantPage extends StatelessWidget {
  const BecomeMerchantPage({super.key, this.onStoreCreated});

  final VoidCallback? onStoreCreated;

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

            // ── Store illustration ──────────────────────────────────────────
            _StoreIllustration(),
            SizedBox(height: 40.h),

            // ── Headline ────────────────────────────────────────────────────
            Text(
              l10n.become_merchant_headline,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: _sellerColor,
                height: 1.3,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),

            // ── Subtitle ────────────────────────────────────────────────────
            Text(
              l10n.become_merchant_subtitle,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.7,
              ),
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            // ── Create Store CTA ────────────────────────────────────────────
            _SellerPrimaryButton(
              label: l10n.become_merchant_button,
              onPressed: () => context.push(
                AppRouter.createStore,
                extra: CreateStoreArgs(
                  onSuccess: () {
                    if (context.mounted) {
                      onStoreCreated?.call();
                      context.go(AppRouter.merchantPending);
                    }
                  },
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

// ── Store Illustration ────────────────────────────────────────────────────────

class _StoreIllustration extends StatelessWidget {
  static const _sellerColor = AppColors.primaryOfSeller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180.w,
      height: 180.w,
      decoration: BoxDecoration(
        color: _sellerColor.withValues(alpha: 0.07),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.storefront_rounded,
        size: 90.w,
        color: _sellerColor,
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

  static const _sellerColor = AppColors.primaryOfSeller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _sellerColor,
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
