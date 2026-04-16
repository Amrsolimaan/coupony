import 'dart:io';

import 'package:coupony/config/dependency_injection/injection_container.dart'
    as di;
import 'package:coupony/core/widgets/custom_bottom_nav_bar/customer_bottom_nav_bar.dart';
import 'package:coupony/core/widgets/custom_bottom_nav_bar/seller_bottom_nav_bar.dart';
import 'package:coupony/features/seller_flow/CreateStore/domain/use_cases/get_stores_use_case.dart';
import 'package:coupony/features/seller_flow/CreateStore/presentation/pages/create_store_screen.dart';
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
import '../../../../../features/seller_flow/CreateStore/presentation/pages/create_store_screen.dart'
    show CreateStoreArgs;
import '../../../../../core/utils/image_url_utils.dart';
import '../../../../../core/widgets/images/app_cached_image.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/use_cases/update_profile_params.dart';
import '../../cubit/Customer_Profile_cubit.dart';
import '../../cubit/Customer_Profile_state.dart';
import '../../cubit/stores_display_cubit.dart';
import '../../widgets/full_screen_photo_viewer.dart';
import '../../widgets/profile_photo_bottom_sheet.dart';
import '../../widgets/shared_card.dart';
import '../../widgets/store_selection_bottom_sheet.dart';
import '../../../../auth/domain/entities/user_persona.dart';
import '../../../../auth/presentation/cubit/persona_cubit.dart';
import '../../../../auth/presentation/widgets/role_animation_wrapper.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOMER MAIN PROFILE SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class MainProfile extends StatelessWidget {
  const MainProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MultiBlocProvider(
      providers: [
        BlocProvider<StoresDisplayCubit>(
          create: (context) => di.sl<StoresDisplayCubit>(),
        ),
      ],
      child: BlocBuilder<PersonaCubit, UserPersona>(
        builder: (context, persona) {
          // ✅ Check if user is guest - show guest view instead of loading profile
          final isGuest = persona is GuestPersona || 
                          (persona is SellerPersona && persona.isGuest);
          
          if (isGuest) {
            // Show guest view - redirect to login
            return _buildGuestView(context, l10n, persona is SellerPersona);
          }

          // Normal authenticated user flow
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

              return BlocBuilder<PersonaCubit, UserPersona>(
                builder: (context, persona) {
                  // ✅ Check persona state for seller, guest, and pending
                  final isSeller = persona is SellerPersona;
                  final isGuest = persona is GuestPersona || 
                                  (persona is SellerPersona && persona.isGuest);
                  final isPending = persona is SellerPersona && persona.isPending;
                  
                  return Scaffold(
                    backgroundColor: AppColors.surface,
                    appBar: _buildAppBar(context, l10n, isSeller),
                    body: _buildBody(context, state, l10n, isSeller),
                    bottomNavigationBar: isSeller
                        ? SellerBottomNavBar(
                            currentIndex: 0,
                            onTap: (index) =>
                                _handleSellerNavigation(context, index, isGuest, isPending),
                          )
                        : CustomBottomNavBar(
                            currentIndex: 0,
                            onTap: (index) => _handleNavigation(context, index),
                          ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // ── Guest View ─────────────────────────────────────────────────────────────
  Widget _buildGuestView(BuildContext context, AppLocalizations l10n, bool isSeller) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(context, l10n, isSeller),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  color: isSeller 
                      ? AppColors.primaryOfSeller.withValues(alpha: 0.1)
                      : AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSeller ? FontAwesomeIcons.store : FontAwesomeIcons.house,
                  size: 50.w,
                  color: isSeller ? AppColors.primaryOfSeller : AppColors.primary,
                ),
              ),
              SizedBox(height: 24.h),

              // Title
              Text(
                isSeller 
                    ? 'ابدأ رحلتك في البيع على كوبوني'
                    : l10n.welcome,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),

              // Subtitle
              Text(
                isSeller
                    ? 'أنشئ متجرك واعرض خصوماتك وتواصل لعملائك جدد.'
                    : 'سجل دخول للوصول إلى حسابك',
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),

              // Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go(AppRouter.login),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSeller 
                        ? AppColors.primaryOfSeller 
                        : AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.login,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: isSeller
          ? SellerBottomNavBar(
              currentIndex: 0,
              onTap: (index) => _handleSellerNavigation(context, index, true, false),
            )
          : CustomBottomNavBar(
              currentIndex: 0,
              onTap: (index) => _handleNavigation(context, index),
            ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AppLocalizations l10n,
    bool isSeller,
  ) {
    return AppBar(
      surfaceTintColor: isSeller
          ? AppColors.primaryOfSeller
          : AppColors.primary,
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
    bool isSeller,
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

      return RefreshIndicator(
        onRefresh: () async {
          // Refresh profile
          context.read<ProfileCubit>().loadProfile();
          
          // Refresh stores if seller
          if (isSeller) {
            context.read<StoresDisplayCubit>().refreshStores();
          }
          
          // Wait a bit for the refresh to complete
          await Future.delayed(const Duration(milliseconds: 500));
        },
        color: isSeller ? AppColors.primaryOfSeller : AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 16.h),
              _buildProfileHeader(context, user, l10n),

              // ── Stores Section (Seller Only) ───────────────────────────────
              if (isSeller) _buildStoresSection(context, l10n),

              SizedBox(height: 24.h),
              _buildMenuList(context, l10n, user as UserModel, isSeller),
              SizedBox(height: 24.h),
              _buildVersionInfo(l10n),
              SizedBox(height: 24.h),
            ],
          ),
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
          AnimatedPrimaryColor(
            builder: (context, primaryColor) {
              return CircularProgressIndicator(
                color: primaryColor,
                strokeWidth: 3.w,
              );
            },
          ),
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
            AnimatedPrimaryColor(
              builder: (context, primaryColor) {
                return ElevatedButton(
                  onPressed: () => context.read<ProfileCubit>().loadProfile(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(
                      horizontal: 32.w,
                      vertical: 12.h,
                    ),
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
                );
              },
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
                AnimatedPrimaryColor(
                  builder: (context, primaryColor) {
                    return ElevatedButton(
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
                        backgroundColor: primaryColor,
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
                    );
                  },
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
              child: AnimatedPrimaryColor(
                builder: (context, primaryColor) {
                  return Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor,
                          primaryColor.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2.w),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.3),
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
                  );
                },
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

  // ── Stores Section (Seller Only) ──────────────────────────────────────────
  Widget _buildStoresSection(BuildContext context, AppLocalizations l10n) {
    // Trigger load when widget is built
    final storesDisplayCubit = context.read<StoresDisplayCubit>();

    // Load stores if not already loaded
    if (storesDisplayCubit.state is StoresDisplayInitial) {
      storesDisplayCubit.loadStores();
    }

    return BlocBuilder<StoresDisplayCubit, StoresDisplayState>(
      builder: (context, state) {
        // Don't show anything during loading or error
        if (state is StoresDisplayLoading || state is StoresDisplayError) {
          return const SizedBox.shrink();
        }

        if (state is StoresDisplayLoaded) {
          final stores = state.stores;

          // Don't show if no stores OR only one pending store
          if (stores.isEmpty ||
              (stores.length == 1 && stores.first.isPending)) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12.h),

              // ── Stores Horizontal List (No Title) ──────────────────────────
              SizedBox(
                height: 104.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: stores.length + 1, // +1 for Add Store button
                  itemBuilder: (context, index) {
                    // First item is "Add Store" button
                    if (index == 0) {
                      return _buildAddStoreCard(context, l10n);
                    }

                    // Other items are stores
                    final store = stores[index - 1];
                    return _buildStoreCard(
                      context, store, l10n, state.selectedStoreId,
                    );
                  },
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  // ── Add Store Card Widget ──────────────────────────────────────────────────
  Widget _buildAddStoreCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: 70.w,
      margin: EdgeInsets.only(right: 10.w),
      child: InkWell(
        onTap: () => _handleAddStore(context),
        borderRadius: BorderRadius.circular(12.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Add Icon Circle ────────────────────────────────────────────────
            AnimatedPrimaryColor(
              builder: (context, primaryColor) {
                return Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.3),
                      width: 2.w,
                      style: BorderStyle.solid,
                    ),
                    color: primaryColor.withValues(alpha: 0.05),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    size: 30.w,
                    color: primaryColor,
                  ),
                );
              },
            ),
            SizedBox(height: 6.h),

            // ── Add Store Label ────────────────────────────────────────────────
            Text(
              l10n.profile_add_store,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Store Card Widget (Smart) ──────────────────────────────────────────────
  // Tap:       active+selected → snackbar | active+other → switch | pending/rejected → track flow
  // Long press: shows delete bottom sheet (UI only — coming soon)
  Widget _buildStoreCard(
    BuildContext context,
    UserStoreModel store,
    AppLocalizations l10n,
    String? selectedStoreId,
  ) {
    final isSelected = store.id == selectedStoreId;

    // Status colors
    final Color statusColor;
    final String statusLabel;
    if (store.isActive) {
      statusColor = const Color(0xFF15803D);
      statusLabel = l10n.store_status_active;
    } else if (store.isPending) {
      statusColor = const Color(0xFFF59E0B);
      statusLabel = l10n.store_status_pending;
    } else {
      statusColor = const Color(0xFFEF4444);
      statusLabel = l10n.store_status_rejected;
    }

    return GestureDetector(
      onTap: () => _handleStoreCardTap(context, store, isSelected, l10n),
      onLongPress: () => _showDeleteStoreSheet(context, store, l10n),
      child: Container(
        width: 80.w,
        margin: EdgeInsets.only(right: 10.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Logo with selection checkmark ──────────────────────────────
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected && store.isActive
                          ? const Color(0xFF15803D)
                          : statusColor.withValues(alpha: 0.3),
                      width: isSelected && store.isActive ? 2.5.w : 1.5.w,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Opacity(
                    opacity: store.isActive ? 1.0 : 0.65,
                    child: AppCachedImageCircular(
                      imageUrl: store.logoUrl ?? '',
                      size: 60.w,
                      borderWidth: 0,
                    ),
                  ),
                ),

                // Checkmark badge — selected active store
                if (isSelected && store.isActive)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 18.w,
                      height: 18.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF15803D),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 1.5.w),
                      ),
                      child: Icon(Icons.check_rounded, size: 11.w, color: Colors.white),
                    ),
                  ),

                // Status icon badge — pending/rejected
                if (!store.isActive)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 18.w,
                      height: 18.w,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 1.5.w),
                      ),
                      child: Icon(
                        store.isPending
                            ? Icons.schedule_rounded
                            : Icons.close_rounded,
                        size: 11.w,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: 4.h),

            // ── Store Name ─────────────────────────────────────────────────
            Text(
              store.name.isEmpty ? '—' : store.name,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 2.h),

            // ── Status badge ───────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5.w,
                  height: 5.w,
                  decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                ),
                SizedBox(width: 3.w),
                Flexible(
                  child: Text(
                    statusLabel,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 9,
                      color: statusColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Handle Store Card Tap ─────────────────────────────────────────────────
  Future<void> _handleStoreCardTap(
    BuildContext context,
    UserStoreModel store,
    bool isSelected,
    AppLocalizations l10n,
  ) async {
    if (store.isActive) {
      if (isSelected) {
        // Already the active store — inform the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.store_already_active,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF15803D),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16.w),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          ),
        );
      } else {
        // Switch to this active store
        await context.read<StoresDisplayCubit>().selectStore(store.id);
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.store_switched_to(store.name.isNotEmpty ? store.name : '—'),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.primaryOfSeller,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16.w),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          ),
        );

        // Navigate to seller store to show the selected store's data
        context.push(AppRouter.sellerStore, extra: {'isGuest': false, 'isPending': false});
      }
    } else if (store.isPending) {
      context.push(AppRouter.merchantPending);
    } else if (store.isRejected) {
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
    }
  }

  // ── Delete Store Bottom Sheet (UI only — coming soon) ─────────────────────
  void _showDeleteStoreSheet(
    BuildContext context,
    UserStoreModel store,
    AppLocalizations l10n,
  ) {
    final storeName = store.name.isNotEmpty ? store.name : '—';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 20.h),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            // Store info row
            Row(
              children: [
                AppCachedImageCircular(
                  imageUrl: store.logoUrl ?? '',
                  size: 44.w,
                  borderWidth: 0,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        storeName,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        l10n.store_delete_dialog_message(storeName),
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // Delete button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.store_delete_coming_soon,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: AppColors.textSecondary,
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.all(16.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.delete_outline_rounded, size: 18.w),
                label: Text(l10n.store_delete_dialog_title),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
              ),
            ),

            SizedBox(height: 10.h),

            // Cancel button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Text(
                  l10n.create_store_cancel,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Menu List ──────────────────────────────────────────────────────────────
  // [isSeller] comes from the single BlocBuilder<PersonaCubit> that wraps
  // the whole Scaffold — guaranteed to be in sync with the bottom nav bar.
  Widget _buildMenuList(
    BuildContext context,
    AppLocalizations l10n,
    UserModel user,
    bool isSeller,
  ) {
    // ── Load stores once ───────────────────────────────────────────────────
    final storesDisplayCubit = context.read<StoresDisplayCubit>();
    if (storesDisplayCubit.state is StoresDisplayInitial) {
      storesDisplayCubit.loadStores();
    }

    return BlocBuilder<StoresDisplayCubit, StoresDisplayState>(
      builder: (context, storesState) {
        // [currentRole] read here from the cubit — NOT a new BlocBuilder.
        // We only need the role string to decide the merchant button label.
        final currentRole =
            context.read<PersonaCubit>().state is SellerPersona ? 'seller' : 'customer';
        final roles = user.roles;

        // ══════════════════════════════════════════════════════════════════════
        // MERCHANT BUTTON LOGIC - SMART ROLE + STORE STATUS HIERARCHY
        // ══════════════════════════════════════════════════════════════════════

        String merchantButtonLabel;
        VoidCallback merchantButtonAction;

        // Get stores from StoresDisplayCubit (real-time data)
        final List<dynamic> stores = storesState is StoresDisplayLoaded
            ? storesState.stores
            : user.stores; // fallback until cubit loads

        if (currentRole == 'seller') {
          // ── SELLER ROLE SCENARIOS ────────────────────────────────────────

          if (stores.length > 1) {
            // Multiple stores - check if all are pending/rejected
            final allPendingOrRejected = stores.every((s) => s.isPending || s.isRejected);
            
            if (allPendingOrRejected) {
              // All stores are pending/rejected
              merchantButtonLabel = l10n.profile_track_request;
              merchantButtonAction = () =>
                  _handlePendingOrRejectedSeller(context);
            } else {
              // At least one active store - switch to customer directly
              merchantButtonLabel = l10n.profile_switch_to_customer;
              merchantButtonAction = () => _handleSwitchToCustomer(context);
            }
          } else if (stores.length == 1) {
            final store = stores.first;
            if (store.isActive) {
              merchantButtonLabel = l10n.profile_switch_to_customer;
              merchantButtonAction = () => _handleSwitchToCustomer(context);
            } else {
              merchantButtonLabel = l10n.profile_track_request;
              merchantButtonAction = () =>
                  _handlePendingOrRejectedSeller(context);
            }
          } else {
            merchantButtonLabel = l10n.become_merchant_title;
            merchantButtonAction = () => _handlePureCustomer(context);
          }
        } else {
          // ── CUSTOMER ROLE SCENARIOS ─────────────────────────────────────

          if (roles.contains('seller') && stores.isNotEmpty) {
            merchantButtonLabel = l10n.profile_switch_to_merchant;
            merchantButtonAction = () =>
                _handleSellerWithStores(context, stores);
          } else if (roles.contains('seller_pending') ||
              stores.any((s) => s.isPending || s.isRejected)) {
            merchantButtonLabel = l10n.profile_track_request;
            merchantButtonAction = () =>
                _handlePendingOrRejectedSeller(context);
          } else {
            merchantButtonLabel = l10n.become_merchant_title;
            merchantButtonAction = () => _handlePureCustomer(context);
          }
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

            // ── Follow Card — Customer only ─────────────────────────────
            // Uses the [isSeller] passed from the outer Scaffold BlocBuilder.
            // This is the exact same value that controls the bottom nav bar,
            // so it is guaranteed to be correct.
            if (!isSeller)
              SharedProfileCard(
                icon: FontAwesomeIcons.userGroup,
                title: l10n.profile_follow,
                onTap: () => context.push(AppRouter.customerFollowing),
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
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BECOME MERCHANT BUTTON LOGIC - ROLE + STORE STATUS HIERARCHY
  // ══════════════════════════════════════════════════════════════════════════
  //
  // FLOW:
  // 1. Seller with stores → Show store selection bottom sheet
  // 2. Pending/Rejected Seller → Fetch full store details from GET /api/v1/stores
  //    - If rejected → merchant_rejected_page → merchant_status_page
  //    - If pending → merchant_pending_page
  // 3. Pure Customer → become_merchant (create new store)
  //
  // ══════════════════════════════════════════════════════════════════════════

  // ── CASE 1: SELLER WITH STORES ─────────────────────────────────────────────
  // User has stores (active, pending, or rejected) - show bottom sheet
  Future<void> _handleSellerWithStores(
    BuildContext context,
    List<dynamic> stores,
  ) async {
    await StoreSelectionBottomSheet.show(
      context: context,
      stores: stores.cast(),
    );
  }

  // ── CASE 2 & 3: PENDING OR REJECTED SELLER ─────────────────────────────────
  // Fetch full store details from GET /api/v1/stores to determine exact status
  Future<void> _handlePendingOrRejectedSeller(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
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
              content: Text(
                'Failed to fetch store details: ${failure.message}',
              ),
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
            context.push(AppRouter.merchantPending);
          } else if (store.isActive) {
            // Navigate to approved page
            context.push(AppRouter.merchantApproved);
          }
        },
      );
    } catch (e) {
      if (!context.mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  // ── CASE 4: PURE CUSTOMER ──────────────────────────────────────────────────
  // No store yet - start creation flow
  void _handlePureCustomer(BuildContext context) {
    final profileCubit = context.read<ProfileCubit>();
    context.push(
      AppRouter.becomeMerchant,
      extra: BecomeMerchantArgs(onStoreCreated: profileCubit.loadProfile),
    );
  }

  // ── SWITCH TO CUSTOMER (Seller → Customer) ────────────────────────────────
  void _handleSwitchToCustomer(BuildContext context) {
    // Switch role to customer
    context.read<PersonaCubit>().switchPersona();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'تم التحول إلى وضع المستخدم',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  // ── HANDLE ADD STORE ───────────────────────────────────────────────────────
  /// Navigates to CreateStoreScreen to add a new store.
  /// After successful creation, refreshes the profile and stores list.
  void _handleAddStore(BuildContext context) {
    context.push(
      AppRouter.createStore,
      extra: CreateStoreArgs(
        onSuccess: () {
          // Return to main_profile (pop CreateStoreScreen off the stack)
          context.pop();

          // Refresh profile data and stores list
          context.read<ProfileCubit>().loadProfile();
          context.read<StoresDisplayCubit>().refreshStores();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'تم إضافة المحل بنجاح',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(16.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          );
        },
      ),
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

  void _handleSellerNavigation(BuildContext context, int index, bool isGuest, bool isPending) {
    // ✅ Pass guest/pending status to navigation
    final args = {'isGuest': isGuest, 'isPending': isPending};
    
    switch (index) {
      case 0:
        // Already on profile
        break;
      case 1:
        context.go(AppRouter.sellerStore, extra: args);
        break;
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
}
