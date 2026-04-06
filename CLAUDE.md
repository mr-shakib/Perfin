# Perfin Instant Context

Last updated: 2026-04-06
Scope: fast orientation for coding sessions in this repository.

## What This Project Is

Perfin is a Flutter personal finance app with:
- local-first persistence via Hive
- optional cloud sync and auth via Supabase
- AI insights/chat via Groq API
- Provider-based state management

Primary development root: `lib/`

## Quick Start

1. Install deps:
   - `flutter pub get`
2. Create `.env` in project root (minimum):
   - `GROQ_API_KEY=...`
   - `SUPABASE_URL=...` (optional, app has fallback values)
   - `SUPABASE_ANON_KEY=...` (optional, app has fallback values)
3. Run app:
   - `flutter run`

Optional entrypoint for notification testing:
- `flutter run -t lib/notification_test_main.dart`

## Core Architecture

### App Bootstrap

Main entry: `lib/main.dart`

Startup sequence (simplified):
1. Flutter binding init
2. `.env` load (best effort)
3. Supabase init (only if URL/key look valid)
4. Hive storage init
5. Service construction
6. Provider graph wiring
7. `MaterialApp` launch at route `/splash`

Important behavior:
- App tolerates failed Supabase init and can continue in local-only mode.
- Background sync is attempted only when Supabase is initialized.

### State Management (Provider)

Provider wiring is centralized in `lib/main.dart`.

High-level dependency graph:
- Independent roots:
  - `ThemeProvider`
  - `CurrencyProvider`
  - `OnboardingProvider`
  - `AuthProvider`
- Dependent providers:
  - `TransactionProvider` depends on `AuthProvider`
  - `BudgetProvider` depends on `AuthProvider` + `TransactionProvider`
  - `AIProvider` depends on `AuthProvider`
  - `InsightProvider` depends on `AuthProvider`
  - `GoalProvider` depends on `AuthProvider`

### Screen Composition

Key routes in `MaterialApp` (see `lib/main.dart`):
- `/splash` (auth + onboarding gate)
- `/login`, `/signup`
- `/onboarding/*`
- `/dashboard` -> `MainDashboard`

Main tab shell: `lib/screens/main_dashboard.dart`
- Home
- Feed
- Perfin (AI chat)
- Goals
- Profile

## Data and Storage Model

### Local Storage

Primary storage implementation: `lib/services/hive_storage_service.dart`

Data is stored as JSON strings under keys. Common patterns:
- transactions: `transactions_<userId>`
- monthly budget: `monthly_budget_<userId>_<year>_<month>`
- category budgets: `category_budgets_<userId>`
- onboarding prefs: `onboarding_preferences`
- notification prefs: `notification_prefs_<userId>`
- sync queue: `sync_queue`

### Core Services

Main service layer in `lib/services/`:
- `auth_service.dart`
- `transaction_service.dart`
- `budget_service.dart`
- `goal_service.dart`
- `insight_service.dart`
- `ai_service.dart`
- `notification_service.dart`
- `sync_service.dart`

Model exports live in `lib/models/models.dart`.

### Sync Strategy (Offline-first)

Sync queue logic: `lib/services/sync_service.dart`
- queue operation types: create/update/delete
- entity types: transaction/budget/goal
- retry with exponential backoff (max 3)
- completed operations cleaned from queue after processing

Supabase sync target tables include:
- `transactions`
- `budgets`
- `goals`

## Backend and Schema

Base Supabase setup: `supabase_setup.sql`
- tables: profiles, transactions, budgets, goals
- RLS policies and indexes

Feature migration: `supabase_migrations/001_add_main_app_features.sql`
- extends transactions and budgets
- adds `chat_messages`, `notification_preferences`
- adds indexes/triggers/RLS policies

Note: migration assumptions depend on base schema being applied first.

## AI System

Main implementation: `lib/services/ai_service.dart`
- provider: Groq chat completions endpoint (`https://api.groq.com/openai/v1`)
- model default: `llama-3.3-70b-versatile`
- features include summary, prediction, recurring detection, chat query handling, goal feasibility/prioritization

Factory helper: `lib/services/ai_service_factory.dart`
- expects `GROQ_API_KEY`

## Notifications

Notification plumbing:
- helper: `lib/services/notification_helper.dart`
- service: `lib/services/notification_service.dart`

Current behavior:
- local notifications via `flutter_local_notifications`
- duplicate suppression via per-user notification log
- permissions requested separately (not automatically in `initialize()`)

## Important Project Facts and Gotchas

1. AI key naming drift exists in docs.
   - Runtime code uses `GROQ_API_KEY`.
   - Some docs still mention Gemini wording or `GEMINI_API_KEY`.

2. Android notification permission is not present in manifest right now.
   - `android/app/src/main/AndroidManifest.xml` currently does not include `POST_NOTIFICATIONS`.

3. Supabase credentials have hardcoded fallback values.
   - See `lib/config/supabase_config.dart`.

4. Local storage implementation is Hive, even though some docs mention SQLite schema.
   - The runtime sync queue currently uses storage-service-backed JSON, not direct SQL table writes.

5. Repository includes generated/build artifacts in workspace tree (`build/` exists).
   - Be careful not to treat generated files as source-of-truth.

## Testing Snapshot

Test layout:
- root smoke test: `test/widget_test.dart`
- unit tests: `test/unit/models`, `test/unit/services`, `test/unit/providers`, `test/unit/utils`
- widget tests: `test/widget/`

Standard commands:
- `flutter test`
- `flutter test --coverage`

## Deployment/Web Hosting Files

- Firebase metadata: `firebase.json`
- Netlify config: `netlify.toml`
- Vercel config: `vercel.json`
- Web shell: `web/index.html`

Web configs route all paths to `index.html` for SPA behavior.

## Where To Edit For Common Tasks

### Add a new business feature
1. Add/extend model in `lib/models/`
2. Add service logic in `lib/services/`
3. Add provider state/commands in `lib/providers/`
4. Add/update screens/widgets under `lib/screens/`
5. If cloud-backed, update SQL in `supabase_setup.sql` or `supabase_migrations/`
6. Add tests under `test/unit/` and/or `test/widget/`

### Add a new route/screen
1. Create screen in `lib/screens/...`
2. Register route in `lib/main.dart`
3. Connect navigation in relevant screen/widget

### Add new sync entity
1. Add model serialization (`toJson`, `fromJson`, optional `toSupabaseJson`)
2. Extend sync entity handling in `lib/services/sync_service.dart`
3. Queue operations from the relevant provider
4. Add/adjust Supabase schema and RLS policies

## Suggested Session Warm-up (60 seconds)

When starting work, read these first:
1. `lib/main.dart`
2. `lib/screens/main_dashboard.dart`
3. `lib/providers/transaction_provider.dart`
4. `lib/services/transaction_service.dart`
5. `lib/services/ai_service.dart` (if touching AI)

This gives enough context to safely implement most feature changes.