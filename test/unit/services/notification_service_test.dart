import 'package:flutter_test/flutter_test.dart';
import 'package:perfin/models/notification_preferences.dart';
import 'package:perfin/services/notification_service.dart';
import 'package:perfin/services/notification_helper.dart';
import '../services/mock_storage_service.dart';

void main() {
  group('NotificationService - Preferences Management', () {
    late MockStorageService mockStorage;
    late NotificationService notificationService;

    setUp(() {
      mockStorage = MockStorageService();
      mockStorage.init();
      // Use a real NotificationHelper but don't call methods that require Flutter binding
      notificationService = NotificationService(mockStorage, NotificationHelper());
    });

    group('Notification Preferences', () {
      test('should return default preferences when none exist', () async {
        final prefs = await notificationService.getNotificationPreferences(
          userId: 'user123',
        );

        expect(prefs.userId, 'user123');
        expect(prefs.budgetAlerts, true);
        expect(prefs.recurringExpenseReminders, true);
        expect(prefs.goalDeadlineAlerts, true);
        expect(prefs.unusualSpendingAlerts, true);
      });

      test('should save and retrieve notification preferences', () async {
        final preferences = NotificationPreferences(
          userId: 'user123',
          budgetAlerts: false,
          recurringExpenseReminders: true,
          goalDeadlineAlerts: false,
          unusualSpendingAlerts: true,
          updatedAt: DateTime.now(),
        );

        await notificationService.updateNotificationPreferences(
          userId: 'user123',
          preferences: preferences,
        );

        final retrieved = await notificationService.getNotificationPreferences(
          userId: 'user123',
        );

        expect(retrieved.userId, 'user123');
        expect(retrieved.budgetAlerts, false);
        expect(retrieved.recurringExpenseReminders, true);
        expect(retrieved.goalDeadlineAlerts, false);
        expect(retrieved.unusualSpendingAlerts, true);
      });

      test('should update timestamp when saving preferences', () async {
        final now = DateTime.now();
        final preferences = NotificationPreferences(
          userId: 'user123',
          budgetAlerts: true,
          updatedAt: now.subtract(const Duration(days: 1)),
        );

        await notificationService.updateNotificationPreferences(
          userId: 'user123',
          preferences: preferences,
        );

        final retrieved = await notificationService.getNotificationPreferences(
          userId: 'user123',
        );

        // Updated timestamp should be more recent than the original
        expect(retrieved.updatedAt.isAfter(now.subtract(const Duration(seconds: 5))), true);
      });

      test('should handle multiple users independently', () async {
        final prefs1 = NotificationPreferences(
          userId: 'user1',
          budgetAlerts: false,
          updatedAt: DateTime.now(),
        );

        final prefs2 = NotificationPreferences(
          userId: 'user2',
          budgetAlerts: true,
          updatedAt: DateTime.now(),
        );

        await notificationService.updateNotificationPreferences(
          userId: 'user1',
          preferences: prefs1,
        );

        await notificationService.updateNotificationPreferences(
          userId: 'user2',
          preferences: prefs2,
        );

        final retrieved1 = await notificationService.getNotificationPreferences(
          userId: 'user1',
        );

        final retrieved2 = await notificationService.getNotificationPreferences(
          userId: 'user2',
        );

        expect(retrieved1.budgetAlerts, false);
        expect(retrieved2.budgetAlerts, true);
      });
    });
  });
}
