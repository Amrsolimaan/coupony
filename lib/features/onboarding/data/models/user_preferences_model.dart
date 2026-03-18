import 'package:hive/hive.dart';
import '../../domain/entities/user_preferences_entity.dart';

part 'user_preferences_model.g.dart';

/// User preferences model for onboarding (All 3 Steps)
/// Serves as a DTO for Hive and API interactions
@HiveType(typeId: 1) // Unique typeId for Hive
class UserPreferencesModel extends UserPreferencesEntity {
  // ════════════════════════════════════════════════════════
  // Explicitly overridden fields so Hive Generator can see them
  // ════════════════════════════════════════════════════════
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

  const UserPreferencesModel({
    required this.selectedCategories,
    required this.timestamp,
    this.isSynced = false,
    this.budgetPreference,
    this.budgetSliderValue,
    this.shoppingStyles,
    this.categoryScores = const {},
    this.seenProductIds = const [],
    this.lastDecayDate,
  }) : super(
          selectedCategories: selectedCategories,
          timestamp: timestamp,
          isSynced: isSynced,
          budgetPreference: budgetPreference,
          budgetSliderValue: budgetSliderValue,
          shoppingStyles: shoppingStyles,
          categoryScores: categoryScores,
          seenProductIds: seenProductIds,
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

  /// Convert to JSON (for API)
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
