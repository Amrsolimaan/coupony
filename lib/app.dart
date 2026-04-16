import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/localization/locale_cubit.dart';
import 'package:coupony/core/network/global_network_listener.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/features/auth/presentation/cubit/persona_cubit.dart';
import 'package:coupony/features/auth/domain/entities/user_persona.dart';
import 'package:coupony/features/permissions/presentation/cubit/permission_flow_cubit.dart';
import 'package:coupony/features/user_flow/CustomerOnboarding/presentation/cubit/onboarding_flow_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/app_theme.dart';
import 'config/routes/app_router.dart';
import 'config/dependency_injection/injection_container.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        // توفير الـ Cubits العالمية هنا
        return MultiBlocProvider(
          providers: [
            BlocProvider<LocaleCubit>(create: (context) => sl<LocaleCubit>()),
            BlocProvider<PersonaCubit>(
              create: (context) => sl<PersonaCubit>(),
            ),
            BlocProvider<OnboardingFlowCubit>(
              create: (context) => sl<OnboardingFlowCubit>(),
            ),
            BlocProvider<PermissionFlowCubit>(
              create: (context) => sl<PermissionFlowCubit>(),
            ),
          ],
          // ✅ إزالة GlobalNetworkListener من هنا
          child: const AppView(),
        );
      },
    );
  }
}

/// AppView with WidgetsBindingObserver to detect system locale changes
class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Register observer to listen for system changes
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Unregister observer when widget is disposed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    super.didChangeLocales(locales);

    // When system locale changes, update app locale if no manual preference
    if (locales != null && locales.isNotEmpty) {
      final systemLocale = locales.first;
      final localeCubit = context.read<LocaleCubit>();

      // Update locale only if user hasn't manually set a preference
      localeCubit.updateFromSystemLocale(systemLocale);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return BlocBuilder<PersonaCubit, UserPersona>(
          builder: (context, persona) {
            // Theme is driven exclusively by PersonaCubit — structurally
            // in sync with the route because both observe the same state.
            final primaryColor = switch (persona) {
              LoadingPersona() => Colors.white, // neutral during cache read
              SellerPersona()  => AppColors.primaryOfSeller,
              _                => AppColors.primary,
            };
            
            final theme = AppTheme.lightTheme.copyWith(
              primaryColor: primaryColor,
              colorScheme: AppTheme.lightTheme.colorScheme.copyWith(
                primary: primaryColor,
              ),
            );
            return MaterialApp.router(
              title: 'Coupony',
              debugShowCheckedModeBanner: false,
              theme: theme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeMode.light,
              routerConfig: AppRouter.router,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: locale,
              // ✅ إضافة GlobalNetworkListener هنا داخل MaterialApp
              builder: (context, child) {
                return GlobalNetworkListener(child: child ?? const SizedBox.shrink());
              },
            );
          },
        );
      },
    );
  }
}
