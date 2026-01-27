import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../models/trend_data_point.dart';

/// Widget displaying spending trend over time as a line chart
/// Requirements: 3.7
class SpendingTrendChart extends StatelessWidget {
  final List<TrendDataPoint> trendData;
  final String periodLabel;

  const SpendingTrendChart({
    super.key,
    required this.trendData,
    this.periodLabel = 'Spending Trend',
  });

  @override
  Widget build(BuildContext context) {
    if (trendData.isEmpty) {
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
          Text(
            periodLabel,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              _buildLineChartData(),
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _buildLineChartData() {
    final sortedData = List<TrendDataPoint>.from(trendData)
      ..sort((a, b) => a.date.compareTo(b.date));

    final maxY = sortedData.map((d) => d.amount).reduce((a, b) => a > b ? a : b);
    final minY = 0.0;

    final spots = sortedData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.amount);
    }).toList();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY / 4,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xFFE0E0E0),
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
            interval: _getBottomInterval(sortedData.length),
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= sortedData.length) {
                return const Text('');
              }
              return _buildBottomTitle(sortedData[index].date);
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            interval: maxY / 4,
            getTitlesWidget: (value, meta) {
              return Text(
                '\$${_formatAmount(value)}',
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF666666),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          left: BorderSide(color: Color(0xFFE0E0E0)),
          bottom: BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
      minX: 0,
      maxX: (sortedData.length - 1).toDouble(),
      minY: minY,
      maxY: maxY * 1.1, // Add 10% padding at top
      lineBarsData: [
        LineChartBarData(
          spots: spots,
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
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((spot) {
              final index = spot.x.toInt();
              if (index < 0 || index >= sortedData.length) {
                return null;
              }
              final dataPoint = sortedData[index];
              return LineTooltipItem(
                '\$${dataPoint.amount.toStringAsFixed(2)}\n${DateFormat('MMM d').format(dataPoint.date)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  Widget _buildBottomTitle(DateTime date) {
    final format = DateFormat('MMM d');
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        format.format(date),
        style: const TextStyle(
          fontSize: 10,
          color: Color(0xFF666666),
        ),
      ),
    );
  }

  double _getBottomInterval(int dataLength) {
    if (dataLength <= 7) {
      return 1;
    } else if (dataLength <= 14) {
      return 2;
    } else if (dataLength <= 30) {
      return 5;
    } else {
      return 10;
    }
  }

  String _formatAmount(double amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}k';
    }
    return amount.toStringAsFixed(0);
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
              Icons.show_chart,
              size: 48,
              color: Color(0xFF999999),
            ),
            SizedBox(height: 16),
            Text(
              'No trend data',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF666666),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add more transactions to see spending trends',
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
