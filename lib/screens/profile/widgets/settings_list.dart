import 'package:flutter/material.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/currency_provider.dart';
import '../../../services/sync_service.dart';
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
            
            const SizedBox(height: 16),
            
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
            
            const SizedBox(height: 16),
            
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
            
            const SizedBox(height: 16),
            
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
            
            const SizedBox(height: 16),
            
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
            
            const SizedBox(height: 16),
            
            _buildSyncButton(
              context: context,
              userId: authProvider.user?.id ?? '',
            ),
            
            const SizedBox(height: 16),
            
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
            
            const SizedBox(height: 16),
            
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
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColors.error.withOpacity(0.1)
                    : AppColors.creamLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isDestructive
                    ? AppColors.error
                    : AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
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
                          ? AppColors.error
                          : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.neutral500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.neutral400,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncButton({
    required BuildContext context,
    required String userId,
  }) {
    final syncService = Provider.of<SyncService>(context, listen: false);
    
    return FutureBuilder<Map<String, dynamic>>(
      future: syncService.getSyncStatus(),
      builder: (context, snapshot) {
        final syncStatus = snapshot.data;
        final pendingCount = syncStatus?['pendingCount'] ?? 0;
        final failedCount = syncStatus?['failedCount'] ?? 0;
        
        String subtitle;
        if (snapshot.connectionState == ConnectionState.waiting) {
          subtitle = 'Loading status...';
        } else if (pendingCount > 0) {
          subtitle = '$pendingCount pending • Tap to sync';
        } else if (failedCount > 0) {
          subtitle = '$failedCount failed • Tap to retry';
        } else {
          subtitle = 'All data synced';
        }
        
        return _buildSyncActionButton(
          context: context,
          userId: userId,
          subtitle: subtitle,
          hasPendingOrFailed: pendingCount > 0 || failedCount > 0,
        );
      },
    );
  }

  Widget _buildSyncActionButton({
    required BuildContext context,
    required String userId,
    required String subtitle,
    required bool hasPendingOrFailed,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isSyncing = false;
        
        return GestureDetector(
          onTap: isSyncing ? null : () async {
            if (userId.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please log in to sync data'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }
            
            setState(() => isSyncing = true);
            
            try {
              final syncService = Provider.of<SyncService>(context, listen: false);
              
              // Push local changes to Supabase
              final result = await syncService.forceSyncAll(userId: userId);
              
              // Pull latest data from Supabase
              try {
                await syncService.pullFromSupabase(userId);
              } catch (e) {
                debugPrint('Failed to pull from Supabase: $e');
              }
              
              if (context.mounted) {
                if (result.failureCount > 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Synced ${result.successCount} items, ${result.failureCount} failed',
                      ),
                      backgroundColor: Colors.orange,
                      action: SnackBarAction(
                        label: 'Retry',
                        textColor: Colors.white,
                        onPressed: () {},
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✓ Successfully synced all data'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
                setState(() => isSyncing = false);
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Sync failed: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
                setState(() => isSyncing = false);
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: hasPendingOrFailed 
                  ? AppColors.warning.withOpacity(0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: hasPendingOrFailed
                        ? AppColors.warning.withOpacity(0.15)
                        : AppColors.creamLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: isSyncing
                      ? Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                hasPendingOrFailed
                                    ? AppColors.warning
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                        )
                      : Icon(
                          Icons.sync_rounded,
                          color: hasPendingOrFailed
                              ? AppColors.warning
                              : AppColors.primary,
                          size: 22,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sync Data',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: hasPendingOrFailed
                              ? AppColors.warning
                              : const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isSyncing ? 'Syncing...' : subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.neutral500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSyncing ? Icons.hourglass_empty_rounded : Icons.chevron_right_rounded,
                  color: AppColors.neutral400,
                  size: 24,
                ),
              ],
            ),
          ),
        );
      },
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
