import 'package:flutter/foundation.dart';
import '../models/subscription_plan.dart';
import 'storage_service.dart';

/// Handles subscription state and usage counters.
///
/// Current implementation is local-first. Server sync can be layered on top
/// of the same interface when billing and backend hooks are connected.
class SubscriptionService {
  static const String _subscriptionPrefix = 'subscription';
  static const String _usagePrefix = 'usage_counters';

  static const String aiCopilotPromptsMetricKey = 'ai_copilot_prompts';

  final StorageService _storageService;

  SubscriptionService(this._storageService);

  static String monthlyPeriodKey([DateTime? now]) {
    final date = now ?? DateTime.now();
    final month = date.month.toString().padLeft(2, '0');
    return '${date.year}-$month';
  }

  Future<SubscriptionInfo> loadSubscription(String userId) async {
    final key = '${_subscriptionPrefix}_$userId';

    try {
      final data = await _storageService.load<Map<String, dynamic>>(key);
      if (data == null) {
        return SubscriptionInfo.free(userId: userId);
      }
      return SubscriptionInfo.fromJson(data);
    } catch (e) {
      debugPrint('Failed to load subscription for $userId: $e');
      return SubscriptionInfo.free(userId: userId);
    }
  }

  Future<void> saveSubscription(SubscriptionInfo subscription) async {
    final key = '${_subscriptionPrefix}_${subscription.userId}';
    await _storageService.save(key, subscription.toJson());
  }

  Future<Map<String, int>> loadUsageCounters({
    required String userId,
    required String periodKey,
  }) async {
    final key = '${_usagePrefix}_${userId}_$periodKey';

    try {
      final data = await _storageService.load<Map<String, dynamic>>(key);
      if (data == null) {
        return {};
      }

      final counters = <String, int>{};
      data.forEach((metric, rawValue) {
        if (rawValue is num) {
          counters[metric] = rawValue.toInt();
        }
      });

      return counters;
    } catch (e) {
      debugPrint('Failed to load usage counters for $userId: $e');
      return {};
    }
  }

  Future<int> loadUsageCount({
    required String userId,
    required String metricKey,
    required String periodKey,
  }) async {
    final counters = await loadUsageCounters(
      userId: userId,
      periodKey: periodKey,
    );

    return counters[metricKey] ?? 0;
  }

  Future<int> incrementUsageCounter({
    required String userId,
    required String metricKey,
    required String periodKey,
    int by = 1,
  }) async {
    final key = '${_usagePrefix}_${userId}_$periodKey';
    final counters = await loadUsageCounters(
      userId: userId,
      periodKey: periodKey,
    );

    final current = counters[metricKey] ?? 0;
    final next = current + by;

    counters[metricKey] = next;
    await _storageService.save(key, counters);

    return next;
  }
}
