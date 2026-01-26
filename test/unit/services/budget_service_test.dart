import 'package:flutter_test/flutter_test.dart';
import 'package:perfin/models/budget.dart';
import 'package:perfin/services/budget_service.dart';
import 'mock_storage_service.dart';

void main() {
  late MockStorageService mockStorage;
  late BudgetService budgetService;

  setUp(() {
    mockStorage = MockStorageService();
    mockStorage.init();
    budgetService = BudgetService(mockStorage);
  });

  group('BudgetService', () {
    group('fetchMonthlyBudget', () {
      test('returns null when no budget exists', () async {
        final result = await budgetService.fetchMonthlyBudget('user1', 2024, 1);
        expect(result, isNull);
      });

      test('returns saved budget', () async {
        final budget = Budget(
          id: 'budget1',
          userId: 'user1',
          amount: 1000.0,
          year: 2024,
          month: 1,
        );

        await budgetService.saveBudget(budget);
        final result = await budgetService.fetchMonthlyBudget('user1', 2024, 1);

        expect(result, isNotNull);
        expect(result!.id, equals('budget1'));
        expect(result.amount, equals(1000.0));
        expect(result.year, equals(2024));
        expect(result.month, equals(1));
      });
    });

    group('fetchCategoryBudgets', () {
      test('returns empty map when no category budgets exist', () async {
        final result = await budgetService.fetchCategoryBudgets('user1');
        expect(result, isEmpty);
      });

      test('returns saved category budgets', () async {
        await budgetService.saveCategoryBudget('Food', 500.0, 'user1');
        await budgetService.saveCategoryBudget('Transport', 200.0, 'user1');

        final result = await budgetService.fetchCategoryBudgets('user1');

        expect(result, hasLength(2));
        expect(result['Food'], equals(500.0));
        expect(result['Transport'], equals(200.0));
      });
    });

    group('saveBudget', () {
      test('saves valid budget successfully', () async {
        final budget = Budget(
          id: 'budget1',
          userId: 'user1',
          amount: 1500.0,
          year: 2024,
          month: 3,
        );

        await budgetService.saveBudget(budget);
        final result = await budgetService.fetchMonthlyBudget('user1', 2024, 3);

        expect(result, isNotNull);
        expect(result!.amount, equals(1500.0));
      });

      test('throws ValidationException for invalid budget (zero amount)', () async {
        final budget = Budget(
          id: 'budget1',
          userId: 'user1',
          amount: 0.0,
          year: 2024,
          month: 1,
        );

        expect(
          () => budgetService.saveBudget(budget),
          throwsA(isA<ValidationException>()),
        );
      });

      test('throws ValidationException for invalid budget (negative amount)', () async {
        final budget = Budget(
          id: 'budget1',
          userId: 'user1',
          amount: -100.0,
          year: 2024,
          month: 1,
        );

        expect(
          () => budgetService.saveBudget(budget),
          throwsA(isA<ValidationException>()),
        );
      });

      test('throws ValidationException for invalid month', () async {
        final budget = Budget(
          id: 'budget1',
          userId: 'user1',
          amount: 1000.0,
          year: 2024,
          month: 13,
        );

        expect(
          () => budgetService.saveBudget(budget),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('saveCategoryBudget', () {
      test('saves valid category budget successfully', () async {
        await budgetService.saveCategoryBudget('Entertainment', 300.0, 'user1');

        final result = await budgetService.fetchCategoryBudgets('user1');
        expect(result['Entertainment'], equals(300.0));
      });

      test('updates existing category budget', () async {
        await budgetService.saveCategoryBudget('Food', 500.0, 'user1');
        await budgetService.saveCategoryBudget('Food', 600.0, 'user1');

        final result = await budgetService.fetchCategoryBudgets('user1');
        expect(result['Food'], equals(600.0));
      });

      test('throws ValidationException for zero amount', () async {
        expect(
          () => budgetService.saveCategoryBudget('Food', 0.0, 'user1'),
          throwsA(isA<ValidationException>()),
        );
      });

      test('throws ValidationException for negative amount', () async {
        expect(
          () => budgetService.saveCategoryBudget('Food', -100.0, 'user1'),
          throwsA(isA<ValidationException>()),
        );
      });

      test('throws ValidationException for empty category', () async {
        expect(
          () => budgetService.saveCategoryBudget('', 100.0, 'user1'),
          throwsA(isA<ValidationException>()),
        );
      });

      test('throws ValidationException for whitespace-only category', () async {
        expect(
          () => budgetService.saveCategoryBudget('   ', 100.0, 'user1'),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('storage error handling', () {
      test('throws BudgetServiceException when storage fails on save', () async {
        // Create a storage that will fail
        final failingStorage = MockStorageService();
        // Don't initialize it, so it will throw
        final failingService = BudgetService(failingStorage);

        final budget = Budget(
          id: 'budget1',
          userId: 'user1',
          amount: 1000.0,
          year: 2024,
          month: 1,
        );

        expect(
          () => failingService.saveBudget(budget),
          throwsA(isA<BudgetServiceException>()),
        );
      });
    });
  });
}
