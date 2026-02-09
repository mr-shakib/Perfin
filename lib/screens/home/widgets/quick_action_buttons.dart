import 'package:flutter/material.dart';
import '../../transactions/add_transaction_screen.dart';
import '../../budget/manage_budget_screen.dart';
import '../../insights/insights_screen.dart';
import '../../../theme/app_colors.dart';

/// Quick Action Buttons - Modern Circular Design
/// Requirements: 1.9
class QuickActionButtons extends StatelessWidget {
  const QuickActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          context,
          'Add',
          Icons.add_rounded,
          AppColors.primary,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddTransactionScreen(),
              ),
            );
          },
        ),
        _buildActionButton(
          context,
          'Transfer',
          Icons.swap_horiz_rounded,
          AppColors.secondary,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddTransactionScreen(),
              ),
            );
          },
        ),
        _buildActionButton(
          context,
          'Insights',
          Icons.bar_chart_rounded,
          AppColors.info,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const InsightsScreen(),
              ),
            );
          },
        ),
        _buildActionButton(
          context,
          'Budget',
          Icons.account_balance_wallet_rounded,
          AppColors.warning,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ManageBudgetScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(32),
              child: Center(
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
