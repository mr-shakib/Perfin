import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/currency_provider.dart';
import 'edit_profile_form.dart';

/// User info section - Enhanced Profile Card Design
class UserInfoSection extends StatelessWidget {
  final User user;

  const UserInfoSection({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final currentBalance = transactionProvider.currentBalance;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE6E3DB), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B2430).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2D4668), Color(0xFF456892)],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Center(
                  child: Text(
                    _getInitials(user.name),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A2333),
                        letterSpacing: -0.2,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF768096),
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 4),
                    Text(
                      'Member since ${_formatMemberSince(user.createdAt)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF8A93A4),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Material(
                color: const Color(0xFFF5F3ED),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => _showEditProfileDialog(context),
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.edit_rounded,
                      size: 17,
                      color: Color(0xFF41506A),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'Balance',
                  value: currencyProvider.formatWhole(currentBalance),
                  valueColor: currentBalance >= 0
                      ? const Color(0xFF2EA86F)
                      : const Color(0xFFD25A50),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  label: 'Income',
                  value: currencyProvider.formatWhole(
                    transactionProvider.totalIncome,
                  ),
                  valueColor: const Color(0xFF2EA86F),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  label: 'Expenses',
                  value: currencyProvider.formatWhole(
                    transactionProvider.totalExpense,
                  ),
                  valueColor: const Color(0xFFD25A50),
                ),
              ),
            ],
          ),
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

  String _formatMemberSince(DateTime createdAt) {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F7F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEBE6DB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF758198),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: valueColor,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
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
