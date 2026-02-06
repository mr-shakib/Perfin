import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/currency_provider.dart';
import '../../../models/transaction.dart';

/// Full-screen Expense Card
class ExpenseCard extends StatelessWidget {
  const ExpenseCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionProvider, CurrencyProvider>(
      builder: (context, transactionProvider, currencyProvider, _) {
        final expenses = transactionProvider.transactions
            .where((t) => t.type == TransactionType.expense)
            .toList();
        
        final totalExpense = expenses.fold<double>(
          0.0,
          (sum, t) => sum + t.amount,
        );

        final now = DateTime.now();
        final thisMonth = expenses.where((t) =>
            t.date.year == now.year && t.date.month == now.month).toList();
        final monthlyExpense = thisMonth.fold<double>(
          0.0,
          (sum, t) => sum + t.amount,
        );

        // Group by category
        final Map<String, double> byCategory = {};
        for (var expense in thisMonth) {
          byCategory[expense.category] = 
              (byCategory[expense.category] ?? 0) + expense.amount;
        }

        final topCategories = byCategory.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFF3B30),
                Color(0xFFFF6B5A),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.arrow_upward,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Total Expenses',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currencyProvider.format(totalExpense),
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -3,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'This Month',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          currencyProvider.format(monthlyExpense),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -2,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (topCategories.isNotEmpty) ...[
                          const Divider(color: Colors.white, height: 1),
                          const SizedBox(height: 20),
                          Text(
                            'Top Categories',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...topCategories.take(3).map((entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      currencyProvider.formatWhole(entry.value),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Swipe up for more',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 32,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
