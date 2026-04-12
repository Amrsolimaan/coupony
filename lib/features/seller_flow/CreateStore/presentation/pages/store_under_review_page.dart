import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:coupony/features/auth/presentation/cubit/login_cubit.dart';
import 'package:coupony/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// STORE UNDER REVIEW PAGE  (redesigned — compact & modern)
//
// Shown when ALL of the seller's stores have status == 'pending'.
// Provides direct WhatsApp and Email contact channels with no excessive
// vertical spacers.
// ─────────────────────────────────────────────────────────────────────────────

class StoreUnderReviewPage extends StatelessWidget {
  const StoreUnderReviewPage({super.key});

  static const _whatsAppNumber = '201000724083';
  static const _supportEmail   = 'coupony8@gmail.com';
  static const _sellerColor    = AppColors.primaryOfSeller;

  // ── Logout handler ─────────────────────────────────────────────────────────

  Future<void> _handleLogout(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          l10n.logout_dialog_title,
          style: AppTextStyles.customStyle(
            context,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _sellerColor,
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
                color: _sellerColor,
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

  // ── URL launchers ──────────────────────────────────────────────────────────

  Future<void> _openWhatsApp(BuildContext context) async {
    final uri = Uri.parse('https://wa.me/$_whatsAppNumber');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // WhatsApp not installed — silently ignore
    }
  }

  Future<void> _openEmail(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final uri  = Uri(
      scheme:  'mailto',
      path:    _supportEmail,
      queryParameters: {
        'subject': l10n.under_review_title,
        'body':    l10n.under_review_body,
      },
    );
    if (!await launchUrl(uri)) {
      // No email client — silently ignore
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

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
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              // ── Logout button ──────────────────────────────────────────────
              Positioned(
                top: 16.h,
                left: isRTL ? null : 16.w,
                right: isRTL ? 16.w : null,
                child: BlocBuilder<LoginCubit, AuthState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return Padding(
                        padding: EdgeInsets.all(12.w),
                        child: SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation(_sellerColor),
                          ),
                        ),
                      );
                    }
                    
                    return IconButton(
                      icon: FaIcon(
                        FontAwesomeIcons.arrowRightFromBracket,
                        color: _sellerColor,
                        size: 22.w,
                      ),
                      tooltip: l10n.logout,
                      onPressed: () => _handleLogout(context),
                    );
                  },
                ),
              ),

              // ── Main content ───────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 24.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
              // ── Pending icon ───────────────────────────────────────────────
              Container(
                width: 96.w,
                height: 96.w,
                decoration: BoxDecoration(
                  color: _sellerColor.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: FaIcon(
                  FontAwesomeIcons.hourglassHalf,
                  size: 48.w,
                  color: _sellerColor,
                ),
              ),
              SizedBox(height: 28.h),

              // ── Title ──────────────────────────────────────────────────────
              Text(
                l10n.under_review_title,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _sellerColor,
                  height: 1.3,
                  letterSpacing: -0.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),

              // ── Body ───────────────────────────────────────────────────────
              Text(
                l10n.under_review_body,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.65,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40.h),

              // ── Contact support card ───────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: _sellerColor.withValues(alpha: 0.12),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _sellerColor.withValues(alpha: 0.07),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.contact_support,
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // WhatsApp button
                    _ContactButton(
                      icon: FontAwesomeIcons.whatsapp,
                      label: l10n.store_under_review_whatsapp_button,
                      color: const Color(0xFF25D366),
                      onTap: () => _openWhatsApp(context),
                    ),
                    SizedBox(height: 10.h),

                    // Email button
                    _ContactButton(
                      icon: FontAwesomeIcons.envelope,
                      label: l10n.store_under_review_email_button,
                      color: _sellerColor,
                      onTap: () => _openEmail(context),
                    ),
                  ],
                ),
              ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
);
  }
}

// ── Private contact button widget ─────────────────────────────────────────────

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String   label;
  final Color    color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.09),
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              FaIcon(icon, color: color, size: 20.w),
              SizedBox(width: 12.w),
              Text(
                label,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const Spacer(),
              FaIcon(
                FontAwesomeIcons.chevronRight,
                color: color.withValues(alpha: 0.6),
                size: 12.w,
              ),
            ],
          ),
        ),
      ),
    );
  }
}