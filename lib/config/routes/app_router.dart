import 'package:coupony/features/onboarding/presentation/pages/onboarding_completion_loading_page.dart';
import 'package:coupony/features/permissions/presentation/pages/permission_flow_wrapper.dart';
import 'package:coupony/features/permissions/presentation/pages/pages/location_error_page.dart';
import 'package:coupony/features/permissions/presentation/pages/pages/location_intro_page.dart';
import 'package:coupony/features/permissions/presentation/pages/pages/location_map_page.dart';
import 'package:coupony/features/permissions/presentation/pages/pages/notification_error_page.dart';
import 'package:coupony/features/permissions/presentation/pages/pages/notification_intro_page.dart';
import 'package:coupony/features/permissions/presentation/pages/pages/permission_loading_page.dart';
import 'package:coupony/features/permissions/presentation/pages/pages/permission_splash_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Core
import 'package:coupony/config/dependency_injection/injection_container.dart';
import 'package:coupony/core/constants/storage_keys.dart';
import 'package:coupony/core/storage/secure_storage_service.dart';

// Auth screens
import 'package:coupony/features/auth/presentation/pages/splash_screen.dart';
import 'package:coupony/features/auth/presentation/pages/onboarding_screen.dart';

// Onboarding screens
import 'package:coupony/features/onboarding/presentation/pages/language_selection_page.dart';
import 'package:coupony/features/permissions/presentation/pages/pages/welcome_gateway_page.dart';
import 'package:coupony/features/onboarding/presentation/pages/onboarding_preferences_screen.dart';
import 'package:coupony/features/onboarding/presentation/pages/onboarding_budget_screen.dart';
import 'package:coupony/features/onboarding/presentation/pages/onboarding_shopping_style_screen.dart';

// ── Placeholder screens (replace with real screens when built) ──────────────

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Login Screen')));
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Register Screen')));
}

class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('OTP Verification Screen')));
}

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('User Home Screen')));
}

class MerchantDashboardScreen extends StatelessWidget {
  const MerchantDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Merchant Dashboard')));
}

// ── Route paths that are always accessible without a token ──────────────────
const _publicRoutes = {
  AppRouter.splash,
  AppRouter.languageSelection,
  AppRouter.onboarding,
  AppRouter.onboardingPreferences,
  AppRouter.onboardingBudget,
  AppRouter.onboardingShoppingStyle,
  AppRouter.onboardingCompletionLoading,
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
};

class AppRouter {
  // ── Route paths ───────────────────────────────────────────────────────────
  static const String splash                    = '/';
  static const String languageSelection         = '/language-selection';
  static const String onboarding                = '/onboarding';
  static const String onboardingPreferences     = '/onboarding-preferences';
  static const String onboardingBudget          = '/onboarding-budget';
  static const String onboardingShoppingStyle   = '/onboarding-shopping-style';
  static const String onboardingCompletionLoading = '/onboarding-completion-loading';
  static const String login                     = '/login';
  static const String register                  = '/register';
  static const String otpVerification           = '/otp-verification';
  static const String home                      = '/home';
  static const String merchantDashboard         = '/merchant-dashboard';

  // Permission flow
  static const String permissionFlow            = '/permission-flow';
  static const String permissionSplash          = '/permission-splash';
  static const String permissionLocationIntro   = '/permission-location-intro';
  static const String permissionLocationMap     = '/permission-location-map';
  static const String permissionLocationError   = '/permission-location-error';
  static const String permissionNotificationIntro  = '/permission-notification-intro';
  static const String permissionNotificationError  = '/permission-notification-error';
  static const String permissionLoading         = '/permission-loading';
  static const String welcomeGateway            = '/welcome-gateway';

  // ── Router ────────────────────────────────────────────────────────────────
  static final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: true,

    // ── Auth guard ──────────────────────────────────────────────────────────
    redirect: (context, state) async {
      final location = state.matchedLocation;

      // Public routes are always accessible
      if (_publicRoutes.contains(location)) return null;

      // Protected route — check for stored token
      final token = await sl<SecureStorageService>().read(StorageKeys.authToken);
      if (token == null) return login;

      return null; // Token present — allow navigation
    },

    routes: [
      // 1. Splash
      GoRoute(
        path: splash,
        builder: (context, state) => const AnimatedSplashScreen(),
      ),

      // 2. Language Selection
      GoRoute(
        path: languageSelection,
        builder: (context, state) => const LanguageSelectionPage(),
      ),

      // 3. Onboarding flow
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: onboardingPreferences,
        builder: (context, state) => const OnboardingCategorySelectionScreen(),
      ),
      GoRoute(
        path: onboardingBudget,
        builder: (context, state) => const OnboardingBudgetScreen(),
      ),
      GoRoute(
        path: onboardingShoppingStyle,
        builder: (context, state) => const OnboardingShoppingStyleScreen(),
      ),
      GoRoute(
        path: onboardingCompletionLoading,
        builder: (context, state) => const OnboardingCompletionLoadingPage(),
      ),

      // 4. Permission flow
      GoRoute(
        path: permissionFlow,
        builder: (context, state) => const PermissionFlowWrapper(),
      ),
      GoRoute(
        path: permissionSplash,
        builder: (context, state) => const PermissionSplashPage(),
      ),
      GoRoute(
        path: permissionLocationIntro,
        builder: (context, state) => const LocationIntroPage(),
      ),
      GoRoute(
        path: permissionLocationMap,
        builder: (context, state) => const LocationMapPage(),
      ),
      GoRoute(
        path: permissionLocationError,
        builder: (context, state) => const LocationErrorPage(),
      ),
      GoRoute(
        path: permissionNotificationIntro,
        builder: (context, state) => const NotificationIntroPage(),
      ),
      GoRoute(
        path: permissionNotificationError,
        builder: (context, state) => const NotificationErrorPage(),
      ),
      GoRoute(
        path: permissionLoading,
        builder: (context, state) => const PermissionLoadingPage(),
      ),
      GoRoute(
        path: welcomeGateway,
        builder: (context, state) => const WelcomeGatewayPage(),
      ),

      // 5. Auth screens
      GoRoute(
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: otpVerification,
        builder: (context, state) => const OtpVerificationScreen(),
      ),

      // 6. Protected app screens
      GoRoute(
        path: home,
        builder: (context, state) => const UserHomeScreen(),
      ),
      GoRoute(
        path: merchantDashboard,
        builder: (context, state) => const MerchantDashboardScreen(),
      ),
    ],
  );
}
