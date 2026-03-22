# CouponyLoadingIndicator - Usage Examples

## ✨ Features

- ✅ Circular progress with smooth gradient
- ✅ Rotation animation (continuous)
- ✅ Pulse effect for center icon
- ✅ Fade transitions for messages
- ✅ Optimized with RepaintBoundary
- ✅ Fully customizable
- ✅ Responsive with ScreenUtil

---

## 📖 Basic Usage

### Example 1: Simple Loading (Indeterminate)
```dart
import 'package:coupony/core/widgets/loading/loading.dart';

CouponyLoadingIndicator(
  progress: 0.0, // Indeterminate
  message: 'Loading...',
)
```

### Example 2: Progress Loading (Determinate)
```dart
CouponyLoadingIndicator(
  progress: 0.65, // 65%
  message: 'Loading data...',
  showPercentage: true,
)
```

### Example 3: Custom Size and Colors
```dart
CouponyLoadingIndicator(
  progress: 0.5,
  size: 150.0,
  primaryColor: Colors.blue,
  secondaryColor: Colors.lightBlue,
  strokeWidth: 10.0,
  centerIcon: Icons.download,
  message: 'Downloading...',
)
```

### Example 4: Without Percentage
```dart
CouponyLoadingIndicator(
  progress: 0.8,
  showPercentage: false,
  message: 'Almost done...',
)
```

---

## 🎯 Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `progress` | `double` | `0.0` | Progress value (0.0 to 1.0) |
| `size` | `double` | `120.0` | Size of the circular indicator |
| `primaryColor` | `Color?` | `AppColors.primary` | Primary gradient color |
| `secondaryColor` | `Color?` | Auto (lighter primary) | Secondary gradient color |
| `centerIcon` | `IconData?` | `Icons.check_circle_outline` | Center icon |
| `showPercentage` | `bool` | `true` | Show percentage text |
| `message` | `String?` | `null` | Optional message below indicator |
| `strokeWidth` | `double` | `8.0` | Width of the progress stroke |
| `animationDuration` | `Duration` | `1500ms` | Rotation animation duration |

---

## 🎨 Use Cases

### 1. Permission Loading Page
```dart
BlocBuilder<PermissionFlowCubit, PermissionFlowState>(
  builder: (context, state) {
    return CouponyLoadingIndicator(
      progress: state.loadingProgress,
      message: _getLoadingMessage(state.loadingProgress),
    );
  },
)
```

### 2. Onboarding Save Progress
```dart
BlocBuilder<OnboardingFlowCubit, OnboardingFlowState>(
  builder: (context, state) {
    if (state.isSaving) {
      return CouponyLoadingIndicator(
        progress: 0.0, // Indeterminate
        message: 'Saving preferences...',
        centerIcon: Icons.save,
      );
    }
    return YourContent();
  },
)
```

### 3. API Call Loading
```dart
FutureBuilder<Data>(
  future: apiCall(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CouponyLoadingIndicator(
        message: 'Fetching data...',
        centerIcon: Icons.cloud_download,
      );
    }
    return DataWidget(snapshot.data);
  },
)
```

### 4. File Upload Progress
```dart
StreamBuilder<double>(
  stream: uploadProgressStream,
  builder: (context, snapshot) {
    final progress = snapshot.data ?? 0.0;
    return CouponyLoadingIndicator(
      progress: progress,
      message: 'Uploading... ${(progress * 100).toInt()}%',
      centerIcon: Icons.upload,
    );
  },
)
```

---

## 🎭 Animation Details

### Rotation Animation
- **Type:** Continuous rotation
- **Duration:** 1500ms (customizable)
- **Curve:** Linear
- **Effect:** Smooth gradient rotation

### Pulse Animation
- **Type:** Scale transition
- **Duration:** 1000ms
- **Curve:** EaseInOut
- **Range:** 0.9 to 1.1
- **Effect:** Breathing effect for center icon

### Fade Animation
- **Type:** Opacity transition
- **Duration:** 500ms
- **Curve:** EaseIn
- **Trigger:** When message changes
- **Effect:** Smooth message transitions

---

## 🎨 Color Schemes

### Default (Orange)
```dart
CouponyLoadingIndicator(
  progress: 0.5,
  // Uses AppColors.primary (orange)
)
```

### Success (Green)
```dart
CouponyLoadingIndicator(
  progress: 1.0,
  primaryColor: Colors.green,
  secondaryColor: Colors.lightGreen,
  centerIcon: Icons.check_circle,
  message: 'Complete!',
)
```

### Error (Red)
```dart
CouponyLoadingIndicator(
  progress: 0.3,
  primaryColor: Colors.red,
  secondaryColor: Colors.redAccent,
  centerIcon: Icons.error_outline,
  message: 'Error occurred',
)
```

### Info (Blue)
```dart
CouponyLoadingIndicator(
  progress: 0.6,
  primaryColor: Colors.blue,
  secondaryColor: Colors.lightBlue,
  centerIcon: Icons.info_outline,
  message: 'Processing...',
)
```

---

## 🚀 Performance Tips

### 1. Use RepaintBoundary (Already Built-in)
The widget already uses `RepaintBoundary` internally for optimal performance.

### 2. Avoid Unnecessary Rebuilds
```dart
// ✅ Good: Only rebuild when progress changes
BlocBuilder<MyCubit, MyState>(
  buildWhen: (previous, current) => 
    previous.progress != current.progress,
  builder: (context, state) {
    return CouponyLoadingIndicator(progress: state.progress);
  },
)

// ❌ Bad: Rebuilds on every state change
BlocBuilder<MyCubit, MyState>(
  builder: (context, state) {
    return CouponyLoadingIndicator(progress: state.progress);
  },
)
```

### 3. Use const When Possible
```dart
// ✅ Good: Static loading
const CouponyLoadingIndicator(
  progress: 0.0,
  message: 'Loading...',
)
```

---

## 🎯 Best Practices

### 1. Message Guidelines
```dart
// ✅ Good: Short, clear messages
'Loading...'
'Saving preferences...'
'Almost done...'

// ❌ Bad: Long, unclear messages
'Please wait while we are loading your data from the server...'
```

### 2. Progress Updates
```dart
// ✅ Good: Smooth progress updates
setState(() {
  progress += 0.1; // Increment by 10%
});

// ❌ Bad: Jumpy progress
setState(() {
  progress = 1.0; // Instant jump to 100%
});
```

### 3. Icon Selection
```dart
// ✅ Good: Contextual icons
Icons.check_circle_outline  // General loading
Icons.download             // Downloading
Icons.upload               // Uploading
Icons.save                 // Saving
Icons.sync                 // Syncing

// ❌ Bad: Unrelated icons
Icons.home                 // Not related to loading
Icons.settings             // Confusing context
```

---

## 🐛 Troubleshooting

### Issue: Widget not animating
**Solution:** Ensure the widget is inside a StatefulWidget or has access to TickerProvider.

### Issue: Progress not updating
**Solution:** Make sure you're calling `setState()` or using a state management solution.

### Issue: Colors not showing
**Solution:** Check that `AppColors.primary` is properly defined in your theme.

### Issue: Size too small/large
**Solution:** Adjust the `size` parameter. Default is 120.0, try values between 80-200.

---

## 📚 Related Widgets

- `CircularProgressIndicator` - Flutter's built-in (simpler)
- `LinearProgressIndicator` - For horizontal progress bars
- `RefreshIndicator` - For pull-to-refresh

---

## 🎉 Credits

Created for the Coupony project as part of the Loading UI Overhaul (Phase 1).

**Features:**
- Custom painter for gradient circle
- Multiple animation controllers
- Optimized performance
- Fully responsive
- Highly customizable
