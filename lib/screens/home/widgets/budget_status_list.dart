import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/budget_provider.dart';
import '../../../providers/transaction_provider.dart';

/// Budget Status List Widget
/// Displays all active budgets with utilization bars and color-coded indicators
/// Requirements: 1.4-1.6
class BudgetStatusList extends StatelessWidget {
  const BudgetStatusList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<BudgetProvider, TransactionProvider>(
      builder: (context, budgetProvider, transactionProvider, _) {
        final categoryBudgets = budgetProvider.categoryBudgets;
        final expensesByCategory = transactionProvider.expensesByCategory;

        // Handle empty state
        if (categoryBudgets.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.pie_chart_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No budgets set',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create budgets to track your spending by category',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to budget creation
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Budget creation coming soon!'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create Budget'),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Budget Status',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Navigate to budget management
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Budget management coming soon!'),
                          ),
                        );
                      },
                      child: const Text('Manage'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Budget items
                ...categoryBudgets.entries.map((entry) {
                  final category = entry.key;
                  final budgetAmount = entry.value;
                  final spent = expensesByCategory[category] ?? 0.0;
                  final utilization = budgetAmount > 0 ? (spent / budgetAmount) : 0.0;
                  final status = budgetProvider.getBudgetStatusForCategory(category, spent);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _buildBudgetItem(
                      context,
                      category: category,
                      spent: spent,
                      budget: budgetAmount,
                      utilization: utilization,
                      status: status,
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBudgetItem(
    BuildContext context, {
    required String category,
    required double spent,
    required double budget,
    required double utilization,
    required BudgetStatus status,
  }) {
    // Determine color based on status
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case BudgetStatus.underBudget:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'On track';
        break;
      case BudgetStatus.nearLimit:
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        statusText = 'Near limit';
        break;
      case BudgetStatus.overBudget:
        statusColor = Colors.red;
        statusIcon = Icons.error;
        statusText = 'Over budget';
        break;
    }

    final percentage = (utilization * 100).clamp(0, 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                category,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            Row(
              children: [
                Icon(
                  statusIcon,
                  size: 16,
                  color: statusColor,
                ),
                const SizedBox(width: 4),
                Text(
                  statusText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: utilization.clamp(0.0, 1.0),
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 8),

        // Amount details
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$${spent.toStringAsFixed(2)} of \$${budget.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
