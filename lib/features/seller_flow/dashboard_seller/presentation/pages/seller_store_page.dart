import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:coupony/core/widgets/custom_bottom_nav_bar/seller_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../../config/routes/app_router.dart';
import '../cubit/seller_store_cubit.dart';
import '../cubit/seller_store_state.dart';
import '../widgets/guest_seller_view.dart';
import '../widgets/pending_approval_view_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SELLER STORE PAGE
// ─────────────────────────────────────────────────────────────────────────────

class SellerStorePage extends StatelessWidget {
  const SellerStorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<SellerStoreCubit, SellerStoreState>(
      listener: (context, state) {
        // ── Handle Error ───────────────────────────────────────────────────
        if (state is SellerStoreError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
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
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: (state is SellerStoreGuest || state is SellerStorePending)
              ? null // Hide AppBar for Guest and Pending states
              : _buildAppBar(context, l10n),
          body: _buildBody(context, state, l10n),
          bottomNavigationBar: SellerBottomNavBar(
            currentIndex: 1, // Store tab
            onTap: (index) => _handleNavigation(context, index, state),
          ),
        );
      },
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return AppBar(
    backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: true,
      title: Text(
        l10n.home,
        style: AppTextStyles.customStyle(
          context,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryOfSeller
        ),
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────
  Widget _buildBody(
    BuildContext context,
    SellerStoreState state,
    AppLocalizations l10n,
  ) {
    // ── Loading State ──────────────────────────────────────────────────────
    if (state is SellerStoreLoading) {
      return _buildLoadingState(l10n);
    }

    // ── Error State ────────────────────────────────────────────────────────
    if (state is SellerStoreError) {
      return _buildErrorState(context, state, l10n);
    }

    // ── Guest View ─────────────────────────────────────────────────────────
    if (state is SellerStoreGuest) {
      return const GuestSellerViewWidget(
        icon: FontAwesomeIcons.store,
      );
    }

    // ── Pending Approval View ──────────────────────────────────────────────
    if (state is SellerStorePending) {
      return PendingApprovalViewWidget(
        icon: FontAwesomeIcons.store,
        onContactUs: () {
          // TODO: Navigate to contact us
        },
      );
    }

    // ── Normal Store Content ───────────────────────────────────────────────
    return _buildStoreContent(context, l10n);
  }

  // ── Loading State ──────────────────────────────────────────────────────────
  Widget _buildLoadingState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primaryOfSeller,
            strokeWidth: 3.w,
          ),
          SizedBox(height: 16.h),
          Text(
            l10n.loading,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Error State ────────────────────────────────────────────────────────────
  Widget _buildErrorState(
    BuildContext context,
    SellerStoreError state,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64.w,
              color: AppColors.error,
            ),
            SizedBox(height: 16.h),
            Text(
              state.message,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () {
                // TODO: Retry logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOfSeller,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                l10n.profile_retry,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Store Content ──────────────────────────────────────────────────────────
  Widget _buildStoreContent(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 60.h),
            
            // ── Store Icon ─────────────────────────────────────────────────
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: AppColors.primaryOfSeller.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.store,
                  size: 48.sp,
                  color: AppColors.primaryOfSeller,
                ),
              ),
            ),
            SizedBox(height: 32.h),
            
            // ── Title ──────────────────────────────────────────────────────
            Text(
              l10n.seller_store_content_title,
              textAlign: TextAlign.center,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
            SizedBox(height: 16.h),
            
            // ── Subtitle ───────────────────────────────────────────────────
            Text(
              l10n.seller_store_content_subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Navigation Handler ─────────────────────────────────────────────────────
  void _handleNavigation(
    BuildContext context,
    int index,
    SellerStoreState state,
  ) {
    // Extract isGuest and isPending from current state
    bool isGuest = false;
    bool isPending = false;

    if (state is SellerStoreInitial) {
      isGuest = state.isGuest;
      isPending = state.isPending;
    } else if (state is SellerStoreLoaded) {
      isGuest = state.isGuest;
      isPending = state.isPending;
    } else if (state is SellerStoreGuest) {
      isGuest = true;
    } else if (state is SellerStorePending) {
      isPending = true;
    }

    final args = {
      'isGuest': isGuest,
      'isPending': isPending,
    };

    switch (index) {
      case 0: // Account
        context.go(AppRouter.customerProfile);
        break;
      case 1: // Store
        // Already on store, do nothing
        break;
      case 2: // Analytics
        context.go(AppRouter.sellerAnalytics, extra: args);
        break;
      case 3: // Offers
        context.go(AppRouter.sellerOffers, extra: args);
        break;
      case 4: // Home
        context.go(AppRouter.sellerHome, extra: args);
        break;
    }
  }
}
