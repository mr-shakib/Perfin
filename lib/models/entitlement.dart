import 'subscription_plan.dart';

/// Features that can be gated by subscription plan.
enum AppFeature {
  aiCopilotChat,
  aiAdvancedInsights,
  advancedAnalytics,
  recurringRules,
  billTracker,
  netWorthTracking,
  debtPlanner,
  familyWorkspace,
  advancedExport,
}

/// Usage metrics that may have quota limits.
enum UsageMetric { aiCopilotPrompts }

/// Plan-based entitlement configuration.
class Entitlement {
  final SubscriptionPlan plan;
  final Set<AppFeature> enabledFeatures;
  final Map<UsageMetric, int?> usageLimits;
  final int analyticsHistoryMonths;
  final int maxActiveGoals;

  const Entitlement({
    required this.plan,
    required this.enabledFeatures,
    required this.usageLimits,
    required this.analyticsHistoryMonths,
    required this.maxActiveGoals,
  });

  bool canUse(AppFeature feature) => enabledFeatures.contains(feature);

  int? limitFor(UsageMetric metric) => usageLimits[metric];

  bool hasUnlimitedUsage(UsageMetric metric) => limitFor(metric) == null;

  static Entitlement forPlan(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return const Entitlement(
          plan: SubscriptionPlan.free,
          enabledFeatures: {AppFeature.aiCopilotChat},
          usageLimits: {UsageMetric.aiCopilotPrompts: 20},
          analyticsHistoryMonths: 3,
          maxActiveGoals: 3,
        );
      case SubscriptionPlan.pro:
        return const Entitlement(
          plan: SubscriptionPlan.pro,
          enabledFeatures: {
            AppFeature.aiCopilotChat,
            AppFeature.aiAdvancedInsights,
            AppFeature.advancedAnalytics,
            AppFeature.recurringRules,
            AppFeature.billTracker,
            AppFeature.netWorthTracking,
            AppFeature.debtPlanner,
            AppFeature.advancedExport,
          },
          usageLimits: {UsageMetric.aiCopilotPrompts: null},
          analyticsHistoryMonths: 24,
          maxActiveGoals: 1000,
        );
      case SubscriptionPlan.family:
        return const Entitlement(
          plan: SubscriptionPlan.family,
          enabledFeatures: {
            AppFeature.aiCopilotChat,
            AppFeature.aiAdvancedInsights,
            AppFeature.advancedAnalytics,
            AppFeature.recurringRules,
            AppFeature.billTracker,
            AppFeature.netWorthTracking,
            AppFeature.debtPlanner,
            AppFeature.advancedExport,
            AppFeature.familyWorkspace,
          },
          usageLimits: {UsageMetric.aiCopilotPrompts: null},
          analyticsHistoryMonths: 24,
          maxActiveGoals: 1000,
        );
    }
  }
}
