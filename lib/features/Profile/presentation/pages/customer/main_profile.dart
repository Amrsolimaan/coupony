import 'dart:io';

import 'package:coupony/config/dependency_injection/injection_container.dart' as di;
import 'package:coupony/core/widgets/custom_bottom_nav_bar/customer_bottom_nav_bar.dart';
import 'package:coupony/features/seller_flow/CreateStore/domain/use_cases/get_stores_use_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../config/routes/app_router.dart';
import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../features/auth/data/models/user_model.dart';
import '../../../../../features/auth/data/models/user_store_model.dart';
import '../../../../../features/Profile/presentation/pages/customer/become_merchant_page.dart'
    show BecomeMerchantArgs;
import '../../../../../features/Profile/presentation/pages/customer/merchant_rejected_page.dart'
    show MerchantStatusArgs;
import '../../../../../core/utils/image_url_utils.dart';
import '../../../../../core/widgets/images/app_cached_image.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/use_cases/update_profile_params.dart';
import '../../cubit/Customer_Profile_cubit.dart';
import '../../cubit/Customer_Profile_state.dart';
import '../../widgets/full_screen_photo_viewer.dart';
import '../../widgets/profile_photo_bottom_sheet.dart';
import '../../widgets/shared_card.dart';


// ─────────────────────────────────────────────────────────────────────────────
// CUSTOMER MAIN PROFILE SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class MainProfile extends StatelessWidget {
  const MainProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        // ── Handle Profile Update Success ──────────────────────────────────
        if (state is ProfileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Profile updated successfully',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(16.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          );
        }

        // ── Handle Profile Update Error ────────────────────────────────────
        if (state is ProfileError) {
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
        // ── Trigger profile load if not already loaded ─────────────────────
        if (state is ProfileInitial) {
          context.read<ProfileCubit>().loadProfile();
        }

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: _buildAppBar(context, l10n),
          body: _buildBody(context, state, l10n),
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: 0,
            onTap: (index) => _handleNavigation(context, index),
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
        l10n.profile_title,
        style: AppTextStyles.customStyle(
          context,
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          size: 20.w,
          color: AppColors.textPrimary,
        ),
        onPressed: () => context.go(AppRouter.home),
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────
  Widget _buildBody(
    BuildContext context,
    ProfileState state,
    AppLocalizations l10n,
  ) {
    if (state is ProfileLoading || state is ProfileUpdating) {
      return _buildLoadingState(l10n);
    }

    if (state is ProfileError) {
      return _buildErrorState(context, state, l10n);
    }

    if (state is ProfileLoaded || state is ProfileUpdateSuccess) {
      final user = state is ProfileLoaded
          ? state.user
          : (state as ProfileUpdateSuccess).user;

      return SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16.h),
            _buildProfileHeader(context, user, l10n),
            SizedBox(height: 24.h),
            _buildMenuList(context, l10n, user as UserModel),
            SizedBox(height: 24.h),
            _buildVersionInfo(l10n),
            SizedBox(height: 24.h),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // ── Loading State ──────────────────────────────────────────────────────────
  Widget _buildLoadingState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3.w),
          SizedBox(height: 16.h),
          Text(
            l10n.profile_loading,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  // ── Error State ────────────────────────────────────────────────────────────
  Widget _buildErrorState(
    BuildContext context,
    ProfileError state,
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
              l10n.profile_error,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () => context.read<ProfileCubit>().loadProfile(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                l10n.profile_retry,
                style: TextStyle(
                  fontSize: 14.sp,
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

  // ── Profile Header ─────────────────────────────────────────────────────────
  Widget _buildProfileHeader(
    BuildContext context,
    dynamic user,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Avatar ─────────────────────────────────────────────────────────
          _buildAvatar(context, user.avatar, user),
          SizedBox(width: 16.w),

          // ── User Info ──────────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName.isNotEmpty
                      ? user.fullName
                      : l10n.profile_default_user,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  user.email,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 12.h),

                // ── Edit Account Button ────────────────────────────────────────
                ElevatedButton(
                  onPressed: () async {
                    final result = await context.push(
                      AppRouter.editCustomerProfile,
                    );
                    // If profile was updated successfully, reload the profile
                    if (result == true && context.mounted) {
                      context.read<ProfileCubit>().loadProfile();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 10.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.profile_edit_account,
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
        ],
      ),
    );
  }

  // ── Avatar Widget with Camera Icon ────────────────────────────────────────
  Widget _buildAvatar(BuildContext context, String? avatarUrl, dynamic user) {
    return GestureDetector(
      onTap: () => _handleAvatarTap(context, user),
      child: Hero(
        tag: 'profile_avatar',
        child: Stack(
          children: [
            // ── Avatar Circle with Shadow ──────────────────────────────────────
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: AppCachedImageCircular(
                imageUrl: avatarUrl ?? '',
                size: 80.w,
                borderWidth: 3.w,
                borderColor: AppColors.surface,
              ),
            ),

            // ── Camera Icon Overlay with Gradient ──────────────────────────────
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 2.w),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  size: 12.w,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Handle Avatar Tap (Show Modern Bottom Sheet) ──────────────────────────
  Future<void> _handleAvatarTap(BuildContext context, dynamic user) async {
    final l10n = AppLocalizations.of(context)!;
    final imageUrl = ImageUrlUtils.buildFullImageUrl(user.avatar as String?);
    final hasPhoto = imageUrl != null && imageUrl.isNotEmpty;

    try {
      // ── Show Modern Bottom Sheet ───────────────────────────────────────────
      final action = await ProfilePhotoBottomSheet.show(
        context: context,
        hasPhoto: hasPhoto,
        photoUrl: imageUrl,
      );

      if (action == null || !context.mounted) return;

      // ── Handle Actions ─────────────────────────────────────────────────────
      switch (action) {
        case ProfilePhotoAction.view:
          _viewPhoto(context, imageUrl);
          break;

        case ProfilePhotoAction.camera:
          await _pickImage(context, ImageSource.camera);
          break;

        case ProfilePhotoAction.gallery:
          await _pickImage(context, ImageSource.gallery);
          break;

        case ProfilePhotoAction.remove:
          _removePhoto(context);
          break;
      }
    } catch (e) {
      // ── Handle Errors ──────────────────────────────────────────────────────
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.profile_error,
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

  // ── View Photo in Full Screen ──────────────────────────────────────────────
  void _viewPhoto(BuildContext context, String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return;

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: FullScreenPhotoViewer(
              imageUrl: imageUrl,
              heroTag: 'profile_avatar',
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  // ── Pick Image from Camera or Gallery ──────────────────────────────────────
  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      // ── Create Update Params ───────────────────────────────────────────────
      final imageFile = File(pickedFile.path);
      final params = UpdateProfileParams(avatar: imageFile);

      // ── Trigger API Call ───────────────────────────────────────────────────
      if (context.mounted) {
        context.read<ProfileCubit>().updateProfile(params);
      }
    } catch (e) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.profile_error,
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

  // ── Remove Photo ───────────────────────────────────────────────────────────
  void _removePhoto(BuildContext context) {
    final params = UpdateProfileParams(removeAvatar: 1);
    context.read<ProfileCubit>().updateProfile(params);
  }

  // ── Menu List ──────────────────────────────────────────────────────────────
  Widget _buildMenuList(
    BuildContext context,
    AppLocalizations l10n,
    UserModel user,
  ) {
    // Get roles and stores from user
    final roles = user.roles;
    final stores = user.stores;
    
    // DEBUG: Log for verification
    print('🔍 [MainProfile] User roles: $roles');
    print('🔍 [MainProfile] User stores: ${stores.length}');
    if (stores.isNotEmpty) {
      print('🔍 [MainProfile] First store status: ${stores.first.status}');
    }

    // Determine button label and action based on roles + store status
    String merchantButtonLabel;
    VoidCallback merchantButtonAction;

    // ══════════════════════════════════════════════════════════════════════════
    // MERCHANT BUTTON LOGIC - ROLE + STORE STATUS HIERARCHY
    // ══════════════════════════════════════════════════════════════════════════
    
    if (roles.contains('seller') && stores.any((s) => s.isActive)) {
      // ── CASE 1: ACTIVE SELLER (approved store) ──────────────────────────────
      print('✅ [MainProfile] CASE 1: Active Seller - Switch to Merchant');
      merchantButtonLabel = l10n.profile_switch_to_merchant;
      merchantButtonAction = () => _handleActiveSeller(context);
      
    } else if (roles.contains('seller_pending') || stores.any((s) => s.isPending || s.isRejected)) {
      // ── CASE 2 & 3: PENDING OR REJECTED - Need to fetch full store details ──
      print('✅ [MainProfile] CASE 2/3: Pending or Rejected - Fetching store details');
      merchantButtonLabel = l10n.merchant_review_pending_title;
      merchantButtonAction = () => _handlePendingOrRejectedSeller(context);
      
    } else {
      // ── CASE 4: PURE CUSTOMER ───────────────────────────────────────────────
      print('✅ [MainProfile] CASE 4: Pure Customer');
      merchantButtonLabel = l10n.become_merchant_title;
      merchantButtonAction = () => _handlePureCustomer(context);
    }

    return Column(
      children: [
        SharedProfileCard(
          icon: FontAwesomeIcons.heart,
          title: l10n.profile_favorites,
          onTap: () {
            // TODO: Navigate to favorites
          },
        ),
        SharedProfileCard(
          icon: FontAwesomeIcons.store,
          title: merchantButtonLabel,
          onTap: merchantButtonAction,
        ),
        SharedProfileCard(
          icon: FontAwesomeIcons.userGroup,
          title: l10n.profile_follow,
          onTap: () {
            // TODO: Navigate to following
          },
        ),
        SharedProfileCard(
          icon: FontAwesomeIcons.locationDot,
          title: l10n.profile_address,
          onTap: () => context.push(AppRouter.addressManagement),
        ),
        SharedProfileCard(
          icon: FontAwesomeIcons.gear,
          title: l10n.profile_settings,
          onTap: () => context.push(AppRouter.settingsPage),
        ),
        SharedProfileCard(
          icon: FontAwesomeIcons.circleQuestion,
          title: l10n.profile_support,
          onTap: () => context.push(AppRouter.helpSupport),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BECOME MERCHANT BUTTON LOGIC - ROLE + STORE STATUS HIERARCHY
  // ══════════════════════════════════════════════════════════════════════════
  //
  // FLOW:
  // 1. Active Seller (seller role + active store) → merchant_approved_page
  // 2. Pending/Rejected Seller → Fetch full store details from GET /api/v1/stores
  //    - If rejected → merchant_rejected_page → merchant_status_page
  //    - If pending → merchant_pending_page
  // 3. Pure Customer → become_merchant (create new store)
  //
  // ══════════════════════════════════════════════════════════════════════════

  // ── CASE 1: ACTIVE SELLER ──────────────────────────────────────────────────
  // User has approved store - show approval page with two options:
  // - Switch to Merchant → Dashboard
  // - Continue as Customer → Stay in profile
  void _handleActiveSeller(BuildContext context) {
    print('🚀 [MainProfile] Navigating to merchant_approved_page');
    context.push(AppRouter.merchantApproved);
  }

  // ── CASE 2 & 3: PENDING OR REJECTED SELLER ─────────────────────────────────
  // Fetch full store details from GET /api/v1/stores to determine exact status
  Future<void> _handlePendingOrRejectedSeller(BuildContext context) async {
    print('🚀 [MainProfile] Fetching store details from GET /api/v1/stores');
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Import the use case
      final getStoresUseCase = di.sl<GetStoresUseCase>();
      final result = await getStoresUseCase();

      if (!context.mounted) return;
      
      // Close loading dialog
      Navigator.of(context).pop();

      result.fold(
        (failure) {
          // Handle error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to fetch store details: ${failure.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        },
        (stores) {
          if (stores.isEmpty) {
            // No stores found - treat as pure customer
            _handlePureCustomer(context);
            return;
          }

          final store = stores.first;
          
          if (store.isRejected) {
            // Navigate to rejected page
            print('🚀 [MainProfile] Store is REJECTED - navigating to merchant_rejected_page');
            context.push(
              AppRouter.merchantRejected,
              extra: MerchantStatusArgs(
                storeId: store.id,
                reasons: store.rejectionReason != null 
                    ? [store.rejectionReason!] 
                    : store.rejectionReasons,
                store: store,
              ),
            );
          } else if (store.isPending) {
            // Navigate to pending page
            print('🚀 [MainProfile] Store is PENDING - navigating to merchant_pending_page');
            context.push(AppRouter.merchantPending);
          } else if (store.isActive) {
            // Navigate to approved page
            print('🚀 [MainProfile] Store is ACTIVE - navigating to merchant_approved_page');
            context.push(AppRouter.merchantApproved);
          }
        },
      );
    } catch (e) {
      if (!context.mounted) return;
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ── CASE 4: PURE CUSTOMER ──────────────────────────────────────────────────
  // No store yet - start creation flow
  void _handlePureCustomer(BuildContext context) {
    print('🚀 [MainProfile] Navigating to become_merchant');
    final profileCubit = context.read<ProfileCubit>();
    context.push(
      AppRouter.becomeMerchant,
      extra: BecomeMerchantArgs(onStoreCreated: profileCubit.loadProfile),
    );
  }

  // ── Version Info ───────────────────────────────────────────────────────────
  Widget _buildVersionInfo(AppLocalizations l10n) {
    const version = '1.0.0';
    return Center(
      child: Text(
        l10n.profile_version(version),
        style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
      ),
    );
  }

  // ── Navigation Handler ─────────────────────────────────────────────────────
  void _handleNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        // Already on profile
        break;
      case 1:
        // TODO: Navigate to categories
        break;
      case 2:
        // TODO: Navigate to explorer
        break;
      case 3:
        // TODO: Navigate to coupons
        break;
      case 4:
        context.go(AppRouter.home);
        break;
    }
  }
}
