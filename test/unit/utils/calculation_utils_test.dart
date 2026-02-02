import 'package:flutter_test/flutter_test.dart';
import 'package:perfin/models/transaction.dart';
import 'package:perfin/utils/calculation_utils.dart';

void main() {
  group('calculateBalance', () {
    test('returns 0 for empty transaction list', () {
      expect(calculateBalance([]), 0.0);
    });

    test('calculates balance correctly with income and expenses', () {
      final transactions = [
        Transaction(
          id: '1',
          amount: 1000.0,
          category: 'Salary',
          type: TransactionType.income,
          date: DateTime(2024, 1, 15),
          userId: 'user1',
        ),
        Transaction(
          id: '2',
          amount: 300.0,
          category: 'Groceries',
          type: TransactionType.expense,
          date: DateTime(2024, 1, 20),
          userId: 'user1',
        ),
        Transaction(
          id: '3',
          amount: 200.0,
          category: 'Transport',
          type: TransactionType.expense,
          date: DateTime(2024, 1, 25),
          userId: 'user1',
        ),
      ];

      expect(calculateBalance(transactions), 500.0);
    });

    test('calculates balance with only income', () {
      final transactions = [
        Transaction(
          id: '1',
          amount: 1000.0,
          category: 'Salary',
          type: TransactionType.income,
          date: DateTime(2024, 1, 15),
          userId: 'user1',
        ),
      ];

      expect(calculateBalance(transactions), 1000.0);
    });

    test('calculates balance with only expenses', () {
      final transactions = [
        Transaction(
          id: '1',
          amount: 300.0,
          category: 'Groceries',
          type: TransactionType.expense,
          date: DateTime(2024, 1, 20),
          userId: 'user1',
        ),
      ];

      expect(calculateBalance(transactions), -300.0);
    });
  });

  group('calculateExpensesByCategory', () {
    test('returns empty map for empty transaction list', () {
      expect(calculateExpensesByCategory([]), {});
    });

    test('groups expenses by category correctly', () {
      final transactions = [
        Transaction(
          id: '1',
          amount: 300.0,
          category: 'Groceries',
          type: TransactionType.expense,
          date: DateTime(2024, 1, 20),
          userId: 'user1',
        ),
        Transaction(
          id: '2',
          amount: 200.0,
          category: 'Transport',
          type: TransactionType.expense,
          date: DateTime(2024, 1, 25),
          userId: 'user1',
        ),
        Transaction(
          id: '3',
          amount: 150.0,
          category: 'Groceries',
          type: TransactionType.expense,
          date: DateTime(2024, 1, 28),
          userId: 'user1',
        ),
      ];

      final result = calculateExpensesByCategory(transactions);
      expect(result['Groceries'], 450.0);
      expect(result['Transport'], 200.0);
    });

    test('ignores income transactions', () {
      final transactions = [
        Transaction(
          id: '1',
          amount: 1000.0,
          category: 'Salary',
          type: TransactionType.income,
          date: DateTime(2024, 1, 15),
          userId: 'user1',
        ),
        Transaction(
          id: '2',
          amount: 300.0,
          category: 'Groceries',
          type: TransactionType.expense,
          date: DateTime(2024, 1, 20),
          userId: 'user1',
        ),
      ];

      final result = calculateExpensesByCategory(transactions);
      expect(result.containsKey('Salary'), false);
      expect(result['Groceries'], 300.0);
    });
  });

  group('calculateMonthlySummary', () {
    test('returns zero summary for empty transaction list', () {
      final summary = calculateMonthlySummary([], 2024, 1);
      expect(summary.year, 2024);
      expect(summary.month, 1);
      expect(summary.totalIncome, 0.0);
      expect(summary.totalExpense, 0.0);
      expect(summary.balance, 0.0);
      expect(summary.expensesByCategory, {});
    });

    test('calculates monthly summary correctly', () {
      final transactions = [
        Transaction(
          id: '1',
          amount: 1000.0,
          category: 'Salary',
          type: TransactionType.income,
          date: DateTime(2024, 1, 15),
          userId: 'user1',
        ),
        Transaction(
          id: '2',
          amount: 300.0,
          category: 'Groceries',
          type: TransactionType.expense,
          date: DateTime(2024, 1, 20),
          userId: 'user1',
        ),
        Transaction(
          id: '3',
          amount: 200.0,
          category: 'Transport',
          type: TransactionType.expense,
          date: DateTime(2024, 1, 25),
          userId: 'user1',
        ),
        // Transaction from different month (should be excluded)
        Transaction(
          id: '4',
          amount: 500.0,
          category: 'Bonus',
          type: TransactionType.income,
          date: DateTime(2024, 2, 10),
          userId: 'user1',
        ),
      ];

      final summary = calculateMonthlySummary(transactions, 2024, 1);
      expect(summary.year, 2024);
      expect(summary.month, 1);
      expect(summary.totalIncome, 1000.0);
      expect(summary.totalExpense, 500.0);
      expect(summary.balance, 500.0);
      expect(summary.expensesByCategory['Groceries'], 300.0);
      expect(summary.expensesByCategory['Transport'], 200.0);
    });
  });

  group('calculateMonthlyTrends', () {
    test('returns empty list for empty transaction list', () {
      expect(calculateMonthlyTrends([]), []);
    });

    test('calculates trends for single month', () {
      final transactions = [
        Transaction(
          id: '1',
          amount: 1000.0,
          category: 'Salary',
          type: TransactionType.income,
          date: DateTime(2024, 1, 15),
          userId: 'user1',
        ),
        Transaction(
          id: '2',
          amount: 300.0,
          category: 'Groceries',
          type: TransactionType.expense,
          date: DateTime(2024, 1, 20),
          userId: 'user1',
        ),
      ];

      final trends = calculateMonthlyTrends(transactions);
      expect(trends.length, 1);
      expect(trends[0].year, 2024);
      expect(trends[0].month, 1);
      expect(trends[0].totalIncome, 1000.0);
      expect(trends[0].totalExpense, 300.0);
    });

    test('calculates trends across multiple months', () {
      final transactions = [
        Transaction(
          id: '1',
          amount: 1000.0,
          category: 'Salary',
          type: TransactionType.income,
          date: DateTime(2024, 1, 15),
          userId: 'user1',
        ),
        Transaction(
          id: '2',
          amount: 300.0,
          category: 'Groceries',
          type: TransactionType.expense,
          date: DateTime(2024, 1, 20),
          userId: 'user1',
        ),
        Transaction(
          id: '3',
          amount: 1200.0,
          category: 'Salary',
          type: TransactionType.income,
          date: DateTime(2024, 2, 15),
          userId: 'user1',
        ),
        Transaction(
          id: '4',
          amount: 400.0,
          category: 'Groceries',
          type: TransactionType.expense,
          date: DateTime(2024, 3, 10),
          userId: 'user1',
        ),
      ];

      final trends = calculateMonthlyTrends(transactions);
      expect(trends.length, 3);
      
      // January
      expect(trends[0].year, 2024);
      expect(trends[0].month, 1);
      expect(trends[0].totalIncome, 1000.0);
      expect(trends[0].totalExpense, 300.0);
      
      // February
      expect(trends[1].year, 2024);
      expect(trends[1].month, 2);
      expect(trends[1].totalIncome, 1200.0);
      expect(trends[1].totalExpense, 0.0);
      
      // March
      expect(trends[2].year, 2024);
      expect(trends[2].month, 3);
      expect(trends[2].totalIncome, 0.0);
      expect(trends[2].totalExpense, 400.0);
    });
  });
}
