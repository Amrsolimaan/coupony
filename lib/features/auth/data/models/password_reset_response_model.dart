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
  /// If expires_at is not provided, defaults to 5 minutes from now.
  factory PasswordResetResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    
    // Handle case where API doesn't return expiry info
    final expiresAtStr = data['expires_at'] as String?;
    final expiresInMins = (data['expires_in_minutes'] as num?)?.toDouble() ?? 5.0;
    
    final expiresAt = expiresAtStr != null
        ? DateTime.parse(expiresAtStr)
        : DateTime.now().add(Duration(minutes: expiresInMins.toInt()));
    
    return PasswordResetResponseModel(
      expiresAt:        expiresAt,
      expiresInMinutes: expiresInMins,
    );
  }

  /// Remaining duration until the code expires (may be negative if already expired).
  Duration get remainingDuration => expiresAt.difference(DateTime.now());

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  List<Object?> get props => [expiresAt, expiresInMinutes];
}
