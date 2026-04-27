import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/budget_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/ai_provider.dart';
import '../../providers/currency_provider.dart';
import '../../theme/app_colors.dart';
import 'widgets/financial_summary_card.dart';
import 'widgets/budget_status_list.dart';
import 'widgets/ai_summary_card.dart';
import 'widgets/recent_transactions_list.dart';
import 'widgets/quick_action_buttons.dart';
import 'widgets/spending_snapshot_card.dart';

/// Home Tab - Visual dashboard optimized for quick scanning.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    final transactionProvider = context.read<TransactionProvider>();
    final budgetProvider = context.read<BudgetProvider>();
    final aiProvider = context.read<AIProvider>();

    await Future.wait([
      transactionProvider.loadTransactions(),
      budgetProvider.loadBudgets(),
    ]);

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    await aiProvider.generateSummary(
      startDate: startOfMonth,
      endDate: endOfMonth,
    );
  }

  Future<void> _onRefresh() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EC),
      body:
          Consumer4<
            TransactionProvider,
            BudgetProvider,
            AIProvider,
            CurrencyProvider
          >(
            builder:
                (
                  context,
                  transactionProvider,
                  budgetProvider,
                  aiProvider,
                  currencyProvider,
                  _,
                ) {
                  if (transactionProvider.state == LoadingState.loading &&
                      transactionProvider.transactions.isEmpty) {
                    return _buildLoadingState();
                  }

                  if (transactionProvider.state == LoadingState.error &&
                      transactionProvider.transactions.isEmpty) {
                    return _buildErrorState(transactionProvider.errorMessage);
                  }

                  final summary = transactionProvider.currentMonthSummary;
                  final netFlow = summary.totalIncome - summary.totalExpense;
                  final savingsRate = summary.totalIncome > 0
                      ? ((netFlow / summary.totalIncome) * 100).clamp(
                          -100.0,
                          100.0,
                        )
                      : 0.0;
                  final budgetLeft = budgetProvider.remainingBudget;
                  final hasBudget = budgetProvider.monthlyBudget != null;

                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFFDFBF5), Color(0xFFF4F0E6)],
                      ),
                    ),
                    child: RefreshIndicator(
                      onRefresh: _onRefresh,
                      color: AppColors.primary,
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        slivers: [
                          SliverToBoxAdapter(
                            child: SafeArea(
                              bottom: false,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  16,
                                  20,
                                  8,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              DateFormat(
                                                'EEE, MMM d',
                                              ).format(now),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF7B808A),
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              _getGreetingByHour(now.hour),
                                              style: const TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF1A2333),
                                                letterSpacing: -0.8,
                                                height: 1.05,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        _buildIconActionButton(
                                          icon:
                                              Icons.notifications_none_rounded,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                            sliver: SliverList(
                              delegate: SliverChildListDelegate([
                                const FinancialSummaryCard(),
                                const SizedBox(height: 16),
                                _buildKpiGrid(
                                  currencyProvider: currencyProvider,
                                  netFlow: netFlow,
                                  income: summary.totalIncome,
                                  expense: summary.totalExpense,
                                  savingsRate: savingsRate,
                                  budgetLeft: budgetLeft,
                                  hasBudget: hasBudget,
                                ),
                                const SizedBox(height: 18),
                                const QuickActionButtons(),
                                const SizedBox(height: 24),
                                _buildSectionLabel(
                                  icon: Icons.stacked_bar_chart_rounded,
                                  title: 'Spending Snapshot',
                                ),
                                const SizedBox(height: 10),
                                const SpendingSnapshotCard(),
                                const SizedBox(height: 24),
                                _buildSectionLabel(
                                  icon: Icons.auto_awesome_rounded,
                                  title: 'AI Brief',
                                ),
                                const SizedBox(height: 10),
                                const AISummaryCard(),
                                const SizedBox(height: 24),
                                _buildSectionLabel(
                                  icon: Icons.schedule_rounded,
                                  title: 'Recent Activity',
                                ),
                                const SizedBox(height: 10),
                                const RecentTransactionsList(),
                                const SizedBox(height: 24),
                                _buildSectionLabel(
                                  icon: Icons.pie_chart_rounded,
                                  title: 'Budget Health',
                                ),
                                const SizedBox(height: 10),
                                const BudgetStatusList(),
                              ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
          ),
    );
  }

  String _getGreetingByHour(int hour) {
    if (hour < 12) {
      return 'Good morning';
    }
    if (hour < 17) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }

  Widget _buildIconActionButton({required IconData icon}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9E5DA), width: 1),
      ),
      child: IconButton(
        onPressed: () {},
        icon: Icon(icon),
        color: const Color(0xFF1A2333),
        iconSize: 22,
      ),
    );
  }

  Widget _buildKpiGrid({
    required CurrencyProvider currencyProvider,
    required double netFlow,
    required double income,
    required double expense,
    required double savingsRate,
    required double budgetLeft,
    required bool hasBudget,
  }) {
    final items = [
      _KpiItem(
        label: 'Net Flow',
        value:
            '${netFlow >= 0 ? '+' : '-'}${currencyProvider.formatWhole(netFlow.abs())}',
        icon: netFlow >= 0
            ? Icons.trending_up_rounded
            : Icons.trending_down_rounded,
        color: netFlow >= 0 ? const Color(0xFF2EA86F) : const Color(0xFFD25A50),
      ),
      _KpiItem(
        label: 'Income',
        value: currencyProvider.formatWhole(income),
        icon: Icons.south_west_rounded,
        color: const Color(0xFF2EA86F),
      ),
      _KpiItem(
        label: 'Spent',
        value: currencyProvider.formatWhole(expense),
        icon: Icons.north_east_rounded,
        color: const Color(0xFFD25A50),
      ),
      _KpiItem(
        label: hasBudget ? 'Budget Left' : 'Savings Rate',
        value: hasBudget
            ? '${budgetLeft >= 0 ? '+' : '-'}${currencyProvider.formatWhole(budgetLeft.abs())}'
            : '${savingsRate.toStringAsFixed(0)}%',
        icon: hasBudget
            ? Icons.account_balance_wallet_rounded
            : Icons.savings_rounded,
        color: hasBudget
            ? (budgetLeft >= 0
                  ? const Color(0xFF2EA86F)
                  : const Color(0xFFD25A50))
            : const Color(0xFF44618A),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items
              .map(
                (item) =>
                    SizedBox(width: itemWidth, child: _buildKpiCard(item)),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildKpiCard(_KpiItem item) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7E3D8), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B2430).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(item.icon, size: 18, color: item.color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7D8697),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1A2333),
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFFEAEFF8),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF334B6E)),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A2333),
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF303E50)),
    );
  }

  Widget _buildErrorState(String? errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('😕', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Color(0xFF666666)),
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
}

class _KpiItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}
