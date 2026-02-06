import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../models/monthly_summary.dart';
import '../models/budget.dart';
import '../models/sync_operation.dart';
import '../models/sync_result.dart';
import '../services/transaction_service.dart';
import '../services/notification_service.dart';
import '../services/sync_service.dart';
import '../utils/calculation_utils.dart';

/// Enum representing the loading state
enum LoadingState { idle, loading, loaded, error }

/// Provider managing transaction state and operations
/// Uses ChangeNotifier to notify listeners of state changes
/// Provides derived state calculations for balance, summaries, and analytics
class TransactionProvider extends ChangeNotifier {
  final TransactionService _transactionService;
  final NotificationService? _notificationService;
  final SyncService? _syncService;
  String? _userId;

  // Private state
  List<Transaction> _transactions = [];
  LoadingState _state = LoadingState.idle;
  String? _errorMessage;

  // Budget tracking for notifications
  Budget? _monthlyBudget;
  Map<String, double> _categoryBudgets = {};

  TransactionProvider(
    this._transactionService, [
    this._notificationService,
    this._syncService,
  ]);

  // Public getters for base state
  List<Transaction> get transactions => List.unmodifiable(_transactions);

  LoadingState get state => _state;

  String? get errorMessage => _errorMessage;

  // Derived state getters - computed from base state

  /// Calculate current balance (total income - total expense)
  double get currentBalance {
    return calculateBalance(_transactions);
  }

  /// Calculate total income from all transactions
  double get totalIncome {
    return _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Calculate total expense from all transactions
  double get totalExpense {
    return _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Calculate expenses grouped by category
  Map<String, double> get expensesByCategory {
    return calculateExpensesByCategory(_transactions);
  }

  /// Calculate monthly trends over time
  List<MonthlySummary> get monthlyTrends {
    return calculateMonthlyTrends(_transactions);
  }

  /// Get summary for the current month
  MonthlySummary get currentMonthSummary {
    final now = DateTime.now();
    return calculateMonthlySummary(_transactions, now.year, now.month);
  }

  /// Update the user ID for this provider
  /// Should be called when authentication state changes
  void updateUserId(String? userId) {
    _userId = userId;
    if (userId == null) {
      // Clear transactions when user logs out
      _transactions = [];
      _state = LoadingState.idle;
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Update budget information for notification checking
  void updateBudgets(
    Budget? monthlyBudget,
    Map<String, double> categoryBudgets,
  ) {
    _monthlyBudget = monthlyBudget;
    _categoryBudgets = categoryBudgets;
  }

  /// Load transactions from storage
  /// Sets state to loading during fetch
  /// Sets state to loaded on success
  /// Sets state to error on failure with error message
  Future<void> loadTransactions() async {
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
      _transactions = await _transactionService.fetchTransactions(_userId!);
      _state = LoadingState.loaded;
      _errorMessage = null;
      notifyListeners();
    } on TransactionServiceException catch (e) {
      _state = LoadingState.error;
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _state = LoadingState.error;
      _errorMessage = 'Failed to load transactions: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Add a new transaction
  /// Validates transaction before adding
  /// Persists to storage on success
  /// Updates state and notifies listeners
  Future<void> addTransaction(Transaction transaction) async {
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
      await _transactionService.saveTransaction(transaction);

      // Queue sync operation for Supabase
      await _queueSyncOperation(
        operationType: 'create',
        entityId: transaction.id,
        data: transaction.toSupabaseJson(),
      );

      // Reload transactions to get updated list
      _transactions = await _transactionService.fetchTransactions(_userId!);
      _state = LoadingState.loaded;
      _errorMessage = null;
      notifyListeners();

      // Check budget and send notifications if needed
      await _checkBudgetAndNotify();
    } on ValidationException catch (e) {
      _state = LoadingState.error;
      _errorMessage = 'Validation failed: ${e.message}';
      notifyListeners();
    } on TransactionServiceException catch (e) {
      _state = LoadingState.error;
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _state = LoadingState.error;
      _errorMessage = 'Failed to add transaction: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Bulk import transactions from bill analysis
  /// Creates multiple transactions from extracted bill data
  /// Persists to storage on success
  /// Updates state and notifies listeners
  Future<void> importTransactionsFromBill(
    List<Map<String, dynamic>> extractedTransactions,
  ) async {
    if (_userId == null) {
      _state = LoadingState.error;
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return;
    }

    if (extractedTransactions.isEmpty) {
      _errorMessage = 'No transactions to import';
      notifyListeners();
      return;
    }

    _state = LoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final uuid = const Uuid();
      int successCount = 0;

      for (final txnData in extractedTransactions) {
        try {
          // Parse transaction data
          final amount = (txnData['amount'] as num?)?.toDouble() ?? 0.0;
          final category = txnData['category'] as String? ?? 'other';
          final description = txnData['description'] as String? ?? 'Unknown';
          final merchant = txnData['merchant'] as String? ?? '';
          final dateStr = txnData['date'] as String?;
          
          DateTime transactionDate;
          try {
            transactionDate = dateStr != null 
                ? DateTime.parse(dateStr) 
                : DateTime.now();
          } catch (e) {
            transactionDate = DateTime.now();
          }

          // Create transaction
          final transaction = Transaction(
            id: uuid.v4(),
            amount: amount,
            category: category,
            type: TransactionType.expense,
            date: transactionDate,
            notes: merchant.isNotEmpty 
                ? '$merchant - $description' 
                : description,
            userId: _userId!,
            isSynced: false,
          );

          // Validate and save
          if (transaction.isValid()) {
            await _transactionService.saveTransaction(transaction);

            // Queue sync operation
            await _queueSyncOperation(
              operationType: 'create',
              entityId: transaction.id,
              data: transaction.toSupabaseJson(),
            );

            successCount++;
          }
        } catch (e) {
          debugPrint('Failed to import transaction: $e');
          // Continue with other transactions
        }
      }

      // Reload transactions to get updated list
      _transactions = await _transactionService.fetchTransactions(_userId!);
      _state = LoadingState.loaded;
      _errorMessage = successCount > 0 
          ? null 
          : 'Failed to import any transactions';
      notifyListeners();

      // Check budget and send notifications if needed
      if (successCount > 0) {
        await _checkBudgetAndNotify();
      }
    } catch (e) {
      _state = LoadingState.error;
      _errorMessage = 'Failed to import transactions: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Update an existing transaction
  /// Validates transaction before updating
  /// Persists to storage on success
  /// Updates state and notifies listeners
  Future<void> updateTransaction(String id, Transaction transaction) async {
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
      await _transactionService.updateTransaction(transaction);

      // Queue sync operation for Supabase
      await _queueSyncOperation(
        operationType: 'update',
        entityId: transaction.id,
        data: transaction.toSupabaseJson(),
      );

      // Reload transactions to get updated list
      _transactions = await _transactionService.fetchTransactions(_userId!);
      _state = LoadingState.loaded;
      _errorMessage = null;
      notifyListeners();
    } on ValidationException catch (e) {
      _state = LoadingState.error;
      _errorMessage = 'Validation failed: ${e.message}';
      notifyListeners();
    } on TransactionServiceException catch (e) {
      _state = LoadingState.error;
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _state = LoadingState.error;
      _errorMessage = 'Failed to update transaction: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Delete a transaction
  /// Persists to storage on success
  /// Updates state and notifies listeners
  Future<void> deleteTransaction(String id) async {
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
      await _transactionService.deleteTransaction(id, _userId!);

      // Queue sync operation for Supabase
      await _queueSyncOperation(
        operationType: 'delete',
        entityId: id,
        data: {'id': id},
      );

      // Reload transactions to get updated list
      _transactions = await _transactionService.fetchTransactions(_userId!);
      _state = LoadingState.loaded;
      _errorMessage = null;
      notifyListeners();
    } on TransactionServiceException catch (e) {
      _state = LoadingState.error;
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _state = LoadingState.error;
      _errorMessage = 'Failed to delete transaction: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Get transactions within a specific date range
  /// Returns list of transactions filtered by date range
  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactions
        .where(
          (t) =>
              (t.date.isAfter(start) || t.date.isAtSameMomentAs(start)) &&
              (t.date.isBefore(end) || t.date.isAtSameMomentAs(end)),
        )
        .toList();
  }

  /// Check budget utilization and send notifications if thresholds are exceeded
  Future<void> _checkBudgetAndNotify() async {
    if (_notificationService == null || _userId == null) return;

    final now = DateTime.now();
    final currentMonthExpenses = currentMonthSummary.totalExpense;

    // Check monthly budget
    if (_monthlyBudget != null &&
        _monthlyBudget!.year == now.year &&
        _monthlyBudget!.month == now.month) {
      final utilization = (currentMonthExpenses / _monthlyBudget!.amount) * 100;

      // Send notification if budget is at 80% or over 100%
      if (utilization >= 80) {
        try {
          await _notificationService.sendBudgetAlert(
            userId: _userId!,
            budget: _monthlyBudget!,
            utilizationPercentage: utilization,
          );
        } catch (e) {
          // Don't fail transaction if notification fails
          debugPrint('Failed to send budget notification: $e');
        }
      }
    }

    // Check category budgets
    final expensesByCategory = this.expensesByCategory;
    for (var entry in _categoryBudgets.entries) {
      final category = entry.key;
      final budgetAmount = entry.value;
      final spent = expensesByCategory[category] ?? 0.0;
      final utilization = (spent / budgetAmount) * 100;

      // Send notification if category budget is at 80% or over 100%
      if (utilization >= 80) {
        try {
          // Create a budget object for the category
          final categoryBudget = Budget(
            id: 'category_$category',
            userId: _userId!,
            amount: budgetAmount,
            year: now.year,
            month: now.month,
          );

          await _notificationService.sendBudgetAlert(
            userId: _userId!,
            budget: categoryBudget,
            utilizationPercentage: utilization,
          );
        } catch (e) {
          // Don't fail transaction if notification fails
          debugPrint('Failed to send category budget notification: $e');
        }
      }
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
        entityType: 'transaction',
        entityId: entityId,
        data: data,
        queuedAt: DateTime.now(),
      );

      await _syncService.queueOperation(operation: operation);
      debugPrint(
        'Queued sync operation: $operationType for transaction $entityId',
      );

      // Trigger background sync (fire and forget)
      _syncService.processSyncQueue().catchError((e) {
        debugPrint('Background sync failed: $e');
        // Return empty result on error
        return SyncResult(
          successCount: 0,
          failureCount: 0,
          failedOperationIds: [],
          syncedAt: DateTime.now(),
        );
      });
    } catch (e) {
      // Don't fail the transaction if sync queueing fails
      debugPrint('Failed to queue sync operation: $e');
    }
  }
}
