import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/ai_provider.dart';
import '../../providers/insight_provider.dart' as insight;
import '../../services/insight_service.dart';
import '../../theme/app_colors.dart';
import 'widgets/time_period_selector.dart';
import 'widgets/spending_breakdown_chart.dart';
import 'widgets/spending_trend_chart.dart';
import 'widgets/prediction_card.dart';
import 'widgets/recurring_expenses_list.dart';
import 'widgets/spending_patterns_list.dart';

/// Insights Tab - Spending Analysis and Predictions
/// Requirements: 3.1-3.9, 4.1-4.10, 5.1-5.8
class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  TimePeriod _selectedPeriod = TimePeriod.currentMonth;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    final insightProvider = context.read<insight.InsightProvider>();
    final aiProvider = context.read<AIProvider>();

    final dateRange = _getDateRange(_selectedPeriod);
    final granularity = _getGranularity(_selectedPeriod);

    await Future.wait([
      insightProvider.loadAllInsights(
        startDate: dateRange.start,
        endDate: dateRange.end,
        granularity: granularity,
      ),
      aiProvider.generatePrediction(targetMonth: DateTime.now()),
      aiProvider.detectPatterns(
        startDate: dateRange.start,
        endDate: dateRange.end,
      ),
      aiProvider.detectRecurringExpenses(),
    ]);
  }

  Future<void> _onRefresh() async {
    await _loadData();
  }

  void _onPeriodChanged(TimePeriod? period) {
    if (period != null && period != _selectedPeriod) {
      setState(() {
        _selectedPeriod = period;
      });
      _loadData();
    }
  }

  DateTimeRange _getDateRange(TimePeriod period) {
    final now = DateTime.now();
    
    switch (period) {
      case TimePeriod.currentMonth:
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        );
      case TimePeriod.lastMonth:
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        return DateTimeRange(
          start: lastMonth,
          end: DateTime(lastMonth.year, lastMonth.month + 1, 0, 23, 59, 59),
        );
      case TimePeriod.last3Months:
        return DateTimeRange(
          start: DateTime(now.year, now.month - 3, 1),
          end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        );
      case TimePeriod.last6Months:
        return DateTimeRange(
          start: DateTime(now.year, now.month - 6, 1),
          end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        );
      case TimePeriod.lastYear:
        return DateTimeRange(
          start: DateTime(now.year - 1, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        );
    }
  }

  TrendGranularity _getGranularity(TimePeriod period) {
    switch (period) {
      case TimePeriod.currentMonth:
      case TimePeriod.lastMonth:
        return TrendGranularity.daily;
      case TimePeriod.last3Months:
      case TimePeriod.last6Months:
        return TrendGranularity.weekly;
      case TimePeriod.lastYear:
        return TrendGranularity.monthly;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamLight,
      body: Consumer3<insight.InsightProvider, AIProvider, TransactionProvider>(
        builder: (context, insightProvider, aiProvider, transactionProvider, _) {
          if (insightProvider.state == insight.LoadingState.loading &&
              insightProvider.spendingByCategory.isEmpty) {
            return _buildLoadingState();
          }

          if (insightProvider.state == insight.LoadingState.error &&
              insightProvider.spendingByCategory.isEmpty) {
            return _buildErrorState(insightProvider.errorMessage);
          }

          // Check if there's no data
          final hasNoData = transactionProvider.transactions.isEmpty;

          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppColors.primary,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // Header that scrolls away
                SliverToBoxAdapter(
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Insights',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildTimePeriodSelector(),
                        ],
                      ),
                    ),
                  ),
                ),

                // Content
                if (hasNoData)
                  SliverFillRemaining(
                    child: _buildEmptyState(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: 100),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Spending breakdown chart - subtask 6.3
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SpendingBreakdownChart(
                            spendingByCategory: insightProvider.spendingByCategory,
                          ),
                        ),
                        
                        const SizedBox(height: 32),

                        // Spending trend chart - subtask 6.4
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SpendingTrendChart(
                            trendData: insightProvider.spendingTrend,
                            periodLabel: 'Spending Over Time',
                          ),
                        ),
                        
                        const SizedBox(height: 32),

                        // Prediction card - subtask 6.5
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: PredictionCard(
                            prediction: aiProvider.currentPrediction,
                            hasInsufficientData: aiProvider.currentPrediction == null,
                            isLoading: aiProvider.state == LoadingState.loading,
                          ),
                        ),
                        
                        const SizedBox(height: 32),

                        // Recurring expenses list - subtask 6.6
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: RecurringExpensesList(
                            recurringExpenses: aiProvider.recurringExpenses,
                            isLoading: aiProvider.state == LoadingState.loading,
                          ),
                        ),
                        
                        const SizedBox(height: 32),

                        // Spending patterns list - subtask 6.7
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SpendingPatternsList(
                            patterns: aiProvider.patterns,
                            isLoading: aiProvider.state == LoadingState.loading,
                          ),
                        ),
                      ]),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimePeriodSelector() {
    return TimePeriodSelector(
      selectedPeriod: _selectedPeriod,
      onChanged: _onPeriodChanged,
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFF1A1A1A),
      ),
    );
  }

  Widget _buildErrorState(String? errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '😕',
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _onRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A1A),
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '📊',
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            const Text(
              'No insights yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add transactions to see spending patterns and predictions',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
