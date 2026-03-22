import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/notification_service.dart';

/// Navigation signals for the permission flow
enum PermissionNavigationSignal {
  none,
  toLocationIntro,
  toLocationMap,
  toLocationError,
  toNotificationIntro,
  toNotificationError,
  toLoading,
  toHome,
}

/// Message types for user feedback
enum MessageType {
  error,
  success,
  info,
}

/// Permission Flow State
/// Manages the state of the permission flow (location + notification)
class PermissionFlowState extends Equatable {
  // ════════════════════════════════════════════════════════
  // CURRENT STEP (1-4)
  // ════════════════════════════════════════════════════════

  /// Current step in the flow
  /// 1 = Location Intro
  /// 2 = Location Map (after grant)
  /// 3 = Notification Intro
  /// 4 = Complete (loading/navigate)
  final int currentStep;

  /// Navigation signal to trigger UI transitions
  final PermissionNavigationSignal navSignal;

  // ════════════════════════════════════════════════════════
  // LOCATION PERMISSION
  // ════════════════════════════════════════════════════════

  /// Location permission status
  final LocationPermissionStatus locationStatus;

  /// User's current position (if location granted)
  final Position? userPosition;

  /// Whether location request is in progress
  final bool isRequestingLocation;

  // ════════════════════════════════════════════════════════
  // NOTIFICATION PERMISSION
  // ════════════════════════════════════════════════════════

  /// Notification permission status
  final NotificationPermissionStatus notificationStatus;

  /// FCM Token (if notification granted)
  final String? fcmToken;

  /// Whether notification request is in progress
  final bool isRequestingNotification;

  // ════════════════════════════════════════════════════════
  // FLOW CONTROL
  // ════════════════════════════════════════════════════════

  /// Whether the entire flow is completed
  final bool isCompleted;

  /// Whether user skipped the flow
  final bool isSkipped;

  /// Whether flow has completed at least once
  final bool hasCompletedFlow;

  /// Message key for localized user feedback (replaces errorMessage)
  final String? messageKey;

  /// Message type (error, success, info)
  final MessageType? messageType;

  /// Current human-readable address
  final String? currentAddress;

  /// Loading progress (0.0 to 1.0) for final loading screen
  final double loadingProgress;

  const PermissionFlowState({
    this.currentStep = 1,
    this.navSignal = PermissionNavigationSignal.none,
    this.locationStatus = LocationPermissionStatus.notRequested,
    this.userPosition,
    this.isRequestingLocation = false,
    this.notificationStatus = NotificationPermissionStatus.notRequested,
    this.fcmToken,
    this.isRequestingNotification = false,
    this.isCompleted = false,
    this.isSkipped = false,
    this.hasCompletedFlow = false,
    this.messageKey,
    this.messageType,
    this.loadingProgress = 0.0,
    this.currentAddress,
  });

  // ════════════════════════════════════════════════════════
  // COPY WITH
  // ════════════════════════════════════════════════════════

  PermissionFlowState copyWith({
    int? currentStep,
    PermissionNavigationSignal? navSignal,
    LocationPermissionStatus? locationStatus,
    Position? userPosition,
    bool? isRequestingLocation,
    NotificationPermissionStatus? notificationStatus,
    String? fcmToken,
    bool? isRequestingNotification,
    bool? isCompleted,
    bool? isSkipped,
    bool? hasCompletedFlow,
    String? messageKey,
    MessageType? messageType,
    double? loadingProgress,
    String? currentAddress,
  }) {
    return PermissionFlowState(
      currentStep: currentStep ?? this.currentStep,
      navSignal: navSignal ?? this.navSignal,
      locationStatus: locationStatus ?? this.locationStatus,
      userPosition: userPosition ?? this.userPosition,
      isRequestingLocation: isRequestingLocation ?? this.isRequestingLocation,
      notificationStatus: notificationStatus ?? this.notificationStatus,
      fcmToken: fcmToken ?? this.fcmToken,
      isRequestingNotification:
          isRequestingNotification ?? this.isRequestingNotification,
      isCompleted: isCompleted ?? this.isCompleted,
      isSkipped: isSkipped ?? this.isSkipped,
      hasCompletedFlow: hasCompletedFlow ?? this.hasCompletedFlow,
      messageKey: messageKey,
      messageType: messageType,
      loadingProgress: loadingProgress ?? this.loadingProgress,
      currentAddress: currentAddress ?? this.currentAddress,
    );
  }

  // ════════════════════════════════════════════════════════
  // HELPER GETTERS
  // ════════════════════════════════════════════════════════

  /// Check if location is granted
  bool get isLocationGranted =>
      locationStatus == LocationPermissionStatus.granted ||
      locationStatus == LocationPermissionStatus.grantedLimited;

  /// Check if notification is granted
  bool get isNotificationGranted =>
      notificationStatus == NotificationPermissionStatus.granted;

  /// Check if location is permanently denied
  bool get isLocationPermanentlyDenied =>
      locationStatus == LocationPermissionStatus.permanentlyDenied;

  /// Check if notification is permanently denied
  bool get isNotificationPermanentlyDenied =>
      notificationStatus ==
      NotificationPermissionStatus
          .error; // Note: Notification service doesn't have a specific perm-denied in enum yet, usually handled by error or checking settings.

  /// Check if user has saved position
  bool get hasUserPosition => userPosition != null;

  /// Check if any request is in progress
  bool get isRequesting => isRequestingLocation || isRequestingNotification;

  /// Check if we should show location error screen
  bool get shouldShowLocationError =>
      locationStatus == LocationPermissionStatus.error ||
      locationStatus == LocationPermissionStatus.serviceDisabled;

  /// Check if we should show notification error screen
  bool get shouldShowNotificationError =>
      notificationStatus == NotificationPermissionStatus.error;

  // ════════════════════════════════════════════════════════
  // ✅ FIXED: Added currentAddress to props
  // ════════════════════════════════════════════════════════

  @override
  List<Object?> get props => [
    currentStep,
    navSignal,
    locationStatus,
    userPosition,
    isRequestingLocation,
    notificationStatus,
    fcmToken,
    isRequestingNotification,
    isCompleted,
    isSkipped,
    hasCompletedFlow,
    messageKey,
    messageType,
    loadingProgress,
    currentAddress,
  ];

  @override
  String toString() {
    return 'PermissionFlowState('
        'step: $currentStep, '
        'location: $locationStatus, '
        'notification: $notificationStatus, '
        'completed: $isCompleted'
        ')';
  }
}
