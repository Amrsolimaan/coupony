import 'package:coupony/features/user_flow/CustomerOnboarding/domain/entities/onboarding_user_type.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Provides role-based theming for onboarding screens
/// SOURCE OF TRUTH: OnboardingUserType (derived from UserEntity.role)
class CouponyThemeProvider {
  final OnboardingUserType userType;

  const CouponyThemeProvider(this.userType);

  /// Primary color based on user role
  Color get primaryColor {
    return userType == OnboardingUserType.seller
        ? AppColors.primaryOfSeller
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
