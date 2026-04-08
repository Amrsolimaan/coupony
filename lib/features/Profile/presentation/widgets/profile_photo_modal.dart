import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODERN PROFILE PHOTO MODAL BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────

class ProfilePhotoModal {
  /// Show modern modal bottom sheet for profile photo actions
  static Future<void> show({
    required BuildContext context,
    required String? currentPhotoUrl,
    required Function(File) onPhotoSelected,
    required VoidCallback onPhotoRemove,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ProfilePhotoModalContent(
        currentPhotoUrl: currentPhotoUrl,
        onPhotoSelected: onPhotoSelected,
        onPhotoRemove: onPhotoRemove,
        l10n: l10n,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MODAL CONTENT WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class _ProfilePhotoModalContent extends StatelessWidget {
  final String? currentPhotoUrl;
  final Function(File) onPhotoSelected;
  final VoidCallback onPhotoRemove;
  final AppLocalizations l10n;

  const _ProfilePhotoModalContent({
    required this.currentPhotoUrl,
    required this.onPhotoSelected,
    required this.onPhotoRemove,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Handle Bar ─────────────────────────────────────────────────────
            _buildHandleBar(),

            // ── Modal Options ──────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                children: [
                  // View Photo Option
                  if (currentPhotoUrl != null && currentPhotoUrl!.isNotEmpty)
                    _buildOption(
                      context: context,
                      icon: Icons.visibility_outlined,
                      label: l10n.profile_photo_view,
                      onTap: () {
                        Navigator.pop(context);
                        _showFullScreenPhoto(context, currentPhotoUrl!);
                      },
                    ),

                  if (currentPhotoUrl != null && currentPhotoUrl!.isNotEmpty)
                    SizedBox(height: 8.h),

                  // Change Photo Option
                  _buildOption(
                    context: context,
                    icon: Icons.edit_outlined,
                    label: l10n.profile_photo_change,
                    onTap: () {
                      Navigator.pop(context);
                      _showImageSourceOptions(context);
                    },
                  ),

                  SizedBox(height: 8.h),

                  // Remove Photo Option (Destructive)
                  if (currentPhotoUrl != null && currentPhotoUrl!.isNotEmpty)
                    _buildOption(
                      context: context,
                      icon: Icons.delete_outline_rounded,
                      label: l10n.profile_photo_remove,
                      isDestructive: true,
                      onTap: () {
                        Navigator.pop(context);
                        _showRemoveConfirmation(context);
                      },
                    ),
                ],
              ),
            ),

            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  // ── Handle Bar Widget ──────────────────────────────────────────────────────
  Widget _buildHandleBar() {
    return Container(
      margin: EdgeInsets.only(top: 12.h, bottom: 20.h),
      width: 40.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }

  // ── Build Option Widget ────────────────────────────────────────────────────
  Widget _buildOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: isDestructive
                ? AppColors.error.withValues(alpha: 0.05)
                : AppColors.grey200.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDestructive
                  ? AppColors.error.withValues(alpha: 0.2)
                  : AppColors.divider,
              width: 1.w,
            ),
          ),
          child: Row(
            children: [
              // ── Icon Container ─────────────────────────────────────────────
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: isDestructive
                      ? AppColors.error.withValues(alpha: 0.1)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  size: 22.w,
                  color: isDestructive ? AppColors.error : AppColors.primary,
                ),
              ),
              SizedBox(width: 16.w),

              // ── Label ──────────────────────────────────────────────────────
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDestructive
                        ? AppColors.error
                        : AppColors.textPrimary,
                  ),
                ),
              ),

              // ── Arrow Icon ─────────────────────────────────────────────────
              if (!isDestructive)
                Icon(
                  Icons.arrow_back_ios_rounded,
                  size: 16.w,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Show Full Screen Photo ─────────────────────────────────────────────────
  void _showFullScreenPhoto(BuildContext context, String photoUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullScreenPhotoViewer(imageUrl: photoUrl),
      ),
    );
  }

  // ── Show Image Source Options ──────────────────────────────────────────────
  void _showImageSourceOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHandleBar(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  children: [
                    // Camera Option
                    _buildOption(
                      context: context,
                      icon: Icons.camera_alt_outlined,
                      label: l10n.profile_photo_camera,
                      onTap: () async {
                        Navigator.pop(context);
                        await _pickImage(context, ImageSource.camera);
                      },
                    ),
                    SizedBox(height: 8.h),

                    // Gallery Option
                    _buildOption(
                      context: context,
                      icon: Icons.photo_library_outlined,
                      label: l10n.profile_photo_gallery,
                      onTap: () async {
                        Navigator.pop(context);
                        await _pickImage(context, ImageSource.gallery);
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  // ── Show Remove Confirmation ───────────────────────────────────────────────
  void _showRemoveConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHandleBar(),
              SizedBox(height: 12.h),

              // Warning Icon
              Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 32.w,
                  color: AppColors.error,
                ),
              ),
              SizedBox(height: 20.h),

              // Title
              Text(
                l10n.profile_photo_remove_confirm_title,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),

              // Message
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Text(
                  l10n.profile_photo_remove_confirm_message,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 32.h),

              // Action Buttons
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    // Delete Button
                    _buildConfirmButton(
                      context: context,
                      label: l10n.profile_photo_remove_confirm_button,
                      onTap: () {
                        Navigator.pop(context);
                        onPhotoRemove();
                      },
                      isDestructive: true,
                    ),
                    SizedBox(height: 12.h),

                    // Cancel Button
                    _buildConfirmButton(
                      context: context,
                      label: l10n.profile_photo_remove_cancel_button,
                      onTap: () => Navigator.pop(context),
                      isDestructive: false,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build Confirmation Button ──────────────────────────────────────────────
  Widget _buildConfirmButton({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
    required bool isDestructive,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: isDestructive
                ? AppColors.error
                : AppColors.grey200.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDestructive ? AppColors.error : AppColors.divider,
              width: 1.w,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDestructive ? Colors.white : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // ── Pick Image ─────────────────────────────────────────────────────────────
  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        onPhotoSelected(File(pickedFile.path));
      }
    } catch (e) {
      // Handle error silently or show a snackbar
      debugPrint('Error picking image: $e');
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FULL SCREEN PHOTO VIEWER
// ─────────────────────────────────────────────────────────────────────────────

class _FullScreenPhotoViewer extends StatelessWidget {
  final String imageUrl;

  const _FullScreenPhotoViewer({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Photo ──────────────────────────────────────────────────────────
          Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Hero(
                  tag: 'profile_photo',
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 3.w,
                      ),
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.error_outline_rounded,
                      size: 64.w,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Close Button ───────────────────────────────────────────────────
          SafeArea(
            child: Align(
              alignment: AlignmentDirectional.topEnd,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1.5.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 24.w,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
