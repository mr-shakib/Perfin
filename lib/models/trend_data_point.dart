/// Data point for trend visualization
class TrendDataPoint {
  final DateTime date;
  final double amount;
  final String? label;

  TrendDataPoint({
    required this.date,
    required this.amount,
    this.label,
  });

  /// Convert TrendDataPoint instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'amount': amount,
      'label': label,
    };
  }

  /// Create TrendDataPoint instance from JSON map
  factory TrendDataPoint.fromJson(Map<String, dynamic> json) {
    return TrendDataPoint(
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      label: json['label'] as String?,
    );
  }

  @override
  String toString() {
    return 'TrendDataPoint(date: $date, amount: $amount, label: $label)';
  }
}
