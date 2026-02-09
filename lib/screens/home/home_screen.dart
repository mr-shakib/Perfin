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
      backgroundColor: AppColors.neutral100,
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
                // Minimal header with notification icon
                SliverToBoxAdapter(
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.06),
                                  blurRadius: 12,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.notifications_none_rounded),
                              iconSize: 24,
                              color: AppColors.primary,
                              onPressed: () {},
                            ),
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
                      const SizedBox(height: 16),
                      
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: FinancialSummaryCard(),
                      ),
                      
                      const SizedBox(height: 40),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: QuickActionButtons(),
                      ),
                      
                      const SizedBox(height: 40),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: RecentTransactionsList(),
                      ),
                      
                      const SizedBox(height: 32),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: AISummaryCard(),
                      ),
                      
                      const SizedBox(height: 32),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
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
    return Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildErrorState(String? errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Oops!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage ?? 'Something went wrong',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.neutral600,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _onRefresh,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
