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
    super.isOnboardingCompleted,
  });

  /// Handles both flat { first_name, access_token } and nested { data: {...} }
  /// responses, as indicated by the Login Postman test script:
  ///   jsonData.data.access_token  OR  jsonData.access_token
  factory UserModel.fromJson(Map<String, dynamic> json) {
    print('🔍 UserModel.fromJson - Raw JSON: $json');
    
    final data = json['data'] as Map<String, dynamic>? ?? json;
    print('🔍 UserModel.fromJson - Processed data: $data');
    
    // فحص is_onboarding_completed في المكانين (root level و data level)
    final onboardingFromRoot = json['is_onboarding_completed'] as bool?;
    final onboardingFromData = data['is_onboarding_completed'] as bool?;
    final finalOnboardingStatus = onboardingFromRoot ?? onboardingFromData ?? false;
    
    print('🎯 UserModel.fromJson - is_onboarding_completed:');
    print('  - From root: $onboardingFromRoot');
    print('  - From data: $onboardingFromData');
    print('  - Final value: $finalOnboardingStatus');
    
    // استخراج بيانات المستخدم من user object إذا كان موجود
    final userObject = data['user'] as Map<String, dynamic>?;
    final userInfo = userObject ?? data;
    
    final userModel = UserModel(
      id:           0, // Backend uses UUID, we'll keep as 0 for now
      firstName:    userInfo['profile']?['first_name'] as String? ?? '',
      lastName:     userInfo['profile']?['last_name'] as String? ?? '',
      email:        userInfo['email'] as String? ?? '',
      phoneNumber:  userInfo['phone_number'] as String? ?? '',
      role:         json['role'] as String? ?? data['role'] as String? ?? 'user',
      // Token can be at root or nested under data
      accessToken:  json['access_token']  as String?
                 ?? data['access_token']  as String?,
      refreshToken: json['refresh_token'] as String?
                 ?? data['refresh_token'] as String?,
      fcmToken:     data['fcm_token'] as String?,
      isOnboardingCompleted: finalOnboardingStatus,
    );
    
    print('✅ UserModel created successfully - Final isOnboardingCompleted: ${userModel.isOnboardingCompleted}');
    return userModel;
  }

  Map<String, dynamic> toJson() => {
    'id':                     id,
    'first_name':             firstName,
    'last_name':              lastName,
    'email':                  email,
    'phone_number':           phoneNumber,
    'role':                   role,
    'access_token':           accessToken,
    'refresh_token':          refreshToken,
    'fcm_token':              fcmToken,
    'is_onboarding_completed': isOnboardingCompleted,
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
    bool? isOnboardingCompleted,
  }) {
    return UserModel(
      id:                   id                   ?? this.id,
      firstName:            firstName             ?? this.firstName,
      lastName:             lastName              ?? this.lastName,
      email:                email                 ?? this.email,
      phoneNumber:          phoneNumber           ?? this.phoneNumber,
      role:                 role                  ?? this.role,
      accessToken:          accessToken           ?? this.accessToken,
      refreshToken:         refreshToken          ?? this.refreshToken,
      fcmToken:             fcmToken              ?? this.fcmToken,
      isOnboardingCompleted: isOnboardingCompleted ?? this.isOnboardingCompleted,
    );
  }
}
