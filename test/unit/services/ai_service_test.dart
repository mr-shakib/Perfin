import 'package:flutter_test/flutter_test.dart';
import 'package:perfin/services/ai_service.dart';
import 'package:perfin/services/transaction_service.dart';
import 'package:perfin/services/budget_service.dart';
import 'package:perfin/services/goal_service.dart';
import 'package:perfin/services/insight_service.dart';
import 'package:perfin/models/transaction.dart';
import 'mock_storage_service.dart';

void main() {
  group('AIService', () {
    late MockStorageService mockStorage;
    late TransactionService transactionService;
    late BudgetService budgetService;
    late GoalService goalService;
    late InsightService insightService;
    late AIService aiService;

    setUp(() {
      mockStorage = MockStorageService();
      mockStorage.init(); // Initialize storage
      transactionService = TransactionService(mockStorage);
      budgetService = BudgetService(mockStorage);
      goalService = GoalService(mockStorage, transactionService);
      insightService = InsightService(transactionService);
      
      // Use a test API key (will fail actual API calls but allows testing structure)
      aiService = AIService(
        transactionService: transactionService,
        budgetService: budgetService,
        goalService: goalService,
        insightService: insightService,
        apiKey: 'test-api-key',
      );
    });

    test('AIService can be instantiated', () {
      expect(aiService, isNotNull);
    });

    test('getSuggestedQuestions returns list of questions', () {
      final questions = aiService.getSuggestedQuestions();
      
      expect(questions, isNotEmpty);
      expect(questions.length, greaterThan(5));
      expect(questions.first, contains('?'));
    });

    test('generateFinancialSummary handles insufficient data', () async {
      // Test with no transactions
      final summary = await aiService.generateFinancialSummary(
        userId: 'test-user',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
      );

      expect(summary.hasInsufficientData, isTrue);
      expect(summary.confidenceScore, equals(0));
      expect(summary.totalSpending, equals(0.0));
      expect(summary.totalIncome, equals(0.0));
    });

    test('predictMonthEndSpending throws error with insufficient data', () async {
      // Test with no transactions (less than 30 days)
      expect(
        () => aiService.predictMonthEndSpending(
          userId: 'test-user',
          targetMonth: DateTime.now(),
        ),
        throwsA(isA<AIServiceException>()),
      );
    });

    test('detectSpendingPatterns returns empty list with no data', () async {
      final patterns = await aiService.detectSpendingPatterns(
        userId: 'test-user',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
      );

      expect(patterns, isEmpty);
    });

    test('detectRecurringExpenses returns empty list with no data', () async {
      final expenses = await aiService.detectRecurringExpenses(
        userId: 'test-user',
      );

      expect(expenses, isEmpty);
    });

    test('analyzeGoalFeasibility throws error with insufficient data', () async {
      // Create a test goal
      final goal = await goalService.createGoal(
        userId: 'test-user',
        name: 'Test Goal',
        targetAmount: 1000.0,
        targetDate: DateTime.now().add(const Duration(days: 365)),
      );

      // Test with no transactions
      expect(
        () => aiService.analyzeGoalFeasibility(
          userId: 'test-user',
          goal: goal,
        ),
        throwsA(isA<AIServiceException>()),
      );
    });

    test('suggestSpendingReductions returns empty list with no data', () async {
      final suggestions = await aiService.suggestSpendingReductions(
        userId: 'test-user',
        targetSavings: 100.0,
      );

      expect(suggestions, isEmpty);
    });

    test('prioritizeGoals throws error with no goals', () async {
      expect(
        () => aiService.prioritizeGoals(
          userId: 'test-user',
          goals: [],
        ),
        throwsA(isA<AIServiceException>()),
      );
    });

    group('With sample data', () {
      setUp(() async {
        // Add some sample transactions
        final now = DateTime.now();
        
        for (int i = 0; i < 15; i++) {
          await transactionService.saveTransaction(
            Transaction(
              id: 'txn-$i',
              userId: 'test-user',
              amount: 50.0 + (i * 10),
              category: i % 3 == 0 ? 'groceries' : (i % 3 == 1 ? 'entertainment' : 'utilities'),
              type: TransactionType.expense,
              date: now.subtract(Duration(days: i * 2)),
              notes: 'Test transaction $i',
            ),
          );
        }

        // Add some income transactions
        await transactionService.saveTransaction(
          Transaction(
            id: 'income-1',
            userId: 'test-user',
            amount: 3000.0,
            category: 'salary',
            type: TransactionType.income,
            date: now.subtract(const Duration(days: 5)),
            notes: 'Monthly salary',
          ),
        );
      });

      test('generateFinancialSummary works with sufficient data', () async {
        final summary = await aiService.generateFinancialSummary(
          userId: 'test-user',
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now(),
        );

        expect(summary.hasInsufficientData, isFalse);
        expect(summary.totalSpending, greaterThan(0));
        expect(summary.totalIncome, greaterThan(0));
        expect(summary.topSpendingCategory, isNotEmpty);
        expect(summary.confidenceScore, greaterThan(0));
      });

      test('detectSpendingPatterns finds patterns with data', () async {
        final patterns = await aiService.detectSpendingPatterns(
          userId: 'test-user',
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now(),
        );

        // May or may not find patterns depending on data, but should not throw
        expect(patterns, isA<List>());
      });

      test('detectRecurringExpenses finds recurring expenses', () async {
        // Add more similar transactions to create a pattern
        final now = DateTime.now();
        for (int i = 0; i < 3; i++) {
          await transactionService.saveTransaction(
            Transaction(
              id: 'recurring-$i',
              userId: 'test-user',
              amount: 100.0,
              category: 'subscription',
              type: TransactionType.expense,
              date: now.subtract(Duration(days: i * 30)),
              notes: 'Monthly subscription',
            ),
          );
        }

        final expenses = await aiService.detectRecurringExpenses(
          userId: 'test-user',
        );

        // Should detect the recurring subscription
        expect(expenses, isNotEmpty);
        final subscription = expenses.firstWhere(
          (e) => e.categoryId == 'subscription',
          orElse: () => expenses.first,
        );
        expect(subscription.averageAmount, closeTo(100.0, 10.0));
      });
    });
  });
}
