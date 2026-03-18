import 'package:coupon/features/permissions/presentation/pages/permission_flow_wrapper.dart';
import 'package:coupon/features/permissions/presentation/pages/pages/location_error_page.dart';
import 'package:coupon/features/permissions/presentation/pages/pages/location_intro_page.dart';
import 'package:coupon/features/permissions/presentation/pages/pages/location_map_page.dart';
import 'package:coupon/features/permissions/presentation/pages/pages/notification_error_page.dart';
import 'package:coupon/features/permissions/presentation/pages/pages/notification_intro_page.dart';
import 'package:coupon/features/permissions/presentation/pages/pages/permission_loading_page.dart';
import 'package:coupon/features/permissions/presentation/pages/pages/permission_splash_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// استيراد شاشات الـ Onboarding
import 'package:coupon/features/auth/presentation/pages/splash_screen.dart';
import 'package:coupon/features/auth/presentation/pages/onboarding_screen.dart';
import 'package:coupon/features/onboarding/presentation/pages/onboarding_preferences_screen.dart';
import 'package:coupon/features/onboarding/presentation/pages/onboarding_budget_screen.dart';
import 'package:coupon/features/onboarding/presentation/pages/onboarding_shopping_style_screen.dart';

// Placeholder screens for testing
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

class AppRouter {
  // أسماء المسارات (Route Names)
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String onboardingPreferences = '/onboarding-preferences';
  static const String onboardingBudget = '/onboarding-budget';
  static const String onboardingShoppingStyle = '/onboarding-shopping-style';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String merchantDashboard = '/merchant-dashboard';

  // ✅ Permission Flow Routes (محدثة)
  static const String permissionFlow = '/permission-flow'; // NEW - Entry point
  static const String permissionSplash = '/permission-splash';
  static const String permissionLocationIntro = '/permission-location-intro';
  static const String permissionLocationMap = '/permission-location-map';
  static const String permissionLocationError = '/permission-location-error';
  static const String permissionNotificationIntro =
      '/permission-notification-intro';
  static const String permissionNotificationError =
      '/permission-notification-error';
  static const String permissionLoading = '/permission-loading';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: true,
    routes: [
      // 1. Splash Screen
      GoRoute(
        path: splash,
        builder: (context, state) => const AnimatedSplashScreen(),
      ),

      // 2. Onboarding Flow
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

      // ✅ 3. Permission Flow - NEW ARCHITECTURE
      // Entry Point - Wrapper that listens to Cubit and auto-navigates
      GoRoute(
        path: permissionFlow,
        builder: (context, state) => const PermissionFlowWrapper(),
      ),

      // Individual Permission Screens (navigated to by Wrapper)
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

      // 4. Auth Screens
      GoRoute(path: login, builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // 5. Main App Screens
      GoRoute(path: home, builder: (context, state) => const UserHomeScreen()),
      GoRoute(
        path: merchantDashboard,
        builder: (context, state) => const MerchantDashboardScreen(),
      ),
    ],
  );
}
