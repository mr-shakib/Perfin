import '../models/transaction.dart';
import '../models/monthly_summary.dart';

/// Calculate the current balance from a list of transactions
/// Balance = Total Income - Total Expense
double calculateBalance(List<Transaction> transactions) {
  double income = transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double expense = transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  return income - expense;
}

/// Calculate expenses grouped by category
/// Returns a map where keys are category names and values are total expenses
Map<String, double> calculateExpensesByCategory(List<Transaction> transactions) {
  Map<String, double> breakdown = {};

  for (var transaction in transactions) {
    if (transaction.type == TransactionType.expense) {
      breakdown[transaction.category] =
          (breakdown[transaction.category] ?? 0.0) + transaction.amount;
    }
  }

  return breakdown;
}

/// Calculate monthly summary for a specific year and month
/// Aggregates income, expense, balance, and category breakdown for the given month
MonthlySummary calculateMonthlySummary(
  List<Transaction> transactions,
  int year,
  int month,
) {
  // Filter transactions for the specified month
  var monthTransactions = transactions
      .where((t) => t.date.year == year && t.date.month == month)
      .toList();

  // Calculate total income for the month
  double income = monthTransactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  // Calculate total expense for the month
  double expense = monthTransactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  return MonthlySummary(
    year: year,
    month: month,
    totalIncome: income,
    totalExpense: expense,
    balance: income - expense,
    expensesByCategory: calculateExpensesByCategory(monthTransactions),
  );
}

/// Calculate monthly trends over time
/// Returns a list of monthly summaries ordered chronologically
List<MonthlySummary> calculateMonthlyTrends(List<Transaction> transactions) {
  if (transactions.isEmpty) {
    return [];
  }

  // Find the range of months covered by transactions
  DateTime earliest = transactions
      .map((t) => t.date)
      .reduce((a, b) => a.isBefore(b) ? a : b);
  DateTime latest = transactions
      .map((t) => t.date)
      .reduce((a, b) => a.isAfter(b) ? a : b);

  List<MonthlySummary> trends = [];

  // Generate summaries for each month in the range
  DateTime current = DateTime(earliest.year, earliest.month);
  DateTime end = DateTime(latest.year, latest.month);

  while (current.isBefore(end) || 
         (current.year == end.year && current.month == end.month)) {
    trends.add(calculateMonthlySummary(
      transactions,
      current.year,
      current.month,
    ));

    // Move to next month
    if (current.month == 12) {
      current = DateTime(current.year + 1, 1);
    } else {
      current = DateTime(current.year, current.month + 1);
    }
  }

  return trends;
}
