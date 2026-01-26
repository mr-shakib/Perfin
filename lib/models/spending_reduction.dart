/// Suggested spending reduction for achieving a goal
class SpendingReduction {
  final String categoryId;
  final double currentMonthlySpending;
  final double suggestedReduction;
  final double newMonthlySpending;
  final String rationale;
  final bool isEssential;

  SpendingReduction({
    required this.categoryId,
    required this.currentMonthlySpending,
    required this.suggestedReduction,
    required this.newMonthlySpending,
    required this.rationale,
    this.isEssential = false,
  });

  /// Convert SpendingReduction instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'currentMonthlySpending': currentMonthlySpending,
      'suggestedReduction': suggestedReduction,
      'newMonthlySpending': newMonthlySpending,
      'rationale': rationale,
      'isEssential': isEssential,
    };
  }

  /// Create SpendingReduction instance from JSON map
  factory SpendingReduction.fromJson(Map<String, dynamic> json) {
    return SpendingReduction(
      categoryId: json['categoryId'] as String,
      currentMonthlySpending: (json['currentMonthlySpending'] as num).toDouble(),
      suggestedReduction: (json['suggestedReduction'] as num).toDouble(),
      newMonthlySpending: (json['newMonthlySpending'] as num).toDouble(),
      rationale: json['rationale'] as String,
      isEssential: json['isEssential'] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return 'SpendingReduction(categoryId: $categoryId, '
        'currentMonthlySpending: $currentMonthlySpending, '
        'suggestedReduction: $suggestedReduction, isEssential: $isEssential)';
  }
}
