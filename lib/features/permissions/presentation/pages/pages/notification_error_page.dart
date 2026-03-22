import 'package:coupony/config/routes/app_router.dart';
import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/features/permissions/presentation/cubit/permission_flow_cubit.dart';
import 'package:coupony/features/permissions/presentation/cubit/permission_flow_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../widgets/organisms/permission_content_card.dart';

/// Notification Error Page
/// Shown when notification permission fails or is denied
/// Offers retry or settings option
class NotificationErrorPage extends StatelessWidget {
  const NotificationErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocListener<PermissionFlowCubit, PermissionFlowState>(
          listener: (context, state) {
            if (state.navSignal == PermissionNavigationSignal.toLoading) {
              context.go(AppRouter.permissionLoading);
              context.read<PermissionFlowCubit>().clearNavigationSignal();
            } else if (state.navSignal == PermissionNavigationSignal.toHome) {
              context.go(AppRouter.home);
              context.read<PermissionFlowCubit>().clearNavigationSignal();
            }
          },
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical: 40.h),
              child: BlocBuilder<PermissionFlowCubit, PermissionFlowState>(
                builder: (context, state) {
                  final l10n = AppLocalizations.of(context)!;
                  return PermissionContentCard(
                    iconAssetPath: 'assets/icons/notification_error.png',
                    title: l10n.notification_error_title,
                    subtitle: l10n.notification_error_subtitle,
                    primaryButtonText: l10n.notification_error_retry,
                    onPrimaryPressed: () {
                      context
                          .read<PermissionFlowCubit>()
                          .retryNotificationPermission();
                    },
                    isPrimaryLoading: state.isRequestingNotification,
                    skipButtonText: l10n.location_error_skip,
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
