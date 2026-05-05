import 'package:flutter/material.dart';
import '../../transactions/add_transaction_screen.dart';
import '../../budget/manage_budget_screen.dart';
import '../../insights/insights_screen.dart';
import '../../../theme/app_colors.dart';

/// Quick action row with icon-first compact cards.
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
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    final isPrimary = backgroundColor == const Color(0xFF24354F);

    return Container(
      height: 98,
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
            ).withValues(alpha: isPrimary ? 0.16 : 0.07),
            blurRadius: isPrimary ? 18 : 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isPrimary
                        ? Colors.white.withValues(alpha: 0.2)
                        : AppColors.creamCard,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 21),
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: isPrimary ? Colors.white : const Color(0xFF1A2333),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
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
