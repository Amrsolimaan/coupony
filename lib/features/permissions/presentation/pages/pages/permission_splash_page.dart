import 'package:coupon/config/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: PermissionContentCard(
              // Using asset path - you'll need to add the actual asset
              iconAssetPath: 'assets/icons/permissions_splash.png',
              // Or use a custom widget:
              // iconWidget: Row(
              //   mainAxisSize: MainAxisSize.min,
              //   children: [
              //     Icon(Icons.notifications, size: 48.w, color: Theme.of(context).primaryColor),
              //     SizedBox(width: 16.w),
              //     Icon(Icons.location_on, size: 48.w, color: Theme.of(context).primaryColor),
              //   ],
              // ),
              title: 'السماح بالوصول إلى الموقع والإشعارات',
              subtitle:
                  'سنستخدم موقعك لعرض الخدمات القريبة منك، والإشعارات لإبقائك على اطلاع بآخر التحديثات',
              primaryButtonText: 'سماح',
              onPrimaryPressed: () {
                // Navigate to location intro
                // context.read<PermissionFlowCubit>().goToStep(1);
                // Or use router:
                context.go(AppRouter.permissionLocationIntro);
              },
              skipButtonText: 'تخطي الآن',
              onSkipPressed: () {
                // Skip entire flow
                // context.read<PermissionFlowCubit>().skipEntireFlow();
                // Or use router:
                context.go('/login');
              },
            ),
          ),
        ),
      ),
    );
  }
}
