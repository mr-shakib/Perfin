import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/goal.dart';
import '../models/sync_operation.dart';
import '../models/sync_result.dart';
import '../services/goal_service.dart';
import '../services/sync_service.dart';

/// Enum representing the loading state
enum LoadingState { idle, loading, loaded, error }

/// Provider managing goal state and operations
/// Uses ChangeNotifier to notify listeners of state changes
class GoalProvider extends ChangeNotifier {
  final GoalService _goalService;
  final SyncService? _syncService;

  // Private state
  List<Goal> _goals = [];
  LoadingState _state = LoadingState.idle;
  String? _errorMessage;

  GoalProvider(this._goalService, [this._syncService]);

  // Public getters
  List<Goal> get goals => _goals;

  List<Goal> get activeGoals => _goals.where((g) => !g.isCompleted).toList();

  List<Goal> get completedGoals => _goals.where((g) => g.isCompleted).toList();

  LoadingState get state => _state;

  String? get errorMessage => _errorMessage;

  /// Load all goals for the current user
  Future<void> loadGoals(String userId) async {
    _state = LoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _goals = await _goalService.getUserGoals(
        userId: userId,
        includeCompleted: true,
      );
      _state = LoadingState.loaded;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _state = LoadingState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Create a new goal
  Future<void> createGoal({
    required String userId,
    required String name,
    required double targetAmount,
    required DateTime targetDate,
    double currentAmount = 0.0,
    String? linkedCategoryId,
  }) async {
    try {
      final goal = await _goalService.createGoal(
        userId: userId,
        name: name,
        targetAmount: targetAmount,
        targetDate: targetDate,
        currentAmount: currentAmount,
        linkedCategoryId: linkedCategoryId,
      );

      _goals.add(goal);

      // Queue sync operation for Supabase
      await _queueSyncOperation(
        operationType: 'create',
        entityId: goal.id,
        data: goal.toSupabaseJson(),
      );

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Update goal progress
  Future<void> updateGoalProgress({
    required String goalId,
    required String userId,
    required double newAmount,
  }) async {
    try {
      final updatedGoal = await _goalService.updateGoalProgress(
        goalId: goalId,
        userId: userId,
        newAmount: newAmount,
      );

      final index = _goals.indexWhere((g) => g.id == goalId);
      if (index != -1) {
        _goals[index] = updatedGoal;

        // Queue sync operation for Supabase
        await _queueSyncOperation(
          operationType: 'update',
          entityId: updatedGoal.id,
          data: updatedGoal.toSupabaseJson(),
        );

        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Mark goal as complete
  Future<void> markGoalComplete({
    required String goalId,
    required String userId,
  }) async {
    try {
      final updatedGoal = await _goalService.markGoalComplete(
        goalId: goalId,
        userId: userId,
      );

      final index = _goals.indexWhere((g) => g.id == goalId);
      if (index != -1) {
        _goals[index] = updatedGoal;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Delete a goal
  Future<void> deleteGoal({
    required String goalId,
    required String userId,
  }) async {
    try {
      await _goalService.deleteGoal(goalId: goalId, userId: userId);

      _goals.removeWhere((g) => g.id == goalId);

      // Queue sync operation for Supabase
      await _queueSyncOperation(
        operationType: 'delete',
        entityId: goalId,
        data: {'id': goalId},
      );

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Sync goal from linked transactions
  Future<void> syncGoalFromTransactions({
    required String goalId,
    required String userId,
  }) async {
    try {
      final updatedGoal = await _goalService.syncGoalFromTransactions(
        goalId: goalId,
        userId: userId,
      );

      final index = _goals.indexWhere((g) => g.id == goalId);
      if (index != -1) {
        _goals[index] = updatedGoal;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Get a specific goal by ID
  Goal? getGoalById(String goalId) {
    try {
      return _goals.firstWhere((g) => g.id == goalId);
    } catch (e) {
      return null;
    }
  }

  /// Queue a sync operation to sync data to Supabase
  Future<void> _queueSyncOperation({
    required String operationType,
    required String entityId,
    required Map<String, dynamic> data,
  }) async {
    if (_syncService == null) {
      debugPrint('SyncService not available, skipping sync');
      return;
    }

    try {
      final operation = SyncOperation(
        id: const Uuid().v4(),
        operationType: operationType,
        entityType: 'goal',
        entityId: entityId,
        data: data,
        queuedAt: DateTime.now(),
      );

      await _syncService.queueOperation(operation: operation);
      debugPrint('Queued sync operation: $operationType for goal $entityId');

      // Trigger background sync (fire and forget)
      _syncService.processSyncQueue().catchError((e) {
        debugPrint('Background sync failed: $e');
        return SyncResult(
          successCount: 0,
          failureCount: 0,
          failedOperationIds: [],
          syncedAt: DateTime.now(),
        );
      });
    } catch (e) {
      debugPrint('Failed to queue sync operation: $e');
    }
  }
}
