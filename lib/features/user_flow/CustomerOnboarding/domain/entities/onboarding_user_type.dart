/// Distinguishes which backend endpoint to call during onboarding submission.
///
/// Derived from [UserEntity.role]:
///   'user'     → [customer]  → POST /api/v1/on-boarding/customer
///   'merchant' → [seller]    → POST /api/v1/on-boarding/seller
enum OnboardingUserType {
  customer,
  seller;

  /// Map a raw role string (from SecureStorage / API) to the correct type.
  static OnboardingUserType fromRole(String? role) {
    return role == 'seller' ? seller : customer;
  }

  /// The path segment used in the API endpoint URL.
  String get apiSegment => this == seller ? 'seller' : 'customer';
}
