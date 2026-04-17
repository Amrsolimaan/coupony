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

  /// No description provided for @language_selection_title.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Language'**
  String get language_selection_title;

  /// No description provided for @language_arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get language_arabic;

  /// No description provided for @language_english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language_english;

  /// No description provided for @language_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get language_continue;

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

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @no_categories_available.
  ///
  /// In en, this message translates to:
  /// **'No categories available'**
  String get no_categories_available;

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

  /// No description provided for @onboarding_loading_preparing_seller.
  ///
  /// In en, this message translates to:
  /// **'Preparing your store...'**
  String get onboarding_loading_preparing_seller;

  /// No description provided for @onboarding_loading_saving_seller.
  ///
  /// In en, this message translates to:
  /// **'Saving your store data...'**
  String get onboarding_loading_saving_seller;

  /// No description provided for @onboarding_loading_preparing_experience_seller.
  ///
  /// In en, this message translates to:
  /// **'Setting up your dashboard...'**
  String get onboarding_loading_preparing_experience_seller;

  /// No description provided for @onboarding_loading_complete_seller.
  ///
  /// In en, this message translates to:
  /// **'Your store is almost ready...'**
  String get onboarding_loading_complete_seller;

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

  /// No description provided for @login_google_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Google Sign-In was cancelled'**
  String get login_google_cancelled;

  /// No description provided for @error_no_internet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get error_no_internet;

  /// No description provided for @error_no_internet_check_network.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network.'**
  String get error_no_internet_check_network;

  /// No description provided for @login_success.
  ///
  /// In en, this message translates to:
  /// **'Logged in successfully'**
  String get login_success;

  /// No description provided for @continue_button.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_button;

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

  /// No description provided for @network_slow_warning.
  ///
  /// In en, this message translates to:
  /// **'Slow internet connection detected'**
  String get network_slow_warning;

  /// No description provided for @network_very_slow_warning.
  ///
  /// In en, this message translates to:
  /// **'Very slow internet — some features may be delayed'**
  String get network_very_slow_warning;

  /// No description provided for @login_success_title.
  ///
  /// In en, this message translates to:
  /// **'Login Successful!'**
  String get login_success_title;

  /// No description provided for @create_store_title.
  ///
  /// In en, this message translates to:
  /// **'Create Store'**
  String get create_store_title;

  /// No description provided for @create_store_logo_label.
  ///
  /// In en, this message translates to:
  /// **'Store Logo'**
  String get create_store_logo_label;

  /// No description provided for @create_store_logo_hint.
  ///
  /// In en, this message translates to:
  /// **'Choose a clear and appropriate image for your store logo'**
  String get create_store_logo_hint;

  /// No description provided for @create_store_logo_format.
  ///
  /// In en, this message translates to:
  /// **'PNG or JPG, max size 5MB'**
  String get create_store_logo_format;

  /// No description provided for @create_store_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Store Name'**
  String get create_store_name_hint;

  /// No description provided for @create_store_category_hint.
  ///
  /// In en, this message translates to:
  /// **'Choose the appropriate category'**
  String get create_store_category_hint;

  /// No description provided for @create_store_category_scroll_hint.
  ///
  /// In en, this message translates to:
  /// **'Scroll down to see more'**
  String get create_store_category_scroll_hint;

  /// No description provided for @create_store_description_hint.
  ///
  /// In en, this message translates to:
  /// **'Write a brief description of your store and services'**
  String get create_store_description_hint;

  /// No description provided for @create_store_description_error.
  ///
  /// In en, this message translates to:
  /// **'Maximum allowed limit exceeded'**
  String get create_store_description_error;

  /// No description provided for @create_store_city_hint.
  ///
  /// In en, this message translates to:
  /// **'Choose the city'**
  String get create_store_city_hint;

  /// No description provided for @create_store_area_hint.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get create_store_area_hint;

  /// No description provided for @create_store_branches_hint.
  ///
  /// In en, this message translates to:
  /// **'Number of branches'**
  String get create_store_branches_hint;

  /// No description provided for @create_store_terms_agree.
  ///
  /// In en, this message translates to:
  /// **'Agree to Terms & Conditions'**
  String get create_store_terms_agree;

  /// No description provided for @create_store_button.
  ///
  /// In en, this message translates to:
  /// **'Create Store'**
  String get create_store_button;

  /// No description provided for @category_toys.
  ///
  /// In en, this message translates to:
  /// **'Toys'**
  String get category_toys;

  /// No description provided for @category_games.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get category_games;

  /// No description provided for @city_fayoum.
  ///
  /// In en, this message translates to:
  /// **'Fayoum'**
  String get city_fayoum;

  /// No description provided for @city_giza.
  ///
  /// In en, this message translates to:
  /// **'Giza'**
  String get city_giza;

  /// No description provided for @area_lutf_allah.
  ///
  /// In en, this message translates to:
  /// **'Lutf Allah'**
  String get area_lutf_allah;

  /// No description provided for @seller_store_info_title.
  ///
  /// In en, this message translates to:
  /// **'Store Information'**
  String get seller_store_info_title;

  /// No description provided for @seller_store_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Store Name'**
  String get seller_store_name_hint;

  /// No description provided for @seller_store_description_hint.
  ///
  /// In en, this message translates to:
  /// **'Write a brief description of your store and services'**
  String get seller_store_description_hint;

  /// No description provided for @seller_store_description_counter.
  ///
  /// In en, this message translates to:
  /// **'{current}/{max} characters'**
  String seller_store_description_counter(Object current, Object max);

  /// No description provided for @seller_store_logo_label.
  ///
  /// In en, this message translates to:
  /// **'Store Logo'**
  String get seller_store_logo_label;

  /// No description provided for @seller_store_logo_hint.
  ///
  /// In en, this message translates to:
  /// **'Choose a clear image for your store logo'**
  String get seller_store_logo_hint;

  /// No description provided for @seller_best_offer_time_title.
  ///
  /// In en, this message translates to:
  /// **'When are you most active with offers?'**
  String get seller_best_offer_time_title;

  /// No description provided for @seller_best_offer_time_all_week.
  ///
  /// In en, this message translates to:
  /// **'All Week Long'**
  String get seller_best_offer_time_all_week;

  /// No description provided for @seller_best_offer_time_all_week_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Always active store'**
  String get seller_best_offer_time_all_week_subtitle;

  /// No description provided for @seller_best_offer_time_weekends.
  ///
  /// In en, this message translates to:
  /// **'Weekends and Occasions'**
  String get seller_best_offer_time_weekends;

  /// No description provided for @seller_best_offer_time_weekends_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Outings and leisure'**
  String get seller_best_offer_time_weekends_subtitle;

  /// No description provided for @seller_best_offer_time_off_peak.
  ///
  /// In en, this message translates to:
  /// **'Off-peak Times'**
  String get seller_best_offer_time_off_peak;

  /// No description provided for @seller_best_offer_time_off_peak_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Offers to increase sales during quiet times'**
  String get seller_best_offer_time_off_peak_subtitle;

  /// No description provided for @seller_price_range_title.
  ///
  /// In en, this message translates to:
  /// **'Classify your prices so we can reach the right audience'**
  String get seller_price_range_title;

  /// No description provided for @seller_price_range_economic.
  ///
  /// In en, this message translates to:
  /// **'Economic Prices'**
  String get seller_price_range_economic;

  /// No description provided for @seller_price_range_economic_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Offers that suit everyone and are very affordable'**
  String get seller_price_range_economic_subtitle;

  /// No description provided for @seller_price_range_medium.
  ///
  /// In en, this message translates to:
  /// **'Medium Category'**
  String get seller_price_range_medium;

  /// No description provided for @seller_price_range_medium_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Good quality and moderate price'**
  String get seller_price_range_medium_subtitle;

  /// No description provided for @seller_price_range_premium.
  ///
  /// In en, this message translates to:
  /// **'Premium Category'**
  String get seller_price_range_premium;

  /// No description provided for @seller_price_range_premium_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Luxurious products and high-end products'**
  String get seller_price_range_premium_subtitle;

  /// No description provided for @seller_price_range_all_levels.
  ///
  /// In en, this message translates to:
  /// **'All Levels'**
  String get seller_price_range_all_levels;

  /// No description provided for @seller_price_range_all_levels_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Offers covering all price categories'**
  String get seller_price_range_all_levels_subtitle;

  /// No description provided for @seller_delivery_method_title.
  ///
  /// In en, this message translates to:
  /// **'How do customers reach your products?'**
  String get seller_delivery_method_title;

  /// No description provided for @seller_delivery_method_physical.
  ///
  /// In en, this message translates to:
  /// **'I have a physical store to receive customers.'**
  String get seller_delivery_method_physical;

  /// No description provided for @seller_delivery_method_online.
  ///
  /// In en, this message translates to:
  /// **'We are fully online.'**
  String get seller_delivery_method_online;

  /// No description provided for @seller_target_audience_title.
  ///
  /// In en, this message translates to:
  /// **'Who do your offers target more?'**
  String get seller_target_audience_title;

  /// No description provided for @seller_target_audience_youth.
  ///
  /// In en, this message translates to:
  /// **'Youth'**
  String get seller_target_audience_youth;

  /// No description provided for @seller_target_audience_youth_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Social Media generation and trends'**
  String get seller_target_audience_youth_subtitle;

  /// No description provided for @seller_target_audience_families.
  ///
  /// In en, this message translates to:
  /// **'Families & Households'**
  String get seller_target_audience_families;

  /// No description provided for @seller_target_audience_families_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Home seekers and children'**
  String get seller_target_audience_families_subtitle;

  /// No description provided for @seller_target_audience_everyone.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get seller_target_audience_everyone;

  /// No description provided for @seller_target_audience_everyone_subtitle.
  ///
  /// In en, this message translates to:
  /// **'General offers for all ages'**
  String get seller_target_audience_everyone_subtitle;

  /// No description provided for @seller_onboarding_success_title.
  ///
  /// In en, this message translates to:
  /// **'Onboarding Completed Successfully!'**
  String get seller_onboarding_success_title;

  /// No description provided for @customer_onboarding_success_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Coupony!'**
  String get customer_onboarding_success_title;

  /// No description provided for @seller_onboarding_start_title.
  ///
  /// In en, this message translates to:
  /// **'Let\'s understand your business better\nto connect you with the right customers'**
  String get seller_onboarding_start_title;

  /// No description provided for @seller_onboarding_start_subtitle.
  ///
  /// In en, this message translates to:
  /// **'4 simple steps will help us understand your business'**
  String get seller_onboarding_start_subtitle;

  /// No description provided for @seller_onboarding_start_button.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get seller_onboarding_start_button;

  /// No description provided for @onboarding_time_most_active_title.
  ///
  /// In en, this message translates to:
  /// **'When are you most active with offers?'**
  String get onboarding_time_most_active_title;

  /// No description provided for @onboarding_time_all_week.
  ///
  /// In en, this message translates to:
  /// **'All Week Long'**
  String get onboarding_time_all_week;

  /// No description provided for @onboarding_time_all_week_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Always active store'**
  String get onboarding_time_all_week_subtitle;

  /// No description provided for @onboarding_time_weekends_occasions.
  ///
  /// In en, this message translates to:
  /// **'Weekends and Occasions'**
  String get onboarding_time_weekends_occasions;

  /// No description provided for @onboarding_time_weekends_occasions_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Outings and leisure'**
  String get onboarding_time_weekends_occasions_subtitle;

  /// No description provided for @onboarding_time_off_peak.
  ///
  /// In en, this message translates to:
  /// **'Off-peak Times'**
  String get onboarding_time_off_peak;

  /// No description provided for @onboarding_time_off_peak_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Offers to increase sales during quiet times'**
  String get onboarding_time_off_peak_subtitle;

  /// No description provided for @sellerOnboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s understand your business better\nto connect you with the right customers'**
  String get sellerOnboardingTitle;

  /// No description provided for @sellerOnboardingSubTitle.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get sellerOnboardingSubTitle;

  /// No description provided for @customerOnboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get to know you better...\nand offer you more'**
  String get customerOnboardingTitle;

  /// No description provided for @customerOnboardingSubTitle.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get customerOnboardingSubTitle;

  /// No description provided for @success_seller_onboarding_completed.
  ///
  /// In en, this message translates to:
  /// **'Store setup completed!'**
  String get success_seller_onboarding_completed;

  /// No description provided for @success_seller_price_category_updated.
  ///
  /// In en, this message translates to:
  /// **'Price category updated successfully'**
  String get success_seller_price_category_updated;

  /// No description provided for @success_seller_reach_method_updated.
  ///
  /// In en, this message translates to:
  /// **'Reach method updated successfully'**
  String get success_seller_reach_method_updated;

  /// No description provided for @success_seller_offer_time_updated.
  ///
  /// In en, this message translates to:
  /// **'Offer time updated successfully'**
  String get success_seller_offer_time_updated;

  /// No description provided for @success_seller_audience_updated.
  ///
  /// In en, this message translates to:
  /// **'Target audience updated successfully'**
  String get success_seller_audience_updated;

  /// No description provided for @success_seller_onboarding_all_updated.
  ///
  /// In en, this message translates to:
  /// **'All settings updated successfully'**
  String get success_seller_onboarding_all_updated;

  /// No description provided for @error_seller_onboarding_step1_incomplete.
  ///
  /// In en, this message translates to:
  /// **'Please select your price category'**
  String get error_seller_onboarding_step1_incomplete;

  /// No description provided for @error_seller_onboarding_step2_incomplete.
  ///
  /// In en, this message translates to:
  /// **'Please select how customers reach you'**
  String get error_seller_onboarding_step2_incomplete;

  /// No description provided for @error_seller_onboarding_step3_incomplete.
  ///
  /// In en, this message translates to:
  /// **'Please select your most active offer time'**
  String get error_seller_onboarding_step3_incomplete;

  /// No description provided for @error_seller_onboarding_step4_incomplete.
  ///
  /// In en, this message translates to:
  /// **'Please select your target audience'**
  String get error_seller_onboarding_step4_incomplete;

  /// No description provided for @error_unexpected.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get error_unexpected;

  /// No description provided for @create_store_phone_hint.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get create_store_phone_hint;

  /// No description provided for @create_store_verification_docs_label.
  ///
  /// In en, this message translates to:
  /// **'Verification Documents'**
  String get create_store_verification_docs_label;

  /// No description provided for @create_store_commercial_register_hint.
  ///
  /// In en, this message translates to:
  /// **'Commercial Register'**
  String get create_store_commercial_register_hint;

  /// No description provided for @create_store_tax_card_hint.
  ///
  /// In en, this message translates to:
  /// **'Tax Card'**
  String get create_store_tax_card_hint;

  /// No description provided for @create_store_id_front_hint.
  ///
  /// In en, this message translates to:
  /// **'ID Card (Front)'**
  String get create_store_id_front_hint;

  /// No description provided for @create_store_id_back_hint.
  ///
  /// In en, this message translates to:
  /// **'ID Card (Back)'**
  String get create_store_id_back_hint;

  /// No description provided for @create_store_socials_label.
  ///
  /// In en, this message translates to:
  /// **'Social Media Links'**
  String get create_store_socials_label;

  /// No description provided for @create_store_socials_empty.
  ///
  /// In en, this message translates to:
  /// **'No social links added yet'**
  String get create_store_socials_empty;

  /// No description provided for @create_store_add_social.
  ///
  /// In en, this message translates to:
  /// **'Add Link'**
  String get create_store_add_social;

  /// No description provided for @create_store_select_platform.
  ///
  /// In en, this message translates to:
  /// **'Select Platform'**
  String get create_store_select_platform;

  /// No description provided for @create_store_choose_platform.
  ///
  /// In en, this message translates to:
  /// **'Choose a social platform'**
  String get create_store_choose_platform;

  /// No description provided for @create_store_no_platforms.
  ///
  /// In en, this message translates to:
  /// **'No platforms available'**
  String get create_store_no_platforms;

  /// No description provided for @create_store_social_id_hint.
  ///
  /// In en, this message translates to:
  /// **'Platform ID (e.g. 1)'**
  String get create_store_social_id_hint;

  /// No description provided for @create_store_social_link_hint.
  ///
  /// In en, this message translates to:
  /// **'Link (e.g. https://facebook.com/...)'**
  String get create_store_social_link_hint;

  /// No description provided for @create_store_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get create_store_cancel;

  /// No description provided for @success_create_store.
  ///
  /// In en, this message translates to:
  /// **'Store created successfully!'**
  String get success_create_store;

  /// No description provided for @error_create_store_name_required.
  ///
  /// In en, this message translates to:
  /// **'Store name is required'**
  String get error_create_store_name_required;

  /// No description provided for @error_create_store_phone_required.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get error_create_store_phone_required;

  /// No description provided for @error_create_store_address_required.
  ///
  /// In en, this message translates to:
  /// **'Address is required'**
  String get error_create_store_address_required;

  /// No description provided for @error_create_store_category_required.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one category'**
  String get error_create_store_category_required;

  /// No description provided for @error_create_store_server.
  ///
  /// In en, this message translates to:
  /// **'Could not create store. Please try again'**
  String get error_create_store_server;

  /// No description provided for @create_store_location_section_label.
  ///
  /// In en, this message translates to:
  /// **'Store Location'**
  String get create_store_location_section_label;

  /// No description provided for @create_store_locate_button.
  ///
  /// In en, this message translates to:
  /// **'Detect My Location'**
  String get create_store_locate_button;

  /// No description provided for @create_store_location_fetched.
  ///
  /// In en, this message translates to:
  /// **'Location detected'**
  String get create_store_location_fetched;

  /// No description provided for @create_store_map_search_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Search for store location'**
  String get create_store_map_search_placeholder;

  /// No description provided for @create_store_map_your_location.
  ///
  /// In en, this message translates to:
  /// **'Your Location'**
  String get create_store_map_your_location;

  /// No description provided for @create_store_map_confirm_button.
  ///
  /// In en, this message translates to:
  /// **'Confirm Location'**
  String get create_store_map_confirm_button;

  /// No description provided for @create_store_map_use_current.
  ///
  /// In en, this message translates to:
  /// **'Use My Current Location'**
  String get create_store_map_use_current;

  /// No description provided for @create_store_map_no_results.
  ///
  /// In en, this message translates to:
  /// **'No search results found'**
  String get create_store_map_no_results;

  /// No description provided for @create_store_map_search_error.
  ///
  /// In en, this message translates to:
  /// **'Search error, please try again'**
  String get create_store_map_search_error;

  /// No description provided for @create_store_map_voice_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Voice search is unavailable'**
  String get create_store_map_voice_unavailable;

  /// No description provided for @create_store_map_tap_to_select.
  ///
  /// In en, this message translates to:
  /// **'Drag the map to select location'**
  String get create_store_map_tap_to_select;

  /// No description provided for @create_store_map_coordinates_format.
  ///
  /// In en, this message translates to:
  /// **'Coordinates: {lat}, {lng}'**
  String create_store_map_coordinates_format(Object lat, Object lng);

  /// No description provided for @error_create_store_location_denied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied. Please enable it in settings.'**
  String get error_create_store_location_denied;

  /// No description provided for @error_create_store_location_gps_off.
  ///
  /// In en, this message translates to:
  /// **'GPS is disabled. Please enable location services.'**
  String get error_create_store_location_gps_off;

  /// No description provided for @error_create_store_location_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not determine location. Please try again.'**
  String get error_create_store_location_failed;

  /// No description provided for @store_under_review_title.
  ///
  /// In en, this message translates to:
  /// **'Your request is under review'**
  String get store_under_review_title;

  /// No description provided for @store_under_review_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Your request is currently being reviewed, you will be notified upon completion'**
  String get store_under_review_subtitle;

  /// No description provided for @store_under_review_home_button.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get store_under_review_home_button;

  /// No description provided for @store_under_review_contact_button.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get store_under_review_contact_button;

  /// No description provided for @store_under_review_whatsapp_button.
  ///
  /// In en, this message translates to:
  /// **'Chat on WhatsApp'**
  String get store_under_review_whatsapp_button;

  /// No description provided for @store_under_review_email_button.
  ///
  /// In en, this message translates to:
  /// **'Send us an Email'**
  String get store_under_review_email_button;

  /// No description provided for @under_review_title.
  ///
  /// In en, this message translates to:
  /// **'Your Store is Under Review'**
  String get under_review_title;

  /// No description provided for @under_review_body.
  ///
  /// In en, this message translates to:
  /// **'Our team is reviewing your information. You\'ll receive a notification once your store is approved.'**
  String get under_review_body;

  /// No description provided for @contact_support.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contact_support;

  /// No description provided for @select_store.
  ///
  /// In en, this message translates to:
  /// **'Select Your Store'**
  String get select_store;

  /// No description provided for @select_store_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the store you\'d like to manage'**
  String get select_store_subtitle;

  /// No description provided for @select_store_active_badge.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get select_store_active_badge;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logout_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout_dialog_title;

  /// No description provided for @logout_dialog_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logout_dialog_message;

  /// No description provided for @logout_dialog_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get logout_dialog_cancel;

  /// No description provided for @logout_dialog_confirm.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout_dialog_confirm;

  /// No description provided for @logout_success.
  ///
  /// In en, this message translates to:
  /// **'Logged out successfully'**
  String get logout_success;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @coupons.
  ///
  /// In en, this message translates to:
  /// **'My Coupons'**
  String get coupons;

  /// No description provided for @explorer.
  ///
  /// In en, this message translates to:
  /// **'Explorer'**
  String get explorer;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @store.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get store;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @offers.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get offers;

  /// No description provided for @profile_title.
  ///
  /// In en, this message translates to:
  /// **'Personal Account'**
  String get profile_title;

  /// No description provided for @profile_edit_account.
  ///
  /// In en, this message translates to:
  /// **'Edit Account'**
  String get profile_edit_account;

  /// No description provided for @profile_favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites List'**
  String get profile_favorites;

  /// No description provided for @profile_be_seller.
  ///
  /// In en, this message translates to:
  /// **'Become a Seller'**
  String get profile_be_seller;

  /// No description provided for @profile_follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get profile_follow;

  /// No description provided for @profile_address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get profile_address;

  /// No description provided for @profile_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profile_settings;

  /// No description provided for @profile_support.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get profile_support;

  /// No description provided for @profile_version.
  ///
  /// In en, this message translates to:
  /// **'Version: {version}'**
  String profile_version(Object version);

  /// No description provided for @profile_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading data...'**
  String get profile_loading;

  /// No description provided for @profile_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading data'**
  String get profile_error;

  /// No description provided for @profile_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get profile_retry;

  /// No description provided for @profile_default_user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get profile_default_user;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit_account.
  ///
  /// In en, this message translates to:
  /// **'Edit Account'**
  String get edit_account;

  /// No description provided for @first_name.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get first_name;

  /// No description provided for @last_name.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get last_name;

  /// No description provided for @phone_number.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone_number;

  /// No description provided for @edit_profile_title.
  ///
  /// In en, this message translates to:
  /// **'Personal Account'**
  String get edit_profile_title;

  /// No description provided for @profile_update_success.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profile_update_success;

  /// No description provided for @profile_photo_view.
  ///
  /// In en, this message translates to:
  /// **'View Photo'**
  String get profile_photo_view;

  /// No description provided for @profile_photo_change.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get profile_photo_change;

  /// No description provided for @profile_photo_remove.
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get profile_photo_remove;

  /// No description provided for @profile_photo_camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get profile_photo_camera;

  /// No description provided for @profile_photo_gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get profile_photo_gallery;

  /// No description provided for @profile_photo_remove_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get profile_photo_remove_confirm_title;

  /// No description provided for @profile_photo_remove_confirm_message.
  ///
  /// In en, this message translates to:
  /// **'Your profile photo will be permanently deleted'**
  String get profile_photo_remove_confirm_message;

  /// No description provided for @profile_photo_remove_confirm_button.
  ///
  /// In en, this message translates to:
  /// **'Yes, Delete'**
  String get profile_photo_remove_confirm_button;

  /// No description provided for @profile_photo_remove_cancel_button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profile_photo_remove_cancel_button;

  /// No description provided for @address_management_title.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address_management_title;

  /// No description provided for @address_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No addresses added yet'**
  String get address_empty_title;

  /// No description provided for @address_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your address so we can deliver coupons easily'**
  String get address_empty_subtitle;

  /// No description provided for @address_add_new.
  ///
  /// In en, this message translates to:
  /// **'Add New Address'**
  String get address_add_new;

  /// No description provided for @address_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search for area, city...'**
  String get address_search_hint;

  /// No description provided for @address_search_no_results.
  ///
  /// In en, this message translates to:
  /// **'No results found for'**
  String get address_search_no_results;

  /// No description provided for @address_label_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Label Address'**
  String get address_label_dialog_title;

  /// No description provided for @address_label_dialog_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name for easy access later'**
  String get address_label_dialog_subtitle;

  /// No description provided for @address_label_hint.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get address_label_hint;

  /// No description provided for @address_label_required.
  ///
  /// In en, this message translates to:
  /// **'Please enter an address name'**
  String get address_label_required;

  /// No description provided for @address_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get address_save;

  /// No description provided for @address_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get address_cancel;

  /// No description provided for @address_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get address_edit;

  /// No description provided for @address_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get address_delete;

  /// No description provided for @address_set_default.
  ///
  /// In en, this message translates to:
  /// **'Set as Default'**
  String get address_set_default;

  /// No description provided for @address_set_default_success.
  ///
  /// In en, this message translates to:
  /// **'Address set as default successfully'**
  String get address_set_default_success;

  /// No description provided for @address_default_badge.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get address_default_badge;

  /// No description provided for @address_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Delete Address'**
  String get address_delete_title;

  /// No description provided for @address_delete_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this address?'**
  String get address_delete_message;

  /// No description provided for @address_select_location_first.
  ///
  /// In en, this message translates to:
  /// **'Please select a location on the map first'**
  String get address_select_location_first;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @current_location_default_name.
  ///
  /// In en, this message translates to:
  /// **'Your Current Location'**
  String get current_location_default_name;

  /// No description provided for @settings_notifications_open_settings.
  ///
  /// In en, this message translates to:
  /// **'Please allow notifications from device settings'**
  String get settings_notifications_open_settings;

  /// No description provided for @help_support_title.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get help_support_title;

  /// No description provided for @help_faq_title.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get help_faq_title;

  /// No description provided for @help_faq_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Answers to the most common questions'**
  String get help_faq_subtitle;

  /// No description provided for @help_usage_guide_title.
  ///
  /// In en, this message translates to:
  /// **'Usage Guide'**
  String get help_usage_guide_title;

  /// No description provided for @help_usage_guide_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn how to use the app'**
  String get help_usage_guide_subtitle;

  /// No description provided for @help_report_problem_title.
  ///
  /// In en, this message translates to:
  /// **'Report a Problem'**
  String get help_report_problem_title;

  /// No description provided for @help_report_problem_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Let us know if you face any issues'**
  String get help_report_problem_subtitle;

  /// No description provided for @help_rate_app_title.
  ///
  /// In en, this message translates to:
  /// **'Rate the App'**
  String get help_rate_app_title;

  /// No description provided for @help_rate_app_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Share your opinion about the app'**
  String get help_rate_app_subtitle;

  /// No description provided for @help_terms_title.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get help_terms_title;

  /// No description provided for @help_terms_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Review the app\'s terms of use'**
  String get help_terms_subtitle;

  /// No description provided for @help_contact_us_title.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get help_contact_us_title;

  /// No description provided for @help_contact_us_subtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'re here to help you 24/7'**
  String get help_contact_us_subtitle;

  /// No description provided for @contact_us_page_title.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contact_us_page_title;

  /// No description provided for @contact_whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get contact_whatsapp;

  /// No description provided for @contact_facebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get contact_facebook;

  /// No description provided for @contact_website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get contact_website;

  /// No description provided for @contact_instagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get contact_instagram;

  /// No description provided for @contact_open_error.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link'**
  String get contact_open_error;

  /// No description provided for @faq_q1.
  ///
  /// In en, this message translates to:
  /// **'What is Coupony?'**
  String get faq_q1;

  /// No description provided for @faq_a1.
  ///
  /// In en, this message translates to:
  /// **'Coupony is an app that provides you with the best coupons, deals, and discounts from your favorite stores in one place.'**
  String get faq_a1;

  /// No description provided for @faq_q2.
  ///
  /// In en, this message translates to:
  /// **'How do I use a coupon?'**
  String get faq_q2;

  /// No description provided for @faq_a2.
  ///
  /// In en, this message translates to:
  /// **'After browsing available offers, tap on the coupon to copy it, then use it when making a purchase from the store, either online or in-store.'**
  String get faq_a2;

  /// No description provided for @faq_q3.
  ///
  /// In en, this message translates to:
  /// **'Is the app free?'**
  String get faq_q3;

  /// No description provided for @faq_a3.
  ///
  /// In en, this message translates to:
  /// **'Yes, Coupony is completely free. You can browse and use all coupons and offers without any fees.'**
  String get faq_a3;

  /// No description provided for @faq_q4.
  ///
  /// In en, this message translates to:
  /// **'How do I contact support?'**
  String get faq_q4;

  /// No description provided for @faq_a4.
  ///
  /// In en, this message translates to:
  /// **'You can reach us through the \"Contact Us\" page in the Help & Support section, or directly via WhatsApp.'**
  String get faq_a4;

  /// No description provided for @faq_q5.
  ///
  /// In en, this message translates to:
  /// **'Can I become a merchant?'**
  String get faq_q5;

  /// No description provided for @faq_a5.
  ///
  /// In en, this message translates to:
  /// **'Absolutely! You can register as a merchant from the profile page by tapping \"Become a Seller\" to create your store.'**
  String get faq_a5;

  /// No description provided for @faq_seller_q1.
  ///
  /// In en, this message translates to:
  /// **'How do I create my first offer?'**
  String get faq_seller_q1;

  /// No description provided for @faq_seller_a1.
  ///
  /// In en, this message translates to:
  /// **'From your store dashboard, tap \"Add Offer\", fill in the offer details including discount percentage, validity period, and terms. Your offer will be reviewed before going live.'**
  String get faq_seller_a1;

  /// No description provided for @faq_seller_q2.
  ///
  /// In en, this message translates to:
  /// **'How long does store approval take?'**
  String get faq_seller_q2;

  /// No description provided for @faq_seller_a2.
  ///
  /// In en, this message translates to:
  /// **'Store approval typically takes 24-48 hours. You\'ll receive a notification once your store is approved and ready to publish offers.'**
  String get faq_seller_a2;

  /// No description provided for @faq_seller_q3.
  ///
  /// In en, this message translates to:
  /// **'Are there any fees for sellers?'**
  String get faq_seller_q3;

  /// No description provided for @faq_seller_a3.
  ///
  /// In en, this message translates to:
  /// **'Currently, Coupony is free for all sellers. We may introduce premium features in the future, but basic store and offer management will remain free.'**
  String get faq_seller_a3;

  /// No description provided for @faq_seller_q4.
  ///
  /// In en, this message translates to:
  /// **'How do I track my offer performance?'**
  String get faq_seller_q4;

  /// No description provided for @faq_seller_a4.
  ///
  /// In en, this message translates to:
  /// **'Your dashboard provides detailed analytics including views, coupon usage, and customer engagement. You can track performance for each offer individually.'**
  String get faq_seller_a4;

  /// No description provided for @faq_seller_q5.
  ///
  /// In en, this message translates to:
  /// **'Can I edit or delete published offers?'**
  String get faq_seller_q5;

  /// No description provided for @faq_seller_a5.
  ///
  /// In en, this message translates to:
  /// **'Yes! You can edit offer details or delete offers anytime from your store management page. Changes to active offers take effect immediately.'**
  String get faq_seller_a5;

  /// No description provided for @guide_step1_title.
  ///
  /// In en, this message translates to:
  /// **'Create an Account'**
  String get guide_step1_title;

  /// No description provided for @guide_step1_desc.
  ///
  /// In en, this message translates to:
  /// **'Register a new account using your email or enter as a guest to browse offers.'**
  String get guide_step1_desc;

  /// No description provided for @guide_step2_title.
  ///
  /// In en, this message translates to:
  /// **'Browse Offers'**
  String get guide_step2_title;

  /// No description provided for @guide_step2_desc.
  ///
  /// In en, this message translates to:
  /// **'Explore the latest offers and coupons from stores near you or based on your interests.'**
  String get guide_step2_desc;

  /// No description provided for @guide_step3_title.
  ///
  /// In en, this message translates to:
  /// **'Choose a Coupon'**
  String get guide_step3_title;

  /// No description provided for @guide_step3_desc.
  ///
  /// In en, this message translates to:
  /// **'Tap on the offer you like to view coupon details and available discount.'**
  String get guide_step3_desc;

  /// No description provided for @guide_step4_title.
  ///
  /// In en, this message translates to:
  /// **'Copy the Code'**
  String get guide_step4_title;

  /// No description provided for @guide_step4_desc.
  ///
  /// In en, this message translates to:
  /// **'Copy the discount code with a single tap and use it when shopping.'**
  String get guide_step4_desc;

  /// No description provided for @guide_step5_title.
  ///
  /// In en, this message translates to:
  /// **'Enjoy the Discount'**
  String get guide_step5_title;

  /// No description provided for @guide_step5_desc.
  ///
  /// In en, this message translates to:
  /// **'Present the coupon at checkout and enjoy savings whether online or in-store.'**
  String get guide_step5_desc;

  /// No description provided for @guide_seller_step1_title.
  ///
  /// In en, this message translates to:
  /// **'Create Your Store'**
  String get guide_seller_step1_title;

  /// No description provided for @guide_seller_step1_desc.
  ///
  /// In en, this message translates to:
  /// **'Register as a seller and create your store by adding store information and logo.'**
  String get guide_seller_step1_desc;

  /// No description provided for @guide_seller_step2_title.
  ///
  /// In en, this message translates to:
  /// **'Add Offers'**
  String get guide_seller_step2_title;

  /// No description provided for @guide_seller_step2_desc.
  ///
  /// In en, this message translates to:
  /// **'Create attractive offers and coupons for your customers with discount rates and duration.'**
  String get guide_seller_step2_desc;

  /// No description provided for @guide_seller_step3_title.
  ///
  /// In en, this message translates to:
  /// **'Manage Offers'**
  String get guide_seller_step3_title;

  /// No description provided for @guide_seller_step3_desc.
  ///
  /// In en, this message translates to:
  /// **'Track your offers performance, views, and usage from the dashboard.'**
  String get guide_seller_step3_desc;

  /// No description provided for @guide_seller_step4_title.
  ///
  /// In en, this message translates to:
  /// **'Engage with Customers'**
  String get guide_seller_step4_title;

  /// No description provided for @guide_seller_step4_desc.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications when customers use your coupons and interact with them.'**
  String get guide_seller_step4_desc;

  /// No description provided for @guide_seller_step5_title.
  ///
  /// In en, this message translates to:
  /// **'Boost Sales'**
  String get guide_seller_step5_title;

  /// No description provided for @guide_seller_step5_desc.
  ///
  /// In en, this message translates to:
  /// **'Leverage analytics to improve your offers and attract more customers.'**
  String get guide_seller_step5_desc;

  /// No description provided for @report_problem_description.
  ///
  /// In en, this message translates to:
  /// **'Tell us about the problem you encountered and we\'ll work on fixing it as soon as possible'**
  String get report_problem_description;

  /// No description provided for @report_problem_subject.
  ///
  /// In en, this message translates to:
  /// **'Problem Subject'**
  String get report_problem_subject;

  /// No description provided for @report_problem_details.
  ///
  /// In en, this message translates to:
  /// **'Problem Details'**
  String get report_problem_details;

  /// No description provided for @report_problem_submit.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get report_problem_submit;

  /// No description provided for @report_problem_empty_error.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get report_problem_empty_error;

  /// No description provided for @report_problem_success.
  ///
  /// In en, this message translates to:
  /// **'Report submitted successfully, thank you!'**
  String get report_problem_success;

  /// No description provided for @rate_app_heading.
  ///
  /// In en, this message translates to:
  /// **'Rate Your Experience'**
  String get rate_app_heading;

  /// No description provided for @rate_app_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Share your feedback to help us improve your experience'**
  String get rate_app_subtitle;

  /// No description provided for @rate_app_comment_hint.
  ///
  /// In en, this message translates to:
  /// **'Add your comment here (optional)'**
  String get rate_app_comment_hint;

  /// No description provided for @rate_app_submit.
  ///
  /// In en, this message translates to:
  /// **'Submit Rating'**
  String get rate_app_submit;

  /// No description provided for @rate_app_select_rating.
  ///
  /// In en, this message translates to:
  /// **'Please select a rating'**
  String get rate_app_select_rating;

  /// No description provided for @rate_app_success.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your rating!'**
  String get rate_app_success;

  /// No description provided for @terms_last_updated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: April 2026'**
  String get terms_last_updated;

  /// No description provided for @terms_section1_title.
  ///
  /// In en, this message translates to:
  /// **'Acceptance of Terms'**
  String get terms_section1_title;

  /// No description provided for @terms_section1_content.
  ///
  /// In en, this message translates to:
  /// **'By using the Coupony app, you agree to be bound by these terms and conditions. If you do not agree to these terms, please do not use the app.'**
  String get terms_section1_content;

  /// No description provided for @terms_section2_title.
  ///
  /// In en, this message translates to:
  /// **'App Usage'**
  String get terms_section2_title;

  /// No description provided for @terms_section2_content.
  ///
  /// In en, this message translates to:
  /// **'You are permitted to use the app for personal, non-commercial purposes only. You may not copy, modify, distribute, or sell any part of the app without prior permission.'**
  String get terms_section2_content;

  /// No description provided for @terms_section3_title.
  ///
  /// In en, this message translates to:
  /// **'Your Account'**
  String get terms_section3_title;

  /// No description provided for @terms_section3_content.
  ///
  /// In en, this message translates to:
  /// **'You are responsible for maintaining the confidentiality of your account information and password. You agree to notify us immediately of any unauthorized use of your account.'**
  String get terms_section3_content;

  /// No description provided for @terms_section4_title.
  ///
  /// In en, this message translates to:
  /// **'Coupons & Offers'**
  String get terms_section4_title;

  /// No description provided for @terms_section4_content.
  ///
  /// In en, this message translates to:
  /// **'All coupons and offers displayed in the app are subject to the terms and conditions of the advertising stores. Coupony is not responsible for the validity or changes in terms of any offer.'**
  String get terms_section4_content;

  /// No description provided for @terms_section5_title.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get terms_section5_title;

  /// No description provided for @terms_section5_content.
  ///
  /// In en, this message translates to:
  /// **'We respect your privacy and are committed to protecting your personal data. For more information, please review our privacy policy.'**
  String get terms_section5_content;

  /// No description provided for @terms_seller_section1_title.
  ///
  /// In en, this message translates to:
  /// **'Seller Terms Acceptance'**
  String get terms_seller_section1_title;

  /// No description provided for @terms_seller_section1_content.
  ///
  /// In en, this message translates to:
  /// **'By registering as a seller on Coupony, you agree to comply with these seller-specific terms and conditions. If you do not agree, please do not create a store.'**
  String get terms_seller_section1_content;

  /// No description provided for @terms_seller_section2_title.
  ///
  /// In en, this message translates to:
  /// **'Seller Responsibilities'**
  String get terms_seller_section2_title;

  /// No description provided for @terms_seller_section2_content.
  ///
  /// In en, this message translates to:
  /// **'You are responsible for the accuracy of information and offers you publish. All coupons must be valid and usable. Any misleading content may result in account suspension.'**
  String get terms_seller_section2_content;

  /// No description provided for @terms_seller_section3_title.
  ///
  /// In en, this message translates to:
  /// **'Store Management'**
  String get terms_seller_section3_title;

  /// No description provided for @terms_seller_section3_content.
  ///
  /// In en, this message translates to:
  /// **'You must keep your store information up-to-date and manage your offers regularly. You are responsible for responding to customer inquiries and resolving issues related to your offers.'**
  String get terms_seller_section3_content;

  /// No description provided for @terms_seller_section4_title.
  ///
  /// In en, this message translates to:
  /// **'Offers & Coupons'**
  String get terms_seller_section4_title;

  /// No description provided for @terms_seller_section4_content.
  ///
  /// In en, this message translates to:
  /// **'You must honor the terms of offers you publish. Coupony reserves the right to remove any offer that violates policies or receives repeated customer complaints.'**
  String get terms_seller_section4_content;

  /// No description provided for @terms_seller_section5_title.
  ///
  /// In en, this message translates to:
  /// **'Fees & Payments'**
  String get terms_seller_section5_title;

  /// No description provided for @terms_seller_section5_content.
  ///
  /// In en, this message translates to:
  /// **'Platform usage is currently free for sellers. We reserve the right to implement future fees with advance notice. Any pricing model changes will be communicated to you.'**
  String get terms_seller_section5_content;

  /// No description provided for @terms_seller_section6_title.
  ///
  /// In en, this message translates to:
  /// **'Account Termination'**
  String get terms_seller_section6_title;

  /// No description provided for @terms_seller_section6_content.
  ///
  /// In en, this message translates to:
  /// **'We reserve the right to suspend or terminate seller accounts for terms violations or repeated complaints. You may close your account anytime from store settings.'**
  String get terms_seller_section6_content;

  /// No description provided for @staff_list_title.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staff_list_title;

  /// No description provided for @staff_filter_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get staff_filter_all;

  /// No description provided for @staff_filter_active.
  ///
  /// In en, this message translates to:
  /// **'Active Staff'**
  String get staff_filter_active;

  /// No description provided for @staff_filter_stopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped Staff'**
  String get staff_filter_stopped;

  /// No description provided for @staff_status_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get staff_status_active;

  /// No description provided for @staff_status_stopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get staff_status_stopped;

  /// No description provided for @staff_role_cashier.
  ///
  /// In en, this message translates to:
  /// **'Cashier'**
  String get staff_role_cashier;

  /// No description provided for @staff_branch_label.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get staff_branch_label;

  /// No description provided for @staff_joined_since.
  ///
  /// In en, this message translates to:
  /// **'Since'**
  String get staff_joined_since;

  /// No description provided for @staff_menu_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get staff_menu_edit;

  /// No description provided for @staff_menu_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get staff_menu_delete;

  /// No description provided for @staff_delete_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Confirm Staff Deletion'**
  String get staff_delete_confirm_title;

  /// No description provided for @staff_delete_confirm_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this staff member?'**
  String get staff_delete_confirm_message;

  /// No description provided for @staff_delete_confirm_button.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get staff_delete_confirm_button;

  /// No description provided for @staff_delete_cancel_button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get staff_delete_cancel_button;

  /// No description provided for @staff_empty_message.
  ///
  /// In en, this message translates to:
  /// **'No staff members found'**
  String get staff_empty_message;

  /// No description provided for @staff_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search for staff...'**
  String get staff_search_hint;

  /// No description provided for @staff_no_search_results.
  ///
  /// In en, this message translates to:
  /// **'No search results found'**
  String get staff_no_search_results;

  /// No description provided for @staff_edit_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get staff_edit_save;

  /// No description provided for @staff_edit_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get staff_edit_cancel;

  /// No description provided for @staff_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Staff Name'**
  String get staff_name_hint;

  /// No description provided for @staff_role_hint.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get staff_role_hint;

  /// No description provided for @staff_branch_hint.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get staff_branch_hint;

  /// No description provided for @staff_update_success.
  ///
  /// In en, this message translates to:
  /// **'Staff updated successfully'**
  String get staff_update_success;

  /// No description provided for @staff_update_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to update staff'**
  String get staff_update_error;

  /// No description provided for @staff_add_title.
  ///
  /// In en, this message translates to:
  /// **'Add New Staff'**
  String get staff_add_title;

  /// No description provided for @staff_add_personal_info.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get staff_add_personal_info;

  /// No description provided for @staff_add_role_assignment.
  ///
  /// In en, this message translates to:
  /// **'Role & Assignment'**
  String get staff_add_role_assignment;

  /// No description provided for @staff_add_learn_more.
  ///
  /// In en, this message translates to:
  /// **'Learn More About Roles'**
  String get staff_add_learn_more;

  /// No description provided for @staff_add_email_hint.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get staff_add_email_hint;

  /// No description provided for @staff_add_branch_hint.
  ///
  /// In en, this message translates to:
  /// **'Select Branch'**
  String get staff_add_branch_hint;

  /// No description provided for @staff_add_submit.
  ///
  /// In en, this message translates to:
  /// **'Send Invitation'**
  String get staff_add_submit;

  /// No description provided for @staff_add_success.
  ///
  /// In en, this message translates to:
  /// **'Staff member added successfully'**
  String get staff_add_success;

  /// No description provided for @staff_add_error_name_required.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get staff_add_error_name_required;

  /// No description provided for @staff_add_error_email_required.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get staff_add_error_email_required;

  /// No description provided for @staff_add_error_email_invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get staff_add_error_email_invalid;

  /// No description provided for @staff_add_error_role_required.
  ///
  /// In en, this message translates to:
  /// **'Please select a role'**
  String get staff_add_error_role_required;

  /// No description provided for @staff_add_error_branch_required.
  ///
  /// In en, this message translates to:
  /// **'Please select a branch'**
  String get staff_add_error_branch_required;

  /// No description provided for @staff_role_analyst.
  ///
  /// In en, this message translates to:
  /// **'Data Analyst'**
  String get staff_role_analyst;

  /// No description provided for @staff_role_manager.
  ///
  /// In en, this message translates to:
  /// **'General Manager'**
  String get staff_role_manager;

  /// No description provided for @staff_roles_comparison_title.
  ///
  /// In en, this message translates to:
  /// **'Role Permissions Comparison'**
  String get staff_roles_comparison_title;

  /// No description provided for @staff_permission_label.
  ///
  /// In en, this message translates to:
  /// **'Permission'**
  String get staff_permission_label;

  /// No description provided for @staff_permission_scan_qr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get staff_permission_scan_qr;

  /// No description provided for @staff_permission_view_data.
  ///
  /// In en, this message translates to:
  /// **'View Data'**
  String get staff_permission_view_data;

  /// No description provided for @staff_permission_add_data.
  ///
  /// In en, this message translates to:
  /// **'Add Data'**
  String get staff_permission_add_data;

  /// No description provided for @staff_permission_edit_data.
  ///
  /// In en, this message translates to:
  /// **'Edit Data'**
  String get staff_permission_edit_data;

  /// No description provided for @staff_permission_delete_data.
  ///
  /// In en, this message translates to:
  /// **'Delete Data'**
  String get staff_permission_delete_data;

  /// No description provided for @notifications_page_title.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications_page_title;

  /// No description provided for @notifications_sort_newest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get notifications_sort_newest;

  /// No description provided for @notifications_sort_oldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get notifications_sort_oldest;

  /// No description provided for @notifications_filter_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get notifications_filter_all;

  /// No description provided for @notifications_filter_offer.
  ///
  /// In en, this message translates to:
  /// **'Offer'**
  String get notifications_filter_offer;

  /// No description provided for @notifications_filter_coupon.
  ///
  /// In en, this message translates to:
  /// **'Coupon'**
  String get notifications_filter_coupon;

  /// No description provided for @notifications_filter_system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get notifications_filter_system;

  /// No description provided for @notifications_filter_general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get notifications_filter_general;

  /// No description provided for @notifications_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get notifications_empty_title;

  /// No description provided for @notifications_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll let you know when there\'s something new'**
  String get notifications_empty_subtitle;

  /// No description provided for @notifications_type_coupon.
  ///
  /// In en, this message translates to:
  /// **'Coupon'**
  String get notifications_type_coupon;

  /// No description provided for @notifications_type_offer.
  ///
  /// In en, this message translates to:
  /// **'Offer'**
  String get notifications_type_offer;

  /// No description provided for @notifications_type_system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get notifications_type_system;

  /// No description provided for @notifications_type_general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get notifications_type_general;

  /// No description provided for @notifications_details_page_title.
  ///
  /// In en, this message translates to:
  /// **'Notification Details'**
  String get notifications_details_page_title;

  /// No description provided for @notifications_details_message_label.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get notifications_details_message_label;

  /// No description provided for @seller_notifications_filter_order.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get seller_notifications_filter_order;

  /// No description provided for @seller_notifications_filter_store.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get seller_notifications_filter_store;

  /// No description provided for @seller_notifications_filter_analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get seller_notifications_filter_analytics;

  /// No description provided for @seller_notifications_filter_employee.
  ///
  /// In en, this message translates to:
  /// **'Employees'**
  String get seller_notifications_filter_employee;

  /// No description provided for @seller_notifications_type_order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get seller_notifications_type_order;

  /// No description provided for @seller_notifications_type_store.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get seller_notifications_type_store;

  /// No description provided for @seller_notifications_type_analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get seller_notifications_type_analytics;

  /// No description provided for @seller_notifications_type_employee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get seller_notifications_type_employee;

  /// No description provided for @notification_badge_approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get notification_badge_approved;

  /// No description provided for @notification_badge_rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get notification_badge_rejected;

  /// No description provided for @notification_badge_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get notification_badge_pending;

  /// No description provided for @notification_badge_used.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get notification_badge_used;

  /// No description provided for @contact_us_heading.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contact_us_heading;

  /// No description provided for @contact_us_description.
  ///
  /// In en, this message translates to:
  /// **'We\'re here to help you anytime'**
  String get contact_us_description;

  /// No description provided for @seller_products_title.
  ///
  /// In en, this message translates to:
  /// **'My Products'**
  String get seller_products_title;

  /// No description provided for @seller_products_empty.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get seller_products_empty;

  /// No description provided for @seller_products_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first product to start selling'**
  String get seller_products_empty_subtitle;

  /// No description provided for @seller_product_add.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get seller_product_add;

  /// No description provided for @seller_product_title_hint.
  ///
  /// In en, this message translates to:
  /// **'Product Title'**
  String get seller_product_title_hint;

  /// No description provided for @seller_product_slug_hint.
  ///
  /// In en, this message translates to:
  /// **'Slug (URL-friendly name)'**
  String get seller_product_slug_hint;

  /// No description provided for @seller_product_short_desc_hint.
  ///
  /// In en, this message translates to:
  /// **'Short Description'**
  String get seller_product_short_desc_hint;

  /// No description provided for @seller_product_desc_hint.
  ///
  /// In en, this message translates to:
  /// **'Full Description'**
  String get seller_product_desc_hint;

  /// No description provided for @seller_product_type_hint.
  ///
  /// In en, this message translates to:
  /// **'Product Type'**
  String get seller_product_type_hint;

  /// No description provided for @seller_product_base_price_hint.
  ///
  /// In en, this message translates to:
  /// **'Base Price'**
  String get seller_product_base_price_hint;

  /// No description provided for @seller_product_compare_price_hint.
  ///
  /// In en, this message translates to:
  /// **'Compare at Price'**
  String get seller_product_compare_price_hint;

  /// No description provided for @seller_product_currency_hint.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get seller_product_currency_hint;

  /// No description provided for @seller_product_sku_hint.
  ///
  /// In en, this message translates to:
  /// **'SKU'**
  String get seller_product_sku_hint;

  /// No description provided for @seller_product_status_hint.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get seller_product_status_hint;

  /// No description provided for @seller_product_status_draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get seller_product_status_draft;

  /// No description provided for @seller_product_status_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get seller_product_status_active;

  /// No description provided for @seller_product_status_inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get seller_product_status_inactive;

  /// No description provided for @seller_product_is_featured.
  ///
  /// In en, this message translates to:
  /// **'Featured Product'**
  String get seller_product_is_featured;

  /// No description provided for @seller_product_categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get seller_product_categories;

  /// No description provided for @seller_product_images.
  ///
  /// In en, this message translates to:
  /// **'Product Images'**
  String get seller_product_images;

  /// No description provided for @seller_product_add_image.
  ///
  /// In en, this message translates to:
  /// **'Add Image'**
  String get seller_product_add_image;

  /// No description provided for @seller_product_variants.
  ///
  /// In en, this message translates to:
  /// **'Variants'**
  String get seller_product_variants;

  /// No description provided for @seller_product_add_variant.
  ///
  /// In en, this message translates to:
  /// **'Add Variant'**
  String get seller_product_add_variant;

  /// No description provided for @seller_product_variant_title_hint.
  ///
  /// In en, this message translates to:
  /// **'Variant Title (e.g. Red / XL)'**
  String get seller_product_variant_title_hint;

  /// No description provided for @seller_product_variant_sku_hint.
  ///
  /// In en, this message translates to:
  /// **'Variant SKU'**
  String get seller_product_variant_sku_hint;

  /// No description provided for @seller_product_variant_price_hint.
  ///
  /// In en, this message translates to:
  /// **'Variant Price'**
  String get seller_product_variant_price_hint;

  /// No description provided for @seller_product_attributes.
  ///
  /// In en, this message translates to:
  /// **'Attributes'**
  String get seller_product_attributes;

  /// No description provided for @seller_product_attribute_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Attribute Name (e.g. color)'**
  String get seller_product_attribute_name_hint;

  /// No description provided for @seller_product_attribute_value_hint.
  ///
  /// In en, this message translates to:
  /// **'Attribute Value (e.g. red)'**
  String get seller_product_attribute_value_hint;

  /// No description provided for @seller_product_save.
  ///
  /// In en, this message translates to:
  /// **'Save Product'**
  String get seller_product_save;

  /// No description provided for @seller_product_update.
  ///
  /// In en, this message translates to:
  /// **'Update Product'**
  String get seller_product_update;

  /// No description provided for @seller_product_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete Product'**
  String get seller_product_delete;

  /// No description provided for @seller_product_delete_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Delete Product'**
  String get seller_product_delete_confirm_title;

  /// No description provided for @seller_product_delete_confirm_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this product? This action cannot be undone.'**
  String get seller_product_delete_confirm_message;

  /// No description provided for @seller_product_delete_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get seller_product_delete_cancel;

  /// No description provided for @seller_product_delete_confirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get seller_product_delete_confirm;

  /// No description provided for @success_seller_product_created.
  ///
  /// In en, this message translates to:
  /// **'Product created successfully!'**
  String get success_seller_product_created;

  /// No description provided for @success_seller_product_updated.
  ///
  /// In en, this message translates to:
  /// **'Product updated successfully!'**
  String get success_seller_product_updated;

  /// No description provided for @success_seller_product_deleted.
  ///
  /// In en, this message translates to:
  /// **'Product deleted successfully!'**
  String get success_seller_product_deleted;

  /// No description provided for @success_seller_product_status_updated.
  ///
  /// In en, this message translates to:
  /// **'Product status updated successfully!'**
  String get success_seller_product_status_updated;

  /// No description provided for @error_seller_product_title_required.
  ///
  /// In en, this message translates to:
  /// **'Product title is required'**
  String get error_seller_product_title_required;

  /// No description provided for @error_seller_product_price_required.
  ///
  /// In en, this message translates to:
  /// **'Base price is required'**
  String get error_seller_product_price_required;

  /// No description provided for @error_seller_product_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load products. Please try again'**
  String get error_seller_product_load_failed;

  /// No description provided for @error_seller_product_not_found.
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get error_seller_product_not_found;

  /// No description provided for @public_products_title.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get public_products_title;

  /// No description provided for @public_products_empty.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get public_products_empty;

  /// No description provided for @public_products_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters'**
  String get public_products_empty_subtitle;

  /// No description provided for @public_products_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get public_products_search_hint;

  /// No description provided for @public_products_filter_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get public_products_filter_all;

  /// No description provided for @public_products_filter_featured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get public_products_filter_featured;

  /// No description provided for @public_products_loading_more.
  ///
  /// In en, this message translates to:
  /// **'Loading more products...'**
  String get public_products_loading_more;

  /// No description provided for @public_products_no_more.
  ///
  /// In en, this message translates to:
  /// **'No more products'**
  String get public_products_no_more;

  /// No description provided for @public_product_details_title.
  ///
  /// In en, this message translates to:
  /// **'Product Details'**
  String get public_product_details_title;

  /// No description provided for @public_product_price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get public_product_price;

  /// No description provided for @public_product_compare_price.
  ///
  /// In en, this message translates to:
  /// **'Was'**
  String get public_product_compare_price;

  /// No description provided for @public_product_sku.
  ///
  /// In en, this message translates to:
  /// **'SKU'**
  String get public_product_sku;

  /// No description provided for @public_product_variants.
  ///
  /// In en, this message translates to:
  /// **'Variants'**
  String get public_product_variants;

  /// No description provided for @public_product_images.
  ///
  /// In en, this message translates to:
  /// **'Product Images'**
  String get public_product_images;

  /// No description provided for @public_product_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get public_product_description;

  /// No description provided for @public_product_featured_badge.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get public_product_featured_badge;

  /// No description provided for @public_categories_title.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get public_categories_title;

  /// No description provided for @public_categories_all.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get public_categories_all;

  /// No description provided for @public_categories_empty.
  ///
  /// In en, this message translates to:
  /// **'No categories available'**
  String get public_categories_empty;

  /// No description provided for @public_categories_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to load categories'**
  String get public_categories_error;

  /// No description provided for @public_category_products_title.
  ///
  /// In en, this message translates to:
  /// **'Category Products'**
  String get public_category_products_title;

  /// No description provided for @error_public_products_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load products. Please try again'**
  String get error_public_products_load_failed;

  /// No description provided for @error_public_product_not_found.
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get error_public_product_not_found;

  /// No description provided for @error_public_categories_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load categories. Please try again'**
  String get error_public_categories_load_failed;

  /// No description provided for @settings_page_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_page_title;

  /// No description provided for @settings_app_section.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get settings_app_section;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @settings_notifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications Automatically'**
  String get settings_notifications;

  /// No description provided for @settings_data_section.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get settings_data_section;

  /// No description provided for @settings_delete_account.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settings_delete_account;

  /// No description provided for @settings_delete_account_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete account'**
  String get settings_delete_account_subtitle;

  /// No description provided for @settings_storage_section.
  ///
  /// In en, this message translates to:
  /// **'Storage Management'**
  String get settings_storage_section;

  /// No description provided for @settings_clear_cache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get settings_clear_cache;

  /// No description provided for @settings_cache_size.
  ///
  /// In en, this message translates to:
  /// **'Cache Size'**
  String get settings_cache_size;

  /// No description provided for @clear_cache_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clear_cache_dialog_title;

  /// No description provided for @clear_cache_dialog_message.
  ///
  /// In en, this message translates to:
  /// **'This will clear temporarily stored coupons, stores, and products. Your personal data and settings will not be deleted.'**
  String get clear_cache_dialog_message;

  /// No description provided for @clear_cache_confirm_button.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clear_cache_confirm_button;

  /// No description provided for @clear_cache_success.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared successfully'**
  String get clear_cache_success;

  /// No description provided for @clear_cache_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while clearing cache'**
  String get clear_cache_error;

  /// No description provided for @cache_files_size.
  ///
  /// In en, this message translates to:
  /// **'Files Size:'**
  String get cache_files_size;

  /// No description provided for @cache_files_count.
  ///
  /// In en, this message translates to:
  /// **'Files Count:'**
  String get cache_files_count;

  /// No description provided for @cache_calculating.
  ///
  /// In en, this message translates to:
  /// **'Calculating...'**
  String get cache_calculating;

  /// No description provided for @settings_security_section.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get settings_security_section;

  /// No description provided for @settings_change_password.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get settings_change_password;

  /// No description provided for @settings_change_password_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Last updated 2 months ago'**
  String get settings_change_password_subtitle;

  /// No description provided for @settings_legal_section.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get settings_legal_section;

  /// No description provided for @settings_terms_of_use.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get settings_terms_of_use;

  /// No description provided for @settings_privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settings_privacy_policy;

  /// No description provided for @settings_about_app.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get settings_about_app;

  /// No description provided for @settings_app_version.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get settings_app_version;

  /// No description provided for @settings_copyright.
  ///
  /// In en, this message translates to:
  /// **'@2025 All rights reserved'**
  String get settings_copyright;

  /// No description provided for @offer_success_message.
  ///
  /// In en, this message translates to:
  /// **'Offer saved successfully'**
  String get offer_success_message;

  /// No description provided for @offer_edit_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Offer'**
  String get offer_edit_title;

  /// No description provided for @offer_create_title.
  ///
  /// In en, this message translates to:
  /// **'Create New Offer'**
  String get offer_create_title;

  /// No description provided for @offer_save_action.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get offer_save_action;

  /// No description provided for @offer_title_label.
  ///
  /// In en, this message translates to:
  /// **'Offer Title'**
  String get offer_title_label;

  /// No description provided for @offer_description_label.
  ///
  /// In en, this message translates to:
  /// **'Offer Description'**
  String get offer_description_label;

  /// No description provided for @offer_discount_type_label.
  ///
  /// In en, this message translates to:
  /// **'Discount Type'**
  String get offer_discount_type_label;

  /// No description provided for @offer_discount_type_percentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get offer_discount_type_percentage;

  /// No description provided for @offer_discount_type_buy_get.
  ///
  /// In en, this message translates to:
  /// **'Buy & Get'**
  String get offer_discount_type_buy_get;

  /// No description provided for @offer_discount_type_fixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed Amount'**
  String get offer_discount_type_fixed;

  /// No description provided for @offer_category_label.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get offer_category_label;

  /// No description provided for @offer_sub_category_label.
  ///
  /// In en, this message translates to:
  /// **'Sub-Category'**
  String get offer_sub_category_label;

  /// No description provided for @offer_select_hint.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get offer_select_hint;

  /// No description provided for @offer_sizes_label.
  ///
  /// In en, this message translates to:
  /// **'Sizes'**
  String get offer_sizes_label;

  /// No description provided for @offer_colors_label.
  ///
  /// In en, this message translates to:
  /// **'Colors'**
  String get offer_colors_label;

  /// No description provided for @offer_original_price_label.
  ///
  /// In en, this message translates to:
  /// **'Original Price'**
  String get offer_original_price_label;

  /// No description provided for @offer_discounted_price_label.
  ///
  /// In en, this message translates to:
  /// **'Discounted Price'**
  String get offer_discounted_price_label;

  /// No description provided for @offer_discount_value_label.
  ///
  /// In en, this message translates to:
  /// **'Discount Value'**
  String get offer_discount_value_label;

  /// No description provided for @offer_publish_settings_label.
  ///
  /// In en, this message translates to:
  /// **'Publish Settings'**
  String get offer_publish_settings_label;

  /// No description provided for @offer_publish_now.
  ///
  /// In en, this message translates to:
  /// **'Publish Now'**
  String get offer_publish_now;

  /// No description provided for @offer_schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get offer_schedule;

  /// No description provided for @offer_start_date_label.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get offer_start_date_label;

  /// No description provided for @offer_end_date_label.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get offer_end_date_label;

  /// No description provided for @offer_image_picker_hint.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload offer image'**
  String get offer_image_picker_hint;

  /// No description provided for @offer_image_picker_sub.
  ///
  /// In en, this message translates to:
  /// **'PNG or JPG, max size 5MB'**
  String get offer_image_picker_sub;

  /// No description provided for @offer_update.
  ///
  /// In en, this message translates to:
  /// **'Update Offer'**
  String get offer_update;

  /// No description provided for @offer_save_publish.
  ///
  /// In en, this message translates to:
  /// **'Save & Publish'**
  String get offer_save_publish;

  /// No description provided for @offer_delete_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Delete Offer'**
  String get offer_delete_confirm_title;

  /// No description provided for @offer_delete_confirm_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this offer? This action cannot be undone.'**
  String get offer_delete_confirm_message;

  /// No description provided for @offer_delete_confirm_button.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get offer_delete_confirm_button;

  /// No description provided for @offer_delete_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get offer_delete_cancel;

  /// No description provided for @offer_empty.
  ///
  /// In en, this message translates to:
  /// **'No offers yet'**
  String get offer_empty;

  /// No description provided for @delete_account_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Confirm Account Deletion'**
  String get delete_account_dialog_title;

  /// No description provided for @delete_account_dialog_message.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone'**
  String get delete_account_dialog_message;

  /// No description provided for @delete_account_confirm_button.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get delete_account_confirm_button;

  /// No description provided for @language_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get language_dialog_title;

  /// No description provided for @language_dialog_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the appropriate language for you'**
  String get language_dialog_subtitle;

  /// No description provided for @language_arabic_full.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get language_arabic_full;

  /// No description provided for @language_english_full.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language_english_full;

  /// No description provided for @language_english_subtitle.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language_english_subtitle;

  /// No description provided for @change_password_current_label.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get change_password_current_label;

  /// No description provided for @change_password_new_label.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get change_password_new_label;

  /// No description provided for @change_password_confirm_label.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get change_password_confirm_label;

  /// No description provided for @change_password_current_error.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect, please try again'**
  String get change_password_current_error;

  /// No description provided for @change_password_forgot_link.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get change_password_forgot_link;

  /// No description provided for @change_password_submit.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get change_password_submit;

  /// No description provided for @change_password_success.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get change_password_success;

  /// No description provided for @privacy_policy_title.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_policy_title;

  /// No description provided for @privacy_policy_last_updated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: April 2026'**
  String get privacy_policy_last_updated;

  /// No description provided for @privacy_policy_section1_title.
  ///
  /// In en, this message translates to:
  /// **'1. Data Collection'**
  String get privacy_policy_section1_title;

  /// No description provided for @privacy_policy_section1_content.
  ///
  /// In en, this message translates to:
  /// **'We collect information you provide to us and data about how you use our services to improve your experience and show you the most relevant offers.'**
  String get privacy_policy_section1_content;

  /// No description provided for @privacy_policy_section2_title.
  ///
  /// In en, this message translates to:
  /// **'2. Data Usage'**
  String get privacy_policy_section2_title;

  /// No description provided for @privacy_policy_section2_content.
  ///
  /// In en, this message translates to:
  /// **'Your data is used to personalize your experience, process transactions, send notifications about offers, and improve our services continuously.'**
  String get privacy_policy_section2_content;

  /// No description provided for @privacy_policy_section3_title.
  ///
  /// In en, this message translates to:
  /// **'3. Data Protection'**
  String get privacy_policy_section3_title;

  /// No description provided for @privacy_policy_section3_content.
  ///
  /// In en, this message translates to:
  /// **'We implement industry-standard security measures to protect your personal information from unauthorized access, alteration, disclosure, or destruction.'**
  String get privacy_policy_section3_content;

  /// No description provided for @privacy_policy_section4_title.
  ///
  /// In en, this message translates to:
  /// **'4. Third Parties'**
  String get privacy_policy_section4_title;

  /// No description provided for @privacy_policy_section4_content.
  ///
  /// In en, this message translates to:
  /// **'We do not sell, trade, or transfer your personal information to outside parties without your consent, except as required by law or to provide our services.'**
  String get privacy_policy_section4_content;

  /// No description provided for @privacy_policy_section5_title.
  ///
  /// In en, this message translates to:
  /// **'5. Your Rights'**
  String get privacy_policy_section5_title;

  /// No description provided for @privacy_policy_section5_content.
  ///
  /// In en, this message translates to:
  /// **'You have the right to access, correct, or delete your personal data at any time by contacting our support team through the app.'**
  String get privacy_policy_section5_content;

  /// No description provided for @terms_section6_title.
  ///
  /// In en, this message translates to:
  /// **'6. Amendments'**
  String get terms_section6_title;

  /// No description provided for @terms_section6_content.
  ///
  /// In en, this message translates to:
  /// **'We reserve the right to modify these terms and conditions at any time. Continued use of the app after changes constitutes your acceptance.'**
  String get terms_section6_content;

  /// No description provided for @terms_agree_button.
  ///
  /// In en, this message translates to:
  /// **'Agree'**
  String get terms_agree_button;

  /// No description provided for @privacy_agree_button.
  ///
  /// In en, this message translates to:
  /// **'Agree'**
  String get privacy_agree_button;

  /// No description provided for @become_merchant_title.
  ///
  /// In en, this message translates to:
  /// **'Become a Merchant'**
  String get become_merchant_title;

  /// No description provided for @become_merchant_headline.
  ///
  /// In en, this message translates to:
  /// **'Start Your Business on Coupony'**
  String get become_merchant_headline;

  /// No description provided for @become_merchant_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Turn your store into a new growth opportunity,\nand reach more customers in your area with ease.'**
  String get become_merchant_subtitle;

  /// No description provided for @become_merchant_button.
  ///
  /// In en, this message translates to:
  /// **'Create Store'**
  String get become_merchant_button;

  /// No description provided for @seller_store_title.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get seller_store_title;

  /// No description provided for @seller_store_content_title.
  ///
  /// In en, this message translates to:
  /// **'Manage Your Store'**
  String get seller_store_content_title;

  /// No description provided for @seller_store_content_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Here you can manage your store information, update details, and add new branches.'**
  String get seller_store_content_subtitle;

  /// No description provided for @seller_home_title.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get seller_home_title;

  /// No description provided for @seller_home_content_title.
  ///
  /// In en, this message translates to:
  /// **'Seller Home Page'**
  String get seller_home_content_title;

  /// No description provided for @seller_home_content_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to your seller dashboard'**
  String get seller_home_content_subtitle;

  /// No description provided for @seller_analytics_title.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get seller_analytics_title;

  /// No description provided for @seller_analytics_content_title.
  ///
  /// In en, this message translates to:
  /// **'Sales Analytics'**
  String get seller_analytics_content_title;

  /// No description provided for @seller_analytics_content_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your store performance and sales in detail'**
  String get seller_analytics_content_subtitle;

  /// No description provided for @seller_offers_title.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get seller_offers_title;

  /// No description provided for @seller_offers_content_title.
  ///
  /// In en, this message translates to:
  /// **'Manage Offers'**
  String get seller_offers_content_title;

  /// No description provided for @seller_offers_content_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Create and manage your promotional offers and discounts'**
  String get seller_offers_content_subtitle;

  /// No description provided for @merchant_review_pending_title.
  ///
  /// In en, this message translates to:
  /// **'Your Request is Under Review'**
  String get merchant_review_pending_title;

  /// No description provided for @merchant_review_pending_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Your request is currently under review.\nYou will be notified once it\'s done.'**
  String get merchant_review_pending_subtitle;

  /// No description provided for @merchant_review_pending_button.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get merchant_review_pending_button;

  /// No description provided for @merchant_review_contact_prompt.
  ///
  /// In en, this message translates to:
  /// **'If you experience any issue'**
  String get merchant_review_contact_prompt;

  /// No description provided for @merchant_review_contact_link.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get merchant_review_contact_link;

  /// No description provided for @merchant_incomplete_title.
  ///
  /// In en, this message translates to:
  /// **'Please Complete Your Store Data'**
  String get merchant_incomplete_title;

  /// No description provided for @merchant_incomplete_subtitle.
  ///
  /// In en, this message translates to:
  /// **'The store cannot be activated due to missing data.\nPlease complete it to continue.'**
  String get merchant_incomplete_subtitle;

  /// No description provided for @merchant_incomplete_button.
  ///
  /// In en, this message translates to:
  /// **'Complete Data'**
  String get merchant_incomplete_button;

  /// No description provided for @merchant_rejected_title.
  ///
  /// In en, this message translates to:
  /// **'Store Activation Could Not Be Completed'**
  String get merchant_rejected_title;

  /// No description provided for @merchant_rejected_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Please review the rejection reasons\nand make the necessary edits to resubmit.'**
  String get merchant_rejected_subtitle;

  /// No description provided for @guest_seller_mode_title.
  ///
  /// In en, this message translates to:
  /// **'Guest Mode'**
  String get guest_seller_mode_title;

  /// No description provided for @guest_seller_welcome_title.
  ///
  /// In en, this message translates to:
  /// **'Start Your Selling Journey on Coupony'**
  String get guest_seller_welcome_title;

  /// No description provided for @guest_seller_welcome_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your store, showcase your discounts, and reach new customers.'**
  String get guest_seller_welcome_subtitle;

  /// No description provided for @guest_seller_login_button.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get guest_seller_login_button;

  /// No description provided for @seller_pending_approval_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get seller_pending_approval_title;

  /// No description provided for @seller_pending_approval_message.
  ///
  /// In en, this message translates to:
  /// **'This page will be activated after your store is approved.'**
  String get seller_pending_approval_message;

  /// No description provided for @seller_pending_approval_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Quick overview of your store performance, latest sales, and suggestions to improve offers and increase engagement.'**
  String get seller_pending_approval_subtitle;

  /// No description provided for @seller_pending_contact_prefix.
  ///
  /// In en, this message translates to:
  /// **'If you experience any issue'**
  String get seller_pending_contact_prefix;

  /// No description provided for @seller_pending_contact_link.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get seller_pending_contact_link;

  /// No description provided for @merchant_rejected_view_status_button.
  ///
  /// In en, this message translates to:
  /// **'View Request Status'**
  String get merchant_rejected_view_status_button;

  /// No description provided for @merchant_status_title.
  ///
  /// In en, this message translates to:
  /// **'Request Status'**
  String get merchant_status_title;

  /// No description provided for @merchant_status_headline.
  ///
  /// In en, this message translates to:
  /// **'Some Edits Needed'**
  String get merchant_status_headline;

  /// No description provided for @merchant_status_subtitle.
  ///
  /// In en, this message translates to:
  /// **'There is data that needs correction to complete activation'**
  String get merchant_status_subtitle;

  /// No description provided for @merchant_status_edit_button.
  ///
  /// In en, this message translates to:
  /// **'Edit Data'**
  String get merchant_status_edit_button;

  /// No description provided for @merchant_status_support_button.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get merchant_status_support_button;

  /// No description provided for @merchant_approved_headline.
  ///
  /// In en, this message translates to:
  /// **'Your Store is Now Live!'**
  String get merchant_approved_headline;

  /// No description provided for @merchant_approved_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! Your store has been reviewed and activated. You can now start publishing your offers.'**
  String get merchant_approved_subtitle;

  /// No description provided for @merchant_approved_button.
  ///
  /// In en, this message translates to:
  /// **'Go to Store'**
  String get merchant_approved_button;

  /// No description provided for @update_store_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Store Data'**
  String get update_store_title;

  /// No description provided for @update_store_button.
  ///
  /// In en, this message translates to:
  /// **'Update Data'**
  String get update_store_button;

  /// No description provided for @success_update_store.
  ///
  /// In en, this message translates to:
  /// **'Store data updated successfully!'**
  String get success_update_store;

  /// No description provided for @error_update_store_server.
  ///
  /// In en, this message translates to:
  /// **'Could not update store. Please try again'**
  String get error_update_store_server;

  /// No description provided for @merchant_approved_switch_button.
  ///
  /// In en, this message translates to:
  /// **'Switch to Merchant'**
  String get merchant_approved_switch_button;

  /// No description provided for @merchant_approved_continue_button.
  ///
  /// In en, this message translates to:
  /// **'Continue as Customer'**
  String get merchant_approved_continue_button;

  /// No description provided for @profile_switch_to_merchant.
  ///
  /// In en, this message translates to:
  /// **'Switch to Merchant'**
  String get profile_switch_to_merchant;

  /// No description provided for @profile_track_request.
  ///
  /// In en, this message translates to:
  /// **'Track Your Request'**
  String get profile_track_request;

  /// No description provided for @profile_switch_to_customer.
  ///
  /// In en, this message translates to:
  /// **'Switch to Customer'**
  String get profile_switch_to_customer;

  /// No description provided for @profile_my_stores.
  ///
  /// In en, this message translates to:
  /// **'My Stores'**
  String get profile_my_stores;

  /// No description provided for @profile_add_store.
  ///
  /// In en, this message translates to:
  /// **'Add Store'**
  String get profile_add_store;

  /// No description provided for @profile_stores_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load stores'**
  String get profile_stores_load_failed;

  /// No description provided for @profile_store_fetch_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch store details'**
  String get profile_store_fetch_failed;

  /// No description provided for @profile_switched_to_customer.
  ///
  /// In en, this message translates to:
  /// **'Switched to customer mode'**
  String get profile_switched_to_customer;

  /// No description provided for @profile_store_added_success.
  ///
  /// In en, this message translates to:
  /// **'Store added successfully'**
  String get profile_store_added_success;

  /// No description provided for @store_selection_sheet_title.
  ///
  /// In en, this message translates to:
  /// **'Select Your Store'**
  String get store_selection_sheet_title;

  /// No description provided for @store_selection_sheet_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the store you want to manage'**
  String get store_selection_sheet_subtitle;

  /// No description provided for @store_status_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get store_status_active;

  /// No description provided for @store_status_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending Review'**
  String get store_status_pending;

  /// No description provided for @store_status_rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get store_status_rejected;

  /// No description provided for @store_not_active_pending_message.
  ///
  /// In en, this message translates to:
  /// **'This store cannot be selected because it is pending approval'**
  String get store_not_active_pending_message;

  /// No description provided for @store_not_active_rejected_message.
  ///
  /// In en, this message translates to:
  /// **'This store cannot be selected because it was rejected'**
  String get store_not_active_rejected_message;

  /// No description provided for @store_already_active.
  ///
  /// In en, this message translates to:
  /// **'This is already your active store'**
  String get store_already_active;

  /// No description provided for @store_switched_to.
  ///
  /// In en, this message translates to:
  /// **'Switched to {name}'**
  String store_switched_to(String name);

  /// No description provided for @store_delete_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Delete Store'**
  String get store_delete_dialog_title;

  /// No description provided for @store_delete_dialog_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String store_delete_dialog_message(String name);

  /// No description provided for @store_delete_dialog_confirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get store_delete_dialog_confirm;

  /// No description provided for @store_delete_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Store deletion will be available in a future update'**
  String get store_delete_coming_soon;

  /// No description provided for @merchant_no_changes_snackbar.
  ///
  /// In en, this message translates to:
  /// **'No changes detected. Please fix the listed issues before resubmitting.'**
  String get merchant_no_changes_snackbar;

  /// No description provided for @seller_welcome_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome, Merchant!'**
  String get seller_welcome_title;

  /// No description provided for @seller_welcome_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Your store has been approved and is ready to start'**
  String get seller_welcome_subtitle;

  /// No description provided for @seller_dashboard_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Dashboard Coming Soon'**
  String get seller_dashboard_coming_soon;

  /// No description provided for @seller_analytics_greeting.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get seller_analytics_greeting;

  /// No description provided for @seller_analytics_filter_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get seller_analytics_filter_all;

  /// No description provided for @seller_analytics_filter_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get seller_analytics_filter_today;

  /// No description provided for @seller_analytics_filter_last_7_days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get seller_analytics_filter_last_7_days;

  /// No description provided for @seller_analytics_filter_last_30_days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get seller_analytics_filter_last_30_days;

  /// No description provided for @seller_analytics_filter_custom.
  ///
  /// In en, this message translates to:
  /// **'Custom Date...'**
  String get seller_analytics_filter_custom;

  /// No description provided for @seller_analytics_filter_this_month.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get seller_analytics_filter_this_month;

  /// No description provided for @seller_analytics_filter_this_year.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get seller_analytics_filter_this_year;

  /// No description provided for @seller_analytics_monthly_goal_title.
  ///
  /// In en, this message translates to:
  /// **'Monthly Coupons Goal'**
  String get seller_analytics_monthly_goal_title;

  /// No description provided for @seller_analytics_goal_label.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get seller_analytics_goal_label;

  /// No description provided for @seller_analytics_achieved_label.
  ///
  /// In en, this message translates to:
  /// **'Achieved'**
  String get seller_analytics_achieved_label;

  /// No description provided for @seller_analytics_goal_completion.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of goal achieved'**
  String seller_analytics_goal_completion(Object percent);

  /// No description provided for @seller_analytics_new_followers_title.
  ///
  /// In en, this message translates to:
  /// **'New Followers'**
  String get seller_analytics_new_followers_title;

  /// No description provided for @seller_analytics_this_month.
  ///
  /// In en, this message translates to:
  /// **'This Month  +{count}'**
  String seller_analytics_this_month(Object count);

  /// No description provided for @seller_analytics_offer_distribution_title.
  ///
  /// In en, this message translates to:
  /// **'Offer Types Distribution'**
  String get seller_analytics_offer_distribution_title;

  /// No description provided for @seller_analytics_top_offers_title.
  ///
  /// In en, this message translates to:
  /// **'Top Performing Offers'**
  String get seller_analytics_top_offers_title;

  /// No description provided for @seller_analytics_usage_count.
  ///
  /// In en, this message translates to:
  /// **'{count} Uses'**
  String seller_analytics_usage_count(Object count);

  /// No description provided for @seller_analytics_retry_button.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get seller_analytics_retry_button;

  /// No description provided for @shop_display_edit_button.
  ///
  /// In en, this message translates to:
  /// **'Edit Store Info'**
  String get shop_display_edit_button;

  /// No description provided for @shop_display_rating_label.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get shop_display_rating_label;

  /// No description provided for @shop_display_followers_label.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get shop_display_followers_label;

  /// No description provided for @shop_display_coupons_label.
  ///
  /// In en, this message translates to:
  /// **'Coupons'**
  String get shop_display_coupons_label;

  /// No description provided for @shop_display_description_title.
  ///
  /// In en, this message translates to:
  /// **'Store Description'**
  String get shop_display_description_title;

  /// No description provided for @shop_display_category_title.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get shop_display_category_title;

  /// No description provided for @shop_display_hours_title.
  ///
  /// In en, this message translates to:
  /// **'Business Hours'**
  String get shop_display_hours_title;

  /// No description provided for @shop_display_reviews_title.
  ///
  /// In en, this message translates to:
  /// **'Ratings'**
  String get shop_display_reviews_title;

  /// No description provided for @shop_display_total_reviews.
  ///
  /// In en, this message translates to:
  /// **'{count} ratings'**
  String shop_display_total_reviews(Object count);

  /// No description provided for @shop_display_open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get shop_display_open;

  /// No description provided for @shop_display_closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get shop_display_closed;

  /// No description provided for @shop_display_no_description.
  ///
  /// In en, this message translates to:
  /// **'No description available'**
  String get shop_display_no_description;

  /// No description provided for @shop_display_no_category.
  ///
  /// In en, this message translates to:
  /// **'No categories added yet'**
  String get shop_display_no_category;

  /// No description provided for @shop_display_day_sun.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get shop_display_day_sun;

  /// No description provided for @shop_display_day_mon.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get shop_display_day_mon;

  /// No description provided for @shop_display_day_tue.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get shop_display_day_tue;

  /// No description provided for @shop_display_day_wed.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get shop_display_day_wed;

  /// No description provided for @shop_display_day_thu.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get shop_display_day_thu;

  /// No description provided for @shop_display_day_fri.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get shop_display_day_fri;

  /// No description provided for @shop_display_day_sat.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get shop_display_day_sat;

  /// No description provided for @shop_display_customer_reviews_title.
  ///
  /// In en, this message translates to:
  /// **'Customer Reviews'**
  String get shop_display_customer_reviews_title;

  /// No description provided for @shop_display_no_reviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get shop_display_no_reviews;

  /// No description provided for @shop_display_verified_badge.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get shop_display_verified_badge;

  /// No description provided for @followers_page_title.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followers_page_title;

  /// No description provided for @followers_page_follow_btn.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get followers_page_follow_btn;

  /// No description provided for @following_page_title.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following_page_title;

  /// No description provided for @following_page_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search stores...'**
  String get following_page_search_hint;

  /// No description provided for @following_page_empty_title.
  ///
  /// In en, this message translates to:
  /// **'Not following anyone yet'**
  String get following_page_empty_title;

  /// No description provided for @following_page_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore stores and follow the ones you love to see their latest offers here.'**
  String get following_page_empty_subtitle;

  /// No description provided for @following_page_unfollow_btn.
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get following_page_unfollow_btn;

  /// No description provided for @following_page_unfollow_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Unfollow store?'**
  String get following_page_unfollow_confirm_title;

  /// No description provided for @following_page_unfollow_confirm_body.
  ///
  /// In en, this message translates to:
  /// **'You will stop receiving updates from this store.'**
  String get following_page_unfollow_confirm_body;

  /// No description provided for @following_page_unfollow_confirm_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get following_page_unfollow_confirm_cancel;

  /// No description provided for @following_page_unfollow_confirm_ok.
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get following_page_unfollow_confirm_ok;

  /// No description provided for @following_page_no_results.
  ///
  /// In en, this message translates to:
  /// **'No stores match your search'**
  String get following_page_no_results;

  /// No description provided for @home_greeting.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get home_greeting;

  /// No description provided for @home_delivery_to.
  ///
  /// In en, this message translates to:
  /// **'Delivery to'**
  String get home_delivery_to;

  /// No description provided for @home_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search for offers and stores...'**
  String get home_search_hint;

  /// No description provided for @home_categories_title.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get home_categories_title;

  /// No description provided for @home_promo_on_going.
  ///
  /// In en, this message translates to:
  /// **'Promo on Going'**
  String get home_promo_on_going;

  /// No description provided for @home_shop_now.
  ///
  /// In en, this message translates to:
  /// **'Shop Now'**
  String get home_shop_now;

  /// No description provided for @home_personalized_title.
  ///
  /// In en, this message translates to:
  /// **'Offers for You'**
  String get home_personalized_title;

  /// No description provided for @home_brands_title.
  ///
  /// In en, this message translates to:
  /// **'Brands'**
  String get home_brands_title;

  /// No description provided for @home_category_offers_title.
  ///
  /// In en, this message translates to:
  /// **'Category Offers'**
  String get home_category_offers_title;

  /// No description provided for @home_favorites_title.
  ///
  /// In en, this message translates to:
  /// **'Recent Favorites'**
  String get home_favorites_title;

  /// No description provided for @home_travel_offers_title.
  ///
  /// In en, this message translates to:
  /// **'Travel Offers'**
  String get home_travel_offers_title;

  /// No description provided for @home_egypt_offers_title.
  ///
  /// In en, this message translates to:
  /// **'Featured Offers in Egypt'**
  String get home_egypt_offers_title;

  /// No description provided for @home_see_all.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get home_see_all;

  /// No description provided for @home_save_badge.
  ///
  /// In en, this message translates to:
  /// **'Save {percent}%'**
  String home_save_badge(Object percent);

  /// No description provided for @home_discount_up_to.
  ///
  /// In en, this message translates to:
  /// **'Discount up to'**
  String get home_discount_up_to;

  /// No description provided for @home_min_transaction.
  ///
  /// In en, this message translates to:
  /// **'Min. transaction'**
  String get home_min_transaction;

  /// No description provided for @nav_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get nav_home;

  /// No description provided for @nav_categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get nav_categories;

  /// No description provided for @nav_explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get nav_explore;

  /// No description provided for @nav_coupons.
  ///
  /// In en, this message translates to:
  /// **'My Coupons'**
  String get nav_coupons;

  /// No description provided for @nav_account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get nav_account;

  /// No description provided for @home_stores_title.
  ///
  /// In en, this message translates to:
  /// **'Stores'**
  String get home_stores_title;

  /// No description provided for @home_featured_offers_title.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get home_featured_offers_title;

  /// No description provided for @seller_home_subscription_renew_title.
  ///
  /// In en, this message translates to:
  /// **'Subscription Renewal'**
  String get seller_home_subscription_renew_title;

  /// No description provided for @seller_home_subscription_renew_body.
  ///
  /// In en, this message translates to:
  /// **'Your subscription expires in 2 days. Renew to keep your benefits.'**
  String get seller_home_subscription_renew_body;

  /// No description provided for @seller_home_stat_active_offers.
  ///
  /// In en, this message translates to:
  /// **'Active Offers'**
  String get seller_home_stat_active_offers;

  /// No description provided for @seller_home_stat_used_coupons.
  ///
  /// In en, this message translates to:
  /// **'Used Coupons'**
  String get seller_home_stat_used_coupons;

  /// No description provided for @seller_home_stat_views.
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get seller_home_stat_views;

  /// No description provided for @seller_home_stat_shares.
  ///
  /// In en, this message translates to:
  /// **'Shares'**
  String get seller_home_stat_shares;

  /// No description provided for @seller_home_quick_actions_title.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get seller_home_quick_actions_title;

  /// No description provided for @seller_home_add_offer_label.
  ///
  /// In en, this message translates to:
  /// **'Add New Offer'**
  String get seller_home_add_offer_label;

  /// No description provided for @seller_home_add_offer_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Publish a new offer now'**
  String get seller_home_add_offer_subtitle;

  /// No description provided for @seller_home_add_product_label.
  ///
  /// In en, this message translates to:
  /// **'Add New Product'**
  String get seller_home_add_product_label;

  /// No description provided for @seller_home_add_product_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Publish a new product now'**
  String get seller_home_add_product_subtitle;

  /// No description provided for @seller_home_scan_qr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get seller_home_scan_qr;

  /// No description provided for @seller_home_add_employee.
  ///
  /// In en, this message translates to:
  /// **'Add Employee'**
  String get seller_home_add_employee;

  /// No description provided for @seller_home_manage_employees_title.
  ///
  /// In en, this message translates to:
  /// **'Manage Employees'**
  String get seller_home_manage_employees_title;

  /// No description provided for @seller_home_manage_employees_subtitle.
  ///
  /// In en, this message translates to:
  /// **'View and manage employees'**
  String get seller_home_manage_employees_subtitle;

  /// No description provided for @staff_delete_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Confirm Staff Deletion'**
  String get staff_delete_dialog_title;

  /// No description provided for @staff_delete_dialog_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get staff_delete_dialog_confirm;

  /// No description provided for @staff_delete_dialog_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get staff_delete_dialog_cancel;

  /// No description provided for @seller_home_active_offers_section.
  ///
  /// In en, this message translates to:
  /// **'Active Offers'**
  String get seller_home_active_offers_section;

  /// No description provided for @seller_home_no_active_offers.
  ///
  /// In en, this message translates to:
  /// **'No active offers currently'**
  String get seller_home_no_active_offers;

  /// No description provided for @seller_home_sidebar_active_seller.
  ///
  /// In en, this message translates to:
  /// **'Active Seller'**
  String get seller_home_sidebar_active_seller;

  /// No description provided for @seller_home_sidebar_notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get seller_home_sidebar_notifications;

  /// No description provided for @seller_home_offer_usage_count.
  ///
  /// In en, this message translates to:
  /// **'{count} Uses'**
  String seller_home_offer_usage_count(Object count);

  /// No description provided for @seller_offers_tab_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get seller_offers_tab_all;

  /// No description provided for @seller_offers_tab_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get seller_offers_tab_active;

  /// No description provided for @seller_offers_tab_expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get seller_offers_tab_expired;

  /// No description provided for @seller_offers_tab_scheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get seller_offers_tab_scheduled;

  /// No description provided for @seller_offers_page_title.
  ///
  /// In en, this message translates to:
  /// **'My Offers'**
  String get seller_offers_page_title;

  /// No description provided for @seller_offers_empty_all.
  ///
  /// In en, this message translates to:
  /// **'No offers'**
  String get seller_offers_empty_all;

  /// No description provided for @seller_offers_empty_active.
  ///
  /// In en, this message translates to:
  /// **'No active offers'**
  String get seller_offers_empty_active;

  /// No description provided for @seller_offers_empty_expired.
  ///
  /// In en, this message translates to:
  /// **'No expired offers'**
  String get seller_offers_empty_expired;

  /// No description provided for @seller_offers_empty_scheduled.
  ///
  /// In en, this message translates to:
  /// **'No scheduled offers'**
  String get seller_offers_empty_scheduled;

  /// No description provided for @seller_offers_add_new.
  ///
  /// In en, this message translates to:
  /// **'Add New Offer +'**
  String get seller_offers_add_new;

  /// No description provided for @seller_offer_status_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get seller_offer_status_active;

  /// No description provided for @seller_offer_status_expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get seller_offer_status_expired;

  /// No description provided for @seller_offer_status_scheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get seller_offer_status_scheduled;

  /// No description provided for @seller_offer_chip_percentage.
  ///
  /// In en, this message translates to:
  /// **'% Discount'**
  String get seller_offer_chip_percentage;

  /// No description provided for @seller_offer_action_details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get seller_offer_action_details;

  /// No description provided for @seller_offer_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get seller_offer_delete_title;

  /// No description provided for @seller_offer_delete_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this offer?\nThis action cannot be undone.'**
  String get seller_offer_delete_message;

  /// No description provided for @edit_store_field_name.
  ///
  /// In en, this message translates to:
  /// **'Store Name'**
  String get edit_store_field_name;

  /// No description provided for @edit_store_field_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter store name'**
  String get edit_store_field_name_hint;

  /// No description provided for @edit_store_field_name_required.
  ///
  /// In en, this message translates to:
  /// **'Store name is required'**
  String get edit_store_field_name_required;

  /// No description provided for @edit_store_field_description_label.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get edit_store_field_description_label;

  /// No description provided for @edit_store_field_description_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter store description'**
  String get edit_store_field_description_hint;

  /// No description provided for @edit_store_field_email_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter email address'**
  String get edit_store_field_email_hint;

  /// No description provided for @edit_store_field_phone_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get edit_store_field_phone_hint;

  /// No description provided for @edit_store_working_hours_title.
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get edit_store_working_hours_title;

  /// No description provided for @edit_store_category_label.
  ///
  /// In en, this message translates to:
  /// **'Offer Category'**
  String get edit_store_category_label;

  /// No description provided for @edit_store_select_category.
  ///
  /// In en, this message translates to:
  /// **'Choose Category'**
  String get edit_store_select_category;

  /// No description provided for @edit_store_loading_categories.
  ///
  /// In en, this message translates to:
  /// **'Loading categories...'**
  String get edit_store_loading_categories;

  /// No description provided for @edit_store_categories_error.
  ///
  /// In en, this message translates to:
  /// **'Error loading categories'**
  String get edit_store_categories_error;

  /// No description provided for @edit_store_save_loading.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get edit_store_save_loading;

  /// No description provided for @edit_store_save_changes.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get edit_store_save_changes;

  /// No description provided for @edit_store_time_from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get edit_store_time_from;

  /// No description provided for @edit_store_time_to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get edit_store_time_to;

  /// No description provided for @offer_details_status_active_now.
  ///
  /// In en, this message translates to:
  /// **'Active Now'**
  String get offer_details_status_active_now;

  /// No description provided for @offer_details_category_label.
  ///
  /// In en, this message translates to:
  /// **'Category:'**
  String get offer_details_category_label;

  /// No description provided for @offer_details_sizes_title.
  ///
  /// In en, this message translates to:
  /// **'Available Sizes'**
  String get offer_details_sizes_title;

  /// No description provided for @offer_details_colors_title.
  ///
  /// In en, this message translates to:
  /// **'Available Colors'**
  String get offer_details_colors_title;

  /// No description provided for @offer_details_valid_until.
  ///
  /// In en, this message translates to:
  /// **'Valid Until'**
  String get offer_details_valid_until;

  /// No description provided for @offer_details_terms_title.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get offer_details_terms_title;

  /// No description provided for @offer_details_edit_button.
  ///
  /// In en, this message translates to:
  /// **'Edit Offer Details'**
  String get offer_details_edit_button;

  /// No description provided for @offer_details_date_placeholder.
  ///
  /// In en, this message translates to:
  /// **'DD/MM/YYYY'**
  String get offer_details_date_placeholder;

  /// No description provided for @offer_terms_validity_date.
  ///
  /// In en, this message translates to:
  /// **'This offer is valid until {date} only, and will not be accepted after this date under any circumstances.'**
  String offer_terms_validity_date(String date);

  /// No description provided for @offer_terms_validity_open.
  ///
  /// In en, this message translates to:
  /// **'The offer is valid until further notice, and the store reserves the right to stop it at any time.'**
  String get offer_terms_validity_open;

  /// No description provided for @offer_terms_discount_percentage.
  ///
  /// In en, this message translates to:
  /// **'This offer grants a {pct}% discount on the original price ({original}), making the final price {discounted}.'**
  String offer_terms_discount_percentage(
    String pct,
    String original,
    String discounted,
  );

  /// No description provided for @offer_terms_discount_fixed.
  ///
  /// In en, this message translates to:
  /// **'A fixed discount of {saved} is applied to the original price.'**
  String offer_terms_discount_fixed(String saved);

  /// No description provided for @offer_terms_discount_buy_get.
  ///
  /// In en, this message translates to:
  /// **'Buy & Get offer; automatically applied when the purchase condition is met.'**
  String get offer_terms_discount_buy_get;

  /// No description provided for @offer_terms_category_scope.
  ///
  /// In en, this message translates to:
  /// **'This offer is exclusive to the \"{scope}\" category and does not include other products.'**
  String offer_terms_category_scope(String scope);

  /// No description provided for @offer_terms_sizes.
  ///
  /// In en, this message translates to:
  /// **'The discount applies to available sizes ({sizes}) only, and prices may differ for other sizes.'**
  String offer_terms_sizes(String sizes);

  /// No description provided for @offer_terms_start_date.
  ///
  /// In en, this message translates to:
  /// **'The offer officially activates on {date}, and will not be accepted before this date.'**
  String offer_terms_start_date(String date);

  /// No description provided for @offer_terms_no_combine.
  ///
  /// In en, this message translates to:
  /// **'This offer cannot be combined with any other discounts or offers at the same time.'**
  String get offer_terms_no_combine;

  /// No description provided for @offer_terms_store_rights.
  ///
  /// In en, this message translates to:
  /// **'{storeName} reserves the right to modify the offer terms or cancel it without prior notice.'**
  String offer_terms_store_rights(String storeName);

  /// No description provided for @offer_terms_return_policy.
  ///
  /// In en, this message translates to:
  /// **'In case of return or exchange, the amount will be recalculated according to the store\'s approved policy without being bound by the offer price.'**
  String get offer_terms_return_policy;

  /// No description provided for @guest_profile_title.
  ///
  /// In en, this message translates to:
  /// **'Start Your Journey on Coupony'**
  String get guest_profile_title;

  /// No description provided for @guest_profile_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your store, showcase your offers, and reach new customers.'**
  String get guest_profile_subtitle;

  /// No description provided for @guest_login_button.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get guest_login_button;
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
