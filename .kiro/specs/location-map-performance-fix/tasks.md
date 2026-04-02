# Implementation Plan

- [x] 1. Write bug condition exploration test
  - **Property 1: Bug Condition** - Map Loading Performance and Address Formatting
  - **CRITICAL**: This test MUST FAIL on unfixed code - failure confirms the bug exists
  - **DO NOT attempt to fix the test or the code when it fails**
  - **NOTE**: This test encodes the expected behavior - it will validate the fix when it passes after implementation
  - **GOAL**: Surface counterexamples that demonstrate the bug exists
  - **Scoped PBT Approach**: For deterministic bugs, scope the property to the concrete failing case(s) to ensure reproducibility
  - Test that map loading takes more than 5 seconds due to onCameraIdle + 500ms delay
  - Test that address contains "Placemark", "coordinates", or "null" values
  - Run test on UNFIXED code
  - **EXPECTED OUTCOME**: Test FAILS (this is correct - it proves the bug exists)
  - Document counterexamples found to understand root cause
  - Mark task complete when test is written, run, and failure is documented
  - _Requirements: 1.1, 1.2, 1.3, 1.4_

- [x] 2. Write preservation property tests (BEFORE implementing fix)
  - **Property 2: Preservation** - Map Interaction and Navigation Behavior
  - **IMPORTANT**: Follow observation-first methodology
  - Observe behavior on UNFIXED code for non-buggy inputs
  - Test that map tap updates marker position and fetches address
  - Test that "Use Current Location" button moves camera to user position
  - Test that search functionality finds and navigates to locations
  - Test that network banner appears when connection is lost
  - Test that location confirmation navigates to notification screen
  - Write property-based tests capturing observed behavior patterns from Preservation Requirements
  - Property-based testing generates many test cases for stronger guarantees
  - Run tests on UNFIXED code
  - **EXPECTED OUTCOME**: Tests PASS (this confirms baseline behavior to preserve)
  - Mark task complete when tests are written, run, and passing on unfixed code
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7_

- [x] 3. Fix for map loading performance and address formatting

  - [x] 3.1 Optimize map loading strategy using onMapCreated
    - Remove dependency on onCameraIdle for hiding loading overlay
    - Use onMapCreated callback to hide loading immediately when map controller is ready
    - Add short timeout (300-500ms) as safety net only
    - Update _isMapLoading state in onMapCreated instead of onCameraIdle
    - _Bug_Condition: isBugCondition(input) where input.type == MapLoadEvent AND input.loadingTime > 2000ms_
    - _Expected_Behavior: result.loadingTime <= 2000ms using onMapCreated_
    - _Preservation: Map interaction, navigation, and all existing functionality must remain unchanged_
    - _Requirements: 2.1, 2.2, 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7_

  - [x] 3.2 Create address formatting function (_formatAddress)
    - Add new function _formatAddress(List<Placemark> placemarks) to _LocationMapPageState
    - Extract only relevant fields: street, subLocality, locality, administrativeArea, country
    - Filter out null values and empty strings
    - Join fields with Arabic comma separator (، )
    - Return "موقع غير معروف" if no valid fields found
    - _Bug_Condition: isBugCondition(input) where input.type == AddressFetchEvent AND input.address contains technical symbols_
    - _Expected_Behavior: result.address matches clean format without coordinates or symbols_
    - _Preservation: All geocoding calls must continue to work correctly_
    - _Requirements: 2.3, 2.4, 3.1, 3.2, 3.3_

  - [x] 3.3 Update all geocoding calls to use formatted addresses
    - Update onTap handler to use _formatAddress when fetching address
    - Update "Use Current Location" button handler to use _formatAddress
    - Update search location handler to use _formatAddress
    - Ensure all address displays show clean formatted text
    - _Bug_Condition: isBugCondition(input) where address contains "Placemark" or "null"_
    - _Expected_Behavior: All addresses display clean human-readable text_
    - _Preservation: Search, tap, and current location features must work identically_
    - _Requirements: 2.3, 2.4, 3.1, 3.2, 3.3_

  - [x] 3.4 Improve error handling with formatted fallback
    - When geocoding fails, display formatted coordinates instead of technical error
    - Use localization for fallback messages
    - Format: "الموقع: XX.XXXX° شمالاً، YY.YYYY° شرقاً"
    - Add try-catch blocks around all geocoding calls
    - _Bug_Condition: isBugCondition(input) where geocoding fails and shows technical error_
    - _Expected_Behavior: Display clean formatted coordinates as fallback_
    - _Preservation: Error handling must not break existing functionality_
    - _Requirements: 2.3, 2.4, 3.4_

  - [x] 3.5 Verify bug condition exploration test now passes
    - **Property 1: Expected Behavior** - Fast Loading and Clean Addresses
    - **IMPORTANT**: Re-run the SAME test from task 1 - do NOT write a new test
    - The test from task 1 encodes the expected behavior
    - When this test passes, it confirms the expected behavior is satisfied
    - Run bug condition exploration test from step 1
    - **EXPECTED OUTCOME**: Test PASSES (confirms bug is fixed)
    - _Requirements: Expected Behavior Properties from design_

  - [x] 3.6 Verify preservation tests still pass
    - **Property 2: Preservation** - Map Interaction Unchanged
    - **IMPORTANT**: Re-run the SAME tests from task 2 - do NOT write new tests
    - Run preservation property tests from step 2
    - **EXPECTED OUTCOME**: Tests PASS (confirms no regressions)
    - Confirm all tests still pass after fix (no regressions)

- [x] 4. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.
