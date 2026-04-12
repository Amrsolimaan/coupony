import 'package:coupony/config/routes/app_router.dart';
import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/services/location_service.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:coupony/core/utils/message_formatter.dart';
import 'package:coupony/features/permissions/presentation/cubit/permission_flow_cubit.dart';
import 'package:coupony/features/permissions/presentation/cubit/permission_flow_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/organisms/permission_content_card.dart';

/// Location Error Page
/// Shown when location permission fails or is denied
/// Offers retry or settings option
///
/// ✅ FIXED FEATURES:
/// - Better error messages based on error type
/// - Proper handling of different error states
/// - Clear user guidance for each scenario
class LocationErrorPage extends StatefulWidget {
  const LocationErrorPage({super.key});

  @override
  State<LocationErrorPage> createState() => _LocationErrorPageState();
}

class _LocationErrorPageState extends State<LocationErrorPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Register observer to detect when app resumes (returns from settings)
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Unregister observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // ✅ App came to foreground (possibly from Settings)
      // Trigger check for GPS/Permission status
      context.read<PermissionFlowCubit>().checkLocationStatusOnResume();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocListener<PermissionFlowCubit, PermissionFlowState>(
          listener: (context, state) {
            if (state.navSignal == PermissionNavigationSignal.toLocationIntro) {
              context.go(AppRouter.permissionLocationIntro);
              context.read<PermissionFlowCubit>().clearNavigationSignal();
            } else if (state.navSignal ==
                PermissionNavigationSignal.toLocationMap) {
              context.go(AppRouter.permissionLocationMap);
              context.read<PermissionFlowCubit>().clearNavigationSignal();
            } else if (state.navSignal ==
                PermissionNavigationSignal.toNotificationIntro) {
              context.go(AppRouter.permissionNotificationIntro);
              context.read<PermissionFlowCubit>().clearNavigationSignal();
            }
          },
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical: 40.h),
              child: BlocBuilder<PermissionFlowCubit, PermissionFlowState>(
                builder: (context, state) {
                  if (state.isRequestingLocation) {
                    return _buildLoadingView(context);
                  }

                  final l10n = AppLocalizations.of(context)!;

                  // ✅ Determine error type and customize messaging
                  final bool isPermanentlyDenied =
                      state.isLocationPermanentlyDenied;
                  final bool isServiceDisabled =
                      state.locationStatus ==
                      LocationPermissionStatus.serviceDisabled;
                  final bool hasError = state.messageKey != null;

                  // ✅ Build appropriate error message
                  String subtitle;
                  String primaryButtonText;

                  if (isServiceDisabled) {
                    // GPS is turned off
                    subtitle = hasError
                        ? context.getLocalizedMessage(state.messageKey)
                        : l10n.location_error_service_disabled;
                    primaryButtonText = l10n.location_error_open_settings;
                  } else if (isPermanentlyDenied) {
                    // Permission permanently denied
                    subtitle = l10n.location_error_permanently_denied;
                    primaryButtonText = l10n.location_error_open_app_settings;
                  } else if (hasError) {
                    // Custom error message from cubit
                    subtitle = context.getLocalizedMessage(state.messageKey);
                    primaryButtonText = l10n.location_error_retry;
                  } else {
                    // Generic error
                    subtitle = l10n.location_error_generic;
                    primaryButtonText = l10n.location_error_retry;
                  }

                  return PermissionContentCard(
                    iconAssetPath: 'assets/icons/location_error.png',
                    title: l10n.locationPermissionTitle,
                    subtitle: subtitle,
                    primaryButtonText: primaryButtonText,
                    onPrimaryPressed: () {
                      // ✅ Retry or open settings based on status
                      context
                          .read<PermissionFlowCubit>()
                          .retryLocationPermission();
                    },
                    // We handle loading with full screen view now
                    isPrimaryLoading: false,
                    skipButtonText: l10n.location_error_skip,
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

  /// ✅ UPDATED: Loading layout fully matching PermissionLoadingPage
  Widget _buildLoadingView(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon matching permission_loading_page style
          FaIcon(
            FontAwesomeIcons.locationCrosshairs,
            size: 90.w,
            color: Theme.of(context).primaryColor,
          ),

          SizedBox(height: 40.h),

          // Loading Text
          Text(
            l10n.location_error_checking,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 40.h),

          // Progress Bar (indeterminate)
          ClipRRect(
            borderRadius: BorderRadius.circular(3.r),
            child: LinearProgressIndicator(
              minHeight: 6.h,
              backgroundColor: AppColors.grey200,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // Status Message
          Text(
            l10n.permissions_please_wait,
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
  }
}
