// ملف اختبار يدوي لنظام مراقبة الشبكة
// استخدمه للتأكد من أن النظام يعمل بشكل صحيح

import 'package:flutter/material.dart';
import 'network_monitor.dart';
import 'network_thresholds.dart';

/// صفحة اختبار لمحاكاة طلبات بطيئة وعرض رسائل الشبكة
class NetworkTestPage extends StatelessWidget {
  const NetworkTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختبار مراقبة الشبكة'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'اختبار نظام مراقبة الشبكة',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // زر لمحاكاة طلب بطيء (يظهر تحذير فوراً)
            ElevatedButton(
              onPressed: () => _simulateSlowRequest(context, 6000),
              child: const Text('محاكاة طلب بطيء (6 ثواني - يظهر تحذير)'),
            ),
            const SizedBox(height: 10),
            
            // زر لمحاكاة طلب بطيء جداً
            ElevatedButton(
              onPressed: () => _simulateSlowRequest(context, 9000),
              child: const Text('محاكاة طلب بطيء جداً (9 ثواني)'),
            ),
            const SizedBox(height: 10),
            
            // زر لمحاكاة طلب سريع
            ElevatedButton(
              onPressed: () => _simulateSlowRequest(context, 1000),
              child: const Text('محاكاة طلب سريع (1 ثانية)'),
            ),
            const SizedBox(height: 20),
            
            // عرض إحصائيات النظام
            ElevatedButton(
              onPressed: () => _showStats(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text('عرض إحصائيات النظام'),
            ),
            const SizedBox(height: 10),
            
            // إعادة تعيين النظام
            ElevatedButton(
              onPressed: () {
                NetworkMonitor.instance.dispose();
                NetworkMonitor.instance.initialize();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إعادة تعيين النظام')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text('إعادة تعيين النظام'),
            ),
          ],
        ),
      ),
    );
  }

  void _simulateSlowRequest(BuildContext context, int delayMs) {
    final shouldWarn = NetworkMonitor.instance.recordRequest(
      responseTimeMs: delayMs,
      requestType: RequestType.api,
    );
    
    debugPrint('📊 طلب محاكى: ${delayMs}ms - تحذير: $shouldWarn');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تسجيل طلب: ${delayMs}ms - تحذير: $shouldWarn'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showStats(BuildContext context) {
    final stats = NetworkMonitor.instance.analyticsSnapshot;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إحصائيات النظام'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('السرعة الحالية: ${stats['currentSpeed']}'),
              Text('متوسط الوقت: ${stats['averageMs']?.toStringAsFixed(0)}ms'),
              Text('عدد الطلبات البطيئة المتتالية: ${stats['consecutiveSlowCount']}'),
              Text('النقاط: ${stats['slowScore']}'),
              Text('نوع الاتصال: ${stats['connectionType']}'),
              Text('الحساسية: ${stats['sensitivity']}'),
              Text('مستوى التأخير: ${stats['backoffLevel']}'),
              Text('آخر تحذير: ${stats['lastWarningShown'] ?? 'لا يوجد'}'),
              Text('انتهى التأخير: ${stats['cooldownExpired']}'),
              const SizedBox(height: 10),
              const Text('أوقات الاستجابة:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${stats['responseTimes']}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}
