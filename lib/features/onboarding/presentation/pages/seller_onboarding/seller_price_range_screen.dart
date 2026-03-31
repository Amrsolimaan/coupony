import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:coupony/core/widgets/buttons/app_button_variants.dart';
import 'package:coupony/core/widgets/buttons/app_outlined_button.dart';
import 'package:coupony/core/widgets/buttons/app_primary_button.dart';
import 'package:coupony/features/onboarding/domain/entities/onboarding_user_type.dart';
import 'package:coupony/features/onboarding/presentation/providers/onboarding_theme_provider.dart';
import 'package:coupony/features/onboarding/presentation/widgets/category_card.dart';
import 'package:coupony/features/onboarding/presentation/widgets/onboarding_submit_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Seller Price Range Screen (UI ONLY - No Cubit/Repository)
/// Step 2 of 4 in Seller Onboarding Flow
class SellerPriceRangeScreen extends StatefulWidget {
  const SellerPriceRangeScreen({super.key});

  @override
  State<SellerPriceRangeScreen> createState() => _SellerPriceRangeScreenState();
}

class _SellerPriceRangeScreenState extends State<SellerPriceRangeScreen> {
  String? _selectedPriceRange;

  final _theme = const OnboardingThemeProvider(OnboardingUserType.seller);

  bool get _isValid => _selectedPriceRange != null;

  void _onNext() {
    if (_isValid) {
      Navigator.pushNamed(context, '/seller_delivery_method');
    }
  }

  void _onSkip() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 24.h),

            OnboardingStepIndicator(
              currentStep: 2,
              totalSteps: 4,
              theme: _theme,
            ),

            SizedBox(height: 32.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                l10n.seller_price_range_title,
                textAlign: TextAlign.center,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 24.h),

            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                children: [
                  SelectionOptionCard(
                    title: l10n.seller_price_range_economic,
                    subtitle: l10n.seller_price_range_economic_subtitle,
                    icon: Icons.percent,
                    isSelected: _selectedPriceRange == 'economic',
                    onTap: () =>
                        setState(() => _selectedPriceRange = 'economic'),
                    theme: _theme,
                  ),
                  SizedBox(height: 12.h),
                  SelectionOptionCard(
                    title: l10n.seller_price_range_medium,
                    subtitle: l10n.seller_price_range_medium_subtitle,
                    icon: Icons.balance,
                    isSelected: _selectedPriceRange == 'medium',
                    onTap: () =>
                        setState(() => _selectedPriceRange = 'medium'),
                    theme: _theme,
                  ),
                  SizedBox(height: 12.h),
                  SelectionOptionCard(
                    title: l10n.seller_price_range_premium,
                    subtitle: l10n.seller_price_range_premium_subtitle,
                    icon: Icons.workspace_premium,
                    isSelected: _selectedPriceRange == 'premium',
                    onTap: () =>
                        setState(() => _selectedPriceRange = 'premium'),
                    theme: _theme,
                  ),
                  SizedBox(height: 12.h),
                  SelectionOptionCard(
                    title: l10n.seller_price_range_all_levels,
                    subtitle: l10n.seller_price_range_all_levels_subtitle,
                    icon: Icons.layers,
                    isSelected: _selectedPriceRange == 'all',
                    onTap: () => setState(() => _selectedPriceRange = 'all'),
                    theme: _theme,
                  ),
                ],
              ),
            ),

            _buildActionButtons(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Row(
        children: [
          Expanded(
            child: AppOutlinedButton(
              text: l10n.skip,
              onPressed: _onSkip,
              size: AppButtonSize.medium,
              borderRadius: 12.r,
              borderWidth: 1.5.w,
              borderColor: _theme.primaryColor,
              textColor: _theme.primaryColor,
              padding: EdgeInsets.symmetric(vertical: 8.h),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: AppPrimaryButton(
              text: l10n.next,
              onPressed: _isValid ? _onNext : null,
              size: AppButtonSize.medium,
              borderRadius: 12.r,
              backgroundColor: _theme.primaryColor,
              padding: EdgeInsets.symmetric(vertical: 8.h),
            ),
          ),
        ],
      ),
    );
  }
}