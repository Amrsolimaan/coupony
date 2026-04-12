import 'package:coupony/config/routes/app_router.dart';
import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:coupony/core/storage/secure_storage_service.dart';
import 'package:coupony/core/constants/storage_keys.dart';
import 'package:coupony/core/widgets/providers_theme/coupony_theme_provider.dart';
import 'package:coupony/config/dependency_injection/injection_container.dart' as di;
import 'package:coupony/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:coupony/features/user_flow/CustomerOnboarding/domain/entities/onboarding_user_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Onboarding Completion Loading Page
/// Final loading screen after onboarding is completed
/// Shows progress animation before navigating to permission flow
class OnboardingCompletionLoadingPage extends StatefulWidget {
  const OnboardingCompletionLoadingPage({super.key});

  @override
  State<OnboardingCompletionLoadingPage> createState() =>
      _OnboardingCompletionLoadingPageState();
}

class _OnboardingCompletionLoadingPageState
    extends State<OnboardingCompletionLoadingPage> {
  double _progress = 0.0;
  OnboardingUserType _userType = OnboardingUserType.customer;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _startLoadingAnimation();
  }

  /// Load user role from secure storage
  Future<void> _loadUserRole() async {
    try {
      final secureStorage = di.sl<SecureStorageService>();
      // ✅ Now uses getPrimaryRole() which reads from roles array
      final authLocalDs = di.sl<AuthLocalDataSource>();
      final role = await authLocalDs.getPrimaryRole();
      if (mounted) {
        setState(() {
          _userType = OnboardingUserType.fromRole(role);
        });
      }
    } catch (e) {
      // Default to customer if error
      if (mounted) {
        setState(() {
          _userType = OnboardingUserType.customer;
        });
      }
    }
  }

  /// Simulate loading progress for better UX
  Future<void> _startLoadingAnimation() async {
    // Capture router before any async gap
    final router = GoRouter.of(context);

    // Step 1: Saving preferences (33%)
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _progress = 0.33);

    // Step 2: Preparing your experience (66%)
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _progress = 0.66);

    // Step 3: Almost there (100%)
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _progress = 1.0);

    // Wait a bit before navigating
    await Future.delayed(const Duration(milliseconds: 300));

    // Navigate to home using pre-captured router
    if (mounted) {
      router.go(AppRouter.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = CouponyThemeProvider(_userType);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success Icon
                Icon(
                  Icons.check_circle_outline,
                  size: 100.w,
                  color: theme.primaryColor,
                ),

                SizedBox(height: 40.h),

                // Loading Text
                Text(
                  theme.isSeller
                      ? l10n.onboarding_loading_preparing_seller
                      : l10n.onboarding_loading_preparing,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 40.h),

                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(3.r),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 6.h,
                    backgroundColor: AppColors.grey200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.primaryColor,
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // Progress Text
                Text(
                  '${(_progress * 100).toInt()}%',
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 14,
                    color: AppColors.grey600,
                  ),
                ),

                SizedBox(height: 24.h),

                // Status Messages
                Text(
                  _getLoadingMessage(context, _progress, theme),
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Get loading message based on progress and user role
  String _getLoadingMessage(
    BuildContext context,
    double progress,
    CouponyThemeProvider theme,
  ) {
    final l10n = AppLocalizations.of(context)!;

    if (theme.isSeller) {
      // Messages for merchant
      if (progress < 0.4) {
        return l10n.onboarding_loading_saving_seller;
      } else if (progress < 0.7) {
        return l10n.onboarding_loading_preparing_experience_seller;
      } else {
        return l10n.onboarding_loading_complete_seller;
      }
    } else {
      // Messages for customer
      if (progress < 0.4) {
        return l10n.onboarding_loading_saving;
      } else if (progress < 0.7) {
        return l10n.onboarding_loading_preparing_experience;
      } else {
        return l10n.onboarding_loading_complete;
      }
    }
  }
}
