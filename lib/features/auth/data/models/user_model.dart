import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phoneNumber,
    super.role,
    super.accessToken,
    super.refreshToken,
    super.fcmToken,
  });

  /// Handles both flat { first_name, access_token } and nested { data: {...} }
  /// responses, as indicated by the Login Postman test script:
  ///   jsonData.data.access_token  OR  jsonData.access_token
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return UserModel(
      id:           data['id'] as int? ?? 0,
      firstName:    data['first_name'] as String? ?? '',
      lastName:     data['last_name']  as String? ?? '',
      email:        data['email']      as String? ?? '',
      phoneNumber:  data['phone_number'] as String? ?? '',
      role:         data['role']       as String? ?? 'user',
      // Token can be at root or nested under data
      accessToken:  json['access_token']  as String?
                 ?? data['access_token']  as String?,
      refreshToken: json['refresh_token'] as String?
                 ?? data['refresh_token'] as String?,
      fcmToken:     data['fcm_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':           id,
    'first_name':   firstName,
    'last_name':    lastName,
    'email':        email,
    'phone_number': phoneNumber,
    'role':         role,
    'access_token':  accessToken,
    'refresh_token': refreshToken,
    'fcm_token':     fcmToken,
  };

  UserModel copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? role,
    String? accessToken,
    String? refreshToken,
    String? fcmToken,
  }) {
    return UserModel(
      id:           id           ?? this.id,
      firstName:    firstName    ?? this.firstName,
      lastName:     lastName     ?? this.lastName,
      email:        email        ?? this.email,
      phoneNumber:  phoneNumber  ?? this.phoneNumber,
      role:         role         ?? this.role,
      accessToken:  accessToken  ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      fcmToken:     fcmToken     ?? this.fcmToken,
    );
  }
}
