import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/ai_provider.dart';
import 'widgets/financial_summary_card.dart';
import 'widgets/budget_status_list.dart';
import 'widgets/ai_summary_card.dart';
import 'widgets/recent_transactions_list.dart';
import 'widgets/quick_action_buttons.dart';

/// Home Tab - Financial Overview
/// Requirements: 1.1-1.10, 2.1-2.8
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load data after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    final transactionProvider = context.read<TransactionProvider>();
    final budgetProvider = context.read<BudgetProvider>();
    final aiProvider = context.read<AIProvider>();

    // Load transactions and budgets
    await Future.wait([
      transactionProvider.loadTransactions(),
      budgetProvider.loadBudgets(),
    ]);

    // Generate AI summary for current month
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Consumer3<TransactionProvider, BudgetProvider, AIProvider>(
          builder: (context, transactionProvider, budgetProvider, aiProvider, _) {
            // Show loading state
            if (transactionProvider.state == LoadingState.loading &&
                transactionProvider.transactions.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // Show error state
            if (transactionProvider.state == LoadingState.error &&
                transactionProvider.transactions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      transactionProvider.errorMessage ?? 'Failed to load data',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _onRefresh,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // Main content
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Financial Summary Card
                  const FinancialSummaryCard(),
                  const SizedBox(height: 16),

                  // AI Summary Card
                  const AISummaryCard(),
                  const SizedBox(height: 16),

                  // Budget Status List
                  const BudgetStatusList(),
                  const SizedBox(height: 16),

                  // Recent Transactions
                  const RecentTransactionsList(),
                  const SizedBox(height: 16),

                  // Quick Actions
                  const QuickActionButtons(),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
