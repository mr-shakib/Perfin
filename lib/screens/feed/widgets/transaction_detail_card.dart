import 'package:flutter/material.dart';
import '../../../models/transaction.dart';
import '../../../utils/currency_utils.dart';
import 'package:intl/intl.dart';

/// Full-screen Individual Transaction Detail Card
class TransactionDetailCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailCard({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    // Minimal color scheme
    final backgroundColor = isIncome
        ? const Color(0xFFF0FDF4) // Very light green
        : const Color(0xFFFFF1F2); // Very light red
    
    final accentColor = isIncome
        ? const Color(0xFF16A34A) // Green
        : const Color(0xFFDC2626); // Red

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: backgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Transaction type icon and label
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                      size: 40,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    isIncome ? 'Income' : 'Expense',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                ],
              ),

              // Amount
              Text(
                '${isIncome ? '+' : '-'}${CurrencyUtils.format(transaction.amount)}',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                  letterSpacing: -3,
                ),
              ),

              // Details card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE5E5E5),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // Category
                    _buildDetailRow(
                      Icons.category_outlined,
                      'Category',
                      transaction.category,
                      accentColor,
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFE5E5E5), height: 1),
                    const SizedBox(height: 16),

                    // Date
                    _buildDetailRow(
                      Icons.calendar_today_outlined,
                      'Date',
                      dateFormat.format(transaction.date),
                      accentColor,
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFE5E5E5), height: 1),
                    const SizedBox(height: 16),

                    // Time
                    _buildDetailRow(
                      Icons.access_time_outlined,
                      'Time',
                      timeFormat.format(transaction.date),
                      accentColor,
                    ),

                    if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFFE5E5E5), height: 1),
                      const SizedBox(height: 16),

                      // Notes
                      _buildDetailRow(
                        Icons.note_outlined,
                        'Notes',
                        transaction.notes!,
                        accentColor,
                      ),
                    ],
                  ],
                ),
              ),

              // Swipe indicator
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Swipe for more',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF999999).withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: const Color(0xFF999999).withValues(alpha: 0.6),
                    size: 24,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color accentColor) {
    return Row(
      children: [
        Icon(
          icon,
          color: accentColor.withValues(alpha: 0.7),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF999999),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
