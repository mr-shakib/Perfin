import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/budget_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/currency_provider.dart';
import '../../../theme/app_colors.dart';
import '../../budget/manage_budget_screen.dart';

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
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.creamLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.pie_chart_outline_rounded,
                    size: 32,
                    color: AppColors.neutral400,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No budgets set',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Create a budget to track your spending',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Budget Overview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to budgets screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManageBudgetScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'See All',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

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

        Container(
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.neutral200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: utilization.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

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
