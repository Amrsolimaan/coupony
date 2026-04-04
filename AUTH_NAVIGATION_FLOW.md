# Authentication Navigation Flow Diagram

## Complete Navigation Flow (After Implementation)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         AUTHENTICATION ENTRY                             │
│                                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌─────────────┐│
│  │    Login     │  │   Register   │  │ Google Auth  │  │ OTP Verify  ││
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  └──────┬──────┘│
│         │                 │                  │                 │        │
│         └─────────────────┴──────────────────┴─────────────────┘        │
│                                    │                                     │
└────────────────────────────────────┼─────────────────────────────────────┘
                                     │
                                     ▼
                        ┌────────────────────────┐
                        │  Check User Role       │
                        │  & Onboarding Status   │
                        └────────────┬───────────┘
                                     │
                ┌────────────────────┴────────────────────┐
                │                                         │
                ▼                                         ▼
    ┌───────────────────────┐                ┌───────────────────────┐
    │   role == 'seller'    │                │  role == 'customer'   │
    └───────────┬───────────┘                └───────────┬───────────┘
                │                                         │
                │                                         │
    ┌───────────┴───────────┐                ┌───────────┴───────────┐
    │                       │                │                       │
    ▼                       ▼                ▼                       ▼
┌─────────────┐      ┌─────────────┐   ┌─────────────┐      ┌─────────────┐
│ Onboarding  │      │ Onboarding  │   │ Onboarding  │      │ Onboarding  │
│ Completed?  │      │ Completed?  │   │ Completed?  │      │ Completed?  │
│             │      │             │   │             │      │             │
│   ✅ YES    │      │   ❌ NO     │   │   ✅ YES    │      │   ❌ NO     │
└──────┬──────┘      └──────┬──────┘   └──────┬──────┘      └──────┬──────┘
       │                    │                  │                    │
       │                    │                  │                    │
       ▼                    ▼                  ▼                    ▼
┌──────────────┐    ┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│   Merchant   │    │    Seller    │   │     Home     │   │   Customer   │
│  Dashboard   │    │  Onboarding  │   │    Screen    │   │  Onboarding  │
│              │    │              │   │              │   │              │
│  🔵 Blue     │    │  🔵 Blue     │   │  🟢 Green    │   │  🟢 Green    │
│   Theme      │    │   Theme      │   │   Theme      │   │   Theme      │
└──────────────┘    └──────┬───────┘   └──────────────┘   └──────┬───────┘
                           │                                      │
                           │ Complete                             │ Complete
                           │ Onboarding                           │ Onboarding
                           │                                      │
                           ▼                                      ▼
                    ┌──────────────┐                      ┌──────────────┐
                    │   Merchant   │                      │     Home     │
                    │  Dashboard   │                      │    Screen    │
                    │              │                      │              │
                    │  🔵 Blue     │                      │  🟢 Green    │
                    │   Theme      │                      │   Theme      │
                    └──────────────┘                      └──────────────┘
```

## Navigation Signal Mapping

```
AuthNavigation Enum Value          →  Route Destination
─────────────────────────────────────────────────────────────────────
toSellerOnboarding (NEW)           →  /seller-onboarding (Blue Theme)
toMerchantDash                     →  /merchant-dashboard (Blue Theme)
toOnboarding                       →  /onboarding (Green Theme)
toHome                             →  / (Green Theme)
toOtpVerification                  →  /otp-verification
toResetPassword                    →  /reset-password
toLogin                            →  /login
toRegister                         →  /register
```

## Decision Logic (Pseudocode)

```typescript
function determineNavigation(user: User): AuthNavigation {
  if (user.role === 'seller') {
    // SELLER PATH
    if (user.isOnboardingCompleted) {
      return AuthNavigation.toMerchantDash;      // ✅ Completed → Dashboard
    } else {
      return AuthNavigation.toSellerOnboarding;  // ⏳ Incomplete → Onboarding
    }
  } else {
    // CUSTOMER PATH
    if (user.isOnboardingCompleted) {
      return AuthNavigation.toHome;              // ✅ Completed → Home
    } else {
      return AuthNavigation.toOnboarding;        // ⏳ Incomplete → Onboarding
    }
  }
}
```

## Theme Application Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    App Initialization                        │
│                                                              │
│  1. AuthRoleCubit loads persisted role from storage         │
│  2. MaterialApp listens to AuthRoleCubit state              │
│  3. Theme is set based on role:                             │
│     - isSeller = true  → Blue Theme (primaryOfSeller)       │
│     - isSeller = false → Green Theme (primary)              │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    User Authentication                       │
│                                                              │
│  1. User logs in/registers with selected role               │
│  2. AuthRoleCubit updates role state                        │
│  3. MaterialApp rebuilds with new theme                     │
│  4. Navigation occurs with correct theme already applied    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  Destination Screen                          │
│                                                              │
│  - Screen inherits theme from MaterialApp                   │
│  - All widgets use Theme.of(context).primaryColor           │
│  - No manual theme switching needed                         │
│  - Smooth, seamless transition                              │
└─────────────────────────────────────────────────────────────┘
```

## Seller Onboarding Steps

```
┌──────────────────────────────────────────────────────────────┐
│              Seller Onboarding Flow (4 Steps)                │
│                      🔵 Blue Theme                           │
└──────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │   Step 1 of 4   │
                    │  Price Range    │
                    │                 │
                    │  Select pricing │
                    │  tier for store │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │   Step 2 of 4   │
                    │ Delivery Method │
                    │                 │
                    │ Choose delivery │
                    │    options      │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │   Step 3 of 4   │
                    │   Store Info    │
                    │                 │
                    │  Enter store    │
                    │    details      │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │   Step 4 of 4   │
                    │Target Audience  │
                    │                 │
                    │ Define customer │
                    │   demographics  │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │   Complete!     │
                    │                 │
                    │ Backend updates │
                    │ isOnboarding    │
                    │ Completed=true  │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │   Merchant      │
                    │   Dashboard     │
                    │                 │
                    │  🔵 Blue Theme  │
                    └─────────────────┘
```

## Key Differences: Before vs After

### BEFORE (Incorrect)
```
Seller Login → ❌ Merchant Dashboard (Direct)
              (Skipped onboarding entirely)
```

### AFTER (Correct)
```
Seller Login → ✅ Check isOnboardingCompleted
              │
              ├─ false → Seller Onboarding → Complete → Dashboard
              │
              └─ true  → Merchant Dashboard (Direct)
```

## Error Handling

```
┌─────────────────────────────────────────────────────────────┐
│                    Error Scenarios                           │
└─────────────────────────────────────────────────────────────┘

1. Invalid Credentials
   └─> Show error snackbar (Red color)
   └─> Stay on login/register screen

2. Network Error
   └─> Show error snackbar (Red color)
   └─> Stay on current screen

3. OTP Verification Failed
   └─> Show error snackbar (Red color)
   └─> Allow retry

4. Backend isOnboardingCompleted = null
   └─> Treat as false (redirect to onboarding)
   └─> Safe default behavior

5. Unknown Role
   └─> Treat as customer
   └─> Redirect to customer onboarding
```

## Testing Scenarios

```
┌─────────────────────────────────────────────────────────────┐
│                    Test Scenarios                            │
└─────────────────────────────────────────────────────────────┘

✅ Scenario 1: New Seller Registration
   Input: Register as seller
   Expected: Seller Onboarding (Blue Theme)
   
✅ Scenario 2: Returning Seller Login (Onboarding Complete)
   Input: Login as seller (isOnboardingCompleted: true)
   Expected: Merchant Dashboard (Blue Theme)
   
✅ Scenario 3: Returning Seller Login (Onboarding Incomplete)
   Input: Login as seller (isOnboardingCompleted: false)
   Expected: Seller Onboarding (Blue Theme)
   
✅ Scenario 4: New Customer Registration
   Input: Register as customer
   Expected: Customer Onboarding (Green Theme)
   
✅ Scenario 5: Returning Customer Login (Onboarding Complete)
   Input: Login as customer (isOnboardingCompleted: true)
   Expected: Home Screen (Green Theme)
   
✅ Scenario 6: Google Sign-In (New Seller)
   Input: Google sign-in with seller role
   Expected: Seller Onboarding (Blue Theme)
   
✅ Scenario 7: OTP Verification (Seller)
   Input: Verify OTP for seller account
   Expected: Seller Onboarding or Dashboard (based on flag)
```
