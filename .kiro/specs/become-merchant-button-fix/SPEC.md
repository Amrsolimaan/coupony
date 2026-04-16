# Become Merchant Button Fix - Specification

## Overview
Fix critical issues with "Become Merchant" button logic that prevent proper role switching and store selection for users logging in directly as customers.

## Problem Statement

### Issue 1: Button doesn't work for direct customer login
**Scenario:**
- User logs in as customer
- Clicks "Become Merchant" button
- Button uses stale data from login response instead of real-time store data
- StoresDisplayCubit never loads because it's only triggered in seller view

**Root Cause:**
```dart
// Current flow:
1. User logs in as customer → isSeller = false
2. _buildStoresSection() NOT called (only shown for seller)
3. StoresDisplayCubit.loadStores() NEVER triggered
4. StoresDisplayCubit state remains StoresDisplayInitial
5. Button logic: if (storesState is StoresDisplayLoaded) → fails
6. Falls back to user.stores (stale data)
```

### Issue 2: Role not persisted when selecting store
**Scenario:**
- User switches from customer to seller by selecting a store
- selectedStoreId is saved
- Role is NOT saved
- When navigating to other pages, role reverts to 'customer'

**Root Cause:**
```dart
// In store_selection_bottom_sheet.dart:
✅ Saves: await di.sl<AuthLocalDataSource>().saveSelectedStoreId(store.id)
❌ Missing: await di.sl<AuthRoleCubit>().setRole('seller')
```

## Architecture Analysis

### Current State
- **AuthRoleCubit**: Singleton (registered in auth_injection.dart, provided globally in app.dart)
- **StoresDisplayCubit**: Factory (registered in profile_injection.dart, created locally in main_profile.dart)
- **StoresDisplayCubit**: Has 5-minute cache mechanism
- **Role Storage**: Two-layer system
  - Backend roles (SharedPreferences) - source of truth for permissions
  - Active role (SecureStorage) - user's current choice

### Data Flow
```
Login → Backend returns roles: ['seller', 'customer']
     → getPrimaryRole() checks saved preference
     → If no preference, uses backend's primary role
     → User toggles role → setRole() saves preference
```

## Solution Design

### Fix 1: Load StoresDisplayCubit for all users
**Location:** `lib/features/Profile/presentation/pages/customer/main_profile.dart`

**Change:** In `_buildMenuList()`, trigger `loadStores()` before building button logic

**Implementation:**
```dart
Widget _buildMenuList(BuildContext context, AppLocalizations l10n, UserModel user) {
  return BlocBuilder<AuthRoleCubit, AuthRoleState>(
    builder: (context, roleState) {
      final currentRole = roleState.role;
      final roles = user.roles;

      // ✅ NEW: Load stores for ALL users (not just sellers)
      // This ensures button logic has fresh data
      final storesDisplayCubit = context.read<StoresDisplayCubit>();
      if (storesDisplayCubit.state is StoresDisplayInitial) {
        storesDisplayCubit.loadStores();
      }

      return BlocBuilder<StoresDisplayCubit, StoresDisplayState>(
        builder: (context, storesState) {
          // ... existing button logic
        },
      );
    },
  );
}
```

**Impact Analysis:**
- ✅ Ensures fresh store data for all users
- ✅ Uses existing 5-minute cache, so no performance hit
- ✅ Doesn't affect seller flow (already loads in _buildStoresSection)
- ✅ Minimal code change
- ⚠️ Triggers API call on first profile load for customers with stores
- ✅ Cache prevents repeated calls

### Fix 2: Save role when selecting store
**Location:** `lib/features/Profile/presentation/widgets/store_selection_bottom_sheet.dart`

**Change:** In `_handleStoreTap()`, save role after saving store ID

**Implementation:**
```dart
Future<void> _handleStoreTap(UserStoreModel store) async {
  // ... existing validation code ...

  setState(() => _selectingId = store.id);

  try {
    // Save selected store ID
    await di.sl<AuthLocalDataSource>().saveSelectedStoreId(store.id);
    
    // ✅ NEW: Save role to persist seller mode
    await di.sl<AuthRoleCubit>().setRole('seller');

    if (!mounted) return;

    // Close bottom sheet
    Navigator.of(context).pop();

    // Navigate to seller_store_page
    context.push(
      AppRouter.sellerStore,
      extra: {'isGuest': false, 'isPending': false},
    );
  } catch (e) {
    // ... existing error handling ...
  }
}
```

**Impact Analysis:**
- ✅ Persists role choice across navigation
- ✅ Matches user intent (selecting store = becoming seller)
- ✅ Uses existing AuthRoleCubit.setRole() method
- ✅ No breaking changes to existing flows
- ✅ Consistent with role toggle behavior

## Side Effects Analysis

### Performance Impact
- **Fix 1:** Minimal - uses existing cache, only loads once per 5 minutes
- **Fix 2:** None - just adds one storage write operation

### User Experience Impact
- **Fix 1:** Positive - button works correctly for all scenarios
- **Fix 2:** Positive - role persists as expected

### Backward Compatibility
- ✅ No breaking changes
- ✅ Existing seller flow unchanged
- ✅ Existing customer flow enhanced
- ✅ No database schema changes
- ✅ No API changes

### Edge Cases Handled
1. **Customer with no stores:** Button shows "Become Merchant" ✅
2. **Customer with pending store:** Button shows "Track Request" ✅
3. **Customer with active stores:** Button shows "Switch to Merchant" ✅
4. **Seller with multiple stores:** Shows store selection ✅
5. **Network failure:** Uses cached data ✅
6. **Cache expiry:** Refreshes automatically ✅

## Testing Strategy

### Manual Testing Scenarios
1. **Direct customer login:**
   - Login as customer with stores
   - Click "Become Merchant" button
   - Verify store selection appears
   - Select store
   - Verify navigation to seller dashboard
   - Navigate to profile
   - Verify still in seller mode ✅

2. **Seller to customer switch:**
   - Login as seller
   - Switch to customer mode
   - Click "Become Merchant" button
   - Verify works correctly ✅

3. **Store selection persistence:**
   - Select store from bottom sheet
   - Navigate to other pages
   - Return to profile
   - Verify still in seller mode ✅

4. **Cache behavior:**
   - Load profile (triggers API)
   - Reload profile within 5 minutes (uses cache)
   - Wait 5+ minutes, reload (triggers API) ✅

## Implementation Checklist

### Phase 1: Fix StoresDisplayCubit Loading
- [ ] Modify `_buildMenuList()` in main_profile.dart
- [ ] Add loadStores() trigger for all users
- [ ] Test with direct customer login
- [ ] Test with seller to customer switch
- [ ] Verify cache behavior

### Phase 2: Fix Role Persistence
- [ ] Modify `_handleStoreTap()` in store_selection_bottom_sheet.dart
- [ ] Add setRole('seller') after saveSelectedStoreId()
- [ ] Test store selection flow
- [ ] Test navigation persistence
- [ ] Test app restart persistence

### Phase 3: Verification
- [ ] Run all manual test scenarios
- [ ] Check diagnostics for errors
- [ ] Verify no performance regression
- [ ] Verify no breaking changes

## Files to Modify

1. **lib/features/Profile/presentation/pages/customer/main_profile.dart**
   - Modify `_buildMenuList()` method
   - Add StoresDisplayCubit loading logic

2. **lib/features/Profile/presentation/widgets/store_selection_bottom_sheet.dart**
   - Modify `_handleStoreTap()` method
   - Add role persistence logic

## Success Criteria

✅ Button works correctly for direct customer login
✅ Role persists after store selection
✅ No performance degradation
✅ No breaking changes to existing flows
✅ All edge cases handled
✅ Cache mechanism works as expected

## Risks & Mitigation

### Risk 1: Loading stores for all users increases API calls
**Mitigation:** 5-minute cache prevents excessive calls

### Risk 2: Role change might affect other flows
**Mitigation:** Uses existing setRole() method, well-tested

### Risk 3: Race conditions in async operations
**Mitigation:** Proper await/async handling, state checks

## Notes

- This fix addresses root causes, not symptoms
- Solution is minimal and focused
- Uses existing architecture patterns
- No new dependencies required
- Backward compatible
