import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../models/goal.dart';
import '../../../providers/currency_provider.dart';

/// Line chart showing goal progress over time
/// Requirements: 9.1-9.12
class GoalProgressChart extends StatelessWidget {
  final Goal goal;

  const GoalProgressChart({
    super.key,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrencyProvider>(
      builder: (context, currencyProvider, _) {
    // Generate progress data points
    final progressData = _generateProgressData();

    if (progressData.isEmpty) {
      return _buildEmptyState();
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
          const Text(
            'Progress Over Time',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: goal.targetAmount / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0xFFE5E5E5),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        return _buildBottomTitle(value.toInt(), progressData.length);
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      interval: goal.targetAmount / 4,
                      getTitlesWidget: (value, meta) {
                        return _buildLeftTitle(value, currencyProvider);
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: const Color(0xFFE5E5E5),
                    width: 1,
                  ),
                ),
                minX: 0,
                maxX: (progressData.length - 1).toDouble(),
                minY: 0,
                maxY: goal.targetAmount * 1.1, // Add 10% padding
                lineBarsData: [
                  // Target line
                  LineChartBarData(
                    spots: _generateTargetLine(progressData.length),
                    isCurved: false,
                    color: const Color(0xFFE5E5E5),
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    dashArray: [5, 5],
                  ),
                  // Actual progress line
                  LineChartBarData(
                    spots: progressData,
                    isCurved: true,
                    color: const Color(0xFF1A1A1A),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: const Color(0xFF1A1A1A),
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF1A1A1A).withOpacity(0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => const Color(0xFF1A1A1A),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        if (spot.barIndex == 1) {
                          // Only show tooltip for actual progress line
                          return LineTooltipItem(
                            currencyProvider.formatWhole(spot.y),
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }
                        return null;
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(
                color: const Color(0xFF1A1A1A),
                label: 'Actual Progress',
              ),
              const SizedBox(width: 24),
              _buildLegendItem(
                color: const Color(0xFFE5E5E5),
                label: 'Target',
                isDashed: true,
              ),
            ],
          ),
        ],
      ),
    );
      },
    );
  }

  Widget _buildEmptyState() {
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
        child: Text(
          'No progress data yet',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomTitle(int index, int totalPoints) {
    if (index == 0) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text(
          'Start',
          style: TextStyle(
            fontSize: 10,
            color: Color(0xFF666666),
          ),
        ),
      );
    } else if (index == totalPoints - 1) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text(
          'Now',
          style: TextStyle(
            fontSize: 10,
            color: Color(0xFF666666),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildLeftTitle(double value, CurrencyProvider currencyProvider) {
    if (value == 0) {
      return Text(
        '${currencyProvider.currentCurrency.symbol}0',
        style: const TextStyle(
          fontSize: 10,
          color: Color(0xFF666666),
        ),
      );
    }
    
    final k = value / 1000;
    if (k >= 1) {
      return Text(
        '${currencyProvider.currentCurrency.symbol}${k.toStringAsFixed(0)}k',
        style: const TextStyle(
          fontSize: 10,
          color: Color(0xFF666666),
        ),
      );
    }
    
    return Text(
      currencyProvider.formatWhole(value),
      style: const TextStyle(
        fontSize: 10,
        color: Color(0xFF666666),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    bool isDashed = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF666666),
          ),
        ),
      ],
    );
  }

  List<FlSpot> _generateProgressData() {
    // For now, generate a simple progress line from creation to current
    // In a real implementation, this would use historical progress data
    final spots = <FlSpot>[];
    
    // Start point (creation date)
    spots.add(const FlSpot(0, 0));
    
    // Current point
    spots.add(FlSpot(1, goal.currentAmount));
    
    return spots;
  }

  List<FlSpot> _generateTargetLine(int points) {
    // Generate a straight line from 0 to target amount
    return [
      const FlSpot(0, 0),
      FlSpot((points - 1).toDouble(), goal.targetAmount),
    ];
  }
}
