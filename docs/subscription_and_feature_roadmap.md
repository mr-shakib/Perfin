# Perfin Subscription and Feature Roadmap

Last updated: 2026-04-07
Owner: Product + Engineering
Status: Approved for implementation planning

## 1. Product Goal

Perfin should remain highly useful for everyday users on the free tier, while charging for advanced automation, prediction, AI depth, and multi-user workflows.

Guiding rule:
- Free tier = essential money tracking and budgeting.
- Paid tier = time-saving automation, deeper insights, and premium planning tools.

## 2. Plan Structure

### Free (Core)

This tier must feel complete for basic personal finance use.

Included:
- Unlimited manual income/expense tracking
- Custom categories
- Monthly budgets by category
- Basic savings goals and goal progress
- Core dashboard charts (income, expenses, category split)
- Standard notifications (budget and goal reminders)
- Basic data export (CSV)
- One account profile and basic sync

Limits:
- AI Copilot usage cap (example: 20 prompts/month)
- Analytics history cap (example: last 3 months)
- Max active goals (example: 3)

### Pro (Paid)

This tier targets users who want forecasting, optimization, and automation.

Included:
- Unlimited AI Copilot + advanced AI insights
- Goal feasibility simulations and what-if planning
- Advanced analytics and trends (6/12/24 months)
- Cash-flow prediction and anomaly alerts
- Recurring transaction rules and smart auto-categorization
- Subscription and bill management center
- Net worth tracking (assets + liabilities)
- Debt payoff planner (snowball/avalanche)
- Advanced exports (PDF summary, tax-oriented views)
- Priority sync and multi-device reliability improvements

### Family (Paid, Phase 3)

Included:
- Shared household workspace
- Shared budgets/goals and role permissions
- Household insights and monthly family reports

## 3. Feature Entitlement Matrix

| Area | Feature | Free | Pro | Family |
|---|---|---|---|---|
| Transactions | Manual transaction entry | Yes | Yes | Yes |
| Transactions | Bulk edit + advanced filters | No | Yes | Yes |
| Budgeting | Category budgets | Yes | Yes | Yes |
| Budgeting | Smart adaptive budget recommendations | No | Yes | Yes |
| Goals | Basic goal tracking | Yes (limit: 3 active) | Yes | Yes |
| Goals | AI feasibility + what-if simulation | No | Yes | Yes |
| AI | Copilot chat | Limited monthly prompts | Unlimited | Unlimited |
| Analytics | Basic monthly breakdown | Yes | Yes | Yes |
| Analytics | Forecasting + anomaly detection | No | Yes | Yes |
| Bills | Bill/subscription tracker | No | Yes | Yes |
| Net Worth | Asset/liability dashboard | No | Yes | Yes |
| Debt | Payoff planner | No | Yes | Yes |
| Collaboration | Shared household finance | No | No | Yes |
| Export | CSV export | Yes | Yes | Yes |
| Export | PDF/custom report exports | No | Yes | Yes |

## 4. Complete App Feature Vision

To make Perfin a complete personal finance app, we will add these capabilities:

1. Account Hub
- Manage cash wallets, bank accounts, cards, loans, and liabilities.
- Show balances and account-level trends.

2. Bill and Subscription Center
- Track recurring bills/subscriptions.
- Due date reminders and payment status.
- Monthly recurring burden summary.

3. Net Worth Dashboard
- Assets vs liabilities timeline.
- Month-over-month net worth movement and drivers.

4. Debt Payoff Planner
- Snowball and avalanche strategies.
- Suggested monthly plan and payoff date forecast.

5. Automation Rules Engine
- Rule examples: auto-categorize merchants, auto-tag recurring payments, auto-goal allocation.

6. Advanced Analytics
- Cash-flow projection.
- Budget risk forecast before month-end.
- Spending anomaly and overspend risk alerts.

7. Household Collaboration (Family Plan)
- Shared spaces, roles, and approval controls.

8. Tax and Annual Reporting
- Yearly summaries, category totals, exportable reports.

## 5. Implementation Roadmap

### Phase 0: Monetization Foundation (Start here)

Goal: introduce subscription architecture without breaking current flows.

Engineering tasks:
- Add plan/entitlement models:
  - `lib/models/subscription_plan.dart`
  - `lib/models/entitlement.dart`
- Add subscription service/provider:
  - `lib/services/subscription_service.dart`
  - `lib/providers/subscription_provider.dart`
- Add lightweight feature gate helper:
  - `lib/utils/feature_gate.dart`
- Add paywall screen:
  - `lib/screens/subscription/subscription_screen.dart`
- Wire provider in `lib/main.dart`.
- Add UI gate points for AI prompt limits and premium-only cards.

Data layer tasks (Supabase + local fallback):
- New table: `subscriptions`
  - `id`, `user_id`, `plan`, `status`, `period_start`, `period_end`, `created_at`, `updated_at`
- New table: `usage_counters`
  - `id`, `user_id`, `metric_key`, `period_key`, `count`, `updated_at`
- RLS policy by `user_id`.
- Sync behavior: local counters merge to server on login.

Deliverables:
- Users can see current plan and limits.
- Pro features are gated with clear upgrade prompts.
- No core feature is blocked for existing free users.

### Phase 1: Pro Core Features

Goal: ship features that directly justify Pro subscription.

Features:
- Bill & subscription tracker
- Recurring transaction rules
- Advanced analytics history + forecast
- AI unlimited mode for Pro

Engineering slices:
- `bill` module (model/service/provider/screens)
- `rule_engine` module for auto-categorization
- analytics extensions in `insight_service.dart` + `insight_provider.dart`

### Phase 2: Completeness Features

Goal: expand from budget tracker into full finance management platform.

Features:
- Account hub (assets + liabilities)
- Net worth dashboard
- Debt payoff planner

Engineering slices:
- `account` module
- `liability` module
- `net_worth` aggregator service
- debt strategy calculator utility

### Phase 3: Family Plan + Collaboration

Goal: add shared finance capability and higher-value paid plan.

Features:
- Shared household entity
- Member roles (owner/editor/viewer)
- Shared budget/goal workflows

## 6. UX and Pricing Rules

1. Never block existing user data behind paywall.
- Users can always view previously entered transactions/budgets/goals.

2. Use soft paywall, not hard interruption.
- Show locked cards and upgrade CTAs where value is discovered.

3. Meter first, then upsell.
- Example: after free AI prompt quota is consumed, show usage meter and upgrade modal.

4. Keep free tier generous.
- Free users should be able to manage day-to-day money without frustration.

## 7. KPIs to Track After Launch

Business:
- Free to Pro conversion rate
- Trial to paid conversion rate
- Monthly recurring revenue (MRR)
- Churn rate

Product:
- Weekly active users
- AI usage per active user
- Budget adherence improvement
- Goal completion rate
- Net worth tracking retention (Phase 2 onward)

## 8. Sprint Plan to Begin Implementation

Sprint 1 (Subscription Foundation):
- Implement plan model + provider + gate helper
- Add subscription screen and profile entry point
- Gate AI usage limit for free tier
- Add `subscriptions` + `usage_counters` migrations

Sprint 2 (First Paid Value):
- Bill/subscription tracker (CRUD + reminders)
- Recurring rule engine v1 (merchant/category based)
- Upgrade prompts from bill center and AI quota screens

Sprint 3 (Advanced Intelligence):
- Cash-flow forecast card
- Overspending risk alerts
- Monthly premium report export

## 9. Definition of Done (for each new feature)

- Business logic implemented in service + provider
- Gating rules applied in UI and backend checks
- Sync behavior tested for offline/online transitions
- Unit tests for core calculations and entitlement checks
- Widget tests for paywall and locked-state UX
- Documentation updated in `docs/`

---

This document is the baseline reference for subscription decisions and rollout sequencing.
