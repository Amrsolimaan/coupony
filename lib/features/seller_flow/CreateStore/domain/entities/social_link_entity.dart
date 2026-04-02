import 'package:equatable/equatable.dart';

/// Represents a social media link attached to a store.
class SocialLinkEntity extends Equatable {
  final int socialId;
  final String link;

  const SocialLinkEntity({
    required this.socialId,
    required this.link,
  });

  SocialLinkEntity copyWith({int? socialId, String? link}) {
    return SocialLinkEntity(
      socialId: socialId ?? this.socialId,
      link: link ?? this.link,
    );
  }

  @override
  List<Object?> get props => [socialId, link];
}
