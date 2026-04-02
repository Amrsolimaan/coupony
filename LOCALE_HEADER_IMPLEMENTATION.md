**ACT AS: Senior Lead Flutter Architect**
**OBJECTIVE: COMPLETE 1:1 Mirroring of Data Layer for SellerOnboarding.**

**CONTEXT:** Domain layer is done. Now, populate the empty files in `lib/features/SellerOnboarding/data/` by mirroring `lib/features/CustomerOnboarding/data/`.

**SELLER API DATA 
- Base Endpoint: /api/v1/on-boarding/seller
- POST Body & GET Response Keys:
price_category: [budget, mid_range, premium]

customer_reach_method: [physical_store, online_only]

best_offer_time: [all_week, weekends_occasions, off_peak]

target_audience: [youth, families, all]

**TASK: POPULATE THESE 4 KEY FILES:**

1. **Model (`models/seller_preferences_model.dart`):**
   - Read `user_preferences_model.dart` from Customer.
   - Mirror it, but replace all Customer fields with the 4 Seller fields.
   - Ensure it extends `SellerPreferencesEntity`.
   - Update `fromJson` and `toJson` to use the snake_case keys from the API.

2. **Remote Data Source (`data_sources/seller_onboarding_remote_data_source.dart`):**
   - Mirror `onboarding_remote_data_source.dart`.
   - Update endpoint to: `/api/v1/on-boarding/seller`.
   - Ensure POST and GET methods use the new `SellerPreferencesModel`.

3. **Local Data Source (`data_sources/seller_onboarding_local_data_source.dart`):**
   - Mirror `onboarding_local_data_source.dart`.
   - Change the storage key to something unique like: `CACHED_SELLER_ONBOARDING`.

4. **Repository Implementation (`repositories/seller_onboarding_repository_impl.dart`):**
   - Mirror `onboarding_repository_impl.dart`.
   - Update it to inject the 2 NEW Seller Data Sources.
   - Link all 5 Use Cases logic to the new Seller Remote and Local sources.

**STRICT RULES:**
- NO imports from CustomerOnboarding. All imports must point to the Seller feature.
- Use the same error handling pattern (DioException -> Failure).

**GO: Populate these 4 Data layer files now.**