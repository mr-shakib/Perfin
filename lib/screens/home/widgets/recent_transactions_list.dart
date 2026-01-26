import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../models/transaction.dart';
import 'package:intl/intl.dart';

/// Recent Transactions List Widget
/// Displays the last 3 transactions with tap to navigate to detail view
/// Requirements: 1.7-1.8
class RecentTransactionsList extends StatelessWidget {
  const RecentTransactionsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, _) {
        final allTransactions = transactionProvider.transactions;

        // Handle empty state
        if (allTransactions.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start tracking your finances by adding your first transaction',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // Get the 3 most recent transactions
        final recentTransactions = allTransactions.take(3).toList();

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
                      'Recent Transactions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Navigate to all transactions
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('View all transactions coming soon!'),
                          ),
                        );
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Transaction items
                ...recentTransactions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final transaction = entry.value;
                  final isLast = index == recentTransactions.length - 1;

                  return Column(
                    children: [
                      _buildTransactionItem(context, transaction),
                      if (!isLast) const Divider(height: 24),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionItem(BuildContext context, Transaction transaction) {
    final isIncome = transaction.type == TransactionType.income;
    final dateFormat = DateFormat('MMM dd, yyyy');

    return InkWell(
      onTap: () {
        // TODO: Navigate to transaction detail view
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction detail for ${transaction.id}'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isIncome
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: isIncome ? Colors.green : Colors.red,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Transaction details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.category,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        dateFormat.format(transaction.date),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        const Text('•'),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            transaction.notes!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Amount
            Text(
              '${isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isIncome ? Colors.green : Colors.red,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
