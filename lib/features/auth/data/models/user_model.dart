import '../../domain/entities/user_entity.dart';
import 'user_store_model.dart';

class UserModel extends UserEntity {
  /// Raw roles list returned by the backend (e.g. ['seller', 'customer']).
  final List<String> roles;

  /// Stores associated with this seller account, populated from the login
  /// / OTP response. Empty for customer accounts.
  final List<UserStoreModel> stores;

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
    super.avatar,
    super.gender,
    super.bio,
    super.language,
    super.isOnboardingCompleted,
    super.isStoreCreated,
    super.isStoreOwner,
    this.roles  = const [],
    this.stores = const [],
  });

  /// True ONLY when this user is an approved, active seller.
  ///
  /// Rules (all three must hold):
  ///   1. isStoreOwner == true  (backend-confirmed approval)
  ///   2. roles contains 'seller'
  ///   3. roles does NOT contain 'seller_pending'
  ///
  /// A seller_pending user always returns false here and must be treated
  /// as a customer throughout the app until the backend promotes them.
  bool get isActiveSeller =>
      isStoreOwner &&
      roles.contains('seller') &&
      !roles.contains('seller_pending');

  /// Handles flat { first_name, access_token }, nested { data: {...} } and
  /// triple-nested { data: { user: {...} } } API shapes.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    print('🔍 UserModel.fromJson - Raw JSON: $json');

    final data     = json['data'] as Map<String, dynamic>? ?? json;
    final userObject = data['user'] as Map<String, dynamic>?;
    final userInfo   = userObject ?? data;

    // ── is_onboarding_completed ──────────────────────────────────────────────
    final finalOnboardingStatus =
        (json['is_onboarding_completed']       as bool?) ??
        (data['is_onboarding_completed']       as bool?) ??
        (userObject?['is_onboarding_completed'] as bool?) ??
        false;

    // ── is_store_created ─────────────────────────────────────────────────────
    final finalStoreCreated =
        (json['is_store_created']        as bool?) ??
        (data['is_store_created']        as bool?) ??
        (userObject?['is_store_created'] as bool?) ??
        false;

    // ── roles (raw list) ─────────────────────────────────────────────────────
    final rolesRaw  = userInfo['roles'] as List<dynamic>? ?? [];
    final rolesList = rolesRaw.map((e) => e.toString()).toList();

    // ── is_store_owner ───────────────────────────────────────────────────────
    // Parse directly from the API, then fall back to role-based derivation.
    // An approved seller has the 'seller' role WITHOUT 'seller_pending'.
    // A seller_pending user is NOT a store owner yet.
    final bool finalIsStoreOwner =
        (json['is_store_owner']         as bool?) ??
        (data['is_store_owner']         as bool?) ??
        (userObject?['is_store_owner']  as bool?) ??
        // Derived fallback: approved iff they have 'seller' but NOT 'seller_pending'
        (rolesList.contains('seller') && !rolesList.contains('seller_pending'));

    // ── roleFromArray ────────────────────────────────────────────────────────
    // STRICT: seller_pending is NOT 'seller'. Only an approved seller gets
    // 'seller'. This prevents any ambiguity in caching and routing.
    String? roleFromArray;
    if (rolesList.isNotEmpty) {
      if (rolesList.contains('seller') && !rolesList.contains('seller_pending')) {
        roleFromArray = 'seller';          // approved seller
      } else if (rolesList.contains('seller_pending')) {
        roleFromArray = 'seller_pending';  // pending — still a customer functionally
      } else if (rolesList.contains('customer')) {
        roleFromArray = 'customer';
      } else {
        roleFromArray = rolesList.first;
      }
    }

    final finalRole =
        (json['role']        as String?) ??
        (data['role']        as String?) ??
        (userObject?['role'] as String?) ??
        (userInfo['role']    as String?) ??
        roleFromArray ??
        'customer';

    // ── stores ───────────────────────────────────────────────────────────────
    final storesRaw  = userInfo['stores'] as List<dynamic>? ?? [];
    final storesList = UserStoreModel.fromJsonList(storesRaw);

    print('🎯 Role: $finalRole | Roles: $rolesList | Stores: ${storesList.length}');

    final profile = userInfo['profile'] as Map<String, dynamic>?;

    return UserModel(
      id:                    int.tryParse(userInfo['id']?.toString() ?? '') ?? 0,
      firstName:             profile?['first_name'] as String? ?? '',
      lastName:              profile?['last_name']  as String? ?? '',
      email:                 userInfo['email']        as String? ?? '',
      phoneNumber:           userInfo['phone_number'] as String? ?? '',
      role:                  finalRole,
      accessToken:           json['access_token']  as String? ?? data['access_token']  as String?,
      refreshToken:          json['refresh_token'] as String? ?? data['refresh_token'] as String?,
      fcmToken:              data['fcm_token'] as String?,
      avatar:                profile?['avatar']   as String?,
      gender:                profile?['gender']   as String?,
      bio:                   profile?['bio']      as String?,
      language:              profile?['language'] as String?,
      isOnboardingCompleted: finalOnboardingStatus,
      isStoreCreated:        finalStoreCreated,
      isStoreOwner:          finalIsStoreOwner,
      roles:                 rolesList,
      stores:                storesList,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':                      id,
    'first_name':              firstName,
    'last_name':               lastName,
    'email':                   email,
    'phone_number':            phoneNumber,
    'role':                    role,
    'access_token':            accessToken,
    'refresh_token':           refreshToken,
    'fcm_token':               fcmToken,
    'avatar':                  avatar,
    'gender':                  gender,
    'bio':                     bio,
    'language':                language,
    'is_onboarding_completed': isOnboardingCompleted,
    'is_store_created':        isStoreCreated,
    'is_store_owner':          isStoreOwner,
    'roles':                   roles,
    'stores':                  stores.map((s) => s.toJson()).toList(),
  };

  UserModel copyWith({
    int?                  id,
    String?               firstName,
    String?               lastName,
    String?               email,
    String?               phoneNumber,
    String?               role,
    String?               accessToken,
    String?               refreshToken,
    String?               fcmToken,
    String?               avatar,
    String?               gender,
    String?               bio,
    String?               language,
    bool?                 isOnboardingCompleted,
    bool?                 isStoreCreated,
    bool?                 isStoreOwner,
    List<String>?         roles,
    List<UserStoreModel>? stores,
  }) {
    return UserModel(
      id:                    id                    ?? this.id,
      firstName:             firstName             ?? this.firstName,
      lastName:              lastName              ?? this.lastName,
      email:                 email                 ?? this.email,
      phoneNumber:           phoneNumber           ?? this.phoneNumber,
      role:                  role                  ?? this.role,
      accessToken:           accessToken           ?? this.accessToken,
      refreshToken:          refreshToken          ?? this.refreshToken,
      fcmToken:              fcmToken              ?? this.fcmToken,
      avatar:                avatar                ?? this.avatar,
      gender:                gender                ?? this.gender,
      bio:                   bio                   ?? this.bio,
      language:              language              ?? this.language,
      isOnboardingCompleted: isOnboardingCompleted ?? this.isOnboardingCompleted,
      isStoreCreated:        isStoreCreated        ?? this.isStoreCreated,
      isStoreOwner:          isStoreOwner          ?? this.isStoreOwner,
      roles:                 roles                 ?? this.roles,
      stores:                stores                ?? this.stores,
    );
  }
}
