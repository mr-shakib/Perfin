import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/currency_provider.dart';
import '../../../theme/app_colors.dart';
import 'edit_profile_form.dart';

/// User info section - Modern Card Design
class UserInfoSection extends StatelessWidget {
  final User user;

  const UserInfoSection({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with gradient background
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Gradient Header
              Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primaryDark,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () => _showEditProfileDialog(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Overlapping Avatar
              Positioned(
                left: 0,
                right: 0,
                bottom: -40,
                child: Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 5,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.secondary,
                          AppColors.secondary.withOpacity(0.8),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _getInitials(user.name),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 52),

          // Stats Row (3 columns)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatColumn(
                    label: 'Balance',
                    value: _formatValue(transactionProvider.currentBalance),
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.neutral200,
                ),
                Expanded(
                  child: _buildStatColumn(
                    label: 'Income',
                    value: _formatValue(transactionProvider.totalIncome),
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.neutral200,
                ),
                Expanded(
                  child: _buildStatColumn(
                    label: 'Expenses',
                    value: _formatValue(transactionProvider.totalExpense),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // User Name
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 4),

          // Email / subtitle
          Text(
            user.email,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.neutral500,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';

    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }

    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  String _formatValue(double value) {
    if (value.abs() >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value.abs() >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  Widget _buildStatColumn({
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.neutral500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: EditProfileForm(user: user),
      ),
    );
  }
}
