import 'package:coupony/features/user_flow/CustomerOnboarding/domain/entities/user_preferences_entity.dart';
import 'package:hive/hive.dart';

part 'user_preferences_model.g.dart';

/// User preferences model for onboarding (All 3 Steps)
/// Serves as a DTO for Hive and API interactions
@HiveType(typeId: 1) // Unique typeId for Hive
class UserPreferencesModel extends UserPreferencesEntity {
  @override
  @HiveField(0)
  final List<String> selectedCategories;
  
  @override
  @HiveField(1)
  final DateTime timestamp;
  
  @override
  @HiveField(2)
  final bool isSynced;
  
  @override
  @HiveField(3)
  final String? budgetPreference;
  
  @override
  @HiveField(4)
  final double? budgetSliderValue;
  
  @override
  @HiveField(5)
  final List<String>? shoppingStyles;
  
  @override
  @HiveField(6)
  final Map<String, int> categoryScores;
  
  @override
  @HiveField(7)
  final List<String> seenProductIds;
  
  @override
  @HiveField(8)
  final DateTime? lastDecayDate;

  UserPreferencesModel({
    List<String>? selectedCategories,
    DateTime? timestamp,
    this.isSynced = false,
    this.budgetPreference,
    this.budgetSliderValue,
    this.shoppingStyles,
    Map<String, int>? categoryScores,
    List<String>? seenProductIds,
    this.lastDecayDate,
  })  : selectedCategories = selectedCategories ?? const [],
        categoryScores = categoryScores ?? const {},
        seenProductIds = seenProductIds ?? const [],
        timestamp = timestamp ?? DateTime.utc(1970),
        super(
          selectedCategories: selectedCategories ?? const [],
          timestamp: timestamp ?? DateTime.utc(1970),
          isSynced: isSynced,
          budgetPreference: budgetPreference,
          budgetSliderValue: budgetSliderValue,
          shoppingStyles: shoppingStyles,
          categoryScores: categoryScores ?? const {},
          seenProductIds: seenProductIds ?? const [],
          lastDecayDate: lastDecayDate,
        );

  /// Convert Entity to Model
  factory UserPreferencesModel.fromEntity(UserPreferencesEntity entity) {
    return UserPreferencesModel(
      selectedCategories: entity.selectedCategories,
      budgetPreference: entity.budgetPreference,
      budgetSliderValue: entity.budgetSliderValue,
      shoppingStyles: entity.shoppingStyles,
      categoryScores: entity.categoryScores,
      seenProductIds: entity.seenProductIds,
      lastDecayDate: entity.lastDecayDate,
      timestamp: entity.timestamp,
      isSynced: entity.isSynced,
    );
  }

  /// Convert Model to Entity
  UserPreferencesEntity toEntity() {
    return UserPreferencesEntity(
      selectedCategories: selectedCategories,
      budgetPreference: budgetPreference,
      budgetSliderValue: budgetSliderValue,
      shoppingStyles: shoppingStyles,
      categoryScores: categoryScores,
      seenProductIds: seenProductIds,
      lastDecayDate: lastDecayDate,
      timestamp: timestamp,
      isSynced: isSynced,
    );
  }

  /// Factory constructor for creating from JSON (for API)
  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
    return UserPreferencesModel(
      selectedCategories: List<String>.from(json['selected_categories'] ?? []),
      budgetPreference: json['budget_preference'] as String?,
      budgetSliderValue: json['budget_slider_value'] as double?,
      shoppingStyles: json['shopping_styles'] != null
          ? List<String>.from(json['shopping_styles'])
          : null,
      categoryScores: json['category_scores'] != null
          ? Map<String, int>.from(json['category_scores'])
          : const {},
      seenProductIds: json['seen_product_ids'] != null
          ? List<String>.from(json['seen_product_ids'])
          : const [],
      lastDecayDate: json['last_decay_date'] != null
          ? DateTime.parse(json['last_decay_date'] as String)
          : null,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isSynced: json['is_synced'] as bool? ?? false,
    );
  }

  /// Parse the response from GET /on-boarding/{customer|seller}.
  ///
  /// The server echoes back the same field names used in the POST body:
  ///   { "interesting_offers": [...], "shopping_style": [...], "budget": "..." }
  /// optionally wrapped in a `data` envelope.
  ///
  /// [existingScores], [existingSeenIds], and [existingLastDecayDate] are
  /// local-only interest-tracking values the server does not store — pass
  /// them in so they are preserved when the model is written back to Hive.
  factory UserPreferencesModel.fromApiGetJson(
    Map<String, dynamic> json, {
    Map<String, int> existingScores = const {},
    List<String> existingSeenIds = const [],
    DateTime? existingLastDecayDate,
  }) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return UserPreferencesModel(
      selectedCategories: List<String>.from(data['interesting_offers'] ?? []),
      shoppingStyles: data['shopping_style'] != null
          ? List<String>.from(data['shopping_style'] as List)
          : null,
      budgetPreference:  data['budget'] as String?,
      budgetSliderValue: null, // server does not store the slider position
      categoryScores:    existingScores,
      seenProductIds:    existingSeenIds,
      lastDecayDate:     existingLastDecayDate,
      timestamp:         DateTime.now(),
      isSynced:          true,
    );
  }

  /// Serialize for the onboarding submission endpoints.
  ///
  /// Field names match the Postman contract exactly:
  ///   POST /api/v1/on-boarding/customer  |  /api/v1/on-boarding/seller
  ///   { "interesting_offers": [...], "shopping_style": [...], "budget": "..." }
  ///
  /// Do NOT confuse with [toJson()] which uses Hive-friendly field names.
  Map<String, dynamic> toApiJson() {
    return {
      'interesting_offers': selectedCategories,
      'shopping_style':     shoppingStyles ?? [],
      'budget':             budgetPreference ?? '',
    };
  }

  /// Convert to JSON (for Hive internal storage — not for API)
  Map<String, dynamic> toJson() {
    return {
      'selected_categories': selectedCategories,
      'budget_preference': budgetPreference,
      'budget_slider_value': budgetSliderValue,
      'shopping_styles': shoppingStyles,
      'category_scores': categoryScores,
      'seen_product_ids': seenProductIds,
      'last_decay_date': lastDecayDate?.toIso8601String(),
      'timestamp': timestamp.toIso8601String(),
      'is_synced': isSynced,
    };
  }

  /// Create empty preferences
  factory UserPreferencesModel.empty() {
    return UserPreferencesModel(
      selectedCategories: const [],
      budgetPreference: null,
      budgetSliderValue: null,
      shoppingStyles: null,
      categoryScores: const {},
      seenProductIds: const [],
      lastDecayDate: null,
      timestamp: DateTime.now(),
      isSynced: false,
    );
  }

  /// Copy with method
  @override
  UserPreferencesModel copyWith({
    List<String>? selectedCategories,
    String? budgetPreference,
    double? budgetSliderValue,
    List<String>? shoppingStyles,
    Map<String, int>? categoryScores,
    List<String>? seenProductIds,
    DateTime? lastDecayDate,
    DateTime? timestamp,
    bool? isSynced,
  }) {
    return UserPreferencesModel(
      selectedCategories: selectedCategories ?? this.selectedCategories,
      budgetPreference: budgetPreference ?? this.budgetPreference,
      budgetSliderValue: budgetSliderValue ?? this.budgetSliderValue,
      shoppingStyles: shoppingStyles ?? this.shoppingStyles,
      categoryScores: categoryScores ?? this.categoryScores,
      seenProductIds: seenProductIds ?? this.seenProductIds,
      lastDecayDate: lastDecayDate ?? this.lastDecayDate,
      timestamp: timestamp ?? this.timestamp,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
