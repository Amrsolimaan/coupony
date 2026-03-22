# Cubit Localization Refactoring Guide
## Error Key Pattern Implementation

**Date**: 2026-03-21  
**Status**: ✅ ARB FILES UPDATED - CUBIT REFACTORING PENDING  
**Pattern**: Error Key Pattern for full i18n support

---

## Overview

This guide provides a complete refactoring plan to replace hardcoded Arabic strings in Cubits with translation keys, enabling full localization support.

---

## Phase 1: ARB Files Updated ✅

### New Translation Keys Added

#### Permission Flow Error Keys:

```json
// Location Errors
"error_location_position_failed": "Could not determine your current location. Make sure GPS is enabled"
"error_location_service_disabled": "Please enable location service (GPS) from device settings"
"error_location_unexpected": "An unexpected error occurred. Please try again"
"error_location_gps_check_failed": "Failed to check GPS status"
"error_location_weak_signal": "Could not determine your location. Make sure you have a strong GPS signal"
"error_location_use_current_failed": "Could not determine your location. Make sure GPS is enabled and try again"

// Settings Errors
"error_settings_open_failed": "Failed to open settings"
"error_settings_app_open_failed": "Failed to open app settings"

// Notification Errors
"error_notification_unexpected": "An unexpected error occurred"
"error_notification_settings_failed": "Failed to open settings"

// Success Messages
"success_location_gps_enabled": "After enabling GPS, return to the app and press Try Again"
"success_location_settings_opened": "After allowing location access, return to the app and press Try Again"

// Info Messages
"info_location_settings_manual": "Could not open settings. Open device settings manually and enable location"
"info_location_app_settings_manual": "Could not open settings. Open device settings manually and grant location permission to the app"
"info_notification_settings_manual": "Could not open settings. Open device settings manually and enable notifications"
```

#### Onboarding Flow Keys:

```json
// Success Messages
"success_onboarding_preferences_saved": "Your preferences have been saved successfully"
"success_onboarding_categories_updated": "Categories updated successfully"
"success_onboarding_budget_updated": "Budget updated successfully"
"success_onboarding_styles_updated": "Shopping style updated successfully"
"success_onboarding_all_updated": "All your preferences have been updated successfully"

// Error Messages
"error_onboarding_step1_incomplete": "Please select at least one category"
"error_onboarding_step2_incomplete": "Please select your budget preference"
"error_onboarding_step3_incomplete": "Please select at least one shopping style"
```

---

## Phase 2: State Classes Refactoring

### 2.1 PermissionFlowState

**File**: `lib/features/permissions/presentation/cubit/permission_flow_state.dart`

#### Current Structure:
```dart
class PermissionFlowState extends Equatable {
  final String? errorMessage; // ❌ Contains hardcoded Arabic text
  // ... other fields
}
```

#### Refactored Structure:
```dart
class PermissionFlowState extends Equatable {
  final String? messageKey; // ✅ Translation key (e.g., 'error_location_position_failed')
  final MessageType? messageType; // ✅ error, success, info
  // ... other fields
}

enum MessageType {
  error,
  success,
  info,
}
```

#### Changes Required:

1. **Rename Field**:
   ```dart
   // OLD
   final String? errorMessage;
   
   // NEW
   final String? messageKey;
   final MessageType? messageType;
   ```

2. **Update copyWith**:
   ```dart
   PermissionFlowState copyWith({
     // OLD
     String? errorMessage,
     
     // NEW
     String? messageKey,
     MessageType? messageType,
     // ... other params
   }) {
     return PermissionFlowState(
       // OLD
       errorMessage: errorMessage,
       
       // NEW
       messageKey: messageKey,
       messageType: messageType,
       // ... other fields
     );
   }
   ```

3. **Update props**:
   ```dart
   @override
   List<Object?> get props => [
     // OLD
     errorMessage,
     
     // NEW
     messageKey,
     messageType,
     // ... other props
   ];
   ```

---

### 2.2 OnboardingFlowState

**File**: `lib/features/onboarding/presentation/cubit/onboarding_flow_state.dart`

#### Current Structure:
```dart
class OnboardingFlowState extends Equatable {
  final String? saveError; // ❌ Contains hardcoded Arabic text
  final String? saveSuccessMessage; // ❌ Contains hardcoded Arabic text
  // ... other fields
}
```

#### Refactored Structure:
```dart
class OnboardingFlowState extends Equatable {
  final String? errorMessageKey; // ✅ Translation key for errors
  final String? successMessageKey; // ✅ Translation key for success
  // ... other fields
}
```

#### Changes Required:

1. **Rename Fields**:
   ```dart
   // OLD
   final String? saveError;
   final String? saveSuccessMessage;
   
   // NEW
   final String? errorMessageKey;
   final String? successMessageKey;
   ```

2. **Update copyWith**:
   ```dart
   OnboardingFlowState copyWith({
     // OLD
     String? saveError,
     String? saveSuccessMessage,
     
     // NEW
     String? errorMessageKey,
     String? successMessageKey,
     // ... other params
   }) {
     return OnboardingFlowState(
       // OLD
       saveError: saveError,
       saveSuccessMessage: saveSuccessMessage,
       
       // NEW
       errorMessageKey: errorMessageKey,
       successMessageKey: successMessageKey,
       // ... other fields
     );
   }
   ```

3. **Update props**:
   ```dart
   @override
   List<Object?> get props => [
     // OLD
     saveError,
     saveSuccessMessage,
     
     // NEW
     errorMessageKey,
     successMessageKey,
     // ... other props
   ];
   ```

---

## Phase 3: Cubit Refactoring

### 3.1 PermissionFlowCubit

**File**: `lib/features/permissions/presentation/cubit/permission_flow_cubit.dart`

#### Critical Messages to Refactor (10 instances):

| Line | Old Hardcoded Message | New Message Key | Type |
|------|----------------------|-----------------|------|
| 206 | `'تعذر تحديد موقعك الحالي. تأكد من تفعيل GPS'` | `error_location_position_failed` | error |
| 217 | `'يرجى تفعيل خدمة الموقع (GPS) من إعدادات الجهاز'` | `error_location_service_disabled` | error |
| 241 | `'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى'` | `error_location_unexpected` | error |
| 588 | `'تعذر تحديد موقعك. تأكد من تفعيل GPS وحاول مرة أخرى'` | `error_location_use_current_failed` | error |
| 609 | `'تعذر التحقق من حالة GPS'` | `error_location_gps_check_failed` | error |
| 661 | `'تعذر تحديد موقعك. تأكد من وجود إشارة GPS قوية'` | `error_location_weak_signal` | error |
| 693 | `'تعذر فتح الإعدادات'` | `error_settings_open_failed` | error |
| 723 | `'تعذر فتح إعدادات التطبيق'` | `error_settings_app_open_failed` | error |
| 815 | `'حدث خطأ غير متوقع'` | `error_notification_unexpected` | error |
| 842 | `'تعذر فتح الإعدادات'` | `error_notification_settings_failed` | error |

#### Refactoring Examples:

**Example 1: Simple Error Message**

```dart
// ❌ OLD (Line 206)
_safeEmit(
  state.copyWith(
    errorMessage: 'تعذر تحديد موقعك الحالي. تأكد من تفعيل GPS',
    navSignal: PermissionNavigationSignal.toLocationError,
  ),
);

// ✅ NEW
_safeEmit(
  state.copyWith(
    messageKey: 'error_location_position_failed',
    messageType: MessageType.error,
    navSignal: PermissionNavigationSignal.toLocationError,
  ),
);
```

**Example 2: Success Message**

```dart
// ❌ OLD (Line 699)
_safeEmit(
  state.copyWith(
    errorMessage: 'بعد تفعيل GPS، ارجع للتطبيق واضغط محاولة مرة أخرى',
  ),
);

// ✅ NEW
_safeEmit(
  state.copyWith(
    messageKey: 'success_location_gps_enabled',
    messageType: MessageType.success,
  ),
);
```

**Example 3: Info Message**

```dart
// ❌ OLD (Line 735)
_safeEmit(
  state.copyWith(
    errorMessage: 'تعذر فتح الإعدادات. افتح إعدادات الجهاز يدوياً وفعّل الموقع',
  ),
);

// ✅ NEW
_safeEmit(
  state.copyWith(
    messageKey: 'info_location_settings_manual',
    messageType: MessageType.info,
  ),
);
```

---

### 3.2 OnboardingFlowCubit

**File**: `lib/features/onboarding/presentation/cubit/onboarding_flow_cubit.dart`

#### Critical Messages to Refactor (8 instances):

| Method | Old Hardcoded Message | New Message Key | Type |
|--------|----------------------|-----------------|------|
| `saveProgress()` | Dynamic success messages | `success_onboarding_*` | success |
| `submitOnboarding()` | `'Please select at least one category'` | `error_onboarding_step1_incomplete` | error |
| `submitOnboarding()` | `'Please select your budget preference'` | `error_onboarding_step2_incomplete` | error |
| `submitOnboarding()` | `'Please select at least one shopping style'` | `error_onboarding_step3_incomplete` | error |
| `_generateSuccessMessage()` | `'تم حفظ اختياراتك بنجاح'` | `success_onboarding_preferences_saved` | success |
| `_generateSuccessMessage()` | `'تم تحديث التصنيفات بنجاح'` | `success_onboarding_categories_updated` | success |
| `_generateSuccessMessage()` | `'تم تحديث الميزانية بنجاح'` | `success_onboarding_budget_updated` | success |
| `_generateSuccessMessage()` | `'تم تحديث أسلوب التسوق بنجاح'` | `success_onboarding_styles_updated` | success |

#### Refactoring Examples:

**Example 1: Validation Error**

```dart
// ❌ OLD
if (!state.isStep1Valid) {
  logger.w('Cannot submit: Step 1 incomplete');
  _safeEmit(state.copyWith(saveError: 'Please select at least one category'));
  return;
}

// ✅ NEW
if (!state.isStep1Valid) {
  logger.w('Cannot submit: Step 1 incomplete');
  _safeEmit(state.copyWith(errorMessageKey: 'error_onboarding_step1_incomplete'));
  return;
}
```

**Example 2: Dynamic Success Message**

```dart
// ❌ OLD
String _generateSuccessMessage(List<String> changes, bool hasAnyChanges) {
  if (!hasAnyChanges) {
    return 'تم حفظ اختياراتك بنجاح';
  }
  
  final changeMessages = <String>[];
  if (changes.contains('categories')) {
    changeMessages.add('التصنيفات');
  }
  // ... more logic
  
  if (changeMessages.length == 1) {
    return 'تم تحديث ${changeMessages.first} بنجاح';
  }
  // ... more logic
}

// ✅ NEW
String _generateSuccessMessageKey(List<String> changes, bool hasAnyChanges) {
  if (!hasAnyChanges) {
    return 'success_onboarding_preferences_saved';
  }
  
  if (changes.length == 1) {
    if (changes.contains('categories')) {
      return 'success_onboarding_categories_updated';
    } else if (changes.contains('budget')) {
      return 'success_onboarding_budget_updated';
    } else if (changes.contains('shopping_styles')) {
      return 'success_onboarding_styles_updated';
    }
  }
  
  // Multiple changes
  return 'success_onboarding_all_updated';
}
```

**Example 3: Save Success**

```dart
// ❌ OLD
_safeEmit(
  state.copyWith(
    isSaving: false,
    saveError: null,
    saveSuccessMessage: successMessage, // Hardcoded Arabic
    hasChanges: false,
  ),
);

// ✅ NEW
_safeEmit(
  state.copyWith(
    isSaving: false,
    errorMessageKey: null,
    successMessageKey: successMessageKey, // Translation key
    hasChanges: false,
  ),
);
```

---

## Phase 4: UI Integration

### 4.1 How to Display Messages in UI

#### Pattern 1: BlocListener for Snackbars/Toasts

```dart
BlocListener<PermissionFlowCubit, PermissionFlowState>(
  listener: (context, state) {
    if (state.messageKey != null) {
      final l10n = AppLocalizations.of(context)!;
      final message = _getLocalizedMessage(l10n, state.messageKey!);
      
      // Show snackbar based on message type
      final color = state.messageType == MessageType.error
          ? AppColors.error
          : state.messageType == MessageType.success
              ? AppColors.success
              : AppColors.info;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
        ),
      );
    }
  },
  child: YourWidget(),
)
```

#### Pattern 2: Direct Display in Widget

```dart
BlocBuilder<PermissionFlowCubit, PermissionFlowState>(
  builder: (context, state) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      children: [
        if (state.messageKey != null)
          Container(
            padding: EdgeInsets.all(16),
            color: state.messageType == MessageType.error
                ? AppColors.errorLight
                : AppColors.successLight,
            child: Text(
              _getLocalizedMessage(l10n, state.messageKey!),
              style: AppTextStyles.bodyMedium,
            ),
          ),
        // ... other widgets
      ],
    );
  },
)
```

#### Helper Method for Message Retrieval:

```dart
String _getLocalizedMessage(AppLocalizations l10n, String messageKey) {
  // Use reflection or a map to get the message
  switch (messageKey) {
    case 'error_location_position_failed':
      return l10n.error_location_position_failed;
    case 'error_location_service_disabled':
      return l10n.error_location_service_disabled;
    case 'error_location_unexpected':
      return l10n.error_location_unexpected;
    // ... add all other keys
    default:
      return l10n.unexpectedError; // Fallback
  }
}
```

#### Better Approach: Extension Method

```dart
// lib/core/localization/message_key_extension.dart
extension MessageKeyExtension on AppLocalizations {
  String getMessage(String key) {
    switch (key) {
      // Permission errors
      case 'error_location_position_failed':
        return error_location_position_failed;
      case 'error_location_service_disabled':
        return error_location_service_disabled;
      case 'error_location_unexpected':
        return error_location_unexpected;
      case 'error_location_gps_check_failed':
        return error_location_gps_check_failed;
      case 'error_location_weak_signal':
        return error_location_weak_signal;
      case 'error_location_use_current_failed':
        return error_location_use_current_failed;
      case 'error_settings_open_failed':
        return error_settings_open_failed;
      case 'error_settings_app_open_failed':
        return error_settings_app_open_failed;
      case 'error_notification_unexpected':
        return error_notification_unexpected;
      case 'error_notification_settings_failed':
        return error_notification_settings_failed;
      
      // Permission success
      case 'success_location_gps_enabled':
        return success_location_gps_enabled;
      case 'success_location_settings_opened':
        return success_location_settings_opened;
      
      // Permission info
      case 'info_location_settings_manual':
        return info_location_settings_manual;
      case 'info_location_app_settings_manual':
        return info_location_app_settings_manual;
      case 'info_notification_settings_manual':
        return info_notification_settings_manual;
      
      // Onboarding success
      case 'success_onboarding_preferences_saved':
        return success_onboarding_preferences_saved;
      case 'success_onboarding_categories_updated':
        return success_onboarding_categories_updated;
      case 'success_onboarding_budget_updated':
        return success_onboarding_budget_updated;
      case 'success_onboarding_styles_updated':
        return success_onboarding_styles_updated;
      case 'success_onboarding_all_updated':
        return success_onboarding_all_updated;
      
      // Onboarding errors
      case 'error_onboarding_step1_incomplete':
        return error_onboarding_step1_incomplete;
      case 'error_onboarding_step2_incomplete':
        return error_onboarding_step2_incomplete;
      case 'error_onboarding_step3_incomplete':
        return error_onboarding_step3_incomplete;
      
      // Fallback
      default:
        return unexpectedError;
    }
  }
}
```

#### Usage in UI:

```dart
// Simple and clean!
final l10n = AppLocalizations.of(context)!;
final message = l10n.getMessage(state.messageKey!);

Text(message);
```

---

## Phase 5: Naming Convention

### Pattern: `{feature}_{action}_{status}`

#### Examples:

- **Permission Errors**: `error_location_position_failed`
- **Permission Success**: `success_location_gps_enabled`
- **Permission Info**: `info_location_settings_manual`
- **Onboarding Errors**: `error_onboarding_step1_incomplete`
- **Onboarding Success**: `success_onboarding_categories_updated`

### Rules:

1. **Prefix**: Always start with message type (`error_`, `success_`, `info_`)
2. **Feature**: Add feature name (`location_`, `notification_`, `onboarding_`)
3. **Action**: Describe what happened (`position_failed`, `gps_enabled`, `step1_incomplete`)
4. **Consistency**: Use snake_case for all keys
5. **Clarity**: Key should be self-explanatory

---

## Phase 6: Migration Checklist

### Step 1: Update State Classes ✅
- [ ] Add `messageKey` field to `PermissionFlowState`
- [ ] Add `messageType` enum to `PermissionFlowState`
- [ ] Rename `saveError` to `errorMessageKey` in `OnboardingFlowState`
- [ ] Rename `saveSuccessMessage` to `successMessageKey` in `OnboardingFlowState`
- [ ] Update `copyWith` methods
- [ ] Update `props` lists

### Step 2: Update Cubits ✅
- [ ] Replace all hardcoded messages in `PermissionFlowCubit` (10 instances)
- [ ] Replace all hardcoded messages in `OnboardingFlowCubit` (8 instances)
- [ ] Update `_generateSuccessMessage` to return keys instead of strings
- [ ] Test all error scenarios

### Step 3: Create Extension Method ✅
- [ ] Create `lib/core/localization/message_key_extension.dart`
- [ ] Add `getMessage()` extension method
- [ ] Add all message keys to switch statement

### Step 4: Update UI ✅
- [ ] Update all pages that display error messages
- [ ] Update all pages that display success messages
- [ ] Use `l10n.getMessage(state.messageKey!)` pattern
- [ ] Test language switching

### Step 5: Testing ✅
- [ ] Test all error scenarios in both languages
- [ ] Test all success scenarios in both languages
- [ ] Test language switching with active messages
- [ ] Verify no hardcoded strings remain

---

## Benefits of This Approach

### 1. Full Localization Support ✅
- All messages automatically translated
- No hardcoded strings in business logic
- Easy to add new languages

### 2. Consistency ✅
- Standardized naming convention
- Centralized message management
- Type-safe message keys

### 3. Maintainability ✅
- Easy to update messages
- Single source of truth (ARB files)
- Clear separation of concerns

### 4. Testability ✅
- Can test message keys without language dependency
- Mock localization easily
- Verify correct keys are emitted

### 5. Scalability ✅
- Easy to add new messages
- Pattern can be applied to all features
- Supports complex message scenarios

---

## Example: Complete Flow

### 1. User Action Triggers Error

```dart
// In Cubit
Future<void> requestLocationPermission() async {
  // ... logic
  
  if (permissionDenied) {
    _safeEmit(
      state.copyWith(
        messageKey: 'error_location_position_failed',
        messageType: MessageType.error,
      ),
    );
  }
}
```

### 2. UI Listens to State Change

```dart
BlocListener<PermissionFlowCubit, PermissionFlowState>(
  listener: (context, state) {
    if (state.messageKey != null) {
      final l10n = AppLocalizations.of(context)!;
      final message = l10n.getMessage(state.messageKey!);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  },
  child: MyPage(),
)
```

### 3. Message Displayed in User's Language

- **Arabic**: "تعذر تحديد موقعك الحالي. تأكد من تفعيل GPS"
- **English**: "Could not determine your current location. Make sure GPS is enabled"

---

## Conclusion

✅ ARB files updated with 26 new translation keys  
✅ Naming convention established  
✅ Refactoring pattern documented  
✅ UI integration examples provided  
✅ Extension method pattern recommended  

**Next Steps**:
1. Update State classes
2. Refactor Cubits to use message keys
3. Create extension method
4. Update UI to display localized messages
5. Test thoroughly in both languages

This refactoring will make the app fully localizable and maintainable for future language additions.
