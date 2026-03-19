import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

/// Notification Service
/// Handles notification permission requests and FCM token management
/// 
/// IMPORTANT - Privacy Compliance:
/// - NEVER requests permission without user action
/// - Always shows rationale BEFORE requesting
/// - Handles graceful degradation on denial
/// - App works fully without notifications
/// Top-level background message handler for Firebase Messaging
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  
  final logger = Logger();
  logger.d("Handling a background message: ${message.messageId}");
  logger.d("Message data: ${message.data}");
  logger.d("Message notification: ${message.notification?.body}");
}

/// Notification Service
/// Handles notification permission requests and FCM token management
class NotificationService {
  final Logger logger;
  final FirebaseMessaging _messaging;

  NotificationService({
    required this.logger,
    FirebaseMessaging? messaging,
  }) : _messaging = messaging ?? FirebaseMessaging.instance;

  // ════════════════════════════════════════════════════════
  // INITIALIZATION & LISTENERS
  // ════════════════════════════════════════════════════════

  /// Initialize listeners for foreground and background messages
  void initializeListeners() {
    // 1. Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      logger.i('Got a message whilst in the foreground!');
      logger.i('Message data: ${message.data}');

      if (message.notification != null) {
        logger.i('Message also contained a notification: ${message.notification?.title}');
        logger.i('Notification Title: ${message.notification?.title}');
        logger.i('Notification Body: ${message.notification?.body}');
      }
    });

    // 2. Background/Terminated messages (when app is opened via notification)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      logger.i('A new onMessageOpenedApp event was published!');
      logger.i('App opened from notification: ${message.notification?.title}');
    });

    // 3. Set background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    logger.i('FCM Listeners initialized');
  }

  // ════════════════════════════════════════════════════════
  // PERMISSION CHECK
  // ════════════════════════════════════════════════════════

  /// Check current notification permission status
  /// Does NOT request permission, only checks
  Future<NotificationPermissionStatus> checkPermissionStatus() async {
    try {
      final settings = await _messaging.getNotificationSettings();
      
      logger.d('Notification permission status: ${settings.authorizationStatus}');
      
      return _mapAuthorizationStatus(settings.authorizationStatus);
    } catch (e) {
      logger.e('Error checking notification permission: $e');
      return NotificationPermissionStatus.error;
    }
  }

  // ════════════════════════════════════════════════════════
  // PERMISSION REQUEST (CONTEXTUAL)
  // ════════════════════════════════════════════════════════

  /// Request notification permission
  /// 
  /// MUST be called AFTER showing rationale to user
  /// Should only be called when user clicks "Allow" button
  /// 
  /// Returns permission status after request
  Future<NotificationPermissionStatus> requestPermission() async {
    try {
      logger.i('Requesting notification permission...');

      // Request permission (this shows system dialog)
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      logger.i('Notification permission result: ${settings.authorizationStatus}');
      
      final status = _mapAuthorizationStatus(settings.authorizationStatus);

      // If granted, get FCM token
      if (status == NotificationPermissionStatus.granted ||
          status == NotificationPermissionStatus.provisional) {
        await _getFCMToken();
      }

      return status;
    } catch (e) {
      logger.e('Error requesting notification permission: $e');
      return NotificationPermissionStatus.error;
    }
  }

  // ════════════════════════════════════════════════════════
  // FCM TOKEN MANAGEMENT
  // ════════════════════════════════════════════════════════

  /// Get FCM token (for push notifications)
  /// Returns null if permission not granted
  Future<String?> getFCMToken() async {
    try {
      final status = await checkPermissionStatus();
      
      if (status != NotificationPermissionStatus.granted &&
          status != NotificationPermissionStatus.provisional) {
        logger.w('Cannot get FCM token: Permission not granted');
        return null;
      }

      return await _getFCMToken();
    } catch (e) {
      logger.e('Error getting FCM token: $e');
      return null;
    }
  }

  /// Send FCM token to backend (Placeholder for API integration)
  Future<void> sendTokenToBackend(String token) async {
    // ════════════════════════════════════════════════════════
    // TODO: Integrate with backend API
    // ════════════════════════════════════════════════════════
    logger.d('FCM Token: $token');
    logger.i('Token sent to backend: ${token.substring(0, 20)}...');
    
    // Example:
    // await dio.post('/update-token', data: {'fcm_token': token});
  }

  /// Internal method to get FCM token
  Future<String?> _getFCMToken() async {
    try {
      final token = await _messaging.getToken();
      
      if (token != null) {
        logger.i('FCM Token: ${token.substring(0, 20)}...');
        // Send to backend
        await sendTokenToBackend(token);
      } else {
        logger.w('FCM Token is null');
      }
      
      return token;
    } catch (e) {
      logger.e('Error getting FCM token: $e');
      return null;
    }
  }

  /// Delete FCM token (e.g., on logout)
  Future<void> deleteFCMToken() async {
    try {
      await _messaging.deleteToken();
      logger.i('FCM Token deleted');
    } catch (e) {
      logger.e('Error deleting FCM token: $e');
    }
  }

  /// Listen to FCM token refresh
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  // ════════════════════════════════════════════════════════
  // NOTIFICATION CHANNELS (Android)
  // ════════════════════════════════════════════════════════

  /// Setup notification channels (Android only)
  /// Call this after permission is granted
  Future<void> setupNotificationChannels() async {
    try {
      // Note: Actual channel creation is done in native Android code
      // This is just a placeholder for any Dart-side setup
      logger.d('Notification channels setup');
    } catch (e) {
      logger.e('Error setting up notification channels: $e');
    }
  }

  // ════════════════════════════════════════════════════════
  // SETTINGS NAVIGATION (LAST RESORT)
  // ════════════════════════════════════════════════════════

  /// Open app settings (only for permanently denied)
  /// 
  /// SHOULD ONLY BE CALLED:
  /// - When permission is permanently denied
  /// - AND user clicked "Try Again" button
  /// - NOT automatically
  Future<bool> openAppSettings() async {
    try {
      logger.i('Opening app settings for notification permission...');
      return await ph.openAppSettings();
    } catch (e) {
      logger.e('Error opening app settings: $e');
      return false;
    }
  }

  // ════════════════════════════════════════════════════════
  // HELPER METHODS
  // ════════════════════════════════════════════════════════

  /// Map Firebase authorization status to our custom enum
  NotificationPermissionStatus _mapAuthorizationStatus(
    AuthorizationStatus status,
  ) {
    switch (status) {
      case AuthorizationStatus.authorized:
        return NotificationPermissionStatus.granted;
      case AuthorizationStatus.provisional:
        return NotificationPermissionStatus.provisional;
      case AuthorizationStatus.denied:
        return NotificationPermissionStatus.denied;
      case AuthorizationStatus.notDetermined:
        return NotificationPermissionStatus.notRequested;
    }
  }

  // ════════════════════════════════════════════════════════
  // FOREGROUND NOTIFICATION HANDLING
  // ════════════════════════════════════════════════════════

  /// Configure foreground notification presentation options (iOS)
  Future<void> configureForegroundNotifications() async {
    try {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      logger.d('Foreground notification options configured');
    } catch (e) {
      logger.e('Error configuring foreground notifications: $e');
    }
  }
}

// ════════════════════════════════════════════════════════
// ENUMS
// ════════════════════════════════════════════════════════

/// Notification permission status
enum NotificationPermissionStatus {
  /// Permission granted (full access)
  granted,
  
  /// Permission granted (provisional - iOS, silent notifications only)
  provisional,
  
  /// Permission denied (can ask again)
  denied,
  
  /// Permission not requested yet
  notRequested,
  
  /// Error occurred
  error,
}
