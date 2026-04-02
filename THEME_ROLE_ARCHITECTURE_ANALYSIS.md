# 🏗️ THEME-ROLE ARCHITECTURE ANALYSIS & REFACTOR ROADMAP

**Senior Lead Flutter Architect Report**  
**Date:** April 1, 2026  
**Objective:** Deconstruct Theme-Role coupling and design a Clean Unified System

---

## 📋 EXECUTIVE SUMMARY

The current architecture suffers from **THREE CRITICAL FLAWS**:

1. **Onboarding Dependency Leak**: `CouponyThemeProvider` is tightly coupled to `OnboardingUserType` from the CustomerOnboarding feature
2. **Isolated Login Toggle**: Role changes in Login/Register screens don't propagate to OTP/ResetPassword screens
3. **Dual Theme Systems**: Two parallel systems exist (`CouponyThemeProvider` vs `AnimatedPrimaryColor`) causing inconsistency

**Impact**: Theme colors are NOT truly global, leading to broken UX when users switch roles.

---

## 🔍 PHASE 1: THE "ONBOARDING" GHOST CONNECTION

### Current Architecture Flaw

**File:** `lib/core/widgets/providers_theme/coupony_theme_provider.dart`

```dart
import 'package:coupony/features/CustomerOnboarding/domain/entities/onboarding_user_type.dart';

class CouponyThemeProvider {
  final OnboardingUserType userType;  // ❌ FEATURE-SPECIFIC TYPE IN CORE!
  
  Color get primaryColor {
    return userType == OnboardingUserType.seller
        ? AppColors.primaryOfSeller
        : AppColors.primary;
  }
}
```

### The Circular Dependency Problem


**Dependency Flow:**
```
core/widgets/providers_theme/coupony_theme_provider.dart
    ↓ IMPORTS
features/CustomerOnboarding/domain/entities/onboarding_user_type.dart
```

**Why This Is Wrong:**

1. **Violation of Clean Architecture**: Core layer depends on Feature layer
2. **Prevents Reusability**: `CouponyThemeProvider` cannot be used outside Onboarding context
3. **Tight Coupling**: Changes to Onboarding feature can break core theming
4. **Semantic Mismatch**: "Onboarding" is a temporary flow, but Theme is app-wide

**The "Ghost Connection":**

`OnboardingUserType` is defined in the CustomerOnboarding feature:
```dart
enum OnboardingUserType {
  customer,
  seller;
  
  static OnboardingUserType fromRole(String? role) {
    return role == 'merchant' ? seller : customer;
  }
}
```

This enum should NOT exist in a feature module—it represents a GLOBAL user classification.

---

## 🔍 PHASE 2: THE LOGIN CONTROL ANALYSIS

### Current Role Management System

**Global State:** `AuthRoleCubit` (✅ Correctly implemented)
- Location: `lib/features/auth/presentation/cubit/auth_role_cubit.dart`
- Persists role to SecureStorage
- Provides global role state across auth screens


**Role Toggle Widget:** `RoleToggle` (✅ Correctly uses AuthRoleCubit)
```dart
// lib/features/auth/presentation/widgets/role_toggle.dart
RoleToggle(
  userLabel: l10n.login_user_role,
  merchantLabel: l10n.login_merchant_role,
)

// Internally updates AuthRoleCubit:
onTap: () => context.read<AuthRoleCubit>().setRole('customer'),
```

### The Animation System (✅ Working Correctly)

**File:** `lib/features/auth/presentation/widgets/role_animation_wrapper.dart`

Three animation widgets exist:
1. `RoleAnimationWrapper` - Blur + theme transition
2. `AnimatedLogoSwitcher` - Logo morph animation
3. `AnimatedPrimaryColor` - Color interpolation

**All three correctly listen to `AuthRoleCubit`:**
```dart
BlocBuilder<AuthRoleCubit, AuthRoleState>(
  builder: (context, roleState) {
    // Animation updates when roleState changes
  },
)
```

### Why Login Toggle WORKS in Login/Register

**Login Screen:**
```dart
// ✅ Provides AuthRoleCubit
BlocProvider<AuthRoleCubit>.value(
  value: di.sl<AuthRoleCubit>(),
),

// ✅ Wraps content in RoleAnimationWrapper
RoleAnimationWrapper(
  child: SingleChildScrollView(...),
)

// ✅ Uses AnimatedPrimaryColor for buttons
AnimatedPrimaryColor(
  builder: (context, primaryColor) {
    return AppPrimaryButton(
      backgroundColor: primaryColor,
    );
  },
)
```


**Register Screen:** Same pattern—works correctly.

### Why Toggle FAILS in OTP/ResetPassword Screens

**OTP Screen Analysis:**
```dart
// ❌ NO BlocProvider for AuthRoleCubit!
// ❌ NO RoleAnimationWrapper!
// ❌ Role passed as constructor parameter (static, not reactive)

class OtpScreen extends HookWidget {
  final String role;  // ❌ Static string, doesn't update
  
  const OtpScreen({
    this.role = 'customer',  // ❌ Defaults to customer
  });
  
  @override
  Widget build(BuildContext context) {
    // ❌ Hardcoded color based on constructor parameter
    final primaryColor = role == 'merchant'
        ? AppColors.primaryOfSeller
        : AppColors.primary;
    
    // Button uses static color
    AppPrimaryButton(
      backgroundColor: primaryColor,  // ❌ Never updates
    );
  }
}
```

**ResetPassword Screen Analysis:**
```dart
// ❌ Same problem—role is constructor parameter
class ResetPasswordScreen extends HookWidget {
  final String role;
  
  const ResetPasswordScreen({
    this.role = 'customer',  // ❌ Static
  });
  
  @override
  Widget build(BuildContext context) {
    // ❌ Hardcoded color
    final primaryColor = role == 'merchant'
        ? AppColors.primaryOfSeller
        : AppColors.primary;
  }
}
```


### Root Cause Analysis

**The Problem:**
1. OTP and ResetPassword screens receive `role` as a route parameter
2. This parameter is set ONCE when navigating from Login/Register
3. If user changes role AFTER navigation, the parameter doesn't update
4. Screens don't listen to `AuthRoleCubit`, so they can't react to changes

**Navigation Flow:**
```
LoginScreen (role: customer)
  → User toggles to merchant
  → AuthRoleCubit updates to 'merchant'
  → User clicks "Forgot Password"
  → Navigates to ForgotPasswordScreen
  → ForgotPasswordScreen sends OTP
  → Navigates to OtpScreen(role: 'merchant')  ✅ Correct at this moment
  
BUT:
  → User goes back to Login
  → User toggles to customer
  → AuthRoleCubit updates to 'customer'
  → OtpScreen still shows merchant colors  ❌ BROKEN
```

---

## 🔍 PHASE 3: THE UNIFICATION STRATEGY

### Step 1: Decouple UserType from Onboarding

**Goal:** Move role definition to core layer

**Action Plan:**

1. Create `lib/core/domain/enums/user_role.dart`:
```dart
enum UserRole {
  customer,
  merchant;
  
  static UserRole fromString(String? role) {
    return role == 'merchant' ? merchant : customer;
  }
  
  String toApiString() => this == merchant ? 'merchant' : 'customer';
}
```


2. Update `CouponyThemeProvider` to use `UserRole`:
```dart
import 'package:coupony/core/domain/enums/user_role.dart';

class CouponyThemeProvider {
  final UserRole userRole;  // ✅ Core enum, not feature-specific
  
  const CouponyThemeProvider(this.userRole);
  
  Color get primaryColor {
    return userRole == UserRole.merchant
        ? AppColors.primaryOfSeller
        : AppColors.primary;
  }
}
```

3. Deprecate `OnboardingUserType` and create adapter:
```dart
// In onboarding feature
extension OnboardingUserTypeAdapter on UserRole {
  String get apiSegment => this == UserRole.merchant ? 'seller' : 'customer';
}
```

**Benefits:**
- ✅ Core layer no longer depends on feature layer
- ✅ `UserRole` can be used across entire app
- ✅ Onboarding feature adapts to core enum

---

### Step 2: Centralize Theme Management

**Goal:** Make `AuthRoleCubit` the single source of truth for ALL screens

**Current Problem:**
- `AuthRoleCubit` exists but isn't provided at app root
- Each screen manually provides it via `BlocProvider.value`
- OTP/ResetPassword screens don't provide it at all

**Solution: Elevate AuthRoleCubit to App Root**


**Update `lib/app.dart`:**
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            // ✅ ADD AuthRoleCubit at root level
            BlocProvider<AuthRoleCubit>(
              create: (context) => sl<AuthRoleCubit>()..loadPersistedRole(),
            ),
            BlocProvider<LocaleCubit>(create: (context) => sl<LocaleCubit>()),
            BlocProvider<OnboardingFlowCubit>(
              create: (context) => sl<OnboardingFlowCubit>(),
            ),
            BlocProvider<PermissionFlowCubit>(
              create: (context) => sl<PermissionFlowCubit>(),
            ),
          ],
          child: GlobalNetworkListener(child: const AppView()),
        );
      },
    );
  }
}
```

**Benefits:**
- ✅ `AuthRoleCubit` available in EVERY screen
- ✅ No need to manually provide in each auth screen
- ✅ Role persists across entire app lifecycle

---

### Step 3: Reactive Flow Implementation

**Goal:** Ensure ALL screens react to role changes instantly

**3.1: Remove Static Role Parameters**

**OTP Screen Refactor:**
```dart
// ❌ BEFORE
class OtpScreen extends HookWidget {
  final String role;  // Static parameter
  
  const OtpScreen({this.role = 'customer'});
  
  @override
  Widget build(BuildContext context) {
    final primaryColor = role == 'merchant'
        ? AppColors.primaryOfSeller
        : AppColors.primary;
  }
}
```


```dart
// ✅ AFTER
class OtpScreen extends HookWidget {
  // ✅ Remove role parameter entirely
  
  const OtpScreen({
    required this.email,
    required this.mode,
    this.maskedRecipient,
    this.expiryMinutes,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // ✅ Wrap in RoleAnimationWrapper
        child: RoleAnimationWrapper(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ✅ Use AnimatedPrimaryColor
                AnimatedPrimaryColor(
                  builder: (context, primaryColor) {
                    return AppPrimaryButton(
                      backgroundColor: primaryColor,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

**ResetPassword Screen Refactor:**
```dart
// ❌ BEFORE
class ResetPasswordScreen extends HookWidget {
  final String role;
  
  const ResetPasswordScreen({
    required this.email,
    required this.token,
    this.role = 'customer',
  });
}
```


```dart
// ✅ AFTER
class ResetPasswordScreen extends HookWidget {
  // ✅ Remove role parameter
  
  const ResetPasswordScreen({
    required this.email,
    required this.token,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ✅ Use AnimatedPrimaryColor
              AnimatedPrimaryColor(
                builder: (context, primaryColor) {
                  return AppPrimaryButton(
                    backgroundColor: primaryColor,
                  );
                },
              ),
              
              // ✅ Use AnimatedPrimaryColor for strength meter
              AnimatedPrimaryColor(
                builder: (context, primaryColor) {
                  return _PasswordStrengthMeter(
                    strength: state.passwordStrength,
                    primaryColor: primaryColor,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**3.2: Update Route Definitions**

**File:** `lib/config/routes/app_router.dart`

```dart
// ❌ BEFORE
GoRoute(
  path: '/otp',
  builder: (context, state) {
    final extra = state.extra as Map<String, String>;
    return OtpScreen(
      email: extra['email'] ?? '',
      role: extra['role'] ?? 'customer',  // ❌ Passing static role
    );
  },
),
```


```dart
// ✅ AFTER
GoRoute(
  path: '/otp',
  builder: (context, state) {
    final extra = state.extra as Map<String, String>;
    return OtpScreen(
      email: extra['email'] ?? '',
      // ✅ No role parameter—screen reads from AuthRoleCubit
    );
  },
),

GoRoute(
  path: '/reset-password',
  builder: (context, state) {
    final extra = state.extra as Map<String, String>;
    return ResetPasswordScreen(
      email: extra['email'] ?? '',
      token: extra['token'] ?? '',
      // ✅ No role parameter
    );
  },
),
```

**3.3: Update Navigation Calls**

**ForgotPasswordScreen → OtpScreen:**
```dart
// ❌ BEFORE
context.push(AppRouter.otpVerification, extra: {
  'email': email,
  'role': context.read<AuthRoleCubit>().state.role,  // ❌ Passing static role
});

// ✅ AFTER
context.push(AppRouter.otpVerification, extra: {
  'email': email,
  // ✅ No role—OtpScreen reads from AuthRoleCubit directly
});
```

**OtpScreen → ResetPasswordScreen:**
```dart
// ❌ BEFORE
context.push(AppRouter.resetPassword, extra: {
  'email': email,
  'token': state.resetToken ?? '',
  'role': role,  // ❌ Forwarding static role
});

// ✅ AFTER
context.push(AppRouter.resetPassword, extra: {
  'email': email,
  'token': state.resetToken ?? '',
  // ✅ No role
});
```


---

## 📊 IMPACT ANALYSIS

### Before Refactor (Current State)

| Screen | AuthRoleCubit | RoleAnimationWrapper | AnimatedPrimaryColor | Reactive? |
|--------|---------------|----------------------|----------------------|-----------|
| LoginScreen | ✅ Provided | ✅ Used | ✅ Used | ✅ YES |
| RegisterScreen | ✅ Provided | ✅ Used | ✅ Used | ✅ YES |
| OtpScreen | ❌ Not provided | ❌ Not used | ❌ Not used | ❌ NO |
| ResetPasswordScreen | ❌ Not provided | ❌ Not used | ❌ Partial | ❌ NO |
| ForgotPasswordScreen | ❌ Not provided | ❌ Not used | ❌ Not used | ❌ NO |

**Result:** Role toggle works in Login/Register but FAILS in other screens.

### After Refactor (Target State)

| Screen | AuthRoleCubit | RoleAnimationWrapper | AnimatedPrimaryColor | Reactive? |
|--------|---------------|----------------------|----------------------|-----------|
| LoginScreen | ✅ From root | ✅ Used | ✅ Used | ✅ YES |
| RegisterScreen | ✅ From root | ✅ Used | ✅ Used | ✅ YES |
| OtpScreen | ✅ From root | ✅ Added | ✅ Added | ✅ YES |
| ResetPasswordScreen | ✅ From root | ✅ Added | ✅ Added | ✅ YES |
| ForgotPasswordScreen | ✅ From root | ✅ Added | ✅ Added | ✅ YES |

**Result:** Role toggle works EVERYWHERE instantly.

---

## 🎯 IMPLEMENTATION ROADMAP

### Phase 1: Core Decoupling (2-3 hours)

**Files to modify:**
1. Create `lib/core/domain/enums/user_role.dart`
2. Update `lib/core/widgets/providers_theme/coupony_theme_provider.dart`
3. Update all references to `OnboardingUserType` in onboarding features
4. Update `AuthRoleCubit` to use `UserRole` enum


**Testing:**
- ✅ Verify onboarding screens still work
- ✅ Verify API calls use correct role strings
- ✅ Verify no import errors

### Phase 2: Root-Level Cubit (1 hour)

**Files to modify:**
1. Update `lib/app.dart` to provide `AuthRoleCubit` at root
2. Remove `BlocProvider<AuthRoleCubit>.value` from individual auth screens
3. Update splash screen to call `loadPersistedRole()`

**Testing:**
- ✅ Verify role persists across app restarts
- ✅ Verify all auth screens can access `AuthRoleCubit`

### Phase 3: Screen Refactoring (3-4 hours)

**Files to modify:**
1. `lib/features/auth/presentation/pages/otp_screen.dart`
   - Remove `role` parameter
   - Add `RoleAnimationWrapper`
   - Replace hardcoded colors with `AnimatedPrimaryColor`

2. `lib/features/auth/presentation/pages/reset_password_screen.dart`
   - Remove `role` parameter
   - Replace hardcoded colors with `AnimatedPrimaryColor`

3. `lib/features/auth/presentation/pages/forgot_password_screen.dart`
   - Add `RoleAnimationWrapper`
   - Replace hardcoded colors with `AnimatedPrimaryColor`

4. `lib/config/routes/app_router.dart`
   - Remove `role` from route parameters
   - Update navigation calls

**Testing:**
- ✅ Navigate Login → Register → OTP → ResetPassword
- ✅ Toggle role at each step
- ✅ Verify colors update instantly everywhere
- ✅ Verify animations work smoothly


### Phase 4: Cleanup & Documentation (1 hour)

**Tasks:**
1. Deprecate `OnboardingUserType` with migration guide
2. Update architecture documentation
3. Add code comments explaining reactive theme system
4. Create developer guide for adding new role-aware screens

**Testing:**
- ✅ Full regression test of auth flow
- ✅ Test with both customer and merchant roles
- ✅ Verify no console warnings or errors

---

## 🚀 EXPECTED OUTCOMES

### Technical Benefits

1. **Clean Architecture Compliance**
   - Core layer independent of feature layers
   - Proper dependency direction (features → core, not core → features)

2. **Single Source of Truth**
   - `AuthRoleCubit` is the ONLY place role is managed
   - No duplicate role state across screens

3. **Reactive UI**
   - All screens automatically update when role changes
   - No manual color management needed

4. **Maintainability**
   - Adding new role-aware screens is trivial
   - Consistent pattern across entire app

### User Experience Benefits

1. **Instant Visual Feedback**
   - Role toggle updates ALL screens immediately
   - Smooth animations across entire auth flow

2. **Consistency**
   - Same colors and animations everywhere
   - No jarring transitions between screens

3. **Reliability**
   - Role persists across app restarts
   - No state loss during navigation


---

## 🔧 MIGRATION CHECKLIST

### Pre-Refactor
- [ ] Create feature branch: `refactor/unified-theme-system`
- [ ] Backup current codebase
- [ ] Document current behavior with screenshots
- [ ] Run full test suite to establish baseline

### Phase 1: Core Decoupling
- [ ] Create `UserRole` enum in core
- [ ] Update `CouponyThemeProvider`
- [ ] Update `AuthRoleCubit` to use `UserRole`
- [ ] Create adapter for onboarding features
- [ ] Run tests and fix compilation errors

### Phase 2: Root-Level Cubit
- [ ] Add `AuthRoleCubit` to `MyApp` providers
- [ ] Remove individual `BlocProvider.value` calls
- [ ] Update splash screen initialization
- [ ] Test role persistence

### Phase 3: Screen Refactoring
- [ ] Refactor `OtpScreen`
- [ ] Refactor `ResetPasswordScreen`
- [ ] Refactor `ForgotPasswordScreen`
- [ ] Update route definitions
- [ ] Update navigation calls
- [ ] Test complete auth flow

### Phase 4: Cleanup
- [ ] Remove unused code
- [ ] Update documentation
- [ ] Add code comments
- [ ] Run final test suite
- [ ] Create PR with detailed description

### Post-Refactor
- [ ] Code review with team
- [ ] QA testing on multiple devices
- [ ] Monitor for issues in production
- [ ] Update team documentation

---

## 📝 CONCLUSION

The current architecture has a **fundamental flaw**: theme management is split between two systems:
1. `CouponyThemeProvider` (coupled to Onboarding)
2. `AnimatedPrimaryColor` (correctly uses AuthRoleCubit)


The solution is to:
1. **Decouple** `UserRole` from Onboarding feature → move to core
2. **Centralize** `AuthRoleCubit` at app root → available everywhere
3. **Standardize** all screens to use `AnimatedPrimaryColor` → consistent reactivity

**Estimated Total Time:** 7-9 hours  
**Risk Level:** Low (incremental changes, easy to rollback)  
**Impact:** High (fixes broken UX, improves architecture)

**Recommendation:** Proceed with refactor in phases, testing thoroughly at each step.

---

**Report Prepared By:** Senior Lead Flutter Architect  
**Date:** April 1, 2026  
**Status:** Ready for Implementation
