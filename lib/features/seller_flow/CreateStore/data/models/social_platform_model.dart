import '../../domain/entities/social_platform_entity.dart';

/// Data model for social media platform.
/// Maps JSON from API to domain entity.
class SocialPlatformModel extends SocialPlatformEntity {
  const SocialPlatformModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.iconUrl,
  });

  factory SocialPlatformModel.fromJson(Map<String, dynamic> json) {
    return SocialPlatformModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      iconUrl: json['icon'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': iconUrl,
    };
  }
}
