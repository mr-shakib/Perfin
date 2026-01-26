import 'dart:convert';
import '../models/goal.dart';
import 'storage_service.dart';
import 'transaction_service.dart';

/// Service responsible for goal management
/// Handles goal CRUD operations and automatic progress tracking
class GoalService {
  final StorageService _storageService;
  final TransactionService _transactionService;

  static const String _goalsKeyPrefix = 'goals_';

  GoalService(this._storageService, this._transactionService);

  /// Create a new goal
  /// Validates input and saves to storage
  Future<Goal> createGoal({
    required String userId,
    required String name,
    required double targetAmount,
    required DateTime targetDate,
    double currentAmount = 0.0,
    String? linkedCategoryId,
  }) async {
    // Validate inputs
    if (name.trim().isEmpty) {
      throw GoalServiceException('Goal name cannot be empty');
    }

    if (targetAmount <= 0) {
      throw GoalServiceException('Target amount must be positive');
    }

    if (targetDate.isBefore(DateTime.now())) {
      throw GoalServiceException('Target date cannot be in the past');
    }

    if (currentAmount < 0) {
      throw GoalServiceException('Current amount cannot be negative');
    }

    try {
      final now = DateTime.now();
      final goal = Goal(
        id: _generateId(),
        userId: userId,
        name: name,
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        targetDate: targetDate,
        createdAt: now,
        updatedAt: now,
        isCompleted: false,
        linkedCategoryId: linkedCategoryId,
        isManualTracking: false,
      );

      // Fetch existing goals
      final goals = await getUserGoals(userId: userId, includeCompleted: true);

      // Add new goal
      goals.add(goal);

      // Save updated list
      await _saveGoalsList(userId, goals);

      return goal;
    } catch (e) {
      if (e is GoalServiceException) {
        rethrow;
      }
      throw GoalServiceException('Failed to create goal: ${e.toString()}');
    }
  }

  /// Update goal progress
  /// Sets manual tracking flag when user manually updates progress
  Future<Goal> updateGoalProgress({
    required String goalId,
    required String userId,
    required double newAmount,
  }) async {
    if (newAmount < 0) {
      throw GoalServiceException('Amount cannot be negative');
    }

    try {
      final goal = await getGoalById(goalId, userId);
      if (goal == null) {
        throw GoalServiceException('Goal with ID $goalId not found');
      }

      // Update goal with new amount and set manual tracking
      final updatedGoal = goal.copyWith(
        currentAmount: newAmount,
        updatedAt: DateTime.now(),
        isManualTracking: true,
      );

      await _updateGoal(updatedGoal);

      return updatedGoal;
    } catch (e) {
      if (e is GoalServiceException) {
        rethrow;
      }
      throw GoalServiceException(
          'Failed to update goal progress: ${e.toString()}');
    }
  }

  /// Calculate required monthly savings for a goal
  /// Formula: (target_amount - current_amount) / months_remaining
  double calculateRequiredMonthlySavings({
    required double targetAmount,
    required double currentAmount,
    required DateTime targetDate,
  }) {
    final now = DateTime.now();
    final monthsRemaining =
        (targetDate.year - now.year) * 12 + (targetDate.month - now.month);

    if (monthsRemaining <= 0) return 0;

    return (targetAmount - currentAmount) / monthsRemaining;
  }

  /// Calculate progress percentage for a goal
  /// Formula: (current_amount / target_amount) * 100
  double calculateProgressPercentage({
    required double currentAmount,
    required double targetAmount,
  }) {
    if (targetAmount <= 0) return 0;
    return (currentAmount / targetAmount) * 100;
  }

  /// Mark goal as complete
  /// Moves goal to completed state
  Future<Goal> markGoalComplete({
    required String goalId,
    required String userId,
  }) async {
    try {
      final goal = await getGoalById(goalId, userId);
      if (goal == null) {
        throw GoalServiceException('Goal with ID $goalId not found');
      }

      final updatedGoal = goal.copyWith(
        isCompleted: true,
        updatedAt: DateTime.now(),
      );

      await _updateGoal(updatedGoal);

      return updatedGoal;
    } catch (e) {
      if (e is GoalServiceException) {
        rethrow;
      }
      throw GoalServiceException('Failed to mark goal complete: ${e.toString()}');
    }
  }

  /// Delete a goal
  Future<void> deleteGoal({
    required String goalId,
    required String userId,
  }) async {
    try {
      final goal = await getGoalById(goalId, userId);
      if (goal == null) {
        throw GoalServiceException('Goal with ID $goalId not found');
      }

      // Fetch all goals
      final goals =
          await getUserGoals(userId: goal.userId, includeCompleted: true);

      // Remove the goal
      goals.removeWhere((g) => g.id == goalId);

      // Save updated list
      await _saveGoalsList(goal.userId, goals);
    } catch (e) {
      if (e is GoalServiceException) {
        rethrow;
      }
      throw GoalServiceException('Failed to delete goal: ${e.toString()}');
    }
  }

  /// Get all goals for a user
  /// Optionally include completed goals
  Future<List<Goal>> getUserGoals({
    required String userId,
    bool includeCompleted = false,
  }) async {
    try {
      final key = _getGoalsKey(userId);
      final goalsData = await _storageService.load<String>(key);

      if (goalsData == null) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(goalsData);
      final goals = jsonList
          .map((json) => Goal.fromJson(json as Map<String, dynamic>))
          .toList();

      // Filter by completion status if needed
      if (!includeCompleted) {
        return goals.where((g) => !g.isCompleted).toList();
      }

      return goals;
    } catch (e) {
      throw GoalServiceException('Failed to fetch goals: ${e.toString()}');
    }
  }

  /// Sync goal progress from linked transactions
  /// Automatically updates goal based on transactions in linked category
  Future<Goal> syncGoalFromTransactions({
    required String goalId,
    required String userId,
  }) async {
    try {
      final goal = await getGoalById(goalId, userId);
      if (goal == null) {
        throw GoalServiceException('Goal with ID $goalId not found');
      }

      // Only sync if goal has linked category and is not manually tracked
      if (goal.linkedCategoryId == null || goal.isManualTracking) {
        return goal;
      }

      // Fetch all transactions for user
      final transactions =
          await _transactionService.fetchTransactions(goal.userId);

      // Filter transactions by linked category and date (after goal creation)
      final linkedTransactions = transactions
          .where((t) =>
              t.category == goal.linkedCategoryId &&
              !t.date.isBefore(goal.createdAt))
          .toList();

      // Calculate total from linked transactions
      final totalAmount = linkedTransactions.fold<double>(
        0.0,
        (sum, t) => sum + t.amount,
      );

      // Update goal with calculated amount
      final updatedGoal = goal.copyWith(
        currentAmount: totalAmount,
        updatedAt: DateTime.now(),
      );

      await _updateGoal(updatedGoal);

      return updatedGoal;
    } catch (e) {
      if (e is GoalServiceException) {
        rethrow;
      }
      throw GoalServiceException(
          'Failed to sync goal from transactions: ${e.toString()}');
    }
  }

  /// Get a goal by ID with userId context
  Future<Goal?> getGoalById(String goalId, String userId) async {
    final goals = await getUserGoals(userId: userId, includeCompleted: true);
    try {
      return goals.firstWhere((g) => g.id == goalId);
    } catch (e) {
      return null;
    }
  }

  /// Update an existing goal
  Future<void> _updateGoal(Goal goal) async {
    try {
      final goals =
          await getUserGoals(userId: goal.userId, includeCompleted: true);

      final index = goals.indexWhere((g) => g.id == goal.id);
      if (index == -1) {
        throw GoalServiceException('Goal not found');
      }

      goals[index] = goal;

      await _saveGoalsList(goal.userId, goals);
    } catch (e) {
      if (e is GoalServiceException) {
        rethrow;
      }
      throw GoalServiceException('Failed to update goal: ${e.toString()}');
    }
  }

  /// Get storage key for user's goals
  String _getGoalsKey(String userId) {
    return '$_goalsKeyPrefix$userId';
  }

  /// Save goals list to storage
  Future<void> _saveGoalsList(String userId, List<Goal> goals) async {
    final key = _getGoalsKey(userId);
    final jsonList = goals.map((g) => g.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _storageService.save(key, jsonString);
  }

  /// Generate a unique ID for a goal
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

/// Custom exception for goal service operations
class GoalServiceException implements Exception {
  final String message;

  GoalServiceException(this.message);

  @override
  String toString() => 'GoalServiceException: $message';
}
