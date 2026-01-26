/// Detected unusual spending transaction
class SpendingAnomaly {
  final String transactionId;
  final String categoryId;
  final double amount;
  final DateTime date;
  final String anomalyType;
  final String explanation;
  final double deviationFromNormal;
  final int confidenceScore;

  SpendingAnomaly({
    required this.transactionId,
    required this.categoryId,
    required this.amount,
    required this.date,
    required this.anomalyType,
    required this.explanation,
    required this.deviationFromNormal,
    required this.confidenceScore,
  });

  /// Convert SpendingAnomaly instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'categoryId': categoryId,
      'amount': amount,
      'date': date.toIso8601String(),
      'anomalyType': anomalyType,
      'explanation': explanation,
      'deviationFromNormal': deviationFromNormal,
      'confidenceScore': confidenceScore,
    };
  }

  /// Create SpendingAnomaly instance from JSON map
  factory SpendingAnomaly.fromJson(Map<String, dynamic> json) {
    return SpendingAnomaly(
      transactionId: json['transactionId'] as String,
      categoryId: json['categoryId'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      anomalyType: json['anomalyType'] as String,
      explanation: json['explanation'] as String,
      deviationFromNormal: (json['deviationFromNormal'] as num).toDouble(),
      confidenceScore: json['confidenceScore'] as int,
    );
  }

  @override
  String toString() {
    return 'SpendingAnomaly(transactionId: $transactionId, '
        'categoryId: $categoryId, amount: $amount, '
        'anomalyType: $anomalyType, confidenceScore: $confidenceScore)';
  }
}
