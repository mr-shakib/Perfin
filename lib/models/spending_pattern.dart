/// Detected spending pattern in transaction history
class SpendingPattern {
  final String patternType;
  final String categoryId;
  final String description;
  final double magnitude;
  final int confidenceScore;
  final DateTime detectedAt;

  SpendingPattern({
    required this.patternType,
    required this.categoryId,
    required this.description,
    required this.magnitude,
    required this.confidenceScore,
    required this.detectedAt,
  });

  /// Convert SpendingPattern instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'patternType': patternType,
      'categoryId': categoryId,
      'description': description,
      'magnitude': magnitude,
      'confidenceScore': confidenceScore,
      'detectedAt': detectedAt.toIso8601String(),
    };
  }

  /// Create SpendingPattern instance from JSON map
  factory SpendingPattern.fromJson(Map<String, dynamic> json) {
    return SpendingPattern(
      patternType: json['patternType'] as String,
      categoryId: json['categoryId'] as String,
      description: json['description'] as String,
      magnitude: (json['magnitude'] as num).toDouble(),
      confidenceScore: json['confidenceScore'] as int,
      detectedAt: DateTime.parse(json['detectedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'SpendingPattern(patternType: $patternType, categoryId: $categoryId, '
        'description: $description, magnitude: $magnitude, '
        'confidenceScore: $confidenceScore)';
  }
}
