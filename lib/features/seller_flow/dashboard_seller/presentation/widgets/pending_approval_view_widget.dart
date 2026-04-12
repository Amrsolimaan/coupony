import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:coupony/core/widgets/images/app_cached_image.dart';
import 'package:coupony/features/auth/presentation/cubit/login_cubit.dart';
import 'package:coupony/features/auth/presentation/cubit/auth_state.dart';
import 'package:coupony/features/Profile/presentation/cubit/Customer_Profile_cubit.dart';
import 'package:coupony/features/Profile/presentation/cubit/Customer_Profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PENDING APPROVAL VIEW WIDGET (Content only - no Scaffold, no bottom bar)
// ─────────────────────────────────────────────────────────────────────────────

class PendingApprovalViewWidget extends StatefulWidget {
  final VoidCallback onContactUs;
  final IconData icon;

  const PendingApprovalViewWidget({
    super.key,
    required this.onContactUs,
    this.icon = FontAwesomeIcons.store,
  });

  @override
  State<PendingApprovalViewWidget> createState() => _PendingApprovalViewWidgetState();
}

class _PendingApprovalViewWidgetState extends State<PendingApprovalViewWidget> {
  @override
  void initState() {
    super.initState();
    // Load user profile when view is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileCubit>().loadProfile();
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          l10n.logout_dialog_title,
          style: AppTextStyles.customStyle(
            context,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryOfSeller,
          ),
        ),
        content: Text(
          l10n.logout_dialog_message,
          style: AppTextStyles.customStyle(
            context,
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              l10n.logout_dialog_cancel,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              l10n.logout_dialog_confirm,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryOfSeller,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<LoginCubit>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return BlocListener<LoginCubit, AuthState>(
      listenWhen: (previous, current) =>
          previous.navSignal != current.navSignal &&
          current.navSignal == AuthNavigation.toLogin,
      listener: (context, state) {
        context.go('/login');
      },
      child: Column(
        children: [
          // ── Top Bar ──────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logout button on the left (LTR) or right (RTL)
                  if (!isRTL)
                    BlocBuilder<LoginCubit, AuthState>(
                      builder: (context, state) {
                        if (state.isLoading) {
                          return Padding(
                            padding: EdgeInsets.all(12.w),
                            child: SizedBox(
                              width: 24.w,
                              height: 24.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation(
                                  AppColors.primaryOfSeller,
                                ),
                              ),
                            ),
                          );
                        }

                        return IconButton(
                          icon: FaIcon(
                            FontAwesomeIcons.arrowRightFromBracket,
                            color: AppColors.primaryOfSeller,
                            size: 22.w,
                          ),
                          tooltip: l10n.logout,
                          onPressed: () => _handleLogout(context),
                        );
                      },
                    ),

                  // Title and Avatar together
                  BlocBuilder<ProfileCubit, ProfileState>(
                    builder: (context, state) {
                      String? avatarUrl;
                      if (state is ProfileLoaded) {
                        avatarUrl = state.user.avatar;
                      } else if (state is ProfileUpdateSuccess) {
                        avatarUrl = state.user.avatar;
                      }

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isRTL) ...[
                            // LTR: Avatar first, then text
                            AppCachedImageCircular(
                              imageUrl: avatarUrl ?? '',
                              size: 40.w,
                              borderWidth: 2.w,
                              borderColor: AppColors.primaryOfSeller,
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              l10n.seller_pending_approval_title,
                              style: AppTextStyles.customStyle(
                                context,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ] else ...[
                            // RTL: Text first, then avatar
                            Text(
                              l10n.seller_pending_approval_title,
                              style: AppTextStyles.customStyle(
                                context,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            AppCachedImageCircular(
                              imageUrl: avatarUrl ?? '',
                              size: 40.w,
                              borderWidth: 2.w,
                              borderColor: AppColors.primaryOfSeller,
                            ),
                          ],
                        ],
                      );
                    },
                  ),

                  // Logout button on the right (RTL) or left (LTR)
                  if (isRTL)
                    BlocBuilder<LoginCubit, AuthState>(
                      builder: (context, state) {
                        if (state.isLoading) {
                          return Padding(
                            padding: EdgeInsets.all(12.w),
                            child: SizedBox(
                              width: 24.w,
                              height: 24.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation(
                                  AppColors.primaryOfSeller,
                                ),
                              ),
                            ),
                          );
                        }

                        return IconButton(
                          icon: FaIcon(
                            FontAwesomeIcons.arrowRightFromBracket,
                            color: AppColors.primaryOfSeller,
                            size: 22.w,
                          ),
                          tooltip: l10n.logout,
                          onPressed: () => _handleLogout(context),
                        );
                      },
                    )
                  else
                    SizedBox(width: 48.w), // Balance for LTR
                ],
              ),
            ),
          ),

          // ── Content ──────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      color: AppColors.primaryOfSeller.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: FaIcon(
                        widget.icon,
                        size: 48.sp,
                        color: AppColors.primaryOfSeller,
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Text(
                    l10n.seller_pending_approval_message,
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
                  Text(
                    l10n.seller_pending_approval_subtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Contact Us Link ──────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.seller_pending_contact_prefix,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(width: 4.w),
                GestureDetector(
                  onTap: widget.onContactUs,
                  child: Text(
                    l10n.seller_pending_contact_link,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryOfSeller,
                    ).copyWith(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}
