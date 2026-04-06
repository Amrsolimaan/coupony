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
    super.isStoreCreated,
  });

  /// Handles both flat { first_name, access_token } and nested { data: {...} }
  /// responses, as indicated by the Login Postman test script:
  ///   jsonData.data.access_token  OR  jsonData.access_token
  factory UserModel.fromJson(Map<String, dynamic> json) {
    print('🔍 UserModel.fromJson - Raw JSON: $json');

    final data = json['data'] as Map<String, dynamic>? ?? json;
    print('🔍 UserModel.fromJson - Processed data: $data');

    // استخراج بيانات المستخدم من user object إذا كان موجود
    // ⚠️ MUST be extracted BEFORE the flag checks so all three nesting levels
    //    (root → data → data.user) are covered in the fallback chain.
    final userObject = data['user'] as Map<String, dynamic>?;
    final userInfo = userObject ?? data;

    // فحص is_onboarding_completed في المكانين الثلاثة: root, data, data.user
    final onboardingFromRoot = json['is_onboarding_completed'] as bool?;
    final onboardingFromData = data['is_onboarding_completed'] as bool?;
    final onboardingFromUser = userObject?['is_onboarding_completed'] as bool?;
    final finalOnboardingStatus = onboardingFromRoot ?? onboardingFromData ?? onboardingFromUser ?? false;

    print('🎯 UserModel.fromJson - is_onboarding_completed:');
    print('  - From root: $onboardingFromRoot');
    print('  - From data: $onboardingFromData');
    print('  - From data.user: $onboardingFromUser');
    print('  - Final value: $finalOnboardingStatus');

    // فحص is_store_created في المكانين الثلاثة: root, data, data.user
    final storeCreatedFromRoot = json['is_store_created'] as bool?;
    final storeCreatedFromData = data['is_store_created'] as bool?;
    final storeCreatedFromUser = userObject?['is_store_created'] as bool?;
    final finalStoreCreated = storeCreatedFromRoot ?? storeCreatedFromData ?? storeCreatedFromUser ?? false;
    print('🎯 UserModel.fromJson - is_store_created:');
    print('  - From root: $storeCreatedFromRoot');
    print('  - From data: $storeCreatedFromData');
    print('  - From data.user: $storeCreatedFromUser');
    print('  - Final value: $finalStoreCreated');
    
    // 🔍 Enhanced role extraction with detailed logging
    // Try multiple locations: root level, data level, and user object level
    // Also handle 'roles' array from backend
    final roleFromRoot = json['role'] as String?;
    final roleFromData = data['role'] as String?;
    final roleFromUser = userObject?['role'] as String?;
    final roleFromUserInfo = userInfo['role'] as String?;
    
    // 🔧 NEW: Handle 'roles' array from backend
    // Backend returns: "roles": ["seller_pending", "customer"]
    // We need to extract the primary role
    final rolesArray = userInfo['roles'] as List<dynamic>?;
    String? roleFromArray;
    if (rolesArray != null && rolesArray.isNotEmpty) {
      // Priority: seller_pending > seller > customer > user
      if (rolesArray.contains('seller_pending') || rolesArray.contains('seller')) {
        roleFromArray = 'seller';
      } else if (rolesArray.contains('customer')) {
        roleFromArray = 'customer';
      } else {
        roleFromArray = rolesArray.first.toString();
      }
    }
    
    final finalRole = roleFromRoot ?? roleFromData ?? roleFromUser ?? roleFromUserInfo ?? roleFromArray ?? 'user';
    
    print('🎯 UserModel.fromJson - ROLE DETECTION:');
    print('  - From root (json[\'role\']): $roleFromRoot');
    print('  - From data (data[\'role\']): $roleFromData');
    print('  - From userObject (userObject[\'role\']): $roleFromUser');
    print('  - From userInfo (userInfo[\'role\']): $roleFromUserInfo');
    print('  - From roles array (userInfo[\'roles\']): $rolesArray');
    print('  - Extracted role from array: $roleFromArray');
    print('  - Final role value: $finalRole');
    
    final userModel = UserModel(
      id:           0, // Backend uses UUID, we'll keep as 0 for now
      firstName:    userInfo['profile']?['first_name'] as String? ?? '',
      lastName:     userInfo['profile']?['last_name'] as String? ?? '',
      email:        userInfo['email'] as String? ?? '',
      phoneNumber:  userInfo['phone_number'] as String? ?? '',
      role:         finalRole,
      // Token can be at root or nested under data
      accessToken:  json['access_token']  as String?
                 ?? data['access_token']  as String?,
      refreshToken: json['refresh_token'] as String?
                 ?? data['refresh_token'] as String?,
      fcmToken:     data['fcm_token'] as String?,
      isOnboardingCompleted: finalOnboardingStatus,
      isStoreCreated: finalStoreCreated,
    );

    print('✅ UserModel created successfully:');
    print('  - Role: ${userModel.role}');
    print('  - isOnboardingCompleted: ${userModel.isOnboardingCompleted}');
    print('  - isStoreCreated: ${userModel.isStoreCreated}');
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
    'is_store_created':        isStoreCreated,
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
    bool? isStoreCreated,
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
      isStoreCreated:        isStoreCreated        ?? this.isStoreCreated,
    );
  }
}
