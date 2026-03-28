// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Coupony';

  @override
  String get welcome => 'Welcome';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get hasAccount => 'Already have an account?';

  @override
  String get continuee => 'Continue';

  @override
  String get networkError => 'No internet connection';

  @override
  String get serverError => 'Server error occurred';

  @override
  String get cacheError => 'No cached data available';

  @override
  String get unexpectedError => 'An unexpected error occurred';

  @override
  String get onboardingTitle => 'Your interests shape your experience';

  @override
  String get onboardingSubtitle =>
      'Choose the categories you care about so we can show you the best offers and discounts tailored for you.';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get startNow => 'Start Now';

  @override
  String get categoryRestaurants => 'Restaurants & Cafes';

  @override
  String get categoryFashion => 'Fashion & Style';

  @override
  String get categorySupermarket => 'Supermarket';

  @override
  String get categoryElectronics => 'Electronics';

  @override
  String get categoryPharmacy => 'Pharmacy';

  @override
  String get categoryBeauty => 'Beauty & Care';

  @override
  String get categoryTravel => 'Travel';

  @override
  String get categoryOther => 'Other';

  @override
  String get budgetTitle => 'Set Your Budget';

  @override
  String get budgetSubtitle =>
      'We\'ll use your choice to prepare a suitable experience from the start';

  @override
  String get budgetLow => 'Low Budget';

  @override
  String get budgetMedium => 'Medium Budget';

  @override
  String get budgetBestValue => 'Best Value';

  @override
  String get shoppingStyleTitle => 'Your Shopping Style?';

  @override
  String get shoppingStyleSubtitle =>
      'Tell us how you shop so we can recommend better alerts';

  @override
  String get shoppingOnline => 'I shop Online most of the time';

  @override
  String get shoppingBasedOnOffer => 'Based on offers';

  @override
  String get shoppingInStore => 'I prefer In-Store';

  @override
  String get shoppingBestDiscount => 'I look for best discounts';

  @override
  String get finish => 'Finish';

  @override
  String get locationPermissionTitle => 'Location';

  @override
  String get locationPermissionSubtitle =>
      'Allow the app to access your location while using the app?';

  @override
  String get allow => 'Allow';

  @override
  String get skipNow => 'Skip Now';

  @override
  String get locationErrorTitle => 'Location';

  @override
  String get locationErrorSubtitle =>
      'The app could not access your current location, please try again';

  @override
  String get locationServiceDisabledSubtitle =>
      'Location service is disabled, please enable GPS and try again';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get notificationPermissionTitle => 'Notifications';

  @override
  String get notificationPermissionSubtitle =>
      'Please enable notifications to receive updates and reminders';

  @override
  String get confirmLocation => 'Confirm Location';

  @override
  String get useCurrentLocation => 'Use Current Location';

  @override
  String get searchAreaPlaceholder => 'Search area, street name...';

  @override
  String get yourLocation => 'Your Location';

  @override
  String get loadingPermissions => 'Initializing settings...';

  @override
  String get loadingPrep => 'Preparing...';

  @override
  String get loadingData => 'Loading data...';

  @override
  String get loadingAlmostDone => 'Almost done...';

  @override
  String get permissions_splash_title =>
      'Allow Access to Location and Notifications';

  @override
  String get permissions_splash_subtitle =>
      'We\'ll use your location to show nearby services, and notifications to keep you updated';

  @override
  String get permissions_loading_preparing => 'Preparing everything...';

  @override
  String get permissions_loading_checking => 'Checking permissions...';

  @override
  String get permissions_loading_data => 'Loading data...';

  @override
  String get permissions_loading_complete => 'Loading complete...';

  @override
  String get onboarding_loading_preparing => 'Preparing your experience...';

  @override
  String get onboarding_loading_saving => 'Saving your preferences...';

  @override
  String get onboarding_loading_preparing_experience =>
      'Preparing your personalized experience...';

  @override
  String get onboarding_loading_complete => 'Almost there...';

  @override
  String get permissions_location_checking => 'Checking location...';

  @override
  String get permissions_please_wait => 'Please wait...';

  @override
  String get location_map_no_results => 'No results found';

  @override
  String get location_map_search_error => 'Search error occurred';

  @override
  String get location_map_voice_unavailable => 'Voice search unavailable';

  @override
  String get location_map_use_current => 'Use your current location';

  @override
  String get location_map_your_location => 'Your Location';

  @override
  String get location_map_tap_to_select => 'Tap on map to select your location';

  @override
  String get location_map_search_placeholder => 'Search area, street name...';

  @override
  String get location_map_current_location_marker => 'Your current location';

  @override
  String get location_map_confirm_button => 'Confirm Location';

  @override
  String location_map_coordinates_format(Object lat, Object lng) {
    return 'Latitude: $lat, Longitude: $lng';
  }

  @override
  String get location_error_service_disabled =>
      'Please enable location service (GPS) from device settings to continue';

  @override
  String get location_error_permanently_denied =>
      'Location permission permanently denied. Please enable it from settings';

  @override
  String get location_error_generic =>
      'The app could not access your current location, please try again';

  @override
  String get location_error_open_settings => 'Open Device Settings';

  @override
  String get location_error_open_app_settings => 'Open Settings';

  @override
  String get location_error_retry => 'Try Again';

  @override
  String get location_error_skip => 'Skip Now';

  @override
  String get location_error_checking => 'Checking location...';

  @override
  String get notification_error_title => 'Notifications';

  @override
  String get notification_error_subtitle =>
      'The app could not enable notifications, please try again';

  @override
  String get notification_error_retry => 'Try Again';

  @override
  String get error_location_position_failed =>
      'Could not determine your current location. Make sure GPS is enabled';

  @override
  String get error_location_service_disabled =>
      'Please enable location service (GPS) from device settings';

  @override
  String get error_location_unexpected =>
      'An unexpected error occurred. Please try again';

  @override
  String get error_location_gps_check_failed => 'Failed to check GPS status';

  @override
  String get error_location_weak_signal =>
      'Could not determine your location. Make sure you have a strong GPS signal';

  @override
  String get error_location_use_current_failed =>
      'Could not determine your location. Make sure GPS is enabled and try again';

  @override
  String get error_settings_open_failed => 'Failed to open settings';

  @override
  String get error_settings_app_open_failed => 'Failed to open app settings';

  @override
  String get error_notification_unexpected => 'An unexpected error occurred';

  @override
  String get error_notification_settings_failed => 'Failed to open settings';

  @override
  String get success_location_gps_enabled =>
      'After enabling GPS, return to the app and press Try Again';

  @override
  String get success_location_settings_opened =>
      'After allowing location access, return to the app and press Try Again';

  @override
  String get info_location_settings_manual =>
      'Could not open settings. Open device settings manually and enable location';

  @override
  String get info_location_app_settings_manual =>
      'Could not open settings. Open device settings manually and grant location permission to the app';

  @override
  String get info_notification_settings_manual =>
      'Could not open settings. Open device settings manually and enable notifications';

  @override
  String get success_onboarding_preferences_saved =>
      'Your preferences have been saved successfully';

  @override
  String get success_onboarding_categories_updated =>
      'Categories updated successfully';

  @override
  String get success_onboarding_budget_updated => 'Budget updated successfully';

  @override
  String get success_onboarding_styles_updated =>
      'Shopping style updated successfully';

  @override
  String get success_onboarding_all_updated =>
      'All your preferences have been updated successfully';

  @override
  String get error_onboarding_step1_incomplete =>
      'Please select at least one category';

  @override
  String get error_onboarding_step2_incomplete =>
      'Please select your budget preference';

  @override
  String get error_onboarding_step3_incomplete =>
      'Please select at least one shopping style';

  @override
  String get onboarding_intro_title =>
      'Let\'s get to know you better\nand offer you more';

  @override
  String get onboarding_intro_continue => 'Continue';

  @override
  String get welcome_gateway_title => 'Welcome';

  @override
  String get welcome_gateway_subtitle =>
      'You can sign in to access all services, or continue as a guest';

  @override
  String get welcome_gateway_login => 'Sign In';

  @override
  String get welcome_gateway_guest => 'Guest';

  @override
  String get login_welcome_back => 'Welcome Back!';

  @override
  String get login_user_role => 'User';

  @override
  String get login_merchant_role => 'Merchant';

  @override
  String get login_remember_me => 'Remember me';

  @override
  String get login_or_divider => 'Or continue with';

  @override
  String get login_google_button => 'Continue with Google';

  @override
  String get login_success => 'Logged in successfully';

  @override
  String get continue_button => 'Continue';

  @override
  String get register_success => 'Account created successfully';

  @override
  String get register_otp_sent => 'Verification code sent to your email';

  @override
  String get otp_sent_success => 'Verification code sent successfully';

  @override
  String get otp_verified_success => 'Verified successfully';

  @override
  String get otp_empty_error => 'Please enter the verification code';

  @override
  String get register_now => 'Register Now';

  @override
  String get register_welcome => 'Welcome\nGet Started with Registration!';

  @override
  String get register_first_name => 'First Name';

  @override
  String get register_last_name => 'Last Name';

  @override
  String get register_phone => 'Phone Number';

  @override
  String get register_password => 'Password';

  @override
  String get register_confirm_password => 'Confirm Password';

  @override
  String get register_agree_terms => 'Agree to Terms & Conditions';

  @override
  String get login_now => 'Login Now';

  @override
  String get auth_error_invalid_credentials => 'Invalid email or password';

  @override
  String get auth_error_network => 'No internet connection';

  @override
  String get auth_error_server => 'Server error occurred. Please try again';

  @override
  String get auth_error_user_not_found => 'No account found with this email';

  @override
  String get auth_error_unexpected => 'An unexpected error occurred';

  @override
  String get otp_screen_title => 'Email Verification';

  @override
  String get otp_screen_subtitle =>
      'Please enter the verification code we just sent to';

  @override
  String get otp_verify_button => 'Verify';

  @override
  String get otp_resend_timer_prefix => 'Didn\'t receive the code?';

  @override
  String get otp_resend_prefix => 'Didn\'t receive the code?';

  @override
  String get otp_resend_button => 'Resend';

  @override
  String get otp_success_title => 'Account Verified Successfully';

  @override
  String get otp_success_button => 'Go to Home';

  @override
  String get otp_expiry_notice => 'This code is valid for 10 minutes';

  @override
  String get forgot_password_title => 'Forgot Password?';

  @override
  String get forgot_password_subtitle =>
      'Enter your email and we\'ll send you a reset code';

  @override
  String get forgot_password_email_hint => 'Your email address';

  @override
  String get forgot_password_send_button => 'Send Reset Code';

  @override
  String get forgot_password_code_sent =>
      'If the account exists, you will receive a reset code';

  @override
  String get forgot_password_back_to_login => 'Back to Login';

  @override
  String get reset_password_title => 'Create New Password';

  @override
  String get reset_password_subtitle =>
      'Your new password must be unique from those\npreviously used.';

  @override
  String get reset_password_code_hint => 'Reset Code';

  @override
  String get reset_password_new_password_hint => 'New Password';

  @override
  String get reset_password_confirm_hint => 'Confirm New Password';

  @override
  String get reset_password_submit_button => 'Reset Password';

  @override
  String get reset_password_resend_code => 'Resend Code';

  @override
  String get reset_password_success => 'Password reset successfully';

  @override
  String get reset_password_error_invalid_token =>
      'Invalid or expired reset token';

  @override
  String get reset_password_error_server =>
      'Could not reset password. Please try again';

  @override
  String get reset_password_strength_min_length => 'At least 8 characters';

  @override
  String get reset_password_strength_digit =>
      'At least one number (0-9) and symbol';

  @override
  String get reset_password_strength_uppercase =>
      'Lowercase (a-z) and uppercase (A-Z) letters';

  @override
  String get reset_password_strength_lowercase => 'Contains a lowercase letter';

  @override
  String get reset_password_error_mismatch =>
      'Passwords do not match. Please try again';

  @override
  String get reset_password_continue_login => 'Continue to Login';

  @override
  String get network_slow_warning => 'Slow internet connection detected';

  @override
  String get network_very_slow_warning =>
      'Very slow internet — some features may be delayed';

  @override
  String get login_success_title => 'Login Successful!';
}
