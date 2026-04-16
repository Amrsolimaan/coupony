import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/buttons/app_primary_button.dart';
import '../../../../auth/domain/entities/user_persona.dart';
import '../../../../auth/presentation/cubit/persona_cubit.dart';
import '../../../../auth/presentation/widgets/role_animation_wrapper.dart';
import '../../widgets/shared_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TERMS & CONDITIONS PAGE
// ─────────────────────────────────────────────────────────────────────────────

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

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
  PreferredSizeWidget _buildAppBar(
      BuildContext context, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      title: Text(
        l10n.help_terms_title,
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
    return BlocBuilder<PersonaCubit, UserPersona>(
      builder: (context, persona) {
        final isSeller = persona is SellerPersona;

        final termsSections = isSeller
            ? [
                _TermsSection(
                  title: l10n.terms_seller_section1_title,
                  content: l10n.terms_seller_section1_content,
                ),
                _TermsSection(
                  title: l10n.terms_seller_section2_title,
                  content: l10n.terms_seller_section2_content,
                ),
                _TermsSection(
                  title: l10n.terms_seller_section3_title,
                  content: l10n.terms_seller_section3_content,
                ),
                _TermsSection(
                  title: l10n.terms_seller_section4_title,
                  content: l10n.terms_seller_section4_content,
                ),
                _TermsSection(
                  title: l10n.terms_seller_section5_title,
                  content: l10n.terms_seller_section5_content,
                ),
                _TermsSection(
                  title: l10n.terms_seller_section6_title,
                  content: l10n.terms_seller_section6_content,
                ),
              ]
            : [
                _TermsSection(
                  title: l10n.terms_section1_title,
                  content: l10n.terms_section1_content,
                ),
                _TermsSection(
                  title: l10n.terms_section2_title,
                  content: l10n.terms_section2_content,
                ),
                _TermsSection(
                  title: l10n.terms_section3_title,
                  content: l10n.terms_section3_content,
                ),
                _TermsSection(
                  title: l10n.terms_section4_title,
                  content: l10n.terms_section4_content,
                ),
                _TermsSection(
                  title: l10n.terms_section5_title,
                  content: l10n.terms_section5_content,
                ),
                _TermsSection(
                  title: l10n.terms_section6_title,
                  content: l10n.terms_section6_content,
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

                    // ── Last Updated ────────────────────────────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Text(
                        l10n.terms_last_updated,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // ── Terms Sections ──────────────────────────────────────────
                    ...termsSections
                        .map((section) => _buildSection(context, section)),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),

            // ── Agree Button ──────────────────────────────────────────────────────
            AnimatedPrimaryColor(
              builder: (context, primaryColor) {
                return Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
                  child: AppPrimaryButton(
                    text: l10n.terms_agree_button,
                    height: 56.h,
                    backgroundColor: primaryColor,
                    textStyle: AppTextStyles.customStyle(
                      context,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    onPressed: () => context.pop(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // ── Section Widget ─────────────────────────────────────────────────────────
  Widget _buildSection(BuildContext context, _TermsSection section) {
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
// TERMS SECTION MODEL
// ─────────────────────────────────────────────────────────────────────────────

class _TermsSection {
  final String title;
  final String content;

  const _TermsSection({required this.title, required this.content});
}
