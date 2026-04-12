import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/buttons/app_primary_button.dart';
import '../../widgets/shared_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PRIVACY POLICY PAGE
// ─────────────────────────────────────────────────────────────────────────────

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(context, l10n),
      body: SafeArea(
        bottom: true,
        child: _buildBody(context, l10n),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(
      BuildContext context, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      title: Text(
        l10n.privacy_policy_title,
        style: AppTextStyles.customStyle(
          context,
          fontSize: 18,
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
    final sections = [
      _PolicySection(
        title: l10n.privacy_policy_section1_title,
        content: l10n.privacy_policy_section1_content,
      ),
      _PolicySection(
        title: l10n.privacy_policy_section2_title,
        content: l10n.privacy_policy_section2_content,
      ),
      _PolicySection(
        title: l10n.privacy_policy_section3_title,
        content: l10n.privacy_policy_section3_content,
      ),
      _PolicySection(
        title: l10n.privacy_policy_section4_title,
        content: l10n.privacy_policy_section4_content,
      ),
      _PolicySection(
        title: l10n.privacy_policy_section5_title,
        content: l10n.privacy_policy_section5_content,
      ),
    ];

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12.h),

                // ── Last Updated ──────────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Text(
                    l10n.privacy_policy_last_updated,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),

                // ── Sections ──────────────────────────────────────────────────
                ...sections.map((s) => _buildSection(context, s)),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),

        // ── Agree Button ──────────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
          child: AppPrimaryButton(
            text: l10n.privacy_agree_button,
            height: 56.h,
            backgroundColor: AppColors.primary,
            textStyle: AppTextStyles.customStyle(
              context,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            onPressed: () => context.pop(),
          ),
        ),
      ],
    );
  }

  // ── Section Widget ─────────────────────────────────────────────────────────
  Widget _buildSection(BuildContext context, _PolicySection section) {
    return SharedProfileCard(
      title: '',
      onTap: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            section.content,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION MODEL
// ─────────────────────────────────────────────────────────────────────────────

class _PolicySection {
  final String title;
  final String content;

  const _PolicySection({required this.title, required this.content});
}
