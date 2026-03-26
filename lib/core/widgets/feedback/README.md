# Glassmorphic SnackBar System

نظام إشعارات متقدم بتصميم glassmorphism احترافي مستوحى من iOS.

## ✨ المميزات الجديدة

### � تصميم Glassmorphism
- **تأثير الزجاج**: خلفية شفافة مع blur effect
- **ألوان ناعمة**: ألوان iOS الأصلية بدلاً من Material Design الحادة
- **حدود شفافة**: borders ناعمة مع شفافية متدرجة
- **ظلال متقدمة**: ظلال ملونة مع glow effect

### 🎭 الرسوم المتحركة
- **انزلاق مرن**: elastic slide animation من الأسفل
- **تأثير النبض**: glow pulsing للألوان
- **شريط التقدم**: progress indicator مدمج
- **تفاعل اللمس**: haptic feedback حسب نوع الرسالة

### 🎯 تحسينات UX
- **سحب للإغلاق**: swipe up gesture للإخفاء
- **إغلاق تلقائي**: مع progress indicator
- **ردود فعل لمسية**: مختلفة لكل نوع رسالة
- **تصميم متجاوب**: يتكيف مع أحجام الشاشات

## 🎨 الألوان الجديدة

```dart
// iOS Inspired Colors
static const Color success = Color(0xFF34C759);      // iOS Green
static const Color error = Color(0xFFFF3B30);        // iOS Red  
static const Color warning = Color(0xFFFF9500);      // iOS Orange
static const Color info = Color(0xFF007AFF);         // iOS Blue

// Glassmorphism Support
static const Color glassWhite = Color(0xCCFFFFFF);   // شفاف أبيض
static const Color glassBorder = Color(0x33FFFFFF);  // حدود شفافة
static const Color glassOverlay = Color(0x1AFFFFFF); // طبقة علوية
```

## 🚀 الاستخدام

### الطريقة الأساسية
```dart
AppSnackBar.show(
  context,
  message: 'تم تحديث جميع اختياراتك بنجاح',
  type: SnackBarType.success,
  duration: Duration(seconds: 4),
  enableHaptic: true,
);
```

### الأنواع المتاحة
```dart
// نجاح - أخضر iOS مع haptic خفيف
SnackBarType.success

// خطأ - أحمر iOS مع haptic قوي  
SnackBarType.error

// تحذير - برتقالي iOS مع haptic متوسط
SnackBarType.warning

// معلومات - أزرق iOS مع haptic خفيف
SnackBarType.info
```

## 🎪 التجربة التفاعلية

استخدم `SnackBarDemo` لاختبار جميع الأنواع:

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => SnackBarDemo()),
);
```

## 🔧 التخصيص المتقدم

### تعديل شدة التوهج
```dart
_SnackBarConfig(
  primaryColor: AppColors.success,
  softColor: AppColors.successSoft,
  icon: Icons.check_circle_rounded,
  glowIntensity: 0.8, // 0.0 - 1.0
);
```

### تخصيص الرسوم المتحركة
```dart
// مدة الانزلاق
duration: const Duration(milliseconds: 800)

// منحنى الحركة  
curve: Curves.elasticOut

// شدة الـ blur
ImageFilter.blur(sigmaX: 20, sigmaY: 20)
```

## 🎨 مقارنة التصميم

### قبل (Material Design)
- ألوان حادة ومشبعة
- خلفية صلبة
- حدود حادة
- ظلال بسيطة

### بعد (Glassmorphism)
- ألوان iOS ناعمة
- خلفية شفافة مع blur
- حدود شفافة متدرجة
- ظلال ملونة مع glow
- تأثيرات تفاعلية متقدمة

## 📱 الدعم

- ✅ iOS Style Colors
- ✅ Glassmorphism Effects  
- ✅ Haptic Feedback
- ✅ RTL Support
- ✅ Responsive Design
- ✅ Accessibility Ready