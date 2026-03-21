import 'package:coupon/config/routes/app_router.dart';
import 'package:coupon/core/localization/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../widgets/organisms/permission_content_card.dart';

/// Permission Splash Page
/// First screen that asks user if they want to go through permissions
/// or skip directly to login
class PermissionSplashPage extends StatelessWidget {
  const PermissionSplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: PermissionContentCard(
              iconAssetPath: 'assets/icons/permissions_splash.png',
              title: l10n.permissions_splash_title,
              subtitle: l10n.permissions_splash_subtitle,
              primaryButtonText: l10n.allow,
              onPrimaryPressed: () {
                context.go(AppRouter.permissionLocationIntro);
              },
              skipButtonText: l10n.skipNow,
              onSkipPressed: () {
                context.go('/login');
              },
            ),
          ),
        ),
      ),
    );
  }
}
