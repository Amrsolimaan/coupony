import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.role,
    super.token,
    super.refreshToken,
    super.fcmToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handles both flat { id, name, token } and nested { data: {...}, token }
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return UserModel(
      id:           data['id'] as int,
      name:         data['name'] as String,
      email:        data['email'] as String,
      phone:        data['phone'] as String,
      role:         data['role'] as String? ?? 'user',
      token:        json['token'] as String? ?? data['token'] as String?,
      refreshToken: json['refresh_token'] as String? ??
                    data['refresh_token'] as String?,
      fcmToken:     data['fcm_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':            id,
    'name':          name,
    'email':         email,
    'phone':         phone,
    'role':          role,
    'token':         token,
    'refresh_token': refreshToken,
    'fcm_token':     fcmToken,
  };

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? token,
    String? refreshToken,
    String? fcmToken,
  }) {
    return UserModel(
      id:           id ?? this.id,
      name:         name ?? this.name,
      email:        email ?? this.email,
      phone:        phone ?? this.phone,
      role:         role ?? this.role,
      token:        token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      fcmToken:     fcmToken ?? this.fcmToken,
    );
  }
}
