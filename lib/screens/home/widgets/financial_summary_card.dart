import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/transaction_provider.dart';

/// Financial Summary Card Widget
/// Displays current balance, monthly income, and monthly spending
/// Requirements: 1.1-1.3
class FinancialSummaryCard extends StatelessWidget {
  const FinancialSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, _) {
        // Handle loading state
        if (transactionProvider.state == LoadingState.loading &&
            transactionProvider.transactions.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(
                    'Loading financial data...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        }

        // Handle error state
        if (transactionProvider.state == LoadingState.error &&
            transactionProvider.transactions.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    transactionProvider.errorMessage ?? 'Failed to load data',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // Get current month summary
        final summary = transactionProvider.currentMonthSummary;
        final currentBalance = transactionProvider.currentBalance;

        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Financial Overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                // Current Balance
                _buildSummaryRow(
                  context,
                  label: 'Current Balance',
                  amount: currentBalance,
                  icon: Icons.account_balance_wallet,
                  color: currentBalance >= 0 ? Colors.green : Colors.red,
                  isLarge: true,
                ),
                const Divider(height: 24),

                // Monthly Income
                _buildSummaryRow(
                  context,
                  label: 'Monthly Income',
                  amount: summary.totalIncome,
                  icon: Icons.arrow_downward,
                  color: Colors.green,
                ),
                const SizedBox(height: 12),

                // Monthly Spending
                _buildSummaryRow(
                  context,
                  label: 'Monthly Spending',
                  amount: summary.totalExpense,
                  icon: Icons.arrow_upward,
                  color: Colors.red,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(
    BuildContext context, {
    required String label,
    required double amount,
    required IconData icon,
    required Color color,
    bool isLarge = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: isLarge ? 28 : 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: isLarge
                    ? Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        )
                    : Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
