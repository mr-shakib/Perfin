import 'package:flutter/foundation.dart';
import '../models/trend_data_point.dart';
import '../models/spending_anomaly.dart';
import '../services/insight_service.dart';

/// Loading state enum
enum LoadingState {
  idle,
  loading,
  loaded,
  error,
}

/// Provider managing insight state and operations
/// Uses ChangeNotifier to notify listeners of state changes
class InsightProvider extends ChangeNotifier {
  final InsightService _insightService;
  String? _userId;

  // Private state
  Map<String, double> _spendingByCategory = {};
  List<TrendDataPoint> _spendingTrend = [];
  Map<String, double> _budgetUtilization = {};
  List<SpendingAnomaly> _anomalies = [];
  LoadingState _state = LoadingState.idle;
  String? _errorMessage;

  InsightProvider(this._insightService);

  // Public getters
  Map<String, double> get spendingByCategory => Map.unmodifiable(_spendingByCategory);
  List<TrendDataPoint> get spendingTrend => List.unmodifiable(_spendingTrend);
  Map<String, double> get budgetUtilization => Map.unmodifiable(_budgetUtilization);
  List<SpendingAnomaly> get anomalies => List.unmodifiable(_anomalies);
  LoadingState get state => _state;
  String? get errorMessage => _errorMessage;

  /// Update the user ID for this provider
  void updateUserId(String? userId) {
    _userId = userId;
    if (userId == null) {
      // Clear insights when user logs out
      _spendingByCategory = {};
      _spendingTrend = [];
      _budgetUtilization = {};
      _anomalies = [];
      _state = LoadingState.idle;
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Load spending by category for a date range
  Future<void> loadSpendingByCategory({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
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
      _spendingByCategory = await _insightService.calculateSpendingByCategory(
        userId: _userId!,
        startDate: startDate,
        endDate: endDate,
      );
      _state = LoadingState.loaded;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _state = LoadingState.error;
      _errorMessage = 'Failed to load spending data: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Load spending trend for a date range
  Future<void> loadSpendingTrend({
    required DateTime startDate,
    required DateTime endDate,
    required TrendGranularity granularity,
  }) async {
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
      _spendingTrend = await _insightService.calculateSpendingTrend(
        userId: _userId!,
        startDate: startDate,
        endDate: endDate,
        granularity: granularity,
      );
      _state = LoadingState.loaded;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _state = LoadingState.error;
      _errorMessage = 'Failed to load spending trend: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Load budget utilization for a month
  Future<void> loadBudgetUtilization({
    required DateTime month,
    required Map<String, double> categoryBudgets,
  }) async {
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
      _budgetUtilization = await _insightService.calculateBudgetUtilization(
        userId: _userId!,
        month: month,
        categoryBudgets: categoryBudgets,
      );
      _state = LoadingState.loaded;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _state = LoadingState.error;
      _errorMessage = 'Failed to load budget utilization: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Load anomalies for a date range
  Future<void> loadAnomalies({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
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
      _anomalies = await _insightService.detectAnomalies(
        userId: _userId!,
        startDate: startDate,
        endDate: endDate,
      );
      _state = LoadingState.loaded;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _state = LoadingState.error;
      _errorMessage = 'Failed to load anomalies: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Load all insights for a date range
  Future<void> loadAllInsights({
    required DateTime startDate,
    required DateTime endDate,
    required TrendGranularity granularity,
    Map<String, double>? categoryBudgets,
  }) async {
    await Future.wait([
      loadSpendingByCategory(startDate: startDate, endDate: endDate),
      loadSpendingTrend(
        startDate: startDate,
        endDate: endDate,
        granularity: granularity,
      ),
      loadAnomalies(startDate: startDate, endDate: endDate),
      if (categoryBudgets != null)
        loadBudgetUtilization(
          month: startDate,
          categoryBudgets: categoryBudgets,
        ),
    ]);
  }
}
