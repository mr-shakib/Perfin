/// Model for storing user onboarding preferences
class OnboardingPreferences {
  final String? savingsGoal;
  final List<String> selectedCategories;
  final bool dailyDigest;
  final bool billReminders;
  final bool budgetAlerts;
  final int weeklyReviewDay; // 0 = Monday, 6 = Sunday
  final bool isCompleted;

  OnboardingPreferences({
    this.savingsGoal,
    this.selectedCategories = const [],
    this.dailyDigest = true,
    this.billReminders = true,
    this.budgetAlerts = true,
    this.weeklyReviewDay = 6, // Default to Sunday
    this.isCompleted = false,
  });

  /// Create from JSON
  factory OnboardingPreferences.fromJson(Map<String, dynamic> json) {
    return OnboardingPreferences(
      savingsGoal: json['savingsGoal'] as String?,
      selectedCategories: (json['selectedCategories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      dailyDigest: json['dailyDigest'] as bool? ?? true,
      billReminders: json['billReminders'] as bool? ?? true,
      budgetAlerts: json['budgetAlerts'] as bool? ?? true,
      weeklyReviewDay: json['weeklyReviewDay'] as int? ?? 6,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'savingsGoal': savingsGoal,
      'selectedCategories': selectedCategories,
      'dailyDigest': dailyDigest,
      'billReminders': billReminders,
      'budgetAlerts': budgetAlerts,
      'weeklyReviewDay': weeklyReviewDay,
      'isCompleted': isCompleted,
    };
  }

  /// Create a copy with updated fields
  OnboardingPreferences copyWith({
    String? savingsGoal,
    List<String>? selectedCategories,
    bool? dailyDigest,
    bool? billReminders,
    bool? budgetAlerts,
    int? weeklyReviewDay,
    bool? isCompleted,
  }) {
    return OnboardingPreferences(
      savingsGoal: savingsGoal ?? this.savingsGoal,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      dailyDigest: dailyDigest ?? this.dailyDigest,
      billReminders: billReminders ?? this.billReminders,
      budgetAlerts: budgetAlerts ?? this.budgetAlerts,
      weeklyReviewDay: weeklyReviewDay ?? this.weeklyReviewDay,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// Get savings goal percentage
  double? getSavingsPercentage() {
    switch (savingsGoal) {
      case 'starter':
        return 0.05; // 5%
      case 'builder':
        return 0.10; // 10%
      case 'aggressive':
        return 0.20; // 20%
      default:
        return null; // Custom
    }
  }

  /// Get day name
  String getDayName() {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weeklyReviewDay];
  }
}
