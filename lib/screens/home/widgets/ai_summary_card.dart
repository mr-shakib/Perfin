import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/ai_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/currency_provider.dart';

/// Compact AI insight card with metrics-first hierarchy.
class AISummaryCard extends StatelessWidget {
  const AISummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AIProvider, CurrencyProvider>(
      builder: (context, aiProvider, currencyProvider, _) {
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

        final netFlow = summary.totalIncome - summary.totalSpending;

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2B3E5D), Color(0xFF35537D)],
                      ),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 17,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'AI Snapshot',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF172132),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F6FC),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: const Color(0xFFDCE6F5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${summary.confidenceScore}%',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3E516F),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildMetricPill(
                    icon: netFlow >= 0
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    label: 'Net',
                    value:
                        '${netFlow >= 0 ? '+' : '-'}${currencyProvider.formatWhole(netFlow.abs())}',
                    color: netFlow >= 0
                        ? const Color(0xFF2EA86F)
                        : const Color(0xFFD25A50),
                  ),
                  _buildMetricPill(
                    icon: Icons.pie_chart_rounded,
                    label: 'Top',
                    value: _truncate(summary.topSpendingCategory),
                    color: const Color(0xFF3E516F),
                  ),
                  _buildMetricPill(
                    icon: Icons.warning_amber_rounded,
                    label: 'Alerts',
                    value: '${summary.anomalies.length}',
                    color: summary.anomalies.isNotEmpty
                        ? const Color(0xFFC96B1A)
                        : const Color(0xFF2EA86F),
                  ),
                ],
              ),
              if (summary.insights.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: summary.insights
                      .take(2)
                      .map((insight) => _buildInsightChip(insight))
                      .toList(),
                ),
              ],
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 7,
                  value: (summary.confidenceScore / 100).clamp(0.0, 1.0),
                  backgroundColor: const Color(0xFFE6EBF4),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF3E628E),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricPill({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4EAF4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            '$label $value',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2B3D59),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightChip(String insight) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt_rounded, size: 14, color: Color(0xFF4A6387)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              _truncate(insight, maxChars: 52),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF4D596B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 140,
      decoration: _cardDecoration(),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF35537D),
              strokeWidth: 2.6,
            ),
            SizedBox(height: 12),
            Text(
              'Generating insights...',
              style: TextStyle(
                color: Color(0xFF657287),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Color(0xFF647083), size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'AI insights unavailable',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF647083),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsufficientDataCard(String message) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: Color(0xFF3E516F),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _truncate(message, maxChars: 68),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF647083),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _truncate(String value, {int maxChars = 18}) {
    final normalized = value.trim().replaceAll(RegExp(r'\\s+'), ' ');
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
