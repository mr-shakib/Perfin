/// Prioritized goal with rationale
class PrioritizedGoal {
  final String goalId;
  final int priority;
  final String rationale;

  PrioritizedGoal({
    required this.goalId,
    required this.priority,
    required this.rationale,
  });

  /// Convert PrioritizedGoal instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'goalId': goalId,
      'priority': priority,
      'rationale': rationale,
    };
  }

  /// Create PrioritizedGoal instance from JSON map
  factory PrioritizedGoal.fromJson(Map<String, dynamic> json) {
    return PrioritizedGoal(
      goalId: json['goalId'] as String,
      priority: json['priority'] as int,
      rationale: json['rationale'] as String,
    );
  }

  @override
  String toString() {
    return 'PrioritizedGoal(goalId: $goalId, priority: $priority, rationale: $rationale)';
  }
}

/// AI-generated prioritization of multiple goals
class GoalPrioritization {
  final List<PrioritizedGoal> prioritizedGoals;
  final bool hasConflicts;
  final String? conflictExplanation;
  final double totalRequiredMonthlySavings;
  final double availableMonthlySurplus;
  final DateTime analyzedAt;

  GoalPrioritization({
    required this.prioritizedGoals,
    this.hasConflicts = false,
    this.conflictExplanation,
    required this.totalRequiredMonthlySavings,
    required this.availableMonthlySurplus,
    required this.analyzedAt,
  });

  /// Convert GoalPrioritization instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'prioritizedGoals': prioritizedGoals.map((g) => g.toJson()).toList(),
      'hasConflicts': hasConflicts,
      'conflictExplanation': conflictExplanation,
      'totalRequiredMonthlySavings': totalRequiredMonthlySavings,
      'availableMonthlySurplus': availableMonthlySurplus,
      'analyzedAt': analyzedAt.toIso8601String(),
    };
  }

  /// Create GoalPrioritization instance from JSON map
  factory GoalPrioritization.fromJson(Map<String, dynamic> json) {
    return GoalPrioritization(
      prioritizedGoals: (json['prioritizedGoals'] as List)
          .map((g) => PrioritizedGoal.fromJson(g as Map<String, dynamic>))
          .toList(),
      hasConflicts: json['hasConflicts'] as bool? ?? false,
      conflictExplanation: json['conflictExplanation'] as String?,
      totalRequiredMonthlySavings: (json['totalRequiredMonthlySavings'] as num).toDouble(),
      availableMonthlySurplus: (json['availableMonthlySurplus'] as num).toDouble(),
      analyzedAt: DateTime.parse(json['analyzedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'GoalPrioritization(hasConflicts: $hasConflicts, '
        'totalRequiredMonthlySavings: $totalRequiredMonthlySavings, '
        'availableMonthlySurplus: $availableMonthlySurplus)';
  }
}
