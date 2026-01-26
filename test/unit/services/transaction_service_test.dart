import 'package:flutter_test/flutter_test.dart';
import 'package:perfin/models/transaction.dart';
import 'package:perfin/services/transaction_service.dart';
import 'mock_storage_service.dart';

void main() {
  group('TransactionService', () {
    late TransactionService transactionService;
    late MockStorageService storageService;

    setUp(() async {
      storageService = MockStorageService();
      await storageService.init();
      transactionService = TransactionService(storageService);
    });

    tearDown(() async {
      await storageService.clear();
    });

    test('fetchTransactions returns empty list when no transactions exist', () async {
      final transactions = await transactionService.fetchTransactions('user123');
      expect(transactions, isEmpty);
    });

    test('saveTransaction adds a valid transaction', () async {
      final transaction = Transaction(
        id: 'txn1',
        amount: 100.0,
        category: 'Food',
        type: TransactionType.expense,
        date: DateTime.now().subtract(const Duration(days: 1)),
        userId: 'user123',
      );

      await transactionService.saveTransaction(transaction);

      final transactions = await transactionService.fetchTransactions('user123');
      expect(transactions.length, 1);
      expect(transactions[0].id, 'txn1');
      expect(transactions[0].amount, 100.0);
    });

    test('saveTransaction throws ValidationException for invalid transaction', () async {
      final transaction = Transaction(
        id: 'txn1',
        amount: -50.0, // Invalid: negative amount
        category: 'Food',
        type: TransactionType.expense,
        date: DateTime.now(),
        userId: 'user123',
      );

      expect(
        () => transactionService.saveTransaction(transaction),
        throwsA(isA<ValidationException>()),
      );
    });

    test('updateTransaction modifies existing transaction', () async {
      final transaction = Transaction(
        id: 'txn1',
        amount: 100.0,
        category: 'Food',
        type: TransactionType.expense,
        date: DateTime.now().subtract(const Duration(days: 1)),
        userId: 'user123',
      );

      await transactionService.saveTransaction(transaction);

      final updatedTransaction = Transaction(
        id: 'txn1',
        amount: 150.0,
        category: 'Groceries',
        type: TransactionType.expense,
        date: DateTime.now().subtract(const Duration(days: 1)),
        userId: 'user123',
      );

      await transactionService.updateTransaction(updatedTransaction);

      final transactions = await transactionService.fetchTransactions('user123');
      expect(transactions.length, 1);
      expect(transactions[0].amount, 150.0);
      expect(transactions[0].category, 'Groceries');
    });

    test('updateTransaction throws exception for non-existent transaction', () async {
      final transaction = Transaction(
        id: 'nonexistent',
        amount: 100.0,
        category: 'Food',
        type: TransactionType.expense,
        date: DateTime.now().subtract(const Duration(days: 1)),
        userId: 'user123',
      );

      expect(
        () => transactionService.updateTransaction(transaction),
        throwsA(isA<TransactionServiceException>()),
      );
    });

    test('deleteTransaction removes transaction', () async {
      final transaction = Transaction(
        id: 'txn1',
        amount: 100.0,
        category: 'Food',
        type: TransactionType.expense,
        date: DateTime.now().subtract(const Duration(days: 1)),
        userId: 'user123',
      );

      await transactionService.saveTransaction(transaction);
      await transactionService.deleteTransaction('txn1', 'user123');

      final transactions = await transactionService.fetchTransactions('user123');
      expect(transactions, isEmpty);
    });

    test('deleteTransaction throws exception for non-existent transaction', () async {
      expect(
        () => transactionService.deleteTransaction('nonexistent', 'user123'),
        throwsA(isA<TransactionServiceException>()),
      );
    });

    test('fetchTransactions returns transactions ordered by date', () async {
      final transaction1 = Transaction(
        id: 'txn1',
        amount: 100.0,
        category: 'Food',
        type: TransactionType.expense,
        date: DateTime(2024, 1, 1),
        userId: 'user123',
      );

      final transaction2 = Transaction(
        id: 'txn2',
        amount: 200.0,
        category: 'Transport',
        type: TransactionType.expense,
        date: DateTime(2024, 1, 15),
        userId: 'user123',
      );

      final transaction3 = Transaction(
        id: 'txn3',
        amount: 300.0,
        category: 'Salary',
        type: TransactionType.income,
        date: DateTime(2024, 1, 10),
        userId: 'user123',
      );

      await transactionService.saveTransaction(transaction1);
      await transactionService.saveTransaction(transaction2);
      await transactionService.saveTransaction(transaction3);

      final transactions = await transactionService.fetchTransactions('user123');
      expect(transactions.length, 3);
      // Should be ordered by date, most recent first
      expect(transactions[0].id, 'txn2'); // Jan 15
      expect(transactions[1].id, 'txn3'); // Jan 10
      expect(transactions[2].id, 'txn1'); // Jan 1
    });
  });
}
