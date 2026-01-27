import 'package:flutter/material.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/currency_provider.dart';
import '../budget_management_screen.dart';
import '../category_management_screen.dart';
import '../privacy_settings_screen.dart';
import '../currency_settings_screen.dart';
import 'data_export_dialog.dart';
import 'account_deletion_dialog.dart';
import '../../../theme/app_colors.dart';
import 'package:provider/provider.dart';

/// Settings list - Clean Minimal Design
class SettingsList extends StatelessWidget {
  final AuthProvider authProvider;
  final ThemeProvider themeProvider;

  const SettingsList({
    super.key,
    required this.authProvider,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrencyProvider>(
      builder: (context, currencyProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSettingItem(
              context: context,
              icon: Icons.palette_outlined,
              title: 'Appearance',
              subtitle: _getThemeLabel(themeProvider.themeMode),
              onTap: () => _showThemeSelector(context),
            ),
            
            const SizedBox(height: 12),
            
            _buildSettingItem(
              context: context,
              icon: Icons.attach_money,
              title: 'Currency',
              subtitle: '${currencyProvider.currentCurrency.code} (${currencyProvider.currentCurrency.symbol})',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CurrencySettingsScreen(),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            _buildSettingItem(
              context: context,
              icon: Icons.account_balance_wallet_outlined,
              title: 'Manage Budgets',
              subtitle: 'Set spending limits',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BudgetManagementScreen(),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            _buildSettingItem(
              context: context,
              icon: Icons.category_outlined,
              title: 'Manage Categories',
              subtitle: 'Organize transactions',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CategoryManagementScreen(),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            _buildSettingItem(
              context: context,
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Settings',
              subtitle: 'Control your data',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacySettingsScreen(),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            _buildSettingItem(
              context: context,
              icon: Icons.download_outlined,
              title: 'Export Data',
              subtitle: 'Download your data',
              onTap: () => showDialog(
                context: context,
                builder: (context) => DataExportDialog(
                  userId: authProvider.user?.id ?? '',
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            _buildSettingItem(
              context: context,
              icon: Icons.delete_forever_outlined,
              title: 'Delete Account',
              subtitle: 'Permanently delete',
              onTap: () => showDialog(
                context: context,
                builder: (context) => AccountDeletionDialog(
                  userId: authProvider.user?.id ?? '',
                  authProvider: authProvider,
                ),
              ),
              isDestructive: true,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.creamLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFF0F0F0),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDestructive
                    ? const Color(0xFFFFF5F5)
                    : AppColors.creamCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDestructive
                    ? const Color(0xFFFF3B30)
                    : const Color(0xFF1A1A1A),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDestructive
                          ? const Color(0xFFFF3B30)
                          : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF999999),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFCCCCCC),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'Auto';
    }
  }

  void _showThemeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Theme',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 20),
              _buildThemeOption(
                context: context,
                icon: Icons.light_mode,
                label: 'Light',
                mode: ThemeMode.light,
              ),
              const SizedBox(height: 12),
              _buildThemeOption(
                context: context,
                icon: Icons.dark_mode,
                label: 'Dark',
                mode: ThemeMode.dark,
              ),
              const SizedBox(height: 12),
              _buildThemeOption(
                context: context,
                icon: Icons.settings_brightness,
                label: 'Auto',
                mode: ThemeMode.system,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required ThemeMode mode,
  }) {
    final isSelected = themeProvider.themeMode == mode;
    
    return GestureDetector(
      onTap: () {
        themeProvider.setTheme(mode);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A1A1A) : AppColors.creamCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
