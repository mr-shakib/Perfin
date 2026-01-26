import 'spending_reduction.dart';

/// Enum representing the feasibility level of a goal
enum FeasibilityLevel {
  easy,
  moderate,
  challenging,
  unrealistic;

  /// Convert FeasibilityLevel to string for JSON serialization
  String toJson() => name;

  /// Create FeasibilityLevel from string
  static FeasibilityLevel fromJson(String value) {
    return FeasibilityLevel.values.firstWhere(
      (level) => level.name == value,
      orElse: () => throw ArgumentError('Invalid feasibility level: $value'),
    );
  }
}

/// AI analysis of goal achievability
class GoalFeasibilityAnalysis {
  final String goalId;
  final bool isAchievable;
  final double requiredMonthlySavings;
  final double averageMonthlySurplus;
  final FeasibilityLevel feasibilityLevel;
  final List<SpendingReduction> suggestedReductions;
  final String explanation;
  final int confidenceScore;
  final DateTime analyzedAt;

  GoalFeasibilityAnalysis({
    required this.goalId,
    required this.isAchievable,
    required this.requiredMonthlySavings,
    required this.averageMonthlySurplus,
    required this.feasibilityLevel,
    required this.suggestedReductions,
    required this.explanation,
    required this.confidenceScore,
    required this.analyzedAt,
  });

  /// Convert GoalFeasibilityAnalysis instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'goalId': goalId,
      'isAchievable': isAchievable,
      'requiredMonthlySavings': requiredMonthlySavings,
      'averageMonthlySurplus': averageMonthlySurplus,
      'feasibilityLevel': feasibilityLevel.toJson(),
      'suggestedReductions': suggestedReductions.map((r) => r.toJson()).toList(),
      'explanation': explanation,
      'confidenceScore': confidenceScore,
      'analyzedAt': analyzedAt.toIso8601String(),
    };
  }

  /// Create GoalFeasibilityAnalysis instance from JSON map
  factory GoalFeasibilityAnalysis.fromJson(Map<String, dynamic> json) {
    return GoalFeasibilityAnalysis(
      goalId: json['goalId'] as String,
      isAchievable: json['isAchievable'] as bool,
      requiredMonthlySavings: (json['requiredMonthlySavings'] as num).toDouble(),
      averageMonthlySurplus: (json['averageMonthlySurplus'] as num).toDouble(),
      feasibilityLevel: FeasibilityLevel.fromJson(json['feasibilityLevel'] as String),
      suggestedReductions: (json['suggestedReductions'] as List)
          .map((r) => SpendingReduction.fromJson(r as Map<String, dynamic>))
          .toList(),
      explanation: json['explanation'] as String,
      confidenceScore: json['confidenceScore'] as int,
      analyzedAt: DateTime.parse(json['analyzedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'GoalFeasibilityAnalysis(goalId: $goalId, isAchievable: $isAchievable, '
        'feasibilityLevel: $feasibilityLevel, confidenceScore: $confidenceScore)';
  }
}
