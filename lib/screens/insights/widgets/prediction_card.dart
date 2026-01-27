import 'package:flutter/material.dart';
import '../../../models/spending_prediction.dart';
import '../../../theme/app_colors.dart';

/// Widget displaying AI-powered spending prediction
/// Requirements: 4.1-4.6
class PredictionCard extends StatelessWidget {
  final SpendingPrediction? prediction;
  final bool hasInsufficientData;
  final bool isLoading;

  const PredictionCard({
    super.key,
    this.prediction,
    this.hasInsufficientData = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (hasInsufficientData || prediction == null) {
      return _buildInsufficientDataState();
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
                Icons.auto_graph,
                size: 24,
                color: Color(0xFF1A1A1A),
              ),
              const SizedBox(width: 8),
              const Text(
                'Spending Prediction',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Predicted amount
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'Predicted: ',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
              Text(
                '\$${prediction!.predictedAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Confidence indicator
          _buildConfidenceIndicator(prediction!.confidenceScore),
          
          const SizedBox(height: 16),
          
          // Explanation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.creamLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              prediction!.explanation,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
                height: 1.5,
              ),
            ),
          ),
          
          // Low confidence warning
          if (prediction!.confidenceScore < 60) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFFFE69C),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 20,
                    color: Color(0xFF856404),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Low confidence: This prediction may not be accurate due to limited or variable data.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF856404),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfidenceIndicator(int confidenceScore) {
    final confidence = confidenceScore / 100.0;
    final color = _getConfidenceColor(confidenceScore);
    final label = _getConfidenceLabel(confidenceScore);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Confidence: $label',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            Text(
              '$confidenceScore%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: confidence,
            backgroundColor: const Color(0xFFE0E0E0),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
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

  String _getConfidenceLabel(int score) {
    if (score >= 80) {
      return 'High';
    } else if (score >= 60) {
      return 'Medium';
    } else {
      return 'Low';
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
              'Generating prediction...',
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

  Widget _buildInsufficientDataState() {
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
              Icons.auto_graph,
              size: 48,
              color: Color(0xFF999999),
            ),
            SizedBox(height: 16),
            Text(
              'Predictions not available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF666666),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add at least 30 days of transactions to see spending predictions',
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
