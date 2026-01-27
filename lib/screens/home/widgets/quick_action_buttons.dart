import 'package:flutter/material.dart';
import '../../transactions/add_transaction_screen.dart';
import '../../budget/manage_budget_screen.dart';
import '../../../screens/main_dashboard.dart';

/// Quick Action Buttons - Clean Minimal Design
/// Requirements: 1.9
class QuickActionButtons extends StatelessWidget {
  const QuickActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildButton(
            context,
            'Add',
            Icons.add,
            const Color(0xFF1A1A1A),
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddTransactionScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildButton(
            context,
            'Stats',
            Icons.bar_chart,
            const Color(0xFFF5F5F5),
            () {
              // Switch to Insights tab (index 1)
              MainDashboard.switchTab(context, 1);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildButton(
            context,
            'Budget',
            Icons.pie_chart_outline,
            const Color(0xFFF5F5F5),
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageBudgetScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildButton(
    BuildContext context,
    String label,
    IconData icon,
    Color bgColor,
    VoidCallback? onTap,
  ) {
    final isDark = bgColor == const Color(0xFF1A1A1A);
    
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(
                icon,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
