import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/budget_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/currency_provider.dart';
import '../../../theme/app_colors.dart';

/// Budget Status List - Clean Minimal Design
/// Requirements: 1.4-1.6
class BudgetStatusList extends StatelessWidget {
  const BudgetStatusList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<BudgetProvider, TransactionProvider, CurrencyProvider>(
      builder: (context, budgetProvider, transactionProvider, currencyProvider, _) {
        final categoryBudgets = budgetProvider.categoryBudgets;
        final expensesByCategory = transactionProvider.expensesByCategory;

        if (categoryBudgets.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppColors.creamLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFE5E5E5),
                width: 1,
              ),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.pie_chart_outline,
                  size: 48,
                  color: Color(0xFFCCCCCC),
                ),
                SizedBox(height: 16),
                Text(
                  'No budgets set',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: AppColors.creamLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE5E5E5),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Budgets',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 20),

              ...categoryBudgets.entries.map((entry) {
                final category = entry.key;
                final budgetAmount = entry.value;
                final spent = expensesByCategory[category] ?? 0.0;
                final utilization = budgetAmount > 0 ? (spent / budgetAmount) : 0.0;
                final status = budgetProvider.getBudgetStatusForCategory(category, spent);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _buildBudgetItem(
                    category: category,
                    spent: spent,
                    budget: budgetAmount,
                    utilization: utilization,
                    status: status,
                    currencyProvider: currencyProvider,
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBudgetItem({
    required String category,
    required double spent,
    required double budget,
    required double utilization,
    required BudgetStatus status,
    required CurrencyProvider currencyProvider,
  }) {
    Color statusColor;

    switch (status) {
      case BudgetStatus.underBudget:
        statusColor = const Color(0xFF00C853);
        break;
      case BudgetStatus.nearLimit:
        statusColor = const Color(0xFFFF9500);
        break;
      case BudgetStatus.overBudget:
        statusColor = const Color(0xFFFF3B30);
        break;
    }

    final percentage = (utilization * 100).clamp(0, 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: utilization.clamp(0.0, 1.0),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Text(
          '${currencyProvider.formatWhole(spent)} of ${currencyProvider.formatWhole(budget)}',
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF999999),
          ),
        ),
      ],
    );
  }
}
