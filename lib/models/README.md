# Perfin Data Models

This directory contains all data models for the Perfin application. Models are organized by feature area and follow consistent patterns for serialization, equality, and string representation.

## Model Categories

### Core Models

**Transaction** (`transaction.dart`)
- Represents financial transactions (income/expense)
- Extended with `isSynced` for offline support
- Extended with `linkedGoalId` for automatic goal tracking
- Includes validation logic

**Budget** (`budget.dart`)
- Represents monthly budget allocations
- Extended with `isActive` for soft deletion
- Tracks spending limits by category

**User** (`user.dart`)
- Represents authenticated users
- Contains basic profile information

**Goal** (`goal.dart`)
- Represents financial goals with target amounts and deadlines
- Includes calculated properties:
  - `progressPercentage`: (currentAmount / targetAmount) * 100
  - `requiredMonthlySavings`: (targetAmount - currentAmount) / monthsRemaining
  - `daysRemaining`: Days until target date
- Supports automatic tracking via linked categories
- Supports manual tracking override

### AI-Related Models

**AISummary** (`ai_summary.dart`)
- Natural language financial summary
- Includes insights, anomalies, and confidence scores
- Flags insufficient data scenarios

**SpendingPrediction** (`spending_prediction.dart`)
- End-of-month spending predictions
- Includes confidence intervals (lower/upper bounds)
- Lists assumptions used in prediction

**SpendingPattern** (`spending_pattern.dart`)
- Detected patterns in spending behavior
- Types: increasing, decreasing, weekend_heavy, etc.
- Includes magnitude and confidence score

**RecurringExpense** (`recurring_expense.dart`)
- Automatically detected recurring expenses
- Tracks frequency, average amount, next expected date
- References supporting transactions

**SpendingAnomaly** (`spending_anomaly.dart`)
- Unusual spending transactions
- Types: unusually_high, unusual_category, unusual_timing
- Includes deviation from normal and explanation

### Chat and AI Response Models

**ChatMessage** (`chat_message.dart`)
- Messages in Copilot conversation
- Roles: user, assistant
- Supports metadata for references and calculations

**AIResponse** (`ai_response.dart`)
- AI-generated responses to queries
- Includes data references and calculations
- Supports clarifying questions

**DataReference** (`data_reference.dart`)
- References to data used in AI responses
- Types: transaction, budget, goal
- Provides human-readable descriptions

### Goal Analysis Models

**GoalFeasibilityAnalysis** (`goal_feasibility_analysis.dart`)
- AI analysis of goal achievability
- Feasibility levels: easy, moderate, challenging, unrealistic
- Includes spending reduction suggestions

**SpendingReduction** (`spending_reduction.dart`)
- Suggested spending reductions for goals
- Identifies non-essential high-spending categories
- Calculates new monthly spending targets

**GoalPrioritization** (`goal_prioritization.dart`)
- Prioritization of multiple goals
- Detects conflicts when total savings exceed surplus
- Provides rationale for priority order

### Utility Models

**TrendDataPoint** (`trend_data_point.dart`)
- Data points for trend visualization
- Used in charts and graphs

**NotificationPreferences** (`notification_preferences.dart`)
- User preferences for notifications
- Controls: budget alerts, recurring expense reminders, goal alerts, unusual spending alerts

### Sync Models

**SyncOperation** (`sync_operation.dart`)
- Operations queued for synchronization
- Types: create, update, delete
- Statuses: pending, inProgress, completed, failed
- Tracks retry count for failed operations

**SyncResult** (`sync_result.dart`)
- Result of sync operations
- Tracks success/failure counts
- Lists failed operation IDs

## Model Patterns

All models follow these patterns:

### JSON Serialization
```dart
// To JSON
Map<String, dynamic> toJson() { ... }

// From JSON
factory Model.fromJson(Map<String, dynamic> json) { ... }
```

### Equality and Hashing
```dart
@override
bool operator ==(Object other) { ... }

@override
int get hashCode { ... }
```

### String Representation
```dart
@override
String toString() { ... }
```

### Enums
Enums include serialization methods:
```dart
String toJson() => name;
static EnumType fromJson(String value) { ... }
```

### Immutability
Models are immutable. Use `copyWith` methods for updates:
```dart
Model copyWith({ ... }) { ... }
```

## Usage

Import all models at once:
```dart
import 'package:perfin/models/models.dart';
```

Or import specific models:
```dart
import 'package:perfin/models/goal.dart';
import 'package:perfin/models/transaction.dart';
```

## Validation

Models with business logic include validation:
- `Transaction.isValid()` - Validates transaction data
- Goal constraints enforced in constructor (positive amounts, future dates)
- Budget constraints enforced in database schema

## Calculated Properties

Some models include calculated properties (getters):
- `Goal.progressPercentage`
- `Goal.requiredMonthlySavings`
- `Goal.daysRemaining`

These are computed on-the-fly and not stored in the database.

## Database Mapping

Models map to database tables as follows:
- `Transaction` → `transactions` table
- `Budget` → `budgets` table
- `Goal` → `goals` table
- `ChatMessage` → `chat_messages` table
- `NotificationPreferences` → `notification_preferences` table
- `SyncOperation` → `sync_queue` table (local SQLite only)

See `supabase_migrations/` for database schema definitions.
