# LoadingOverlay - Complete Integration Guide

## 📚 Table of Contents
1. [Overview](#overview)
2. [Basic Usage](#basic-usage)
3. [Integration with Bloc](#integration-with-bloc)
4. [Context-Aware Icons](#context-aware-icons)
5. [Templates for Common Scenarios](#templates)
6. [Best Practices](#best-practices)
7. [Examples](#examples)

---

## 🎯 Overview

`LoadingOverlay` is a reusable widget that displays a beautiful loading indicator with:
- ✨ Blur effect (BackdropFilter)
- 🚫 Modal barrier (prevents user interaction)
- 🎨 Context-aware icons
- 💬 Custom messages
- 📊 Progress tracking (optional)

---

## 📖 Basic Usage

### Simple Loading Overlay
```dart
import 'package:coupony/core/widgets/loading/loading.dart';

LoadingOverlay(
  isLoading: true,
  message: 'Loading...',
  child: YourScreenContent(),
)
```

### With Progress
```dart
LoadingOverlay(
  isLoading: true,
  progress: 0.65, // 65%
  message: 'Uploading...',
  icon: LoadingIcons.uploading,
  child: YourScreenContent(),
)
```

---

## 🔄 Integration with Bloc

### Pattern 1: BlocBuilder (Recommended)
```dart
BlocBuilder<MyCubit, MyState>(
  builder: (context, state) {
    return LoadingOverlay(
      isLoading: state.isSaving,
      message: 'Saving data...',
      icon: LoadingIcons.saving,
      child: YourScreenContent(),
    );
  },
)
```

### Pattern 2: BlocConsumer
```dart
BlocConsumer<MyCubit, MyState>(
  listener: (context, state) {
    // Handle navigation, snackbars, etc.
  },
  builder: (context, state) {
    return LoadingOverlay(
      isLoading: state.isLoading,
      message: _getLoadingMessage(state),
      icon: _getLoadingIcon(state),
      child: YourScreenContent(),
    );
  },
)
```

### Pattern 3: LoadingOverlayBuilder (Convenience)
```dart
BlocBuilder<MyCubit, MyState>(
  builder: (context, state) {
    return LoadingOverlayBuilder(
      isLoading: state.isSaving,
      message: 'Saving...',
      icon: LoadingIcons.saving,
      child: YourScreenContent(),
    );
  },
)
```

---

## 🎨 Context-Aware Icons

Use the `LoadingIcons` helper class for appropriate icons:

```dart
class LoadingIcons {
  static const saving = Icons.save_outlined;
  static const uploading = Icons.cloud_upload_outlined;
  static const downloading = Icons.cloud_download_outlined;
  static const syncing = Icons.sync;
  static const processing = Icons.settings_outlined;
  static const sending = Icons.send_outlined;
  static const loading = Icons.hourglass_empty;
  static const checking = Icons.check_circle_outline;
  static const searching = Icons.search;
  static const refreshing = Icons.refresh;
}
```

### Usage:
```dart
LoadingOverlay(
  isLoading: true,
  icon: LoadingIcons.saving,  // ✅ Context-aware
  message: 'Saving preferences...',
  child: YourContent(),
)
```

---

## 📋 Templates for Common Scenarios

### Template 1: Form Submission
```dart
class MyFormScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<FormCubit, FormState>(
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state.isSubmitting,
            message: 'Submitting form...',
            icon: LoadingIcons.sending,
            child: SafeArea(
              child: Column(
                children: [
                  // Your form fields
                  ElevatedButton(
                    onPressed: state.isSubmitting 
                      ? null 
                      : () => context.read<FormCubit>().submit(),
                    child: Text('Submit'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
```

### Template 2: Data Fetching
```dart
class DataListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<DataCubit, DataState>(
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state.isLoading,
            message: 'Loading data...',
            icon: LoadingIcons.loading,
            child: state.hasData
              ? ListView.builder(...)
              : EmptyStateWidget(),
          );
        },
      ),
    );
  }
}
```

### Template 3: File Upload with Progress
```dart
class UploadScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<UploadCubit, UploadState>(
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state.isUploading,
            progress: state.uploadProgress, // 0.0 to 1.0
            message: 'Uploading... ${(state.uploadProgress * 100).toInt()}%',
            icon: LoadingIcons.uploading,
            child: YourUploadUI(),
          );
        },
      ),
    );
  }
}
```

### Template 4: Onboarding (Already Implemented)
```dart
class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<OnboardingFlowCubit, OnboardingFlowState>(
        listener: (context, state) {
          // Handle navigation
        },
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state.isSaving,
            message: 'Saving preferences...',
            icon: LoadingIcons.saving,
            child: SafeArea(
              child: Column(
                children: [
                  // Onboarding content
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
```

### Template 5: Settings/Preferences
```dart
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state.isSaving,
            message: 'Saving settings...',
            icon: LoadingIcons.saving,
            child: ListView(
              children: [
                // Settings tiles
              ],
            ),
          );
        },
      ),
    );
  }
}
```

---

## ✅ Best Practices

### 1. Always Use Context-Aware Icons
```dart
// ✅ Good
LoadingOverlay(
  icon: LoadingIcons.saving,
  message: 'Saving...',
)

// ❌ Bad
LoadingOverlay(
  icon: Icons.home, // Not related to loading
  message: 'Saving...',
)
```

### 2. Keep Messages Short and Clear
```dart
// ✅ Good
'Saving preferences...'
'Uploading file...'
'Loading data...'

// ❌ Bad
'Please wait while we save your preferences to the database...'
```

### 3. Use Progress When Available
```dart
// ✅ Good: Show progress for determinate operations
LoadingOverlay(
  isLoading: true,
  progress: state.uploadProgress,
  message: 'Uploading...',
)

// ✅ Also Good: No progress for indeterminate operations
LoadingOverlay(
  isLoading: true,
  message: 'Processing...',
)
```

### 4. Disable Buttons During Loading
```dart
ElevatedButton(
  onPressed: state.isLoading ? null : () => doSomething(),
  child: Text('Submit'),
)
```

### 5. Use buildWhen to Optimize Rebuilds
```dart
BlocBuilder<MyCubit, MyState>(
  buildWhen: (previous, current) => 
    previous.isLoading != current.isLoading,
  builder: (context, state) {
    return LoadingOverlay(
      isLoading: state.isLoading,
      child: YourContent(),
    );
  },
)
```

---

## 📝 Examples

### Example 1: Login Screen
```dart
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.isAuthenticated) {
            context.go('/home');
          }
        },
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state.isLoading,
            message: 'Signing in...',
            icon: LoadingIcons.checking,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  children: [
                    TextField(/* email */),
                    TextField(/* password */),
                    ElevatedButton(
                      onPressed: state.isLoading 
                        ? null 
                        : () => context.read<AuthCubit>().login(),
                      child: Text('Login'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
```

### Example 2: Profile Update
```dart
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state.isUpdating,
            message: 'Updating profile...',
            icon: LoadingIcons.syncing,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  // Profile fields
                  ElevatedButton(
                    onPressed: state.isUpdating
                      ? null
                      : () => context.read<ProfileCubit>().update(),
                    child: Text('Save Changes'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
```

### Example 3: Search Screen
```dart
class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state.isSearching,
            message: 'Searching...',
            icon: LoadingIcons.searching,
            child: Column(
              children: [
                SearchBar(
                  onChanged: (query) => 
                    context.read<SearchCubit>().search(query),
                ),
                Expanded(
                  child: state.hasResults
                    ? ListView.builder(...)
                    : EmptySearchWidget(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

---

## 🎨 Customization Options

### Custom Blur Intensity
```dart
LoadingOverlay(
  isLoading: true,
  blurIntensity: 10.0, // Default: 5.0
  child: YourContent(),
)
```

### Custom Background Opacity
```dart
LoadingOverlay(
  isLoading: true,
  backgroundOpacity: 0.5, // Default: 0.3
  child: YourContent(),
)
```

### Custom Indicator Size
```dart
LoadingOverlay(
  isLoading: true,
  indicatorSize: 150.0, // Default: 120.0
  child: YourContent(),
)
```

---

## 🐛 Troubleshooting

### Issue: Overlay not showing
**Solution:** Ensure `isLoading` is actually `true` in your state.

### Issue: Can still tap through overlay
**Solution:** The modal barrier should prevent this. Check if you're using the correct widget structure.

### Issue: Blur effect not visible
**Solution:** Increase `blurIntensity` or check if the background has enough contrast.

### Issue: Performance issues
**Solution:** Use `buildWhen` in BlocBuilder to prevent unnecessary rebuilds.

---

## 🎉 Summary

`LoadingOverlay` provides a consistent, beautiful loading experience across your app:

✅ Easy to integrate with Bloc  
✅ Context-aware icons  
✅ Customizable appearance  
✅ Prevents user interaction during loading  
✅ Premium blur effect  
✅ Progress tracking support  

Use the templates provided to quickly integrate into any screen!
