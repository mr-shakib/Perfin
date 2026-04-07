import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/subscription_plan.dart';
import '../../providers/subscription_provider.dart';
import '../../theme/app_colors.dart';

/// Subscription management and upgrade screen.
class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamLight,
      appBar: AppBar(
        title: const Text('Subscription'),
        backgroundColor: AppColors.creamLight,
        elevation: 0,
      ),
      body: Consumer<SubscriptionProvider>(
        builder: (context, subscriptionProvider, _) {
          final plan = subscriptionProvider.currentPlan;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildCurrentPlanCard(subscriptionProvider),
              const SizedBox(height: 20),
              _buildPlanCard(
                context: context,
                provider: subscriptionProvider,
                title: 'Free',
                subtitle: 'Great for day-to-day tracking',
                features: const [
                  'Unlimited transaction tracking',
                  'Budgets and basic goals',
                  'Basic charts and CSV export',
                  'AI Copilot: 20 prompts/month',
                ],
                plan: SubscriptionPlan.free,
                isCurrent: plan == SubscriptionPlan.free,
              ),
              const SizedBox(height: 12),
              _buildPlanCard(
                context: context,
                provider: subscriptionProvider,
                title: 'Pro',
                subtitle: 'Advanced automation and intelligence',
                features: const [
                  'Unlimited AI Copilot prompts',
                  'Forecasting and anomaly insights',
                  'Bill and subscription tools',
                  'Net worth and debt planning',
                ],
                plan: SubscriptionPlan.pro,
                isCurrent: plan == SubscriptionPlan.pro,
              ),
              const SizedBox(height: 12),
              _buildPlanCard(
                context: context,
                provider: subscriptionProvider,
                title: 'Family',
                subtitle: 'Shared household finance collaboration',
                features: const [
                  'Everything in Pro',
                  'Shared family workspace',
                  'Shared goals and budgets',
                  'Role-based household access',
                ],
                plan: SubscriptionPlan.family,
                isCurrent: plan == SubscriptionPlan.family,
              ),
              if (!kDebugMode) ...[
                const SizedBox(height: 20),
                const Text(
                  'Billing integration is coming soon. For now, this screen documents and previews plan differences.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF666666),
                    height: 1.4,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrentPlanCard(SubscriptionProvider provider) {
    final planName = provider.currentPlan.displayName;
    final aiUsage = provider.hasUnlimitedAiPrompts
        ? 'Unlimited AI prompts'
        : '${provider.aiPromptsUsed}/${provider.aiPromptsLimit ?? 0} AI prompts used this month';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Plan',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            planName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            aiUsage,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required BuildContext context,
    required SubscriptionProvider provider,
    required String title,
    required String subtitle,
    required List<String> features,
    required SubscriptionPlan plan,
    required bool isCurrent,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.creamCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent ? const Color(0xFF1A1A1A) : const Color(0xFFE5E5E5),
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(width: 8),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Current',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 12),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Icon(
                      Icons.check_circle,
                      size: 14,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isCurrent
                  ? null
                  : () async {
                      if (!kDebugMode) {
                        return;
                      }

                      await provider.setPlanForDevelopment(plan);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Switched to ${plan.displayName} (debug mode)',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: isCurrent
                    ? const Color(0xFFD0D0D0)
                    : const Color(0xFF1A1A1A),
                foregroundColor: isCurrent
                    ? const Color(0xFF666666)
                    : Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isCurrent
                    ? 'Current Plan'
                    : (kDebugMode ? 'Switch (Debug)' : 'Coming Soon'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
