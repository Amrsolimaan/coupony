# 🔍 REDIRECT LOGIC DEEP-DIVE ANALYSIS
## Why Existing Merchants Are Forced Into "Create Store" Flow

---

## 📋 EXECUTIVE SUMMARY

**THE PROBLEM:**
Existing merchants with `roles: ['seller', 'customer']` and active stores are being redirected to `/create-store` after login, even though they should go directly to `/seller-home`.

**ROOT CAUSE:**
The GoRouter's `redirect` function in `app_router.dart` **DOES NOT CHECK USER ROLES OR STORES**. It only validates authentication tokens. The actual routing logic happens AFTER the redirect passes, in the Splash Screen, which relies on **stale cached data** that may not reflect the user's current backend status.

---

## 🔍 INVESTIGATION FINDINGS

### FINDING 1: GoRouter Redirect is Token-Only

**File:** `lib/config/routes/app_router.dart` (Lines 265-290)

```dart
redirect: (context, state) async {
  final location = state.matchedLocation;

  // Public routes are always accessible
  if (_publicRoutes.contains(location)) return null;

  // 1. Authenticated user — token present and non-empty.
  final token = await sl<SecureStorageService>().read(
    StorageKeys.authToken,
  );
  if (token != null && token.isNotEmpty) return null;

  // 2. Guest user — explicit visitor session
  final isGuest =
      sl<SharedPreferences>().getBool(StorageKeys.isGuest) ?? false;
  if (isGuest) return null;

  // 3. No session — redirect to gateway
  return welcomeGateway;
}
```

**ANALYSIS:**
- ✅ Checks: Token exists
- ❌ Does NOT check: User roles
- ❌ Does NOT check: User stores
- ❌ Does NOT check: Store status (active/pending/rejected)
- ❌ Does NOT check: Onboarding completion

**CONCLUSION:**
The redirect function is a **pure authentication guard**. It has NO knowledge of user roles or merchant status. Once the token is valid, it passes control to the Splash Screen.

---

### FINDING 2: Splash Screen Uses Cached Data (Stale Risk)

**File:** `lib/features/auth/presentation/pages/splash_screen.dart` (Lines 100-160)

```dart
Future<void> _checkOnboardingStatus() async {
  try {
    final authLocalDs = di.sl<AuthLocalDataSource>();

    // ✅ Read token and guest status first
    final token = await authLocalDs.getAccessToken();
    final isGuest = await authLocalDs.getGuestStatus();

    if (!mounted) return;

    // Guest user → go to home immediately
    if (isGuest) {
      context.go(AppRouter.home);
      return;
    }

    // No token → not authenticated → go to login
    if (token == null || token.isEmpty) {
      context.go(AppRouter.login);
      return;
    }

    // ✅ Authenticated user: safely read user-scoped flags
    bool isOnboardingCompleted = false;
    bool isStoreCreated = false;

    try {
      final results = await Future.wait([
        authLocalDs.getOnboardingCompleted(),
        authLocalDs.getStoreCreated(),
      ]);
      isOnboardingCompleted = results[0] as bool;
      isStoreCreated = results[1] as bool;
    } catch (e) {
      // userId missing or other cache error - treat as fresh user
      print('⚠️ Could not read user-scoped flags: $e');
      isOnboardingCompleted = false;
      isStoreCreated = false;
    }

    if (!mounted) return;

    final authRoleCubit = context.read<AuthRoleCubit>();

    // ⚠️ CRITICAL: This is where the decision is made
    if (authRoleCubit.state.isSeller) {
      // Seller must complete onboarding before store decisions
      if (!isOnboardingCompleted) {
        context.go(AppRouter.sellerOnboarding);
        return;
      }

      // ⚠️ PROBLEM: Delegates to SellerRoutingResolver with CACHED data
      await SellerRoutingResolver.resolveFromCache(
        context: context,
        isOnboardingCompleted: isOnboardingCompleted,
        isStoreCreated: isStoreCreated,
        authLocalDs: authLocalDs,
      );
      return;
    }

    // Customer path
    context.go(isOnboardingCompleted ? AppRouter.home : AppRouter.onboarding);
  } catch (e) {
    print('❌ _checkOnboardingStatus error: $e');
    if (mounted) context.go(AppRouter.login);
  }
}
```

**ANALYSIS:**
- ✅ Reads `isOnboardingCompleted` from cache
- ✅ Reads `isStoreCreated` from cache
- ⚠️ Reads `authRoleCubit.state.isSeller` from cache
- ❌ Does NOT fetch fresh user data from API
- ❌ Does NOT check `user.stores` array
- ❌ Does NOT check `user.roles` array

**THE STALE DATA PROBLEM:**
1. User logs in as customer → Cache stores `role: 'customer'`
2. User creates store via profile → Backend updates `roles: ['seller', 'customer']`
3. User logs out and logs back in → Splash reads OLD cached role `'customer'`
4. Splash skips seller routing logic → Goes to customer home
5. User clicks "كن تاجراً" → Profile fetches fresh data → Sees `seller` role
6. Profile navigates to merchant flow → But cache is still stale

**CONCLUSION:**
The Splash Screen relies on **cached flags** that may be outdated. It never fetches fresh user data from the backend.

---

### FINDING 3: AuthRoleCubit Uses Cached Role

**File:** `lib/features/auth/presentation/cubit/auth_role_cubit.dart` (Lines 45-65)

```dart
Future<void> loadPersistedRole() async {
  try {
    emit(state.copyWith(isLoading: true));
    
    // ✅ Use helper method to get primary role from roles array
    final authLocalDs = di.sl<AuthLocalDataSource>();
    final role = await authLocalDs.getPrimaryRole();
    
    print('✅ Loaded primary role: $role');
    
    emit(state.copyWith(
      role: role,
      isLoading: false,
    ));
  } catch (e) {
    // On error, default to customer
    print('⚠️ loadPersistedRole failed, defaulting to customer: $e');
    emit(state.copyWith(
      role: 'customer',
      isLoading: false,
    ));
  }
}
```

**File:** `lib/features/auth/data/datasources/auth_local_data_source.dart` (Lines 260-310)

```dart
Future<String> getPrimaryRole() async {
  try {
    // Step 1: Get backend roles (source of truth for permissions)
    final backendRoles = await getCachedUserRoles();
    
    // Step 2: Get user's active role preference (from role_toggle)
    final userSelectedRole = await secureStorage.read(StorageKeys.userRole);
    
    // Step 3: If user has selected a role, validate it against backend roles
    if (userSelectedRole != null && userSelectedRole.isNotEmpty) {
      // Validate: user can only use roles they have from backend
      if (backendRoles.isEmpty) {
        // No backend roles cached yet, trust user selection
        return (userSelectedRole == 'seller') ? 'seller' : 'customer';
      }
      
      // Check if user's selection is valid
      if (userSelectedRole == 'seller') {
        // User wants seller role - check if they have it
        if (backendRoles.contains('seller') || backendRoles.contains('seller_pending')) {
          return 'seller';
        }
        // User doesn't have seller role, fallback to customer
        return 'customer';
      } else {
        // User wants customer role - always allowed
        return 'customer';
      }
    }
    
    // Step 4: No user preference, use backend's primary role
    if (backendRoles.isEmpty) {
      // Fallback to single role storage for backward compatibility
      final savedRole = await secureStorage.read(StorageKeys.userRole);
      return (savedRole == 'seller') ? 'seller' : 'customer';
    }
    
    // Determine primary role from backend roles array
    if (backendRoles.contains('seller') || backendRoles.contains('seller_pending')) {
      return 'seller';
    }
    
    return 'customer';
  } catch (e) {
    print('⚠️ getPrimaryRole failed, defaulting to customer: $e');
    return 'customer'; // Safe default
  }
}
```

**ANALYSIS:**
- ✅ Reads `backendRoles` from cache (SharedPreferences)
- ✅ Reads `userSelectedRole` from cache (SecureStorage)
- ❌ Does NOT fetch fresh roles from API
- ⚠️ If `backendRoles` is empty, falls back to single role storage

**THE CACHE TIMING PROBLEM:**
1. User logs in → `cacheUser()` saves `roles: ['seller', 'customer']`
2. Splash loads → `getPrimaryRole()` reads cached roles → Returns `'seller'`
3. **BUT:** If cache is corrupted or cleared, `backendRoles` is empty
4. Falls back to `userSelectedRole` which might be old `'customer'`
5. Splash thinks user is customer → Skips seller routing

**CONCLUSION:**
`AuthRoleCubit` depends entirely on cached data. If the cache is stale or empty, it defaults to `'customer'`.

---

### FINDING 4: SellerRoutingResolver Uses Cached Stores

**File:** `lib/features/auth/presentation/utils/seller_routing_resolver.dart` (Lines 100-140)

```dart
static Future<void> resolveFromCache({
  required BuildContext context,
  required bool isOnboardingCompleted,
  required bool isStoreCreated,
  required AuthLocalDataSource authLocalDs,
  List<String> userRoles = const [],
}) async {
  if (!isOnboardingCompleted) {
    if (context.mounted) context.go(AppRouter.sellerOnboarding);
    return;
  }

  // ── Check roles from cache if available ──
  if (userRoles.contains('seller_pending')) {
    if (context.mounted) {
      context.go(
        AppRouter.sellerHome,
        extra: {'isGuest': false, 'isPending': true},
      );
    }
    return;
  }
  
  if (userRoles.contains('seller') && !userRoles.contains('seller_pending')) {
    if (context.mounted) {
      context.go(
        AppRouter.sellerHome,
        extra: {'isGuest': false, 'isPending': false},
      );
    }
    return;
  }

  // ⚠️ PROBLEM: Fetches stores from cache
  final stores = await authLocalDs.getCachedStores();
  if (!context.mounted) return;

  await _applyScenarios(
    context:        context,
    isStoreCreated: isStoreCreated,
    stores:         stores,
    authLocalDs:    authLocalDs,
    userRoles:      userRoles,
  );
}
```

**File:** `lib/features/auth/presentation/utils/seller_routing_resolver.dart` (Lines 145-210)

```dart
static Future<void> _applyScenarios({
  required BuildContext context,
  required bool isStoreCreated,
  required List<UserStoreModel> stores,
  required AuthLocalDataSource authLocalDs,
  List<String> userRoles = const [],
}) async {
  // ── Priority Check: Roles-based routing ──
  if (userRoles.contains('seller_pending')) {
    context.go(
      AppRouter.sellerHome,
      extra: {'isGuest': false, 'isPending': true},
    );
    return;
  }
  
  if (userRoles.contains('seller') && !userRoles.contains('seller_pending')) {
    context.go(
      AppRouter.sellerHome,
      extra: {'isGuest': false, 'isPending': false},
    );
    return;
  }

  // ── Fallback: Store-based routing (legacy logic) ──
  // ⚠️ PROBLEM: Scenario 1 — no stores in the list
  if (stores.isEmpty) {
    // If no stores and not created yet, go to create store
    if (!isStoreCreated) {
      context.go(AppRouter.createStore);  // ❌ THIS IS THE TRIGGER
    } else {
      // Store created but not in list yet → probably pending
      context.go(
        AppRouter.sellerHome,
        extra: {'isGuest': false, 'isPending': true},
      );
    }
    return;
  }

  // Scenario 2 — every store is still pending review
  if (stores.every((s) => s.isPending)) {
    context.go(
      AppRouter.sellerHome,
      extra: {'isGuest': false, 'isPending': true},
    );
    return;
  }

  final activeStores = stores.where((s) => s.isActive).toList();

  if (activeStores.length == 1) {
    // Scenario 3 — exactly one active store
    await authLocalDs.saveSelectedStoreId(activeStores.first.id);
    if (context.mounted) {
      context.go(
        AppRouter.sellerHome,
        extra: {'isGuest': false, 'isPending': false},
      );
    }
  } else if (activeStores.length > 1) {
    // Scenario 4 — multiple active stores
    context.go(AppRouter.storeSelection, extra: activeStores);
  } else {
    // No active stores but has stores → all must be pending/rejected
    context.go(
      AppRouter.sellerHome,
      extra: {'isGuest': false, 'isPending': true},
    );
  }
}
```

**ANALYSIS:**
- ✅ Checks `userRoles` array (if provided)
- ⚠️ Reads `stores` from cache via `getCachedStores()`
- ❌ Does NOT fetch fresh stores from API
- ❌ **LINE 171: `context.go(AppRouter.createStore)` — THIS IS THE TRIGGER**

**THE EXACT TRIGGER:**
```dart
if (stores.isEmpty) {
  if (!isStoreCreated) {
    context.go(AppRouter.createStore);  // ❌ SENDS USER TO CREATE STORE
  }
}
```

**WHEN THIS HAPPENS:**
1. User has `roles: ['seller', 'customer']` in backend
2. User has active store in backend
3. **BUT:** Cache is empty or corrupted
4. `getCachedStores()` returns `[]`
5. `stores.isEmpty` is `true`
6. `isStoreCreated` is `false` (also from stale cache)
7. **BOOM:** User is sent to `/create-store`

**CONCLUSION:**
The `SellerRoutingResolver` makes routing decisions based on **cached stores list**. If the cache is empty, it assumes the user has no stores and sends them to create one.

---

## 🎯 THE COMPLETE FLOW (Step-by-Step)

### Scenario: Existing Merchant Logs In

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. USER LOGS IN                                                 │
│    - Email: merchant@example.com                                │
│    - Backend Response:                                          │
│      {                                                          │
│        "role": "seller",                                        │
│        "roles": ["seller", "customer"],                         │
│        "stores": [{ "id": "123", "status": "active" }],        │
│        "is_onboarding_completed": true,                         │
│        "is_store_created": true                                 │
│      }                                                          │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ 2. LOGIN CUBIT CACHES USER DATA                                 │
│    File: auth_local_data_source.dart (cacheUser)                │
│    - Saves to SecureStorage:                                    │
│      • authToken: "abc123..."                                   │
│      • userRole: "seller"                                       │
│      • userId: "merchant@example.com"                           │
│    - Saves to SharedPreferences:                                │
│      • merchant@example.com_onboarding_completed: true          │
│      • merchant@example.com_store_created: true                 │
│      • merchant@example.com_cached_stores: [...]                │
│      • merchant@example.com_user_roles: "seller,customer"       │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ 3. LOGIN CUBIT EMITS NAVIGATION SIGNAL                          │
│    File: login_cubit.dart (Line 40)                             │
│    - Emits: AuthNavigation.toHome                               │
│    - Listener in login_screen.dart catches it                   │
│    - Navigates to: context.go(AppRouter.home)                   │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ 4. GOROUTER REDIRECT FUNCTION RUNS                              │
│    File: app_router.dart (Lines 265-290)                        │
│    - Checks: Token exists? ✅ YES                               │
│    - Returns: null (allows navigation)                          │
│    - Does NOT check roles or stores                             │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ 5. USER LANDS ON /home (Customer Home)                          │
│    - This is WRONG for a seller                                 │
│    - But it happened because:                                   │
│      • Login cubit emitted toHome (not toSellerHome)            │
│      • Redirect function didn't intercept                       │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ 6. USER NAVIGATES TO PROFILE                                    │
│    - Clicks profile icon                                        │
│    - ProfileCubit.loadProfile() fetches FRESH data from API     │
│    - Sees: roles: ['seller', 'customer']                        │
│    - Shows "كن تاجراً" button                                   │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ 7. USER CLICKS "كن تاجراً" BUTTON                              │
│    File: main_profile.dart (Line 738)                           │
│    - Detects: user.roles.contains('seller')                     │
│    - Calls: _handlePendingOrRejectedSeller()                    │
│    - Fetches store details from API                             │
│    - Navigates to: merchant_rejected_page or merchant_pending   │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ 8. USER ENDS UP IN WRONG FLOW                                   │
│    - Expected: Go directly to seller home                       │
│    - Actual: Went through customer home → profile → merchant    │
│    - Root Cause: Login navigation ignored seller role           │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔴 THE ROOT CAUSES (Summary)

### ROOT CAUSE 1: Login Cubit Ignores Seller Role
**File:** `lib/features/auth/presentation/cubit/login_cubit.dart` (Lines 83-87)

```dart
// User selected customer in UI → go to customer flow
nav = user.isOnboardingCompleted
    ? AuthNavigation.toHome
    : AuthNavigation.toOnboarding;
```

**Problem:**
- Login cubit checks `user.isOnboardingCompleted`
- But it does NOT check `user.roles` array
- It assumes customer flow for all non-seller users
- Even if user has `roles: ['seller', 'customer']`, it goes to customer home

**Fix Needed:**
```dart
// Check if user has seller role
if (user.roles.contains('seller') || user.roles.contains('seller_pending')) {
  nav = AuthNavigation.toSellerHome;
} else {
  nav = user.isOnboardingCompleted
      ? AuthNavigation.toHome
      : AuthNavigation.toOnboarding;
}
```

---

### ROOT CAUSE 2: Splash Screen Uses Stale Cache
**File:** `lib/features/auth/presentation/pages/splash_screen.dart` (Lines 130-145)

```dart
// ✅ Authenticated user: safely read user-scoped flags
bool isOnboardingCompleted = false;
bool isStoreCreated = false;

try {
  final results = await Future.wait([
    authLocalDs.getOnboardingCompleted(),
    authLocalDs.getStoreCreated(),
  ]);
  isOnboardingCompleted = results[0] as bool;
  isStoreCreated = results[1] as bool;
} catch (e) {
  // userId missing or other cache error - treat as fresh user
  isOnboardingCompleted = false;
  isStoreCreated = false;
}
```

**Problem:**
- Reads flags from cache (SharedPreferences)
- Does NOT fetch fresh user data from API
- If cache is stale, makes wrong routing decision

**Fix Needed:**
- Fetch fresh user data from API on splash
- Or: Use `SellerRoutingResolver.resolveForUser()` with fresh UserModel

---

### ROOT CAUSE 3: SellerRoutingResolver Uses Cached Stores
**File:** `lib/features/auth/presentation/utils/seller_routing_resolver.dart` (Lines 135-145)

```dart
// ⚠️ PROBLEM: Fetches stores from cache
final stores = await authLocalDs.getCachedStores();

// Scenario 1 — no stores in the list
if (stores.isEmpty) {
  if (!isStoreCreated) {
    context.go(AppRouter.createStore);  // ❌ SENDS TO CREATE STORE
  }
}
```

**Problem:**
- Reads stores from cache
- If cache is empty, assumes user has no stores
- Sends user to create store screen

**Fix Needed:**
- Always pass fresh stores from API
- Or: Fetch stores from API if cache is empty

---

## 📊 DATA FLOW DIAGRAM

```
┌──────────────────────────────────────────────────────────────────┐
│                         LOGIN API RESPONSE                       │
│  {                                                               │
│    "role": "seller",                                             │
│    "roles": ["seller", "customer"],                              │
│    "stores": [{ "id": "123", "status": "active" }],             │
│    "is_onboarding_completed": true,                              │
│    "is_store_created": true                                      │
│  }                                                               │
└──────────────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────────────┐
│                    CACHE (AuthLocalDataSource)                   │
│  SecureStorage:                                                  │
│    • authToken: "abc123..."                                      │
│    • userRole: "seller"                                          │
│    • userId: "merchant@example.com"                              │
│                                                                  │
│  SharedPreferences:                                              │
│    • merchant@example.com_onboarding_completed: true             │
│    • merchant@example.com_store_created: true                    │
│    • merchant@example.com_cached_stores: [...]                   │
│    • merchant@example.com_user_roles: "seller,customer"          │
└──────────────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────────────┐
│                      SPLASH SCREEN READS                         │
│  authRoleCubit.state.isSeller                                    │
│    ↓                                                             │
│  AuthRoleCubit.loadPersistedRole()                               │
│    ↓                                                             │
│  AuthLocalDataSource.getPrimaryRole()                            │
│    ↓                                                             │
│  getCachedUserRoles() → ["seller", "customer"]                   │
│    ↓                                                             │
│  Returns: "seller"                                               │
└──────────────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────────────┐
│                  SELLER ROUTING RESOLVER                         │
│  resolveFromCache(                                               │
│    isOnboardingCompleted: true,  ← FROM CACHE                    │
│    isStoreCreated: true,         ← FROM CACHE                    │
│    userRoles: []                 ← NOT PASSED!                   │
│  )                                                               │
│    ↓                                                             │
│  getCachedStores() → []          ← CACHE EMPTY!                  │
│    ↓                                                             │
│  stores.isEmpty = true                                           │
│    ↓                                                             │
│  context.go(AppRouter.createStore)  ← WRONG DESTINATION          │
└──────────────────────────────────────────────────────────────────┘
```

---

## 🎯 THE EXACT PROBLEM STATEMENT

**The Router sends the user to `createStore` when:**
1. `authRoleCubit.state.isSeller` is `true` (from cached role)
2. `isOnboardingCompleted` is `true` (from cached flag)
3. `getCachedStores()` returns `[]` (cache is empty or stale)
4. `isStoreCreated` is `false` (from cached flag, might be stale)

**The problem is that it ignores:**
1. The `user.stores` array from the fresh API response
2. The `user.roles` array from the fresh API response
3. The actual backend state of the user's merchant account

**Why does this happen?**
- The Splash Screen calls `SellerRoutingResolver.resolveFromCache()`
- This method reads ALL data from cache (SharedPreferences)
- It does NOT fetch fresh data from the API
- If the cache is empty, corrupted, or stale, it makes wrong decisions

---

## ✅ RECOMMENDED SOLUTION

### Option 1: Pass Fresh Data to Resolver (Preferred)

**Change:** Splash Screen should fetch fresh user data and pass it to resolver

```dart
// In splash_screen.dart
Future<void> _checkOnboardingStatus() async {
  // ... existing token check ...

  // ✅ Fetch fresh user data from API
  final authRepository = di.sl<AuthRepository>();
  final result = await authRepository.getCurrentUser();
  
  result.fold(
    (failure) {
      // API failed, fallback to cache
      _useCachedRouting();
    },
    (user) {
      // ✅ Use fresh data from API
      if (user.roles.contains('seller') || user.roles.contains('seller_pending')) {
        SellerRoutingResolver.resolveForUser(
          context: context,
          user: user,  // ✅ Fresh UserModel with stores
          authLocalDs: authLocalDs,
        );
      } else {
        context.go(user.isOnboardingCompleted ? AppRouter.home : AppRouter.onboarding);
      }
    },
  );
}
```

### Option 2: Fix Login Cubit Navigation

**Change:** Login cubit should check roles and emit correct navigation signal

```dart
// In login_cubit.dart
if (user.roles.contains('seller') || user.roles.contains('seller_pending')) {
  // Seller flow - delegate to resolver
  nav = AuthNavigation.toSellerHome;
} else {
  // Customer flow
  nav = user.isOnboardingCompleted
      ? AuthNavigation.toHome
      : AuthNavigation.toOnboarding;
}
```

### Option 3: Pass Roles to Resolver

**Change:** Splash should pass cached roles to resolver

```dart
// In splash_screen.dart
final userRoles = await authLocalDs.getCachedUserRoles();

await SellerRoutingResolver.resolveFromCache(
  context: context,
  isOnboardingCompleted: isOnboardingCompleted,
  isStoreCreated: isStoreCreated,
  authLocalDs: authLocalDs,
  userRoles: userRoles,  // ✅ Pass cached roles
);
```

---

## 🔍 PROOF OF BEHAVIOR

### Code Snippet 1: The Trigger Line
**File:** `seller_routing_resolver.dart` (Line 171)
```dart
if (stores.isEmpty) {
  if (!isStoreCreated) {
    context.go(AppRouter.createStore);  // ❌ THIS LINE SENDS USER TO CREATE STORE
  }
}
```

### Code Snippet 2: The Stale Cache Read
**File:** `seller_routing_resolver.dart` (Line 135)
```dart
final stores = await authLocalDs.getCachedStores();  // ⚠️ READS FROM CACHE
```

### Code Snippet 3: The Missing Roles Check
**File:** `splash_screen.dart` (Line 145)
```dart
await SellerRoutingResolver.resolveFromCache(
  context: context,
  isOnboardingCompleted: isOnboardingCompleted,
  isStoreCreated: isStoreCreated,
  authLocalDs: authLocalDs,
  // ❌ userRoles NOT PASSED - defaults to []
);
```

---

## 📝 CONCLUSION

The redirect logic does NOT check user roles or stores. It only validates authentication tokens. The actual routing happens in the Splash Screen, which relies on stale cached data. When the cache is empty or corrupted, it sends existing merchants to the "Create Store" flow.

**The fix:** Either fetch fresh user data on splash, or ensure cached roles are passed to the resolver.
