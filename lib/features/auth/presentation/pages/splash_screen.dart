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
import '../cubit/auth_role_cubit.dart';
import '../cubit/auth_role_state.dart';
import '../utils/seller_routing_resolver.dart';

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
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.bounceOut)),
    );
    _expandAnimation = Tween<double>(begin: 1.0, end: 30.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 0.8, curve: Curves.easeInOut)),
    );
    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.8, 1.0, curve: Curves.easeIn)),
    );

    _loadRoleAndStart();
  }

  Future<void> _loadRoleAndStart() async {
    try {
      await di.sl<AuthRoleCubit>().loadPersistedRole();
    } catch (_) {}

    if (!mounted) return;

    _controller.forward().then((_) async {
      try {
        final localeCubit = context.read<LocaleCubit>();
        if (!await localeCubit.hasManualPreference()) {
          if (mounted) context.go(AppRouter.languageSelection);
          return;
        }

        final permissionRepository = di.sl<PermissionRepository>();
        final permissionResult     = await permissionRepository.getPermissionStatus();

        permissionResult.fold(
          (failure) {
            if (mounted) context.go(AppRouter.permissionSplash);
          },
          (permissionStatus) {
            if (permissionStatus != null && permissionStatus.hasCompletedFlow) {
              _checkWelcomeGatewayStatus();
            } else {
              if (mounted) context.go(AppRouter.permissionSplash);
            }
          },
        );
      } catch (e) {
        if (mounted) context.go(AppRouter.languageSelection);
      }
    });
  }

  Future<void> _checkWelcomeGatewayStatus() async {
    try {
      final prefs           = di.sl<SharedPreferences>();
      final hasPassedGateway = prefs.getBool(StorageKeys.hasPassedWelcomeGateway) ?? false;
      if (!mounted) return;
      if (hasPassedGateway) {
        _checkOnboardingStatus();
      } else {
        context.go(AppRouter.welcomeGateway);
      }
    } catch (_) {
      if (mounted) context.go(AppRouter.welcomeGateway);
    }
  }

  Future<void> _checkOnboardingStatus() async {
    try {
      final authLocalDs = di.sl<AuthLocalDataSource>();

      final results = await Future.wait([
        authLocalDs.getAccessToken(),
        authLocalDs.getGuestStatus(),
        authLocalDs.getOnboardingCompleted(),
        authLocalDs.getStoreCreated(),
      ]);

      if (!mounted) return;

      final token                = results[0] as String?;
      final isGuest              = results[1] as bool;
      final isOnboardingCompleted = results[2] as bool;
      final isStoreCreated       = results[3] as bool;

      if (isGuest) {
        context.go(AppRouter.home);
        return;
      }

      if (token != null && token.isNotEmpty) {
        final authRoleCubit = context.read<AuthRoleCubit>();

        if (authRoleCubit.state.isSeller) {
          // Step 1: seller must complete onboarding before store decisions
          if (!isOnboardingCompleted) {
            context.go(AppRouter.sellerOnboarding);
            return;
          }

          // Step 2: delegate to the shared 4-scenario resolver
          await SellerRoutingResolver.resolveFromCache(
            context:               context,
            isOnboardingCompleted: isOnboardingCompleted,
            isStoreCreated:        isStoreCreated,
            authLocalDs:           authLocalDs,
          );
          return;
        }

        // Customer path
        context.go(isOnboardingCompleted ? AppRouter.home : AppRouter.onboarding);
        return;
      }

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
    return BlocBuilder<AuthRoleCubit, AuthRoleState>(
      builder: (context, roleState) {
        final gradientColor = roleState.isLoading
            ? Colors.white
            : (roleState.isSeller
                ? AppColors.primaryOfSeller
                : AppColors.splashGradientStart);

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
                    style: AppTextStyles.logoStyle.copyWith(color: Colors.white),
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
