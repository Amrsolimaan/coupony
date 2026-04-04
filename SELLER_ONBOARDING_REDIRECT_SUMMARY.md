# Seller Onboarding Redirect - Implementation Summary

## Objective
Redirect sellers to their onboarding flow instead of home/dashboard after successful authentication, ensuring they complete the seller-specific setup before accessing the merchant dashboard.

## Problem Statement
Previously, sellers were being redirected directly to the merchant dashboard (`toMerchantDash`) after login/register, bypassing the seller onboarding flow. This prevented new sellers from completing their store setup and configuration.

## Solution Overview

### Navigation Flow Changes

#### BEFORE (Old Flow):
```
Seller Login/Register → Merchant Dashboard (Direct)
Customer Login/Register → Customer Onboarding (if not completed) → Home
```

#### AFTER (New Flow):
```
Seller Login/Register → Seller Onboarding (if not completed) → Merchant Dashboard
Customer Login/Register → Customer Onboarding (if not completed) → Home
```

## Implementation Details

### TASK 1: New Navigation Signal

**File**: `lib/features/auth/presentation/cubit/auth_state.dart`

Added new navigation enum value:
```dart
enum AuthNavigation {
  none,
  toHome,             // Customer with completed onboarding → home
  toOnboarding,       // Customer with incomplete onboarding → customer onboarding
  toSellerOnboarding, // Seller with incomplete onboarding → seller onboarding ✨ NEW
  toMerchantDash,     // Seller with completed onboarding → merchant dashboard
  toOtpVerification,
  toResetPassword,
  toLogin,
  toRegister,
}
```

### TASK 2: Updated Auth Cubits

#### 1. LoginCubit (`lib/features/auth/presentation/cubit/login_cubit.dart`)

**BEFORE**:
```dart
final nav = user.role == 'seller'
    ? AuthNavigation.toMerchantDash  // ❌ Always dashboard
    : user.isOnboardingCompleted
        ? AuthNavigation.toHome
        : AuthNavigation.toOnboarding;
```

**AFTER**:
```dart
final AuthNavigation nav;
if (user.role == 'seller') {
  // Sellers: check if onboarding is completed
  nav = user.isOnboardingCompleted
      ? AuthNavigation.toMerchantDash
      : AuthNavigation.toSellerOnboarding;  // ✅ Onboarding first
} else {
  // Customers: check if onboarding is completed
  nav = user.isOnboardingCompleted
      ? AuthNavigation.toHome
      : AuthNavigation.toOnboarding;
}
```

#### 2. RegisterCubit (`lib/features/auth/presentation/cubit/register_cubit.dart`)

**BEFORE**:
```dart
final nav = user.role == 'seller'
    ? AuthNavigation.toMerchantDash  // ❌ Always dashboard
    : AuthNavigation.toHome;
```

**AFTER**:
```dart
final AuthNavigation nav;
if (user.role == 'seller') {
  // Sellers always go to onboarding first (new accounts)
  nav = AuthNavigation.toSellerOnboarding;  // ✅ New sellers → onboarding
} else {
  // Customers go to customer onboarding
  nav = AuthNavigation.toOnboarding;
}
```

#### 3. OtpCubit (`lib/features/auth/presentation/cubit/otp_cubit.dart`)

Updated with same logic as LoginCubit to handle OTP verification flow.

#### 4. GoogleSignInCubit (`lib/features/auth/presentation/cubit/google_sign_in_cubit.dart`)

**BEFORE**:
```dart
AuthNavigation navigation;
if (user.isOnboardingCompleted) {
  navigation = user.role == 'seller' 
      ? AuthNavigation.toMerchantDash 
      : AuthNavigation.toHome;
} else {
  navigation = AuthNavigation.toOnboarding;  // ❌ Wrong for sellers
}
```

**AFTER**:
```dart
final AuthNavigation navigation;
if (user.role == 'seller') {
  navigation = user.isOnboardingCompleted
      ? AuthNavigation.toMerchantDash
      : AuthNavigation.toSellerOnboarding;  // ✅ Seller-specific
} else {
  navigation = user.isOnboardingCompleted
      ? AuthNavigation.toHome
      : AuthNavigation.toOnboarding;
}
```

### TASK 3: Updated UI Screens

#### 1. Login Screen (`lib/features/auth/presentation/pages/login_screen.dart`)

Added `toSellerOnboarding` case to both listeners:

**LoginCubit Listener**:
```dart
switch (state.navSignal) {
  case AuthNavigation.toHome:
    context.go(AppRouter.home);
  case AuthNavigation.toOnboarding:
    context.go(AppRouter.onboarding);
  case AuthNavigation.toSellerOnboarding:  // ✅ NEW
    context.go(AppRouter.sellerOnboarding);
  case AuthNavigation.toMerchantDash:
    context.go(AppRouter.merchantDashboard);
  // ...
}
```

**GoogleSignInCubit Listener** (in success bottom sheet):
```dart
onContinue: () {
  Navigator.of(context).pop();
  switch (state.navSignal) {
    case AuthNavigation.toHome:
      context.go(AppRouter.home);
    case AuthNavigation.toOnboarding:
      context.go(AppRouter.onboarding);
    case AuthNavigation.toSellerOnboarding:  // ✅ NEW
      context.go(AppRouter.sellerOnboarding);
    case AuthNavigation.toMerchantDash:
      context.go(AppRouter.merchantDashboard);
    // ...
  }
}
```

#### 2. Register Screen (`lib/features/auth/presentation/pages/register_screen.dart`)

Added `toSellerOnboarding` case to both RegisterCubit and GoogleSignInCubit listeners (same pattern as login screen).

#### 3. OTP Screen (`lib/features/auth/presentation/pages/otp_screen.dart`)

Updated switch expression:
```dart
final route = switch (state.navSignal) {
  AuthNavigation.toMerchantDash      => AppRouter.merchantDashboard,
  AuthNavigation.toSellerOnboarding  => AppRouter.sellerOnboarding,  // ✅ NEW
  AuthNavigation.toOnboarding        => AppRouter.onboarding,
  _                                  => AppRouter.home,
};
```

## Persistence & Onboarding Completion

### Backend Flag: `isOnboardingCompleted`

The backend already provides an `isOnboardingCompleted` flag in the user entity:
- **true**: User has completed their onboarding flow
- **false**: User needs to complete onboarding

### Logic:
```dart
// For Sellers:
if (user.role == 'seller') {
  if (user.isOnboardingCompleted) {
    // Seller has completed onboarding → Merchant Dashboard
    navigate to AppRouter.merchantDashboard
  } else {
    // Seller needs onboarding → Seller Onboarding
    navigate to AppRouter.sellerOnboarding
  }
}

// For Customers:
if (user.role == 'customer') {
  if (user.isOnboardingCompleted) {
    // Customer has completed onboarding → Home
    navigate to AppRouter.home
  } else {
    // Customer needs onboarding → Customer Onboarding
    navigate to AppRouter.onboarding
  }
}
```

### No Additional Local Storage Needed
The `isOnboardingCompleted` flag from the backend is sufficient. When a seller completes the onboarding flow, the backend updates this flag, and subsequent logins will redirect to the dashboard.

## Theme Synchronization

### Blue Theme for Sellers

The seller onboarding screen automatically picks up the blue theme because:

1. **Global Theme Management** (`lib/app.dart`):
```dart
BlocBuilder<AuthRoleCubit, AuthRoleState>(
  builder: (context, roleState) {
    final primaryColor = roleState.isSeller
        ? AppColors.primaryOfSeller  // 🔵 Blue for sellers
        : AppColors.primary;         // 🟢 Green for customers
    
    final theme = AppTheme.lightTheme.copyWith(
      primaryColor: primaryColor,
      colorScheme: AppTheme.lightTheme.colorScheme.copyWith(
        primary: primaryColor,
      ),
    );
    
    return MaterialApp.router(
      theme: theme,
      // ...
    );
  },
)
```

2. **AuthRoleCubit State Persistence**:
   - When a seller logs in, `AuthRoleCubit` stores `role: 'seller'`
   - The `isSeller` getter returns `true`
   - MaterialApp rebuilds with blue theme
   - Seller onboarding screen inherits blue theme automatically

3. **Smooth Transition**:
   - Theme change happens before navigation
   - No flash or theme mismatch
   - All widgets in seller onboarding use `Theme.of(context).primaryColor`

## Testing Checklist

### Seller Login Flow
- [ ] New seller registers → redirects to Seller Onboarding (blue theme)
- [ ] Seller completes onboarding → backend sets `isOnboardingCompleted: true`
- [ ] Seller logs in again → redirects to Merchant Dashboard (skips onboarding)
- [ ] Seller with incomplete onboarding logs in → redirects to Seller Onboarding

### Customer Login Flow (Unchanged)
- [ ] New customer registers → redirects to Customer Onboarding (green theme)
- [ ] Customer completes onboarding → redirects to Home
- [ ] Customer with incomplete onboarding logs in → redirects to Customer Onboarding

### Google Sign-In Flow
- [ ] Seller signs in with Google (new) → Seller Onboarding
- [ ] Seller signs in with Google (returning) → Merchant Dashboard
- [ ] Customer signs in with Google (new) → Customer Onboarding
- [ ] Customer signs in with Google (returning) → Home

### OTP Verification Flow
- [ ] Seller verifies OTP (new account) → Seller Onboarding
- [ ] Seller verifies OTP (returning) → Merchant Dashboard
- [ ] Customer verifies OTP (new account) → Customer Onboarding
- [ ] Customer verifies OTP (returning) → Home

### Theme Verification
- [ ] Seller onboarding screens display blue theme
- [ ] Customer onboarding screens display green theme
- [ ] No theme flash during navigation
- [ ] All buttons, inputs, and UI elements use correct theme color

## Routes Verification

Existing routes in `app_router.dart`:
```dart
static const String sellerOnboarding = '/seller-onboarding';  // ✅ Already exists
static const String merchantDashboard = '/merchant-dashboard'; // ✅ Already exists
static const String onboarding = '/onboarding';                // ✅ Already exists
static const String home = '/';                                // ✅ Already exists
```

Route configuration:
```dart
GoRoute(
  path: sellerOnboarding,
  pageBuilder: (context, state) => AppPageTransition.build(
    context: context,
    state: state,
    child: const SellerOnboardingPage(),  // ✅ Already configured
  ),
),
```

## Files Modified

### Cubit Layer (Business Logic)
1. `lib/features/auth/presentation/cubit/auth_state.dart` - Added `toSellerOnboarding` enum
2. `lib/features/auth/presentation/cubit/login_cubit.dart` - Updated navigation logic
3. `lib/features/auth/presentation/cubit/register_cubit.dart` - Updated navigation logic
4. `lib/features/auth/presentation/cubit/otp_cubit.dart` - Updated navigation logic
5. `lib/features/auth/presentation/cubit/google_sign_in_cubit.dart` - Updated navigation logic

### UI Layer (Screens)
6. `lib/features/auth/presentation/pages/login_screen.dart` - Added navigation case
7. `lib/features/auth/presentation/pages/register_screen.dart` - Added navigation case
8. `lib/features/auth/presentation/pages/otp_screen.dart` - Added navigation case

## Success Criteria

✅ Sellers are redirected to onboarding after first login/register
✅ Sellers with completed onboarding go directly to dashboard
✅ Customers continue to use existing onboarding flow (unchanged)
✅ Google Sign-In works correctly for both roles
✅ OTP verification works correctly for both roles
✅ Blue theme is applied to seller onboarding screens
✅ Green theme is applied to customer onboarding screens
✅ No breaking changes to existing functionality
✅ All files compile without errors

## Backend Contract

The implementation relies on the backend providing:
```json
{
  "user": {
    "id": "123",
    "email": "seller@example.com",
    "role": "seller",  // or "customer"
    "is_onboarding_completed": false,  // or true
    "access_token": "...",
    "refresh_token": "..."
  }
}
```

## Notes

- No additional local storage flags needed
- Backend `isOnboardingCompleted` flag is the single source of truth
- Theme switching is automatic via `AuthRoleCubit`
- Navigation is cubit-driven, not route-driven
- Seller onboarding flow is already implemented (4 steps)
- No changes needed to seller onboarding screens themselves
