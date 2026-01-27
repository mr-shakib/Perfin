import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../utils/currency_utils.dart';

/// Financial Summary Card - Clean Minimal Design
/// Requirements: 1.1-1.3
class FinancialSummaryCard extends StatelessWidget {
  const FinancialSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, _) {
        final summary = transactionProvider.currentMonthSummary;
        final currentBalance = transactionProvider.currentBalance;

        return Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Balance',
                style: TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              
              Text(
                CurrencyUtils.format(currentBalance),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -2,
                ),
              ),
              
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: _buildStat(
                      'Income',
                      summary.totalIncome,
                      const Color(0xFF00C853),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStat(
                      'Expenses',
                      summary.totalExpense,
                      const Color(0xFFFF3B30),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStat(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF666666),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          CurrencyUtils.formatWhole(amount),
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
