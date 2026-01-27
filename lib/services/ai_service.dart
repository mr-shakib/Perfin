import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/ai_summary.dart';
import '../models/spending_prediction.dart';
import '../models/spending_pattern.dart';
import '../models/recurring_expense.dart';
import '../models/ai_response.dart';
import '../models/chat_message.dart';
import '../models/goal.dart';
import '../models/goal_feasibility_analysis.dart';
import '../models/spending_reduction.dart';
import '../models/goal_prioritization.dart';
import '../models/data_reference.dart';
import '../models/transaction.dart';
import 'transaction_service.dart';
import 'budget_service.dart';
import 'goal_service.dart';
import 'insight_service.dart';

/// Service responsible for AI-powered insights and predictions
/// Uses Groq API for natural language generation
class AIService {
  final TransactionService _transactionService;
  final BudgetService _budgetService;
  final GoalService _goalService;
  final InsightService _insightService;
  final String _apiKey;
  final String _baseUrl = 'https://api.groq.com/openai/v1';
  final String _model = 'llama-3.3-70b-versatile'; // Free, fast, and powerful

  // Essential categories that should not be suggested for reduction
  static const List<String> _essentialCategories = [
    'rent',
    'mortgage',
    'utilities',
    'groceries',
    'healthcare',
    'insurance',
    'transportation',
  ];

  AIService({
    required TransactionService transactionService,
    required BudgetService budgetService,
    required GoalService goalService,
    required InsightService insightService,
    required String apiKey,
  })  : _transactionService = transactionService,
        _budgetService = budgetService,
        _goalService = goalService,
        _insightService = insightService,
        _apiKey = apiKey {
    if (apiKey.isEmpty) {
      debugPrint('ERROR: AIService initialized with empty API key!');
    }
  }

  /// Call Groq API with a prompt
  Future<String> _callGroqAPI(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.7,
          'max_tokens': 1024,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]?['message']?['content'];
        if (content == null) {
          debugPrint('Groq API returned null content: ${response.body}');
          return 'I apologize, but I received an empty response. Please try again.';
        }
        return content as String;
      } else {
        debugPrint('Groq API error: ${response.statusCode} - ${response.body}');
        return 'I encountered an error (${response.statusCode}). Please try again.';
      }
    } catch (e) {
      debugPrint('Groq API call error: $e');
      return 'I\'m having trouble connecting. Please check your internet connection and try again.';
    }
  }

  /// Exclude outliers from a list of values
  /// Outliers are defined as values beyond 2 standard deviations from mean
  List<double> _excludeOutliers(List<double> values) {
    if (values.length < 3) return values;

    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values
            .map((v) => pow(v - mean, 2))
            .reduce((a, b) => a + b) /
        values.length;
    final stdDev = sqrt(variance);

    if (stdDev == 0) return values;

    return values.where((v) => (v - mean).abs() <= 2 * stdDev).toList();
  }

  /// Calculate confidence score based on data quality
  /// More data and less variance = higher confidence
  int _calculateConfidenceScore({
    required int dataPoints,
    required double variance,
    int minDataPoints = 10,
  }) {
    // Base confidence on data quantity
    double confidence = (dataPoints / minDataPoints).clamp(0.0, 1.0) * 50;

    // Adjust for variance (lower variance = higher confidence)
    if (variance > 0) {
      final varianceScore = (1 / (1 + variance / 100)) * 50;
      confidence += varianceScore;
    } else {
      confidence += 50;
    }

    return confidence.clamp(0, 100).round();
  }

  /// Get transactions for the last N months (default 12)
  Future<List<Transaction>> _getRecentTransactions(
    String userId, {
    int months = 12,
  }) async {
    final allTransactions =
        await _transactionService.fetchTransactions(userId);
    final cutoffDate = DateTime.now().subtract(Duration(days: months * 30));

    return allTransactions
        .where((t) => t.date.isAfter(cutoffDate))
        .toList();
  }

  /// Check if user has sufficient data for AI operations
  /// Returns true if at least minTransactions exist
  bool _hasSufficientData(List<Transaction> transactions, int minTransactions) {
    return transactions.length >= minTransactions;
  }


  /// Generate AI-powered financial summary
  /// Requirements: 2.1-2.8
  Future<AISummary> generateFinancialSummary({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final transactions = await _transactionService.fetchTransactions(userId);

      // Check for insufficient data
      if (!_hasSufficientData(transactions, 10)) {
        return AISummary(
          summaryText:
              'You need at least 10 transactions to generate meaningful insights. Keep tracking your spending!',
          totalSpending: 0.0,
          totalIncome: 0.0,
          topSpendingCategory: '',
          topSpendingAmount: 0.0,
          insights: [],
          anomalies: [],
          generatedAt: DateTime.now(),
          confidenceScore: 0,
          hasInsufficientData: true,
        );
      }

      // Filter transactions for current period
      final currentPeriodTxns = transactions
          .where((t) =>
              !t.date.isBefore(startDate) && !t.date.isAfter(endDate))
          .toList();

      // Calculate totals
      final totalSpending = currentPeriodTxns
          .where((t) => t.type == TransactionType.expense)
          .fold<double>(0.0, (sum, t) => sum + t.amount);

      final totalIncome = currentPeriodTxns
          .where((t) => t.type == TransactionType.income)
          .fold<double>(0.0, (sum, t) => sum + t.amount);

      // Calculate previous period for comparison
      final periodDuration = endDate.difference(startDate);
      final prevStartDate = startDate.subtract(periodDuration);
      final prevEndDate = startDate.subtract(const Duration(days: 1));

      final prevPeriodTxns = transactions
          .where((t) =>
              !t.date.isBefore(prevStartDate) && !t.date.isAfter(prevEndDate))
          .toList();

      final prevTotalSpending = prevPeriodTxns
          .where((t) => t.type == TransactionType.expense)
          .fold<double>(0.0, (sum, t) => sum + t.amount);

      // Get spending by category
      final categorySpending =
          await _insightService.calculateSpendingByCategory(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      // Find top spending category
      String topCategory = '';
      double topAmount = 0.0;
      categorySpending.forEach((category, amount) {
        if (amount > topAmount) {
          topAmount = amount;
          topCategory = category;
        }
      });

      // Detect anomalies
      final anomalies = await _insightService.detectAnomalies(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      // Filter low-confidence anomalies
      final highConfidenceAnomalies =
          anomalies.where((a) => a.confidenceScore >= 60).toList();

      // Build insights list
      final List<String> insights = [];

      // Compare to previous period
      if (prevTotalSpending > 0) {
        final percentChange =
            ((totalSpending - prevTotalSpending) / prevTotalSpending) * 100;
        if (percentChange.abs() > 10) {
          insights.add(
            percentChange > 0
                ? 'Your spending increased by ${percentChange.toStringAsFixed(1)}% compared to last period'
                : 'Your spending decreased by ${percentChange.abs().toStringAsFixed(1)}% compared to last period',
          );
        }
      }

      // Top category insight
      if (topCategory.isNotEmpty) {
        final percentage = (topAmount / totalSpending) * 100;
        insights.add(
          '$topCategory is your highest spending category at \$${topAmount.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}% of total)',
        );
      }

      // Anomaly insights
      if (highConfidenceAnomalies.isNotEmpty) {
        insights.add(
          'Detected ${highConfidenceAnomalies.length} unusual transaction${highConfidenceAnomalies.length > 1 ? 's' : ''} this period',
        );
      }

      // Calculate confidence score
      final confidenceScore = _calculateConfidenceScore(
        dataPoints: currentPeriodTxns.length,
        variance: _calculateVariance(
          currentPeriodTxns
              .where((t) => t.type == TransactionType.expense)
              .map((t) => t.amount)
              .toList(),
        ),
      );

      // Generate natural language summary using Groq AI
      final summaryPrompt = '''
You're a friendly personal finance manager. Create a SHORT, upbeat summary (1-2 sentences max) of their finances:

Data:
- Spending: \$${totalSpending.toStringAsFixed(2)}
- Income: \$${totalIncome.toStringAsFixed(2)}
- Top category: $topCategory (\$${topAmount.toStringAsFixed(2)})
- Last period: \$${prevTotalSpending.toStringAsFixed(2)}
- Unusual transactions: ${highConfidenceAnomalies.length}

Tone: Casual, encouraging, emoji-friendly 💰
Keep it super brief - like a quick text update!
''';

      String summaryText;
      try {
        summaryText = await _callGroqAPI(summaryPrompt);
      } catch (e) {
        // Fallback to factual summary if AI fails
        summaryText =
            'You spent \$${totalSpending.toStringAsFixed(2)} and earned \$${totalIncome.toStringAsFixed(2)} this period. Your top spending category was $topCategory.';
      }

      return AISummary(
        summaryText: summaryText,
        totalSpending: totalSpending,
        totalIncome: totalIncome,
        topSpendingCategory: topCategory,
        topSpendingAmount: topAmount,
        insights: insights,
        anomalies: highConfidenceAnomalies,
        generatedAt: DateTime.now(),
        confidenceScore: confidenceScore,
        hasInsufficientData: false,
      );
    } catch (e) {
      throw AIServiceException(
        'Failed to generate financial summary: ${e.toString()}',
      );
    }
  }

  /// Calculate variance of a list of values
  double _calculateVariance(List<double> values) {
    if (values.isEmpty) return 0.0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    return values.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) /
        values.length;
  }


  /// Predict end-of-month spending
  /// Requirements: 4.1-4.10
  Future<SpendingPrediction> predictMonthEndSpending({
    required String userId,
    required DateTime targetMonth,
  }) async {
    try {
      final transactions = await _transactionService.fetchTransactions(userId);

      // Check for minimum 30 days of data
      final oldestTransaction = transactions.isEmpty
          ? DateTime.now()
          : transactions
              .reduce((a, b) => a.date.isBefore(b.date) ? a : b)
              .date;
      final daysSinceOldest = DateTime.now().difference(oldestTransaction).inDays;

      if (daysSinceOldest < 30) {
        throw AIServiceException(
          'Predictions require at least 30 days of transaction history. You have $daysSinceOldest days.',
        );
      }

      // Get expense transactions from last 3 months (excluding outliers)
      final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));
      final recentExpenses = transactions
          .where((t) =>
              t.type == TransactionType.expense && t.date.isAfter(threeMonthsAgo))
          .map((t) => t.amount)
          .toList();

      final cleanedExpenses = _excludeOutliers(recentExpenses);

      if (cleanedExpenses.isEmpty) {
        throw AIServiceException('Insufficient data for prediction');
      }

      // Calculate daily average spending
      final totalSpending =
          cleanedExpenses.reduce((a, b) => a + b);
      final avgDailySpending = totalSpending / 90;

      // Calculate days in target month
      final daysInMonth =
          DateTime(targetMonth.year, targetMonth.month + 1, 0).day;

      // Predict month-end spending
      final predictedAmount = avgDailySpending * daysInMonth;

      // Calculate confidence score based on data consistency
      final variance = _calculateVariance(cleanedExpenses);
      final confidenceScore = _calculateConfidenceScore(
        dataPoints: cleanedExpenses.length,
        variance: variance,
        minDataPoints: 30,
      );

      // Calculate confidence interval (±15% for moderate confidence)
      final intervalPercent = confidenceScore < 60 ? 0.25 : 0.15;
      final lowerBound = predictedAmount * (1 - intervalPercent);
      final upperBound = predictedAmount * (1 + intervalPercent);

      // Build assumptions list
      final assumptions = <String>[
        'Based on your spending patterns from the last 90 days',
        'Excludes unusual one-time purchases',
        'Assumes similar spending behavior continues',
      ];

      if (confidenceScore < 60) {
        assumptions.add('Your spending varies significantly, increasing uncertainty');
      }

      // Generate explanation using Groq AI
      final explanationPrompt = '''
Generate a brief explanation (1-2 sentences) for this spending prediction:
- Predicted amount: \$${predictedAmount.toStringAsFixed(2)}
- Confidence: $confidenceScore%
- Based on: ${cleanedExpenses.length} transactions over 90 days
- Average daily spending: \$${avgDailySpending.toStringAsFixed(2)}

Quick, friendly explanation (1 sentence) - be casual and mention confidence!
''';

      String explanation;
      try {
        explanation = await _callGroqAPI(explanationPrompt);
      } catch (e) {
        explanation =
            'Based on your spending pattern, you\'ll likely spend around \$${predictedAmount.toStringAsFixed(2)} 📊';
      }

      return SpendingPrediction(
        predictedAmount: predictedAmount,
        targetDate: DateTime(targetMonth.year, targetMonth.month + 1, 0),
        confidenceScore: confidenceScore,
        explanation: explanation,
        lowerBound: lowerBound,
        upperBound: upperBound,
        assumptions: assumptions,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      if (e is AIServiceException) {
        rethrow;
      }
      throw AIServiceException(
        'Failed to predict spending: ${e.toString()}',
      );
    }
  }


  /// Detect spending patterns
  /// Requirements: 5.1-5.8
  Future<List<SpendingPattern>> detectSpendingPatterns({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final transactions = await _transactionService.fetchTransactions(userId);

      // Filter expense transactions in date range
      final expenses = transactions
          .where((t) =>
              t.type == TransactionType.expense &&
              !t.date.isBefore(startDate) &&
              !t.date.isAfter(endDate))
          .toList();

      final patterns = <SpendingPattern>[];

      // Calculate period duration for comparison
      final periodDuration = endDate.difference(startDate);
      final prevStartDate = startDate.subtract(periodDuration);
      final prevEndDate = startDate.subtract(const Duration(days: 1));

      // Get spending by category for current and previous periods
      final currentCategorySpending =
          await _insightService.calculateSpendingByCategory(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      final prevCategorySpending =
          await _insightService.calculateSpendingByCategory(
        userId: userId,
        startDate: prevStartDate,
        endDate: prevEndDate,
      );

      // Detect increasing/decreasing trends (20% threshold)
      for (final entry in currentCategorySpending.entries) {
        final category = entry.key;
        final currentAmount = entry.value;
        final prevAmount = prevCategorySpending[category] ?? 0.0;

        if (prevAmount > 0) {
          final percentChange = ((currentAmount - prevAmount) / prevAmount) * 100;

          if (percentChange.abs() > 20) {
            final confidenceScore = _calculateConfidenceScore(
              dataPoints: expenses.where((t) => t.category == category).length,
              variance: 10.0, // Lower variance for trend detection
              minDataPoints: 3,
            );

            if (expenses.where((t) => t.category == category).length >= 3) {
              patterns.add(SpendingPattern(
                patternType: percentChange > 0 ? 'increasing' : 'decreasing',
                categoryId: category,
                description: percentChange > 0
                    ? 'Your $category spending increased by ${percentChange.toStringAsFixed(1)}% compared to the previous period'
                    : 'Your $category spending decreased by ${percentChange.abs().toStringAsFixed(1)}% compared to the previous period',
                magnitude: percentChange.abs(),
                confidenceScore: confidenceScore,
                detectedAt: DateTime.now(),
              ));
            }
          }
        }
      }

      // Detect weekend vs weekday pattern (30% threshold)
      final weekendExpenses = expenses
          .where((t) => t.date.weekday == DateTime.saturday ||
              t.date.weekday == DateTime.sunday)
          .toList();

      final weekdayExpenses = expenses
          .where((t) =>
              t.date.weekday != DateTime.saturday &&
              t.date.weekday != DateTime.sunday)
          .toList();

      if (weekendExpenses.length >= 3 && weekdayExpenses.length >= 3) {
        final weekendTotal =
            weekendExpenses.fold<double>(0.0, (sum, t) => sum + t.amount);
        final weekdayTotal =
            weekdayExpenses.fold<double>(0.0, (sum, t) => sum + t.amount);

        // Normalize by number of days
        final weekendDays = weekendExpenses.length;
        final weekdayDays = weekdayExpenses.length;

        final avgWeekendSpending = weekendTotal / weekendDays;
        final avgWeekdaySpending = weekdayTotal / weekdayDays;

        final totalAvg = (weekendTotal + weekdayTotal) /
            (weekendDays + weekdayDays);

        if (totalAvg > 0) {
          final weekendDiff =
              ((avgWeekendSpending - totalAvg) / totalAvg).abs() * 100;
          final weekdayDiff =
              ((avgWeekdaySpending - totalAvg) / totalAvg).abs() * 100;

          if (weekendDiff > 30 || weekdayDiff > 30) {
            final isWeekendHeavy = avgWeekendSpending > avgWeekdaySpending;
            final difference = (avgWeekendSpending - avgWeekdaySpending).abs();
            final percentDiff =
                (difference / (isWeekendHeavy ? avgWeekdaySpending : avgWeekendSpending)) *
                    100;

            patterns.add(SpendingPattern(
              patternType: isWeekendHeavy ? 'weekend_heavy' : 'weekday_heavy',
              categoryId: 'all',
              description: isWeekendHeavy
                  ? 'You spend ${percentDiff.toStringAsFixed(1)}% more on weekends (\$${avgWeekendSpending.toStringAsFixed(2)}/day) compared to weekdays (\$${avgWeekdaySpending.toStringAsFixed(2)}/day)'
                  : 'You spend ${percentDiff.toStringAsFixed(1)}% more on weekdays (\$${avgWeekdaySpending.toStringAsFixed(2)}/day) compared to weekends (\$${avgWeekendSpending.toStringAsFixed(2)}/day)',
              magnitude: percentDiff,
              confidenceScore: _calculateConfidenceScore(
                dataPoints: expenses.length,
                variance: 15.0,
                minDataPoints: 10,
              ),
              detectedAt: DateTime.now(),
            ));
          }
        }
      }

      // Check for high variability and communicate uncertainty
      final amounts = expenses.map((t) => t.amount).toList();
      if (amounts.length >= 10) {
        final variance = _calculateVariance(amounts);
        final mean = amounts.reduce((a, b) => a + b) / amounts.length;
        final coefficientOfVariation = sqrt(variance) / mean;

        if (coefficientOfVariation > 0.5) {
          patterns.add(SpendingPattern(
            patternType: 'highly_variable',
            categoryId: 'all',
            description:
                'Your spending varies significantly from day to day, making it harder to predict patterns',
            magnitude: coefficientOfVariation * 100,
            confidenceScore: 50,
            detectedAt: DateTime.now(),
          ));
        }
      }

      return patterns;
    } catch (e) {
      throw AIServiceException(
        'Failed to detect spending patterns: ${e.toString()}',
      );
    }
  }

  /// Detect recurring expenses
  /// Requirements: 4.7-4.8
  Future<List<RecurringExpense>> detectRecurringExpenses({
    required String userId,
  }) async {
    try {
      final transactions = await _transactionService.fetchTransactions(userId);

      // Group transactions by category and similar amounts
      final Map<String, List<Transaction>> categoryGroups = {};

      for (final transaction in transactions) {
        if (transaction.type == TransactionType.expense) {
          categoryGroups.putIfAbsent(transaction.category, () => []);
          categoryGroups[transaction.category]!.add(transaction);
        }
      }

      final recurringExpenses = <RecurringExpense>[];

      // Analyze each category for recurring patterns
      for (final entry in categoryGroups.entries) {
        final category = entry.key;
        final categoryTxns = entry.value;

        // Need at least 2 transactions to detect recurrence
        if (categoryTxns.length < 2) continue;

        // Sort by date
        categoryTxns.sort((a, b) => a.date.compareTo(b.date));

        // Group by similar amounts (within 10% tolerance)
        final Map<double, List<Transaction>> amountGroups = {};

        for (final txn in categoryTxns) {
          bool foundGroup = false;

          for (final amount in amountGroups.keys) {
            final tolerance = amount * 0.1;
            if ((txn.amount - amount).abs() <= tolerance) {
              amountGroups[amount]!.add(txn);
              foundGroup = true;
              break;
            }
          }

          if (!foundGroup) {
            amountGroups[txn.amount] = [txn];
          }
        }

        // Check each amount group for recurring pattern
        for (final amountEntry in amountGroups.entries) {
          final groupTxns = amountEntry.value;

          // Need at least 2 occurrences
          if (groupTxns.length < 2) continue;

          // Calculate average frequency
          final intervals = <int>[];
          for (int i = 1; i < groupTxns.length; i++) {
            final daysBetween =
                groupTxns[i].date.difference(groupTxns[i - 1].date).inDays;
            intervals.add(daysBetween);
          }

          final avgFrequency =
              intervals.reduce((a, b) => a + b) / intervals.length;

          // Check if intervals are consistent (within 20% variance)
          final intervalVariance = _calculateVariance(
            intervals.map((i) => i.toDouble()).toList(),
          );
          final coefficientOfVariation = sqrt(intervalVariance) / avgFrequency;

          if (coefficientOfVariation < 0.3) {
            // This is a recurring expense
            final avgAmount = groupTxns
                    .map((t) => t.amount)
                    .reduce((a, b) => a + b) /
                groupTxns.length;

            final lastOccurrence = groupTxns.last.date;
            final nextExpectedDate = lastOccurrence
                .add(Duration(days: avgFrequency.round()));

            final confidenceScore = _calculateConfidenceScore(
              dataPoints: groupTxns.length,
              variance: intervalVariance,
              minDataPoints: 2,
            );

            recurringExpenses.add(RecurringExpense(
              id: '${category}_${avgAmount.toStringAsFixed(0)}',
              categoryId: category,
              description: groupTxns.first.notes ?? category,
              averageAmount: avgAmount,
              frequencyDays: avgFrequency.round(),
              lastOccurrence: lastOccurrence,
              nextExpectedDate: nextExpectedDate,
              confidenceScore: confidenceScore,
              transactionIds: groupTxns.map((t) => t.id).toList(),
            ));
          }
        }
      }

      return recurringExpenses;
    } catch (e) {
      throw AIServiceException(
        'Failed to detect recurring expenses: ${e.toString()}',
      );
    }
  }


  /// Process Copilot query
  /// Requirements: 6.1-6.10
  Future<AIResponse> processCopilotQuery({
    required String userId,
    required String query,
    required List<ChatMessage> conversationHistory,
  }) async {
    try {
      // Fetch user data
      final transactions = await _getRecentTransactions(userId);
      final goals = await _goalService.getUserGoals(userId: userId);
      final categoryBudgets = await _budgetService.fetchCategoryBudgets(userId);

      // Build context for AI
      final contextParts = <String>[];

      // Transaction context
      if (transactions.isNotEmpty) {
        final totalSpending = transactions
            .where((t) => t.type == TransactionType.expense)
            .fold<double>(0.0, (sum, t) => sum + t.amount);
        final totalIncome = transactions
            .where((t) => t.type == TransactionType.income)
            .fold<double>(0.0, (sum, t) => sum + t.amount);

        // Get spending by category using InsightService
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        final categorySpending = await _insightService.calculateSpendingByCategory(
          userId: userId,
          startDate: startOfMonth,
          endDate: now,
        );

        // Sort categories by spending (highest first)
        final sortedCategories = categorySpending.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        // Build category breakdown string
        final categoryBreakdown = sortedCategories.isNotEmpty
            ? sortedCategories
                .map((e) => '  - ${e.key}: \$${e.value.toStringAsFixed(2)}')
                .join('\n')
            : '  (No category data available)';

        contextParts.add('''
Transaction Data:
- Total transactions: ${transactions.length}
- Total spending: \$${totalSpending.toStringAsFixed(2)}
- Total income: \$${totalIncome.toStringAsFixed(2)}
- Date range: ${transactions.last.date.toString().split(' ')[0]} to ${transactions.first.date.toString().split(' ')[0]}

Spending by Category (Current Month):
$categoryBreakdown
''');
      }

      // Budget context
      if (categoryBudgets.isNotEmpty) {
        contextParts.add('''
Budget Data:
- Active budgets: ${categoryBudgets.length}
- Categories: ${categoryBudgets.keys.join(', ')}
''');
      }

      // Goal context
      if (goals.isNotEmpty) {
        contextParts.add('''
Goal Data:
- Active goals: ${goals.length}
- Total target amount: \$${goals.fold<double>(0.0, (sum, g) => sum + g.targetAmount).toStringAsFixed(2)}
''');
      }

      // Build conversation history
      final conversationContext = conversationHistory
          .map((msg) => '${msg.role.name}: ${msg.content}')
          .join('\n');

      // Build prompt
      final prompt = '''
You are Perfin's AI personal finance manager - friendly, supportive, and conversational. Think of yourself as the user's financial buddy who helps them make smart money decisions.

User's Financial Data:
${contextParts.join('\n')}

Recent Conversation:
$conversationContext

User's Question: $query

Your Personality:
- Warm and encouraging, never judgmental
- Use casual, friendly language (like texting a friend)
- Keep responses SHORT and to the point (2-4 sentences max)
- Use emojis occasionally to be more personable 💰 📊 🎯
- Celebrate wins and progress
- Be empathetic about financial challenges

Response Guidelines:
1. Answer directly - no fluff or unnecessary details
2. Use EXACT numbers from their data
3. If you don't have the info, just say "I don't have that data yet"
4. Show quick calculations when relevant (e.g., "Food: \$250 + Shopping: \$180 = \$430 total")
5. Give actionable advice when appropriate
6. Never guess or make up numbers
7. For predictions, say "based on your spending pattern" or "estimated"
8. Keep it conversational - avoid formal financial jargon

Examples of your tone:
- Instead of: "Your total expenditure for the Food category amounts to \$250.00"
- Say: "You spent \$250 on Food this month 🍕"

- Instead of: "I recommend implementing a budget reduction strategy"
- Say: "Try cutting back a bit on dining out - could save you \$50-100!"

- Instead of: "Your financial trajectory indicates positive momentum"
- Say: "Nice! You're doing great this month 🎉"

Now answer their question in a friendly, helpful way:
''';

      // Generate response
      String responseText;
      try {
        responseText = await _callGroqAPI(prompt);
      } catch (e) {
        // If AI generation fails, provide a helpful fallback response
        debugPrint('Groq API error: $e');
        responseText = 'I\'m having trouble connecting to my AI service right now. Please check your internet connection and try again. If the problem persists, the API key might be invalid.';
      }

      // Extract data references and calculations
      final dataReferences = <DataReference>[];
      final calculations = <String>[];

      // Check if response requires clarification
      final requiresClarification = responseText.toLowerCase().contains('could you clarify') ||
          responseText.toLowerCase().contains('which') ||
          responseText.toLowerCase().contains('do you mean');

      // Extract clarifying questions if needed
      List<String>? clarifyingQuestions;
      if (requiresClarification) {
        clarifyingQuestions = _extractQuestions(responseText);
      }

      // Calculate confidence score based on data availability
      int confidenceScore = 85;
      if (transactions.isEmpty) {
        confidenceScore = 30;
      } else if (transactions.length < 5) {
        confidenceScore = 60;
      } else if (transactions.length < 10) {
        confidenceScore = 75;
      }

      if (requiresClarification) {
        confidenceScore = min(confidenceScore, 50);
      }

      return AIResponse(
        responseText: responseText,
        confidenceScore: confidenceScore,
        dataReferences: dataReferences,
        calculations: calculations,
        requiresClarification: requiresClarification,
        clarifyingQuestions: clarifyingQuestions,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      throw AIServiceException(
        'Failed to process copilot query: ${e.toString()}',
      );
    }
  }

  /// Extract questions from text
  List<String> _extractQuestions(String text) {
    final questions = <String>[];
    final sentences = text.split(RegExp(r'[.!?]'));

    for (final sentence in sentences) {
      if (sentence.trim().contains('?') ||
          sentence.toLowerCase().contains('could you') ||
          sentence.toLowerCase().contains('which')) {
        questions.add(sentence.trim());
      }
    }

    return questions;
  }

  /// Get suggested questions for first-time users
  List<String> getSuggestedQuestions() {
    return [
      'How much did I spend this month?',
      'What is my top spending category?',
      'Am I on track with my budget?',
      'Can I afford a \$500 purchase?',
      'How much should I save each month for my goal?',
      'What are my recurring expenses?',
      'Show me my spending trends',
      'How does this month compare to last month?',
    ];
  }


  /// Analyze goal feasibility
  /// Requirements: 10.1-10.10
  Future<GoalFeasibilityAnalysis> analyzeGoalFeasibility({
    required String userId,
    required Goal goal,
  }) async {
    try {
      // Get recent transactions (last 3 months)
      final transactions = await _getRecentTransactions(userId, months: 3);

      if (transactions.length < 10) {
        throw AIServiceException(
          'Need at least 10 transactions to analyze goal feasibility',
        );
      }

      // Calculate average monthly income and spending
      final monthlyIncome = <double>[];
      final monthlySpending = <double>[];

      // Group by month
      final now = DateTime.now();
      for (int i = 0; i < 3; i++) {
        final monthStart = DateTime(now.year, now.month - i, 1);
        final monthEnd = DateTime(now.year, now.month - i + 1, 0);

        final monthTxns = transactions
            .where((t) =>
                !t.date.isBefore(monthStart) && !t.date.isAfter(monthEnd))
            .toList();

        final income = monthTxns
            .where((t) => t.type == TransactionType.income)
            .fold<double>(0.0, (sum, t) => sum + t.amount);

        final spending = monthTxns
            .where((t) => t.type == TransactionType.expense)
            .fold<double>(0.0, (sum, t) => sum + t.amount);

        if (income > 0) monthlyIncome.add(income);
        if (spending > 0) monthlySpending.add(spending);
      }

      // Calculate averages
      final avgMonthlyIncome = monthlyIncome.isEmpty
          ? 0.0
          : monthlyIncome.reduce((a, b) => a + b) / monthlyIncome.length;

      final avgMonthlySpending = monthlySpending.isEmpty
          ? 0.0
          : monthlySpending.reduce((a, b) => a + b) / monthlySpending.length;

      final averageMonthlySurplus = avgMonthlyIncome - avgMonthlySpending;

      // Calculate required monthly savings
      final requiredMonthlySavings =
          _goalService.calculateRequiredMonthlySavings(
        targetAmount: goal.targetAmount,
        currentAmount: goal.currentAmount,
        targetDate: goal.targetDate,
      );

      // Determine feasibility
      final isAchievable = requiredMonthlySavings <= averageMonthlySurplus;

      // Determine feasibility level
      FeasibilityLevel feasibilityLevel;
      if (requiredMonthlySavings <= averageMonthlySurplus * 0.5) {
        feasibilityLevel = FeasibilityLevel.easy;
      } else if (requiredMonthlySavings <= averageMonthlySurplus) {
        feasibilityLevel = FeasibilityLevel.moderate;
      } else if (requiredMonthlySavings <= averageMonthlySurplus * 1.5) {
        feasibilityLevel = FeasibilityLevel.challenging;
      } else {
        feasibilityLevel = FeasibilityLevel.unrealistic;
      }

      // Generate spending reduction suggestions if challenging
      final suggestedReductions = <SpendingReduction>[];
      if (feasibilityLevel == FeasibilityLevel.challenging ||
          feasibilityLevel == FeasibilityLevel.unrealistic) {
        suggestedReductions.addAll(
          await suggestSpendingReductions(
            userId: userId,
            targetSavings: requiredMonthlySavings - averageMonthlySurplus,
          ),
        );
      }

      // Calculate confidence score
      final confidenceScore = _calculateConfidenceScore(
        dataPoints: transactions.length,
        variance: _calculateVariance(monthlySpending),
        minDataPoints: 30,
      );

      // Generate explanation using Groq AI
      final explanationPrompt = '''
Friendly, encouraging message (1-2 sentences) about their goal:
- Goal: ${goal.name}
- Target: \$${goal.targetAmount.toStringAsFixed(2)}
- Current: \$${goal.currentAmount.toStringAsFixed(2)}
- Need to save monthly: \$${requiredMonthlySavings.toStringAsFixed(2)}
- Monthly surplus: \$${averageMonthlySurplus.toStringAsFixed(2)}
- Feasibility: ${feasibilityLevel.name}

Be supportive and actionable! Use emojis 🎯
''';

      String explanation;
      try {
        explanation = await _callGroqAPI(explanationPrompt);
      } catch (e) {
        explanation =
            'You need to save \$${requiredMonthlySavings.toStringAsFixed(2)}/month. Your current surplus is \$${averageMonthlySurplus.toStringAsFixed(2)} 🎯';
      }

      return GoalFeasibilityAnalysis(
        goalId: goal.id,
        isAchievable: isAchievable,
        requiredMonthlySavings: requiredMonthlySavings,
        averageMonthlySurplus: averageMonthlySurplus,
        feasibilityLevel: feasibilityLevel,
        suggestedReductions: suggestedReductions,
        explanation: explanation,
        confidenceScore: confidenceScore,
        analyzedAt: DateTime.now(),
      );
    } catch (e) {
      if (e is AIServiceException) {
        rethrow;
      }
      throw AIServiceException(
        'Failed to analyze goal feasibility: ${e.toString()}',
      );
    }
  }

  /// Suggest spending reductions
  /// Requirements: 10.5
  Future<List<SpendingReduction>> suggestSpendingReductions({
    required String userId,
    required double targetSavings,
  }) async {
    try {
      // Get spending by category for last 3 months
      final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));
      final categorySpending =
          await _insightService.calculateSpendingByCategory(
        userId: userId,
        startDate: threeMonthsAgo,
        endDate: DateTime.now(),
      );

      // Calculate monthly average for each category
      final monthlyCategorySpending = <String, double>{};
      categorySpending.forEach((category, total) {
        monthlyCategorySpending[category] = total / 3;
      });

      // Sort categories by spending (highest first)
      final sortedCategories = monthlyCategorySpending.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final suggestions = <SpendingReduction>[];
      double totalReduction = 0.0;

      // Suggest reductions for non-essential high-spending categories
      for (final entry in sortedCategories) {
        if (totalReduction >= targetSavings) break;

        final category = entry.key;
        final currentSpending = entry.value;

        // Skip essential categories
        final isEssential = _essentialCategories
            .any((essential) => category.toLowerCase().contains(essential));

        if (isEssential) continue;

        // Suggest 20-30% reduction for non-essential categories
        final reductionPercent = 0.25;
        final suggestedReduction = currentSpending * reductionPercent;
        final newSpending = currentSpending - suggestedReduction;

        suggestions.add(SpendingReduction(
          categoryId: category,
          currentMonthlySpending: currentSpending,
          suggestedReduction: suggestedReduction,
          newMonthlySpending: newSpending,
          rationale:
              '$category is a high-spending non-essential category. Reducing by ${(reductionPercent * 100).toStringAsFixed(0)}% could save \$${suggestedReduction.toStringAsFixed(2)}/month.',
          isEssential: false,
        ));

        totalReduction += suggestedReduction;
      }

      return suggestions;
    } catch (e) {
      throw AIServiceException(
        'Failed to suggest spending reductions: ${e.toString()}',
      );
    }
  }

  /// Prioritize multiple goals
  /// Requirements: 10.9-10.10
  Future<GoalPrioritization> prioritizeGoals({
    required String userId,
    required List<Goal> goals,
  }) async {
    try {
      if (goals.isEmpty) {
        throw AIServiceException('No goals to prioritize');
      }

      // Get recent transactions
      final transactions = await _getRecentTransactions(userId, months: 3);

      // Calculate average monthly surplus
      final monthlyIncome = <double>[];
      final monthlySpending = <double>[];

      final now = DateTime.now();
      for (int i = 0; i < 3; i++) {
        final monthStart = DateTime(now.year, now.month - i, 1);
        final monthEnd = DateTime(now.year, now.month - i + 1, 0);

        final monthTxns = transactions
            .where((t) =>
                !t.date.isBefore(monthStart) && !t.date.isAfter(monthEnd))
            .toList();

        final income = monthTxns
            .where((t) => t.type == TransactionType.income)
            .fold<double>(0.0, (sum, t) => sum + t.amount);

        final spending = monthTxns
            .where((t) => t.type == TransactionType.expense)
            .fold<double>(0.0, (sum, t) => sum + t.amount);

        if (income > 0) monthlyIncome.add(income);
        if (spending > 0) monthlySpending.add(spending);
      }

      final avgMonthlyIncome = monthlyIncome.isEmpty
          ? 0.0
          : monthlyIncome.reduce((a, b) => a + b) / monthlyIncome.length;

      final avgMonthlySpending = monthlySpending.isEmpty
          ? 0.0
          : monthlySpending.reduce((a, b) => a + b) / monthlySpending.length;

      final availableMonthlySurplus = avgMonthlyIncome - avgMonthlySpending;

      // Calculate required savings for each goal
      final goalRequirements = <Goal, double>{};
      double totalRequiredSavings = 0.0;

      for (final goal in goals) {
        final required = _goalService.calculateRequiredMonthlySavings(
          targetAmount: goal.targetAmount,
          currentAmount: goal.currentAmount,
          targetDate: goal.targetDate,
        );
        goalRequirements[goal] = required;
        totalRequiredSavings += required;
      }

      // Check for conflicts
      final hasConflicts = totalRequiredSavings > availableMonthlySurplus;

      // Prioritize goals by urgency (earliest deadline first)
      final sortedGoals = goals.toList()
        ..sort((a, b) => a.targetDate.compareTo(b.targetDate));

      final prioritizedGoals = <PrioritizedGoal>[];
      for (int i = 0; i < sortedGoals.length; i++) {
        final goal = sortedGoals[i];
        final required = goalRequirements[goal]!;

        String rationale;
        if (i == 0) {
          rationale =
              'Highest priority due to earliest deadline (${goal.targetDate.toString().split(' ')[0]}). Requires \$${required.toStringAsFixed(2)}/month.';
        } else {
          rationale =
              'Priority ${i + 1}. Deadline: ${goal.targetDate.toString().split(' ')[0]}. Requires \$${required.toStringAsFixed(2)}/month.';
        }

        prioritizedGoals.add(PrioritizedGoal(
          goalId: goal.id,
          priority: i + 1,
          rationale: rationale,
        ));
      }

      // Generate conflict explanation if needed
      String? conflictExplanation;
      if (hasConflicts) {
        final shortfall = totalRequiredSavings - availableMonthlySurplus;
        conflictExplanation =
            'Your goals require \$${totalRequiredSavings.toStringAsFixed(2)}/month total, but you have \$${availableMonthlySurplus.toStringAsFixed(2)}/month available. You need to find \$${shortfall.toStringAsFixed(2)}/month more or adjust your goals.';
      }

      return GoalPrioritization(
        prioritizedGoals: prioritizedGoals,
        hasConflicts: hasConflicts,
        conflictExplanation: conflictExplanation,
        totalRequiredMonthlySavings: totalRequiredSavings,
        availableMonthlySurplus: availableMonthlySurplus,
        analyzedAt: DateTime.now(),
      );
    } catch (e) {
      if (e is AIServiceException) {
        rethrow;
      }
      throw AIServiceException(
        'Failed to prioritize goals: ${e.toString()}',
      );
    }
  }
}

/// Custom exception for AI service operations
class AIServiceException implements Exception {
  final String message;

  AIServiceException(this.message);

  @override
  String toString() => 'AIServiceException: $message';
}




