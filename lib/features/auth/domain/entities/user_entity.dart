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
    this.avatar,
    this.gender,
    this.bio,
    this.language,
    this.isOnboardingCompleted = false,
    this.isStoreCreated = false,
  });

  /// Full display name
  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [
    id, firstName, lastName, email, phoneNumber,
    role, accessToken, refreshToken, fcmToken,
    avatar, gender, bio, language,
    isOnboardingCompleted, isStoreCreated,
  ];
}
