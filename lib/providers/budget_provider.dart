import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/budget.dart';
import '../models/sync_operation.dart';
import '../models/sync_result.dart';
import '../services/budget_service.dart';
import '../services/sync_service.dart';
import 'transaction_provider.dart';

// Export LoadingState from transaction_provider for consistency
export 'transaction_provider.dart' show LoadingState;

/// Enum representing budget status
enum BudgetStatus { underBudget, nearLimit, overBudget }

/// Provider managing budget state and operations
/// Uses ChangeNotifier to notify listeners of state changes
/// Provides derived state calculations for remaining budget and over-budget detection
class BudgetProvider extends ChangeNotifier {
  final BudgetService _budgetService;
  final SyncService? _syncService;
  TransactionProvider? _transactionProvider;
  String? _userId;

  // Private state
  Budget? _monthlyBudget;
  Map<String, double> _categoryBudgets = {};
  LoadingState _state = LoadingState.idle;
  String? _errorMessage;

  BudgetProvider(this._budgetService, [this._syncService]);

  // Public getters for base state
  Budget? get monthlyBudget => _monthlyBudget;

  Map<String, double> get categoryBudgets => Map.unmodifiable(_categoryBudgets);

  LoadingState get state => _state;

  String? get errorMessage => _errorMessage;

  // Derived state getters - computed from base state

  /// Calculate remaining budget (budget amount - total expenses)
  /// Returns 0 if no budget is set
  double get remainingBudget {
    if (_monthlyBudget == null || _transactionProvider == null) {
      return 0.0;
    }

    final now = DateTime.now();
    // Only consider current month's expenses if budget is for current month
    if (_monthlyBudget!.year == now.year &&
        _monthlyBudget!.month == now.month) {
      return _monthlyBudget!.amount -
          _transactionProvider!.currentMonthSummary.totalExpense;
    }

    return _monthlyBudget!.amount;
  }

  /// Get budget status for each category
  /// Returns map of category name to BudgetStatus
  Map<String, BudgetStatus> get categoryBudgetStatus {
    if (_transactionProvider == null) {
      return {};
    }

    final expensesByCategory = _transactionProvider!.expensesByCategory;
    final Map<String, BudgetStatus> statusMap = {};

    for (var entry in _categoryBudgets.entries) {
      final category = entry.key;
      final spent = expensesByCategory[category] ?? 0.0;

      statusMap[category] = getBudgetStatusForCategory(category, spent);
    }

    return statusMap;
  }

  /// Check if total expenses exceed monthly budget
  /// Returns false if no budget is set
  bool get isOverBudget {
    if (_monthlyBudget == null || _transactionProvider == null) {
      return false;
    }

    final now = DateTime.now();
    // Only check current month's expenses if budget is for current month
    if (_monthlyBudget!.year == now.year &&
        _monthlyBudget!.month == now.month) {
      return _transactionProvider!.currentMonthSummary.totalExpense >
          _monthlyBudget!.amount;
    }

    return false;
  }

  /// Update the user ID and transaction provider for this provider
  /// Should be called when authentication state changes
  void updateAuth(String? userId, TransactionProvider? transactionProvider) {
    _userId = userId;
    _transactionProvider = transactionProvider;

    if (userId == null) {
      // Clear budgets when user logs out
      _monthlyBudget = null;
      _categoryBudgets = {};
      _state = LoadingState.idle;
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Load budgets from storage
  /// Sets state to loading during fetch
  /// Sets state to loaded on success
  /// Sets state to error on failure with error message
  Future<void> loadBudgets() async {
    if (_userId == null) {
      _state = LoadingState.error;
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return;
    }

    _state = LoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      _monthlyBudget = await _budgetService.fetchMonthlyBudget(
        _userId!,
        now.year,
        now.month,
      );
      _categoryBudgets = await _budgetService.fetchCategoryBudgets(_userId!);

      // Update transaction provider with budget info
      _transactionProvider?.updateBudgets(_monthlyBudget, _categoryBudgets);

      _state = LoadingState.loaded;
      _errorMessage = null;
      notifyListeners();
    } on BudgetServiceException catch (e) {
      _state = LoadingState.error;
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _state = LoadingState.error;
      _errorMessage = 'Failed to load budgets: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Set monthly budget
  /// Validates budget before saving
  /// Persists to storage on success
  /// Updates state and notifies listeners
  Future<void> setMonthlyBudget(double amount) async {
    if (_userId == null) {
      _state = LoadingState.error;
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return;
    }

    _state = LoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final budget = Budget(
        id: 'budget_${_userId}_${now.year}_${now.month}',
        userId: _userId!,
        amount: amount,
        year: now.year,
        month: now.month,
      );

      await _budgetService.saveBudget(budget);
      _monthlyBudget = budget;

      // Queue sync operation for Supabase
      await _queueSyncOperation(
        operationType: 'create',
        entityId: budget.id,
        data: budget.toSupabaseJson(),
      );

      // Update transaction provider with new budget info
      _transactionProvider?.updateBudgets(_monthlyBudget, _categoryBudgets);

      _state = LoadingState.loaded;
      _errorMessage = null;
      notifyListeners();
    } on ValidationException catch (e) {
      _state = LoadingState.error;
      _errorMessage = 'Validation failed: ${e.message}';
      notifyListeners();
    } on BudgetServiceException catch (e) {
      _state = LoadingState.error;
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _state = LoadingState.error;
      _errorMessage = 'Failed to set monthly budget: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Set category budget
  /// Validates budget before saving
  /// Persists to storage on success
  /// Updates state and notifies listeners
  Future<void> setCategoryBudget(String category, double amount) async {
    if (_userId == null) {
      _state = LoadingState.error;
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return;
    }

    _state = LoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _budgetService.saveCategoryBudget(category, amount, _userId!);

      // Update local state
      _categoryBudgets[category] = amount;

      // Update transaction provider with new budget info
      _transactionProvider?.updateBudgets(_monthlyBudget, _categoryBudgets);

      _state = LoadingState.loaded;
      _errorMessage = null;
      notifyListeners();
    } on ValidationException catch (e) {
      _state = LoadingState.error;
      _errorMessage = 'Validation failed: ${e.message}';
      notifyListeners();
    } on BudgetServiceException catch (e) {
      _state = LoadingState.error;
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _state = LoadingState.error;
      _errorMessage = 'Failed to set category budget: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Get budget status for a specific category
  /// Returns BudgetStatus based on spent amount vs budget amount
  /// - underBudget: spent < 80% of budget
  /// - nearLimit: spent >= 80% and <= 100% of budget
  /// - overBudget: spent > 100% of budget
  BudgetStatus getBudgetStatusForCategory(String category, double spent) {
    final budgetAmount = _categoryBudgets[category];

    if (budgetAmount == null || budgetAmount == 0) {
      return BudgetStatus.underBudget;
    }

    final percentage = spent / budgetAmount;

    if (percentage > 1.0) {
      return BudgetStatus.overBudget;
    } else if (percentage >= 0.8) {
      return BudgetStatus.nearLimit;
    } else {
      return BudgetStatus.underBudget;
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
        entityType: 'budget',
        entityId: entityId,
        data: data,
        queuedAt: DateTime.now(),
      );

      await _syncService.queueOperation(operation: operation);
      debugPrint('Queued sync operation: $operationType for budget $entityId');

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
