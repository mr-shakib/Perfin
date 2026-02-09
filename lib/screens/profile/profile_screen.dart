import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../theme/app_colors.dart';
import 'widgets/profile_card.dart';
import 'widgets/settings_list.dart';

/// Profile screen - Clean Minimal Design
/// Requirements: 12.1-12.10
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final user = authProvider.user;

    // Load transactions when screen is accessed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (transactionProvider.transactions.isEmpty) {
        transactionProvider.loadTransactions();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: user == null
          ? const Center(
              child: Text('Please log in to view your profile'),
            )
          : CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // Minimal header with settings icon
                SliverToBoxAdapter(
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Profile',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                              letterSpacing: -0.5,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.06),
                                  blurRadius: 12,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.settings_outlined),
                              iconSize: 24,
                              color: AppColors.primary,
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Content
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 24),
                      
                      // Profile Card
                      ProfileCardElegant(
                        userName: user.name,
                        userEmail: user.email,
                        avatarUrl: 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user.name)}&size=128&background=667EEA&color=fff',
                        totalTransactions: transactionProvider.transactions.length,
                        accountBalance: transactionProvider.currentBalance,
                      ),
                      
                      const SizedBox(height: 32),

                      // Settings List
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SettingsList(
                          authProvider: authProvider,
                          themeProvider: themeProvider,
                        ),
                      ),
                      
                      const SizedBox(height: 24),

                      // Logout Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildLogoutButton(context, authProvider),
                      ),
                      
                      const SizedBox(height: 24),

                      // App Version
                      Center(
                        child: Text(
                          'Perfin v1.0.0',
                          style: TextStyle(
                            color: AppColors.neutral500,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return GestureDetector(
      onTap: () => _handleLogout(context, authProvider),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.error.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              color: AppColors.error,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              'Logout',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, AuthProvider authProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF666666),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF666666),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Color(0xFFFF3B30),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await authProvider.logout();
      
      // Navigate to login screen and clear navigation stack
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    }
  }
}
