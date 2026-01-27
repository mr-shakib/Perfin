import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/goal_feasibility_analysis.dart';
import '../../../models/spending_reduction.dart';

/// Widget displaying AI feasibility analysis for a goal
/// Requirements: 10.1-10.10
class AIFeasibilityCard extends StatelessWidget {
  final GoalFeasibilityAnalysis? analysis;
  final bool isLoading;

  const AIFeasibilityCard({
    super.key,
    this.analysis,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (analysis == null) {
      return _buildUnavailableState();
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
                'AI Feasibility Analysis',
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

          // Feasibility status
          _buildFeasibilityStatus(),

          const SizedBox(height: 16),

          // Financial metrics
          _buildMetricsRow(),

          const SizedBox(height: 16),

          // Explanation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              analysis!.explanation,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1A1A1A),
                height: 1.5,
              ),
            ),
          ),

          // Spending reduction suggestions
          if (analysis!.suggestedReductions.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Suggested Spending Reductions',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 12),
            ...analysis!.suggestedReductions.map((reduction) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildReductionItem(reduction),
              );
            }),
          ],

          // Confidence score
          const SizedBox(height: 16),
          _buildConfidenceIndicator(),
        ],
      ),
    );
  }

  Widget _buildFeasibilityStatus() {
    final color = _getFeasibilityColor(analysis!.feasibilityLevel);
    final icon = _getFeasibilityIcon(analysis!.feasibilityLevel);
    final label = _getFeasibilityLabel(analysis!.feasibilityLevel);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  analysis!.isAchievable
                      ? 'This goal is achievable'
                      : 'This goal may be challenging',
                  style: TextStyle(
                    fontSize: 13,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            label: 'Required Monthly',
            value: '\$${_formatAmount(analysis!.requiredMonthlySavings)}',
            icon: Icons.savings_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            label: 'Monthly Surplus',
            value: '\$${_formatAmount(analysis!.averageMonthlySurplus)}',
            icon: Icons.account_balance_wallet_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF666666),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReductionItem(SpendingReduction reduction) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reduction.categoryId,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reduction.rationale,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '-\$${_formatAmount(reduction.suggestedReduction)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFF44336),
                ),
              ),
              Text(
                '\$${_formatAmount(reduction.newMonthlySpending)}/mo',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceIndicator() {
    final confidence = analysis!.confidenceScore;
    final color = _getConfidenceColor(confidence);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Confidence',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF666666),
                    ),
                  ),
                  Text(
                    '$confidence%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: confidence / 100,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE5E5E5),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        ),
      ],
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
              'Analyzing goal feasibility...',
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

  Widget _buildUnavailableState() {
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
            Icon(
              Icons.psychology_outlined,
              size: 48,
              color: Color(0xFFCCCCCC),
            ),
            SizedBox(height: 16),
            Text(
              'AI analysis unavailable',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF666666),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add more transactions to enable AI insights',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF999999),
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

  Color _getFeasibilityColor(FeasibilityLevel level) {
    switch (level) {
      case FeasibilityLevel.easy:
        return const Color(0xFF4CAF50);
      case FeasibilityLevel.moderate:
        return const Color(0xFF2196F3);
      case FeasibilityLevel.challenging:
        return const Color(0xFFFF9800);
      case FeasibilityLevel.unrealistic:
        return const Color(0xFFF44336);
    }
  }

  IconData _getFeasibilityIcon(FeasibilityLevel level) {
    switch (level) {
      case FeasibilityLevel.easy:
        return Icons.check_circle;
      case FeasibilityLevel.moderate:
        return Icons.trending_up;
      case FeasibilityLevel.challenging:
        return Icons.warning;
      case FeasibilityLevel.unrealistic:
        return Icons.error;
    }
  }

  String _getFeasibilityLabel(FeasibilityLevel level) {
    switch (level) {
      case FeasibilityLevel.easy:
        return 'Easy to Achieve';
      case FeasibilityLevel.moderate:
        return 'Moderately Achievable';
      case FeasibilityLevel.challenging:
        return 'Challenging';
      case FeasibilityLevel.unrealistic:
        return 'Unrealistic';
    }
  }

  Color _getConfidenceColor(int confidence) {
    if (confidence >= 80) {
      return const Color(0xFF4CAF50);
    } else if (confidence >= 60) {
      return const Color(0xFFFF9800);
    } else {
      return const Color(0xFFF44336);
    }
  }
}
