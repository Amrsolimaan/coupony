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
