import 'package:flutter_test/flutter_test.dart';
import 'package:perfin/models/transaction.dart';

void main() {
  group('Transaction Model', () {
    test('should create a valid transaction', () {
      final transaction = Transaction(
        id: '1',
        amount: 100.0,
        category: 'Food',
        type: TransactionType.expense,
        date: DateTime(2024, 1, 1),
        notes: 'Lunch',
        userId: 'user1',
      );

      expect(transaction.id, '1');
      expect(transaction.amount, 100.0);
      expect(transaction.category, 'Food');
      expect(transaction.type, TransactionType.expense);
      expect(transaction.notes, 'Lunch');
      expect(transaction.userId, 'user1');
    });

    test('should validate a valid transaction', () {
      final transaction = Transaction(
        id: '1',
        amount: 100.0,
        category: 'Food',
        type: TransactionType.expense,
        date: DateTime(2024, 1, 1),
        userId: 'user1',
      );

      expect(transaction.isValid(), true);
    });

    test('should invalidate transaction with non-positive amount', () {
      final transaction = Transaction(
        id: '1',
        amount: 0,
        category: 'Food',
        type: TransactionType.expense,
        date: DateTime(2024, 1, 1),
        userId: 'user1',
      );

      expect(transaction.isValid(), false);
    });

    test('should invalidate transaction with empty category', () {
      final transaction = Transaction(
        id: '1',
        amount: 100.0,
        category: '   ',
        type: TransactionType.expense,
        date: DateTime(2024, 1, 1),
        userId: 'user1',
      );

      expect(transaction.isValid(), false);
    });

    test('should invalidate transaction with future date', () {
      final futureDate = DateTime.now().add(Duration(days: 1));
      final transaction = Transaction(
        id: '1',
        amount: 100.0,
        category: 'Food',
        type: TransactionType.expense,
        date: futureDate,
        userId: 'user1',
      );

      expect(transaction.isValid(), false);
    });

    test('should serialize to JSON correctly', () {
      final transaction = Transaction(
        id: '1',
        amount: 100.0,
        category: 'Food',
        type: TransactionType.expense,
        date: DateTime(2024, 1, 1),
        notes: 'Lunch',
        userId: 'user1',
      );

      final json = transaction.toJson();

      expect(json['id'], '1');
      expect(json['amount'], 100.0);
      expect(json['category'], 'Food');
      expect(json['type'], 'expense');
      expect(json['date'], '2024-01-01T00:00:00.000');
      expect(json['notes'], 'Lunch');
      expect(json['userId'], 'user1');
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': '1',
        'amount': 100.0,
        'category': 'Food',
        'type': 'expense',
        'date': '2024-01-01T00:00:00.000',
        'notes': 'Lunch',
        'userId': 'user1',
      };

      final transaction = Transaction.fromJson(json);

      expect(transaction.id, '1');
      expect(transaction.amount, 100.0);
      expect(transaction.category, 'Food');
      expect(transaction.type, TransactionType.expense);
      expect(transaction.date, DateTime(2024, 1, 1));
      expect(transaction.notes, 'Lunch');
      expect(transaction.userId, 'user1');
    });

    test('should handle income transaction type', () {
      final transaction = Transaction(
        id: '1',
        amount: 1000.0,
        category: 'Salary',
        type: TransactionType.income,
        date: DateTime(2024, 1, 1),
        userId: 'user1',
      );

      expect(transaction.type, TransactionType.income);
      expect(transaction.isValid(), true);
    });

    test('should handle null notes', () {
      final transaction = Transaction(
        id: '1',
        amount: 100.0,
        category: 'Food',
        type: TransactionType.expense,
        date: DateTime(2024, 1, 1),
        userId: 'user1',
      );

      expect(transaction.notes, null);
      
      final json = transaction.toJson();
      expect(json['notes'], null);
      
      final deserialized = Transaction.fromJson(json);
      expect(deserialized.notes, null);
    });
  });

  group('TransactionType', () {
    test('should serialize to JSON correctly', () {
      expect(TransactionType.income.toJson(), 'income');
      expect(TransactionType.expense.toJson(), 'expense');
    });

    test('should deserialize from JSON correctly', () {
      expect(TransactionType.fromJson('income'), TransactionType.income);
      expect(TransactionType.fromJson('expense'), TransactionType.expense);
    });

    test('should throw error for invalid type', () {
      expect(
        () => TransactionType.fromJson('invalid'),
        throwsArgumentError,
      );
    });
  });
}
