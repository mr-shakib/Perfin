import 'dart:convert';
import '../models/budget.dart';
import '../models/goal.dart';
import '../models/recurring_expense.dart';
import '../models/spending_anomaly.dart';
import '../models/notification_preferences.dart';
import 'storage_service.dart';
import 'notification_helper.dart';

/// Service responsible for notification management
/// Handles sending notifications and managing user preferences
class NotificationService {
  final StorageService _storageService;
  final NotificationHelper _notificationHelper;

  static const String _notificationPreferencesKeyPrefix = 'notification_prefs_';
  static const String _notificationLogKeyPrefix = 'notification_log_';

  NotificationService(this._storageService, this._notificationHelper);

  /// Initialize the notification system
  /// Should be called when the app starts
  Future<void> initialize() async {
    await _notificationHelper.initialize();
  }

  /// Send budget alert notification
  /// Triggered when budget reaches 80% or exceeds 100%
  Future<void> sendBudgetAlert({
    required String userId,
    required Budget budget,
    required double utilizationPercentage,
  }) async {
    try {
      // Check if user has budget alerts enabled
      final prefs = await getNotificationPreferences(userId: userId);
      if (!prefs.budgetAlerts) {
        return;
      }

      // Check if we've already sent this notification recently
      final notificationKey =
          'budget_alert_${budget.id}_${utilizationPercentage.round()}';
      if (await _hasRecentNotification(userId, notificationKey)) {
        return;
      }

      // Determine alert level
      String title;
      String body;
      NotificationPriority priority;
      
      if (utilizationPercentage >= 100) {
        title = 'Budget Exceeded';
        body =
            'You have exceeded your budget for ${budget.id} by ${(utilizationPercentage - 100).toStringAsFixed(1)}%';
        priority = NotificationPriority.critical;
      } else {
        title = 'Budget Warning';
        body =
            'You have used ${utilizationPercentage.toStringAsFixed(1)}% of your budget for ${budget.id}';
        priority = NotificationPriority.high;
      }

      // Send notification
      await _sendNotification(
        userId: userId,
        title: title,
        body: body,
        notificationKey: notificationKey,
        priority: priority,
      );
    } catch (e) {
      throw NotificationServiceException(
          'Failed to send budget alert: ${e.toString()}');
    }
  }

  /// Send recurring expense reminder
  /// Triggered when recurring expense is due within 3 days
  Future<void> sendRecurringExpenseReminder({
    required String userId,
    required RecurringExpense expense,
    required int daysUntilDue,
  }) async {
    try {
      // Check if user has recurring expense reminders enabled
      final prefs = await getNotificationPreferences(userId: userId);
      if (!prefs.recurringExpenseReminders) {
        return;
      }

      // Check if we've already sent this notification recently
      final notificationKey = 'recurring_expense_${expense.id}_${expense.nextExpectedDate.toIso8601String()}';
      if (await _hasRecentNotification(userId, notificationKey)) {
        return;
      }

      // Create notification message
      final title = 'Upcoming Expense';
      final body = daysUntilDue == 0
          ? '${expense.description} is due today (\$${expense.averageAmount.toStringAsFixed(2)})'
          : '${expense.description} is due in $daysUntilDue day${daysUntilDue > 1 ? 's' : ''} (\$${expense.averageAmount.toStringAsFixed(2)})';

      // Send notification with priority based on urgency
      await _sendNotification(
        userId: userId,
        title: title,
        body: body,
        notificationKey: notificationKey,
        priority: daysUntilDue == 0
            ? NotificationPriority.high
            : NotificationPriority.medium,
      );
    } catch (e) {
      throw NotificationServiceException(
          'Failed to send recurring expense reminder: ${e.toString()}');
    }
  }

  /// Send goal deadline alert
  /// Triggered when user is behind schedule on a goal
  Future<void> sendGoalDeadlineAlert({
    required String userId,
    required Goal goal,
    required int daysRemaining,
  }) async {
    try {
      // Check if user has goal deadline alerts enabled
      final prefs = await getNotificationPreferences(userId: userId);
      if (!prefs.goalDeadlineAlerts) {
        return;
      }

      // Check if we've already sent this notification recently
      final notificationKey = 'goal_deadline_${goal.id}_${DateTime.now().toIso8601String().substring(0, 10)}';
      if (await _hasRecentNotification(userId, notificationKey)) {
        return;
      }

      // Calculate if behind schedule
      final progressPercentage = goal.progressPercentage;
      final totalDays = goal.targetDate.difference(goal.createdAt).inDays;
      final elapsedDays = DateTime.now().difference(goal.createdAt).inDays;
      final expectedProgress = totalDays > 0 ? (elapsedDays / totalDays) * 100 : 0;

      if (progressPercentage < expectedProgress) {
        // User is behind schedule
        final title = 'Goal Behind Schedule';
        final body =
            'Your goal "${goal.name}" is behind schedule. You need to save \$${goal.requiredMonthlySavings.toStringAsFixed(2)} per month to reach your target.';

        // Send notification
        await _sendNotification(
          userId: userId,
          title: title,
          body: body,
          notificationKey: notificationKey,
          priority: NotificationPriority.high,
        );
      }
    } catch (e) {
      throw NotificationServiceException(
          'Failed to send goal deadline alert: ${e.toString()}');
    }
  }

  /// Send unusual spending alert
  /// Triggered when anomaly is detected
  Future<void> sendUnusualSpendingAlert({
    required String userId,
    required SpendingAnomaly anomaly,
  }) async {
    try {
      // Check if user has unusual spending alerts enabled
      final prefs = await getNotificationPreferences(userId: userId);
      if (!prefs.unusualSpendingAlerts) {
        return;
      }

      // Check if we've already sent this notification recently
      final notificationKey = 'unusual_spending_${anomaly.transactionId}';
      if (await _hasRecentNotification(userId, notificationKey)) {
        return;
      }

      // Create notification message
      final title = 'Unusual Spending Detected';
      final body = anomaly.explanation;

      // Send notification
      await _sendNotification(
        userId: userId,
        title: title,
        body: body,
        notificationKey: notificationKey,
        priority: NotificationPriority.medium,
      );
    } catch (e) {
      throw NotificationServiceException(
          'Failed to send unusual spending alert: ${e.toString()}');
    }
  }

  /// Get notification preferences for a user
  Future<NotificationPreferences> getNotificationPreferences({
    required String userId,
  }) async {
    try {
      final key = _getNotificationPreferencesKey(userId);
      final prefsData = await _storageService.load<String>(key);

      if (prefsData == null) {
        // Return default preferences
        return NotificationPreferences(
          userId: userId,
          updatedAt: DateTime.now(),
        );
      }

      final Map<String, dynamic> json = jsonDecode(prefsData);
      return NotificationPreferences.fromJson(json);
    } catch (e) {
      throw NotificationServiceException(
          'Failed to get notification preferences: ${e.toString()}');
    }
  }

  /// Update notification preferences for a user
  Future<void> updateNotificationPreferences({
    required String userId,
    required NotificationPreferences preferences,
  }) async {
    try {
      final key = _getNotificationPreferencesKey(userId);
      final updatedPrefs = preferences.copyWith(
        updatedAt: DateTime.now(),
      );
      final jsonString = jsonEncode(updatedPrefs.toJson());
      await _storageService.save(key, jsonString);
    } catch (e) {
      throw NotificationServiceException(
          'Failed to update notification preferences: ${e.toString()}');
    }
  }

  /// Send a notification to the user's device
  /// Uses flutter_local_notifications to display system notifications
  Future<void> _sendNotification({
    required String userId,
    required String title,
    required String body,
    required String notificationKey,
    NotificationPriority priority = NotificationPriority.high,
  }) async {
    // Log the notification to prevent duplicates
    await _logNotification(userId, notificationKey);

    // Generate a unique notification ID from the key
    final notificationId = notificationKey.hashCode.abs();

    // Send the actual notification
    await _notificationHelper.showNotification(
      id: notificationId,
      title: title,
      body: body,
      payload: notificationKey,
      priority: priority,
    );
  }

  /// Check if a notification with this key was sent recently (within 24 hours)
  Future<bool> _hasRecentNotification(
      String userId, String notificationKey) async {
    try {
      final key = _getNotificationLogKey(userId);
      final logData = await _storageService.load<String>(key);

      if (logData == null) {
        return false;
      }

      final Map<String, dynamic> log = jsonDecode(logData);
      if (log.containsKey(notificationKey)) {
        final timestamp = DateTime.parse(log[notificationKey] as String);
        final hoursSince = DateTime.now().difference(timestamp).inHours;
        return hoursSince < 24;
      }

      return false;
    } catch (e) {
      // If there's an error reading the log, assume no recent notification
      return false;
    }
  }

  /// Log a notification to prevent duplicates
  Future<void> _logNotification(String userId, String notificationKey) async {
    try {
      final key = _getNotificationLogKey(userId);
      final logData = await _storageService.load<String>(key);

      Map<String, dynamic> log = {};
      if (logData != null) {
        log = jsonDecode(logData);
      }

      // Add new notification to log
      log[notificationKey] = DateTime.now().toIso8601String();

      // Clean up old entries (older than 7 days)
      final cutoffDate = DateTime.now().subtract(const Duration(days: 7));
      log.removeWhere((key, value) {
        final timestamp = DateTime.parse(value as String);
        return timestamp.isBefore(cutoffDate);
      });

      // Save updated log
      final jsonString = jsonEncode(log);
      await _storageService.save(key, jsonString);
    } catch (e) {
      // If logging fails, don't throw - notification was still sent
      // ignore: avoid_print
      print('Failed to log notification: ${e.toString()}');
    }
  }

  /// Get storage key for user's notification preferences
  String _getNotificationPreferencesKey(String userId) {
    return '$_notificationPreferencesKeyPrefix$userId';
  }

  /// Get storage key for user's notification log
  String _getNotificationLogKey(String userId) {
    return '$_notificationLogKeyPrefix$userId';
  }
}

/// Custom exception for notification service operations
class NotificationServiceException implements Exception {
  final String message;

  NotificationServiceException(this.message);

  @override
  String toString() => 'NotificationServiceException: $message';
}
