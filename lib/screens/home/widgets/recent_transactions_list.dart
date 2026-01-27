import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../models/transaction.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';

/// Recent Transactions List - Clean Minimal Design
/// Requirements: 1.7-1.8
class RecentTransactionsList extends StatelessWidget {
  const RecentTransactionsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, _) {
        final allTransactions = transactionProvider.transactions;

        if (allTransactions.isEmpty) {
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
                  Icons.receipt_long_outlined,
                  size: 48,
                  color: Color(0xFFCCCCCC),
                ),
                SizedBox(height: 16),
                Text(
                  'No transactions yet',
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

        final recentTransactions = allTransactions.take(3).toList();

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
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 20),

              ...recentTransactions.asMap().entries.map((entry) {
                final index = entry.key;
                final transaction = entry.value;
                final isLast = index == recentTransactions.length - 1;

                return Column(
                  children: [
                    _buildTransactionItem(context, transaction),
                    if (!isLast)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(height: 1, color: Color(0xFFE0E0E0)),
                      ),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionItem(BuildContext context, Transaction transaction) {
    final isIncome = transaction.type == TransactionType.income;
    final dateFormat = DateFormat('MMM dd');

    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction detail for ${transaction.id}'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isIncome
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: isIncome
                    ? const Color(0xFF00C853)
                    : const Color(0xFFFF3B30),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.category,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormat.format(transaction.date),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),

            Text(
              '${isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isIncome
                    ? const Color(0xFF00C853)
                    : const Color(0xFFFF3B30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
