import '../models/entitlement.dart';

/// Centralized helpers for feature and usage gating logic.
class FeatureGate {
  const FeatureGate._();

  static bool canUseFeature({
    required Entitlement entitlement,
    required AppFeature feature,
  }) {
    return entitlement.canUse(feature);
  }

  static bool canConsumeUsage({
    required Entitlement entitlement,
    required UsageMetric metric,
    required int usedCount,
    int amount = 1,
  }) {
    final limit = entitlement.limitFor(metric);
    if (limit == null) {
      return true;
    }

    return usedCount + amount <= limit;
  }

  static int remainingUsage({
    required Entitlement entitlement,
    required UsageMetric metric,
    required int usedCount,
  }) {
    final limit = entitlement.limitFor(metric);
    if (limit == null) {
      return -1;
    }

    final remaining = limit - usedCount;
    return remaining < 0 ? 0 : remaining;
  }

  static bool hasReachedUsageLimit({
    required Entitlement entitlement,
    required UsageMetric metric,
    required int usedCount,
  }) {
    return !canConsumeUsage(
      entitlement: entitlement,
      metric: metric,
      usedCount: usedCount,
      amount: 1,
    );
  }
}
