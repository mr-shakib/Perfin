import 'package:flutter_test/flutter_test.dart';
import 'package:perfin/models/models.dart';

void main() {
  group('Model Instantiation Tests', () {
    test('Goal model can be instantiated and serialized', () {
      final goal = Goal(
        id: 'test-id',
        userId: 'user-id',
        name: 'Test Goal',
        targetAmount: 1000.0,
        currentAmount: 500.0,
        targetDate: DateTime.now().add(const Duration(days: 365)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(goal.id, 'test-id');
      expect(goal.progressPercentage, 50.0);
      
      final json = goal.toJson();
      final fromJson = Goal.fromJson(json);
      expect(fromJson.id, goal.id);
      expect(fromJson.name, goal.name);
    });

    test('Transaction model with new fields can be instantiated', () {
      final transaction = Transaction(
        id: 'test-id',
        amount: 100.0,
        category: 'Food',
        type: TransactionType.expense,
        date: DateTime.now(),
        userId: 'user-id',
        isSynced: false,
        linkedGoalId: 'goal-id',
      );

      expect(transaction.isSynced, false);
      expect(transaction.linkedGoalId, 'goal-id');
      
      final json = transaction.toJson();
      final fromJson = Transaction.fromJson(json);
      expect(fromJson.isSynced, transaction.isSynced);
      expect(fromJson.linkedGoalId, transaction.linkedGoalId);
    });

    test('Budget model with isActive field can be instantiated', () {
      final budget = Budget(
        id: 'test-id',
        userId: 'user-id',
        amount: 500.0,
        year: 2026,
        month: 1,
        isActive: false,
      );

      expect(budget.isActive, false);
      
      final json = budget.toJson();
      final fromJson = Budget.fromJson(json);
      expect(fromJson.isActive, budget.isActive);
    });

    test('AISummary model can be instantiated', () {
      final summary = AISummary(
        summaryText: 'Test summary',
        totalSpending: 1000.0,
        totalIncome: 2000.0,
        topSpendingCategory: 'Food',
        topSpendingAmount: 500.0,
        insights: ['Insight 1', 'Insight 2'],
        anomalies: [],
        generatedAt: DateTime.now(),
        confidenceScore: 85,
      );

      expect(summary.confidenceScore, 85);
      expect(summary.insights.length, 2);
    });

    test('ChatMessage model can be instantiated', () {
      final message = ChatMessage(
        id: 'test-id',
        userId: 'user-id',
        content: 'Test message',
        role: MessageRole.user,
        timestamp: DateTime.now(),
      );

      expect(message.role, MessageRole.user);
      
      final json = message.toJson();
      final fromJson = ChatMessage.fromJson(json);
      expect(fromJson.role, message.role);
    });

    test('SyncOperation model can be instantiated', () {
      final operation = SyncOperation(
        id: 'test-id',
        operationType: 'create',
        entityType: 'transaction',
        entityId: 'entity-id',
        data: {'test': 'data'},
        queuedAt: DateTime.now(),
        status: SyncStatus.pending,
      );

      expect(operation.status, SyncStatus.pending);
      expect(operation.retryCount, 0);
      
      final json = operation.toJson();
      final fromJson = SyncOperation.fromJson(json);
      expect(fromJson.status, operation.status);
    });

    test('NotificationPreferences model can be instantiated', () {
      final prefs = NotificationPreferences(
        userId: 'user-id',
        budgetAlerts: true,
        recurringExpenseReminders: false,
        goalDeadlineAlerts: true,
        unusualSpendingAlerts: false,
        updatedAt: DateTime.now(),
      );

      expect(prefs.budgetAlerts, true);
      expect(prefs.recurringExpenseReminders, false);
      
      final json = prefs.toJson();
      final fromJson = NotificationPreferences.fromJson(json);
      expect(fromJson.budgetAlerts, prefs.budgetAlerts);
    });

    test('GoalFeasibilityAnalysis model can be instantiated', () {
      final analysis = GoalFeasibilityAnalysis(
        goalId: 'goal-id',
        isAchievable: true,
        requiredMonthlySavings: 100.0,
        averageMonthlySurplus: 150.0,
        feasibilityLevel: FeasibilityLevel.easy,
        suggestedReductions: [],
        explanation: 'Test explanation',
        confidenceScore: 90,
        analyzedAt: DateTime.now(),
      );

      expect(analysis.feasibilityLevel, FeasibilityLevel.easy);
      expect(analysis.isAchievable, true);
      
      final json = analysis.toJson();
      final fromJson = GoalFeasibilityAnalysis.fromJson(json);
      expect(fromJson.feasibilityLevel, analysis.feasibilityLevel);
    });
  });
}
