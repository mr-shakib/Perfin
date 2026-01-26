/// Budget model representing a monthly budget allocation
class Budget {
  final String id;
  final String userId;
  final double amount;
  final int year;
  final int month;

  Budget({
    required this.id,
    required this.userId,
    required this.amount,
    required this.year,
    required this.month,
  });

  /// Convert Budget instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'year': year,
      'month': month,
    };
  }

  /// Create Budget instance from JSON map
  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      year: json['year'] as int,
      month: json['month'] as int,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Budget &&
        other.id == id &&
        other.userId == userId &&
        other.amount == amount &&
        other.year == year &&
        other.month == month;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        amount.hashCode ^
        year.hashCode ^
        month.hashCode;
  }

  @override
  String toString() {
    return 'Budget(id: $id, userId: $userId, amount: $amount, '
        'year: $year, month: $month)';
  }
}
