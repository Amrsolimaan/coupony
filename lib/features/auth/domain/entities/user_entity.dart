import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String role; // 'seller' | 'customer'
  final String? accessToken;
  final String? refreshToken;
  final String? fcmToken;

  // ── Profile fields (populated from /auth/me) ─────────────────────────────
  final String? avatar;
  final String? gender;
  final String? bio;
  final String? language;

  /// Populated from the login/register API response.
  /// true = backend already has the user's onboarding preferences.
  final bool isOnboardingCompleted;

  /// Populated from the login/OTP API response.
  /// true  = seller has already submitted their store for review.
  /// false = seller must complete store creation before accessing the dashboard.
  final bool isStoreCreated;

  /// Populated from the login/OTP/profile API response.
  /// true  = the backend has APPROVED this user's store — they are a live seller.
  /// false = pending review, rejected, or a pure customer.
  ///
  /// This is the authoritative gate for the Seller Flow.
  /// A user with the 'seller_pending' role will ALWAYS have isStoreOwner = false
  /// until the backend approves them and promotes their role to 'seller'.
  final bool isStoreOwner;

  const UserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.role = 'customer',
    this.accessToken,
    this.refreshToken,
    this.fcmToken,
    this.avatar,
    this.gender,
    this.bio,
    this.language,
    this.isOnboardingCompleted = false,
    this.isStoreCreated = false,
    this.isStoreOwner = false,
  });

  /// Full display name
  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [
    id, firstName, lastName, email, phoneNumber,
    role, accessToken, refreshToken, fcmToken,
    avatar, gender, bio, language,
    isOnboardingCompleted, isStoreCreated, isStoreOwner,
  ];
}
