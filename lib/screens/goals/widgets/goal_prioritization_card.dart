import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/goal_prioritization.dart';
import '../../../models/goal.dart';
import '../../../theme/app_colors.dart';

/// Widget displaying AI goal prioritization when multiple goals exist
/// Requirements: 10.9-10.10
class GoalPrioritizationCard extends StatelessWidget {
  final GoalPrioritization? prioritization;
  final List<Goal> goals;
  final bool isLoading;

  const GoalPrioritizationCard({
    super.key,
    this.prioritization,
    required this.goals,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (prioritization == null || goals.length < 2) {
      return const SizedBox.shrink();
    }

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with AI badge
          Row(
            children: [
              const Text(
                'Goal Prioritization',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'AI',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Conflict warning if exists
          if (prioritization!.hasConflicts) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFF9800).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFFF9800),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Goal Conflict Detected',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFF9800),
                          ),
                        ),
                        if (prioritization!.conflictExplanation != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            prioritization!.conflictExplanation!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFFF9800),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Financial summary
          _buildFinancialSummary(),

          const SizedBox(height: 16),

          // Prioritized goals list
          const Text(
            'Recommended Priority Order',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          ...prioritization!.prioritizedGoals.map((prioritizedGoal) {
            final goal = goals.firstWhere(
              (g) => g.id == prioritizedGoal.goalId,
              orElse: () => goals.first,
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildPriorityItem(prioritizedGoal, goal),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary() {
    final isOverBudget = prioritization!.totalRequiredMonthlySavings >
        prioritization!.availableMonthlySurplus;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOverBudget
            ? const Color(0xFFFFEBEE)
            : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Required Monthly',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF666666),
                ),
              ),
              Text(
                '\$${_formatAmount(prioritization!.totalRequiredMonthlySavings)}',
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Available Monthly Surplus',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF666666),
                ),
              ),
              Text(
                '\$${_formatAmount(prioritization!.availableMonthlySurplus)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isOverBudget
                  ? const Color(0xFFF44336)
                  : const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isOverBudget ? Icons.error : Icons.check_circle,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  isOverBudget
                      ? 'Over budget by \$${_formatAmount(prioritization!.totalRequiredMonthlySavings - prioritization!.availableMonthlySurplus)}'
                      : 'Within budget',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityItem(PrioritizedGoal prioritizedGoal, Goal goal) {
    final priorityColor = _getPriorityColor(prioritizedGoal.priority);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.creamLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Priority badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: priorityColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${prioritizedGoal.priority}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  prioritizedGoal.rationale,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
          width: 1,
        ),
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
              'Analyzing goal priorities...',
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

  String _formatAmount(double amount) {
    if (amount >= 1000) {
      return NumberFormat('#,##0').format(amount);
    }
    return amount.toStringAsFixed(0);
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return const Color(0xFF4CAF50); // Green - highest priority
      case 2:
        return const Color(0xFF2196F3); // Blue
      case 3:
        return const Color(0xFFFF9800); // Orange
      default:
        return const Color(0xFF666666); // Gray
    }
  }
}
