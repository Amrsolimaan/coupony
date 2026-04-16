# Implementation Tasks

## Task 1: Fix StoresDisplayCubit Loading for All Users
**Status:** pending
**Priority:** high
**Estimated Time:** 15 minutes

### Description
Modify `_buildMenuList()` to trigger StoresDisplayCubit loading for all users (not just sellers), ensuring the button logic has access to fresh store data.

### Files to Modify
- `lib/features/Profile/presentation/pages/customer/main_profile.dart`

### Implementation Steps
1. Locate `_buildMenuList()` method (around line 960)
2. Add StoresDisplayCubit loading logic before BlocBuilder
3. Check if state is StoresDisplayInitial
4. If yes, trigger loadStores()
5. Ensure this doesn't break existing seller flow

### Code Changes
```dart
Widget _buildMenuList(BuildContext context, AppLocalizations l10n, UserModel user) {
  return BlocBuilder<AuthRoleCubit, AuthRoleState>(
    builder: (context, roleState) {
      final currentRole = roleState.role;
      final roles = user.roles;

      // ✅ NEW: Load stores for ALL users to ensure button has fresh data
      final storesDisplayCubit = context.read<StoresDisplayCubit>();
      if (storesDisplayCubit.state is StoresDisplayInitial) {
        storesDisplayCubit.loadStores();
      }

      return BlocBuilder<StoresDisplayCubit, StoresDisplayState>(
        builder: (context, storesState) {
          // ... rest of existing code unchanged
```

### Testing
- [ ] Login as customer with stores
- [ ] Verify button shows correct label
- [ ] Click button and verify store selection appears
- [ ] Login as seller
- [ ] Verify no regression in seller flow

### Success Criteria
- Button works for direct customer login
- No performance degradation
- Seller flow unchanged

---

## Task 2: Persist Role When Selecting Store
**Status:** pending
**Priority:** high
**Estimated Time:** 10 minutes

### Description
Modify `_handleStoreTap()` in store selection bottom sheet to save the seller role when a store is selected, ensuring role persists across navigation.

### Files to Modify
- `lib/features/Profile/presentation/widgets/store_selection_bottom_sheet.dart`

### Implementation Steps
1. Locate `_handleStoreTap()` method (around line 150)
2. Find the line: `await di.sl<AuthLocalDataSource>().saveSelectedStoreId(store.id);`
3. Add role persistence immediately after
4. Use AuthRoleCubit.setRole('seller')

### Code Changes
```dart
Future<void> _handleStoreTap(UserStoreModel store) async {
  if (_selectingId != null) return;

  // Check if store is active
  if (!store.isActive) {
    // ... existing validation code ...
    return;
  }

  // Store is active - proceed with selection
  setState(() => _selectingId = store.id);

  try {
    // Save selected store ID
    await di.sl<AuthLocalDataSource>().saveSelectedStoreId(store.id);
    
    // ✅ NEW: Save role to persist seller mode across navigation
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
    // ... existing error handling unchanged ...
  }
}
```

### Testing
- [ ] Select store from bottom sheet
- [ ] Navigate to seller dashboard
- [ ] Navigate to profile page
- [ ] Verify still in seller mode
- [ ] Navigate to other pages
- [ ] Return to profile
- [ ] Verify role persisted

### Success Criteria
- Role persists after store selection
- Navigation maintains seller mode
- No breaking changes

---

## Task 3: Integration Testing
**Status:** pending
**Priority:** medium
**Estimated Time:** 20 minutes

### Description
Comprehensive testing of both fixes together to ensure they work correctly in all scenarios.

### Test Scenarios

#### Scenario 1: Direct Customer Login with Stores
1. Logout completely
2. Login as customer who has stores
3. Navigate to profile
4. Verify button shows "Switch to Merchant"
5. Click button
6. Verify store selection bottom sheet appears
7. Select a store
8. Verify navigation to seller dashboard
9. Navigate to profile
10. Verify still in seller mode
11. Navigate to home, then back to profile
12. Verify role persisted

**Expected:** All steps pass ✅

#### Scenario 2: Seller to Customer Switch
1. Login as seller
2. Navigate to profile
3. Click "Switch to Customer"
4. Verify switched to customer mode
5. Click "Switch to Merchant" button
6. Verify store selection appears
7. Select store
8. Verify back in seller mode

**Expected:** All steps pass ✅

#### Scenario 3: Customer with Pending Store
1. Login as customer with pending store
2. Navigate to profile
3. Verify button shows "Track Request"
4. Click button
5. Verify navigates to pending status page

**Expected:** All steps pass ✅

#### Scenario 4: Pure Customer (No Stores)
1. Login as customer with no stores
2. Navigate to profile
3. Verify button shows "Become Merchant"
4. Click button
5. Verify navigates to become merchant page

**Expected:** All steps pass ✅

#### Scenario 5: Cache Behavior
1. Login as customer with stores
2. Navigate to profile (triggers API call)
3. Navigate away and back within 5 minutes
4. Verify uses cached data (no loading indicator)
5. Wait 5+ minutes
6. Navigate to profile again
7. Verify triggers fresh API call

**Expected:** Cache works correctly ✅

### Testing Checklist
- [ ] All scenarios pass
- [ ] No console errors
- [ ] No performance issues
- [ ] No breaking changes
- [ ] Cache mechanism works

---

## Task 4: Code Quality & Diagnostics
**Status:** pending
**Priority:** low
**Estimated Time:** 5 minutes

### Description
Run diagnostics and verify code quality.

### Steps
1. Run `getDiagnostics` on modified files
2. Fix any errors or warnings
3. Verify no new issues introduced

### Files to Check
- `lib/features/Profile/presentation/pages/customer/main_profile.dart`
- `lib/features/Profile/presentation/widgets/store_selection_bottom_sheet.dart`

### Success Criteria
- No errors
- No new warnings
- Code follows project conventions

---

## Summary

**Total Tasks:** 4
**Estimated Total Time:** 50 minutes
**Priority:** High

**Dependencies:**
- Task 2 can be done in parallel with Task 1
- Task 3 requires Task 1 and Task 2 to be completed
- Task 4 can be done after Task 3

**Risk Level:** Low
- Minimal code changes
- Uses existing patterns
- Well-defined scope
- Clear success criteria
