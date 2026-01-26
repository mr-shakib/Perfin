import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/ai_provider.dart';
import '../../../providers/transaction_provider.dart';

/// AI Summary Card Widget
/// Displays AI-generated financial summary with insights and anomalies
/// Requirements: 2.1-2.8
class AISummaryCard extends StatelessWidget {
  const AISummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AIProvider>(
      builder: (context, aiProvider, _) {
        final summary = aiProvider.currentSummary;

        // Handle loading state
        if (aiProvider.state == LoadingState.loading && summary == null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(
                    'Generating AI insights...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        }

        // Handle error state - fall back to factual data
        if (aiProvider.state == LoadingState.error || summary == null) {
          return Card(
            color: Colors.grey[100],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'AI Insights',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'AI insights are temporarily unavailable. Your financial data is still accessible in the sections below.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                  ),
                ],
              ),
            ),
          );
        }

        // Handle insufficient data state
        if (summary.hasInsufficientData) {
          return Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'AI Insights',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    summary.summaryText,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        }

        // Display AI summary with insights
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with confidence indicator
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: Colors.purple,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'AI Insights',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    _buildConfidenceBadge(context, summary.confidenceScore),
                  ],
                ),
                const SizedBox(height: 16),

                // Summary text
                Text(
                  summary.summaryText,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),

                // Key insights
                if (summary.insights.isNotEmpty) ...[
                  const Divider(),
                  const SizedBox(height: 12),
                  Text(
                    'Key Insights',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...summary.insights.map((insight) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.arrow_right,
                              size: 20,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                insight,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],

                // Anomalies
                if (summary.anomalies.isNotEmpty) ...[
                  const Divider(),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.warning_amber,
                              color: Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Unusual Activity',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange[900],
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Detected ${summary.anomalies.length} unusual transaction${summary.anomalies.length > 1 ? 's' : ''} this period',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.orange[900],
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
      },
    );
  }

  Widget _buildConfidenceBadge(BuildContext context, int confidenceScore) {
    Color badgeColor;
    String badgeText;

    if (confidenceScore >= 80) {
      badgeColor = Colors.green;
      badgeText = 'High';
    } else if (confidenceScore >= 60) {
      badgeColor = Colors.orange;
      badgeText = 'Medium';
    } else {
      badgeColor = Colors.red;
      badgeText = 'Low';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified,
            size: 14,
            color: badgeColor,
          ),
          const SizedBox(width: 4),
          Text(
            badgeText,
            style: TextStyle(
              color: badgeColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
