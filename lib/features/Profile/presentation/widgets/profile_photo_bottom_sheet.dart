import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODERN PROFILE PHOTO BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────

class ProfilePhotoBottomSheet {
  /// Show modern bottom sheet with photo options
  static Future<ProfilePhotoAction?> show({
    required BuildContext context,
    required bool hasPhoto,
    String? photoUrl,
    File? localPhoto,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    return await showModalBottomSheet<ProfilePhotoAction>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ProfilePhotoBottomSheetContent(
        hasPhoto: hasPhoto,
        photoUrl: photoUrl,
        localPhoto: localPhoto,
        l10n: l10n,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTTOM SHEET CONTENT
// ─────────────────────────────────────────────────────────────────────────────

class _ProfilePhotoBottomSheetContent extends StatelessWidget {
  final bool hasPhoto;
  final String? photoUrl;
  final File? localPhoto;
  final AppLocalizations l10n;

  const _ProfilePhotoBottomSheetContent({
    required this.hasPhoto,
    required this.photoUrl,
    required this.localPhoto,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28.r),
              topRight: Radius.circular(28.r),
            ),
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
              // ── Handle Bar ─────────────────────────────────────────────────
              SizedBox(height: 12.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 24.h),

              // ── View Photo Option ──────────────────────────────────────────
              if (hasPhoto)
                _buildOption(
                  context: context,
                  icon: Icons.visibility_outlined,
                  title: l10n.profile_photo_view,
                  onTap: () => Navigator.pop(context, ProfilePhotoAction.view),
                ),

              // ── Change Photo Option ────────────────────────────────────────
              _buildOption(
                context: context,
                icon: Icons.photo_camera_outlined,
                title: l10n.profile_photo_change,
                onTap: () => _showChangePhotoOptions(context),
                showDivider: hasPhoto,
              ),

              // ── Remove Photo Option ────────────────────────────────────────
              if (hasPhoto)
                _buildOption(
                  context: context,
                  icon: Icons.delete_outline_rounded,
                  title: l10n.profile_photo_remove,
                  onTap: () => _showRemoveConfirmation(context),
                  isDestructive: true,
                  showDivider: false,
                ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onTap();
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Row(
                children: [
                  // ── Icon ───────────────────────────────────────────────────
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

                  // ── Title ──────────────────────────────────────────────────
                  Expanded(
                    child: Text(
                      title,
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

                  // ── Arrow Icon ─────────────────────────────────────────────
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
        ),

        // ── Divider ────────────────────────────────────────────────────────
        if (showDivider)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Divider(
              height: 1.h,
              thickness: 1.h,
              color: AppColors.divider,
            ),
          ),
      ],
    );
  }

  void _showChangePhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ChangePhotoOptionsSheet(l10n: l10n),
    );
  }

  void _showRemoveConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _RemovePhotoConfirmationSheet(l10n: l10n),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CHANGE PHOTO OPTIONS SHEET
// ─────────────────────────────────────────────────────────────────────────────

class _ChangePhotoOptionsSheet extends StatelessWidget {
  final AppLocalizations l10n;

  const _ChangePhotoOptionsSheet({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28.r),
              topRight: Radius.circular(28.r),
            ),
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
              // ── Handle Bar ─────────────────────────────────────────────────
              SizedBox(height: 12.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 24.h),

              // ── Camera Option ──────────────────────────────────────────────
              _buildSubOption(
                context: context,
                icon: Icons.camera_alt_outlined,
                title: l10n.profile_photo_camera,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context, ProfilePhotoAction.camera);
                },
              ),

              // ── Divider ────────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Divider(
                  height: 1.h,
                  thickness: 1.h,
                  color: AppColors.divider,
                ),
              ),

              // ── Gallery Option ─────────────────────────────────────────────
              _buildSubOption(
                context: context,
                icon: Icons.photo_library_outlined,
                title: l10n.profile_photo_gallery,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context, ProfilePhotoAction.gallery);
                },
              ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Row(
            children: [
              // ── Icon ───────────────────────────────────────────────────────
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  size: 22.w,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 16.w),

              // ── Title ──────────────────────────────────────────────────────
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REMOVE PHOTO CONFIRMATION SHEET
// ─────────────────────────────────────────────────────────────────────────────

class _RemovePhotoConfirmationSheet extends StatelessWidget {
  final AppLocalizations l10n;

  const _RemovePhotoConfirmationSheet({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28.r),
              topRight: Radius.circular(28.r),
            ),
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
              // ── Handle Bar ─────────────────────────────────────────────────
              SizedBox(height: 12.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 24.h),

              // ── Warning Icon ───────────────────────────────────────────────
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

              // ── Title ──────────────────────────────────────────────────────
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

              // ── Message ────────────────────────────────────────────────────
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

              // ── Action Buttons ─────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    // Delete Button
                    _buildConfirmButton(
                      context: context,
                      label: l10n.profile_photo_remove_confirm_button,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pop(context, ProfilePhotoAction.remove);
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

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
    required bool isDestructive,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
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
              color: isDestructive
                  ? AppColors.error
                  : AppColors.divider,
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
}

// ─────────────────────────────────────────────────────────────────────────────
// PROFILE PHOTO ACTION ENUM
// ─────────────────────────────────────────────────────────────────────────────

enum ProfilePhotoAction {
  view,
  camera,
  gallery,
  remove,
}

// ─────────────────────────────────────────────────────────────────────────────
// HAPTIC FEEDBACK HELPER
// ─────────────────────────────────────────────────────────────────────────────

class HapticFeedback {
  static void lightImpact() {
    // Add haptic feedback if needed
  }
}
