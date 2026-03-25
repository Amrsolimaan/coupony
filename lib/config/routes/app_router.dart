import 'package:coupony/features/auth/presentation/pages/forgot_password_screen.dart';
import 'package:coupony/features/auth/presentation/pages/register_screen.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

// Auth screens
import 'package:coupony/features/auth/presentation/pages/splash_screen.dart';
import 'package:coupony/features/auth/presentation/pages/onboarding_screen.dart';
import 'package:coupony/features/auth/presentation/pages/login_screen.dart' as auth_login;
import 'package:coupony/features/auth/presentation/pages/otp_screen.dart';
import 'package:coupony/features/auth/presentation/cubit/forgot_password_cubit.dart';
import 'package:coupony/features/auth/presentation/cubit/login_cubit.dart';
import 'package:coupony/features/auth/presentation/cubit/otp_cubit.dart';
import 'package:coupony/features/auth/presentation/cubit/register_cubit.dart';
import 'package:coupony/features/auth/presentation/cubit/reset_password_cubit.dart';
import 'package:coupony/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coupony/features/auth/presentation/pages/reset_password_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Onboarding screens
import 'package:coupony/features/onboarding/presentation/pages/language_selection_page.dart';
import 'package:coupony/features/permissions/presentation/pages/pages/welcome_gateway_page.dart';
import 'package:coupony/features/onboarding/presentation/pages/onboarding_preferences_screen.dart';
import 'package:coupony/features/onboarding/presentation/pages/onboarding_budget_screen.dart';
import 'package:coupony/features/onboarding/presentation/pages/onboarding_shopping_style_screen.dart';

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
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
  AppRouter.forgotPassword,
  AppRouter.resetPassword,
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
  static const String forgotPassword            = '/forgot-password';
  static const String resetPassword             = '/reset-password';
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

      // Public routes (splash, onboarding, permissions, auth screens) are
      // always accessible — skip the session check entirely.
      if (_publicRoutes.contains(location)) return null;

      // 1. Authenticated user — token present and non-empty.
      final token = await sl<SecureStorageService>().read(StorageKeys.authToken);
      if (token != null && token.isNotEmpty) return null;

      // 2. Guest user — explicit visitor session persisted in SharedPreferences.
      //    getBool() is synchronous once SharedPreferences is initialised.
      final isGuest = sl<SharedPreferences>().getBool(StorageKeys.isGuest) ?? false;
      if (isGuest) return null;

      // 3. No session — redirect to the gateway so the user can sign in or
      //    choose guest mode again.
      return welcomeGateway;
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
        builder: (context, state) => BlocProvider(
          create: (_) => sl<LoginCubit>(),
          child: const auth_login.LoginScreen(),
        ),
      ),
      GoRoute(
        path: register,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<RegisterCubit>(),
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: otpVerification,
        builder: (context, state) {
          // extra can be:
          //   String  — legacy / register flow (email only, emailVerification mode)
          //   Map<String,String> — new flow: { 'email': ..., 'mode': 'forgotPassword' }
          final extra = state.extra;
          final String email;
          final OtpMode mode;
          if (extra is Map<String, String>) {
            email = extra['email'] ?? '';
            mode  = extra['mode'] == 'forgotPassword'
                ? OtpMode.forgotPassword
                : OtpMode.emailVerification;
          } else {
            email = extra as String? ?? '';
            mode  = OtpMode.emailVerification;
          }
          return BlocProvider(
            create: (_) => sl<OtpCubit>(),
            child: OtpScreen(email: email, mode: mode),
          );
        },
      ),
      GoRoute(
        path: forgotPassword,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<ForgotPasswordCubit>(),
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: resetPassword,
        builder: (context, state) {
          final params = state.extra as Map<String, String>?;
          return BlocProvider(
            create: (_) => sl<ResetPasswordCubit>(),
            child: ResetPasswordScreen(
              email: params?['email'] ?? '',
              token: params?['token'] ?? '',
            ),
          );
        },
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
