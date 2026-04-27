import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/currency_provider.dart';
import '../../../models/transaction.dart';
import 'package:intl/intl.dart';

/// Compact list of latest transactions.
class RecentTransactionsList extends StatelessWidget {
  const RecentTransactionsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionProvider, CurrencyProvider>(
      builder: (context, transactionProvider, currencyProvider, _) {
        final allTransactions = transactionProvider.transactions;

        if (allTransactions.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(34),
            decoration: _cardDecoration(),
            child: const Column(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 40,
                  color: Color(0xFFB0B7C4),
                ),
                SizedBox(height: 12),
                Text(
                  'No transactions yet',
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

        final recentTransactions = allTransactions.take(3).toList();

        return Container(
          decoration: _cardDecoration(),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...recentTransactions.asMap().entries.map((entry) {
                final index = entry.key;
                final transaction = entry.value;
                final isLast = index == recentTransactions.length - 1;

                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
                  child: _buildTransactionItem(
                    context,
                    transaction,
                    currencyProvider,
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    Transaction transaction,
    CurrencyProvider currencyProvider,
  ) {
    final isIncome = transaction.type == TransactionType.income;
    final dateFormat = DateFormat('MMM d');

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Transaction detail for ${transaction.id}'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFCFBF8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEAE5DA), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isIncome
                      ? const Color(0xFFEAF9F0)
                      : const Color(0xFFFFF0EE),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  isIncome
                      ? Icons.south_west_rounded
                      : Icons.north_east_rounded,
                  color: isIncome
                      ? const Color(0xFF2EA86F)
                      : const Color(0xFFD25A50),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.category,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C2738),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      transaction.notes?.trim().isNotEmpty == true
                          ? '${dateFormat.format(transaction.date)} • ${transaction.notes!.trim()}'
                          : dateFormat.format(transaction.date),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7E8797),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${isIncome ? '+' : '-'}${currencyProvider.formatWhole(transaction.amount)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isIncome
                      ? const Color(0xFF2EA86F)
                      : const Color(0xFFD25A50),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
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
