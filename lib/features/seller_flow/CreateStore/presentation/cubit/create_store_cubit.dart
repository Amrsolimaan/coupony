import 'package:coupony/core/services/location_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../../../auth/data/datasources/auth_local_data_source.dart';
import '../../../../auth/data/models/user_store_model.dart';
import '../../domain/entities/social_link_entity.dart';
import '../../domain/use_cases/create_store_use_case.dart';
import '../../domain/use_cases/get_categories_use_case.dart';
import '../../domain/use_cases/get_social_platforms_use_case.dart';
import '../../domain/use_cases/get_stores_use_case.dart';
import '../../domain/use_cases/update_store_use_case.dart';
import 'create_store_state.dart';

class CreateStoreCubit extends Cubit<CreateStoreState> {
  final CreateStoreUseCase createStoreUseCase;
  final UpdateStoreUseCase updateStoreUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetSocialPlatformsUseCase getSocialPlatformsUseCase;
  final GetStoresUseCase getStoresUseCase;
  final LocationService locationService;
  final AuthLocalDataSource authLocalDataSource;
  final Logger logger;

  CreateStoreCubit({
    required this.createStoreUseCase,
    required this.updateStoreUseCase,
    required this.getCategoriesUseCase,
    required this.getSocialPlatformsUseCase,
    required this.getStoresUseCase,
    required this.locationService,
    required this.authLocalDataSource,
    required this.logger,
  }) : super(const CreateStoreState()) {
    fetchCategories();
    fetchSocialPlatforms();
  }

  void _safeEmit(CreateStoreState s) {
    if (!isClosed) emit(s);
  }

  // ═══════════════════════════════════════════════════════════
  // FETCH STORE DETAILS (for edit mode)
  // ═══════════════════════════════════════════════════════════

  /// Fetches the full store details from GET /api/v1/stores
  /// Returns the first store found (typically the user's store)
  Future<UserStoreModel?> fetchStoreDetails() async {
    logger.i('Fetching store details from GET /api/v1/stores');
    _safeEmit(state.copyWith(isSubmitting: true));

    final result = await getStoresUseCase();

    return result.fold(
      (failure) {
        logger.e('GetStores failed: ${failure.message}');
        _safeEmit(state.copyWith(
          isSubmitting: false,
          errorKey: failure.message,
        ));
        return null;
      },
      (stores) {
        logger.i('Fetched ${stores.length} stores');
        _safeEmit(state.copyWith(isSubmitting: false));
        return stores.isNotEmpty ? stores.first : null;
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CATEGORIES
  // ═══════════════════════════════════════════════════════════

  Future<void> fetchCategories() async {
    _safeEmit(state.copyWith(isCategoriesLoading: true));

    final result = await getCategoriesUseCase();

    result.fold(
      (failure) {
        logger.w('GetCategories failed: ${failure.message}');
        _safeEmit(state.copyWith(
          isCategoriesLoading: false,
          categoriesErrorKey: failure.message,
        ));
      },
      (categories) {
        logger.i('Fetched ${categories.length} categories');
        _safeEmit(state.copyWith(
          isCategoriesLoading: false,
          categories: categories,
        ));
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SOCIAL PLATFORMS
  // ═══════════════════════════════════════════════════════════

  Future<void> fetchSocialPlatforms() async {
    _safeEmit(state.copyWith(isSocialPlatformsLoading: true));

    final result = await getSocialPlatformsUseCase();

    result.fold(
      (failure) {
        logger.w('GetSocialPlatforms failed: ${failure.message}');
        _safeEmit(state.copyWith(
          isSocialPlatformsLoading: false,
          socialPlatformsErrorKey: failure.message,
        ));
      },
      (platforms) {
        logger.i('Fetched ${platforms.length} social platforms');
        _safeEmit(state.copyWith(
          isSocialPlatformsLoading: false,
          socialPlatforms: platforms,
        ));
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SOCIAL LINKS
  // ═══════════════════════════════════════════════════════════

  void addSocialLink({required int socialId, required String link}) {
    final updated = [...state.socialLinks, SocialLinkEntity(socialId: socialId, link: link)];
    _safeEmit(state.copyWith(socialLinks: updated));
    logger.d('Social link added: socialId=$socialId');
  }

  void removeSocialLink(int index) {
    if (index < 0 || index >= state.socialLinks.length) return;
    final updated = List<SocialLinkEntity>.from(state.socialLinks)..removeAt(index);
    _safeEmit(state.copyWith(socialLinks: updated));
    logger.d('Social link removed at index $index');
  }

  void updateSocialLink(int index, {int? socialId, String? link}) {
    if (index < 0 || index >= state.socialLinks.length) return;
    final updated = List<SocialLinkEntity>.from(state.socialLinks);
    updated[index] = updated[index].copyWith(socialId: socialId, link: link);
    _safeEmit(state.copyWith(socialLinks: updated));
  }

  // ═══════════════════════════════════════════════════════════
  // LOCATION
  // ═══════════════════════════════════════════════════════════

  Future<void> determinePosition() async {
    _safeEmit(state.copyWith(isLocationLoading: true, errorKey: null));

    // 1. Check if GPS is enabled
    final serviceEnabled = await locationService.isLocationServiceEnabled();
    if (!serviceEnabled) {
      logger.w('GPS disabled — cannot fetch location');
      _safeEmit(state.copyWith(
        isLocationLoading: false,
        errorKey: 'error_create_store_location_gps_off',
      ));
      return;
    }

    // 2. Check / request permission
    var status = await locationService.checkPermissionStatus();
    if (status == LocationPermissionStatus.denied) {
      status = await locationService.requestPermission();
    }

    if (status == LocationPermissionStatus.permanentlyDenied ||
        status == LocationPermissionStatus.denied ||
        status == LocationPermissionStatus.serviceDisabled ||
        status == LocationPermissionStatus.error) {
      logger.w('Location permission not granted: $status');
      _safeEmit(state.copyWith(
        isLocationLoading: false,
        errorKey: 'error_create_store_location_denied',
      ));
      return;
    }

    // 3. Fetch position
    final position = await locationService.getCurrentPosition();
    if (position == null) {
      logger.e('getCurrentPosition returned null');
      _safeEmit(state.copyWith(
        isLocationLoading: false,
        errorKey: 'error_create_store_location_failed',
      ));
      return;
    }

    logger.i('Location fetched: ${position.latitude}, ${position.longitude}');
    _safeEmit(state.copyWith(
      isLocationLoading: false,
      latitude: position.latitude.toString(),
      longitude: position.longitude.toString(),
      errorKey: null,
    ));
  }

  // ═══════════════════════════════════════════════════════════
  // SUBMISSION
  // ═══════════════════════════════════════════════════════════

  Future<void> createStore(CreateStoreParams params) async {
    // ── Client-side validation ─────────────────────────────────────────────
    if (params.name.trim().isEmpty) {
      _safeEmit(state.copyWith(errorKey: 'error_create_store_name_required'));
      return;
    }
    if (params.phone.trim().isEmpty) {
      _safeEmit(state.copyWith(errorKey: 'error_create_store_phone_required'));
      return;
    }
    if (params.categoryId == 0) {
      _safeEmit(state.copyWith(errorKey: 'error_create_store_category_required'));
      return;
    }

    logger.i('Submitting createStore for "${params.name}"');
    _safeEmit(state.copyWith(isSubmitting: true, errorKey: null, successKey: null));

    final result = await createStoreUseCase(params);

    await result.fold(
      (failure) async {
        logger.e('CreateStore API failed: ${failure.message}');
        _safeEmit(state.copyWith(
          isSubmitting: false,
          errorKey: failure.message,
        ));
      },
      (_) async {
        logger.i('Store created successfully ✅');

        // Persist the scoped flag ({userId}_is_store_created).
        // Wrapped in try-catch: a cache failure (e.g. SecureStorage unavailable
        // on first launch) must NOT leave the UI stuck in isSubmitting=true.
        // The API call has already succeeded — navigation proceeds regardless.
        try {
          await authLocalDataSource.cacheStoreCreated(true);
          logger.i('storeCreated flag persisted ✅');
        } catch (e) {
          logger.w('cacheStoreCreated failed (non-fatal, proceeding): $e');
        }

        // Navigation emit is the absolute last step, guaranteed to run.
        _safeEmit(state.copyWith(
          isSubmitting: false,
          successKey: 'success_create_store',
          navigationSignal: CreateStoreNavigation.toStoreUnderReview,
        ));
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // UPDATE STORE
  // ═══════════════════════════════════════════════════════════

  Future<void> updateStore(String storeId, CreateStoreParams params) async {
    if (params.name.trim().isEmpty) {
      _safeEmit(state.copyWith(errorKey: 'error_create_store_name_required'));
      return;
    }
    if (params.phone.trim().isEmpty) {
      _safeEmit(state.copyWith(errorKey: 'error_create_store_phone_required'));
      return;
    }

    logger.i('Submitting updateStore for store "$storeId"');
    _safeEmit(state.copyWith(isSubmitting: true, errorKey: null, successKey: null));

    final result = await updateStoreUseCase(storeId, params);

    result.fold(
      (failure) {
        logger.e('UpdateStore API failed: ${failure.message}');
        _safeEmit(state.copyWith(
          isSubmitting: false,
          errorKey: failure.message,
        ));
      },
      (_) {
        logger.i('Store updated successfully ✅');
        _safeEmit(state.copyWith(
          isSubmitting: false,
          successKey: 'success_update_store',
          navigationSignal: CreateStoreNavigation.toMerchantStatus,
        ));
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════

  void clearNavigationSignal() {
    _safeEmit(state.copyWith(navigationSignal: CreateStoreNavigation.none));
  }


  void clearMessages() {
    _safeEmit(state.copyWith(errorKey: null, successKey: null));
  }

  void setLocation(String lat, String lng) {
    _safeEmit(state.copyWith(latitude: lat, longitude: lng));
    logger.i('Location set from map: $lat, $lng');
  }
}
