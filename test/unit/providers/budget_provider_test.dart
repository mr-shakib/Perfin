import 'package:flutter_test/flutter_test.dart';
import 'package:perfin/models/transaction.dart';
import 'package:perfin/providers/budget_provider.dart';
import 'package:perfin/providers/transaction_provider.dart';
import 'package:perfin/services/budget_service.dart';
import 'package:perfin/services/transaction_service.dart';
import '../services/mock_storage_service.dart';

void main() {
  late MockStorageService mockStorage;
  late BudgetService budgetService;
  late TransactionService transactionService;
  late BudgetProvider budgetProvider;
  late TransactionProvider transactionProvider;

  setUp(() {
    mockStorage = MockStorageService();
    mockStorage.init();
    budgetService = BudgetService(mockStorage);
    transactionService = TransactionService(mockStorage);
    budgetProvider = BudgetProvider(budgetService);
    transactionProvider = TransactionProvider(transactionService);
  });

  group('BudgetProvider', () {
    group('initialization', () {
      test('starts with idle state', () {
        expect(budgetProvider.state, equals(LoadingState.idle));
        expect(budgetProvider.monthlyBudget, isNull);
        expect(budgetProvider.categoryBudgets, isEmpty);
        expect(budgetProvider.errorMessage, isNull);
      });
    });

    group('updateAuth', () {
      test('sets user ID and transaction provider', () {
        budgetProvider.updateAuth('user1', transactionProvider);
        // No direct way to verify, but should not throw
      });

      test('clears state when user logs out', () async {
        budgetProvider.updateAuth('user1', transactionProvider);
        await budgetProvider.setMonthlyBudget(1000.0);
        
        budgetProvider.updateAuth(null, null);
        
        expect(budgetProvider.monthlyBudget, isNull);
        expect(budgetProvider.categoryBudgets, isEmpty);
        expect(budgetProvider.state, equals(LoadingState.idle));
      });
    });

    group('setMonthlyBudget', () {
      test('sets monthly budget successfully', () async {
        budgetProvider.updateAuth('user1', transactionProvider);
        
        await budgetProvider.setMonthlyBudget(1500.0);
        
        expect(budgetProvider.state, equals(LoadingState.loaded));
        expect(budgetProvider.monthlyBudget, isNotNull);
        expect(budgetProvider.monthlyBudget!.amount, equals(1500.0));
        expect(budgetProvider.errorMessage, isNull);
      });

      test('fails when user not authenticated', () async {
        await budgetProvider.setMonthlyBudget(1000.0);
        
        expect(budgetProvider.state, equals(LoadingState.error));
        expect(budgetProvider.errorMessage, equals('User not authenticated'));
      });

      test('fails with validation error for zero amount', () async {
        budgetProvider.updateAuth('user1', transactionProvider);
        
        await budgetProvider.setMonthlyBudget(0.0);
        
        expect(budgetProvider.state, equals(LoadingState.error));
        expect(budgetProvider.errorMessage, contains('Validation failed'));
      });

      test('fails with validation error for negative amount', () async {
        budgetProvider.updateAuth('user1', transactionProvider);
        
        await budgetProvider.setMonthlyBudget(-100.0);
        
        expect(budgetProvider.state, equals(LoadingState.error));
        expect(budgetProvider.errorMessage, contains('Validation failed'));
      });
    });

    group('setCategoryBudget', () {
      test('sets category budget successfully', () async {
        budgetProvider.updateAuth('user1', transactionProvider);
        
        await budgetProvider.setCategoryBudget('Food', 500.0);
        
        expect(budgetProvider.state, equals(LoadingState.loaded));
        expect(budgetProvider.categoryBudgets['Food'], equals(500.0));
        expect(budgetProvider.errorMessage, isNull);
      });

      test('updates existing category budget', () async {
        budgetProvider.updateAuth('user1', transactionProvider);
        
        await budgetProvider.setCategoryBudget('Food', 500.0);
        await budgetProvider.setCategoryBudget('Food', 600.0);
        
        expect(budgetProvider.categoryBudgets['Food'], equals(600.0));
      });

      test('fails when user not authenticated', () async {
        await budgetProvider.setCategoryBudget('Food', 500.0);
        
        expect(budgetProvider.state, equals(LoadingState.error));
        expect(budgetProvider.errorMessage, equals('User not authenticated'));
      });

      test('fails with validation error for zero amount', () async {
        budgetProvider.updateAuth('user1', transactionProvider);
        
        await budgetProvider.setCategoryBudget('Food', 0.0);
        
        expect(budgetProvider.state, equals(LoadingState.error));
        expect(budgetProvider.errorMessage, contains('Validation failed'));
      });

      test('fails with validation error for empty category', () async {
        budgetProvider.updateAuth('user1', transactionProvider);
        
        await budgetProvider.setCategoryBudget('', 500.0);
        
        expect(budgetProvider.state, equals(LoadingState.error));
        expect(budgetProvider.errorMessage, contains('Validation failed'));
      });
    });

    group('loadBudgets', () {
      test('loads budgets successfully', () async {
        budgetProvider.updateAuth('user1', transactionProvider);
        
        // Set some budgets first
        await budgetProvider.setMonthlyBudget(2000.0);
        await budgetProvider.setCategoryBudget('Food', 500.0);
        
        // Now load them
        await budgetProvider.loadBudgets();
        
        expect(budgetProvider.state, equals(LoadingState.loaded));
        expect(budgetProvider.monthlyBudget, isNotNull);
        expect(budgetProvider.categoryBudgets, isNotEmpty);
      });

      test('fails when user not authenticated', () async {
        await budgetProvider.loadBudgets();
        
        expect(budgetProvider.state, equals(LoadingState.error));
        expect(budgetProvider.errorMessage, equals('User not authenticated'));
      });
    });

    group('getBudgetStatusForCategory', () {
      test('returns underBudget when spent < 80%', () async {
        budgetProvider.updateAuth('user1', transactionProvider);
        await budgetProvider.setCategoryBudget('Food', 1000.0);
        
        final status = budgetProvider.getBudgetStatusForCategory('Food', 500.0);
        expect(status, equals(BudgetStatus.underBudget));
      });

      test('returns nearLimit when spent >= 80% and <= 100%', () async {
        budgetProvider.updateAuth('user1', transactionProvider);
        await budgetProvider.setCategoryBudget('Food', 1000.0);
        
        final status = budgetProvider.getBudgetStatusForCategory('Food', 850.0);
        expect(status, equals(BudgetStatus.nearLimit));
      });

      test('returns overBudget when spent > 100%', () async {
        budgetProvider.updateAuth('user1', transactionProvider);
        await budgetProvider.setCategoryBudget('Food', 1000.0);
        
        final status = budgetProvider.getBudgetStatusForCategory('Food', 1200.0);
        expect(status, equals(BudgetStatus.overBudget));
      });

      test('returns underBudget when no budget set for category', () {
        final status = budgetProvider.getBudgetStatusForCategory('Food', 500.0);
        expect(status, equals(BudgetStatus.underBudget));
      });
    });

    group('derived state', () {
      test('remainingBudget returns 0 when no budget set', () {
        expect(budgetProvider.remainingBudget, equals(0.0));
      });

      test('remainingBudget calculates correctly with transactions', () async {
        // Set up transaction provider with user
        transactionProvider.updateUserId('user1');
        
        // Add some expense transactions for current month
        final now = DateTime.now();
        final transaction = Transaction(
          id: 'trans1',
          amount: 300.0,
          category: 'Food',
          type: TransactionType.expense,
          date: now,
          userId: 'user1',
        );
        await transactionService.saveTransaction(transaction);
        await transactionProvider.loadTransactions();
        
        // Set up budget provider
        budgetProvider.updateAuth('user1', transactionProvider);
        await budgetProvider.setMonthlyBudget(1000.0);
        
        // Remaining should be 1000 - 300 = 700
        expect(budgetProvider.remainingBudget, equals(700.0));
      });

      test('isOverBudget returns false when no budget set', () {
        expect(budgetProvider.isOverBudget, equals(false));
      });

      test('isOverBudget returns true when expenses exceed budget', () async {
        // Set up transaction provider with user
        transactionProvider.updateUserId('user1');
        
        // Add expense transaction exceeding budget
        final now = DateTime.now();
        final transaction = Transaction(
          id: 'trans1',
          amount: 1500.0,
          category: 'Food',
          type: TransactionType.expense,
          date: now,
          userId: 'user1',
        );
        await transactionService.saveTransaction(transaction);
        await transactionProvider.loadTransactions();
        
        // Set up budget provider
        budgetProvider.updateAuth('user1', transactionProvider);
        await budgetProvider.setMonthlyBudget(1000.0);
        
        expect(budgetProvider.isOverBudget, equals(true));
      });

      test('categoryBudgetStatus returns empty map when no transaction provider', () {
        expect(budgetProvider.categoryBudgetStatus, isEmpty);
      });

      test('categoryBudgetStatus calculates status for all categories', () async {
        // Set up transaction provider with user
        transactionProvider.updateUserId('user1');
        
        // Add expense transactions
        final now = DateTime.now();
        await transactionService.saveTransaction(Transaction(
          id: 'trans1',
          amount: 400.0,
          category: 'Food',
          type: TransactionType.expense,
          date: now,
          userId: 'user1',
        ));
        await transactionService.saveTransaction(Transaction(
          id: 'trans2',
          amount: 900.0,
          category: 'Transport',
          type: TransactionType.expense,
          date: now,
          userId: 'user1',
        ));
        await transactionProvider.loadTransactions();
        
        // Set up budget provider with category budgets
        budgetProvider.updateAuth('user1', transactionProvider);
        await budgetProvider.setCategoryBudget('Food', 1000.0);
        await budgetProvider.setCategoryBudget('Transport', 1000.0);
        
        final statusMap = budgetProvider.categoryBudgetStatus;
        
        expect(statusMap['Food'], equals(BudgetStatus.underBudget)); // 40%
        expect(statusMap['Transport'], equals(BudgetStatus.nearLimit)); // 90%
      });
    });
  });
}
