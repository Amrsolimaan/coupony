import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routes/app_router.dart';
import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../widgets/shared_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HELP & SUPPORT PAGE
// ─────────────────────────────────────────────────────────────────────────────

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(context, l10n),
      body: SafeArea(bottom: true, child: _buildBody(context, l10n)),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      title: Text(
        l10n.help_support_title,
        style: AppTextStyles.customStyle(
          context,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 20.w,
          color: AppColors.textPrimary,
        ),
        onPressed: () => context.pop(),
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────
  Widget _buildBody(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 12.h),
          SharedProfileCard(
            title: l10n.help_faq_title,
            subtitle: l10n.help_faq_subtitle,
            onTap: () => context.push(AppRouter.faqPage),
          ),
          SharedProfileCard(
            title: l10n.help_usage_guide_title,
            subtitle: l10n.help_usage_guide_subtitle,
            onTap: () => context.push(AppRouter.usageGuidePage),
          ),
          SharedProfileCard(
            title: l10n.help_report_problem_title,
            subtitle: l10n.help_report_problem_subtitle,
            onTap: () => context.push(AppRouter.reportProblemPage),
          ),
          SharedProfileCard(
            title: l10n.help_rate_app_title,
            subtitle: l10n.help_rate_app_subtitle,
            onTap: () => context.push(AppRouter.rateAppPage),
          ),
          SharedProfileCard(
            title: l10n.help_terms_title,
            subtitle: l10n.help_terms_subtitle,
            onTap: () => context.push(AppRouter.termsPage),
          ),
          SharedProfileCard(
            title: l10n.help_contact_us_title,
            subtitle: l10n.help_contact_us_subtitle,
            onTap: () => context.push(AppRouter.contactUsPage),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}
