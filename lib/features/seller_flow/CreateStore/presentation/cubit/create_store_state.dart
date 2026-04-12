import 'package:equatable/equatable.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/social_link_entity.dart';
import '../../domain/entities/social_platform_entity.dart';

enum CreateStoreNavigation { none, toMerchantDashboard, toStoreUnderReview, toMerchantStatus }

class CreateStoreState extends Equatable {
  // ── Categories (fetched from API) ──────────────────────────────────────
  final List<CategoryEntity> categories;
  final bool isCategoriesLoading;
  final String? categoriesErrorKey;

  // ── Social Platforms (fetched from API) ───────────────────────────────
  final List<SocialPlatformEntity> socialPlatforms;
  final bool isSocialPlatformsLoading;
  final String? socialPlatformsErrorKey;

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
    this.socialPlatforms = const [],
    this.isSocialPlatformsLoading = false,
    this.socialPlatformsErrorKey,
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
    List<SocialPlatformEntity>? socialPlatforms,
    bool? isSocialPlatformsLoading,
    String? socialPlatformsErrorKey,
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
      socialPlatforms: socialPlatforms ?? this.socialPlatforms,
      isSocialPlatformsLoading: isSocialPlatformsLoading ?? this.isSocialPlatformsLoading,
      socialPlatformsErrorKey: socialPlatformsErrorKey,
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
        socialPlatforms,
        isSocialPlatformsLoading,
        socialPlatformsErrorKey,
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
