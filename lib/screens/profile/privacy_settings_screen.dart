import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Full-screen view for privacy settings
/// Allows enabling/disabling AI features and notification preferences
class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  static const String _aiEnabledKey = 'ai_features_enabled';
  static const String _budgetAlertsKey = 'budget_alerts_enabled';
  static const String _recurringRemindersKey = 'recurring_reminders_enabled';
  static const String _goalAlertsKey = 'goal_alerts_enabled';
  static const String _unusualSpendingKey = 'unusual_spending_alerts_enabled';

  bool _isLoading = true;
  bool _aiEnabled = true;
  bool _budgetAlerts = true;
  bool _recurringReminders = true;
  bool _goalAlerts = true;
  bool _unusualSpendingAlerts = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _aiEnabled = prefs.getBool(_aiEnabledKey) ?? true;
        _budgetAlerts = prefs.getBool(_budgetAlertsKey) ?? true;
        _recurringReminders = prefs.getBool(_recurringRemindersKey) ?? true;
        _goalAlerts = prefs.getBool(_goalAlertsKey) ?? true;
        _unusualSpendingAlerts = prefs.getBool(_unusualSpendingKey) ?? true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _savePreference(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save preference'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // AI Features Section
                const Text(
                  'AI Features',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Enable AI Features'),
                        subtitle: const Text(
                          'AI-powered insights, predictions, and recommendations',
                        ),
                        value: _aiEnabled,
                        onChanged: (value) {
                          setState(() {
                            _aiEnabled = value;
                          });
                          _savePreference(_aiEnabledKey, value);
                        },
                      ),
                      if (!_aiEnabled)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'When AI features are disabled, you will only see '
                            'factual data and manual calculations.',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Notification Preferences Section
                const Text(
                  'Notification Preferences',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Budget Alerts'),
                        subtitle: const Text(
                          'Notify when approaching or exceeding budget limits',
                        ),
                        value: _budgetAlerts,
                        onChanged: (value) {
                          setState(() {
                            _budgetAlerts = value;
                          });
                          _savePreference(_budgetAlertsKey, value);
                        },
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: const Text('Recurring Expense Reminders'),
                        subtitle: const Text(
                          'Notify about upcoming recurring expenses',
                        ),
                        value: _recurringReminders,
                        onChanged: (value) {
                          setState(() {
                            _recurringReminders = value;
                          });
                          _savePreference(_recurringRemindersKey, value);
                        },
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: const Text('Goal Deadline Alerts'),
                        subtitle: const Text(
                          'Notify when behind schedule on financial goals',
                        ),
                        value: _goalAlerts,
                        onChanged: (value) {
                          setState(() {
                            _goalAlerts = value;
                          });
                          _savePreference(_goalAlertsKey, value);
                        },
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: const Text('Unusual Spending Alerts'),
                        subtitle: const Text(
                          'Notify about detected spending anomalies',
                        ),
                        value: _unusualSpendingAlerts,
                        onChanged: (value) {
                          setState(() {
                            _unusualSpendingAlerts = value;
                          });
                          _savePreference(_unusualSpendingKey, value);
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Privacy Information
                Card(
                  color: Colors.blue.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue[700],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Your Privacy',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your financial data is stored securely and never shared '
                          'with third parties. AI features process your data locally '
                          'and only use your own information for insights.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  /// Static method to check if AI features are enabled
  static Future<bool> isAIEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_aiEnabledKey) ?? true;
    } catch (e) {
      return true;
    }
  }

  /// Static method to check if a specific notification type is enabled
  static Future<bool> isNotificationEnabled(String type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      switch (type) {
        case 'budget':
          return prefs.getBool(_budgetAlertsKey) ?? true;
        case 'recurring':
          return prefs.getBool(_recurringRemindersKey) ?? true;
        case 'goal':
          return prefs.getBool(_goalAlertsKey) ?? true;
        case 'unusual':
          return prefs.getBool(_unusualSpendingKey) ?? true;
        default:
          return true;
      }
    } catch (e) {
      return true;
    }
  }
}
