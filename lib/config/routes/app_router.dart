import 'package:coupony/core/widgets/Shared_Onboarding/onboarding_completion_loading_page.dart';

import 'package:coupony/features/auth/presentation/pages/forgot_password_screen.dart';
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
import 'package:coupony/features/seller_flow/CreateStore/presentation/pages/create_store_screen.dart';
import 'package:coupony/features/seller_flow/CreateStore/presentation/pages/store_under_review_page.dart';
import 'package:coupony/features/seller_flow/StoreSelection/presentation/pages/store_selection_page.dart';
import 'package:coupony/features/auth/data/models/user_store_model.dart';
import 'package:coupony/features/seller_flow/SellerOnboarding/presentation/pages/onboarding_seller_screen.dart';
import 'package:coupony/features/seller_flow/SellerOnboarding/presentation/pages/seller_onboarding_start_screen.dart';
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

// ── Placeholder screens (replace with real screens when built) ──────────────

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

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
                title: const Text('Home'),
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
                      'User Home Screen',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('مرحباً! تم تسجيل الدخول بنجاح'),
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
  static const String storeSelection   = '/store-selection';
  static const String login = '/login';
  static const String register = '/register';
  static const String otpVerification = '/otp-verification';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String home = '/home';
  static const String merchantDashboard = '/merchant-dashboard';

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
        pageBuilder: (context, state) => AppPageTransition.build(
          context: context,
          state: state,
          child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => sl<CreateStoreCubit>()),
              BlocProvider(create: (_) => sl<LoginCubit>()),
            ],
            child: const CreateStoreScreen(),
          ),
        ),
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
          child: const UserHomeScreen(),
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
    ],
  );
}
