import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/recurring_expense.dart';
import '../../../theme/app_colors.dart';

/// Widget displaying detected recurring expenses
/// Requirements: 4.7-4.8
class RecurringExpensesList extends StatelessWidget {
  final List<RecurringExpense> recurringExpenses;
  final bool isLoading;

  const RecurringExpensesList({
    super.key,
    required this.recurringExpenses,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (recurringExpenses.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.repeat,
                size: 24,
                color: Color(0xFF1A1A1A),
              ),
              const SizedBox(width: 8),
              const Text(
                'Recurring Expenses',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...recurringExpenses.map((expense) => _buildExpenseItem(expense)),
        ],
      ),
    );
  }

  Widget _buildExpenseItem(RecurringExpense expense) {
    final frequencyText = _getFrequencyText(expense.frequencyDays);
    final daysUntilNext = expense.nextExpectedDate.difference(DateTime.now()).inDays;
    final isUpcoming = daysUntilNext <= 7 && daysUntilNext >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUpcoming ? const Color(0xFFFFF3CD) : AppColors.creamCard,
        borderRadius: BorderRadius.circular(12),
        border: isUpcoming
            ? Border.all(
                color: const Color(0xFFFFE69C),
                width: 1,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  expense.description,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '\$${expense.averageAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 14,
                color: isUpcoming ? const Color(0xFF856404) : const Color(0xFF666666),
              ),
              const SizedBox(width: 4),
              Text(
                frequencyText,
                style: TextStyle(
                  fontSize: 12,
                  color: isUpcoming ? const Color(0xFF856404) : const Color(0xFF666666),
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.calendar_today,
                size: 14,
                color: isUpcoming ? const Color(0xFF856404) : const Color(0xFF666666),
              ),
              const SizedBox(width: 4),
              Text(
                'Next: ${DateFormat('MMM d').format(expense.nextExpectedDate)}',
                style: TextStyle(
                  fontSize: 12,
                  color: isUpcoming ? const Color(0xFF856404) : const Color(0xFF666666),
                ),
              ),
            ],
          ),
          if (isUpcoming) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.notifications_active,
                  size: 14,
                  color: Color(0xFF856404),
                ),
                const SizedBox(width: 4),
                Text(
                  daysUntilNext == 0
                      ? 'Due today'
                      : daysUntilNext == 1
                          ? 'Due tomorrow'
                          : 'Due in $daysUntilNext days',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF856404),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getConfidenceColor(expense.confidenceScore).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${expense.confidenceScore}% confidence',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getConfidenceColor(expense.confidenceScore),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getFrequencyText(int days) {
    if (days <= 1) {
      return 'Daily';
    } else if (days <= 7) {
      return 'Weekly';
    } else if (days <= 14) {
      return 'Bi-weekly';
    } else if (days <= 31) {
      return 'Monthly';
    } else if (days <= 93) {
      return 'Quarterly';
    } else if (days <= 186) {
      return 'Semi-annually';
    } else {
      return 'Annually';
    }
  }

  Color _getConfidenceColor(int score) {
    if (score >= 80) {
      return const Color(0xFF50C878); // Green
    } else if (score >= 60) {
      return const Color(0xFFFFA500); // Orange
    } else {
      return const Color(0xFFFF6B6B); // Red
    }
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.creamLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF1A1A1A),
            ),
            SizedBox(height: 16),
            Text(
              'Detecting recurring expenses...',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.creamLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.repeat,
              size: 48,
              color: Color(0xFF999999),
            ),
            SizedBox(height: 16),
            Text(
              'No recurring expenses detected',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF666666),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add more transactions to detect recurring patterns',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF999999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
