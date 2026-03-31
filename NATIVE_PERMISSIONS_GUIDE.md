# Native Localization for OS Permissions

This guide shows how to implement native localization for permission dialogs on iOS and Android.

## iOS Implementation

### Files Created/Updated:
- `ios/Runner/Info.plist` - Added Camera, Photo Library, and Microphone permission keys
- `ios/Runner/en.lproj/InfoPlist.strings` - English translations
- `ios/Runner/ar.lproj/InfoPlist.strings` - Arabic translations

### How It Works:
iOS automatically uses the localized strings from `InfoPlist.strings` based on the device's system language. The keys in `Info.plist` serve as fallback values.

### Permission Keys Added:
```xml
<!-- Camera & Photo Library - For Store Logo Selection -->
<key>NSPhotoLibraryUsageDescription</key>
<key>NSCameraUsageDescription</key>
<key>NSPhotoLibraryAddUsageDescription</key>

<!-- Microphone - For Voice Search -->
<key>NSMicrophoneUsageDescription</key>
```

## Android Implementation

### Files Created:
- `android/app/src/main/res/values/strings.xml` - English strings
- `android/app/src/main/res/values-ar/strings.xml` - Arabic strings

### How to Use in AndroidManifest.xml:

For runtime permissions (Camera, Gallery, Microphone), Android doesn't show system dialogs with custom messages like iOS. However, you can use these strings in your Flutter permission request UI.

If you're using a permission plugin that supports custom rationale messages, reference them like this in your Dart code:

```dart
// Example with permission_handler package
await Permission.camera.request();
// The rationale can be shown in your own UI before requesting
```

### String Resources Available:
```xml
@string/permission_camera_description
@string/permission_gallery_description
@string/permission_location_description
@string/permission_microphone_description
```

## Testing

### iOS:
1. Change device language: Settings > General > Language & Region
2. Run the app and trigger permission requests
3. Verify dialogs appear in the correct language

### Android:
1. Change device language: Settings > System > Languages
2. The app will use the appropriate `values-ar` or `values` folder
3. Use the string resources in your Flutter UI for permission rationales

## Notes:
- iOS permission dialogs are system-level and automatically localized
- Android runtime permissions don't show custom messages in system dialogs
- For Android, use these strings in your app's permission rationale UI before requesting permissions
