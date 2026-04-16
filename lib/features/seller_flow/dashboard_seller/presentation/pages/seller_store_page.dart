import 'dart:io';

import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:coupony/core/widgets/custom_bottom_nav_bar/seller_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../config/routes/app_router.dart';
import '../../../../Profile/presentation/widgets/profile_photo_bottom_sheet.dart';
import '../../../../auth/domain/entities/user_persona.dart';
import '../../../../auth/presentation/cubit/persona_cubit.dart';
import '../../domain/entities/store_display_entity.dart';
import '../cubit/seller_store_cubit.dart';
import '../cubit/seller_store_state.dart';
import '../cubit/seller_offers_cubit.dart';
import '../widgets/guest_seller_view.dart';
import '../widgets/pending_approval_view_widget.dart';
import '../widgets/seller_offers_grid_view.dart';
import '../widgets/shop_info_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SELLER STORE PAGE — SHOP DISPLAY
// StatelessWidget only. Data flows exclusively through StoreDisplayEntity.
// ─────────────────────────────────────────────────────────────────────────────

class SellerStorePage extends StatelessWidget {
  const SellerStorePage({super.key});

  static const _blue = AppColors.primaryOfSeller; // 0xFF215194

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SellerStoreCubit, SellerStoreState>(
      listener: (context, state) {
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
          backgroundColor: AppColors.scaffoldBackground,
          appBar: _buildAppBar(context, state),
          body: _buildBody(context, state),
          floatingActionButton:
              state is SellerStoreDataLoaded && state.activeTabIndex == 2
                  ? FloatingActionButton(
                      onPressed: () =>
                          context.push(AppRouter.sellerManageOffer),
                      backgroundColor: _blue,
                      elevation: 4,
                      child: Icon(Icons.add_rounded,
                          color: Colors.white, size: 26.w),
                    )
                  : null,
          bottomNavigationBar: SellerBottomNavBar(
            currentIndex: 1,
            onTap: (index) => _handleNavigation(context, index, state),
          ),
        );
      },
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────

  PreferredSizeWidget? _buildAppBar(
    BuildContext context,
    SellerStoreState state,
  ) {
    // ✅ Check PersonaCubit for guest/pending status
    final persona = context.watch<PersonaCubit>().state;
    
    if (persona is GuestPersona) return null;
    if (persona is SellerPersona && (persona.isGuest || persona.isPending)) {
      return null;
    }

    final storeName =
        state is SellerStoreDataLoaded ? state.store.name : '';

    return AppBar(
      surfaceTintColor: AppColors.primaryOfSeller,
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: true,
      leading: BackButton(
        color: AppColors.textPrimary,
        onPressed: () => context.go(AppRouter.customerProfile),
      ),
      title: Text(
        storeName.isNotEmpty
            ? storeName
            : AppLocalizations.of(context)!.store,
        style: AppTextStyles.customStyle(
          context,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    
    );
  }

  // ── Body Router ────────────────────────────────────────────────────────────
  // ✅ PersonaCubit is the single authority for view-mode branching.
  // SellerStoreCubit only drives the active-seller data states below.

  Widget _buildBody(BuildContext context, SellerStoreState state) {
    final persona = context.watch<PersonaCubit>().state;

    // ✅ Check for guest mode first
    if (persona is GuestPersona) {
      return const GuestSellerViewWidget(icon: FontAwesomeIcons.store);
    }
    
    // ✅ Check for seller guest mode (skip button on login)
    if (persona is SellerPersona && persona.isGuest) {
      return const GuestSellerViewWidget(icon: FontAwesomeIcons.store);
    }
    
    // ✅ Check for pending approval
    if (persona is SellerPersona && persona.isPending) {
      return PendingApprovalViewWidget(
        icon: FontAwesomeIcons.store,
        onContactUs: () {},
      );
    }

    // Active seller — delegate to SellerStoreCubit state.
    if (state is SellerStoreLoading || state is SellerStoreInitial) {
      return _buildLoading();
    }
    if (state is SellerStoreError) {
      return _buildError(context, state.message);
    }
    if (state is SellerStoreDataLoaded) {
      return _buildContent(context, state);
    }
    return _buildLoading();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MAIN CONTENT
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildContent(BuildContext context, SellerStoreDataLoaded state) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 1. Banner ────────────────────────────────────────────────────
          _buildBanner(context, state.store),

          // ── 2. Stats Row ─────────────────────────────────────────────────
          _buildStatsRow(context, state.store),

          // ── 3. Tab Icons ──────────────────────────────────────────────────
          _buildTabIcons(context, state.activeTabIndex),

          Divider(color: AppColors.divider, height: 1, thickness: 1),

          // ── 4-7. Tab Content ──────────────────────────────────────────────
          BlocBuilder<SellerStoreCubit, SellerStoreState>(
            builder: (context, tabState) {
              if (tabState is! SellerStoreDataLoaded) {
                return const SizedBox.shrink();
              }
              return switch (tabState.activeTabIndex) {
                0 => ShopInfoView(store: tabState.store),
                1 => _buildLocationPlaceholder(),
                2 => _buildOffersGrid(),
                _ => ShopInfoView(store: tabState.store),
              };
            },
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 1 — BANNER
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildBanner(BuildContext context, StoreDisplayEntity store) {
    return Stack(
      children: [
        // ── Store Logo (full size) or gradient placeholder ────────────────
        Container(
          height: 200.h,
          width: double.infinity,
          decoration: store.logoUrl == null
              ? BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _blue.withValues(alpha: 0.85),
                      const Color(0xFF0D3470),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                )
              : null,
          child: store.logoUrl != null
              ? Image.network(
                  store.logoUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _blue.withValues(alpha: 0.85),
                          const Color(0xFF0D3470),
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                    ),
                    child: Center(
                      child: FaIcon(
                        FontAwesomeIcons.store,
                        size: 64.sp,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                )
              : Center(
                  child: FaIcon(
                    FontAwesomeIcons.store,
                    size: 64.sp,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
        ),

        // ── Camera icon overlay (top-start: right in RTL/Arabic, left in LTR/English) ───
        PositionedDirectional(
          top: 12.h,
          start: 12.w,
          child: GestureDetector(
            onTap: () => _handleCameraTap(context, store),
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                size: 18.w,
                color: _blue,
              ),
            ),
          ),
        ),

        // ── Verified badge ─────────────────────────────────────────────────
        if (store.isVerified)
          PositionedDirectional(
            top: 12.h,
            end: 12.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_rounded,
                      size: 12.w, color: Colors.white),
                  SizedBox(width: 4.w),
                  Text(
                    AppLocalizations.of(context)!.shop_display_verified_badge,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 2 — STATS ROW
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildStatsRow(BuildContext context, StoreDisplayEntity store) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        children: [
          // Rating
          Expanded(
            child: _buildStatItem(
              context,
              value: store.ratingAvg.toStringAsFixed(1),
              label: l10n.shop_display_rating_label,
              icon: Icons.star_rounded,
              iconColor: const Color(0xFFFFB800),
            ),
          ),
          _buildVerticalDivider(),
          // Followers
          Expanded(
            child: GestureDetector(
              onTap: () => context.push(AppRouter.sellerFollowers),
              child: _buildStatItem(
                context,
                value: store.followersDisplay,
                label: l10n.shop_display_followers_label,
              ),
            ),
          ),
          _buildVerticalDivider(),
          // Coupons
          Expanded(
            child: _buildStatItem(
              context,
              value: store.couponsCount.toString(),
              label: l10n.shop_display_coupons_label,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String value,
    required String label,
    IconData? icon,
    Color? iconColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16.w, color: iconColor),
              SizedBox(width: 4.w),
            ],
            Text(
              value,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: AppTextStyles.customStyle(
            context,
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 40.h,
      color: AppColors.divider,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 3 — TAB ICONS ROW
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildTabIcons(BuildContext context, int activeTabIndex) {
    final cubit = context.read<SellerStoreCubit>();
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          // Info tab
          Expanded(
            child: GestureDetector(
              onTap: () => cubit.changeTab(0),
              child: _buildTabIcon(
                icon: FontAwesomeIcons.circleInfo,
                isActive: activeTabIndex == 0,
              ),
            ),
          ),
          _buildVerticalDivider(),
          // Location tab
          Expanded(
            child: GestureDetector(
              onTap: () => cubit.changeTab(1),
              child: _buildTabIcon(
                icon: FontAwesomeIcons.locationDot,
                isActive: activeTabIndex == 1,
              ),
            ),
          ),
          _buildVerticalDivider(),
          // Grid / offers tab
          Expanded(
            child: GestureDetector(
              onTap: () => cubit.changeTab(2),
              child: _buildTabIcon(
                icon: FontAwesomeIcons.tableCells,
                isActive: activeTabIndex == 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabIcon({required IconData icon, required bool isActive}) {
    return Center(
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: isActive
            ? BoxDecoration(
                color: _blue,
                shape: BoxShape.circle,
              )
            : null,
        child: Center(
          child: FaIcon(
            icon,
            size: 18.sp,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB PLACEHOLDERS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildLocationPlaceholder() {
    return SizedBox(
      height: 300.h,
      child: Center(
        child: Icon(
          Icons.location_on_outlined,
          size: 64.w,
          color: AppColors.divider,
        ),
      ),
    );
  }

  Widget _buildOffersGrid() {
    return Builder(
      builder: (context) {
        // ✅ Get guest/pending status from PersonaCubit
        final persona = context.read<PersonaCubit>().state;
        final isGuest = persona is GuestPersona || 
                        (persona is SellerPersona && persona.isGuest);
        final isPending = persona is SellerPersona && persona.isPending;
        
        return BlocProvider(
          create: (_) =>
              SellerOffersCubit(isGuest: isGuest, isPending: isPending)..loadOffers(),
          child: const SellerOffersGridView(),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LOADING STATE
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(
        color: _blue,
        strokeWidth: 3.w,
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ERROR STATE
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 64.w, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              message,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () =>
                  context.read<SellerStoreCubit>().loadStoreDisplay(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                padding:
                    EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.retry,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // NAVIGATION
  // ══════════════════════════════════════════════════════════════════════════

  void _handleNavigation(
    BuildContext context,
    int index,
    SellerStoreState state,
  ) {
    // ✅ Get guest/pending status from PersonaCubit instead of state
    final persona = context.read<PersonaCubit>().state;
    final isGuest = persona is GuestPersona || 
                    (persona is SellerPersona && persona.isGuest);
    final isPending = persona is SellerPersona && persona.isPending;
    final args = {'isGuest': isGuest, 'isPending': isPending};

    switch (index) {
      case 0:
        context.go(AppRouter.customerProfile);
        break;
      case 1:
        break; // Already here
      case 2:
        context.go(AppRouter.sellerAnalytics, extra: args);
        break;
      case 3:
        context.go(AppRouter.sellerOffers, extra: args);
        break;
      case 4:
        context.go(AppRouter.sellerHome, extra: args);
        break;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STORE LOGO UPLOAD
  // ══════════════════════════════════════════════════════════════════════════

  // ── Handle Camera Icon Tap (Show Bottom Sheet) ─────────────────────────────
  Future<void> _handleCameraTap(
    BuildContext context,
    StoreDisplayEntity store,
  ) async {
    final hasPhoto = store.logoUrl != null && store.logoUrl!.isNotEmpty;

    try {
      // ── Show Modern Bottom Sheet ───────────────────────────────────────────
      final action = await ProfilePhotoBottomSheet.show(
        context: context,
        hasPhoto: hasPhoto,
        photoUrl: store.logoUrl,
      );

      if (action == null || !context.mounted) return;

      // ── Handle Actions ─────────────────────────────────────────────────────
      switch (action) {
        case ProfilePhotoAction.view:
          // TODO: Implement full screen view if needed
          break;

        case ProfilePhotoAction.camera:
          await _pickStoreLogo(context, store, ImageSource.camera);
          break;

        case ProfilePhotoAction.gallery:
          await _pickStoreLogo(context, store, ImageSource.gallery);
          break;

        case ProfilePhotoAction.remove:
          _removeStoreLogo(context, store);
          break;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.profile_error,
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
  }

  // ── Pick Store Logo from Camera or Gallery ─────────────────────────────────
  Future<void> _pickStoreLogo(
    BuildContext context,
    StoreDisplayEntity store,
    ImageSource source,
  ) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      // ── Create File and Trigger API Call ───────────────────────────────────
      final imageFile = File(pickedFile.path);
      
      if (context.mounted) {
        // TODO: Call API to upload store logo
        // context.read<SellerStoreCubit>().updateStoreLogo(store.id, imageFile);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'جاري رفع صورة المتجر...',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: _blue,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.profile_error,
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
  }

  // ── Remove Store Logo ──────────────────────────────────────────────────────
  void _removeStoreLogo(BuildContext context, StoreDisplayEntity store) {
    // TODO: Call API to remove store logo
    // context.read<SellerStoreCubit>().removeStoreLogo(store.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'جاري حذف صورة المتجر...',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: _blue,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }
}
