import 'package:equatable/equatable.dart';

/// Represents a social media platform available in the system.
/// Used to display available platforms when user adds social links to their store.
class SocialPlatformEntity extends Equatable {
  final int id;
  final String name;
  final String icon;
  final String iconUrl;

  const SocialPlatformEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.iconUrl,
  });

  @override
  List<Object?> get props => [id, name, icon, iconUrl];
}
