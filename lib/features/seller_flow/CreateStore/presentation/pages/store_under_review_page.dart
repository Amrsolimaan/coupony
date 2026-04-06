import 'package:coupony/config/routes/app_router.dart';
import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:coupony/core/widgets/buttons/app_primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

// ─────────────────────────────────────────────────────────────────────────────
// STORE UNDER REVIEW PAGE
//
// Shown after a seller successfully submits their store for review.
// Provides links to Home and a pre-filled WhatsApp message to support.
// ─────────────────────────────────────────────────────────────────────────────

class StoreUnderReviewPage extends StatelessWidget {
  const StoreUnderReviewPage({super.key});

  static const _whatsAppNumber = '201000724083'; // 01000724083 in E.164

  Future<void> _openWhatsApp(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final message = Uri.encodeComponent(
      '${l10n.store_under_review_contact_button} — ${l10n.store_under_review_title}',
    );
    final uri = Uri.parse('https://wa.me/$_whatsAppNumber?text=$message');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Silently ignore — WhatsApp not installed or launch failed
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: 28.w),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Review Icon ─────────────────────────────────────────────
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryOfSeller.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.hourglass_top_rounded,
                  size: 52.w,
                  color: AppColors.primaryOfSeller,
                ),
              ),
              SizedBox(height: 32.h),

              // ── Title ────────────────────────────────────────────────────
              Text(
                l10n.store_under_review_title,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryOfSeller,
                  height: 1.3,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 14.h),

              // ── Subtitle ─────────────────────────────────────────────────
              Text(
                l10n.store_under_review_subtitle,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3),

              // ── Primary Button: Home ──────────────────────────────────────
              AppPrimaryButton(
                text: l10n.store_under_review_home_button,
                height: 56.h,
                backgroundColor: AppColors.primaryOfSeller,
                textStyle: AppTextStyles.customStyle(
                  context,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                onPressed: () => context.go(AppRouter.merchantDashboard),
              ),
              SizedBox(height: 14.h),

              // ── Secondary Button: Contact Us (WhatsApp) ──────────────────
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: OutlinedButton(
                  onPressed: () => _openWhatsApp(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.primaryOfSeller,
                      width: 1.5.w,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    l10n.store_under_review_contact_button,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryOfSeller,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 28.h),
            ],
          ),
        ),
      ),
    );
  }
}
