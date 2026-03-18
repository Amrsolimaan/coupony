import 'package:coupon/config/routes/app_router.dart';
import 'package:coupon/features/permissions/presentation/cubit/permission_flow_cubit.dart';
import 'package:coupon/features/permissions/presentation/cubit/permission_flow_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../widgets/organisms/permission_content_card.dart';

/// Notification Intro Page
/// Asks user for notification permission
/// Shows rationale before requesting
class NotificationIntroPage extends StatelessWidget {
  const NotificationIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocListener<PermissionFlowCubit, PermissionFlowState>(
          listener: (context, state) {
            // Navigate to loading page after notification permission is handled
            if (state.navSignal == PermissionNavigationSignal.toLoading) {
              context.go(AppRouter.permissionLoading);
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
                    iconAssetPath: 'assets/icons/notification.png',
                    title: 'إشعارات',
                    subtitle: 'يرجى تمكين الإشعارات لتلقى التحديثات والتذكيرات',
                    primaryButtonText: 'سماح',
                    onPrimaryPressed: () {
                      // Request notification permission
                      context
                          .read<PermissionFlowCubit>()
                          .requestNotificationPermission();
                    },
                    isPrimaryLoading: state.isRequestingNotification,
                    skipButtonText: 'تخطي الآن',
                    onSkipPressed: () {
                      // Skip to completion
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