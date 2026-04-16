# Testing Guide - Become Merchant Button Fix

## Overview
This guide provides comprehensive testing scenarios to verify the fixes work correctly in all cases.

---

## Pre-Testing Setup

### Requirements
- ✅ App compiled successfully
- ✅ No diagnostic errors
- ✅ Test accounts ready:
  - Customer with active stores
  - Customer with pending store
  - Customer with no stores
  - Seller with multiple stores

### Environment
- Device: [Your device]
- OS: [Your OS]
- App Version: [Current version]

---

## Test Scenarios

### 🧪 Test 1: Direct Customer Login with Active Stores
**Priority:** HIGH
**Estimated Time:** 3 minutes

#### Steps:
1. **Logout** completely from the app
2. **Login** as customer who has active stores
3. **Navigate** to Profile page
4. **Observe** the "Become Merchant" button
5. **Click** the button
6. **Verify** store selection bottom sheet appears
7. **Select** an active store
8. **Verify** navigation to seller dashboard
9. **Navigate** back to Profile page
10. **Verify** still in seller mode (seller bottom nav visible)
11. **Navigate** to Home, then back to Profile
12. **Verify** role persisted (still seller mode)

#### Expected Results:
- ✅ Button shows "Switch to Merchant" (or Arabic equivalent)
- ✅ Store selection bottom sheet appears with all stores
- ✅ After selection, navigates to seller dashboard
- ✅ Role persists across navigation
- ✅ Seller bottom nav bar visible
- ✅ Profile shows seller UI

#### Pass Criteria:
All steps complete without errors, role persists correctly.

---

### 🧪 Test 2: Seller to Customer Switch and Back
**Priority:** HIGH
**Estimated Time:** 2 minutes

#### Steps:
1. **Login** as seller
2. **Navigate** to Profile page
3. **Verify** in seller mode (seller bottom nav)
4. **Click** "Switch to Customer" button
5. **Verify** switched to customer mode (customer bottom nav)
6. **Click** "Switch to Merchant" button
7. **Verify** store selection appears
8. **Select** a store
9. **Verify** back in seller mode

#### Expected Results:
- ✅ Switch to customer works
- ✅ Button changes to "Switch to Merchant"
- ✅ Store selection appears
- ✅ Switch back to seller works
- ✅ Role persists

#### Pass Criteria:
Role switching works in both directions without issues.

---

### 🧪 Test 3: Customer with Pending Store
**Priority:** MEDIUM
**Estimated Time:** 2 minutes

#### Steps:
1. **Login** as customer with pending store
2. **Navigate** to Profile page
3. **Observe** button label
4. **Click** the button
5. **Verify** navigation to pending status page

#### Expected Results:
- ✅ Button shows "Track Request" (or Arabic equivalent)
- ✅ Clicking navigates to pending status page
- ✅ No errors occur

#### Pass Criteria:
Pending store flow works correctly.

---

### 🧪 Test 4: Customer with Rejected Store
**Priority:** MEDIUM
**Estimated Time:** 2 minutes

#### Steps:
1. **Login** as customer with rejected store
2. **Navigate** to Profile page
3. **Observe** button label
4. **Click** the button
5. **Verify** navigation to rejected status page
6. **Verify** rejection reasons displayed

#### Expected Results:
- ✅ Button shows "Track Request"
- ✅ Clicking navigates to rejected status page
- ✅ Rejection reasons visible
- ✅ No errors occur

#### Pass Criteria:
Rejected store flow works correctly.

---

### 🧪 Test 5: Pure Customer (No Stores)
**Priority:** MEDIUM
**Estimated Time:** 2 minutes

#### Steps:
1. **Login** as customer with no stores
2. **Navigate** to Profile page
3. **Observe** button label
4. **Click** the button
5. **Verify** navigation to "Become Merchant" page

#### Expected Results:
- ✅ Button shows "Become Merchant" (or Arabic equivalent)
- ✅ Clicking navigates to become merchant flow
- ✅ No errors occur

#### Pass Criteria:
New merchant flow works correctly.

---

### 🧪 Test 6: Seller with Multiple Stores
**Priority:** HIGH
**Estimated Time:** 3 minutes

#### Steps:
1. **Login** as seller with multiple stores
2. **Navigate** to Profile page
3. **Verify** stores section visible
4. **Click** "Switch to Merchant" button
5. **Verify** store selection bottom sheet appears
6. **Verify** all stores listed
7. **Select** a different store
8. **Verify** navigation to seller dashboard
9. **Verify** correct store selected

#### Expected Results:
- ✅ All stores visible in profile
- ✅ Store selection shows all stores
- ✅ Can switch between stores
- ✅ Selected store persists
- ✅ No errors occur

#### Pass Criteria:
Multi-store selection works correctly.

---

### 🧪 Test 7: Cache Behavior
**Priority:** LOW
**Estimated Time:** 6 minutes

#### Steps:
1. **Login** as customer with stores
2. **Navigate** to Profile page
3. **Observe** loading indicator (first load)
4. **Navigate** away and back within 5 minutes
5. **Verify** no loading indicator (uses cache)
6. **Wait** 5+ minutes
7. **Navigate** to Profile again
8. **Observe** loading indicator (cache expired)

#### Expected Results:
- ✅ First load triggers API call
- ✅ Subsequent loads within 5 min use cache
- ✅ After 5 min, triggers fresh API call
- ✅ No performance issues

#### Pass Criteria:
Cache mechanism works as designed.

---

### 🧪 Test 8: Network Error Handling
**Priority:** MEDIUM
**Estimated Time:** 2 minutes

#### Steps:
1. **Disable** network connection
2. **Login** (if possible, or use cached session)
3. **Navigate** to Profile page
4. **Click** "Become Merchant" button
5. **Observe** error handling

#### Expected Results:
- ✅ Graceful error message displayed
- ✅ No app crash
- ✅ Can retry after network restored

#### Pass Criteria:
Error handling works correctly.

---

### 🧪 Test 9: Rapid Navigation
**Priority:** LOW
**Estimated Time:** 2 minutes

#### Steps:
1. **Login** as customer with stores
2. **Rapidly navigate** between pages
3. **Click** "Become Merchant" button quickly
4. **Select** store quickly
5. **Navigate** rapidly between pages

#### Expected Results:
- ✅ No race conditions
- ✅ No duplicate API calls
- ✅ State remains consistent
- ✅ No crashes

#### Pass Criteria:
App handles rapid interactions correctly.

---

### 🧪 Test 10: App Restart Persistence
**Priority:** HIGH
**Estimated Time:** 2 minutes

#### Steps:
1. **Login** as customer
2. **Select** a store (become seller)
3. **Close** app completely
4. **Restart** app
5. **Navigate** to Profile
6. **Verify** still in seller mode

#### Expected Results:
- ✅ Role persists after app restart
- ✅ Selected store persists
- ✅ No need to re-select

#### Pass Criteria:
Persistence works across app restarts.

---

## Test Results Template

### Test Execution Log

| Test # | Test Name | Status | Notes | Tester | Date |
|--------|-----------|--------|-------|--------|------|
| 1 | Direct Customer Login | ⏳ | | | |
| 2 | Seller to Customer Switch | ⏳ | | | |
| 3 | Customer with Pending Store | ⏳ | | | |
| 4 | Customer with Rejected Store | ⏳ | | | |
| 5 | Pure Customer | ⏳ | | | |
| 6 | Seller with Multiple Stores | ⏳ | | | |
| 7 | Cache Behavior | ⏳ | | | |
| 8 | Network Error Handling | ⏳ | | | |
| 9 | Rapid Navigation | ⏳ | | | |
| 10 | App Restart Persistence | ⏳ | | | |

**Legend:**
- ⏳ Not Started
- 🔄 In Progress
- ✅ Passed
- ❌ Failed
- ⚠️ Passed with Issues

---

## Bug Report Template

If you find any issues during testing, use this template:

### Bug Report

**Test #:** [Test number]
**Severity:** [Critical / High / Medium / Low]
**Status:** [New / In Progress / Fixed / Closed]

**Description:**
[Clear description of the issue]

**Steps to Reproduce:**
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Expected Result:**
[What should happen]

**Actual Result:**
[What actually happened]

**Screenshots/Logs:**
[Attach if available]

**Environment:**
- Device: [Device name]
- OS: [OS version]
- App Version: [Version]

---

## Success Criteria

### All Tests Must Pass ✅
- No critical bugs
- No high-priority bugs
- Medium/low bugs documented and acceptable

### Performance Acceptable ✅
- No noticeable lag
- Cache works correctly
- API calls minimized

### User Experience Good ✅
- Smooth transitions
- Clear feedback
- No confusing states

---

## Sign-off

**Tested By:** ___________________
**Date:** ___________________
**Overall Status:** [ ] Pass / [ ] Fail
**Notes:** ___________________

---

## Next Steps After Testing

### If All Tests Pass ✅
1. Mark implementation as complete
2. Deploy to production (if applicable)
3. Monitor for issues
4. Close spec

### If Tests Fail ❌
1. Document all failures
2. Analyze root causes
3. Create fix plan
4. Re-test after fixes
5. Repeat until all pass
