import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/services/location_service.dart';
import '../../domain/repositories/permission_repository.dart';
import '../../domain/use_cases/check_permission_status_use_case.dart';
import '../../domain/use_cases/determine_next_permission_step_use_case.dart';
import '../../domain/use_cases/get_address_from_coordinates_use_case.dart';
import '../../domain/use_cases/request_location_permission_use_case.dart';
import 'permission_flow_state.dart';

/// Permission Flow Cubit
/// Manages the permission flow for location and notifications.
///
/// PRIVACY COMPLIANCE:
/// - Follows Google Play & App Store guidelines
/// - Shows rationale BEFORE requesting permissions
/// - Handles graceful degradation on denial
/// - Never batches permission requests
/// - Each permission tied to user action
///
/// Note: This Cubit uses a custom state (PermissionFlowState) instead of BaseState
/// because it manages complex UI flow with multiple steps, navigation signals,
/// and validation flags that don't fit the simple BaseState pattern.
class PermissionFlowCubit extends Cubit<PermissionFlowState> {
  final CheckPermissionStatusUseCase checkPermissionStatusUseCase;
  final RequestLocationPermissionUseCase requestLocationPermissionUseCase;
  final DetermineNextPermissionStepUseCase determineNextPermissionStepUseCase;
  final GetAddressFromCoordinatesUseCase geocodingUseCase;
  final PermissionRepository repository;
  final NotificationService notificationService;
  final Logger logger;

  PermissionFlowCubit({
    required this.checkPermissionStatusUseCase,
    required this.requestLocationPermissionUseCase,
    required this.determineNextPermissionStepUseCase,
    required this.geocodingUseCase,
    required this.repository,
    required this.logger,
    required this.notificationService,
  }) : super(const PermissionFlowState());

  // ════════════════════════════════════════════════════════
  // SAFE EMIT
  // ════════════════════════════════════════════════════════

  void _safeEmit(PermissionFlowState newState) {
    if (!isClosed) emit(newState);
  }

  // ════════════════════════════════════════════════════════
  // INITIALIZATION
  // ════════════════════════════════════════════════════════

  Future<void> initializeFlow() async {
    logger.i('🚀 Initializing Permission Flow...');
    await _loadExistingPermissions();
  }

  Future<void> _loadExistingPermissions() async {
    final result = await repository.getPermissionStatus();

    result.fold(
      (failure) {
        logger.d('No existing permissions found - starting fresh');
        final nextStep = determineNextPermissionStepUseCase.execute(
          locationStatus: LocationPermissionStatus.notRequested,
          notificationStatus: NotificationPermissionStatus.notRequested,
          hasCompletedFlow: false,
          isLocationServiceEnabled: true,
        );
        _safeEmit(
          state.copyWith(
            currentStep: nextStep.step,
            navSignal: nextStep.signal,
          ),
        );
      },
      (status) {
        if (status != null && status.hasCompletedFlow) {
          final nextStep = determineNextPermissionStepUseCase.execute(
            locationStatus: _mapStringToLocationStatus(status.locationStatus),
            notificationStatus: _mapStringToNotificationStatus(
              status.notificationStatus,
            ),
            hasCompletedFlow: status.hasCompletedFlow,
            isLocationServiceEnabled: true,
            hasPosition: status.hasLocation,
          );
          _safeEmit(
            state.copyWith(
              locationStatus: _mapStringToLocationStatus(status.locationStatus),
              notificationStatus: _mapStringToNotificationStatus(
                status.notificationStatus,
              ),
              fcmToken: status.fcmToken,
              hasCompletedFlow: status.hasCompletedFlow,
              userPosition: status.hasLocation
                  ? _createPosition(status.latitude!, status.longitude!)
                  : null,
              currentStep: nextStep.step,
              isCompleted: true,
              navSignal: nextStep.signal,
            ),
          );
          logger.i('User has completed flow before - skipping to home');
        } else {
          final nextStep = determineNextPermissionStepUseCase.execute(
            locationStatus: LocationPermissionStatus.notRequested,
            notificationStatus: NotificationPermissionStatus.notRequested,
            hasCompletedFlow: false,
            isLocationServiceEnabled: true,
          );
          _safeEmit(
            state.copyWith(
              currentStep: nextStep.step,
              navSignal: nextStep.signal,
            ),
          );
          logger.i(
            'Loaded existing permissions but not completed - starting fresh',
          );
        }
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // LOCATION PERMISSION FLOW
  // ════════════════════════════════════════════════════════

  /// User clicked "Allow" on Location Intro screen.
  ///
  /// ✅ ASYNC GATE FIX: Navigation to the map is immediate after the OS
  /// dialog closes. The GPS fix happens in the background via
  /// [_fetchCurrentPositionWithValidation]. The map renders with the default
  /// position first, then the camera animates to the real GPS position when
  /// it arrives.
  Future<void> requestLocationPermission() async {
    logger.i('User requested location permission (rationale shown)');

    _safeEmit(
      state.copyWith(
        isRequestingLocation: true,
        messageKey: null,
        messageType: null,
      ),
    );

    try {
      final result = await requestLocationPermissionUseCase.execute();

      result.fold(
        (failure) {
          logger.e('Location permission request failed: ${failure.message}');
          _safeEmit(
            state.copyWith(
              isRequestingLocation: false,
              locationStatus: LocationPermissionStatus.error,
              messageKey: failure.message,
              navSignal: PermissionNavigationSignal.toLocationError,
            ),
          );
        },
        (status) {
          logger.i('Location permission status: $status');

          if (status == LocationPermissionStatus.granted ||
              status == LocationPermissionStatus.grantedLimited) {
            // ✅ Navigate to map immediately — don't block on GPS fix
            _safeEmit(
              state.copyWith(
                isRequestingLocation: false,
                locationStatus: status,
                currentStep: 2,
                navSignal: PermissionNavigationSignal.toLocationMap,
              ),
            );
            // Kick off GPS fix in background; map page listens for userPosition
            _fetchCurrentPositionWithValidation().ignore();
          } else if (status == LocationPermissionStatus.serviceDisabled) {
            logger.w('Location service disabled');
            _safeEmit(
              state.copyWith(
                isRequestingLocation: false,
                locationStatus: status,
                messageKey: 'error_location_service_disabled',
                messageType: MessageType.error,
                navSignal: PermissionNavigationSignal.toLocationError,
              ),
            );
          } else {
            // Denied — skip to notification step
            logger.w('Location denied, skipping to notification');
            final nextStep =
                determineNextPermissionStepUseCase.afterSkippingLocation();
            _safeEmit(
              state.copyWith(
                isRequestingLocation: false,
                locationStatus: status,
                currentStep: nextStep.step,
                navSignal: nextStep.signal,
              ),
            );
          }
        },
      );
    } catch (e) {
      logger.e('Unexpected error requesting location: $e');
      _safeEmit(
        state.copyWith(
          isRequestingLocation: false,
          locationStatus: LocationPermissionStatus.error,
          messageKey: 'error_location_unexpected',
          messageType: MessageType.error,
          navSignal: PermissionNavigationSignal.toLocationError,
        ),
      );
    }
  }

  /// Fetches the current GPS position and updates state.
  /// Returns true if a position was successfully obtained.
  Future<bool> _fetchCurrentPositionWithValidation() async {
    logger.d('Fetching current position...');

    final serviceResult = await repository.checkLocationServiceEnabled();
    final serviceEnabled = serviceResult.fold((_) => false, (e) => e);

    if (!serviceEnabled) {
      logger.w('Location service is disabled');
      return false;
    }

    final positionResult = await repository.getCurrentPosition();

    return positionResult.fold(
      (failure) {
        logger.e('Failed to get position: ${failure.message}');
        return false;
      },
      (position) {
        logger.i('✅ Position: ${position.latitude}, ${position.longitude}');
        _safeEmit(state.copyWith(userPosition: position));
        // Fetch address for this position
        getAddressFromCoordinates(position.latitude, position.longitude);
        return true;
      },
    );
  }

  /// Reverse-geocode [lat],[lng] and update state with the resulting address.
  Future<void> getAddressFromCoordinates(double lat, double lng) async {
    try {
      final address = await geocodingUseCase.execute(lat, lng);
      _safeEmit(state.copyWith(currentAddress: address));
    } catch (e) {
      logger.e('Geocoding failed: $e');
      // Always emit a fallback address to stop the loading spinner
      final latDir = lat >= 0 ? 'شمالاً' : 'جنوباً';
      final lngDir = lng >= 0 ? 'شرقاً' : 'غرباً';
      final fallbackAddress = 'الموقع: ${lat.abs().toStringAsFixed(4)}° $latDir، '
          '${lng.abs().toStringAsFixed(4)}° $lngDir';
      _safeEmit(state.copyWith(currentAddress: fallbackAddress));
    }
  }

  /// User clicked "استخدم موقعك الحالي" on the map screen.
  Future<void> useCurrentLocation() async {
    logger.i('User wants to use current location');
    _safeEmit(
      state.copyWith(
        isRequestingLocation: true,
        messageKey: null,
        messageType: null,
      ),
    );

    final success = await _fetchCurrentPositionWithValidation();

    _safeEmit(state.copyWith(isRequestingLocation: false));

    if (!success) {
      logger.w('⚠️ Failed to get current location');
      _safeEmit(
        state.copyWith(
          messageKey: 'error_location_use_current_failed',
          messageType: MessageType.error,
        ),
      );
    }
  }

  /// Check status when returning from settings.
  Future<void> checkLocationStatusOnResume() async {
    logger.d('Checking location status on app resume...');

    _safeEmit(
      state.copyWith(
        isRequestingLocation: true,
        messageKey: null,
        messageType: null,
      ),
    );

    await Future.delayed(const Duration(milliseconds: 1500));

    final serviceResult = await repository.checkLocationServiceEnabled();

    bool isGpsEnabled = false;
    serviceResult.fold(
      (failure) => logger.w('Failed to check GPS: ${failure.message}'),
      (enabled) => isGpsEnabled = enabled,
    );

    if (!isGpsEnabled) {
      logger.d('GPS still disabled on resume');
      _safeEmit(state.copyWith(isRequestingLocation: false));
      return;
    }

    final permissionResult = await repository.getPermissionStatus();

    permissionResult.fold(
      (failure) {
        logger.w('Failed to check permission on resume');
        _safeEmit(state.copyWith(isRequestingLocation: false));
      },
      (status) async {
        final locStatus = _mapStringToLocationStatus(status?.locationStatus);

        if (locStatus == LocationPermissionStatus.granted ||
            locStatus == LocationPermissionStatus.grantedLimited) {
          logger.i('✅ GPS ON + Permission GRANTED on resume');

          final positionFetched = await _fetchCurrentPositionWithValidation();

          if (positionFetched) {
            _safeEmit(
              state.copyWith(
                isRequestingLocation: false,
                currentStep: 2,
                navSignal: PermissionNavigationSignal.toLocationMap,
                messageKey: null,
                messageType: null,
              ),
            );
          } else {
            _safeEmit(state.copyWith(isRequestingLocation: false));
          }
        } else {
          if (state.locationStatus ==
              LocationPermissionStatus.serviceDisabled) {
            logger.i('GPS enabled, retrying permission...');
            retryLocationPermission();
          } else {
            _safeEmit(state.copyWith(isRequestingLocation: false));
          }
        }
      },
    );
  }

  /// User confirmed location on map (clicked "تحديد الموقع").
  void confirmLocation() {
    logger.i('User confirmed location');
    
    // Save the selected location with address to local storage
    if (state.userPosition != null) {
      repository.savePermissionStatus(
        latitude: state.userPosition!.latitude,
        longitude: state.userPosition!.longitude,
        address: state.currentAddress,
      );
      logger.i('✅ Saved location with address: ${state.currentAddress}');
    }
    
    final nextStep =
        determineNextPermissionStepUseCase.afterLocationConfirmed();
    _safeEmit(
      state.copyWith(
        currentStep: nextStep.step,
        navSignal: nextStep.signal,
      ),
    );
  }

  /// User clicked "Try Again" on location error screen.
  Future<void> retryLocationPermission() async {
    logger.i('User retrying location permission');
    _safeEmit(state.copyWith(messageKey: null, messageType: null));

    final serviceResult = await repository.checkLocationServiceEnabled();
    await serviceResult.fold(
      (failure) {
        logger.e('Failed to check location service: ${failure.message}');
        _safeEmit(
          state.copyWith(
            messageKey: 'error_location_gps_check_failed',
            messageType: MessageType.error,
            navSignal: PermissionNavigationSignal.toLocationError,
          ),
        );
      },
      (serviceEnabled) async {
        if (!serviceEnabled) {
          logger.w('Location service is disabled, opening location settings');
          _safeEmit(
            state.copyWith(
              locationStatus: LocationPermissionStatus.serviceDisabled,
              messageKey: 'error_location_service_disabled',
              messageType: MessageType.error,
              navSignal: PermissionNavigationSignal.toLocationError,
            ),
          );
          await Future.delayed(const Duration(milliseconds: 500));
          await _openLocationSettings();
          return;
        }

        final currentStatus = state.locationStatus;

        if (currentStatus == LocationPermissionStatus.permanentlyDenied) {
          logger.w('Location permanently denied, opening app settings');
          await _openLocationSettings();
        } else if (currentStatus == LocationPermissionStatus.granted ||
            currentStatus == LocationPermissionStatus.grantedLimited) {
          logger.i('Permission already granted, retrying position fetch');
          _safeEmit(state.copyWith(isRequestingLocation: true));

          final success = await _fetchCurrentPositionWithValidation();
          _safeEmit(state.copyWith(isRequestingLocation: false));

          if (success) {
            _safeEmit(
              state.copyWith(
                currentStep: 2,
                navSignal: PermissionNavigationSignal.toLocationMap,
              ),
            );
          } else {
            _safeEmit(
              state.copyWith(
                messageKey: 'error_location_weak_signal',
                messageType: MessageType.error,
                navSignal: PermissionNavigationSignal.toLocationError,
              ),
            );
          }
        } else {
          logger.i('Requesting permission again directly (skip intro)');
          await requestLocationPermission();
        }
      },
    );
  }

  Future<void> _openLocationSettings() async {
    final isPermanentlyDenied = state.isLocationPermanentlyDenied;
    final isServiceDisabled =
        state.locationStatus == LocationPermissionStatus.serviceDisabled;

    if (isServiceDisabled) {
      logger.i('Opening device location settings');
      final result = await repository.openLocationSettings();
      result.fold(
        (failure) => _safeEmit(
          state.copyWith(
            messageKey: 'error_settings_open_failed',
            messageType: MessageType.error,
          ),
        ),
        (opened) {
          if (!opened) {
            _safeEmit(
              state.copyWith(
                messageKey: 'info_location_settings_manual',
                messageType: MessageType.info,
              ),
            );
          }
        },
      );
    } else if (isPermanentlyDenied) {
      logger.i('Opening app settings for location permission');
      final result = await repository.openAppSettings();
      result.fold(
        (failure) => _safeEmit(
          state.copyWith(
            messageKey: 'error_settings_app_open_failed',
            messageType: MessageType.error,
          ),
        ),
        (opened) {
          if (!opened) {
            _safeEmit(
              state.copyWith(
                messageKey: 'info_location_app_settings_manual',
                messageType: MessageType.info,
              ),
            );
          }
        },
      );
    }
  }

  // ════════════════════════════════════════════════════════
  // NOTIFICATION PERMISSION FLOW
  // ════════════════════════════════════════════════════════

  Future<void> requestNotificationPermission() async {
    logger.i('User requested notification permission (rationale shown)');

    _safeEmit(
      state.copyWith(
        isRequestingNotification: true,
        messageKey: null,
        messageType: null,
      ),
    );

    try {
      final statusResult = await repository.requestNotificationPermission();

      await statusResult.fold(
        (failure) {
          logger.e(
            'Notification permission request failed: ${failure.message}',
          );
          _safeEmit(
            state.copyWith(
              isRequestingNotification: false,
              notificationStatus: NotificationPermissionStatus.error,
              messageKey: failure.message,
            ),
          );
        },
        (status) async {
          logger.i('Notification permission status: $status');

          String? fcmToken;
          if (status == NotificationPermissionStatus.granted ||
              status == NotificationPermissionStatus.provisional) {
            notificationService.initializeListeners();
            final tokenResult = await repository.getFCMToken();
            tokenResult.fold(
              (_) => logger.w('Failed to get FCM token'),
              (token) {
                fcmToken = token;
                logger.i('FCM Token: ${token?.substring(0, 20)}...');
              },
            );
          }

          _safeEmit(
            state.copyWith(
              isRequestingNotification: false,
              notificationStatus: status,
              fcmToken: fcmToken,
            ),
          );

          final nextStep =
              determineNextPermissionStepUseCase.afterNotificationRequest();
          await _completeFlow(nextStep);
        },
      );
    } catch (e) {
      logger.e('Unexpected error requesting notification: $e');
      _safeEmit(
        state.copyWith(
          isRequestingNotification: false,
          notificationStatus: NotificationPermissionStatus.error,
          messageKey: 'error_notification_unexpected',
          messageType: MessageType.error,
        ),
      );
    }
  }

  Future<void> retryNotificationPermission() async {
    logger.i('User retrying notification permission');
    if (state.isNotificationPermanentlyDenied) {
      logger.w('Notification permanently denied, opening settings');
      await _openNotificationSettings();
    } else {
      await requestNotificationPermission();
    }
  }

  Future<void> _openNotificationSettings() async {
    final result = await repository.openNotificationSettings();
    result.fold(
      (failure) => _safeEmit(
        state.copyWith(
          messageKey: 'error_notification_settings_failed',
          messageType: MessageType.error,
        ),
      ),
      (opened) {
        if (!opened) {
          _safeEmit(
            state.copyWith(
              messageKey: 'info_notification_settings_manual',
              messageType: MessageType.info,
            ),
          );
        }
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // SKIP FUNCTIONALITY
  // ════════════════════════════════════════════════════════

  void skipCurrentStep() {
    logger.i('User skipped step ${state.currentStep}');
    if (state.currentStep == 1 || state.currentStep == 2) {
      final nextStep =
          determineNextPermissionStepUseCase.afterSkippingLocation();
      _safeEmit(
        state.copyWith(
          currentStep: nextStep.step,
          navSignal: nextStep.signal,
        ),
      );
    } else if (state.currentStep == 3 || state.currentStep == 4) {
      final nextStep =
          determineNextPermissionStepUseCase.afterSkippingNotification();
      _safeEmit(
        state.copyWith(
          currentStep: nextStep.step,
          navSignal: nextStep.signal,
        ),
      );
    }
  }

  void skipEntireFlow() {
    logger.i('User skipped entire permission flow');
    final nextStep =
        determineNextPermissionStepUseCase.afterSkippingEntireFlow();
    _safeEmit(
      state.copyWith(
        isSkipped: true,
        isCompleted: true,
        currentStep: nextStep.step,
        navSignal: nextStep.signal,
      ),
    );
    repository.savePermissionStatus(hasCompletedFlow: true);
  }

  // ════════════════════════════════════════════════════════
  // FLOW COMPLETION
  // ════════════════════════════════════════════════════════

  Future<void> _completeFlow(NextStepResult nextStep) async {
    logger.i('Completing permission flow...');
    await repository.savePermissionStatus(hasCompletedFlow: true);
    _safeEmit(
      state.copyWith(
        isCompleted: true,
        hasCompletedFlow: true,
        currentStep: nextStep.step,
        navSignal: PermissionNavigationSignal.toWelcomeGateway,
      ),
    );
    logger.i('Permission flow completed - navigating to welcome gateway');
  }

  // ════════════════════════════════════════════════════════
  // NAVIGATION HELPERS
  // ════════════════════════════════════════════════════════

  void goToStep(int step) {
    if (step >= 1 && step <= 4) {
      PermissionNavigationSignal signal = PermissionNavigationSignal.none;
      switch (step) {
        case 1:
          signal = PermissionNavigationSignal.toLocationIntro;
          break;
        case 2:
          signal = PermissionNavigationSignal.toLocationMap;
          break;
        case 3:
          signal = PermissionNavigationSignal.toNotificationIntro;
          break;
        case 4:
          signal = PermissionNavigationSignal.toLoading;
          break;
      }
      _safeEmit(state.copyWith(currentStep: step, navSignal: signal));
      logger.d('Navigated to step $step with signal $signal');
    }
  }

  void clearNavigationSignal() {
    _safeEmit(state.copyWith(navSignal: PermissionNavigationSignal.none));
  }

  void clearMessage() {
    _safeEmit(state.copyWith(messageKey: null, messageType: null));
  }

  Future<void> resetFlow() async {
    await repository.clearPermissionStatus();
    _safeEmit(const PermissionFlowState());
    logger.i('Permission flow reset');
  }

  // ════════════════════════════════════════════════════════
  // HELPER METHODS
  // ════════════════════════════════════════════════════════

  dynamic _createPosition(double latitude, double longitude) => null;

  LocationPermissionStatus _mapStringToLocationStatus(String? status) {
    switch (status) {
      case 'granted':
        return LocationPermissionStatus.granted;
      case 'limited':
        return LocationPermissionStatus.grantedLimited;
      case 'denied':
        return LocationPermissionStatus.denied;
      case 'permanently_denied':
        return LocationPermissionStatus.permanentlyDenied;
      case 'service_disabled':
        return LocationPermissionStatus.serviceDisabled;
      default:
        return status == null
            ? LocationPermissionStatus.notRequested
            : LocationPermissionStatus.error;
    }
  }

  NotificationPermissionStatus _mapStringToNotificationStatus(String? status) {
    switch (status) {
      case 'granted':
        return NotificationPermissionStatus.granted;
      case 'provisional':
        return NotificationPermissionStatus.provisional;
      case 'denied':
        return NotificationPermissionStatus.denied;
      case 'not_requested':
        return NotificationPermissionStatus.notRequested;
      default:
        return NotificationPermissionStatus.error;
    }
  }
}
