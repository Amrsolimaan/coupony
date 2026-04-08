import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routes/app_router.dart';
import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HELP & SUPPORT PAGE
// ─────────────────────────────────────────────────────────────────────────────

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, l10n),
      body: _buildBody(context, l10n),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: true,
      title: Text(
        l10n.help_support_title,
        style: AppTextStyles.customStyle(
          context,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          size: 20.w,
          color: AppColors.textPrimary,
        ),
        onPressed: () => context.pop(),
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────
  Widget _buildBody(BuildContext context, AppLocalizations l10n) {
    final menuItems = [
      _HelpMenuItem(
        title: l10n.help_faq_title,
        subtitle: l10n.help_faq_subtitle,
        onTap: () => context.push(AppRouter.faqPage),
      ),
      _HelpMenuItem(
        title: l10n.help_usage_guide_title,
        subtitle: l10n.help_usage_guide_subtitle,
        onTap: () => context.push(AppRouter.usageGuidePage),
      ),
      _HelpMenuItem(
        title: l10n.help_report_problem_title,
        subtitle: l10n.help_report_problem_subtitle,
        onTap: () => context.push(AppRouter.reportProblemPage),
      ),
      _HelpMenuItem(
        title: l10n.help_rate_app_title,
        subtitle: l10n.help_rate_app_subtitle,
        onTap: () => context.push(AppRouter.rateAppPage),
      ),
      _HelpMenuItem(
        title: l10n.help_terms_title,
        subtitle: l10n.help_terms_subtitle,
        onTap: () => context.push(AppRouter.termsPage),
      ),
      _HelpMenuItem(
        title: l10n.help_contact_us_title,
        subtitle: l10n.help_contact_us_subtitle,
        onTap: () => context.push(AppRouter.contactUsPage),
      ),
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 16.h),
          ...menuItems.map((item) => _buildMenuItem(context, item)),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  // ── Menu Item Widget ───────────────────────────────────────────────────────
  Widget _buildMenuItem(BuildContext context, _HelpMenuItem item) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              children: [
                // ── Text Content ──────────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        item.subtitle,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Arrow Icon ────────────────────────────────────────────────
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELP MENU ITEM MODEL
// ─────────────────────────────────────────────────────────────────────────────

class _HelpMenuItem {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HelpMenuItem({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
