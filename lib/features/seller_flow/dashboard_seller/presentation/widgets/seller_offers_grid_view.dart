import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routes/app_router.dart';
import '../../domain/entities/offer_entity.dart';
import '../cubit/seller_offers_cubit.dart';
import '../cubit/seller_offers_state.dart';
import 'manageable_offer_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SELLER OFFERS GRID VIEW
// 3-column square grid. Manages its own BLoC scope.
// ─────────────────────────────────────────────────────────────────────────────

class SellerOffersGridView extends StatelessWidget {
  const SellerOffersGridView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SellerOffersCubit, SellerOffersState>(
      builder: (context, state) {
        if (state is SellerOffersLoading) {
          return _buildLoading();
        }
        if (state is SellerOffersDataLoaded) {
          if (state.offers.isEmpty) return _buildEmpty(context);
          return _buildGrid(context, state.offers);
        }
        return _buildLoading();
      },
    );
  }

  // ── Grid ───────────────────────────────────────────────────────────────────

  Widget _buildGrid(BuildContext context, List<OfferEntity> offers) {
    return GridView.builder(
      // Non-scrollable: outer SingleChildScrollView handles scroll
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.all(8.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6.w,
        mainAxisSpacing: 6.h,
        childAspectRatio: 1,
      ),
      itemCount: offers.length,
      itemBuilder: (context, index) {
        final offer = offers[index];
        return ManageableOfferCard(
          offer: offer,
          onDeleteRequest: () => _showDeleteDialog(context, offer),
          onEditRequest: () =>
              context.push(AppRouter.sellerManageOffer, extra: offer),
        );
      },
    );
  }

  // ── Delete confirmation dialog ─────────────────────────────────────────────

  void _showDeleteDialog(BuildContext gridContext, OfferEntity offer) {
    final l10n = AppLocalizations.of(gridContext)!;

    showDialog<void>(
      context: gridContext,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            l10n.offer_delete_confirm_title,
            style: AppTextStyles.customStyle(
              gridContext,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          content: Text(
            l10n.offer_delete_confirm_message,
            style: AppTextStyles.customStyle(
              gridContext,
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          actions: [
            // Confirm delete
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  gridContext
                      .read<SellerOffersCubit>()
                      .deleteOffer(offer.id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOfSeller,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Text(
                  l10n.offer_delete_confirm_button,
                  style: AppTextStyles.customStyle(
                    gridContext,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            // Cancel
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    side: BorderSide(color: AppColors.divider),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Text(
                  l10n.offer_delete_cancel,
                  style: AppTextStyles.customStyle(
                    gridContext,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Loading ────────────────────────────────────────────────────────────────

  Widget _buildLoading() {
    return SizedBox(
      height: 200.h,
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryOfSeller,
          strokeWidth: 3,
        ),
      ),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────

  Widget _buildEmpty(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 300.h,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.grid_view_rounded,
              size: 64.w,
              color: AppColors.divider,
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.offer_empty,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
