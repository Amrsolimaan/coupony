import 'package:coupony/config/dependency_injection/injection_container.dart' as di;
import 'package:coupony/config/routes/app_router.dart';
import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../auth/data/datasources/auth_local_data_source.dart';
import '../widgets/atoms/permission_icon.dart';
import '../widgets/atoms/permission_primary_button.dart';

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
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 44.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                PermissionIcon(
                  icon: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.group_outlined,
                      color: Colors.white,
                      size: 48.w,
                    ),
                  ),
                  size: 100.w,
                  showShadow: false,
                ),
                SizedBox(height: 20.h),
                // Title
                Text(
                  l10n.welcome_gateway_title,
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 12.h),
                // Subtitle
                Text(
                  l10n.welcome_gateway_subtitle,
                  style: TextStyle(
                    fontFamily: 'NotoNaskhArabic',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                    letterSpacing: 0,
                    color: const Color.fromARGB(255, 114, 113, 113),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40.h),
                // Sign In button
                PermissionPrimaryButton(
                  text: l10n.welcome_gateway_login,
                  onPressed: () => context.go(AppRouter.login),
                  width: 185.w,
                  height: 48.h,
                  isFullWidth: false,
                ),
                SizedBox(height: 12.h),
                // Guest button
                PermissionPrimaryButton(
                  text: l10n.welcome_gateway_guest,
                  onPressed: () async {
                    await di.sl<AuthLocalDataSource>().cacheGuestStatus(true);
                    if (context.mounted) context.go(AppRouter.home);
                  },
                  width: 185.w,
                  height: 48.h,
                  isFullWidth: false,
                  backgroundColor: const Color(0xFFBDBDBD),
                  textColor: AppColors.textPrimary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}