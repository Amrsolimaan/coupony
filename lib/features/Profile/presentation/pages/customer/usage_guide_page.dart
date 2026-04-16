import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../auth/domain/entities/user_persona.dart';
import '../../../../auth/presentation/cubit/persona_cubit.dart';
import '../../../../auth/presentation/widgets/role_animation_wrapper.dart';
import '../../widgets/shared_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// USAGE GUIDE PAGE
// ─────────────────────────────────────────────────────────────────────────────

class UsageGuidePage extends StatelessWidget {
  const UsageGuidePage({super.key});

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
        l10n.help_usage_guide_title,
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
        
        final guideSteps = isSeller
            ? [
                _GuideStep(
                  stepNumber: '1',
                  title: l10n.guide_seller_step1_title,
                  description: l10n.guide_seller_step1_desc,
                  icon: Icons.store_rounded,
                ),
                _GuideStep(
                  stepNumber: '2',
                  title: l10n.guide_seller_step2_title,
                  description: l10n.guide_seller_step2_desc,
                  icon: Icons.add_business_rounded,
                ),
                _GuideStep(
                  stepNumber: '3',
                  title: l10n.guide_seller_step3_title,
                  description: l10n.guide_seller_step3_desc,
                  icon: Icons.analytics_rounded,
                ),
                _GuideStep(
                  stepNumber: '4',
                  title: l10n.guide_seller_step4_title,
                  description: l10n.guide_seller_step4_desc,
                  icon: Icons.people_rounded,
                ),
                _GuideStep(
                  stepNumber: '5',
                  title: l10n.guide_seller_step5_title,
                  description: l10n.guide_seller_step5_desc,
                  icon: Icons.trending_up_rounded,
                ),
              ]
            : [
                _GuideStep(
                  stepNumber: '1',
                  title: l10n.guide_step1_title,
                  description: l10n.guide_step1_desc,
                  icon: Icons.person_add_rounded,
                ),
                _GuideStep(
                  stepNumber: '2',
                  title: l10n.guide_step2_title,
                  description: l10n.guide_step2_desc,
                  icon: Icons.search_rounded,
                ),
                _GuideStep(
                  stepNumber: '3',
                  title: l10n.guide_step3_title,
                  description: l10n.guide_step3_desc,
                  icon: Icons.local_offer_rounded,
                ),
                _GuideStep(
                  stepNumber: '4',
                  title: l10n.guide_step4_title,
                  description: l10n.guide_step4_desc,
                  icon: Icons.content_copy_rounded,
                ),
                _GuideStep(
                  stepNumber: '5',
                  title: l10n.guide_step5_title,
                  description: l10n.guide_step5_desc,
                  icon: Icons.shopping_bag_rounded,
                ),
              ];

        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 12.h),
              ...guideSteps.map((step) => _buildGuideCard(context, step)),
              SizedBox(height: 24.h),
            ],
          ),
        );
      },
    );
  }

  // ── Guide Step Card ────────────────────────────────────────────────────────
  Widget _buildGuideCard(BuildContext context, _GuideStep step) {
    return SharedProfileCard(
      title: '',
      onTap: null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Step Icon Circle ────────────────────────────────────────────────
          AnimatedPrimaryColor(
            builder: (context, primaryColor) {
              return Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    step.icon,
                    size: 20.w,
                    color: primaryColor,
                  ),
                ),
              );
            },
          ),
          SizedBox(width: 14.w),

          // ── Content ─────────────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${step.stepNumber}. ${step.title}',
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  step.description,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GUIDE STEP MODEL
// ─────────────────────────────────────────────────────────────────────────────

class _GuideStep {
  final String stepNumber;
  final String title;
  final String description;
  final IconData icon;

  const _GuideStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.icon,
  });
}
