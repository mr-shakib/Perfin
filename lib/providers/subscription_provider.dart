import 'package:flutter/foundation.dart';
import '../models/entitlement.dart';
import '../models/subscription_plan.dart';
import '../services/subscription_service.dart';
import '../utils/feature_gate.dart';

/// Manages current subscription plan and usage quotas.
class SubscriptionProvider extends ChangeNotifier {
  final SubscriptionService _subscriptionService;

  String? _userId;
  bool _isLoading = false;
  String? _errorMessage;

  SubscriptionInfo _subscription = SubscriptionInfo.free(userId: 'guest');
  int _aiPromptsUsed = 0;
  String _usagePeriodKey = SubscriptionService.monthlyPeriodKey();

  SubscriptionProvider(this._subscriptionService);

  String? get userId => _userId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  SubscriptionInfo get subscription => _subscription;
  SubscriptionPlan get currentPlan => _subscription.plan;
  Entitlement get entitlement => Entitlement.forPlan(currentPlan);

  int get aiPromptsUsed => _aiPromptsUsed;
  int? get aiPromptsLimit => entitlement.limitFor(UsageMetric.aiCopilotPrompts);

  int get aiPromptsRemaining => FeatureGate.remainingUsage(
    entitlement: entitlement,
    metric: UsageMetric.aiCopilotPrompts,
    usedCount: _aiPromptsUsed,
  );

  bool get hasUnlimitedAiPrompts =>
      entitlement.hasUnlimitedUsage(UsageMetric.aiCopilotPrompts);

  void updateUserId(String? userId) {
    if (_userId == userId) return;

    _userId = userId;

    if (userId == null) {
      _resetState();
      notifyListeners();
      return;
    }

    _loadSubscriptionData();
  }

  Future<void> refresh() async {
    await _loadSubscriptionData();
  }

  bool canUseFeature(AppFeature feature) {
    return FeatureGate.canUseFeature(
      entitlement: entitlement,
      feature: feature,
    );
  }

  bool canConsumeAiPrompt({int amount = 1}) {
    if (!canUseFeature(AppFeature.aiCopilotChat)) {
      return false;
    }

    _rollUsagePeriodIfNeeded();

    return FeatureGate.canConsumeUsage(
      entitlement: entitlement,
      metric: UsageMetric.aiCopilotPrompts,
      usedCount: _aiPromptsUsed,
      amount: amount,
    );
  }

  Future<bool> tryConsumeAiPrompt({int amount = 1}) async {
    if (_userId == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return false;
    }

    _rollUsagePeriodIfNeeded();

    if (!canConsumeAiPrompt(amount: amount)) {
      return false;
    }

    try {
      final updatedCount = await _subscriptionService.incrementUsageCounter(
        userId: _userId!,
        metricKey: SubscriptionService.aiCopilotPromptsMetricKey,
        periodKey: _usagePeriodKey,
        by: amount,
      );

      _aiPromptsUsed = updatedCount;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update AI usage quota';
      debugPrint('Failed to increment AI usage counter: $e');
      notifyListeners();
      return false;
    }
  }

  /// Temporary local plan switch for development and QA.
  /// Replace this with real billing integration in production.
  Future<void> setPlanForDevelopment(SubscriptionPlan plan) async {
    if (_userId == null) {
      return;
    }

    _subscription = _subscription.copyWith(
      plan: plan,
      status: SubscriptionStatus.active,
      updatedAt: DateTime.now(),
    );

    await _subscriptionService.saveSubscription(_subscription);
    notifyListeners();
  }

  Future<void> _loadSubscriptionData() async {
    final userId = _userId;
    if (userId == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _usagePeriodKey = SubscriptionService.monthlyPeriodKey();
      _subscription = await _subscriptionService.loadSubscription(userId);
      _aiPromptsUsed = await _subscriptionService.loadUsageCount(
        userId: userId,
        metricKey: SubscriptionService.aiCopilotPromptsMetricKey,
        periodKey: _usagePeriodKey,
      );
      _errorMessage = null;
    } catch (e) {
      _subscription = SubscriptionInfo.free(userId: userId);
      _aiPromptsUsed = 0;
      _errorMessage = 'Failed to load subscription data';
      debugPrint('Subscription data load failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _rollUsagePeriodIfNeeded() {
    final currentPeriod = SubscriptionService.monthlyPeriodKey();
    if (_usagePeriodKey == currentPeriod) {
      return;
    }

    _usagePeriodKey = currentPeriod;
    _aiPromptsUsed = 0;
  }

  void _resetState() {
    _isLoading = false;
    _errorMessage = null;
    _subscription = SubscriptionInfo.free(userId: 'guest');
    _aiPromptsUsed = 0;
    _usagePeriodKey = SubscriptionService.monthlyPeriodKey();
  }
}
