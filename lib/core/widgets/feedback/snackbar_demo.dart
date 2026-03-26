import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../extensions/snackbar_extension.dart';
import '../../theme/app_colors.dart';

/// Demo page to showcase all SnackBar types
/// 
/// Usage: Navigate to this page to test all snackbar variations
class SnackBarDemoPage extends StatelessWidget {
  const SnackBarDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('SnackBar Demo'),
        backgroundColor: AppColors.primary,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Test All SnackBar Types',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 40.h),
              
              // Success Button
              _DemoButton(
                label: 'Show Success',
                color: AppColors.success,
                onPressed: () {
                  context.showSuccessSnackBar('تم الحفظ بنجاح! ✓');
                },
              ),
              SizedBox(height: 16.h),
              
              // Error Button
              _DemoButton(
                label: 'Show Error',
                color: AppColors.error,
                onPressed: () {
                  context.showErrorSnackBar('حدث خطأ! يرجى المحاولة مرة أخرى');
                },
              ),
              SizedBox(height: 16.h),
              
              // Warning Button
              _DemoButton(
                label: 'Show Warning',
                color: AppColors.warning,
                onPressed: () {
                  context.showWarningSnackBar('تحذير: تحقق من البيانات المدخلة');
                },
              ),
              SizedBox(height: 16.h),
              
              // Info Button
              _DemoButton(
                label: 'Show Info',
                color: AppColors.info,
                onPressed: () {
                  context.showInfoSnackBar('معلومة: يمكنك تغيير اللغة من الإعدادات');
                },
              ),
              SizedBox(height: 40.h),
              
              // Long Message Test
              _DemoButton(
                label: 'Show Long Message',
                color: AppColors.primary,
                onPressed: () {
                  context.showSuccessSnackBar(
                    'هذه رسالة طويلة جداً لاختبار كيف يتعامل الـ SnackBar مع النصوص الطويلة والتفاف الأسطر',
                    duration: const Duration(seconds: 5),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _DemoButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 2,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
