# App SnackBar 🎨

Custom animated snackbar system with beautiful design and smooth animations.

## Features ✨

- 🎯 **4 Types**: Success, Error, Warning, Info
- 🎨 **Beautiful Design**: Modern UI with shadows and rounded corners
- ⚡ **Smooth Animations**: Elastic slide-in, fade, and scale effects
- 📱 **SafeArea Aware**: Respects navigation bars and notches
- 👆 **Swipe to Dismiss**: Swipe down to close
- ⏱️ **Auto Dismiss**: Configurable duration
- 🎭 **Icon Animations**: Pulse effect on icons
- 🌈 **Theme Independent**: Works with both customer and seller themes

## Usage 📝

### Simple Usage (Recommended)

```dart
import 'package:coupony/core/extensions/snackbar_extension.dart';

// Show success message
context.showSuccessSnackBar('تم الحفظ بنجاح');

// Show error message
context.showErrorSnackBar('حدث خطأ ما');

// Show warning message
context.showWarningSnackBar('تحذير: تحقق من البيانات');

// Show info message
context.showInfoSnackBar('معلومة مفيدة');

// Custom duration
context.showSuccessSnackBar(
  'تم الحفظ',
  duration: Duration(seconds: 5),
);
```

### Advanced Usage

```dart
import 'package:coupony/core/widgets/feedback/app_snackbar.dart';

AppSnackBar.show(
  context,
  message: 'Custom message',
  type: SnackBarType.success,
  duration: Duration(seconds: 3),
);
```

## Design Specs 🎨

### Colors

- **Success**: `#4CAF50` (Green) - White text
- **Error**: `#E53935` (Red) - White text
- **Warning**: `#FFC107` (Amber) - Dark text
- **Info**: `#2196F3` (Blue) - White text

### Animations

1. **Slide In**: Elastic curve from bottom
2. **Fade In**: Smooth opacity transition
3. **Scale**: Bounce effect on entry
4. **Icon Pulse**: Elastic scale animation

### Positioning

- Bottom: `SafeArea.bottom + 20.h`
- Horizontal: `20.w` from edges
- Rounded corners: `16.r`

## Migration Guide 🔄

### Before (Old SnackBar)

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Message'),
    backgroundColor: AppColors.error,
  ),
);
```

### After (New SnackBar)

```dart
context.showErrorSnackBar('Message');
```

## Examples 📸

### Success
```dart
context.showSuccessSnackBar('تم إنشاء الحساب بنجاح');
```

### Error
```dart
context.showErrorSnackBar('البريد الإلكتروني مستخدم بالفعل');
```

### Warning
```dart
context.showWarningSnackBar('كلمة المرور ضعيفة');
```

### Info
```dart
context.showInfoSnackBar('يمكنك تغيير اللغة من الإعدادات');
```

## Technical Details 🔧

- Uses `OverlayEntry` for custom positioning
- Respects `MediaQuery.padding.bottom` for safe area
- Auto-removes from overlay after duration
- Supports swipe-to-dismiss gesture
- Smooth animations with `AnimationController`

## Files 📁

- `lib/core/widgets/feedback/app_snackbar.dart` - Main widget
- `lib/core/extensions/snackbar_extension.dart` - Extension methods
