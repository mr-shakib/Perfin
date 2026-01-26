import 'package:flutter_test/flutter_test.dart';
import 'package:perfin/models/budget.dart';

void main() {
  group('Budget Model', () {
    test('should create Budget instance with all required fields', () {
      final budget = Budget(
        id: 'budget-1',
        userId: 'user-1',
        amount: 5000.0,
        year: 2024,
        month: 1,
      );

      expect(budget.id, 'budget-1');
      expect(budget.userId, 'user-1');
      expect(budget.amount, 5000.0);
      expect(budget.year, 2024);
      expect(budget.month, 1);
    });

    test('should serialize to JSON correctly', () {
      final budget = Budget(
        id: 'budget-1',
        userId: 'user-1',
        amount: 5000.0,
        year: 2024,
        month: 1,
      );

      final json = budget.toJson();

      expect(json['id'], 'budget-1');
      expect(json['userId'], 'user-1');
      expect(json['amount'], 5000.0);
      expect(json['year'], 2024);
      expect(json['month'], 1);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'budget-1',
        'userId': 'user-1',
        'amount': 5000.0,
        'year': 2024,
        'month': 1,
      };

      final budget = Budget.fromJson(json);

      expect(budget.id, 'budget-1');
      expect(budget.userId, 'user-1');
      expect(budget.amount, 5000.0);
      expect(budget.year, 2024);
      expect(budget.month, 1);
    });

    test('should handle round-trip JSON serialization', () {
      final original = Budget(
        id: 'budget-1',
        userId: 'user-1',
        amount: 5000.0,
        year: 2024,
        month: 1,
      );

      final json = original.toJson();
      final deserialized = Budget.fromJson(json);

      expect(deserialized, original);
    });

    test('should handle amount as integer in JSON', () {
      final json = {
        'id': 'budget-1',
        'userId': 'user-1',
        'amount': 5000, // Integer instead of double
        'year': 2024,
        'month': 1,
      };

      final budget = Budget.fromJson(json);

      expect(budget.amount, 5000.0);
    });

    test('should correctly implement equality', () {
      final budget1 = Budget(
        id: 'budget-1',
        userId: 'user-1',
        amount: 5000.0,
        year: 2024,
        month: 1,
      );

      final budget2 = Budget(
        id: 'budget-1',
        userId: 'user-1',
        amount: 5000.0,
        year: 2024,
        month: 1,
      );

      final budget3 = Budget(
        id: 'budget-2',
        userId: 'user-1',
        amount: 5000.0,
        year: 2024,
        month: 1,
      );

      expect(budget1, budget2);
      expect(budget1, isNot(budget3));
    });

    test('should correctly implement hashCode', () {
      final budget1 = Budget(
        id: 'budget-1',
        userId: 'user-1',
        amount: 5000.0,
        year: 2024,
        month: 1,
      );

      final budget2 = Budget(
        id: 'budget-1',
        userId: 'user-1',
        amount: 5000.0,
        year: 2024,
        month: 1,
      );

      expect(budget1.hashCode, budget2.hashCode);
    });

    test('should correctly implement toString', () {
      final budget = Budget(
        id: 'budget-1',
        userId: 'user-1',
        amount: 5000.0,
        year: 2024,
        month: 1,
      );

      final string = budget.toString();

      expect(string, contains('budget-1'));
      expect(string, contains('user-1'));
      expect(string, contains('5000.0'));
      expect(string, contains('2024'));
      expect(string, contains('1'));
    });
  });
}
