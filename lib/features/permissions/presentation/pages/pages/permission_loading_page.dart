import 'package:coupony/config/routes/app_router.dart';
import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:coupony/features/permissions/presentation/cubit/permission_flow_cubit.dart';
import 'package:coupony/features/permissions/presentation/cubit/permission_flow_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Permission Loading Page
/// Final loading screen after permissions are completed
/// Shows progress animation before navigating to home/auth
class PermissionLoadingPage extends StatelessWidget {
  const PermissionLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocListener<PermissionFlowCubit, PermissionFlowState>(
          listener: (context, state) {
            // Navigate to onboarding when loading is complete
            if (state.navSignal == PermissionNavigationSignal.toOnboarding) {
              context.go(AppRouter.onboarding);
              context.read<PermissionFlowCubit>().clearNavigationSignal();
            }
            // Keep home navigation for backward compatibility
            if (state.navSignal == PermissionNavigationSignal.toHome) {
              context.go(AppRouter.home);
              context.read<PermissionFlowCubit>().clearNavigationSignal();
            }
          },
          child: Center(
            child: BlocBuilder<PermissionFlowCubit, PermissionFlowState>(
              builder: (context, state) {
                // Get progress from state
                final double progress = state.loadingProgress;

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Logo or Icon
                      FaIcon(
                        FontAwesomeIcons.circleCheck,
                        size: 90.w,
                        color: Theme.of(context).primaryColor,
                      ),

                      SizedBox(height: 40.h),

                      // Loading Text
                      Text(
                        l10n.permissions_loading_preparing,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 40.h),

                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3.r),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6.h,
                          backgroundColor: AppColors.grey200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Progress Text
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 14,
                          color: AppColors.grey600,
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Status Messages (optional)
                      Text(
                        _getLoadingMessage(context, progress),
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Get loading message based on progress
  String _getLoadingMessage(BuildContext context, double progress) {
    final l10n = AppLocalizations.of(context)!;
    
    if (progress < 0.4) {
      return l10n.permissions_loading_checking;
    } else if (progress < 0.7) {
      return l10n.permissions_loading_data;
    } else {
      return l10n.permissions_loading_complete;
    }
  }
}
