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
