import 'package:coupon/config/routes/app_router.dart';
import 'package:coupon/features/permissions/presentation/cubit/permission_flow_cubit.dart';
import 'package:coupon/features/permissions/presentation/cubit/permission_flow_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../widgets/organisms/permission_content_card.dart';

/// Location Intro Page
/// Asks user for location permission
/// Shows rationale before requesting
class LocationIntroPage extends StatelessWidget {
  const LocationIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocListener<PermissionFlowCubit, PermissionFlowState>(
          listener: (context, state) {
            // Navigate to map after permission granted
            if (state.navSignal == PermissionNavigationSignal.toLocationMap) {
              context.go(AppRouter.permissionLocationMap);
              context.read<PermissionFlowCubit>().clearNavigationSignal();
            }
            // Navigate to notification intro if permission denied
            else if (state.navSignal ==
                PermissionNavigationSignal.toNotificationIntro) {
              context.go(AppRouter.permissionNotificationIntro);
              context.read<PermissionFlowCubit>().clearNavigationSignal();
            }
            // Navigate to error page if there's an error
            else if (state.navSignal ==
                PermissionNavigationSignal.toLocationError) {
              context.go(AppRouter.permissionLocationError);
              context.read<PermissionFlowCubit>().clearNavigationSignal();
            }
          },
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical: 40.h),
              child: BlocBuilder<PermissionFlowCubit, PermissionFlowState>(
                builder: (context, state) {
                  return PermissionContentCard(
                    iconAssetPath: 'assets/icons/location.png',
                    title: 'الموقع',
                    subtitle:
                        'السماح للتطبيق بالوصول إلى موقعك أثناء استخدامك للتطبيق؟',
                    primaryButtonText: 'سماح',
                    onPrimaryPressed: () {
                      // Request location permission
                      context
                          .read<PermissionFlowCubit>()
                          .requestLocationPermission();
                    },
                    isPrimaryLoading: state.isRequestingLocation,
                    skipButtonText: 'تخطي الآن',
                    onSkipPressed: () {
                      // Skip to notification
                      context.read<PermissionFlowCubit>().skipCurrentStep();
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
