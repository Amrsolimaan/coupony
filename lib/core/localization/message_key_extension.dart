import 'l10n/app_localizations.dart';

/// Extension method for retrieving localized messages by key
/// 
/// Usage:
/// ```dart
/// final l10n = AppLocalizations.of(context)!;
/// final message = l10n.getMessage('error_location_position_failed');
/// ```
extension MessageKeyExtension on AppLocalizations {
  /// Get localized message by key
  /// Returns the message for the given key, or unexpectedError if key not found
  String getMessage(String key) {
    switch (key) {
      // ════════════════════════════════════════════════════════
      // PERMISSION FLOW - LOCATION ERRORS
      // ════════════════════════════════════════════════════════
      case 'error_location_position_failed':
        return error_location_position_failed;
      case 'error_location_service_disabled':
        return error_location_service_disabled;
      case 'error_location_unexpected':
        return error_location_unexpected;
      case 'error_location_gps_check_failed':
        return error_location_gps_check_failed;
      case 'error_location_weak_signal':
        return error_location_weak_signal;
      case 'error_location_use_current_failed':
        return error_location_use_current_failed;

      // ════════════════════════════════════════════════════════
      // PERMISSION FLOW - SETTINGS ERRORS
      // ════════════════════════════════════════════════════════
      case 'error_settings_open_failed':
        return error_settings_open_failed;
      case 'error_settings_app_open_failed':
        return error_settings_app_open_failed;

      // ════════════════════════════════════════════════════════
      // PERMISSION FLOW - NOTIFICATION ERRORS
      // ════════════════════════════════════════════════════════
      case 'error_notification_unexpected':
        return error_notification_unexpected;
      case 'error_notification_settings_failed':
        return error_notification_settings_failed;

      // ════════════════════════════════════════════════════════
      // PERMISSION FLOW - SUCCESS MESSAGES
      // ════════════════════════════════════════════════════════
      case 'success_location_gps_enabled':
        return success_location_gps_enabled;
      case 'success_location_settings_opened':
        return success_location_settings_opened;

      // ════════════════════════════════════════════════════════
      // PERMISSION FLOW - INFO MESSAGES
      // ════════════════════════════════════════════════════════
      case 'info_location_settings_manual':
        return info_location_settings_manual;
      case 'info_location_app_settings_manual':
        return info_location_app_settings_manual;
      case 'info_notification_settings_manual':
        return info_notification_settings_manual;

      // ════════════════════════════════════════════════════════
      // ONBOARDING FLOW - SUCCESS MESSAGES
      // ════════════════════════════════════════════════════════
      case 'success_onboarding_preferences_saved':
        return success_onboarding_preferences_saved;
      case 'success_onboarding_categories_updated':
        return success_onboarding_categories_updated;
      case 'success_onboarding_budget_updated':
        return success_onboarding_budget_updated;
      case 'success_onboarding_styles_updated':
        return success_onboarding_styles_updated;
      case 'success_onboarding_all_updated':
        return success_onboarding_all_updated;

      // ════════════════════════════════════════════════════════
      // ONBOARDING FLOW - ERROR MESSAGES
      // ════════════════════════════════════════════════════════
      case 'error_onboarding_step1_incomplete':
        return error_onboarding_step1_incomplete;
      case 'error_onboarding_step2_incomplete':
        return error_onboarding_step2_incomplete;
      case 'error_onboarding_step3_incomplete':
        return error_onboarding_step3_incomplete;

      // ════════════════════════════════════════════════════════
      // FALLBACK
      // ════════════════════════════════════════════════════════
      default:
        return unexpectedError;
    }
  }

  /// Check if a message key exists
  bool hasMessageKey(String key) {
    return key == 'error_location_position_failed' ||
        key == 'error_location_service_disabled' ||
        key == 'error_location_unexpected' ||
        key == 'error_location_gps_check_failed' ||
        key == 'error_location_weak_signal' ||
        key == 'error_location_use_current_failed' ||
        key == 'error_settings_open_failed' ||
        key == 'error_settings_app_open_failed' ||
        key == 'error_notification_unexpected' ||
        key == 'error_notification_settings_failed' ||
        key == 'success_location_gps_enabled' ||
        key == 'success_location_settings_opened' ||
        key == 'info_location_settings_manual' ||
        key == 'info_location_app_settings_manual' ||
        key == 'info_notification_settings_manual' ||
        key == 'success_onboarding_preferences_saved' ||
        key == 'success_onboarding_categories_updated' ||
        key == 'success_onboarding_budget_updated' ||
        key == 'success_onboarding_styles_updated' ||
        key == 'success_onboarding_all_updated' ||
        key == 'error_onboarding_step1_incomplete' ||
        key == 'error_onboarding_step2_incomplete' ||
        key == 'error_onboarding_step3_incomplete';
  }
}
