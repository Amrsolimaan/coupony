import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String name;
  final String email;
  final String role; // 'user' or 'merchant'
  final String? token;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.token,
  });

  @override
  List<Object?> get props => [id, name, email, role, token];
}
