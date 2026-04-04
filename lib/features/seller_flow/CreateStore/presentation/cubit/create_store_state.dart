import 'package:equatable/equatable.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/social_link_entity.dart';

enum CreateStoreNavigation { none, toMerchantDashboard, toHome }

class CreateStoreState extends Equatable {
  // ── Categories (fetched from API) ──────────────────────────────────────
  final List<CategoryEntity> categories;
  final bool isCategoriesLoading;
  final String? categoriesErrorKey;

  // ── Social links (managed dynamically) ────────────────────────────────
  final List<SocialLinkEntity> socialLinks;

  // ── Location ──────────────────────────────────────────────────────────
  final bool isLocationLoading;
  final String latitude;
  final String longitude;

  // ── Submission ────────────────────────────────────────────────────────
  final bool isSubmitting;
  final String? errorKey;
  final String? successKey;

  // ── Navigation ────────────────────────────────────────────────────────
  final CreateStoreNavigation navigationSignal;

  const CreateStoreState({
    this.categories = const [],
    this.isCategoriesLoading = false,
    this.categoriesErrorKey,
    this.socialLinks = const [],
    this.isLocationLoading = false,
    this.latitude = '',
    this.longitude = '',
    this.isSubmitting = false,
    this.errorKey,
    this.successKey,
    this.navigationSignal = CreateStoreNavigation.none,
  });

  CreateStoreState copyWith({
    List<CategoryEntity>? categories,
    bool? isCategoriesLoading,
    String? categoriesErrorKey,
    List<SocialLinkEntity>? socialLinks,
    bool? isLocationLoading,
    String? latitude,
    String? longitude,
    bool? isSubmitting,
    String? errorKey,
    String? successKey,
    CreateStoreNavigation? navigationSignal,
  }) {
    return CreateStoreState(
      categories: categories ?? this.categories,
      isCategoriesLoading: isCategoriesLoading ?? this.isCategoriesLoading,
      categoriesErrorKey: categoriesErrorKey,
      socialLinks: socialLinks ?? this.socialLinks,
      isLocationLoading: isLocationLoading ?? this.isLocationLoading,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorKey: errorKey,
      successKey: successKey,
      navigationSignal: navigationSignal ?? this.navigationSignal,
    );
  }

  @override
  List<Object?> get props => [
        categories,
        isCategoriesLoading,
        categoriesErrorKey,
        socialLinks,
        isLocationLoading,
        latitude,
        longitude,
        isSubmitting,
        errorKey,
        successKey,
        navigationSignal,
      ];
}
