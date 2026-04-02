/// Distinguishes which backend endpoint to call during seller onboarding submission.
///
/// Derived from [UserEntity.role]:
///   'merchant' → [seller] → POST /api/v1/on-boarding/seller
enum OnboardingSellerType {
  seller;

  /// Map a raw role string (from SecureStorage / API) to the correct type.
  static OnboardingSellerType fromRole(String? role) {
    return seller;
  }

  /// The path segment used in the API endpoint URL.
  String get apiSegment => 'seller';
}
