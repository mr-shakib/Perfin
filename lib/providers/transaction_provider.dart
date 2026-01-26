import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../models/monthly_summary.dart';
import '../services/transaction_service.dart';
import '../utils/calculation_utils.dart';

/// Enum representing the loading state
enum LoadingState {
  idle,
  loading,
  loaded,
  error,
}

/// Provider managing transaction state and operations
/// Uses ChangeNotifier to notify listeners of state changes
/// Provides derived state calculations for balance, summaries, and analytics
class TransactionProvider extends ChangeNotifier {
  final TransactionService _transactionService;
  String? _userId;

  // Private state
  List<Transaction> _transactions = [];
  LoadingState _state = LoadingState.idle;
  String? _errorMessage;

  TransactionProvider(this._transactionService);

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
      _errorMessage = 'Failed to add transaction: ${e.toString()}';
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
        .where((t) => 
            (t.date.isAfter(start) || t.date.isAtSameMomentAs(start)) &&
            (t.date.isBefore(end) || t.date.isAtSameMomentAs(end)))
        .toList();
  }
}
