import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

/// Time period options for insights filtering
enum TimePeriod {
  currentMonth,
  lastMonth,
  last3Months,
  last6Months,
  lastYear,
}

/// Extension to get display text for time periods
extension TimePeriodExtension on TimePeriod {
  String get displayText {
    switch (this) {
      case TimePeriod.currentMonth:
        return 'Current Month';
      case TimePeriod.lastMonth:
        return 'Last Month';
      case TimePeriod.last3Months:
        return 'Last 3 Months';
      case TimePeriod.last6Months:
        return 'Last 6 Months';
      case TimePeriod.lastYear:
        return 'Last Year';
    }
  }
}

/// Widget for selecting time period for insights
/// Requirements: 3.2-3.4
class TimePeriodSelector extends StatelessWidget {
  final TimePeriod selectedPeriod;
  final ValueChanged<TimePeriod?> onChanged;

  const TimePeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.creamLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TimePeriod>(
          value: selectedPeriod,
          onChanged: onChanged,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFF1A1A1A),
          ),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          items: TimePeriod.values.map((period) {
            return DropdownMenuItem<TimePeriod>(
              value: period,
              child: Text(period.displayText),
            );
          }).toList(),
        ),
      ),
    );
  }
}
