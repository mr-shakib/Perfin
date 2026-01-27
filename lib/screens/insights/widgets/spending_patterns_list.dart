import 'package:flutter/material.dart';
import '../../../models/spending_pattern.dart';

/// Widget displaying detected spending patterns
/// Requirements: 5.1-5.8
class SpendingPatternsList extends StatelessWidget {
  final List<SpendingPattern> patterns;
  final bool isLoading;

  const SpendingPatternsList({
    super.key,
    required this.patterns,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (patterns.isEmpty) {
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
                Icons.insights,
                size: 24,
                color: Color(0xFF1A1A1A),
              ),
              const SizedBox(width: 8),
              const Text(
                'Spending Patterns',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...patterns.map((pattern) => _buildPatternItem(pattern)),
        ],
      ),
    );
  }

  Widget _buildPatternItem(SpendingPattern pattern) {
    final trendIcon = _getTrendIcon(pattern.patternType);
    final trendColor = _getTrendColor(pattern.patternType);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: trendColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  trendIcon,
                  size: 20,
                  color: trendColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getPatternTitle(pattern.patternType),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pattern.categoryId,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
              if (pattern.magnitude != 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: trendColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${pattern.magnitude > 0 ? '+' : ''}${pattern.magnitude.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: trendColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              pattern.description,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF666666),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getConfidenceColor(pattern.confidenceScore).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${pattern.confidenceScore}% confidence',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getConfidenceColor(pattern.confidenceScore),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getTrendIcon(String patternType) {
    switch (patternType.toLowerCase()) {
      case 'increasing':
        return Icons.trending_up;
      case 'decreasing':
        return Icons.trending_down;
      case 'weekend_heavy':
        return Icons.weekend;
      case 'weekday_heavy':
        return Icons.work;
      case 'stable':
        return Icons.trending_flat;
      default:
        return Icons.insights;
    }
  }

  Color _getTrendColor(String patternType) {
    switch (patternType.toLowerCase()) {
      case 'increasing':
        return const Color(0xFFFF6B6B); // Red
      case 'decreasing':
        return const Color(0xFF50C878); // Green
      case 'weekend_heavy':
      case 'weekday_heavy':
        return const Color(0xFF4A90E2); // Blue
      case 'stable':
        return const Color(0xFF999999); // Gray
      default:
        return const Color(0xFF1A1A1A); // Black
    }
  }

  String _getPatternTitle(String patternType) {
    switch (patternType.toLowerCase()) {
      case 'increasing':
        return 'Increasing Trend';
      case 'decreasing':
        return 'Decreasing Trend';
      case 'weekend_heavy':
        return 'Weekend Spending';
      case 'weekday_heavy':
        return 'Weekday Spending';
      case 'stable':
        return 'Stable Pattern';
      default:
        return patternType;
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
        color: const Color(0xFFF5F5F5),
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
              'Detecting patterns...',
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
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.insights,
              size: 48,
              color: Color(0xFF999999),
            ),
            SizedBox(height: 16),
            Text(
              'No patterns detected',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF666666),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add more transactions to detect spending patterns',
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
