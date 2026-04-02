import 'package:hive/hive.dart';
import '../../domain/entities/seller_preferences_entity.dart';

part 'seller_preferences_model.g.dart';

/// Seller preferences model for onboarding (All 4 Steps)
/// Serves as a DTO for Hive and API interactions
///
/// API endpoint: POST/GET /api/v1/on-boarding/seller
@HiveType(typeId: 2) // typeId 1 is reserved for UserPreferencesModel (Customer)
class SellerPreferencesModel extends SellerPreferencesEntity {
  @override
  @HiveField(0)
  final DateTime timestamp;
  
  @override
  @HiveField(1)
  final bool isSynced;
  
  @override
  @HiveField(2)
  final String? priceCategory;
  
  @override
  @HiveField(3)
  final String? customerReachMethod;
  
  @override
  @HiveField(4)
  final String? bestOfferTime;
  
  @override
  @HiveField(5)
  final String? targetAudience;

  SellerPreferencesModel({
    DateTime? timestamp,
    this.isSynced = false,
    this.priceCategory,
    this.customerReachMethod,
    this.bestOfferTime,
    this.targetAudience,
  })  : timestamp = timestamp ?? DateTime.utc(1970),
        super(
          timestamp: timestamp ?? DateTime.utc(1970),
          isSynced: isSynced,
          priceCategory: priceCategory,
          customerReachMethod: customerReachMethod,
          bestOfferTime: bestOfferTime,
          targetAudience: targetAudience,
        );

  /// Convert Entity to Model
  factory SellerPreferencesModel.fromEntity(SellerPreferencesEntity entity) {
    return SellerPreferencesModel(
      priceCategory: entity.priceCategory,
      customerReachMethod: entity.customerReachMethod,
      bestOfferTime: entity.bestOfferTime,
      targetAudience: entity.targetAudience,
      timestamp: entity.timestamp,
      isSynced: entity.isSynced,
    );
  }

  /// Convert Model to Entity
  SellerPreferencesEntity toEntity() {
    return SellerPreferencesEntity(
      priceCategory: priceCategory,
      customerReachMethod: customerReachMethod,
      bestOfferTime: bestOfferTime,
      targetAudience: targetAudience,
      timestamp: timestamp,
      isSynced: isSynced,
    );
  }

  /// Factory constructor for creating from JSON (Hive internal storage — not for API)
  factory SellerPreferencesModel.fromJson(Map<String, dynamic> json) {
    return SellerPreferencesModel(
      priceCategory: json['price_category'] as String?,
      customerReachMethod: json['customer_reach_method'] as String?,
      bestOfferTime: json['best_offer_time'] as String?,
      targetAudience: json['target_audience'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isSynced: json['is_synced'] as bool? ?? false,
    );
  }

  /// Parse the response from GET /api/v1/on-boarding/seller.
  ///
  /// The server echoes back the same field names used in the POST body:
  ///   { "price_category": "...", "customer_reach_method": "...",
  ///     "best_offer_time": "...", "target_audience": "..." }
  /// optionally wrapped in a `data` envelope.
  factory SellerPreferencesModel.fromApiGetJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return SellerPreferencesModel(
      priceCategory: data['price_category'] as String?,
      customerReachMethod: data['customer_reach_method'] as String?,
      bestOfferTime: data['best_offer_time'] as String?,
      targetAudience: data['target_audience'] as String?,
      timestamp: DateTime.now(),
      isSynced: true,
    );
  }

  /// Serialize for POST /api/v1/on-boarding/seller.
  ///
  /// Field names match the Postman contract exactly.
  /// Do NOT confuse with [toJson()] which uses Hive-friendly field names.
  Map<String, dynamic> toApiJson() {
    return {
      'price_category': priceCategory ?? '',
      'customer_reach_method': customerReachMethod ?? '',
      'best_offer_time': bestOfferTime ?? '',
      'target_audience': targetAudience ?? '',
    };
  }

  /// Convert to JSON (Hive internal storage — not for API)
  Map<String, dynamic> toJson() {
    return {
      'price_category': priceCategory,
      'customer_reach_method': customerReachMethod,
      'best_offer_time': bestOfferTime,
      'target_audience': targetAudience,
      'timestamp': timestamp.toIso8601String(),
      'is_synced': isSynced,
    };
  }

  /// Create empty seller preferences
  factory SellerPreferencesModel.empty() {
    return SellerPreferencesModel(
      priceCategory: null,
      customerReachMethod: null,
      bestOfferTime: null,
      targetAudience: null,
      timestamp: DateTime.now(),
      isSynced: false,
    );
  }

  /// Copy with method
  @override
  SellerPreferencesModel copyWith({
    String? priceCategory,
    String? customerReachMethod,
    String? bestOfferTime,
    String? targetAudience,
    DateTime? timestamp,
    bool? isSynced,
  }) {
    return SellerPreferencesModel(
      priceCategory: priceCategory ?? this.priceCategory,
      customerReachMethod: customerReachMethod ?? this.customerReachMethod,
      bestOfferTime: bestOfferTime ?? this.bestOfferTime,
      targetAudience: targetAudience ?? this.targetAudience,
      timestamp: timestamp ?? this.timestamp,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
