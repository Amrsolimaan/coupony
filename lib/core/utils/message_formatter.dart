import 'package:flutter/material.dart';
import '../localization/l10n/app_localizations.dart';

/// Message Formatter Utility
///
/// Provides helper methods to format and localize message keys
/// Ensures all user-facing messages are human-readable and localized
class MessageFormatter {
  MessageFormatter._();

  /// Get localized message from key
  ///
  /// This method ensures that message keys are properly translated
  /// to the current active language (Arabic or English)
  ///
  /// Example:
  /// ```dart
  /// final message = MessageFormatter.getLocalizedMessage(
  ///   context,
  ///   'error_location_service_disabled',
  /// );
  /// // Returns: "Please enable location service (GPS)..." (English)
  /// // Or: "يرجى تفعيل خدمة الموقع..." (Arabic)
  /// ```
  static String getLocalizedMessage(BuildContext context, String? messageKey) {
    if (messageKey == null || messageKey.isEmpty) {
      return '';
    }

    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      // Fallback: Format the key to be human-readable
      return _formatKeyToHumanReadable(messageKey);
    }

    // Try to get the localized message using reflection-like approach
    // Since we can't use reflection in Flutter, we'll use a switch statement
    return _getMessageFromKey(l10n, messageKey);
  }

  /// Get message from key using AppLocalizations
  static String _getMessageFromKey(
    AppLocalizations l10n,
    String messageKey,
  ) {
    // Map of all possible message keys to their getters
    // This ensures type-safe access to localized strings
    switch (messageKey) {
      // Location errors
      case 'error_location_position_failed':
        return l10n.error_location_position_failed;
      case 'error_location_service_disabled':
        return l10n.error_location_service_disabled;
      case 'error_location_unexpected':
        return l10n.error_location_unexpected;
      case 'error_location_gps_check_failed':
        return l10n.error_location_gps_check_failed;
      case 'error_location_weak_signal':
        return l10n.error_location_weak_signal;
      case 'error_location_use_current_failed':
        return l10n.error_location_use_current_failed;

      // Settings errors
      case 'error_settings_open_failed':
        return l10n.error_settings_open_failed;
      case 'error_settings_app_open_failed':
        return l10n.error_settings_app_open_failed;

      // Notification errors
      case 'error_notification_unexpected':
        return l10n.error_notification_unexpected;
      case 'error_notification_settings_failed':
        return l10n.error_notification_settings_failed;

      // Success messages
      case 'success_location_gps_enabled':
        return l10n.success_location_gps_enabled;
      case 'success_location_settings_opened':
        return l10n.success_location_settings_opened;
      case 'success_onboarding_preferences_saved':
        return l10n.success_onboarding_preferences_saved;
      case 'success_onboarding_categories_updated':
        return l10n.success_onboarding_categories_updated;
      case 'success_onboarding_budget_updated':
        return l10n.success_onboarding_budget_updated;
      case 'success_onboarding_styles_updated':
        return l10n.success_onboarding_styles_updated;
      case 'success_onboarding_all_updated':
        return l10n.success_onboarding_all_updated;

      // Info messages
      case 'info_location_settings_manual':
        return l10n.info_location_settings_manual;
      case 'info_location_app_settings_manual':
        return l10n.info_location_app_settings_manual;
      case 'info_notification_settings_manual':
        return l10n.info_notification_settings_manual;

      // Onboarding errors
      case 'error_onboarding_step1_incomplete':
        return l10n.error_onboarding_step1_incomplete;
      case 'error_onboarding_step2_incomplete':
        return l10n.error_onboarding_step2_incomplete;
      case 'error_onboarding_step3_incomplete':
        return l10n.error_onboarding_step3_incomplete;

      // Auth messages
      case 'login_success':
        return l10n.login_success;
      case 'register_success':
        return l10n.register_success;
      case 'register_otp_sent':
        return l10n.register_otp_sent;
      case 'otp_sent_success':
        return l10n.otp_sent_success;
      case 'otp_verified_success':
        return l10n.otp_verified_success;
      case 'otp_empty_error':
        return l10n.otp_empty_error;

      // Auth error keys
      case 'auth_error_invalid_credentials':
        return l10n.auth_error_invalid_credentials;
      case 'auth_error_network':
        return l10n.auth_error_network;
      case 'auth_error_server':
        return l10n.auth_error_server;
      case 'auth_error_user_not_found':
        return l10n.auth_error_user_not_found;
      case 'auth_error_unexpected':
        return l10n.auth_error_unexpected;

      // Fallback: Format key to human-readable
      default:
        return _formatKeyToHumanReadable(messageKey);
    }
  }

  /// Format a key to human-readable text
  ///
  /// Converts: 'error_location_service_disabled'
  /// To: 'Error Location Service Disabled'
  ///
  /// This is a fallback for when a key is not found in translations
  static String _formatKeyToHumanReadable(String key) {
    return key
        .split('_') // Split by underscore
        .map((word) => _capitalizeFirst(word)) // Capitalize each word
        .join(' '); // Join with spaces
  }

  /// Capitalize first letter of a word
  static String _capitalizeFirst(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }

  /// Check if a message key exists in translations
  static bool hasTranslation(BuildContext context, String? messageKey) {
    if (messageKey == null || messageKey.isEmpty) {
      return false;
    }

    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      return false;
    }

    // Check if the key is in our known keys
    return _isKnownKey(messageKey);
  }

  /// Check if a key is known in our translations
  static bool _isKnownKey(String key) {
    const knownKeys = [
      // Location errors
      'error_location_position_failed',
      'error_location_service_disabled',
      'error_location_unexpected',
      'error_location_gps_check_failed',
      'error_location_weak_signal',
      'error_location_use_current_failed',
      // Settings errors
      'error_settings_open_failed',
      'error_settings_app_open_failed',
      // Notification errors
      'error_notification_unexpected',
      'error_notification_settings_failed',
      // Success messages
      'success_location_gps_enabled',
      'success_location_settings_opened',
      'success_onboarding_preferences_saved',
      'success_onboarding_categories_updated',
      'success_onboarding_budget_updated',
      'success_onboarding_styles_updated',
      'success_onboarding_all_updated',
      // Info messages
      'info_location_settings_manual',
      'info_location_app_settings_manual',
      'info_notification_settings_manual',
      // Onboarding errors
      'error_onboarding_step1_incomplete',
      'error_onboarding_step2_incomplete',
      'error_onboarding_step3_incomplete',
      // Auth errors
      'auth_error_invalid_credentials',
      'auth_error_network',
      'auth_error_server',
      'auth_error_user_not_found',
      'auth_error_unexpected',
    ];

    return knownKeys.contains(key);
  }
}

/// Extension on BuildContext for easy access to message formatting
extension MessageFormatterExtension on BuildContext {
  /// Get localized message from key
  ///
  /// Usage:
  /// ```dart
  /// final message = context.getLocalizedMessage(state.messageKey);
  /// ```
  String getLocalizedMessage(String? messageKey) {
    return MessageFormatter.getLocalizedMessage(this, messageKey);
  }

  /// Check if a message key has translation
  bool hasMessageTranslation(String? messageKey) {
    return MessageFormatter.hasTranslation(this, messageKey);
  }
}
