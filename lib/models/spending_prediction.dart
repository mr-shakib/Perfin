/// AI-generated spending prediction for a future period
class SpendingPrediction {
  final double predictedAmount;
  final DateTime targetDate;
  final int confidenceScore;
  final String explanation;
  final double lowerBound;
  final double upperBound;
  final List<String> assumptions;
  final DateTime generatedAt;

  SpendingPrediction({
    required this.predictedAmount,
    required this.targetDate,
    required this.confidenceScore,
    required this.explanation,
    required this.lowerBound,
    required this.upperBound,
    required this.assumptions,
    required this.generatedAt,
  });

  /// Convert SpendingPrediction instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'predictedAmount': predictedAmount,
      'targetDate': targetDate.toIso8601String(),
      'confidenceScore': confidenceScore,
      'explanation': explanation,
      'lowerBound': lowerBound,
      'upperBound': upperBound,
      'assumptions': assumptions,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  /// Create SpendingPrediction instance from JSON map
  factory SpendingPrediction.fromJson(Map<String, dynamic> json) {
    return SpendingPrediction(
      predictedAmount: (json['predictedAmount'] as num).toDouble(),
      targetDate: DateTime.parse(json['targetDate'] as String),
      confidenceScore: json['confidenceScore'] as int,
      explanation: json['explanation'] as String,
      lowerBound: (json['lowerBound'] as num).toDouble(),
      upperBound: (json['upperBound'] as num).toDouble(),
      assumptions: (json['assumptions'] as List).cast<String>(),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'SpendingPrediction(predictedAmount: $predictedAmount, '
        'targetDate: $targetDate, confidenceScore: $confidenceScore, '
        'explanation: $explanation)';
  }
}
