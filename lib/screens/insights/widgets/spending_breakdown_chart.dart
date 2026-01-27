import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Widget displaying spending breakdown by category as a pie chart
/// Requirements: 3.1, 3.5-3.6
class SpendingBreakdownChart extends StatefulWidget {
  final Map<String, double> spendingByCategory;
  final VoidCallback? onTapCategory;

  const SpendingBreakdownChart({
    super.key,
    required this.spendingByCategory,
    this.onTapCategory,
  });

  @override
  State<SpendingBreakdownChart> createState() => _SpendingBreakdownChartState();
}

class _SpendingBreakdownChartState extends State<SpendingBreakdownChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.spendingByCategory.isEmpty) {
      return _buildEmptyState();
    }

    final totalSpending = widget.spendingByCategory.values.fold(0.0, (sum, amount) => sum + amount);

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
          const Text(
            'Spending by Category',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              _touchedIndex = -1;
                              return;
                            }
                            _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      sections: _buildPieChartSections(totalSpending),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 2,
                  child: _buildLegend(totalSpending),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(double totalSpending) {
    final sortedEntries = widget.spendingByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final colors = _getCategoryColors();

    return sortedEntries.asMap().entries.map((entry) {
      final index = entry.key;
      final categoryEntry = entry.value;
      final percentage = (categoryEntry.value / totalSpending) * 100;
      final isTouched = index == _touchedIndex;

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: categoryEntry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: isTouched ? 70 : 60,
        titleStyle: TextStyle(
          fontSize: isTouched ? 16 : 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        badgeWidget: isTouched
            ? Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  categoryEntry.key,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              )
            : null,
        badgePositionPercentageOffset: 1.3,
      );
    }).toList();
  }

  Widget _buildLegend(double totalSpending) {
    final sortedEntries = widget.spendingByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final colors = _getCategoryColors();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sortedEntries.asMap().entries.map((entry) {
          final index = entry.key;
          final categoryEntry = entry.value;
          final percentage = (categoryEntry.value / totalSpending) * 100;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colors[index % colors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryEntry.key,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '\$${categoryEntry.value.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
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
              Icons.pie_chart_outline,
              size: 48,
              color: Color(0xFF999999),
            ),
            SizedBox(height: 16),
            Text(
              'No spending data',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF666666),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add transactions to see your spending breakdown',
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

  List<Color> _getCategoryColors() {
    return [
      const Color(0xFF1A1A1A), // Black
      const Color(0xFF4A90E2), // Blue
      const Color(0xFF50C878), // Green
      const Color(0xFFFF6B6B), // Red
      const Color(0xFFFFA500), // Orange
      const Color(0xFF9B59B6), // Purple
      const Color(0xFF3498DB), // Light Blue
      const Color(0xFFE74C3C), // Dark Red
      const Color(0xFF2ECC71), // Light Green
      const Color(0xFFF39C12), // Yellow
    ];
  }
}
