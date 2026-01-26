# Notification System Usage Guide

## Overview

The notification system is now fully implemented with actual phone notifications using `flutter_local_notifications`. This guide shows how to initialize and use the notification system.

## Setup

### 1. Initialize in main.dart

Add the notification service initialization to your `main()` function:

```dart
import 'services/notification_helper.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ... existing initialization code ...
  
  // Initialize notification system
  final notificationHelper = NotificationHelper();
  final notificationService = NotificationService(storageService, notificationHelper);
  await notificationService.initialize();
  
  runApp(MyApp(
    // ... pass notificationService to your app ...
  ));
}
```

### 2. Android Configuration

Add to `android/app/src/main/AndroidManifest.xml` inside the `<application>` tag:

```xml
<!-- Notification permissions for Android 13+ -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

<!-- Notification channel -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="perfin_channel" />
```

### 3. iOS Configuration

Add to `ios/Runner/Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

## Usage Examples

### Send Budget Alert

```dart
final notificationService = NotificationService(storageService, notificationHelper);

// When budget reaches 80%
await notificationService.sendBudgetAlert(
  userId: 'user123',
  budget: budget,
  utilizationPercentage: 85.0,
);

// When budget is exceeded
await notificationService.sendBudgetAlert(
  userId: 'user123',
  budget: budget,
  utilizationPercentage: 105.0,
);
```

### Send Recurring Expense Reminder

```dart
// Reminder 3 days before
await notificationService.sendRecurringExpenseReminder(
  userId: 'user123',
  expense: recurringExpense,
  daysUntilDue: 3,
);

// Reminder on the day
await notificationService.sendRecurringExpenseReminder(
  userId: 'user123',
  expense: recurringExpense,
  daysUntilDue: 0,
);
```

### Send Goal Deadline Alert

```dart
await notificationService.sendGoalDeadlineAlert(
  userId: 'user123',
  goal: goal,
  daysRemaining: 30,
);
```

### Send Unusual Spending Alert

```dart
await notificationService.sendUnusualSpendingAlert(
  userId: 'user123',
  anomaly: spendingAnomaly,
);
```

### Manage User Preferences

```dart
// Get current preferences
final prefs = await notificationService.getNotificationPreferences(
  userId: 'user123',
);

// Update preferences
final updatedPrefs = prefs.copyWith(
  budgetAlerts: false,
  recurringExpenseReminders: true,
  goalDeadlineAlerts: true,
  unusualSpendingAlerts: true,
);

await notificationService.updateNotificationPreferences(
  userId: 'user123',
  preferences: updatedPrefs,
);
```

## Features

### ✅ Implemented Features

1. **Budget Alerts**
   - Warning at 80% utilization (high priority)
   - Critical alert at 100%+ utilization (critical priority)

2. **Recurring Expense Reminders**
   - Medium priority for 1-3 days before
   - High priority on the day of expense

3. **Goal Deadline Alerts**
   - Alerts when user is behind schedule
   - Shows required monthly savings to get back on track

4. **Unusual Spending Alerts**
   - Notifies about detected anomalies
   - Includes explanation of the unusual pattern

5. **User Preferences**
   - Individual toggles for each notification type
   - Persisted to local storage

6. **Duplicate Prevention**
   - 24-hour window to prevent spam
   - Automatic cleanup of old notification logs

7. **Priority Levels**
   - Low, Medium, High, Critical
   - Affects notification importance and sound

## Notification Priorities

- **Critical**: Budget exceeded (>100%)
- **High**: Budget warning (80-100%), Goal behind schedule, Expense due today
- **Medium**: Recurring expense reminder (1-3 days), Unusual spending
- **Low**: General informational notifications

## Testing

To test notifications in development:

```dart
// Send a test notification
await notificationHelper.showNotification(
  id: 1,
  title: 'Test Notification',
  body: 'This is a test notification from Perfin',
  priority: NotificationPriority.high,
);
```

## Integration with Existing Code

The notification service is designed to be called from:

1. **Budget monitoring** - When transactions update budget utilization
2. **Goal tracking** - When checking goal progress
3. **AI insights** - When anomalies are detected
4. **Scheduled tasks** - For recurring expense reminders

Example integration in TransactionProvider:

```dart
class TransactionProvider extends ChangeNotifier {
  final TransactionService _transactionService;
  final NotificationService _notificationService;
  
  Future<void> addTransaction(Transaction transaction) async {
    await _transactionService.saveTransaction(transaction);
    
    // Check budget utilization and send alert if needed
    final utilization = await _calculateBudgetUtilization();
    if (utilization >= 80) {
      await _notificationService.sendBudgetAlert(
        userId: transaction.userId,
        budget: budget,
        utilizationPercentage: utilization,
      );
    }
    
    notifyListeners();
  }
}
```

## Notes

- Notifications respect user preferences (can be disabled per type)
- Duplicate prevention ensures users aren't spammed
- All notifications are logged for analytics and debugging
- The system works offline (notifications are local, not push)
- iOS requires explicit permission request on first launch
- Android 13+ requires runtime permission for notifications
