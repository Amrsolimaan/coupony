# Global Auth Role Migration Guide

## ✅ COMPLETED

### 1. Core Infrastructure
- ✅ Created `AuthRoleCubit` and `AuthRoleState`
- ✅ Registered `AuthRoleCubit` as lazySingleton in DI
- ✅ Refactored `RoleAnimationWrapper` to use `AuthRoleCubit`
- ✅ Refactored `RoleToggle` to use `AuthRoleCubit`
- ✅ Updated `splash_screen.dart` to initialize `AuthRoleCubit`
- ✅ Updated `login_screen.dart` to use `AuthRoleCubit`

## 🔄 REMAINING SCREENS TO UPDATE

### Pattern for Each Screen:

1. **Remove local `roleNotifier`**:
   ```dart
   // REMOVE THIS:
   final roleNotifier = useValueNotifier<String>('customer');
   ```

2. **Add AuthRoleCubit to providers** (if not already provided by parent):
   ```dart
   BlocProvider<AuthRoleCubit>.value(
     value: di.sl<AuthRoleCubit>(),
   ),
   ```

3. **Update RoleAnimationWrapper**:
   ```dart
   // OLD:
   RoleAnimationWrapper(
     roleNotifier: roleNotifier,
     child: ...
   )
   
   // NEW:
   RoleAnimationWrapper(
     child: ...
   )
   ```

4. **Update AnimatedLogoSwitcher**:
   ```dart
   // OLD:
   AnimatedLogoSwitcher(
     roleNotifier: roleNotifier,
     size: 100,
   )
   
   // NEW:
   AnimatedLogoSwitcher(
     size: 100,
   )
   ```

5. **Update RoleToggle**:
   ```dart
   // OLD:
   RoleToggle(
     roleNotifier: roleNotifier,
     userLabel: l10n.login_user_role,
     merchantLabel: l10n.login_merchant_role,
   )
   
   // NEW:
   RoleToggle(
     userLabel: l10n.login_user_role,
     merchantLabel: l10n.login_merchant_role,
   )
   ```

6. **Update AnimatedPrimaryColor**:
   ```dart
   // OLD:
   AnimatedPrimaryColor(
     roleNotifier: roleNotifier,
     builder: (context, primaryColor) { ... }
   )
   
   // NEW:
   AnimatedPrimaryColor(
     builder: (context, primaryColor) { ... }
   )
   ```

7. **Update role access in callbacks**:
   ```dart
   // OLD:
   role: roleNotifier.value
   
   // NEW:
   BlocBuilder<AuthRoleCubit, AuthRoleState>(
     builder: (context, roleState) {
       return SomeWidget(
         role: roleState.role,
       );
     },
   )
   ```

### Screens to Update:

1. ✅ `lib/features/auth/presentation/pages/login_screen.dart` - DONE
2. 🔄 `lib/features/auth/presentation/pages/register_screen.dart`
3. 🔄 `lib/features/auth/presentation/pages/forgot_password_screen.dart`
4. 🔄 `lib/features/auth/presentation/pages/otp_screen.dart`
5. 🔄 `lib/features/auth/presentation/pages/reset_password_screen.dart`
6. 🔄 Any other auth screens using `RoleAnimationWrapper`

### Special Cases:

#### Screens WITHOUT RoleToggle (like OTP, Reset Password):
- These screens should still wrap content in `RoleAnimationWrapper`
- They will automatically reflect the correct theme based on persisted role
- No toggle needed, just the wrapper for consistent theming

#### Example for OTP Screen:
```dart
// The screen will automatically show blue theme if role is 'merchant'
return Scaffold(
  body: RoleAnimationWrapper(
    child: YourContent(),
  ),
);
```

## 🎯 BENEFITS

1. **Global Persistence**: Role selection persists across all auth screens
2. **Consistent Theming**: All screens reflect the same role-based theme
3. **Single Source of Truth**: `AuthRoleCubit` manages role state globally
4. **Automatic Sync**: Changing role in one screen updates all screens
5. **Splash Screen Support**: Correct theme loads from app start

## 🔧 TESTING CHECKLIST

- [ ] Toggle role in Login → Navigate to Register → Verify theme persists
- [ ] Toggle role in Register → Navigate to Login → Verify theme persists
- [ ] Select Merchant → Close app → Reopen → Verify blue theme on splash
- [ ] Navigate through OTP/Reset flows → Verify consistent theming
- [ ] Test all auth screens show correct colors based on role
