import 'dart:math';
import '../models/transaction.dart';
import '../models/trend_data_point.dart';
import '../models/spending_anomaly.dart';
import 'transaction_service.dart';

/// Granularity for trend calculations
enum TrendGranularity {
  daily,
  weekly,
  monthly,
}

/// Service responsible for financial insights and analytics
/// Handles spending analysis, trend calculations, and anomaly detection
class InsightService {
  final TransactionService _transactionService;

  InsightService(this._transactionService);

  /// Calculate spending by category for a date range
  /// Returns map of category name to total spending amount
  /// Only includes expense transactions
  Future<Map<String, double>> calculateSpendingByCategory({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final transactions = await _transactionService.fetchTransactions(userId);

      // Filter transactions by date range and type
      final filteredTransactions = transactions.where((t) =>
          t.type == TransactionType.expense &&
          !t.date.isBefore(startDate) &&
          !t.date.isAfter(endDate)).toList();

      // Aggregate by category
      final Map<String, double> categorySpending = {};
      for (final transaction in filteredTransactions) {
        categorySpending[transaction.category] =
            (categorySpending[transaction.category] ?? 0.0) + transaction.amount;
      }

      return categorySpending;
    } catch (e) {
      throw InsightServiceException(
        'Failed to calculate spending by category: ${e.toString()}',
      );
    }
  }

  /// Calculate spending trend over time
  /// Returns list of data points aggregated by specified granularity
  Future<List<TrendDataPoint>> calculateSpendingTrend({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    required TrendGranularity granularity,
  }) async {
    try {
      final transactions = await _transactionService.fetchTransactions(userId);

      // Filter expense transactions by date range
      final filteredTransactions = transactions.where((t) =>
          t.type == TransactionType.expense &&
          !t.date.isBefore(startDate) &&
          !t.date.isAfter(endDate)).toList();

      // Group transactions by time period
      final Map<DateTime, double> periodSpending = {};

      for (final transaction in filteredTransactions) {
        final periodKey = _getPeriodKey(transaction.date, granularity);
        periodSpending[periodKey] =
            (periodSpending[periodKey] ?? 0.0) + transaction.amount;
      }

      // Convert to sorted list of data points
      final dataPoints = periodSpending.entries
          .map((entry) => TrendDataPoint(
                date: entry.key,
                amount: entry.value,
              ))
          .toList();

      dataPoints.sort((a, b) => a.date.compareTo(b.date));

      return dataPoints;
    } catch (e) {
      throw InsightServiceException(
        'Failed to calculate spending trend: ${e.toString()}',
      );
    }
  }

  /// Calculate budget utilization percentages for a specific month
  /// Returns map of category name to utilization percentage
  /// Requires category budgets to be passed in
  Future<Map<String, double>> calculateBudgetUtilization({
    required String userId,
    required DateTime month,
    required Map<String, double> categoryBudgets,
  }) async {
    try {
      // Calculate start and end of month
      final startDate = DateTime(month.year, month.month, 1);
      final endDate = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

      // Get spending by category for the month
      final categorySpending = await calculateSpendingByCategory(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      // Calculate utilization percentages
      final Map<String, double> utilization = {};
      for (final entry in categoryBudgets.entries) {
        final category = entry.key;
        final budgetLimit = entry.value;

        if (budgetLimit > 0) {
          final spent = categorySpending[category] ?? 0.0;
          utilization[category] = (spent / budgetLimit) * 100.0;
        } else {
          utilization[category] = 0.0;
        }
      }

      return utilization;
    } catch (e) {
      throw InsightServiceException(
        'Failed to calculate budget utilization: ${e.toString()}',
      );
    }
  }

  /// Detect spending anomalies using statistical methods
  /// Identifies transactions that deviate significantly from normal patterns
  /// Uses 2 standard deviations as the threshold
  Future<List<SpendingAnomaly>> detectAnomalies({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final transactions = await _transactionService.fetchTransactions(userId);

      // Filter expense transactions by date range
      final filteredTransactions = transactions.where((t) =>
          t.type == TransactionType.expense &&
          !t.date.isBefore(startDate) &&
          !t.date.isAfter(endDate)).toList();

      if (filteredTransactions.isEmpty) {
        return [];
      }

      // Group transactions by category
      final Map<String, List<Transaction>> categoryTransactions = {};
      for (final transaction in filteredTransactions) {
        categoryTransactions.putIfAbsent(transaction.category, () => []);
        categoryTransactions[transaction.category]!.add(transaction);
      }

      final List<SpendingAnomaly> anomalies = [];

      // Detect anomalies within each category
      for (final entry in categoryTransactions.entries) {
        final category = entry.key;
        final categoryTxns = entry.value;

        // Need at least 3 transactions to establish a pattern
        if (categoryTxns.length < 3) {
          continue;
        }

        // Calculate mean and standard deviation
        final amounts = categoryTxns.map((t) => t.amount).toList();
        final mean = _calculateMean(amounts);
        final stdDev = _calculateStandardDeviation(amounts, mean);

        // Identify outliers (beyond 2 standard deviations)
        for (final transaction in categoryTxns) {
          final deviation = (transaction.amount - mean).abs();
          if (stdDev > 0 && deviation > 2 * stdDev) {
            // This is an anomaly
            final deviationFromNormal = ((transaction.amount - mean) / mean) * 100;
            final confidenceScore = _calculateAnomalyConfidence(
              deviation,
              stdDev,
              categoryTxns.length,
            );

            anomalies.add(SpendingAnomaly(
              transactionId: transaction.id,
              categoryId: category,
              amount: transaction.amount,
              date: transaction.date,
              anomalyType: transaction.amount > mean
                  ? 'unusually_high'
                  : 'unusually_low',
              explanation: transaction.amount > mean
                  ? 'This transaction is ${deviationFromNormal.abs().toStringAsFixed(1)}% higher than your typical $category spending'
                  : 'This transaction is ${deviationFromNormal.abs().toStringAsFixed(1)}% lower than your typical $category spending',
              deviationFromNormal: deviationFromNormal,
              confidenceScore: confidenceScore,
            ));
          }
        }
      }

      return anomalies;
    } catch (e) {
      throw InsightServiceException(
        'Failed to detect anomalies: ${e.toString()}',
      );
    }
  }

  /// Get period key for grouping transactions by granularity
  DateTime _getPeriodKey(DateTime date, TrendGranularity granularity) {
    switch (granularity) {
      case TrendGranularity.daily:
        return DateTime(date.year, date.month, date.day);
      case TrendGranularity.weekly:
        // Start of week (Monday)
        final dayOfWeek = date.weekday;
        final startOfWeek = date.subtract(Duration(days: dayOfWeek - 1));
        return DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      case TrendGranularity.monthly:
        return DateTime(date.year, date.month, 1);
    }
  }

  /// Calculate mean of a list of numbers
  double _calculateMean(List<double> values) {
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  /// Calculate standard deviation
  double _calculateStandardDeviation(List<double> values, double mean) {
    if (values.length < 2) return 0.0;

    final variance = values
            .map((value) => pow(value - mean, 2))
            .reduce((a, b) => a + b) /
        values.length;

    return sqrt(variance);
  }

  /// Calculate confidence score for anomaly detection
  /// Higher deviation and more data points increase confidence
  int _calculateAnomalyConfidence(
    double deviation,
    double stdDev,
    int sampleSize,
  ) {
    // Base confidence on how many standard deviations away
    final sigmaMultiple = deviation / stdDev;

    // More standard deviations = higher confidence
    double confidence = (sigmaMultiple - 2) * 20 + 60;

    // Adjust for sample size (more data = more confidence)
    if (sampleSize < 10) {
      confidence *= 0.8;
    } else if (sampleSize > 30) {
      confidence *= 1.1;
    }

    // Clamp to 0-100 range
    return confidence.clamp(0, 100).round();
  }
}

/// Custom exception for insight service operations
class InsightServiceException implements Exception {
  final String message;

  InsightServiceException(this.message);

  @override
  String toString() => 'InsightServiceException: $message';
}
