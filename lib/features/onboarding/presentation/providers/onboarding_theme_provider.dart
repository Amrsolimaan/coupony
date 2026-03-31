import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../onboarding/domain/entities/onboarding_user_type.dart';

/// Provides role-based theming for onboarding screens
/// SOURCE OF TRUTH: OnboardingUserType (derived from UserEntity.role)
class OnboardingThemeProvider {
  final OnboardingUserType userType;

  const OnboardingThemeProvider(this.userType);

  /// Primary color based on user role
  Color get primaryColor {
    return userType == OnboardingUserType.seller
        ? AppColors.primary_of_saller
        : AppColors.primary;
  }

  /// Get primary color with opacity
  Color primaryWithOpacity(double opacity) {
    return primaryColor.withValues(alpha: opacity);
  }

  /// Check if current user is seller
  bool get isSeller => userType == OnboardingUserType.seller;

  /// Check if current user is customer
  bool get isCustomer => userType == OnboardingUserType.customer;
}
