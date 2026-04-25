import 'package:flutter/material.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/currency_provider.dart';
import '../../../providers/subscription_provider.dart';
import '../../../providers/on_device_ai_provider.dart';
import '../../../screens/settings/on_device_ai_settings_screen.dart';
import '../budget_management_screen.dart';
import '../category_management_screen.dart';
import '../privacy_settings_screen.dart';
import '../currency_settings_screen.dart';
import 'data_export_dialog.dart';
import 'account_deletion_dialog.dart';
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
    return Consumer2<CurrencyProvider, SubscriptionProvider>(
      builder: (context, currencyProvider, subscriptionProvider, _) {
        final onDevice = context.watch<OnDeviceAIProvider>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Personalization'),
            const SizedBox(height: 10),
            _buildSettingItem(
              context: context,
              icon: Icons.palette_outlined,
              title: 'Appearance',
              subtitle: _getThemeLabel(themeProvider.themeMode),
              onTap: () => _showThemeSelector(context),
            ),
            const SizedBox(height: 10),
            _buildSettingItem(
              context: context,
              icon: Icons.attach_money_rounded,
              title: 'Currency',
              subtitle:
                  '${currencyProvider.currentCurrency.code} (${currencyProvider.currentCurrency.symbol})',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CurrencySettingsScreen(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildSettingItem(
              context: context,
              icon: Icons.workspace_premium_outlined,
              title: 'Subscription',
              subtitle: '${subscriptionProvider.currentPlan.displayName} plan',
              onTap: () => Navigator.pushNamed(context, '/subscription'),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('AI'),
            const SizedBox(height: 10),
            _buildSettingItem(
              context: context,
              icon: Icons.phone_android_outlined,
              title: 'On-Device AI',
              subtitle: onDevice.isModelLoaded
                  ? 'Active — ${onDevice.loadedModelId}'
                  : 'Download a model for offline AI',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const OnDeviceAISettingsScreen(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Finance Tools'),
            const SizedBox(height: 10),
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
            const SizedBox(height: 10),
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
            const SizedBox(height: 10),
            _buildSettingItem(
              context: context,
              icon: Icons.download_outlined,
              title: 'Export Data',
              subtitle: 'Download your data',
              onTap: () => showDialog(
                context: context,
                builder: (context) =>
                    DataExportDialog(userId: authProvider.user?.id ?? ''),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Privacy & Security'),
            const SizedBox(height: 10),
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
            const SizedBox(height: 10),
            _buildSettingItem(
              context: context,
              icon: Icons.delete_forever_outlined,
              title: 'Delete Account',
              subtitle: 'Permanently delete',
              onTap: () => showDialog(
                context: context,
                builder: (context) =>
                    AccountDeletionDialog(authProvider: authProvider),
              ),
              isDestructive: true,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF7B808A),
        letterSpacing: 0.3,
      ),
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
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDestructive
                  ? const Color(0xFFF1D9D6)
                  : const Color(0xFFE7E4DA),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1B2430).withValues(alpha: 0.07),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDestructive
                      ? const Color(0xFFFFF2F0)
                      : const Color(0xFFF6F3EB),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: isDestructive
                      ? const Color(0xFFD25A50)
                      : const Color(0xFF1A2333),
                  size: 19,
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
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDestructive
                            ? const Color(0xFFD25A50)
                            : const Color(0xFF1A2333),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7B808A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFADB3BE),
                size: 20,
              ),
            ],
          ),
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
      backgroundColor: const Color(0xFFFFFCF6),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Theme',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A2333),
                ),
              ),
              const SizedBox(height: 16),
              _buildThemeOption(
                context: context,
                icon: Icons.light_mode,
                label: 'Light',
                mode: ThemeMode.light,
              ),
              const SizedBox(height: 10),
              _buildThemeOption(
                context: context,
                icon: Icons.dark_mode,
                label: 'Dark',
                mode: ThemeMode.dark,
              ),
              const SizedBox(height: 10),
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF24354F) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFFE7E4DA),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF1A2333),
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF1A2333),
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}
