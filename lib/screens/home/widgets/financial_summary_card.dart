import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/currency_provider.dart';

/// Financial Summary hero card with compact metrics.
class FinancialSummaryCard extends StatelessWidget {
  const FinancialSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionProvider, CurrencyProvider>(
      builder: (context, transactionProvider, currencyProvider, _) {
        final summary = transactionProvider.currentMonthSummary;
        final currentBalance = transactionProvider.currentBalance;
        final netFlow = summary.totalIncome - summary.totalExpense;
        final utilization = summary.totalIncome > 0
            ? (summary.totalExpense / summary.totalIncome).clamp(0.0, 1.0)
            : 0.0;

        return Container(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A2333), Color(0xFF273956), Color(0xFF324769)],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF121822).withValues(alpha: 0.24),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Total Balance',
                    style: TextStyle(
                      color: Color(0xFFC9D4E6),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      DateFormat('MMM yyyy').format(DateTime.now()),
                      style: const TextStyle(
                        color: Color(0xFFE5EBF5),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  currencyProvider.format(currentBalance),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.8,
                    height: 1.05,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    netFlow >= 0
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    color: netFlow >= 0
                        ? const Color(0xFF8EE5BA)
                        : const Color(0xFFFFB7AE),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Net ${netFlow >= 0 ? '+' : '-'}${currencyProvider.formatWhole(netFlow.abs())}',
                    style: const TextStyle(
                      color: Color(0xFFC9D4E6),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 7,
                  value: utilization,
                  backgroundColor: Colors.white.withValues(alpha: 0.14),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF8CB4E7),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricChip(
                      'Income',
                      summary.totalIncome,
                      const Color(0xFF5ED2A0),
                      currencyProvider,
                      icon: Icons.arrow_upward_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricChip(
                      'Expenses',
                      summary.totalExpense,
                      const Color(0xFFFF8A7A),
                      currencyProvider,
                      icon: Icons.arrow_downward_rounded,
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

  Widget _buildMetricChip(
    String label,
    double amount,
    Color color,
    CurrencyProvider currencyProvider, {
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFE5EBF5),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          currencyProvider.formatWhole(amount),
          style: TextStyle(
            color: color,
            fontSize: 19,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
