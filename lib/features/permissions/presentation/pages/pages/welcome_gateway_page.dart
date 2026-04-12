import 'package:coupony/config/dependency_injection/injection_container.dart' as di;
import 'package:coupony/config/routes/app_router.dart';
import 'package:coupony/core/constants/storage_keys.dart';
import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../auth/data/datasources/auth_local_data_source.dart';

/// Welcome Gateway Page
/// Shown after permissions flow completes.
/// User can sign in (→ onboarding) or continue as guest (→ home).
class WelcomeGatewayPage extends StatelessWidget {
  const WelcomeGatewayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          child: Column(
            children: [
              const Spacer(flex: 2),
              
              // Icon
              Container(
                width: 120.w,
                height: 120.w,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.userGroup,
                    color: Colors.white,
                    size: 56.w,
                  ),
                ),
              ),
              
              SizedBox(height: 32.h),
              
              // Title
              Text(
                l10n.welcome_gateway_title,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 24.h),
              
              // Subtitle
              Text(
                l10n.welcome_gateway_subtitle,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.6,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(flex: 1),
              
              // Sign In button
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: () async {
                    // Mark that user has passed welcome gateway
                    await di.sl<SharedPreferences>().setBool(
                      StorageKeys.hasPassedWelcomeGateway, 
                      true,
                    );
                    if (context.mounted) context.go(AppRouter.login);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    l10n.welcome_gateway_login,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // Guest button (Outline style with shadow)
              Container(
                width: double.infinity,
                height: 56.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: OutlinedButton(
                  onPressed: () async {
                    // Mark that user has passed welcome gateway
                    await di.sl<SharedPreferences>().setBool(
                      StorageKeys.hasPassedWelcomeGateway, 
                      true,
                    );
                    await di.sl<AuthLocalDataSource>().cacheGuestStatus(true);
                    if (context.mounted) context.go(AppRouter.home);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(
                      color: AppColors.primary,
                      width: 1.5.w,
                    ),
                    backgroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    l10n.welcome_gateway_guest,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}