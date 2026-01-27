import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/ai_provider.dart';
import '../../../providers/transaction_provider.dart';

/// AI Summary Card - Clean Minimal Design
/// Requirements: 2.1-2.8
class AISummaryCard extends StatelessWidget {
  const AISummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AIProvider>(
      builder: (context, aiProvider, _) {
        final summary = aiProvider.currentSummary;

        if (aiProvider.state == LoadingState.loading && summary == null) {
          return _buildLoadingCard();
        }

        if (aiProvider.state == LoadingState.error || summary == null) {
          return _buildErrorCard();
        }

        if (summary.hasInsufficientData) {
          return _buildInsufficientDataCard(summary.summaryText);
        }

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5856D6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'AI Insights',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  Text(
                    '${summary.confidenceScore}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                summary.summaryText,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Color(0xFF333333),
                ),
              ),

              if (summary.insights.isNotEmpty) ...[
                const SizedBox(height: 20),
                ...summary.insights.take(3).map((insight) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Color(0xFF5856D6),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              insight,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],

              if (summary.anomalies.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFFF3B30),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${summary.anomalies.length} anomalies detected',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFF3B30),
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
      },
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF5856D6),
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Color(0xFF666666),
            size: 24,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'AI insights unavailable',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsufficientDataCard(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: Color(0xFF5856D6),
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
