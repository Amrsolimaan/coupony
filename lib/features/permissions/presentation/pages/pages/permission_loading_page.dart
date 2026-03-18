import 'package:coupon/config/routes/app_router.dart';
import 'package:coupon/features/permissions/presentation/cubit/permission_flow_cubit.dart';
import 'package:coupon/features/permissions/presentation/cubit/permission_flow_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Permission Loading Page
/// Final loading screen after permissions are completed
/// Shows progress animation before navigating to home/auth
class PermissionLoadingPage extends StatelessWidget {
  const PermissionLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocListener<PermissionFlowCubit, PermissionFlowState>(
          listener: (context, state) {
            // Navigate to home when loading is complete
            if (state.navSignal == PermissionNavigationSignal.toHome) {
              context.go(AppRouter.home);
              context.read<PermissionFlowCubit>().clearNavigationSignal();
            }
          },
          child: Center(
            child: BlocBuilder<PermissionFlowCubit, PermissionFlowState>(
              builder: (context, state) {
                // Get progress from state
                final double progress = state.loadingProgress;

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Logo or Icon
                      Icon(
                        Icons.check_circle_outline,
                        size: 100.w,
                        color: Theme.of(context).primaryColor,
                      ),

                      SizedBox(height: 40.h),

                      // Loading Text
                      Text(
                        'جاري تحضير كل شيء...',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Cairo',
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 40.h),

                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3.r),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6.h,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Progress Text
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                          fontFamily: 'Cairo',
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Status Messages (optional)
                      Text(
                        _getLoadingMessage(progress),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[500],
                          fontFamily: 'Cairo',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Get loading message based on progress
  String _getLoadingMessage(double progress) {
    if (progress < 0.4) {
      return 'جاري التحقق من الصلاحيات...';
    } else if (progress < 0.7) {
      return 'جاري تحميل البيانات...';
    } else {
      return 'اكتمل التحميل...';
    }
  }
}
