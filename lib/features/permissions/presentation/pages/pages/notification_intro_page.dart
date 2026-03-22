import 'package:coupony/config/routes/app_router.dart';
import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/features/permissions/presentation/cubit/permission_flow_cubit.dart';
import 'package:coupony/features/permissions/presentation/cubit/permission_flow_state.dart';
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
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocListener<PermissionFlowCubit, PermissionFlowState>(
          listener: (context, state) {
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
                    title: l10n.notificationPermissionTitle,
                    subtitle: l10n.notificationPermissionSubtitle,
                    primaryButtonText: l10n.allow,
                    onPrimaryPressed: () {
                      context
                          .read<PermissionFlowCubit>()
                          .requestNotificationPermission();
                    },
                    isPrimaryLoading: state.isRequestingNotification,
                    skipButtonText: l10n.skipNow,
                    onSkipPressed: () {
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
