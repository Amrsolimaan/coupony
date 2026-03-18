import 'package:coupon/core/localization/l10n/app_localizations.dart';
import 'package:coupon/features/permissions/presentation/cubit/permission_flow_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // إضافة استيراد Bloc
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/app_theme.dart';
import 'config/routes/app_router.dart';
import 'config/dependency_injection/injection_container.dart'; // استيراد حاوية الحقن
import 'features/onboarding/presentation/cubit/onboarding_flow_cubit.dart'; // استيراد الـ Cubit الجديد

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
            BlocProvider<OnboardingFlowCubit>(
              create: (context) => sl<OnboardingFlowCubit>(),
            ),
            BlocProvider<PermissionFlowCubit>(
              create: (context) => sl<PermissionFlowCubit>(),
            ),
          ],
          child: MaterialApp.router(
            title: 'Coupony',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            routerConfig: AppRouter.router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('ar'), // اللغة الافتراضية
          ),
        );
      },
    );
  }
}
