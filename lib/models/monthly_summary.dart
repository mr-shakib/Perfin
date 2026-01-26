/// MonthlySummary model representing aggregated financial data for a specific month
class MonthlySummary {
  final int year;
  final int month;
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final Map<String, double> expensesByCategory;

  MonthlySummary({
    required this.year,
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.expensesByCategory,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MonthlySummary &&
        other.year == year &&
        other.month == month &&
        other.totalIncome == totalIncome &&
        other.totalExpense == totalExpense &&
        other.balance == balance &&
        _mapsEqual(other.expensesByCategory, expensesByCategory);
  }

  @override
  int get hashCode {
    return year.hashCode ^
        month.hashCode ^
        totalIncome.hashCode ^
        totalExpense.hashCode ^
        balance.hashCode ^
        expensesByCategory.hashCode;
  }

  @override
  String toString() {
    return 'MonthlySummary(year: $year, month: $month, '
        'totalIncome: $totalIncome, totalExpense: $totalExpense, '
        'balance: $balance, expensesByCategory: $expensesByCategory)';
  }

  /// Helper method to compare two maps for equality
  bool _mapsEqual(Map<String, double> map1, Map<String, double> map2) {
    if (map1.length != map2.length) return false;
    for (var key in map1.keys) {
      if (!map2.containsKey(key) || map1[key] != map2[key]) {
        return false;
      }
    }
    return true;
  }
}
