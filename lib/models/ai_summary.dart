import 'spending_anomaly.dart';

/// AI-generated financial summary for a time period
class AISummary {
  final String summaryText;
  final double totalSpending;
  final double totalIncome;
  final String topSpendingCategory;
  final double topSpendingAmount;
  final List<String> insights;
  final List<SpendingAnomaly> anomalies;
  final DateTime generatedAt;
  final int confidenceScore;
  final bool hasInsufficientData;

  AISummary({
    required this.summaryText,
    required this.totalSpending,
    required this.totalIncome,
    required this.topSpendingCategory,
    required this.topSpendingAmount,
    required this.insights,
    required this.anomalies,
    required this.generatedAt,
    required this.confidenceScore,
    this.hasInsufficientData = false,
  });

  /// Convert AISummary instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'summaryText': summaryText,
      'totalSpending': totalSpending,
      'totalIncome': totalIncome,
      'topSpendingCategory': topSpendingCategory,
      'topSpendingAmount': topSpendingAmount,
      'insights': insights,
      'anomalies': anomalies.map((a) => a.toJson()).toList(),
      'generatedAt': generatedAt.toIso8601String(),
      'confidenceScore': confidenceScore,
      'hasInsufficientData': hasInsufficientData,
    };
  }

  /// Create AISummary instance from JSON map
  factory AISummary.fromJson(Map<String, dynamic> json) {
    return AISummary(
      summaryText: json['summaryText'] as String,
      totalSpending: (json['totalSpending'] as num).toDouble(),
      totalIncome: (json['totalIncome'] as num).toDouble(),
      topSpendingCategory: json['topSpendingCategory'] as String,
      topSpendingAmount: (json['topSpendingAmount'] as num).toDouble(),
      insights: (json['insights'] as List).cast<String>(),
      anomalies: (json['anomalies'] as List)
          .map((a) => SpendingAnomaly.fromJson(a as Map<String, dynamic>))
          .toList(),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      confidenceScore: json['confidenceScore'] as int,
      hasInsufficientData: json['hasInsufficientData'] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return 'AISummary(summaryText: $summaryText, totalSpending: $totalSpending, '
        'totalIncome: $totalIncome, topSpendingCategory: $topSpendingCategory, '
        'confidenceScore: $confidenceScore, hasInsufficientData: $hasInsufficientData)';
  }
}
