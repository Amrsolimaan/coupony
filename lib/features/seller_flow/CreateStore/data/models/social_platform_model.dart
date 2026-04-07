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
    // الباك إند يرسل icon و icon_url
    // icon يحتوي على URL صحيح
    // icon_url قد يحتوي على URL مكرر، لذلك نستخدم icon
    final iconValue = json['icon'] as String? ?? '';
    
    return SocialPlatformModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      icon: iconValue,
      iconUrl: iconValue, // استخدام icon بدلاً من icon_url لتجنب التكرار
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
