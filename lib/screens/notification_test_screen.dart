import 'package:flutter/material.dart';
import '../services/notification_helper.dart';
import '../models/budget.dart';
import '../models/goal.dart';
import '../models/recurring_expense.dart';
import '../models/spending_anomaly.dart';
import '../services/notification_service.dart';
import '../services/hive_storage_service.dart';

/// Test screen for sending notifications
/// Use this to verify the notification system is working
class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  late NotificationHelper _notificationHelper;
  late NotificationService _notificationService;
  bool _initialized = false;
  String _statusMessage = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      _notificationHelper = NotificationHelper();
      await _notificationHelper.initialize();

      final storageService = HiveStorageService();
      await storageService.init();

      _notificationService = NotificationService(storageService, _notificationHelper);
      await _notificationService.initialize();

      setState(() {
        _initialized = true;
        _statusMessage = 'Notification system ready!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: ${e.toString()}';
      });
    }
  }

  Future<void> _sendSimpleNotification() async {
    try {
      await _notificationHelper.showNotification(
        id: 1,
        title: '🎉 Test Notification',
        body: 'This is a simple test notification from Perfin!',
        priority: NotificationPriority.high,
      );
      _showSnackBar('Simple notification sent!');
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    }
  }

  Future<void> _sendBudgetWarning() async {
    try {
      final budget = Budget(
        id: 'test_budget',
        userId: 'test_user',
        amount: 1000,
        year: 2026,
        month: 1,
      );

      await _notificationService.sendBudgetAlert(
        userId: 'test_user',
        budget: budget,
        utilizationPercentage: 85.0,
      );
      _showSnackBar('Budget warning sent!');
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    }
  }

  Future<void> _sendBudgetExceeded() async {
    try {
      final budget = Budget(
        id: 'test_budget',
        userId: 'test_user',
        amount: 1000,
        year: 2026,
        month: 1,
      );

      await _notificationService.sendBudgetAlert(
        userId: 'test_user',
        budget: budget,
        utilizationPercentage: 105.0,
      );
      _showSnackBar('Budget exceeded alert sent!');
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    }
  }

  Future<void> _sendRecurringExpenseReminder() async {
    try {
      final expense = RecurringExpense(
        id: 'test_expense',
        categoryId: 'rent',
        description: 'Monthly Rent',
        averageAmount: 1200,
        frequencyDays: 30,
        lastOccurrence: DateTime.now().subtract(const Duration(days: 27)),
        nextExpectedDate: DateTime.now().add(const Duration(days: 3)),
        confidenceScore: 95,
        transactionIds: ['tx1', 'tx2'],
      );

      await _notificationService.sendRecurringExpenseReminder(
        userId: 'test_user',
        expense: expense,
        daysUntilDue: 3,
      );
      _showSnackBar('Recurring expense reminder sent!');
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    }
  }

  Future<void> _sendGoalAlert() async {
    try {
      final goal = Goal(
        id: 'test_goal',
        userId: 'test_user',
        name: 'Save for Vacation',
        targetAmount: 5000,
        currentAmount: 1000,
        targetDate: DateTime.now().add(const Duration(days: 180)),
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        updatedAt: DateTime.now(),
      );

      await _notificationService.sendGoalDeadlineAlert(
        userId: 'test_user',
        goal: goal,
        daysRemaining: 90,
      );
      _showSnackBar('Goal deadline alert sent!');
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    }
  }

  Future<void> _sendUnusualSpendingAlert() async {
    try {
      final anomaly = SpendingAnomaly(
        transactionId: 'test_tx',
        categoryId: 'dining',
        amount: 250,
        date: DateTime.now(),
        anomalyType: 'unusually_high',
        explanation: 'This transaction is 150% higher than your typical dining spending',
        deviationFromNormal: 150,
        confidenceScore: 85,
      );

      await _notificationService.sendUnusualSpendingAlert(
        userId: 'test_user',
        anomaly: anomaly,
      );
      _showSnackBar('Unusual spending alert sent!');
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    }
  }

  Future<void> _sendScheduledNotification() async {
    try {
      final scheduledTime = DateTime.now().add(const Duration(seconds: 10));
      await _notificationHelper.scheduleNotification(
        id: 100,
        title: '⏰ Scheduled Notification',
        body: 'This notification was scheduled 10 seconds ago!',
        scheduledDate: scheduledTime,
        priority: NotificationPriority.high,
      );
      _showSnackBar('Notification scheduled for 10 seconds from now!');
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Test'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _initialized
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 48),
                          const SizedBox(height: 8),
                          Text(
                            _statusMessage,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Tap any button to send a test notification:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildTestButton(
                    icon: Icons.notifications,
                    label: 'Simple Test Notification',
                    color: Colors.blue,
                    onPressed: _sendSimpleNotification,
                  ),
                  const SizedBox(height: 12),
                  _buildTestButton(
                    icon: Icons.warning_amber,
                    label: 'Budget Warning (80%)',
                    color: Colors.orange,
                    onPressed: _sendBudgetWarning,
                  ),
                  const SizedBox(height: 12),
                  _buildTestButton(
                    icon: Icons.error,
                    label: 'Budget Exceeded (105%)',
                    color: Colors.red,
                    onPressed: _sendBudgetExceeded,
                  ),
                  const SizedBox(height: 12),
                  _buildTestButton(
                    icon: Icons.calendar_today,
                    label: 'Recurring Expense Reminder',
                    color: Colors.purple,
                    onPressed: _sendRecurringExpenseReminder,
                  ),
                  const SizedBox(height: 12),
                  _buildTestButton(
                    icon: Icons.flag,
                    label: 'Goal Deadline Alert',
                    color: Colors.teal,
                    onPressed: _sendGoalAlert,
                  ),
                  const SizedBox(height: 12),
                  _buildTestButton(
                    icon: Icons.trending_up,
                    label: 'Unusual Spending Alert',
                    color: Colors.deepOrange,
                    onPressed: _sendUnusualSpendingAlert,
                  ),
                  const SizedBox(height: 12),
                  _buildTestButton(
                    icon: Icons.schedule,
                    label: 'Scheduled Notification (10s)',
                    color: Colors.indigo,
                    onPressed: _sendScheduledNotification,
                  ),
                  const SizedBox(height: 24),
                  const Card(
                    color: Colors.blue,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Icon(Icons.info, color: Colors.white),
                          SizedBox(height: 8),
                          Text(
                            'Check your notification tray to see the notifications!',
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_statusMessage),
                ],
              ),
            ),
    );
  }

  Widget _buildTestButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
