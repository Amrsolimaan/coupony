import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Coupony'**
  String get appName;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @hasAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get hasAccount;

  /// No description provided for @continuee.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continuee;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get networkError;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error occurred'**
  String get serverError;

  /// No description provided for @cacheError.
  ///
  /// In en, this message translates to:
  /// **'No cached data available'**
  String get cacheError;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get unexpectedError;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Your interests shape your experience'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the categories you care about so we can show you the best offers and discounts tailored for you.'**
  String get onboardingSubtitle;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @startNow.
  ///
  /// In en, this message translates to:
  /// **'Start Now'**
  String get startNow;

  /// No description provided for @categoryRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants & Cafes'**
  String get categoryRestaurants;

  /// No description provided for @categoryFashion.
  ///
  /// In en, this message translates to:
  /// **'Fashion & Style'**
  String get categoryFashion;

  /// No description provided for @categorySupermarket.
  ///
  /// In en, this message translates to:
  /// **'Supermarket'**
  String get categorySupermarket;

  /// No description provided for @categoryElectronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get categoryElectronics;

  /// No description provided for @categoryPharmacy.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get categoryPharmacy;

  /// No description provided for @categoryBeauty.
  ///
  /// In en, this message translates to:
  /// **'Beauty & Care'**
  String get categoryBeauty;

  /// No description provided for @categoryTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get categoryTravel;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @budgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Your Budget'**
  String get budgetTitle;

  /// No description provided for @budgetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll use your choice to prepare a suitable experience from the start'**
  String get budgetSubtitle;

  /// No description provided for @budgetLow.
  ///
  /// In en, this message translates to:
  /// **'Low Budget'**
  String get budgetLow;

  /// No description provided for @budgetMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium Budget'**
  String get budgetMedium;

  /// No description provided for @budgetBestValue.
  ///
  /// In en, this message translates to:
  /// **'Best Value'**
  String get budgetBestValue;

  /// No description provided for @shoppingStyleTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Shopping Style?'**
  String get shoppingStyleTitle;

  /// No description provided for @shoppingStyleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us how you shop so we can recommend better alerts'**
  String get shoppingStyleSubtitle;

  /// No description provided for @shoppingOnline.
  ///
  /// In en, this message translates to:
  /// **'I shop Online most of the time'**
  String get shoppingOnline;

  /// No description provided for @shoppingBasedOnOffer.
  ///
  /// In en, this message translates to:
  /// **'Based on offers'**
  String get shoppingBasedOnOffer;

  /// No description provided for @shoppingInStore.
  ///
  /// In en, this message translates to:
  /// **'I prefer In-Store'**
  String get shoppingInStore;

  /// No description provided for @shoppingBestDiscount.
  ///
  /// In en, this message translates to:
  /// **'I look for best discounts'**
  String get shoppingBestDiscount;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @locationPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationPermissionTitle;

  /// No description provided for @locationPermissionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Allow the app to access your location while using the app?'**
  String get locationPermissionSubtitle;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// No description provided for @skipNow.
  ///
  /// In en, this message translates to:
  /// **'Skip Now'**
  String get skipNow;

  /// No description provided for @locationErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationErrorTitle;

  /// No description provided for @locationErrorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The app could not access your current location, please try again'**
  String get locationErrorSubtitle;

  /// No description provided for @locationServiceDisabledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Location service is disabled, please enable GPS and try again'**
  String get locationServiceDisabledSubtitle;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @notificationPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationPermissionTitle;

  /// No description provided for @notificationPermissionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please enable notifications to receive updates and reminders'**
  String get notificationPermissionSubtitle;

  /// No description provided for @confirmLocation.
  ///
  /// In en, this message translates to:
  /// **'Confirm Location'**
  String get confirmLocation;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use Current Location'**
  String get useCurrentLocation;

  /// No description provided for @searchAreaPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search area, street name...'**
  String get searchAreaPlaceholder;

  /// No description provided for @yourLocation.
  ///
  /// In en, this message translates to:
  /// **'Your Location'**
  String get yourLocation;

  /// No description provided for @loadingPermissions.
  ///
  /// In en, this message translates to:
  /// **'Initializing settings...'**
  String get loadingPermissions;

  /// No description provided for @loadingPrep.
  ///
  /// In en, this message translates to:
  /// **'Preparing...'**
  String get loadingPrep;

  /// No description provided for @loadingData.
  ///
  /// In en, this message translates to:
  /// **'Loading data...'**
  String get loadingData;

  /// No description provided for @loadingAlmostDone.
  ///
  /// In en, this message translates to:
  /// **'Almost done...'**
  String get loadingAlmostDone;

  /// No description provided for @permissions_splash_title.
  ///
  /// In en, this message translates to:
  /// **'Allow Access to Location and Notifications'**
  String get permissions_splash_title;

  /// No description provided for @permissions_splash_subtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll use your location to show nearby services, and notifications to keep you updated'**
  String get permissions_splash_subtitle;

  /// No description provided for @permissions_loading_preparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing everything...'**
  String get permissions_loading_preparing;

  /// No description provided for @permissions_loading_checking.
  ///
  /// In en, this message translates to:
  /// **'Checking permissions...'**
  String get permissions_loading_checking;

  /// No description provided for @permissions_loading_data.
  ///
  /// In en, this message translates to:
  /// **'Loading data...'**
  String get permissions_loading_data;

  /// No description provided for @permissions_loading_complete.
  ///
  /// In en, this message translates to:
  /// **'Loading complete...'**
  String get permissions_loading_complete;

  /// No description provided for @onboarding_loading_preparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing your experience...'**
  String get onboarding_loading_preparing;

  /// No description provided for @onboarding_loading_saving.
  ///
  /// In en, this message translates to:
  /// **'Saving your preferences...'**
  String get onboarding_loading_saving;

  /// No description provided for @onboarding_loading_preparing_experience.
  ///
  /// In en, this message translates to:
  /// **'Preparing your personalized experience...'**
  String get onboarding_loading_preparing_experience;

  /// No description provided for @onboarding_loading_complete.
  ///
  /// In en, this message translates to:
  /// **'Almost there...'**
  String get onboarding_loading_complete;

  /// No description provided for @permissions_location_checking.
  ///
  /// In en, this message translates to:
  /// **'Checking location...'**
  String get permissions_location_checking;

  /// No description provided for @permissions_please_wait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get permissions_please_wait;

  /// No description provided for @location_map_no_results.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get location_map_no_results;

  /// No description provided for @location_map_search_error.
  ///
  /// In en, this message translates to:
  /// **'Search error occurred'**
  String get location_map_search_error;

  /// No description provided for @location_map_voice_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Voice search unavailable'**
  String get location_map_voice_unavailable;

  /// No description provided for @location_map_use_current.
  ///
  /// In en, this message translates to:
  /// **'Use your current location'**
  String get location_map_use_current;

  /// No description provided for @location_map_your_location.
  ///
  /// In en, this message translates to:
  /// **'Your Location'**
  String get location_map_your_location;

  /// No description provided for @location_map_tap_to_select.
  ///
  /// In en, this message translates to:
  /// **'Tap on map to select your location'**
  String get location_map_tap_to_select;

  /// No description provided for @location_map_search_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Search area, street name...'**
  String get location_map_search_placeholder;

  /// No description provided for @location_map_current_location_marker.
  ///
  /// In en, this message translates to:
  /// **'Your current location'**
  String get location_map_current_location_marker;

  /// No description provided for @location_map_confirm_button.
  ///
  /// In en, this message translates to:
  /// **'Confirm Location'**
  String get location_map_confirm_button;

  /// No description provided for @location_map_coordinates_format.
  ///
  /// In en, this message translates to:
  /// **'Latitude: {lat}, Longitude: {lng}'**
  String location_map_coordinates_format(Object lat, Object lng);

  /// No description provided for @location_error_service_disabled.
  ///
  /// In en, this message translates to:
  /// **'Please enable location service (GPS) from device settings to continue'**
  String get location_error_service_disabled;

  /// No description provided for @location_error_permanently_denied.
  ///
  /// In en, this message translates to:
  /// **'Location permission permanently denied. Please enable it from settings'**
  String get location_error_permanently_denied;

  /// No description provided for @location_error_generic.
  ///
  /// In en, this message translates to:
  /// **'The app could not access your current location, please try again'**
  String get location_error_generic;

  /// No description provided for @location_error_open_settings.
  ///
  /// In en, this message translates to:
  /// **'Open Device Settings'**
  String get location_error_open_settings;

  /// No description provided for @location_error_open_app_settings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get location_error_open_app_settings;

  /// No description provided for @location_error_retry.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get location_error_retry;

  /// No description provided for @location_error_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip Now'**
  String get location_error_skip;

  /// No description provided for @location_error_checking.
  ///
  /// In en, this message translates to:
  /// **'Checking location...'**
  String get location_error_checking;

  /// No description provided for @notification_error_title.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notification_error_title;

  /// No description provided for @notification_error_subtitle.
  ///
  /// In en, this message translates to:
  /// **'The app could not enable notifications, please try again'**
  String get notification_error_subtitle;

  /// No description provided for @notification_error_retry.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get notification_error_retry;

  /// No description provided for @error_location_position_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not determine your current location. Make sure GPS is enabled'**
  String get error_location_position_failed;

  /// No description provided for @error_location_service_disabled.
  ///
  /// In en, this message translates to:
  /// **'Please enable location service (GPS) from device settings'**
  String get error_location_service_disabled;

  /// No description provided for @error_location_unexpected.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again'**
  String get error_location_unexpected;

  /// No description provided for @error_location_gps_check_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to check GPS status'**
  String get error_location_gps_check_failed;

  /// No description provided for @error_location_weak_signal.
  ///
  /// In en, this message translates to:
  /// **'Could not determine your location. Make sure you have a strong GPS signal'**
  String get error_location_weak_signal;

  /// No description provided for @error_location_use_current_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not determine your location. Make sure GPS is enabled and try again'**
  String get error_location_use_current_failed;

  /// No description provided for @error_settings_open_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to open settings'**
  String get error_settings_open_failed;

  /// No description provided for @error_settings_app_open_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to open app settings'**
  String get error_settings_app_open_failed;

  /// No description provided for @error_notification_unexpected.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get error_notification_unexpected;

  /// No description provided for @error_notification_settings_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to open settings'**
  String get error_notification_settings_failed;

  /// No description provided for @success_location_gps_enabled.
  ///
  /// In en, this message translates to:
  /// **'After enabling GPS, return to the app and press Try Again'**
  String get success_location_gps_enabled;

  /// No description provided for @success_location_settings_opened.
  ///
  /// In en, this message translates to:
  /// **'After allowing location access, return to the app and press Try Again'**
  String get success_location_settings_opened;

  /// No description provided for @info_location_settings_manual.
  ///
  /// In en, this message translates to:
  /// **'Could not open settings. Open device settings manually and enable location'**
  String get info_location_settings_manual;

  /// No description provided for @info_location_app_settings_manual.
  ///
  /// In en, this message translates to:
  /// **'Could not open settings. Open device settings manually and grant location permission to the app'**
  String get info_location_app_settings_manual;

  /// No description provided for @info_notification_settings_manual.
  ///
  /// In en, this message translates to:
  /// **'Could not open settings. Open device settings manually and enable notifications'**
  String get info_notification_settings_manual;

  /// No description provided for @success_onboarding_preferences_saved.
  ///
  /// In en, this message translates to:
  /// **'Your preferences have been saved successfully'**
  String get success_onboarding_preferences_saved;

  /// No description provided for @success_onboarding_categories_updated.
  ///
  /// In en, this message translates to:
  /// **'Categories updated successfully'**
  String get success_onboarding_categories_updated;

  /// No description provided for @success_onboarding_budget_updated.
  ///
  /// In en, this message translates to:
  /// **'Budget updated successfully'**
  String get success_onboarding_budget_updated;

  /// No description provided for @success_onboarding_styles_updated.
  ///
  /// In en, this message translates to:
  /// **'Shopping style updated successfully'**
  String get success_onboarding_styles_updated;

  /// No description provided for @success_onboarding_all_updated.
  ///
  /// In en, this message translates to:
  /// **'All your preferences have been updated successfully'**
  String get success_onboarding_all_updated;

  /// No description provided for @error_onboarding_step1_incomplete.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one category'**
  String get error_onboarding_step1_incomplete;

  /// No description provided for @error_onboarding_step2_incomplete.
  ///
  /// In en, this message translates to:
  /// **'Please select your budget preference'**
  String get error_onboarding_step2_incomplete;

  /// No description provided for @error_onboarding_step3_incomplete.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one shopping style'**
  String get error_onboarding_step3_incomplete;

  /// No description provided for @onboarding_intro_title.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get to know you better\nand offer you more'**
  String get onboarding_intro_title;

  /// No description provided for @onboarding_intro_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboarding_intro_continue;

  /// No description provided for @welcome_gateway_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome_gateway_title;

  /// No description provided for @welcome_gateway_subtitle.
  ///
  /// In en, this message translates to:
  /// **'You can sign in to access all services, or continue as a guest'**
  String get welcome_gateway_subtitle;

  /// No description provided for @welcome_gateway_login.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get welcome_gateway_login;

  /// No description provided for @welcome_gateway_guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get welcome_gateway_guest;

  /// No description provided for @login_welcome_back.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get login_welcome_back;

  /// No description provided for @login_user_role.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get login_user_role;

  /// No description provided for @login_merchant_role.
  ///
  /// In en, this message translates to:
  /// **'Merchant'**
  String get login_merchant_role;

  /// No description provided for @login_remember_me.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get login_remember_me;

  /// No description provided for @login_or_divider.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get login_or_divider;

  /// No description provided for @login_google_button.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get login_google_button;

  /// No description provided for @login_success.
  ///
  /// In en, this message translates to:
  /// **'Logged in successfully'**
  String get login_success;

  /// No description provided for @register_success.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully'**
  String get register_success;

  /// No description provided for @register_otp_sent.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent to your email'**
  String get register_otp_sent;

  /// No description provided for @otp_sent_success.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent successfully'**
  String get otp_sent_success;

  /// No description provided for @otp_verified_success.
  ///
  /// In en, this message translates to:
  /// **'Verified successfully'**
  String get otp_verified_success;

  /// No description provided for @otp_empty_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter the verification code'**
  String get otp_empty_error;

  /// No description provided for @register_now.
  ///
  /// In en, this message translates to:
  /// **'Register Now'**
  String get register_now;

  /// No description provided for @register_welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome\nGet Started with Registration!'**
  String get register_welcome;

  /// No description provided for @register_first_name.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get register_first_name;

  /// No description provided for @register_last_name.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get register_last_name;

  /// No description provided for @register_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get register_phone;

  /// No description provided for @register_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get register_password;

  /// No description provided for @register_confirm_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get register_confirm_password;

  /// No description provided for @register_agree_terms.
  ///
  /// In en, this message translates to:
  /// **'Agree to Terms & Conditions'**
  String get register_agree_terms;

  /// No description provided for @login_now.
  ///
  /// In en, this message translates to:
  /// **'Login Now'**
  String get login_now;

  /// No description provided for @auth_error_invalid_credentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get auth_error_invalid_credentials;

  /// No description provided for @auth_error_network.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get auth_error_network;

  /// No description provided for @auth_error_server.
  ///
  /// In en, this message translates to:
  /// **'Server error occurred. Please try again'**
  String get auth_error_server;

  /// No description provided for @auth_error_user_not_found.
  ///
  /// In en, this message translates to:
  /// **'No account found with this email'**
  String get auth_error_user_not_found;

  /// No description provided for @auth_error_unexpected.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get auth_error_unexpected;

  /// No description provided for @otp_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Email Verification'**
  String get otp_screen_title;

  /// No description provided for @otp_screen_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter the verification code we just sent to'**
  String get otp_screen_subtitle;

  /// No description provided for @otp_verify_button.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get otp_verify_button;

  /// No description provided for @otp_resend_timer_prefix.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get otp_resend_timer_prefix;

  /// No description provided for @otp_resend_prefix.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get otp_resend_prefix;

  /// No description provided for @otp_resend_button.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get otp_resend_button;

  /// No description provided for @otp_success_title.
  ///
  /// In en, this message translates to:
  /// **'Account Verified Successfully'**
  String get otp_success_title;

  /// No description provided for @otp_success_button.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get otp_success_button;

  /// No description provided for @otp_expiry_notice.
  ///
  /// In en, this message translates to:
  /// **'This code is valid for 10 minutes'**
  String get otp_expiry_notice;

  /// No description provided for @forgot_password_title.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgot_password_title;

  /// No description provided for @forgot_password_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a reset code'**
  String get forgot_password_subtitle;

  /// No description provided for @forgot_password_email_hint.
  ///
  /// In en, this message translates to:
  /// **'Your email address'**
  String get forgot_password_email_hint;

  /// No description provided for @forgot_password_send_button.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Code'**
  String get forgot_password_send_button;

  /// No description provided for @forgot_password_code_sent.
  ///
  /// In en, this message translates to:
  /// **'If the account exists, you will receive a reset code'**
  String get forgot_password_code_sent;

  /// No description provided for @forgot_password_back_to_login.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get forgot_password_back_to_login;

  /// No description provided for @reset_password_title.
  ///
  /// In en, this message translates to:
  /// **'Create New Password'**
  String get reset_password_title;

  /// No description provided for @reset_password_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Your new password must be unique from those\npreviously used.'**
  String get reset_password_subtitle;

  /// No description provided for @reset_password_code_hint.
  ///
  /// In en, this message translates to:
  /// **'Reset Code'**
  String get reset_password_code_hint;

  /// No description provided for @reset_password_new_password_hint.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get reset_password_new_password_hint;

  /// No description provided for @reset_password_confirm_hint.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get reset_password_confirm_hint;

  /// No description provided for @reset_password_submit_button.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get reset_password_submit_button;

  /// No description provided for @reset_password_resend_code.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get reset_password_resend_code;

  /// No description provided for @reset_password_success.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully'**
  String get reset_password_success;

  /// No description provided for @reset_password_error_invalid_token.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired reset token'**
  String get reset_password_error_invalid_token;

  /// No description provided for @reset_password_error_server.
  ///
  /// In en, this message translates to:
  /// **'Could not reset password. Please try again'**
  String get reset_password_error_server;

  /// No description provided for @reset_password_strength_min_length.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get reset_password_strength_min_length;

  /// No description provided for @reset_password_strength_digit.
  ///
  /// In en, this message translates to:
  /// **'At least one number (0-9) and symbol'**
  String get reset_password_strength_digit;

  /// No description provided for @reset_password_strength_uppercase.
  ///
  /// In en, this message translates to:
  /// **'Lowercase (a-z) and uppercase (A-Z) letters'**
  String get reset_password_strength_uppercase;

  /// No description provided for @reset_password_strength_lowercase.
  ///
  /// In en, this message translates to:
  /// **'Contains a lowercase letter'**
  String get reset_password_strength_lowercase;

  /// No description provided for @reset_password_error_mismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match. Please try again'**
  String get reset_password_error_mismatch;

  /// No description provided for @reset_password_continue_login.
  ///
  /// In en, this message translates to:
  /// **'Continue to Login'**
  String get reset_password_continue_login;

  /// In en: 'Slow internet connection detected'
  String get network_slow_warning;

  /// In en: 'Very slow internet — some features may be delayed'
  String get network_very_slow_warning;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
