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

/// Seller Delivery Method Screen (UI ONLY - No Cubit/Repository)
/// Step 3 of 4 in Seller Onboarding Flow
class SellerDeliveryMethodScreen extends StatefulWidget {
  const SellerDeliveryMethodScreen({super.key});

  @override
  State<SellerDeliveryMethodScreen> createState() =>
      _SellerDeliveryMethodScreenState();
}

class _SellerDeliveryMethodScreenState
    extends State<SellerDeliveryMethodScreen> {
  String? _selectedMethod;

  final _theme = const OnboardingThemeProvider(OnboardingUserType.seller);

  bool get _isValid => _selectedMethod != null;

  void _onNext() {
    if (_isValid) {
      Navigator.pushNamed(context, '/seller_target_audience');
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
              currentStep: 3,
              totalSteps: 4,
              theme: _theme,
            ),

            SizedBox(height: 32.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                l10n.seller_delivery_method_title,
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
                    title: l10n.seller_delivery_method_physical,
                    icon: Icons.storefront,
                    isSelected: _selectedMethod == 'physical',
                    onTap: () =>
                        setState(() => _selectedMethod = 'physical'),
                    theme: _theme,
                  ),
                  SizedBox(height: 12.h),
                  SelectionOptionCard(
                    title: l10n.seller_delivery_method_online,
                    icon: Icons.phone_android,
                    isSelected: _selectedMethod == 'online',
                    onTap: () =>
                        setState(() => _selectedMethod = 'online'),
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