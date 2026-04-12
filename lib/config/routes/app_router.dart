import 'package:coupony/core/widgets/Shared_Onboarding/onboarding_completion_loading_page.dart';
import 'package:coupony/features/auth/presentation/pages/forgot_password_screen.dart';
import 'package:coupony/features/Profile/presentation/pages/customer/become_merchant_page.dart';
import 'package:coupony/features/Profile/presentation/pages/customer/merchant_pending_page.dart';
import 'package:coupony/features/Profile/presentation/pages/customer/merchant_incomplete_page.dart';
import 'package:coupony/features/Profile/presentation/pages/customer/merchant_rejected_page.dart';
import 'package:coupony/features/Profile/presentation/pages/customer/merchant_status_page.dart';
import 'package:coupony/features/Profile/presentation/pages/customer/merchant_approved_page.dart';
import 'package:coupony/features/auth/presentation/pages/language_selection_page.dart';
import 'package:coupony/features/auth/presentation/pages/register_screen.dart';
import 'package:coupony/features/permissions/presentation/pages/permission_flow_wrapper.dart';
import 'package:coupony/features/permissions/presentation/pages/pages/location_error_page.dart';
import 'package:coupony/features/permissions/presentation/pages/pages/location_intro_page.dart';
import 'package:coupony/features/permissions/presentation/pages/pages/location_map_page.dart';
import 'package:coupony/features/permissions/presentation/pages/pages/notification_error_page.dart';
import 'package:coupony/features/permissions/presentation/pages/pages/notification_intro_page.dart';
import 'package:coupony/features/permissions/presentation/pages/pages/permission_loading_page.dart';
import 'package:coupony/features/permissions/presentation/pages/pages/permission_splash_page.dart';
import 'package:coupony/features/seller_flow/CreateStore/presentation/cubit/create_store_cubit.dart';
import 'package:coupony/features/seller_flow/CreateStore/presentation/pages/create_store_screen.dart'
    show CreateStoreScreen, CreateStoreMode, CreateStoreArgs;
import 'package:coupony/features/seller_flow/CreateStore/presentation/pages/store_under_review_page.dart';
import 'package:coupony/features/seller_flow/StoreSelection/presentation/pages/store_selection_page.dart';
import 'package:coupony/features/auth/data/models/user_store_model.dart';
import 'package:coupony/features/seller_flow/SellerOnboarding/presentation/pages/onboarding_seller_screen.dart';
import 'package:coupony/features/seller_flow/SellerOnboarding/presentation/pages/seller_onboarding_start_screen.dart';
import 'package:coupony/features/seller_flow/dashboard_seller/presentation/pages/SellerHome.dart';
import 'package:coupony/features/seller_flow/dashboard_seller/presentation/pages/seller_store_page.dart';
import 'package:coupony/features/seller_flow/dashboard_seller/presentation/pages/seller_analytics_page.dart';
import 'package:coupony/features/seller_flow/dashboard_seller/presentation/pages/seller_offers_page.dart';
import 'package:coupony/features/seller_flow/dashboard_seller/presentation/cubit/seller_home_cubit.dart';
import 'package:coupony/features/seller_flow/dashboard_seller/presentation/cubit/seller_store_cubit.dart';
import 'package:coupony/features/seller_flow/dashboard_seller/presentation/cubit/seller_analytics_cubit.dart';
import 'package:coupony/features/seller_flow/dashboard_seller/presentation/cubit/seller_offers_cubit.dart';
import 'package:coupony/features/user_flow/CustomerOnboarding/presentation/pages/onboarding_budget_screen.dart';
import 'package:coupony/features/user_flow/CustomerOnboarding/presentation/pages/onboarding_customer_screen.dart';
import 'package:coupony/features/user_flow/CustomerOnboarding/presentation/pages/onboarding_preferences_screen.dart';
import 'package:coupony/features/user_flow/CustomerOnboarding/presentation/pages/onboarding_shopping_style_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// Core
import 'package:coupony/config/dependency_injection/injection_container.dart';
import 'package:coupony/core/constants/storage_keys.dart';
import 'package:coupony/core/storage/secure_storage_service.dart';
import 'package:coupony/core/navigation/app_page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Auth screens
import 'package:coupony/features/auth/presentation/pages/splash_screen.dart';
import 'package:coupony/features/auth/presentation/pages/login_screen.dart'
    as auth_login;
import 'package:coupony/features/auth/presentation/pages/otp_screen.dart';
import 'package:coupony/features/auth/presentation/cubit/forgot_password_cubit.dart';
import 'package:coupony/features/auth/presentation/cubit/login_cubit.dart';
import 'package:coupony/features/auth/presentation/cubit/otp_cubit.dart';
import 'package:coupony/features/auth/presentation/cubit/register_cubit.dart';
import 'package:coupony/features/auth/presentation/cubit/reset_password_cubit.dart';
import 'package:coupony/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coupony/features/auth/presentation/pages/reset_password_screen.dart';

import 'package:coupony/features/permissions/presentation/pages/pages/welcome_gateway_page.dart';
import 'package:coupony/features/user_flow/CustomerHome/presentation/pages/CutomerHome.dart';
import 'package:coupony/features/Profile/presentation/pages/customer/EditProfilePage.dart';
import 'package:coupony/features/Profile/presentation/pages/customer/main_profile.dart';
import 'package:coupony/features/Profile/presentation/pages/customer/address_management_page.dart';
import 'package:coupony/features/Profile/presentation/pages/customer/address_map_picker_page.dart';
import 'package:coupony/features/Profile/presentation/pages/customer/help_support_page.dart';
import 'package:coupony/features/Profile/presentation/pages/customer/contact_us_page.dart';
import 'package:coupony/features/Profile/presentation/pages/customer/faq_page.dart';
import 'package:coupony/features/Profile/presentation/pages/customer/usage_guide_page.dart';
import 'package:coupony/features/Profile/presentation/pages/customer/report_problem_page.dart';
import 'package:coupony/features/Profile/presentation/pages/customer/rate_app_page.dart';
import 'package:coupony/features/Profile/presentation/pages/customer/terms_page.dart';
import 'package:coupony/features/Profile/presentation/pages/customer/settings_page.dart';
import 'package:coupony/features/Profile/presentation/pages/customer/change_password_page.dart';
import 'package:coupony/features/Profile/presentation/pages/customer/privacy_policy_page.dart';
import 'package:coupony/features/Profile/presentation/cubit/Customer_Profile_cubit.dart';
import 'package:coupony/features/Profile/presentation/cubit/change_password_cubit.dart';
import 'package:coupony/features/Profile/presentation/cubit/address_cubit.dart';

class MerchantDashboardScreen extends StatelessWidget {
  const MerchantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LoginCubit>(),
      child: BlocListener<LoginCubit, AuthState>(
        listener: (context, state) {
          if (state.navSignal == AuthNavigation.toLogin) {
            context.go(AppRouter.login);
          }
        },
        child: Builder(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Merchant Dashboard'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    tooltip: 'تسجيل الخروج',
                    onPressed: () {
                      // Show confirmation dialog
                      showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('تسجيل الخروج'),
                          content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text('إلغاء'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(dialogContext);
                                // Use the correct context from Builder
                                context.read<LoginCubit>().logout();
                              },
                              child: const Text('تسجيل الخروج'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              body: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Merchant Dashboard',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('مرحباً! لوحة تحكم التاجر'),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Routes accessible WITHOUT an auth token ───────────────────────────────
// Onboarding routes are intentionally excluded — they require a logged-in user.
// The redirect guard will send unauthenticated users to /welcome-gateway.
const _publicRoutes = {
  AppRouter.splash,
  AppRouter.languageSelection,
  AppRouter.permissionFlow,
  AppRouter.permissionSplash,
  AppRouter.permissionLocationIntro,
  AppRouter.permissionLocationMap,
  AppRouter.permissionLocationError,
  AppRouter.permissionNotificationIntro,
  AppRouter.permissionNotificationError,
  AppRouter.permissionLoading,
  AppRouter.welcomeGateway,
  AppRouter.login,
  AppRouter.register,
  AppRouter.otpVerification,
  AppRouter.forgotPassword,
  AppRouter.resetPassword,
  AppRouter.sellerHome, // Allow guest seller access
  AppRouter.sellerStore, // Allow guest seller access
  AppRouter.sellerAnalytics, // Allow guest seller access
};

class AppRouter {
  // ── Route paths ───────────────────────────────────────────────────────────
  static const String splash = '/';
  static const String languageSelection = '/language-selection';
  static const String onboarding = '/onboarding';
  static const String onboardingPreferences = '/onboarding-preferences';
  static const String onboardingBudget = '/onboarding-budget';
  static const String onboardingShoppingStyle = '/onboarding-shopping-style';
  static const String onboardingCompletionLoading =
      '/onboarding-completion-loading';
  static const String sellerOnboarding = '/seller-onboarding';
  static const String sellerOnboardingFlow = '/seller-onboarding-flow';
  static const String createStore = '/create-store';
  static const String storeUnderReview = '/store-under-review';
  static const String sellerWelcome = '/seller-welcome';
  static const String storeSelection   = '/store-selection';
  static const String sellerHome = '/seller-home';
  static const String sellerStore = '/seller-store';
  static const String sellerAnalytics = '/seller-analytics';
  static const String sellerOffers = '/seller-offers';
  static const String login = '/login';
  static const String register = '/register';
  static const String otpVerification = '/otp-verification';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String home = '/home';
  static const String merchantDashboard = '/merchant-dashboard';
  static const String customerProfile = '/customer-profile';
  static const String editCustomerProfile = '/edit-customer-profile';
  static const String addressManagement = '/address-management';
  static const String addressMapPicker = '/address-map-picker';
  static const String helpSupport = '/help-support';
  static const String contactUsPage = '/contact-us';
  static const String faqPage = '/faq';
  static const String usageGuidePage = '/usage-guide';
  static const String reportProblemPage = '/report-problem';
  static const String rateAppPage = '/rate-app';
  static const String termsPage = '/terms';
  static const String settingsPage = '/settings';
  static const String changePassword = '/change-password';
  static const String privacyPolicyPage = '/privacy-policy';

  // Merchant registration flow (customer → seller journey)
  static const String becomeMerchant    = '/become-merchant';
  static const String merchantPending   = '/merchant-pending';
  static const String merchantIncomplete = '/merchant-incomplete';
  static const String merchantRejected  = '/merchant-rejected';
  static const String merchantStatus    = '/merchant-status';
  static const String merchantApproved  = '/merchant-approved';

  // Permission flow
  static const String permissionFlow = '/permission-flow';
  static const String permissionSplash = '/permission-splash';
  static const String permissionLocationIntro = '/permission-location-intro';
  static const String permissionLocationMap = '/permission-location-map';
  static const String permissionLocationError = '/permission-location-error';
  static const String permissionNotificationIntro =
      '/permission-notification-intro';
  static const String permissionNotificationError =
      '/permission-notification-error';
  static const String permissionLoading = '/permission-loading';
  static const String welcomeGateway = '/welcome-gateway';

  // ── Router ────────────────────────────────────────────────────────────────
  static final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: true,

    // ── Auth guard ──────────────────────────────────────────────────────────
    redirect: (context, state) async {
      final location = state.matchedLocation;

      // Public routes (splash, onboarding, permissions, auth screens) are
      // always accessible — skip the session check entirely.
      if (_publicRoutes.contains(location)) return null;

      // 1. Authenticated user — token present and non-empty.
      final token = await sl<SecureStorageService>().read(
        StorageKeys.authToken,
      );
      if (token != null && token.isNotEmpty) return null;

      // 2. Guest user — explicit visitor session persisted in SharedPreferences.
      //    getBool() is synchronous once SharedPreferences is initialised.
      final isGuest =
          sl<SharedPreferences>().getBool(StorageKeys.isGuest) ?? false;
      if (isGuest) return null;

      // 3. No session — redirect to the gateway so the user can sign in or
      //    choose guest mode again.
      return welcomeGateway;
    },

    routes: [
      // 1. Splash (No transition - instant)
      GoRoute(
        path: splash,
        pageBuilder: (context, state) => AppPageTransition.buildNoTransition(
          context: context,
          state: state,
          child: const AnimatedSplashScreen(),
        ),
      ),

      // 2. Language Selection
      GoRoute(
        path: languageSelection,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: const LanguageSelectionPage(),
        ),
      ),

      // 3. Onboarding flow
      GoRoute(
        path: onboarding,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: onboardingPreferences,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: const OnboardingCategorySelectionScreen(),
        ),
      ),
      GoRoute(
        path: onboardingBudget,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: const OnboardingBudgetScreen(),
        ),
      ),
      GoRoute(
        path: onboardingShoppingStyle,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: const OnboardingShoppingStyleScreen(),
        ),
      ),
      GoRoute(
        path: onboardingCompletionLoading,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: const OnboardingCompletionLoadingPage(),
        ),
      ),
      GoRoute(
        path: sellerOnboarding,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: const SellerOnboardingStartScreen(),
        ),
      ),
      GoRoute(
        path: sellerOnboardingFlow,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: const SellerOnboardingPage(),
        ),
      ),
      GoRoute(
        path: createStore,
        pageBuilder: (context, state) {
          final args = state.extra as CreateStoreArgs?;
          return AppPageTransition.build(
            context: context,
            state: state,
            child: MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => sl<CreateStoreCubit>()),
                BlocProvider(create: (_) => sl<LoginCubit>()),
              ],
              child: CreateStoreScreen(
                mode: args?.mode ?? CreateStoreMode.create,
                storeId: args?.storeId,
                initialStore: args?.initialStore,
                onSuccess: args?.onSuccess,
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: storeUnderReview,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: BlocProvider(
            create: (_) => sl<LoginCubit>(),
            child: const StoreUnderReviewPage(),
          ),
        ),
      ),
    
      GoRoute(
        path: storeSelection,
        pageBuilder: (context, state) {
          final stores = state.extra as List<UserStoreModel>? ?? const [];
          return AppPageTransition.build(
            context: context,
            state: state,
            child: StoreSelectionPage(stores: stores),
          );
        },
      ),
      GoRoute(
        path: sellerHome,
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, bool>?;
          final isGuest = args?['isGuest'] ?? false;
          final isPending = args?['isPending'] ?? false;
          return AppPageTransition.build(
            context: context,
            state: state,
            child: MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => SellerHomeCubit(
                    isGuest: isGuest,
                    isPending: isPending,
                  ),
                ),
                BlocProvider(
                  create: (_) => sl<ProfileCubit>(),
                ),
                BlocProvider(
                  create: (_) => sl<LoginCubit>(),
                ),
              ],
              child: SellerHomePage(
                isGuest: isGuest,
                isPending: isPending,
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: sellerStore,
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, bool>?;
          final isGuest = args?['isGuest'] ?? false;
          final isPending = args?['isPending'] ?? false;
          return AppPageTransition.build(
            context: context,
            state: state,
            child: MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => SellerStoreCubit(
                    isGuest: isGuest,
                    isPending: isPending,
                  ),
                ),
                BlocProvider(
                  create: (_) => sl<ProfileCubit>(),
                ),
                BlocProvider(
                  create: (_) => sl<LoginCubit>(),
                ),
              ],
              child: const SellerStorePage(),
            ),
          );
        },
      ),
      GoRoute(
        path: sellerAnalytics,
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, bool>?;
          final isGuest = args?['isGuest'] ?? false;
          final isPending = args?['isPending'] ?? false;
          return AppPageTransition.build(
            context: context,
            state: state,
            child: MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => SellerAnalyticsCubit(
                    isGuest: isGuest,
                    isPending: isPending,
                  ),
                ),
                BlocProvider(
                  create: (_) => sl<ProfileCubit>(),
                ),
                BlocProvider(
                  create: (_) => sl<LoginCubit>(),
                ),
              ],
              child: const SellerAnalyticsPage(),
            ),
          );
        },
      ),
      GoRoute(
        path: sellerOffers,
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, bool>?;
          final isGuest = args?['isGuest'] ?? false;
          final isPending = args?['isPending'] ?? false;
          return AppPageTransition.build(
            context: context,
            state: state,
            child: MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => SellerOffersCubit(
                    isGuest: isGuest,
                    isPending: isPending,
                  ),
                ),
                BlocProvider(
                  create: (_) => sl<ProfileCubit>(),
                ),
                BlocProvider(
                  create: (_) => sl<LoginCubit>(),
                ),
              ],
              child: const SellerOffersPage(),
            ),
          );
        },
      ),

      // 4. Permission flow
      GoRoute(
        path: permissionFlow,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: const PermissionFlowWrapper(),
        ),
      ),
      GoRoute(
        path: permissionSplash,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: const PermissionSplashPage(),
        ),
      ),
      GoRoute(
        path: permissionLocationIntro,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: const LocationIntroPage(),
        ),
      ),
      GoRoute(
        path: permissionLocationMap,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: const LocationMapPage(),
        ),
      ),
      GoRoute(
        path: permissionLocationError,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: const LocationErrorPage(),
        ),
      ),
      GoRoute(
        path: permissionNotificationIntro,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: const NotificationIntroPage(),
        ),
      ),
      GoRoute(
        path: permissionNotificationError,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: const NotificationErrorPage(),
        ),
      ),
      GoRoute(
        path: permissionLoading,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: const PermissionLoadingPage(),
        ),
      ),
      GoRoute(
        path: welcomeGateway,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: const WelcomeGatewayPage(),
        ),
      ),

      // 5. Auth screens
      GoRoute(
        path: login,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: BlocProvider(
            create: (_) => sl<LoginCubit>(),
            child: const auth_login.LoginScreen(),
          ),
        ),
      ),
      GoRoute(
        path: register,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: BlocProvider(
            create: (_) => sl<RegisterCubit>(),
            child: const RegisterScreen(),
          ),
        ),
      ),
      GoRoute(
        path: otpVerification,
        pageBuilder: (context, state) {
          // extra can be:
          //   String  — legacy / register flow (email only, emailVerification mode)
          //   Map<String,String> — new flow: { 'email': ..., 'mode': 'forgotPassword' }
          final extra = state.extra;
          final String email;
          final OtpMode mode;
          if (extra is Map<String, String>) {
            email = extra['email'] ?? '';
            mode = extra['mode'] == 'forgotPassword'
                ? OtpMode.forgotPassword
                : OtpMode.emailVerification;
          } else {
            email = extra as String? ?? '';
            mode = OtpMode.emailVerification;
          }
          return AppPageTransition.build(
            context: context,
            state: state,
            child: BlocProvider(
              create: (_) => sl<OtpCubit>(),
              child: OtpScreen(email: email, mode: mode),
            ),
          );
        },
      ),
      GoRoute(
        path: forgotPassword,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: BlocProvider(
            create: (_) => sl<ForgotPasswordCubit>(),
            child: const ForgotPasswordScreen(),
          ),
        ),
      ),
      GoRoute(
        path: resetPassword,
        pageBuilder: (context, state) {
          final params = state.extra as Map<String, String>?;
          return AppPageTransition.build(
            context: context,
            state: state,
            child: BlocProvider(
              create: (_) => sl<ResetPasswordCubit>(),
              child: ResetPasswordScreen(
                email: params?['email'] ?? '',
                token: params?['token'] ?? '',
              ),
            ),
          );
        },
      ),

      // 6. Protected app screens
      GoRoute(
        path: home,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: BlocProvider(
            create: (_) => sl<LoginCubit>(),
            child: const CustomerHome(),
          ),
        ),
      ),
      GoRoute(
        path: merchantDashboard,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: const MerchantDashboardScreen(),
        ),
      ),
      GoRoute(
        path: customerProfile,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: BlocProvider(
            create: (_) => sl<ProfileCubit>(),
            child: const MainProfile(),
          ),
        ),
      ),
      GoRoute(
        path: editCustomerProfile,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: BlocProvider(
            create: (_) => sl<ProfileCubit>()..loadProfile(),
            child: const EditProfilePage(),
          ),
        ),
      ),
      GoRoute(
        path: addressManagement,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: BlocProvider(
            create: (_) => sl<AddressCubit>()..loadAddresses(),
            child: const AddressManagementPage(),
          ),
        ),
      ),
      GoRoute(
        path: addressMapPicker,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: BlocProvider(
            create: (_) => sl<AddressCubit>(),
            child: const AddressMapPickerPage(),
          ),
        ),
      ),
      GoRoute(
        path: helpSupport,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: const HelpSupportPage(),
        ),
      ),
      GoRoute(
        path: contactUsPage,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: const ContactUsPage(),
        ),
      ),
      GoRoute(
        path: faqPage,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: const FaqPage(),
        ),
      ),
      GoRoute(
        path: usageGuidePage,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: const UsageGuidePage(),
        ),
      ),
      GoRoute(
        path: reportProblemPage,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: const ReportProblemPage(),
        ),
      ),
      GoRoute(
        path: rateAppPage,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: const RateAppPage(),
        ),
      ),
      GoRoute(
        path: termsPage,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: const TermsPage(),
        ),
      ),
      GoRoute(
        path: settingsPage,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: BlocProvider(
            create: (_) => sl<ProfileCubit>()..loadProfile(),
            child: const SettingsPage(),
          ),
        ),
      ),
      GoRoute(
        path: changePassword,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: BlocProvider(
            create: (_) => sl<ChangePasswordCubit>(),
            child: const ChangePasswordPage(),
          ),
        ),
      ),
      GoRoute(
        path: privacyPolicyPage,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: const PrivacyPolicyPage(),
        ),
      ),

      // ── Merchant registration flow ──────────────────────────────────────
      GoRoute(
        path: becomeMerchant,
        pageBuilder: (context, state) {
          final args = state.extra as BecomeMerchantArgs?;
          return AppPageTransition.build(
            context: context,
            state: state,
            child: BecomeMerchantPage(
              onStoreCreated: args?.onStoreCreated,
            ),
          );
        },
      ),
      GoRoute(
        path: merchantPending,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: const MerchantPendingPage(),
        ),
      ),
      GoRoute(
        path: merchantIncomplete,
        pageBuilder: (context, state) {
          final storeId = state.extra as String? ?? '';
          return AppPageTransition.build(
            context: context,
            state: state,
            child: MerchantIncompletePage(storeId: storeId),
          );
        },
      ),
      GoRoute(
        path: merchantRejected,
        pageBuilder: (context, state) {
          final args = state.extra as MerchantStatusArgs?;
          return AppPageTransition.build(
            context: context,
            state: state,
            child: MerchantRejectedPage(
              storeId: args?.storeId ?? '',
              rejectionReasons: args?.reasons ?? const [],
            ),
          );
        },
      ),
      GoRoute(
        path: merchantStatus,
        pageBuilder: (context, state) {
          final args = state.extra as MerchantStatusArgs? ??
              const MerchantStatusArgs(storeId: '', reasons: []);
          return AppPageTransition.build(
            context: context,
            state: state,
            child: MerchantStatusPage(args: args),
          );
        },
      ),
      GoRoute(
        path: merchantApproved,
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: const MerchantApprovedPage(),
        ),
      ),
    ],
  );
}
