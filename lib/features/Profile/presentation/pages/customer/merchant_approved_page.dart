import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/dependency_injection/injection_container.dart' as di;
import '../../../../../config/routes/app_router.dart';
import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../auth/data/datasources/auth_local_data_source.dart';
import '../../../../auth/domain/entities/user_persona.dart';
import '../../../../auth/presentation/cubit/persona_cubit.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MERCHANT APPROVED PAGE
//
// Shown when the customer's store has status 'active' and they tap
// "كن تاجراً" from the profile menu. A success confirmation screen
// with a CTA to go to the merchant dashboard.
//
// ✅ UPDATED: Now saves selectedStoreId and navigates to seller_store_page
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
    return BlocBuilder<PersonaCubit, UserPersona>(
      builder: (context, persona) {
        final isSeller = persona is SellerPersona;

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

                // ── Primary Button (Different for Seller vs Customer) ──────────
                SizedBox(
                  width: double.infinity,
                  height: 54.h,
                  child: ElevatedButton(
                    onPressed: () => _handlePrimaryAction(context, isSeller),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _sellerColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      isSeller
                          ? 'متابعة' // Continue/Proceed for seller
                          : l10n.merchant_approved_switch_button, // Switch to Merchant for customer
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                // ── Secondary Button (Only for Customer) ───────────────────────
                if (!isSeller) ...[
                  SizedBox(height: 12.h),
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
                ],
                
                SizedBox(height: 32.h),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Handle Primary Action ─────────────────────────────────────────────────
  /// Handles the primary button press based on current role.
  /// - For Seller: Just navigate to seller_store_page (no role change)
  /// - For Customer: Switch role to seller and navigate
  Future<void> _handlePrimaryAction(BuildContext context, bool isSeller) async {
    if (isSeller) {
      // Seller is already in seller mode, just navigate
      await _navigateToSellerStore(context);
    } else {
      // Customer needs to switch to seller first
      await _handleSwitchToMerchant(context);
    }
  }

  // ── Navigate to Seller Store ──────────────────────────────────────────────
  Future<void> _navigateToSellerStore(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(
            color: _sellerColor,
            strokeWidth: 3.w,
          ),
        ),
      );

      // Get cached stores
      final authLocalDs = di.sl<AuthLocalDataSource>();
      final stores = await authLocalDs.getCachedStores();

      if (stores.isEmpty) {
        if (context.mounted) {
          Navigator.of(context).pop(); // Close loading
          _showErrorSnackBar(
            context,
            'لم يتم العثور على متجر. يرجى المحاولة مرة أخرى.',
          );
        }
        return;
      }

      // Save the first store's ID
      await authLocalDs.saveSelectedStoreId(stores.first.id);

      if (!context.mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      // Navigate to seller store page
      context.go(
        AppRouter.sellerStore,
        extra: {
          'isGuest': false,
          'isPending': false,
        },
      );
    } catch (e) {
      if (!context.mounted) return;

      // Close loading dialog if still open
      Navigator.of(context).pop();

      // Show error message
      _showErrorSnackBar(
        context,
        'حدث خطأ أثناء التحويل. يرجى المحاولة مرة أخرى.',
      );
    }
  }

  // ── Handle Switch to Merchant ──────────────────────────────────────────────
  /// Handles the "Switch to Merchant" button press for CUSTOMER role.
  /// 
  /// This method:
  /// 1. Gets the cached stores from local storage
  /// 2. Saves the first store's ID as selectedStoreId (first-time approval = one store)
  /// 3. Switches the user role to 'seller'
  /// 4. Navigates to seller_store_page
  Future<void> _handleSwitchToMerchant(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(
            color: _sellerColor,
            strokeWidth: 3.w,
          ),
        ),
      );

      // Get cached stores
      final authLocalDs = di.sl<AuthLocalDataSource>();
      final stores = await authLocalDs.getCachedStores();

      if (stores.isEmpty) {
        // This shouldn't happen, but handle it gracefully
        if (context.mounted) {
          Navigator.of(context).pop(); // Close loading
          _showErrorSnackBar(
            context,
            'لم يتم العثور على متجر. يرجى المحاولة مرة أخرى.',
          );
        }
        return;
      }

      // Save the first store's ID (first-time approval = one store only)
      await authLocalDs.saveSelectedStoreId(stores.first.id);

      if (!context.mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      // Switch role to seller
      context.read<PersonaCubit>().switchPersona();

      // Navigate to seller store page
      context.go(
        AppRouter.sellerStore,
        extra: {
          'isGuest': false,
          'isPending': false,
        },
      );
    } catch (e) {
      if (!context.mounted) return;

      // Close loading dialog if still open
      Navigator.of(context).pop();

      // Show error message
      _showErrorSnackBar(
        context,
        'حدث خطأ أثناء التحويل. يرجى المحاولة مرة أخرى.',
      );
    }
  }

  // ── Show Error SnackBar ────────────────────────────────────────────────────
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }
}
