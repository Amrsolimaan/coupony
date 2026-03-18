/// Permission Constants
/// Defines permission types, statuses, and helper methods
class PermissionConstants {
  PermissionConstants._();

  // ════════════════════════════════════════════════════════
  // PERMISSION TYPES
  // ════════════════════════════════════════════════════════
  
  /// Location permission (while using app)
  static const String location = 'location';
  
  /// Notification permission
  static const String notification = 'notification';

  // ════════════════════════════════════════════════════════
  // PERMISSION STATUS
  // ════════════════════════════════════════════════════════
  
  /// Permission granted by user
  static const String granted = 'granted';
  
  /// Permission denied by user (temporary - can ask again)
  static const String denied = 'denied';
  
  /// Permission permanently denied (user selected "Don't ask again")
  static const String permanentlyDenied = 'permanently_denied';
  
  /// Permission not requested yet
  static const String notRequested = 'not_requested';
  
  /// Permission restricted (iOS - parental controls)
  static const String restricted = 'restricted';
  
  /// Permission limited (iOS 14+ - Approximate Location)
  static const String limited = 'limited';

  // ════════════════════════════════════════════════════════
  // VALIDATION
  // ════════════════════════════════════════════════════════
  
  /// Check if permission type is valid
  static bool isValidPermissionType(String type) {
    return type == location || type == notification;
  }
  
  /// Check if permission status is valid
  static bool isValidStatus(String status) {
    return status == granted ||
        status == denied ||
        status == permanentlyDenied ||
        status == notRequested ||
        status == restricted ||
        status == limited;
  }
  
  /// Check if permission is granted
  static bool isGranted(String status) {
    return status == granted || status == limited; // Limited is acceptable
  }
  
  /// Check if permission is denied permanently
  static bool isPermanentlyDenied(String status) {
    return status == permanentlyDenied;
  }
  
  /// Check if we can request permission again
  static bool canRequestAgain(String status) {
    return status == notRequested || status == denied;
  }

  // ════════════════════════════════════════════════════════
  // FLOW STEPS (for PermissionFlowCubit)
  // ════════════════════════════════════════════════════════
  
  /// Step 1: Location intro screen
  static const int stepLocationIntro = 1;
  
  /// Step 2: Location map (after grant)
  static const int stepLocationMap = 2;
  
  /// Step 3: Notification intro screen
  static const int stepNotificationIntro = 3;
  
  /// Step 4: Loading/Complete
  static const int stepComplete = 4;

  // ════════════════════════════════════════════════════════
  // HELPER MESSAGES (for logging)
  // ════════════════════════════════════════════════════════
  
  /// Get user-friendly status message
  static String getStatusMessage(String status) {
    switch (status) {
      case granted:
        return 'Permission granted';
      case denied:
        return 'Permission denied (temporary)';
      case permanentlyDenied:
        return 'Permission permanently denied';
      case notRequested:
        return 'Permission not requested yet';
      case restricted:
        return 'Permission restricted (parental controls)';
      case limited:
        return 'Permission granted (limited - approximate location)';
      default:
        return 'Unknown permission status';
    }
  }
}
