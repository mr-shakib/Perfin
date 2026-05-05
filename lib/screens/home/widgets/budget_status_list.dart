import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/budget_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/currency_provider.dart';

/// Category budget progress list.
class BudgetStatusList extends StatelessWidget {
  const BudgetStatusList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<BudgetProvider, TransactionProvider, CurrencyProvider>(
      builder:
          (context, budgetProvider, transactionProvider, currencyProvider, _) {
            final categoryBudgets = budgetProvider.categoryBudgets;
            final expensesByCategory = transactionProvider.expensesByCategory;

            if (categoryBudgets.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(34),
                decoration: _cardDecoration(),
                child: const Column(
                  children: [
                    Icon(
                      Icons.pie_chart_outline,
                      size: 40,
                      color: Color(0xFFB0B7C4),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No budgets set',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF667284),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Container(
              decoration: _cardDecoration(),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...categoryBudgets.entries.map((entry) {
                    final category = entry.key;
                    final budgetAmount = entry.value;
                    final spent = expensesByCategory[category] ?? 0.0;
                    final utilization = budgetAmount > 0
                        ? (spent / budgetAmount)
                        : 0.0;
                    final status = budgetProvider.getBudgetStatusForCategory(
                      category,
                      spent,
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
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
    Color statusBackground;
    String statusLabel;

    switch (status) {
      case BudgetStatus.underBudget:
        statusColor = const Color(0xFF2EA86F);
        statusBackground = const Color(0xFFE9F8EF);
        statusLabel = 'Healthy';
        break;
      case BudgetStatus.nearLimit:
        statusColor = const Color(0xFFC38724);
        statusBackground = const Color(0xFFFFF5E7);
        statusLabel = 'Near limit';
        break;
      case BudgetStatus.overBudget:
        statusColor = const Color(0xFFD25A50);
        statusBackground = const Color(0xFFFFEFEE);
        statusLabel = 'Over';
        break;
    }

    final percentage = (utilization * 100).clamp(0.0, 999.0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFBF8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAE5DA), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C2738),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBackground,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: utilization.clamp(0.0, 1.0),
              backgroundColor: const Color(0xFFE5E1D7),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${currencyProvider.formatWhole(spent)} / ${currencyProvider.formatWhole(budget)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7E8797),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFE6E3DB), width: 1),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF1B2430).withValues(alpha: 0.08),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}
