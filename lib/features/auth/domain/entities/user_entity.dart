import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role; // 'user' | 'merchant'
  final String? token;
  final String? refreshToken;
  final String? fcmToken;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.token,
    this.refreshToken,
    this.fcmToken,
  });

  @override
  List<Object?> get props => [
    id, name, email, phone, role, token, refreshToken, fcmToken,
  ];
}
