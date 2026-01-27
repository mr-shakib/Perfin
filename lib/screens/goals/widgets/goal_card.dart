import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/goal.dart';
import '../goal_detail_screen.dart';
import '../../../theme/app_colors.dart';

/// Widget displaying individual goal with progress
/// Requirements: 9.1, 9.12
class GoalCard extends StatelessWidget {
  final Goal goal;

  const GoalCard({
    super.key,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final progressPercentage = goal.progressPercentage.clamp(0.0, 100.0);
    final requiredMonthlySavings = goal.requiredMonthlySavings;
    final daysRemaining = goal.daysRemaining;
    final isCompleted = goal.isCompleted;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GoalDetailScreen(goalId: goal.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isCompleted ? AppColors.creamCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE5E5E5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    goal.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isCompleted
                          ? const Color(0xFF666666)
                          : const Color(0xFF1A1A1A),
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                ),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Completed',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Amount progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${_formatAmount(goal.currentAmount)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  'of \$${_formatAmount(goal.targetAmount)}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progressPercentage / 100,
                minHeight: 8,
                backgroundColor: const Color(0xFFE5E5E5),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getProgressColor(progressPercentage, daysRemaining),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Progress percentage
            Text(
              '${progressPercentage.toStringAsFixed(1)}% complete',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666),
              ),
            ),

            const SizedBox(height: 16),

            // Deadline and required savings
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    icon: Icons.calendar_today,
                    label: _formatDeadline(goal.targetDate, daysRemaining),
                    color: _getDeadlineColor(daysRemaining),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoChip(
                    icon: Icons.savings_outlined,
                    label: '\$${_formatAmount(requiredMonthlySavings)}/mo',
                    color: const Color(0xFF666666),
                  ),
                ),
              ],
            ),

            // Manual tracking indicator
            if (goal.isManualTracking) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.edit,
                      size: 16,
                      color: Color(0xFFFF9800),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Manually tracked',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFFF9800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.creamLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000) {
      return NumberFormat('#,##0').format(amount);
    }
    return amount.toStringAsFixed(0);
  }

  String _formatDeadline(DateTime targetDate, int daysRemaining) {
    if (daysRemaining < 0) {
      return 'Overdue';
    } else if (daysRemaining == 0) {
      return 'Today';
    } else if (daysRemaining == 1) {
      return '1 day left';
    } else if (daysRemaining < 30) {
      return '$daysRemaining days left';
    } else if (daysRemaining < 365) {
      final months = (daysRemaining / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} left';
    } else {
      return DateFormat('MMM d, yyyy').format(targetDate);
    }
  }

  Color _getProgressColor(double progressPercentage, int daysRemaining) {
    if (progressPercentage >= 100) {
      return const Color(0xFF4CAF50); // Green - completed
    } else if (daysRemaining < 30 && progressPercentage < 80) {
      return const Color(0xFFFF9800); // Orange - behind schedule
    } else if (progressPercentage >= 75) {
      return const Color(0xFF4CAF50); // Green - on track
    } else {
      return const Color(0xFF1A1A1A); // Black - default
    }
  }

  Color _getDeadlineColor(int daysRemaining) {
    if (daysRemaining < 0) {
      return const Color(0xFFF44336); // Red - overdue
    } else if (daysRemaining < 30) {
      return const Color(0xFFFF9800); // Orange - urgent
    } else {
      return const Color(0xFF666666); // Gray - normal
    }
  }
}
