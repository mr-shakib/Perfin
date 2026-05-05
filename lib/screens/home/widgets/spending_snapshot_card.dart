import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/transaction.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/currency_provider.dart';

/// Compact monthly spending visualization card.
class SpendingSnapshotCard extends StatelessWidget {
  const SpendingSnapshotCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionProvider, CurrencyProvider>(
      builder: (context, transactionProvider, currencyProvider, _) {
        final monthlyCategoryData = _buildMonthlyCategoryData(
          transactionProvider.transactions,
        );

        if (monthlyCategoryData.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(28),
            decoration: _cardDecoration(),
            child: const Column(
              children: [
                Icon(
                  Icons.stacked_bar_chart_rounded,
                  size: 38,
                  color: Color(0xFFB0B7C4),
                ),
                SizedBox(height: 10),
                Text(
                  'No expenses this month',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF667284),
                  ),
                ),
              ],
            ),
          );
        }

        final totalSpent = monthlyCategoryData.values.fold<double>(
          0,
          (sum, value) => sum + value,
        );
        final topCategories = monthlyCategoryData.entries.take(4).toList();
        final maxCategoryAmount = topCategories
            .map((entry) => entry.value)
            .reduce(max);

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          decoration: _cardDecoration(),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.bar_chart_rounded,
                    size: 18,
                    color: Color(0xFF344C70),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'This Month',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF172132),
                      ),
                    ),
                  ),
                  Text(
                    currencyProvider.formatWhole(totalSpent),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF344C70),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 118,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: topCategories.asMap().entries.map((entry) {
                    final index = entry.key;
                    final categoryEntry = entry.value;
                    final height =
                        (categoryEntry.value / maxCategoryAmount).clamp(
                          0.0,
                          1.0,
                        ) *
                        80;

                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: index == topCategories.length - 1 ? 0 : 8,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOutCubic,
                              height: max(16, height),
                              decoration: BoxDecoration(
                                gradient: _barGradient(index),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _truncate(categoryEntry.key, maxChars: 8),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF7B8290),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: topCategories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final categoryEntry = entry.value;
                  final share = (categoryEntry.value / totalSpent * 100)
                      .clamp(0.0, 100.0)
                      .toStringAsFixed(0);

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F9FC),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: _barGradient(index),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$share%',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF344C70),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          currencyProvider.formatWhole(categoryEntry.value),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6E7888),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, double> _buildMonthlyCategoryData(
    List<Transaction> transactions,
  ) {
    final now = DateTime.now();
    final categoryTotals = <String, double>{};

    for (final transaction in transactions) {
      if (transaction.type != TransactionType.expense) continue;
      if (transaction.date.year != now.year ||
          transaction.date.month != now.month) {
        continue;
      }

      categoryTotals.update(
        transaction.category,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries);
  }

  LinearGradient _barGradient(int index) {
    const palette = [
      [Color(0xFF2E4566), Color(0xFF3F5F8D)],
      [Color(0xFF2EA86F), Color(0xFF4CCB90)],
      [Color(0xFFCF6A5E), Color(0xFFD98D7F)],
      [Color(0xFF8A64D1), Color(0xFFA082DC)],
    ];

    final colors = palette[index % palette.length];
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: colors,
    );
  }

  String _truncate(String value, {int maxChars = 12}) {
    final normalized = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.length <= maxChars) {
      return normalized;
    }
    return '${normalized.substring(0, maxChars - 1)}…';
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
