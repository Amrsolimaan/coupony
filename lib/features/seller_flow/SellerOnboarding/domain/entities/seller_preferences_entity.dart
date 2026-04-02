import 'package:equatable/equatable.dart';

/// Pure Domain Entity representing seller onboarding preferences (All 4 Steps)
/// Free from any third-party data serialization annotations (like Hive or JSON)
///
/// API fields → POST /api/v1/on-boarding/seller
///   price_category        → priceCategory
///   customer_reach_method → customerReachMethod
///   best_offer_time       → bestOfferTime
///   target_audience       → targetAudience
class SellerPreferencesEntity extends Equatable {
  final String? priceCategory;
  final String? customerReachMethod;
  final String? bestOfferTime;
  final String? targetAudience;
  final DateTime timestamp;
  final bool isSynced;

  const SellerPreferencesEntity({
    this.priceCategory,
    this.customerReachMethod,
    this.bestOfferTime,
    this.targetAudience,
    required this.timestamp,
    this.isSynced = false,
  });

  /// Check if Step 1 is completed (price category selected)
  bool get isStep1Completed => priceCategory != null && priceCategory!.isNotEmpty;

  /// Check if Step 2 is completed (customer reach method selected)
  bool get isStep2Completed =>
      customerReachMethod != null && customerReachMethod!.isNotEmpty;

  /// Check if Step 3 is completed (best offer time selected)
  bool get isStep3Completed => bestOfferTime != null && bestOfferTime!.isNotEmpty;

  /// Check if Step 4 is completed (target audience selected)
  bool get isStep4Completed => targetAudience != null && targetAudience!.isNotEmpty;

  /// Check if all onboarding steps are completed
  bool get isOnboardingCompleted =>
      isStep1Completed &&
      isStep2Completed &&
      isStep3Completed &&
      isStep4Completed;

  /// Get completion percentage (0.0 to 1.0)
  double get completionPercentage {
    int completed = 0;
    if (isStep1Completed) completed++;
    if (isStep2Completed) completed++;
    if (isStep3Completed) completed++;
    if (isStep4Completed) completed++;
    return completed / 4.0;
  }

  /// Copy with method
  SellerPreferencesEntity copyWith({
    String? priceCategory,
    String? customerReachMethod,
    String? bestOfferTime,
    String? targetAudience,
    DateTime? timestamp,
    bool? isSynced,
  }) {
    return SellerPreferencesEntity(
      priceCategory: priceCategory ?? this.priceCategory,
      customerReachMethod: customerReachMethod ?? this.customerReachMethod,
      bestOfferTime: bestOfferTime ?? this.bestOfferTime,
      targetAudience: targetAudience ?? this.targetAudience,
      timestamp: timestamp ?? this.timestamp,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  List<Object?> get props => [
    priceCategory,
    customerReachMethod,
    bestOfferTime,
    targetAudience,
    timestamp,
    isSynced,
  ];
}
