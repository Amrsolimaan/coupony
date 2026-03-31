# دليل نظام مراقبة الشبكة - Network Monitoring System Guide

## ✅ حالة النظام - System Status

النظام **مربوط بالكامل ويعمل بشكل صحيح**! 

### المكونات المفعّلة:

1. ✅ **NetworkMonitor** - مهيأ في `main.dart`
2. ✅ **NetworkMonitorInterceptor** - مضاف في `DioClient`
3. ✅ **GlobalNetworkListener** - يلف التطبيق بالكامل في `app.dart`
4. ✅ **Localization** - رسائل التحذير متوفرة بالعربية والإنجليزية

---

## 🎯 كيف يعمل النظام

### 1. التسجيل التلقائي
كل طلب HTTP يمر عبر `NetworkMonitorInterceptor` الذي:
- يسجل وقت البداية
- يحسب الوقت المستغرق
- يرسل البيانات لـ `NetworkMonitor`

### 2. التحليل الذكي
`NetworkMonitor` يحلل الطلبات بناءً على:
- **نوع الطلب**: Auth (3s), API (4s), Upload (10s), Download (8s)
- **نوع الاتصال**: WiFi (1x), Mobile (1.5x), Ethernet (0.75x)
- **الحساسية**: Low (1.5x), Medium (1x), High (0.7x)

### 3. عرض التحذيرات
عندما يكتشف النظام شبكة بطيئة:
- يرسل event عبر `qualityStream`
- `GlobalNetworkListener` يستقبل الـ event
- يعرض SnackBar بالرسالة المناسبة

---

## 🔍 لماذا لا أرى التحذيرات؟

### السبب 1: الإنترنت سريع ✅
النظام يعرض تحذير فقط عندما:
- **Slow**: متوسط الاستجابة > 4 ثواني
- **Very Slow**: متوسط الاستجابة > 8 ثواني

إذا كان الإنترنت سريع، لن ترى تحذيرات (وهذا جيد!)

### السبب 2: Cooldown Period ⏱️
لتجنب الإزعاج، التحذير يظهر مرة واحدة كل **دقيقتين**.

إذا ظهر تحذير، لن يظهر مرة أخرى إلا بعد دقيقتين حتى لو كان الإنترنت بطيء.

### السبب 3: Moving Average 📊
النظام يستخدم **متوسط متحرك** لـ 5 طلبات:
- يحتاج لعدة طلبات بطيئة متتالية
- طلب واحد بطيء لا يكفي لعرض التحذير

---

## 🧪 كيفية اختبار النظام

### الطريقة 1: تبطيء الإنترنت (Chrome DevTools)
إذا كنت تستخدم المحاكي:

1. افتح Chrome DevTools
2. اذهب لـ Network tab
3. اختر "Slow 3G" أو "Fast 3G"
4. جرب تسجيل الدخول عدة مرات

### الطريقة 2: تعديل الـ Thresholds مؤقتاً
لاختبار سريع، قلل الـ thresholds في `network_thresholds.dart`:

```dart
static const Map<RequestType, int> baseThresholds = {
  RequestType.auth: 500,    // كان 3000
  RequestType.api: 1000,    // كان 4000
  RequestType.upload: 2000, // كان 10000
  RequestType.download: 1500, // كان 8000
};
```

الآن حتى الإنترنت العادي سيظهر كـ "بطيء" وسترى التحذيرات.

**⚠️ تذكر إرجاع القيم الأصلية بعد الاختبار!**

### الطريقة 3: استخدام Network Throttling على الجهاز
على Android:
1. Settings → Developer Options
2. Networking → Select USB Configuration
3. اختر "Charging only" لتبطيء الشبكة

### الطريقة 4: فحص الـ Console Logs
النظام يطبع logs في الـ console:

```
Network warning shown: verySlow (8500ms avg)
```

إذا لم ترى هذه الرسالة، معناه الإنترنت سريع.

---

## 📊 فحص حالة النظام

### في الكود:
```dart
// الحصول على snapshot للحالة الحالية
final snapshot = NetworkMonitor.instance.analyticsSnapshot;
print('Network Status: $snapshot');

// Output:
// {
//   averageResponseTime: 2500.0,
//   currentSpeed: fast,
//   consecutiveSlowRequests: 0,
//   connectionType: wifi,
//   sensitivity: medium,
//   backoffLevel: 0,
//   lastWarningShown: null,
//   cooldownExpired: true
// }
```

### إضافة Debug Widget (اختياري):
يمكنك إضافة widget صغير يعرض حالة الشبكة:

```dart
StreamBuilder<NetworkQualityEvent>(
  stream: NetworkMonitor.instance.qualityStream,
  builder: (context, snapshot) {
    if (!snapshot.hasData) return SizedBox.shrink();
    
    final event = snapshot.data!;
    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.black54,
      child: Text(
        'Speed: ${event.speed.name} | Avg: ${event.averageResponseTimeMs}ms',
        style: TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  },
)
```

---

## 🎨 رسائل التحذير

### بالعربية:
```
الإنترنت بطيء جداً — قد تتأخر بعض الميزات
```

### بالإنجليزية:
```
Very slow internet — some features may be delayed
```

---

## ⚙️ التخصيص

### تغيير الحساسية:
```dart
NetworkMonitor.instance.sensitivity = NetworkSensitivity.high; // أكثر حساسية
NetworkMonitor.instance.sensitivity = NetworkSensitivity.low;  // أقل حساسية
```

### تغيير Cooldown Period:
في `global_network_listener.dart`:
```dart
static const Duration _warningCooldown = Duration(minutes: 1); // كان 2
```

### تغيير Thresholds:
في `network_thresholds.dart`:
```dart
static const Map<RequestType, int> baseThresholds = {
  RequestType.auth: 2000,    // أسرع
  RequestType.api: 3000,     // أسرع
  // ...
};
```

---

## 📁 الملفات المتعلقة

### Core Files:
- `lib/core/network/network_monitor.dart` - المحرك الأساسي
- `lib/core/network/network_interceptor.dart` - Dio interceptor
- `lib/core/network/network_thresholds.dart` - الإعدادات والحدود
- `lib/core/network/network_speed_detector.dart` - خوارزمية الكشف
- `lib/core/network/global_network_listener.dart` - UI listener

### Integration:
- `lib/main.dart` - تهيئة NetworkMonitor
- `lib/app.dart` - GlobalNetworkListener wrapper
- `lib/core/network/dio_client.dart` - NetworkMonitorInterceptor

### Localization:
- `lib/core/localization/l10n/app_en.arb` - رسائل إنجليزية
- `lib/core/localization/l10n/app_ar.arb` - رسائل عربية

---

## 🐛 استكشاف الأخطاء

### المشكلة: لا أرى أي logs
**الحل**: تأكد من أنك في Debug mode

### المشكلة: التحذيرات لا تظهر أبداً
**الحل**: 
1. تحقق من أن الإنترنت بطيء فعلاً
2. جرب تقليل الـ thresholds مؤقتاً
3. تحقق من الـ console logs

### المشكلة: التحذيرات تظهر كثيراً
**الحل**:
1. زد الـ cooldown period
2. قلل الحساسية: `NetworkSensitivity.low`
3. زد الـ thresholds

### المشكلة: التحذيرات بالإنجليزية
**الحل**: تأكد من أن لغة التطبيق عربية في الإعدادات

---

## ✅ الخلاصة

النظام يعمل بشكل ممتاز! إذا لم ترى تحذيرات، هذا يعني أن:
- ✅ الإنترنت سريع (جيد!)
- ✅ النظام يعمل في الخلفية ويراقب
- ✅ سيظهر تحذير تلقائياً عندما يبطئ الإنترنت

لا حاجة لأي تعديلات إضافية! 🎉
