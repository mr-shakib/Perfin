import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/ai_provider.dart';
import '../../theme/app_colors.dart';
import 'widgets/financial_summary_card.dart';
import 'widgets/budget_status_list.dart';
import 'widgets/ai_summary_card.dart';
import 'widgets/recent_transactions_list.dart';
import 'widgets/quick_action_buttons.dart';

/// Home Tab - Clean Minimal Design
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
    return Scaffold(
      backgroundColor: AppColors.creamLight,
      body: Consumer3<TransactionProvider, BudgetProvider, AIProvider>(
        builder: (context, transactionProvider, budgetProvider, aiProvider, _) {
          if (transactionProvider.state == LoadingState.loading &&
              transactionProvider.transactions.isEmpty) {
            return _buildLoadingState();
          }

          if (transactionProvider.state == LoadingState.error &&
              transactionProvider.transactions.isEmpty) {
            return _buildErrorState(transactionProvider.errorMessage);
          }

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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Overview',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                              letterSpacing: -1,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications_none),
                            iconSize: 28,
                            color: const Color(0xFF1A1A1A),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Content
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: FinancialSummaryCard(),
                      ),
                      
                      const SizedBox(height: 32),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: QuickActionButtons(),
                      ),
                      
                      const SizedBox(height: 32),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: AISummaryCard(),
                      ),
                      
                      const SizedBox(height: 32),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: RecentTransactionsList(),
                      ),
                      
                      const SizedBox(height: 32),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: BudgetStatusList(),
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
}
