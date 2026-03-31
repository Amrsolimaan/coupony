import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../config/routes/app_router.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../config/dependency_injection/injection_container.dart' as di;
import '../../../permissions/domain/repositories/permission_repository.dart';
import '../../data/datasources/auth_local_data_source.dart';

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _dropAnimation;
  late Animation<double> _expandAnimation;
  late Animation<double> _logoOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // 1. حركة السقوط من الأعلى للمنتصف (من -0.5 إلى 0.0)
    // -0.5 معناها نصف الشاشة فوق، و 0.0 معناها المنتصف بالضبط
    _dropAnimation = Tween<double>(begin: -0.5, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.bounceOut),
      ),
    );

    // 2. حركة الانفجار لتغطية الشاشة
    _expandAnimation = Tween<double>(begin: 1.0, end: 30.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.8, curve: Curves.easeInOut),
      ),
    );

    // 3. ظهور اللوجو
    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward().then((_) async {
      // ✅ STEP 1: Check if language has been selected (First-time check)
      try {
        final localeCubit = context.read<LocaleCubit>();
        final hasLanguagePreference = await localeCubit.hasManualPreference();

        if (!hasLanguagePreference) {
          // First time run - Navigate to Language Selection
          if (mounted) context.go(AppRouter.languageSelection);
          return;
        }

        // ✅ STEP 2: Check Permission status first (NEW FLOW: Permissions → Onboarding)
        final permissionRepository = di.sl<PermissionRepository>();
        final permissionResult = await permissionRepository.getPermissionStatus();
        
        permissionResult.fold(
          (failure) {
            // No permission data - start permission flow
            if (mounted) context.go(AppRouter.permissionSplash);
          },
          (permissionStatus) {
            if (permissionStatus != null && permissionStatus.hasCompletedFlow) {
              // ✅ Permissions completed, check if user has passed welcome gateway before
              _checkWelcomeGatewayStatus();
            } else {
              // Permissions not completed - start permission flow
              if (mounted) context.go(AppRouter.permissionSplash);
            }
          },
        );
      } catch (e) {
        // Fallback safety - go to language selection
        if (mounted) context.go(AppRouter.languageSelection);
      }
    });
  }

  /// STEP 3: Check if user has passed welcome gateway before.
  /// If yes → go to login directly
  /// If no → go to welcome gateway (first time after permissions)
  Future<void> _checkWelcomeGatewayStatus() async {
    try {
      final prefs = di.sl<SharedPreferences>();
      final hasPassedGateway = prefs.getBool(StorageKeys.hasPassedWelcomeGateway) ?? false;

      if (!mounted) return;

      if (hasPassedGateway) {
        // User has seen welcome gateway before - check session directly
        _checkOnboardingStatus();
      } else {
        // First time after permissions - show welcome gateway
        context.go(AppRouter.welcomeGateway);
      }
    } catch (_) {
      if (mounted) context.go(AppRouter.welcomeGateway);
    }
  }

  /// STEP 4: Determine session type, then route accordingly.
  ///
  /// Decision tree:
  ///   Guest session          → /home  (guests bypass onboarding)
  ///   Auth token + onboarding done   → /home
  ///   Auth token + onboarding pending → /onboarding  (wizard, post-auth)
  ///   No session             → /login (not welcome gateway - user has passed it before)
  Future<void> _checkOnboardingStatus() async {
    try {
      final authLocalDs = di.sl<AuthLocalDataSource>();

      final results = await Future.wait([
        authLocalDs.getAccessToken(),
        authLocalDs.getGuestStatus(),
        authLocalDs.getOnboardingCompleted(),
      ]);

      if (!mounted) return;

      final token                = results[0] as String?;
      final isGuest              = results[1] as bool;
      final isOnboardingCompleted = results[2] as bool;

      if (isGuest) {
        // Guest users skip onboarding entirely
        context.go(AppRouter.home);
        return;
      }

      if (token != null && token.isNotEmpty) {
        // Authenticated user — check whether they have completed onboarding
        // The flag was written by OnboardingFlowCubit after a 200 OK from
        // POST /api/v1/on-boarding/{role}.
        if (isOnboardingCompleted) {
          context.go(AppRouter.home);
        } else {
          context.go(AppRouter.onboarding);
        }
        return;
      }

      // No session at all
      context.go(AppRouter.login);
    } catch (_) {
      if (mounted) context.go(AppRouter.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // الكرة الساقطة والمتمددة
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Align(
                alignment: Alignment(
                  0.0, // المحور الأفقي: 0 يعني المنتصف
                  _dropAnimation.value, // المحور الرأسي: من -0.5 إلى 0.0
                ),
                child: Transform.scale(
                  scale: _expandAnimation.value,
                  child: Container(
                    width: 80.w, // استخدام ScreenUtil
                    height: 80.h,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.splashGradientStart,
                          AppColors.splashGradientEnd,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // ظهور اللوجو في النهاية
          Center(
            child: FadeTransition(
              opacity: _logoOpacityAnimation,
              child: Text('Coupony', style: AppTextStyles.logoStyle),
            ),
          ),
        ],
      ),
    );
  }
}
