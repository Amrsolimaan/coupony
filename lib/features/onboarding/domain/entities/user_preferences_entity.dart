import 'package:equatable/equatable.dart';

/// Pure Domain Entity representing user preferences (All 3 Steps)
/// Free from any third-party data serialization annotations (like Hive or JSON)
class UserPreferencesEntity extends Equatable {
  final List<String> selectedCategories;
  final String? budgetPreference;
  final double? budgetSliderValue;
  final List<String>? shoppingStyles;
  final Map<String, int> categoryScores;
  final List<String> seenProductIds;
  final DateTime? lastDecayDate;
  final DateTime timestamp;
  final bool isSynced;

  const UserPreferencesEntity({
    required this.selectedCategories,
    this.budgetPreference,
    this.budgetSliderValue,
    this.shoppingStyles,
    this.categoryScores = const {},
    this.seenProductIds = const [],
    this.lastDecayDate,
    required this.timestamp,
    this.isSynced = false,
  });

  /// Check if Step 1 is completed (categories selected)
  bool get isStep1Completed => selectedCategories.isNotEmpty;

  /// Check if Step 2 is completed (budget selected)
  bool get isStep2Completed => budgetPreference != null;

  /// Check if Step 3 is completed (shopping styles selected)
  bool get isStep3Completed =>
      shoppingStyles != null && shoppingStyles!.isNotEmpty;

  /// Check if all onboarding steps are completed
  bool get isOnboardingCompleted =>
      isStep1Completed && isStep2Completed && isStep3Completed;

  /// Get completion percentage (0.0 to 1.0)
  double get completionPercentage {
    int completed = 0;
    if (isStep1Completed) completed++;
    if (isStep2Completed) completed++;
    if (isStep3Completed) completed++;
    return completed / 3.0;
  }

  /// Get top 3 interests based on category scores
  List<String> getTopThreeInterests() {
    if (categoryScores.isEmpty) return [];

    final sortedEntries = categoryScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries.take(3).map((e) => e.key).toList();
  }

  /// Check if decay should be applied (once per day)
  bool shouldApplyDecay() {
    if (lastDecayDate == null) return true;
    final now = DateTime.now();
    final difference = now.difference(lastDecayDate!);
    return difference.inHours >= 24;
  }

  /// Copy with method
  UserPreferencesEntity copyWith({
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
    return UserPreferencesEntity(
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

  @override
  List<Object?> get props => [
    selectedCategories,
    budgetPreference,
    budgetSliderValue,
    shoppingStyles,
    categoryScores,
    seenProductIds,
    lastDecayDate,
    timestamp,
    isSynced,
  ];
}
