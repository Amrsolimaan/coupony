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
import '../../../Profile/domain/repositories/profile_repository.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/user_persona.dart';
import '../cubit/persona_cubit.dart';

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

    _dropAnimation = Tween<double>(begin: -0.5, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.bounceOut),
      ),
    );
    _expandAnimation = Tween<double>(begin: 1.0, end: 30.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.8, curve: Curves.easeInOut),
      ),
    );
    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
      ),
    );

    _loadAndStart();
  }

  // ── Entry point ─────────────────────────────────────────────────────────────

  Future<void> _loadAndStart() async {
    final personaCubit = di.sl<PersonaCubit>();

    // ── Phase 1: Cache read BEFORE animation ───────────────────────────────
    // Reads two SecureStorage keys (~2 ms). The BlocBuilder below rebuilds
    // immediately with the correct role color before the first frame of the
    // animation is painted — eliminating the Seller-color / Customer-route
    // visual contradiction that existed in the previous implementation.
    await personaCubit.preloadFromCache();
    if (!mounted) return;

    // Animation now starts with the correct persona color already set.
    _controller.forward().then((_) => _resolveAfterAnimation());
  }

  // ── Phase 2: API validation after the animation completes ───────────────────

  Future<void> _resolveAfterAnimation() async {
    if (!mounted) return;

    try {
      // ── Locale gate ────────────────────────────────────────────────────────
      final localeCubit = context.read<LocaleCubit>();
      if (!await localeCubit.hasManualPreference()) {
        if (mounted) context.go(AppRouter.languageSelection);
        return;
      }

      // ── Permission gate ────────────────────────────────────────────────────
      final authLocalDs     = di.sl<AuthLocalDataSource>();
      final existingToken   = await authLocalDs.getAccessToken();
      final isAuthenticated = existingToken != null && existingToken.isNotEmpty;

      final permissionRepo   = di.sl<PermissionRepository>();
      final permissionResult = await permissionRepo.getPermissionStatus();
      final bool permissionsComplete = permissionResult.fold(
        (_) => false,
        (status) => status?.hasCompletedFlow ?? false,
      );

      // Heal the permissions flag for authenticated users whose flag was wiped
      // (e.g., after a logout that cleared the Hive box).
      if (!permissionsComplete && isAuthenticated) {
        await permissionRepo.savePermissionStatus(hasCompletedFlow: true);
      }
      if (!permissionsComplete && !isAuthenticated) {
        if (mounted) context.go(AppRouter.permissionSplash);
        return;
      }

      // ── Welcome gateway gate ───────────────────────────────────────────────
      final prefs             = di.sl<SharedPreferences>();
      final hasPassedGateway  =
          prefs.getBool(StorageKeys.hasPassedWelcomeGateway) ?? false;
      if (!hasPassedGateway) {
        if (mounted) context.go(AppRouter.welcomeGateway);
        return;
      }

      // ── Auth gate ──────────────────────────────────────────────────────────
      // ✅ Only check token - PersonaCubit handles guest state
      if (!isAuthenticated) {
        if (mounted) context.go(AppRouter.login);
        return;
      }

      // ── API validation ─────────────────────────────────────────────────────
      // Fetch fresh profile data. On success, PersonaCubit re-resolves using
      // the canonical backend state and corrects any stale-cache mismatch.
      // On failure, the Phase-1 cached persona is kept — routing is consistent.
      final personaCubit  = di.sl<PersonaCubit>();
      final profileRepo   = di.sl<ProfileRepository>();
      final result        = await profileRepo.getProfile();

      if (!mounted) return;

      await result.fold(
        (_) async {
          // API failed — Phase-1 persona is already correct for the session.
          print('⚠️ [Splash] API failed — routing from cached persona');
        },
        (userEntity) async {
          if (userEntity is UserModel) {
            await personaCubit.resolveFromApi(userEntity);
          }
        },
      );

      if (!mounted) return;

      // ── Navigate strictly: /seller-home or /home ───────────────────────────
      _navigateFromPersona(personaCubit.state);
    } catch (e) {
      print('❌ [Splash] _resolveAfterAnimation error: $e');
      if (mounted) context.go(AppRouter.login);
    }
  }

  // ── Fixed routing — no intermediate redirects ────────────────────────────────

  void _navigateFromPersona(UserPersona persona) {
    switch (persona) {
      case SellerPersona(:final isPending, :final isGuest):
        // ✅ ALL sellers (pending or approved) go to /seller-home
        // SellerHome.dart internally shows PendingApprovalViewWidget if isPending = true
        context.go(
          AppRouter.sellerHome,
          extra: {'isGuest': isGuest, 'isPending': isPending},
        );

      case CustomerPersona(:final onboardingCompleted):
        context.go(onboardingCompleted ? AppRouter.home : AppRouter.onboarding);

      case GuestPersona():
        context.go(AppRouter.home);

      case LoadingPersona():
        // Should never reach navigation in loading state — safety fallback.
        context.go(AppRouter.login);
    }
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── UI ───────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // PersonaCubit is the ONLY source of truth for the splash gradient color.
    // Because preloadFromCache() runs before the animation starts, the color
    // is already correct on the very first frame — no post-animation flicker.
    return BlocBuilder<PersonaCubit, UserPersona>(
      builder: (context, persona) {
        final gradientColor = switch (persona) {
          LoadingPersona() => Colors.white,
          SellerPersona()  => AppColors.primaryOfSeller,
          _                => AppColors.splashGradientStart,
        };

        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Align(
                    alignment: Alignment(0.0, _dropAnimation.value),
                    child: Transform.scale(
                      scale: _expandAnimation.value,
                      child: Container(
                        width: 80.w,
                        height: 80.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: gradientColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
              Center(
                child: FadeTransition(
                  opacity: _logoOpacityAnimation,
                  child: Text(
                    'Coupony',
                    style: AppTextStyles.logoStyle.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
