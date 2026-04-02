import 'package:coupony/core/services/location_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/social_link_entity.dart';
import '../../domain/use_cases/create_store_use_case.dart';
import '../../domain/use_cases/get_categories_use_case.dart';
import 'create_store_state.dart';

class CreateStoreCubit extends Cubit<CreateStoreState> {
  final CreateStoreUseCase createStoreUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final LocationService locationService;
  final Logger logger;

  CreateStoreCubit({
    required this.createStoreUseCase,
    required this.getCategoriesUseCase,
    required this.locationService,
    required this.logger,
  }) : super(const CreateStoreState()) {
    fetchCategories();
  }

  void _safeEmit(CreateStoreState s) {
    if (!isClosed) emit(s);
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
    if (params.addressLine1.trim().isEmpty) {
      _safeEmit(state.copyWith(errorKey: 'error_create_store_address_required'));
      return;
    }
    if (params.categoryIds.isEmpty) {
      _safeEmit(state.copyWith(errorKey: 'error_create_store_category_required'));
      return;
    }

    logger.i('Submitting createStore for "${params.name}"');
    _safeEmit(state.copyWith(isSubmitting: true, errorKey: null, successKey: null));

    final result = await createStoreUseCase(params);

    result.fold(
      (failure) {
        logger.e('CreateStore API failed: ${failure.message}');
        _safeEmit(state.copyWith(
          isSubmitting: false,
          errorKey: failure.message,
        ));
      },
      (_) {
        logger.i('Store created successfully ✅');
        _safeEmit(state.copyWith(
          isSubmitting: false,
          successKey: 'success_create_store',
          navigationSignal: CreateStoreNavigation.toMerchantDashboard,
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
}
