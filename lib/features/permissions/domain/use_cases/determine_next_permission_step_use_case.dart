import '../../../../core/services/location_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../presentation/cubit/permission_flow_state.dart';

/// Determine Next Permission Step Use Case
/// Business logic for determining what screen/step to show next
/// based on current permission states
class DetermineNextPermissionStepUseCase {
  /// Execute the use case
  /// Returns the next navigation signal and step number
  NextStepResult execute({
    required LocationPermissionStatus locationStatus,
    required NotificationPermissionStatus notificationStatus,
    required bool hasCompletedFlow,
    required bool isLocationServiceEnabled,
    bool? hasPosition,
  }) {
    // If user has completed flow before, go directly to home
    if (hasCompletedFlow) {
      return NextStepResult(
        step: 4,
        signal: PermissionNavigationSignal.toHome,
      );
    }

    // Determine next step based on location status
    if (locationStatus == LocationPermissionStatus.notRequested) {
      // Start with location intro
      return NextStepResult(
        step: 1,
        signal: PermissionNavigationSignal.toLocationIntro,
      );
    } else if (locationStatus == LocationPermissionStatus.granted ||
        locationStatus == LocationPermissionStatus.grantedLimited) {
      // Location granted - check if we have position
      if (hasPosition == true) {
        // Go to map to confirm location
        return NextStepResult(
          step: 2,
          signal: PermissionNavigationSignal.toLocationMap,
        );
      } else {
        // Permission granted but no position - show error
        return NextStepResult(
          step: 1,
          signal: PermissionNavigationSignal.toLocationError,
        );
      }
    } else if (locationStatus == LocationPermissionStatus.serviceDisabled) {
      // GPS is off - show error
      return NextStepResult(
        step: 1,
        signal: PermissionNavigationSignal.toLocationError,
      );
    } else if (locationStatus == LocationPermissionStatus.denied ||
        locationStatus == LocationPermissionStatus.permanentlyDenied) {
      // Location denied - skip to notification
      return NextStepResult(
        step: 3,
        signal: PermissionNavigationSignal.toNotificationIntro,
      );
    }

    // Check notification status
    if (notificationStatus == NotificationPermissionStatus.notRequested) {
      // Show notification intro
      return NextStepResult(
        step: 3,
        signal: PermissionNavigationSignal.toNotificationIntro,
      );
    } else if (notificationStatus == NotificationPermissionStatus.granted ||
        notificationStatus == NotificationPermissionStatus.provisional) {
      // Notification granted - complete flow
      return NextStepResult(
        step: 4,
        signal: PermissionNavigationSignal.toLoading,
      );
    } else if (notificationStatus == NotificationPermissionStatus.denied) {
      // Notification denied - complete flow anyway
      return NextStepResult(
        step: 4,
        signal: PermissionNavigationSignal.toLoading,
      );
    }

    // Default: start from beginning
    return NextStepResult(
      step: 1,
      signal: PermissionNavigationSignal.toLocationIntro,
    );
  }

  /// Determine next step after location confirmation
  NextStepResult afterLocationConfirmed() {
    return NextStepResult(
      step: 3,
      signal: PermissionNavigationSignal.toNotificationIntro,
    );
  }

  /// Determine next step after notification request (always complete)
  NextStepResult afterNotificationRequest() {
    return NextStepResult(
      step: 4,
      signal: PermissionNavigationSignal.toWelcomeGateway,
    );
  }

  /// Determine next step when skipping location
  NextStepResult afterSkippingLocation() {
    return NextStepResult(
      step: 3,
      signal: PermissionNavigationSignal.toNotificationIntro,
    );
  }

  /// Determine next step when skipping notification
  NextStepResult afterSkippingNotification() {
    return NextStepResult(
      step: 4,
      signal: PermissionNavigationSignal.toWelcomeGateway,
    );
  }

  /// Determine next step when skipping entire flow
  NextStepResult afterSkippingEntireFlow() {
    return NextStepResult(
      step: 4,
      signal: PermissionNavigationSignal.toHome,
    );
  }
}

/// Result of determining next step
class NextStepResult {
  final int step;
  final PermissionNavigationSignal signal;

  NextStepResult({
    required this.step,
    required this.signal,
  });
}
