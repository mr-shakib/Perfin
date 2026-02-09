import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/currency_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../theme/app_colors.dart';

/// Financial Summary Card - Modern Card Design
/// Requirements: 1.1-1.3
class FinancialSummaryCard extends StatelessWidget {
  const FinancialSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<TransactionProvider, CurrencyProvider, AuthProvider>(
      builder: (context, transactionProvider, currencyProvider, authProvider, _) {
        final summary = transactionProvider.currentMonthSummary;
        final currentBalance = transactionProvider.currentBalance;
        final userName = authProvider.user?.name ?? 'User';
        final firstName = userName.split(' ').first;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.creamCard,
                AppColors.creamLight,
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.06),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            firstName[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Hi, $firstName!',
                        style: const TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.visibility_outlined,
                      color: Color(0xFF1A1A1A),
                      size: 20,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              const Text(
                'Total Balance',
                style: TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                currencyProvider.format(currentBalance),
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.5,
                  height: 1.2,
                ),
              ),
              
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: _buildStat(
                      'Income',
                      summary.totalIncome,
                      AppColors.success,
                      Icons.arrow_downward_rounded,
                      currencyProvider,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStat(
                      'Expenses',
                      summary.totalExpense,
                      AppColors.error,
                      Icons.arrow_upward_rounded,
                      currencyProvider,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStat(String label, double amount, Color color, IconData icon, CurrencyProvider currencyProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currencyProvider.formatWhole(amount),
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
