# 🔍 CREATE STORE SCREEN - COMPLETE NAVIGATION ANALYSIS

## 📋 EXECUTIVE SUMMARY

This document maps **every single navigation path** to `create_store_screen.dart`, including trigger logic, data passed, and potential conflicts.

---

## 🎯 ROUTE CONFIGURATION

### Route Constant
```dart
// lib/config/routes/app_router.dart
static const String createStore = '/create-store';
```

### Route Handler
```dart
GoRoute(
  path: createStore,
  pageBuilder: (context, state) {
    final args = state.extra as CreateStoreArgs?;
    return AppPageTransition.build(
      context: context,
      state: state,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => sl<CreateStoreCubit>()),
          BlocProvider(create: (_) => sl<LoginCubit>()),
        ],
        child: CreateStoreScreen(
          mode: args?.mode ?? CreateStoreMode.create,
          storeId: args?.storeId,
          initialStore: args?.initialStore,
          onSuccess: args?.onSuccess,
        ),
      ),
    );
  },
)
```

### Expected Arguments (CreateStoreArgs)
```dart
class CreateStoreArgs {
  final CreateStoreMode mode;           // create | edit
  final String? storeId;                // Required for edit mode
  final UserStoreModel? initialStore;   // Pre-fill data for edit mode
  final VoidCallback? onSuccess;        // Override default navigation
}
```

---

## 🛣️ ALL NAVIGATION PATHS

### PATH 1: FROM SELLER ONBOARDING (First-Time Seller)
**File:** `lib/features/seller_flow/SellerOnboarding/presentation/pages/onboarding_seller_screen.dart`

**Trigger Logic:**
```dart
// Line 58-60: After success bottom sheet
onContinue: () {
  Navigator.of(context).pop();
  context.go(AppRouter.createStore);
}

// Line 69-71: Direct navigation signal
if (state.navigationSignal == SellerOnboardingNavigation.toCreateStore) {
  context.read<SellerOnboardingFlowCubit>().clearNavigationSignal();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    router.go(AppRouter.createStore);
  });
}
```

**Data Passed:**
- ❌ **NO ARGUMENTS** - Uses default `CreateStoreMode.create`
- No `storeId`
- No `initialStore`
- No `onSuccess` callback

**Navigation Type:** `context.go()` - Replaces entire stack

**Expected Behavior:**
- Screen opens in CREATE mode
- Empty form fields
- On success → Default navigation to `AppRouter.storeUnderReview`

---

### PATH 2: FROM SELLER ROUTING RESOLVER (Auto-Navigation)
**File:** `lib/features/auth/presentation/utils/seller_routing_resolver.dart`

**Trigger Logic:**
```dart
// Line 171-172: When no stores exist and store not created
if (!isStoreCreated) {
  context.go(AppRouter.createStore);
}
```

**Context:** Called during:
- Cold start (Splash Screen)
- Post-login
- Post-OTP verification
- Post-Google Sign-In

**Data Passed:**
- ❌ **NO ARGUMENTS** - Uses default `CreateStoreMode.create`

**Navigation Type:** `context.go()` - Replaces entire stack

**Expected Behavior:**
- Screen opens in CREATE mode
- Empty form fields
- On success → Default navigation to `AppRouter.storeUnderReview`

---

### PATH 3: FROM BECOME MERCHANT PAGE (Pure Customer → Seller)
**File:** `lib/features/Profile/presentation/pages/customer/become_merchant_page.dart`

**Trigger Logic:**
```dart
// Line 118-126: "كن تاجراً" button
onPressed: () => context.push(
  AppRouter.createStore,
  extra: CreateStoreArgs(
    onSuccess: () {
      if (context.mounted) {
        onStoreCreated?.call();
        context.go(AppRouter.merchantPending);
      }
    },
  ),
)
```

**Data Passed:**
- ✅ `mode`: Default `CreateStoreMode.create`
- ❌ `storeId`: null
- ❌ `initialStore`: null
- ✅ `onSuccess`: Custom callback → navigates to `merchantPending`

**Navigation Type:** `context.push()` - Keeps stack

**Expected Behavior:**
- Screen opens in CREATE mode
- Empty form fields
- On success → Custom navigation to `AppRouter.merchantPending` (overrides default)

---

### PATH 4: FROM MERCHANT INCOMPLETE PAGE (Incomplete Store)
**File:** `lib/features/Profile/presentation/pages/customer/merchant_incomplete_page.dart`

**Trigger Logic:**
```dart
// Line 122-127: "استكمال البيانات" button
onPressed: () => context.push(
  AppRouter.createStore,
  extra: CreateStoreArgs(
    mode: CreateStoreMode.edit,
    storeId: storeId,
  ),
)
```

**Data Passed:**
- ✅ `mode`: `CreateStoreMode.edit`
- ✅ `storeId`: Passed from page constructor
- ❌ `initialStore`: null (screen will fetch via API)
- ❌ `onSuccess`: null (uses default)

**Navigation Type:** `context.push()` - Keeps stack

**Expected Behavior:**
- Screen opens in EDIT mode
- Fetches store details via `CreateStoreCubit.fetchStoreDetails()`
- Pre-fills form fields
- On success → Default navigation to `AppRouter.merchantStatus`

---

### PATH 5: FROM MERCHANT STATUS PAGE (Rejected Store - Edit)
**File:** `lib/features/Profile/presentation/pages/customer/merchant_status_page.dart`

**Trigger Logic:**
```dart
// Line 94-103: "تعديل البيانات" button
onPressed: () => context.push(
  AppRouter.createStore,
  extra: CreateStoreArgs(
    mode: CreateStoreMode.edit,
    storeId: args.storeId,
    initialStore: args.store,
    onSuccess: () {
      if (context.mounted) context.go(AppRouter.merchantPending);
    },
  ),
)
```

**Data Passed:**
- ✅ `mode`: `CreateStoreMode.edit`
- ✅ `storeId`: From `MerchantStatusArgs`
- ✅ `initialStore`: Full `UserStoreModel` snapshot
- ✅ `onSuccess`: Custom callback → navigates to `merchantPending`

**Navigation Type:** `context.push()` - Keeps stack

**Expected Behavior:**
- Screen opens in EDIT mode
- Pre-fills form fields from `initialStore`
- Validates changes against rejection reasons
- On success → Custom navigation to `AppRouter.merchantPending` (overrides default)

---

### PATH 6: FROM MAIN PROFILE (Indirect via Merchant Rejected Page)
**File:** `lib/features/Profile/presentation/pages/customer/main_profile.dart`

**Trigger Logic:**
```dart
// Line 738-749: Fetches store details, then navigates to merchant_rejected_page
if (store.isRejected) {
  context.push(
    AppRouter.merchantRejected,
    extra: MerchantStatusArgs(
      storeId: store.id,
      reasons: store.rejectionReason != null 
          ? [store.rejectionReason!] 
          : store.rejectionReasons,
      store: store,
    ),
  );
}
```

**Flow:**
1. User clicks "كن تاجراً" button in profile
2. `_handlePendingOrRejectedSeller()` fetches store details
3. If rejected → navigates to `merchant_rejected_page`
4. User clicks "عرض حالة الطلب" → navigates to `merchant_status_page`
5. User clicks "تعديل البيانات" → navigates to `create_store_screen` (PATH 5)

**Data Passed:** See PATH 5

---

## ⚠️ POTENTIAL CONFLICTS & ISSUES

### 🔴 CONFLICT 1: Inconsistent Data Passing in Edit Mode

**Problem:**
- PATH 4 (Incomplete): Passes `storeId` only, screen fetches data
- PATH 5 (Rejected): Passes `storeId` + `initialStore`, screen uses snapshot

**Impact:**
- PATH 4 makes an extra API call
- PATH 5 uses cached data (might be stale)

**Recommendation:**
- Standardize: Always pass `initialStore` when available
- Or: Always fetch fresh data in edit mode

---

### 🔴 CONFLICT 2: Rejection Validation Logic Mismatch

**File:** `create_store_screen.dart` (Lines 600-650)

**Problem:**
```dart
// Screen compares against fetchedStoreData OR initialStore
final storeToCompare = fetchedStoreData ?? initialStore;

if (storeToCompare != null && storeToCompare.isRejected) {
  // Validates if ANY field changed
  if (textFieldsUnchanged && logoUnchanged && locationUnchanged && 
      socialsUnchanged && docsUnchanged) {
    // Shows error with rejection reason
    context.showErrorSnackBar(message);
    return;
  }
}
```

**Issue:**
- PATH 4 (Incomplete): `initialStore` is null, so `fetchedStoreData` is used
- PATH 5 (Rejected): `initialStore` is provided, but screen ALSO fetches data
- If API returns different data than `initialStore`, comparison uses wrong baseline

**Recommendation:**
- Use ONLY `initialStore` if provided (don't fetch)
- Or: Always fetch and ignore `initialStore`

---

### 🔴 CONFLICT 3: Navigation Stack Inconsistency

**Problem:**
- PATH 1, 2: Use `context.go()` - Clears stack
- PATH 3, 4, 5: Use `context.push()` - Keeps stack

**Impact:**
- Back button behavior differs
- PATH 1/2: User can't go back after creating store
- PATH 3/4/5: User can go back to previous screen

**Recommendation:**
- Standardize based on UX requirements
- Rejection flow should probably use `push` (allow back)
- Onboarding flow should probably use `go` (prevent back)

---

### 🟡 CONFLICT 4: onSuccess Callback Inconsistency

**Default Behavior (no callback):**
- CREATE mode → `AppRouter.storeUnderReview`
- EDIT mode → `AppRouter.merchantStatus`

**Custom Callbacks:**
- PATH 3: → `AppRouter.merchantPending`
- PATH 5: → `AppRouter.merchantPending`

**Issue:**
- PATH 5 overrides default EDIT behavior
- User expects to see status page after editing, but goes to pending page instead

**Recommendation:**
- Remove `onSuccess` override in PATH 5
- Let default EDIT behavior handle navigation

---

### 🟡 CONFLICT 5: Main Profile Button Logic

**File:** `main_profile.dart` (Lines 600-650)

**Current Logic:**
```dart
if (roles.contains('seller') && stores.any((s) => s.isActive)) {
  // CASE 1: Active Seller
  merchantButtonAction = () => _handleActiveSeller(context);
  
} else if (roles.contains('seller_pending') || stores.any((s) => s.isPending || s.isRejected)) {
  // CASE 2 & 3: Pending or Rejected
  merchantButtonAction = () => _handlePendingOrRejectedSeller(context);
  
} else {
  // CASE 4: Pure Customer
  merchantButtonAction = () => _handlePureCustomer(context);
}
```

**Issue:**
- CASE 2/3 fetches store details AGAIN (already in `user.stores`)
- Extra API call on every button click
- Potential race condition if store status changes between cache and API

**Recommendation:**
- Use `user.stores` data directly
- Only fetch if `user.stores` is empty or stale

---

## 📊 DATA FLOW SUMMARY

| Path | Mode | storeId | initialStore | onSuccess | Navigation Type |
|------|------|---------|--------------|-----------|-----------------|
| 1. Seller Onboarding | CREATE | ❌ | ❌ | ❌ | `go()` |
| 2. Routing Resolver | CREATE | ❌ | ❌ | ❌ | `go()` |
| 3. Become Merchant | CREATE | ❌ | ❌ | ✅ Custom | `push()` |
| 4. Incomplete Store | EDIT | ✅ | ❌ | ❌ | `push()` |
| 5. Rejected Store | EDIT | ✅ | ✅ | ✅ Custom | `push()` |

---

## 🎯 RECOMMENDED FIXES

### Fix 1: Standardize Edit Mode Data Passing
```dart
// Always pass initialStore when available
context.push(
  AppRouter.createStore,
  extra: CreateStoreArgs(
    mode: CreateStoreMode.edit,
    storeId: store.id,
    initialStore: store, // ✅ Always include
  ),
)
```

### Fix 2: Remove Duplicate Fetch in Edit Mode
```dart
// In create_store_screen.dart
useEffect(() {
  if (!_isEditMode) return null;
  
  // ✅ Only use initialStore if provided
  if (initialStore != null) {
    _prefillForm(initialStore);
    return null;
  }
  
  // ❌ Remove API fetch - should never happen
  // If no initialStore, caller should provide it
  
  return null;
}, const []);
```

### Fix 3: Remove onSuccess Override in Rejection Flow
```dart
// In merchant_status_page.dart
onPressed: () => context.push(
  AppRouter.createStore,
  extra: CreateStoreArgs(
    mode: CreateStoreMode.edit,
    storeId: args.storeId,
    initialStore: args.store,
    // ❌ Remove onSuccess - let default handle it
  ),
)
```

### Fix 4: Optimize Main Profile Button Logic
```dart
// In main_profile.dart
void _handlePendingOrRejectedSeller(BuildContext context) {
  final user = (context.read<ProfileCubit>().state as ProfileLoaded).user as UserModel;
  final store = user.stores.firstWhere((s) => s.isPending || s.isRejected);
  
  // ✅ Use cached data directly
  if (store.isRejected) {
    context.push(
      AppRouter.merchantRejected,
      extra: MerchantStatusArgs(
        storeId: store.id,
        reasons: store.rejectionReasons,
        store: store,
      ),
    );
  } else if (store.isPending) {
    context.push(AppRouter.merchantPending);
  }
}
```

---

## ✅ CONCLUSION

All navigation paths to `create_store_screen` have been identified and analyzed. The main conflicts are:

1. **Inconsistent data passing** between incomplete and rejected flows
2. **Duplicate API fetches** in edit mode
3. **Navigation stack inconsistency** between onboarding and profile flows
4. **onSuccess callback overrides** causing unexpected navigation

Implementing the recommended fixes will ensure consistent behavior across all entry points.
