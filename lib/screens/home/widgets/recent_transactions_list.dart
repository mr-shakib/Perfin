import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/currency_provider.dart';
import '../../../models/transaction.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../main_dashboard.dart';

/// Recent Transactions List - Modern Card Design
/// Requirements: 1.7-1.8
class RecentTransactionsList extends StatelessWidget {
  const RecentTransactionsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionProvider, CurrencyProvider>(
      builder: (context, transactionProvider, currencyProvider, _) {
        final allTransactions = transactionProvider.transactions;

        if (allTransactions.isEmpty) {
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
                    Icons.receipt_long_outlined,
                    size: 32,
                    color: AppColors.neutral400,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No transactions yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Start by adding your first transaction',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
          );
        }

        final recentTransactions = allTransactions.take(5).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Latest Transactions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to Feed tab (index 1)
                      MainDashboard.switchTab(context, 1);
                    },
                    child: Text(
                      'See All',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Container(
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
              padding: const EdgeInsets.all(16),
              child: Column(
                children: recentTransactions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final transaction = entry.value;
                  final isLast = index == recentTransactions.length - 1;

                  return Column(
                    children: [
                      _buildTransactionItem(context, transaction, currencyProvider),
                      if (!isLast)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Divider(
                            height: 1,
                            color: AppColors.neutral200,
                          ),
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTransactionItem(BuildContext context, Transaction transaction, CurrencyProvider currencyProvider) {
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
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isIncome
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Icon(
                  isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
                  color: isIncome ? AppColors.success : AppColors.error,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 14),

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
                  const SizedBox(height: 3),
                  Text(
                    dateFormat.format(transaction.date),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.neutral500,
                    ),
                  ),
                ],
              ),
            ),

            Text(
              '${isIncome ? '+' : ''}${currencyProvider.format(transaction.amount)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isIncome ? AppColors.success : AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
