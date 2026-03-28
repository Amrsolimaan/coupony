import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_snackbar.dart';
import '../../network/network_test_utils.dart';

class SnackBarDemo extends StatelessWidget {
  const SnackBarDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Glassmorphic SnackBar Demo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFE3F2FD),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'اختبر التصميم الجديد',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'اضغط عدة مرات لاختبار عدم التراكم',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF6B6B6B),
                ),
              ),
              SizedBox(height: 40.h),
              
              // Success Button
              _DemoButton(
                title: 'رسالة نجاح',
                subtitle: 'تم تحديث جميع اختياراتك بنجاح',
                color: const Color(0xFF34C759),
                onPressed: () => AppSnackBar.show(
                  context,
                  message: 'تم تحديث جميع اختياراتك بنجاح',
                  type: SnackBarType.success,
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // Error Button
              _DemoButton(
                title: 'رسالة خطأ',
                subtitle: 'حدث خطأ غير متوقع',
                color: const Color(0xFFFF3B30),
                onPressed: () => AppSnackBar.show(
                  context,
                  message: 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى',
                  type: SnackBarType.error,
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // Warning Button
              _DemoButton(
                title: 'رسالة تحذير',
                subtitle: 'يرجى التحقق من البيانات',
                color: const Color(0xFFFF9500),
                onPressed: () => AppSnackBar.show(
                  context,
                  message: 'يرجى التحقق من صحة البيانات المدخلة',
                  type: SnackBarType.warning,
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // Info Button
              _DemoButton(
                title: 'رسالة معلومات',
                subtitle: 'معلومة مهمة للمستخدم',
                color: const Color(0xFF007AFF),
                onPressed: () => AppSnackBar.show(
                  context,
                  message: 'تم حفظ التغييرات تلقائياً في السحابة',
                  type: SnackBarType.info,
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // Network Slow Button
              _DemoButton(
                title: 'تحذير الشبكة البطيئة',
                subtitle: 'تم اكتشاف اتصال إنترنت بطيء',
                color: const Color(0xFFFF8C00),
                onPressed: () => AppSnackBar.show(
                  context,
                  message: 'تم اكتشاف اتصال إنترنت بطيء',
                  type: SnackBarType.networkSlow,
                ),
              ),
              
              SizedBox(height: 24.h),
              
              // Test Network Monitoring
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 24.w),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'اختبار مراقبة الشبكة',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'محاكاة طلبات بطيئة لاختبار النظام التلقائي',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF6B6B6B),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await NetworkTestUtils.simulateSlowRequest();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF8C00),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: Text(
                              'طلب بطيء واحد',
                              style: TextStyle(fontSize: 12.sp),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await NetworkTestUtils.simulateMultipleSlowRequests();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF3B30),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: Text(
                              'عدة طلبات بطيئة',
                              style: TextStyle(fontSize: 12.sp),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onPressed;

  const _DemoButton({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: color.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.touch_app_rounded,
                    color: color,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF6B6B6B),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: color,
                  size: 16.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}