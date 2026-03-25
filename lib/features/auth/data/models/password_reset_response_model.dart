import 'package:equatable/equatable.dart';

/// Response model for POST /auth/password/forgot and /auth/password/resend-otp
/// Contains expiry metadata shown in the UI countdown timer.
class PasswordResetResponseModel extends Equatable {
  final DateTime expiresAt;
  final double expiresInMinutes;

  const PasswordResetResponseModel({
    required this.expiresAt,
    required this.expiresInMinutes,
  });

  /// Handles both flat and nested `{ data: {...} }` responses.
  factory PasswordResetResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return PasswordResetResponseModel(
      expiresAt:        DateTime.parse(data['expires_at'] as String),
      expiresInMinutes: (data['expires_in_minutes'] as num?)?.toDouble() ?? 5.0,
    );
  }

  /// Remaining duration until the code expires (may be negative if already expired).
  Duration get remainingDuration => expiresAt.difference(DateTime.now());

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  List<Object?> get props => [expiresAt, expiresInMinutes];
}
