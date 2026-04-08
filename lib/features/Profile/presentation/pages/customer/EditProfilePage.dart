import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:coupony/core/utils/message_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/extensions/snackbar_extension.dart';
import '../../../domain/use_cases/update_profile_params.dart';
import '../../cubit/Customer_Profile_cubit.dart';
import '../../cubit/Customer_Profile_state.dart';
import '../../widgets/full_screen_photo_viewer.dart';
import '../../widgets/profile_photo_bottom_sheet.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EDIT PROFILE PAGE
// ─────────────────────────────────────────────────────────────────────────────

class EditProfilePage extends HookWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // ── Hook declarations ──────────────────────────────────────────────────
    final firstNameController = useTextEditingController();
    final lastNameController = useTextEditingController();
    final phoneController = useTextEditingController();
    final isEditMode = useValueNotifier(false);
    final selectedImage = useValueNotifier<File?>(null);
    final isNavigating = useValueNotifier(false); // Track navigation state

    // ── Handle Save Callback ───────────────────────────────────────────────
    final handleSave = useCallback(() {
      final params = UpdateProfileParams(
        firstName: firstNameController.text.trim().isNotEmpty
            ? firstNameController.text.trim()
            : null,
        lastName: lastNameController.text.trim().isNotEmpty
            ? lastNameController.text.trim()
            : null,
        phoneNumber: phoneController.text.trim().isNotEmpty
            ? phoneController.text.trim()
            : null,
        avatar: selectedImage.value,
      );

      context.read<ProfileCubit>().updateProfile(params);
    }, [firstNameController, lastNameController, phoneController, selectedImage]);

    // ── Handle Avatar Tap Callback ─────────────────────────────────────────
    final handleAvatarTap = useCallback((dynamic user) async {
      final imageUrl = _buildFullImageUrl(user.avatar);
      final hasPhoto = imageUrl != null || selectedImage.value != null;

      try {
        // ── Show Modern Bottom Sheet ───────────────────────────────────────
        final action = await ProfilePhotoBottomSheet.show(
          context: context,
          hasPhoto: hasPhoto,
          photoUrl: imageUrl,
          localPhoto: selectedImage.value,
        );

        if (action == null) return;

        // ── Handle Actions ─────────────────────────────────────────────────
        switch (action) {
          case ProfilePhotoAction.view:
            _viewPhoto(context, imageUrl, selectedImage.value);
            break;

          case ProfilePhotoAction.camera:
            await _pickImage(context, ImageSource.camera, selectedImage, isEditMode);
            break;

          case ProfilePhotoAction.gallery:
            await _pickImage(context, ImageSource.gallery, selectedImage, isEditMode);
            break;

          case ProfilePhotoAction.remove:
            _removePhoto(context, selectedImage, isEditMode);
            break;
        }
      } catch (e) {
        if (context.mounted) {
          context.showErrorSnackBar(l10n.profile_error);
        }
      }
    }, [selectedImage, isEditMode]);

    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        // ── Handle Success ─────────────────────────────────────────────────
        if (state is ProfileUpdateSuccess) {
          isNavigating.value = true; // Start navigation state
          context.showSuccessSnackBar(l10n.profile_update_success);
          isEditMode.value = false;
          context.pop(true); // Return true to indicate success immediately
        }

        // ── Handle Error ───────────────────────────────────────────────────
        if (state is ProfileError) {
          isNavigating.value = false; // Reset navigation state on error
          context.showErrorSnackBar(context.getLocalizedMessage(state.message));
        }
      },
      builder: (context, state) {
        // ── Initialize controllers with user data ─────────────────────────
        if (state is ProfileLoaded && !isEditMode.value) {
          if (firstNameController.text.isEmpty) {
            firstNameController.text = state.user.firstName;
          }
          if (lastNameController.text.isEmpty) {
            lastNameController.text = state.user.lastName;
          }
          if (phoneController.text.isEmpty) {
            phoneController.text = state.user.phoneNumber;
          }
        }
        if (state is ProfileUpdateSuccess && !isEditMode.value) {
          if (firstNameController.text.isEmpty) {
            firstNameController.text = state.user.firstName;
          }
          if (lastNameController.text.isEmpty) {
            lastNameController.text = state.user.lastName;
          }
          if (phoneController.text.isEmpty) {
            phoneController.text = state.user.phoneNumber;
          }
        }

        final isLoading = state is ProfileUpdating;

        return ValueListenableBuilder<bool>(
          valueListenable: isNavigating,
          builder: (context, navigating, _) {
            // Show loading overlay during update or navigation
            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: _buildAppBar(
                context,
                l10n,
                isLoading || navigating,
                isEditMode,
                handleSave,
              ),
              body: (isLoading || navigating)
                  ? _buildLoadingState(l10n)
                  : _buildBody(
                      context,
                      state,
                      l10n,
                      false,
                      firstNameController,
                      lastNameController,
                      phoneController,
                      isEditMode,
                      selectedImage,
                      handleAvatarTap,
                    ),
            );
          },
        );
      },
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AppLocalizations l10n,
    bool isLoading,
    ValueNotifier<bool> isEditMode,
    VoidCallback onSave,
  ) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: true,
      title: Text(
        l10n.edit_profile_title,
        style: AppTextStyles.customStyle(
          context,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20.w,
          color: AppColors.textPrimary,
        ),
        onPressed: () => context.pop(),
      ),
      actions: [
        // ── Save Button (Only visible in edit mode) ───────────────────────
        ValueListenableBuilder<bool>(
          valueListenable: isEditMode,
          builder: (context, editMode, _) {
            if (!editMode) return const SizedBox.shrink();

            return Padding(
              padding: EdgeInsetsDirectional.only(end: 8.w),
              child: TextButton(
                onPressed: isLoading ? null : onSave,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  l10n.save,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isLoading ? AppColors.textDisabled : AppColors.primary,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────
  Widget _buildBody(
    BuildContext context,
    ProfileState state,
    AppLocalizations l10n,
    bool isLoading,
    TextEditingController firstNameController,
    TextEditingController lastNameController,
    TextEditingController phoneController,
    ValueNotifier<bool> isEditMode,
    ValueNotifier<File?> selectedImage,
    Function(dynamic) onAvatarTap,
  ) {
    if (state is ProfileLoading) {
      return _buildLoadingState(l10n);
    }

    if (state is ProfileLoaded || state is ProfileUpdateSuccess) {
      final user = state is ProfileLoaded
          ? state.user
          : (state as ProfileUpdateSuccess).user;

      return ValueListenableBuilder<bool>(
        valueListenable: isEditMode,
        builder: (context, editMode, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // ── Avatar Section with Background ─────────────────────────────
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 32.h),
                      _buildAvatar(
                        context,
                        user.avatar,
                        isLoading,
                        selectedImage,
                        () => onAvatarTap(user),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        '${user.firstName} ${user.lastName}'.trim(),
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (user.email.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          user.email,
                          style: AppTextStyles.customStyle(
                            context,
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),

                // ── Form Fields Section ────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    children: [
                      // ── First Name Field ───────────────────────────────────────
                      _buildTextField(
                        context: context,
                        controller: firstNameController,
                        label: l10n.first_name,
                        enabled: editMode && !isLoading,
                      ),
                      SizedBox(height: 16.h),

                      // ── Last Name Field ────────────────────────────────────────
                      _buildTextField(
                        context: context,
                        controller: lastNameController,
                        label: l10n.last_name,
                        enabled: editMode && !isLoading,
                      ),
                      SizedBox(height: 16.h),

                      // ── Phone Number Field ─────────────────────────────────────
                      _buildTextField(
                        context: context,
                        controller: phoneController,
                        label: l10n.phone_number,
                        enabled: editMode && !isLoading,
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 32.h),

                      // ── Edit Account Button (Only visible when not in edit mode) ──
                      if (!editMode)
                        _buildEditAccountButton(
                          context,
                          l10n,
                          isLoading,
                          isEditMode,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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
          CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3.w,
          ),
          SizedBox(height: 16.h),
          Text(
            l10n.profile_loading,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Avatar Widget ──────────────────────────────────────────────────────────
  Widget _buildAvatar(
    BuildContext context,
    String? avatarUrl,
    bool isLoading,
    ValueNotifier<File?> selectedImage,
    VoidCallback onTap,
  ) {
    final imageUrl = _buildFullImageUrl(avatarUrl);

    return ValueListenableBuilder<File?>(
      valueListenable: selectedImage,
      builder: (context, image, _) {
        return GestureDetector(
          onTap: isLoading ? null : onTap,
          child: Hero(
            tag: 'profile_avatar_edit',
            child: Stack(
              children: [
                // ── Avatar Circle with Shadow ──────────────────────────────────────
                Container(
                  width: 120.w,
                  height: 120.w,
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
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.surface,
                        width: 4.w,
                      ),
                    ),
                    child: ClipOval(
                      child: image != null
                          ? Image.file(
                              image,
                              fit: BoxFit.cover,
                            )
                          : imageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: AppColors.grey200,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.w,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      _buildAvatarPlaceholder(),
                                )
                              : _buildAvatarPlaceholder(),
                    ),
                  ),
                ),

                // ── Camera Icon Overlay with Gradient ──────────────────────────────
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 36.w,
                    height: 36.w,
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
                      border: Border.all(
                        color: AppColors.surface,
                        width: 3.w,
                      ),
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
                      size: 18.w,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      color: AppColors.grey200,
      child: Icon(
        Icons.person_rounded,
        size: 60.w,
        color: AppColors.textSecondary,
      ),
    );
  }

  String? _buildFullImageUrl(String? avatarUrl) {
    if (avatarUrl == null || avatarUrl.isEmpty) return null;

    if (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://')) {
      if (avatarUrl.contains('/users/avatars/')) {
        return avatarUrl.replaceAll('/users/avatars/', '/storage/avatars/');
      }
      return avatarUrl;
    }

    final baseUrl = ApiConstants.baseUrl.replaceAll('/api/v1', '');
    String cleanPath = avatarUrl;
    if (!cleanPath.startsWith('/storage/') && !cleanPath.startsWith('storage/')) {
      cleanPath = '/storage/$cleanPath';
    } else if (!cleanPath.startsWith('/')) {
      cleanPath = '/$cleanPath';
    }

    return '$baseUrl$cleanPath';
  }

  // ── Text Field Widget ──────────────────────────────────────────────────────
  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required bool enabled,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label ──────────────────────────────────────────────────────────
        Padding(
          padding: EdgeInsetsDirectional.only(start: 4.w, bottom: 8.h),
          child: Text(
            label,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        // ── Text Field ─────────────────────────────────────────────────────
        SizedBox(
          height: 56.h,
          child: TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            textInputAction: TextInputAction.next,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
            ),
            decoration: InputDecoration(
              hintText: label,
              hintStyle: AppTextStyles.customStyle(
                context,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDisabled,
              ),
              contentPadding: EdgeInsetsDirectional.symmetric(
                horizontal: 16.w,
                vertical: 18.h,
              ),
              isDense: true,
              filled: true,
              fillColor: enabled ? AppColors.surface : AppColors.grey200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: AppColors.divider,
                  width: 1.5.w,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: AppColors.divider,
                  width: 1.5.w,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: AppColors.grey200,
                  width: 1.5.w,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: AppColors.primary,
                  width: 1.5.w,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Edit Account Button ────────────────────────────────────────────────────
  Widget _buildEditAccountButton(
    BuildContext context,
    AppLocalizations l10n,
    bool isLoading,
    ValueNotifier<bool> isEditMode,
  ) {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : () => isEditMode.value = true,
          borderRadius: BorderRadius.circular(12.r),
          child: Center(
            child: Text(
              l10n.edit_account,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPER FUNCTIONS FOR PHOTO ACTIONS
// ─────────────────────────────────────────────────────────────────────────────

/// View Photo in Full Screen
void _viewPhoto(BuildContext context, String? imageUrl, File? localImage) {
  if (imageUrl == null && localImage == null) return;

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => FullScreenPhotoViewer(
        imageUrl: imageUrl,
        localImage: localImage,
        heroTag: 'profile_avatar_edit',
      ),
    ),
  );
}

/// Pick Image from Camera or Gallery
Future<void> _pickImage(
  BuildContext context,
  ImageSource source,
  ValueNotifier<File?> selectedImage,
  ValueNotifier<bool> isEditMode,
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

    selectedImage.value = File(pickedFile.path);
    isEditMode.value = true;
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

/// Remove Photo
void _removePhoto(
  BuildContext context,
  ValueNotifier<File?> selectedImage,
  ValueNotifier<bool> isEditMode,
) {
  selectedImage.value = null;
  isEditMode.value = true;
  
  // Trigger API call to remove avatar
  final params = UpdateProfileParams(removeAvatar: 1);
  context.read<ProfileCubit>().updateProfile(params);
}
