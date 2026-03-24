import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String role; // 'user' | 'merchant'
  final String? accessToken;
  final String? refreshToken;
  final String? fcmToken;

  const UserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.role = 'user',
    this.accessToken,
    this.refreshToken,
    this.fcmToken,
  });

  /// Full display name
  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [
    id, firstName, lastName, email, phoneNumber,
    role, accessToken, refreshToken, fcmToken,
  ];
}
