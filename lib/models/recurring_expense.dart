/// Detected recurring expense in transaction history
class RecurringExpense {
  final String id;
  final String categoryId;
  final String description;
  final double averageAmount;
  final int frequencyDays;
  final DateTime lastOccurrence;
  final DateTime nextExpectedDate;
  final int confidenceScore;
  final List<String> transactionIds;

  RecurringExpense({
    required this.id,
    required this.categoryId,
    required this.description,
    required this.averageAmount,
    required this.frequencyDays,
    required this.lastOccurrence,
    required this.nextExpectedDate,
    required this.confidenceScore,
    required this.transactionIds,
  });

  /// Convert RecurringExpense instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'description': description,
      'averageAmount': averageAmount,
      'frequencyDays': frequencyDays,
      'lastOccurrence': lastOccurrence.toIso8601String(),
      'nextExpectedDate': nextExpectedDate.toIso8601String(),
      'confidenceScore': confidenceScore,
      'transactionIds': transactionIds,
    };
  }

  /// Create RecurringExpense instance from JSON map
  factory RecurringExpense.fromJson(Map<String, dynamic> json) {
    return RecurringExpense(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      description: json['description'] as String,
      averageAmount: (json['averageAmount'] as num).toDouble(),
      frequencyDays: json['frequencyDays'] as int,
      lastOccurrence: DateTime.parse(json['lastOccurrence'] as String),
      nextExpectedDate: DateTime.parse(json['nextExpectedDate'] as String),
      confidenceScore: json['confidenceScore'] as int,
      transactionIds: (json['transactionIds'] as List).cast<String>(),
    );
  }

  @override
  String toString() {
    return 'RecurringExpense(id: $id, categoryId: $categoryId, '
        'description: $description, averageAmount: $averageAmount, '
        'frequencyDays: $frequencyDays, confidenceScore: $confidenceScore)';
  }
}
