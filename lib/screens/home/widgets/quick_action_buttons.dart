import 'package:flutter/material.dart';
import '../../transactions/add_transaction_screen.dart';
import '../../budget/manage_budget_screen.dart';
import '../../insights/insights_screen.dart';
import '../../../theme/app_colors.dart';

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
            label: 'Add',
            subtitle: 'Transaction',
            icon: Icons.add_rounded,
            iconColor: Colors.white,
            backgroundColor: const Color(0xFF24354F),
            onTap: () {
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
            label: 'Insights',
            subtitle: 'AI trends',
            icon: Icons.insights_rounded,
            iconColor: const Color(0xFF24354F),
            backgroundColor: Colors.white,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InsightsScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildButton(
            context,
            label: 'Budget',
            subtitle: 'Limits',
            icon: Icons.pie_chart_outline_rounded,
            iconColor: const Color(0xFF24354F),
            backgroundColor: Colors.white,
            onTap: () {
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
    BuildContext context, {
    required String label,
    required String subtitle,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    final isPrimary = backgroundColor == const Color(0xFF24354F);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPrimary ? Colors.transparent : const Color(0xFFE4E2DA),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF1D2430,
            ).withValues(alpha: isPrimary ? 0.18 : 0.08),
            blurRadius: isPrimary ? 20 : 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isPrimary
                        ? Colors.white.withValues(alpha: 0.2)
                        : AppColors.creamCard,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(height: 14),
                Text(
                  label,
                  style: TextStyle(
                    color: isPrimary ? Colors.white : const Color(0xFF1A2333),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isPrimary
                        ? const Color(0xFFD5E0F2)
                        : const Color(0xFF7B808A),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
