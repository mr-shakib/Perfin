# Design Document: Main App Tabs and Features

## Overview

The Perfin main application consists of five primary tabs that work together to provide a comprehensive personal finance management experience. The system is built on Flutter/Dart for mobile-first delivery, with Supabase as the backend infrastructure. The architecture emphasizes financial accuracy, AI transparency, and seamless data flow between components.

The design leverages existing infrastructure (authentication, onboarding, base models) and extends it with tab-specific features, AI-powered insights, and cross-cutting concerns like offline support and real-time sync. Each tab serves a distinct purpose while sharing common data models and services.

**Key Design Principles:**
- Financial accuracy over AI creativity (exact calculations, no hallucinations)
- Explicit separation of facts, predictions, and advice
- Mobile-first with offline-capable architecture
- Minimal cognitive load through progressive disclosure
- Transparent AI with confidence scoring and uncertainty communication

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                       │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐             │
│  │ Home │ │Insig-│ │Copil-│ │Goals │ │Profi-│             │
│  │ Tab  │ │hts   │ │ot    │ │ Tab  │ │le    │             │
│  └──┬───┘ └──┬───┘ └──┬───┘ └──┬───┘ └──┬───┘             │
└─────┼────────┼────────┼────────┼────────┼──────────────────┘
      │        │        │        │        │
┌─────┴────────┴────────┴────────┴────────┴──────────────────┐
│                    Business Logic Layer                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Services   │  │  Providers   │  │  Validators  │     │
│  │              │  │              │  │              │     │
│  │ - Budget     │  │ - Budget     │  │ - Budget     │     │
│  │ - Transaction│  │ - Transaction│  │ - Transaction│     │
│  │ - Goal       │  │ - Goal       │  │ - Goal       │     │
│  │ - AI Engine  │  │ - AI         │  │ - Goal       │     │
│  │ - Insight    │  │ - Insight    │  │              │     │
│  │ - Notification│ │ - Notification│ │              │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└──────────────────────────┬───────────────────────────────────┘
                           │
┌──────────────────────────┴───────────────────────────────────┐
│                      Data Layer                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Supabase   │  │ Local Storage│  │  Sync Queue  │      │
│  │   (Remote)   │  │   (SQLite)   │  │              │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└───────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

**Presentation Layer (Tabs):**
- Render UI components and handle user interactions
- Consume data from Providers via state management
- Trigger business logic through Service calls
- Display loading states, errors, and empty states

**Business Logic Layer:**
- **Services**: Stateless business logic, data transformation, API calls
- **Providers**: State management using Flutter Provider pattern
- **Validators**: Input validation and business rule enforcement
- **AI Engine**: Insight generation, prediction, pattern detection

**Data Layer:**
- **Supabase**: Source of truth for persistent data
- **Local Storage**: Offline cache and pending changes queue
- **Sync Queue**: Manages offline-to-online data synchronization

### Data Flow Patterns

**Read Flow:**
1. Tab requests data from Provider
2. Provider checks local cache freshness
3. If stale or missing, Provider calls Service
4. Service fetches from Supabase
5. Service updates local cache
6. Provider notifies listeners
7. Tab rebuilds with new data

**Write Flow:**
1. Tab calls Service method with user input
2. Service validates input using Validator
3. Service writes to local storage immediately
4. Service queues sync operation
5. Service attempts Supabase write
6. On success: mark sync complete
7. On failure: keep in sync queue for retry
8. Provider notifies listeners
9. All affected tabs update

**AI Flow:**
1. Tab or Service requests AI insight
2. AI Engine fetches required data from Services
3. AI Engine performs analysis/prediction
4. AI Engine calculates confidence score
5. AI Engine formats response with uncertainty markers
6. Response returned to caller with metadata
7. Tab displays insight with confidence indicator

## Components and Interfaces

### Home Tab Components

**HomeScreen Widget:**
- Root widget for Home tab
- Consumes: BudgetProvider, TransactionProvider, AIProvider
- Displays: Financial summary card, budget status list, recent transactions, quick actions

**FinancialSummaryCard Widget:**
- Displays current balance, monthly income, monthly spending
- Consumes: TransactionProvider
- Calculates: Sum of income transactions, sum of expense transactions, net balance

**BudgetStatusList Widget:**
- Displays all active budgets with utilization bars
- Consumes: BudgetProvider, TransactionProvider
- Calculates: (spent_in_category / budget_limit) * 100
- Visual indicators: Green (<80%), Yellow (80-100%), Red (>100%)

**AISummaryCard Widget:**
- Displays AI-generated financial summary
- Consumes: AIProvider
- Shows: Natural language summary, key insights, anomaly alerts
- Handles: Loading state, error state, insufficient data state

**RecentTransactionsList Widget:**
- Displays last 3 transactions
- Consumes: TransactionProvider
- Supports: Tap to navigate to transaction detail

**QuickActionButtons Widget:**
- Provides buttons for common actions
- Actions: Add transaction, View all transactions, Create budget

### Insights Tab Components

**InsightsScreen Widget:**
- Root widget for Insights tab
- Consumes: TransactionProvider, AIProvider, InsightProvider
- Displays: Time period selector, spending breakdown, trend chart, AI predictions

**TimePeriodSelector Widget:**
- Dropdown or segmented control for period selection
- Options: Current month, Last month, Last 3 months, Last 6 months, Last year
- Triggers: Data refresh on selection change

**SpendingBreakdownChart Widget:**
- Pie or donut chart showing category breakdown
- Consumes: TransactionProvider
- Calculates: Sum per category, percentage of total
- Supports: Tap on segment to drill down

**SpendingTrendChart Widget:**
- Line or bar chart showing spending over time
- Consumes: TransactionProvider
- Aggregates: Daily or weekly totals based on period
- Displays: Trend line if sufficient data

**PredictionCard Widget:**
- Displays end-of-month spending prediction
- Consumes: AIProvider
- Shows: Predicted amount, confidence score, explanation
- Visual: Confidence indicator (high/medium/low)

**RecurringExpensesList Widget:**
- Lists detected recurring expenses
- Consumes: AIProvider
- Shows: Expense name, amount, frequency, next expected date

**SpendingPatternsList Widget:**
- Lists detected spending patterns
- Consumes: AIProvider
- Shows: Pattern description, trend indicator, explanation

### Copilot Tab Components

**CopilotScreen Widget:**
- Root widget for Copilot tab
- Consumes: AIProvider, TransactionProvider, BudgetProvider, GoalProvider
- Displays: Chat interface with message history

**ChatMessageList Widget:**
- Scrollable list of chat messages
- Displays: User messages, AI responses, timestamps
- Supports: Auto-scroll to latest message

**ChatInputField Widget:**
- Text input for user queries
- Features: Multi-line support, send button, character limit
- Triggers: Send message on button tap or enter key

**SuggestedQuestionsList Widget:**
- Displays suggested questions for first-time users
- Examples: "How much did I spend this month?", "Am I on track with my budget?", "Can I afford a $500 purchase?"
- Triggers: Populate input field on tap

**AIResponseCard Widget:**
- Displays AI response with formatting
- Shows: Response text, confidence indicators, data references
- Supports: Markdown formatting, inline calculations

**LoadingIndicator Widget:**
- Displays while AI processes query
- Animation: Typing indicator or spinner

### Goals Tab Components

**GoalsScreen Widget:**
- Root widget for Goals tab
- Consumes: GoalProvider, AIProvider
- Displays: Active goals list, completed goals section, create goal button

**GoalCard Widget:**
- Displays individual goal with progress
- Shows: Goal name, target amount, current amount, deadline, progress bar
- Calculates: Progress percentage, required monthly savings
- Supports: Tap to view goal details

**GoalDetailScreen Widget:**
- Full-screen view of goal details
- Shows: All goal information, AI feasibility analysis, progress history
- Actions: Update progress, Edit goal, Delete goal, Mark complete

**CreateGoalForm Widget:**
- Form for creating new goal
- Fields: Goal name, target amount, target date, current amount (optional), linked category (optional)
- Validation: Required fields, positive amounts, future dates
- Triggers: Save to GoalService on submit

**GoalProgressChart Widget:**
- Line chart showing progress over time
- X-axis: Time, Y-axis: Saved amount
- Shows: Target line, actual progress line

**AIFeasibilityCard Widget:**
- Displays AI analysis of goal achievability
- Shows: Feasibility status, required monthly savings, spending reduction suggestions
- Consumes: AIProvider

**GoalPrioritizationCard Widget:**
- Displays when multiple goals exist
- Shows: Recommended priority order, conflict warnings
- Consumes: AIProvider

### Profile Tab Components

**ProfileScreen Widget:**
- Root widget for Profile tab
- Consumes: AuthProvider, ThemeProvider, UserProvider
- Displays: User info, settings sections, logout button

**UserInfoCard Widget:**
- Displays user name and email
- Actions: Edit profile button

**EditProfileForm Widget:**
- Form for updating user information
- Fields: Name, email
- Validation: Required fields, valid email format
- Triggers: Email verification on email change

**SettingsSection Widget:**
- Groups related settings
- Sections: Appearance, Preferences, Budgets & Categories, Data & Privacy

**CurrencySelector Widget:**
- Dropdown for currency selection
- Options: USD, EUR, GBP, JPY, etc.
- Triggers: Update all monetary displays on change

**ThemeSelector Widget:**
- Segmented control for theme selection
- Options: Light, Dark, System
- Triggers: Immediate theme change

**BudgetManagementScreen Widget:**
- Full-screen view for managing budgets
- Displays: List of budgets, create budget button
- Actions: Edit budget, Delete budget

**CategoryManagementScreen Widget:**
- Full-screen view for managing categories
- Displays: List of categories, create category button
- Actions: Edit category, Delete category (with reassignment)

**DataExportButton Widget:**
- Button to trigger data export
- Generates: CSV file with all user data
- Triggers: File download or share sheet

**PrivacySettingsScreen Widget:**
- Full-screen view for privacy settings
- Options: Enable/disable AI features, notification preferences
- Triggers: Update user preferences

**AccountDeletionButton Widget:**
- Button to delete account
- Triggers: Confirmation dialog, then account deletion

### Service Interfaces

**AIService:**
```dart
class AIService {
  // Generate financial summary for home tab
  Future<AISummary> generateFinancialSummary({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });

  // Predict end-of-month spending
  Future<SpendingPrediction> predictMonthEndSpending({
    required String userId,
    required DateTime targetMonth,
  });

  // Detect spending patterns
  Future<List<SpendingPattern>> detectSpendingPatterns({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });

  // Detect recurring expenses
  Future<List<RecurringExpense>> detectRecurringExpenses({
    required String userId,
  });

  // Process copilot query
  Future<AIResponse> processCopilotQuery({
    required String userId,
    required String query,
    required List<ChatMessage> conversationHistory,
  });

  // Analyze goal feasibility
  Future<GoalFeasibilityAnalysis> analyzeGoalFeasibility({
    required String userId,
    required Goal goal,
  });

  // Suggest spending reductions for goal
  Future<List<SpendingReduction>> suggestSpendingReductions({
    required String userId,
    required double targetSavings,
  });

  // Prioritize multiple goals
  Future<GoalPrioritization> prioritizeGoals({
    required String userId,
    required List<Goal> goals,
  });
}
```

**InsightService:**
```dart
class InsightService {
  // Calculate spending by category
  Future<Map<String, double>> calculateSpendingByCategory({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });

  // Calculate spending trend
  Future<List<TrendDataPoint>> calculateSpendingTrend({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    required TrendGranularity granularity, // daily, weekly, monthly
  });

  // Calculate budget utilization
  Future<Map<String, double>> calculateBudgetUtilization({
    required String userId,
    required DateTime month,
  });

  // Detect spending anomalies
  Future<List<SpendingAnomaly>> detectAnomalies({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });
}
```

**GoalService:**
```dart
class GoalService {
  // Create new goal
  Future<Goal> createGoal({
    required String userId,
    required String name,
    required double targetAmount,
    required DateTime targetDate,
    double currentAmount = 0.0,
    String? linkedCategoryId,
  });

  // Update goal progress
  Future<Goal> updateGoalProgress({
    required String goalId,
    required double newAmount,
  });

  // Calculate required monthly savings
  double calculateRequiredMonthlySavings({
    required double targetAmount,
    required double currentAmount,
    required DateTime targetDate,
  });

  // Get goal progress percentage
  double calculateProgressPercentage({
    required double currentAmount,
    required double targetAmount,
  });

  // Mark goal as complete
  Future<Goal> markGoalComplete({
    required String goalId,
  });

  // Delete goal
  Future<void> deleteGoal({
    required String goalId,
  });

  // Get all goals for user
  Future<List<Goal>> getUserGoals({
    required String userId,
    bool includeCompleted = false,
  });

  // Update goal from linked transactions
  Future<Goal> syncGoalFromTransactions({
    required String goalId,
  });
}
```

**NotificationService:**
```dart
class NotificationService {
  // Send budget alert
  Future<void> sendBudgetAlert({
    required String userId,
    required Budget budget,
    required double utilizationPercentage,
  });

  // Send recurring expense reminder
  Future<void> sendRecurringExpenseReminder({
    required String userId,
    required RecurringExpense expense,
    required int daysUntilDue,
  });

  // Send goal deadline alert
  Future<void> sendGoalDeadlineAlert({
    required String userId,
    required Goal goal,
    required int daysRemaining,
  });

  // Send unusual spending alert
  Future<void> sendUnusualSpendingAlert({
    required String userId,
    required SpendingAnomaly anomaly,
  });

  // Get notification preferences
  Future<NotificationPreferences> getNotificationPreferences({
    required String userId,
  });

  // Update notification preferences
  Future<void> updateNotificationPreferences({
    required String userId,
    required NotificationPreferences preferences,
  });
}
```

**SyncService:**
```dart
class SyncService {
  // Queue operation for sync
  Future<void> queueOperation({
    required SyncOperation operation,
  });

  // Process sync queue
  Future<SyncResult> processSyncQueue();

  // Check if data is stale
  bool isDataStale({
    required DateTime lastSyncTime,
  });

  // Force sync all data
  Future<SyncResult> forceSyncAll({
    required String userId,
  });

  // Get sync status
  Future<SyncStatus> getSyncStatus();
}
```

## Data Models

### Core Models (Existing - Extended)

**Transaction (Extended):**
```dart
class Transaction {
  final String id;
  final String userId;
  final double amount;
  final String categoryId;
  final DateTime date;
  final String? description;
  final TransactionType type; // income or expense
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced; // NEW: for offline support
  final String? linkedGoalId; // NEW: for automatic goal tracking
}

enum TransactionType {
  income,
  expense,
}
```

**Budget (Extended):**
```dart
class Budget {
  final String id;
  final String userId;
  final String categoryId;
  final double monthlyLimit;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive; // NEW: for soft deletion
}
```

### New Models

**Goal:**
```dart
class Goal {
  final String id;
  final String userId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isCompleted;
  final String? linkedCategoryId; // for automatic tracking
  final bool isManualTracking; // true if user overrides automatic tracking
  
  // Calculated fields (not stored)
  double get progressPercentage => (currentAmount / targetAmount) * 100;
  double get requiredMonthlySavings {
    final now = DateTime.now();
    final monthsRemaining = (targetDate.year - now.year) * 12 + 
                           (targetDate.month - now.month);
    if (monthsRemaining <= 0) return 0;
    return (targetAmount - currentAmount) / monthsRemaining;
  }
  int get daysRemaining => targetDate.difference(DateTime.now()).inDays;
}
```

**AISummary:**
```dart
class AISummary {
  final String summaryText; // natural language summary
  final double totalSpending;
  final double totalIncome;
  final String topSpendingCategory;
  final double topSpendingAmount;
  final List<String> insights; // key insights
  final List<SpendingAnomaly> anomalies;
  final DateTime generatedAt;
  final int confidenceScore; // 0-100
  final bool hasInsufficientData;
}
```

**SpendingPrediction:**
```dart
class SpendingPrediction {
  final double predictedAmount;
  final DateTime targetDate;
  final int confidenceScore; // 0-100
  final String explanation; // why this prediction
  final double lowerBound; // confidence interval
  final double upperBound; // confidence interval
  final List<String> assumptions; // what the prediction assumes
  final DateTime generatedAt;
}
```

**SpendingPattern:**
```dart
class SpendingPattern {
  final String patternType; // increasing, decreasing, weekend_heavy, etc.
  final String categoryId;
  final String description; // plain language explanation
  final double magnitude; // percentage change or difference
  final int confidenceScore; // 0-100
  final DateTime detectedAt;
}
```

**RecurringExpense:**
```dart
class RecurringExpense {
  final String id;
  final String categoryId;
  final String description;
  final double averageAmount;
  final int frequencyDays; // average days between occurrences
  final DateTime lastOccurrence;
  final DateTime nextExpectedDate;
  final int confidenceScore; // 0-100
  final List<String> transactionIds; // supporting evidence
}
```

**ChatMessage:**
```dart
class ChatMessage {
  final String id;
  final String userId;
  final String content;
  final MessageRole role; // user or assistant
  final DateTime timestamp;
  final Map<String, dynamic>? metadata; // for storing references, calculations
}

enum MessageRole {
  user,
  assistant,
}
```

**AIResponse:**
```dart
class AIResponse {
  final String responseText;
  final int confidenceScore; // 0-100
  final List<DataReference> dataReferences; // what data was used
  final List<String> calculations; // show your work
  final bool requiresClarification;
  final List<String>? clarifyingQuestions;
  final DateTime generatedAt;
}
```

**DataReference:**
```dart
class DataReference {
  final String type; // transaction, budget, goal
  final String id;
  final String description; // human-readable reference
}
```

**GoalFeasibilityAnalysis:**
```dart
class GoalFeasibilityAnalysis {
  final String goalId;
  final bool isAchievable;
  final double requiredMonthlySavings;
  final double averageMonthlySurplus;
  final FeasibilityLevel feasibilityLevel; // easy, moderate, challenging, unrealistic
  final List<SpendingReduction> suggestedReductions;
  final String explanation;
  final int confidenceScore; // 0-100
  final DateTime analyzedAt;
}

enum FeasibilityLevel {
  easy,
  moderate,
  challenging,
  unrealistic,
}
```

**SpendingReduction:**
```dart
class SpendingReduction {
  final String categoryId;
  final double currentMonthlySpending;
  final double suggestedReduction;
  final double newMonthlySpending;
  final String rationale; // why this category
  final bool isEssential; // flag essential categories
}
```

**GoalPrioritization:**
```dart
class GoalPrioritization {
  final List<PrioritizedGoal> prioritizedGoals;
  final bool hasConflicts;
  final String? conflictExplanation;
  final double totalRequiredMonthlySavings;
  final double availableMonthlySurplus;
  final DateTime analyzedAt;
}
```

**PrioritizedGoal:**
```dart
class PrioritizedGoal {
  final String goalId;
  final int priority; // 1 = highest
  final String rationale; // why this priority
}
```

**SpendingAnomaly:**
```dart
class SpendingAnomaly {
  final String transactionId;
  final String categoryId;
  final double amount;
  final DateTime date;
  final String anomalyType; // unusually_high, unusual_category, unusual_timing
  final String explanation;
  final double deviationFromNormal; // how much it differs
  final int confidenceScore; // 0-100
}
```

**TrendDataPoint:**
```dart
class TrendDataPoint {
  final DateTime date;
  final double amount;
  final String? label; // optional label for the point
}
```

**NotificationPreferences:**
```dart
class NotificationPreferences {
  final String userId;
  final bool budgetAlerts;
  final bool recurringExpenseReminders;
  final bool goalDeadlineAlerts;
  final bool unusualSpendingAlerts;
  final DateTime updatedAt;
}
```

**SyncOperation:**
```dart
class SyncOperation {
  final String id;
  final String operationType; // create, update, delete
  final String entityType; // transaction, budget, goal
  final String entityId;
  final Map<String, dynamic> data;
  final DateTime queuedAt;
  final int retryCount;
  final SyncStatus status;
}

enum SyncStatus {
  pending,
  inProgress,
  completed,
  failed,
}
```

**SyncResult:**
```dart
class SyncResult {
  final int successCount;
  final int failureCount;
  final List<String> failedOperationIds;
  final DateTime syncedAt;
}
```

### Database Schema (Supabase)

**Tables:**

```sql
-- goals table
CREATE TABLE goals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  target_amount DECIMAL(10, 2) NOT NULL,
  current_amount DECIMAL(10, 2) DEFAULT 0,
  target_date TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  is_completed BOOLEAN DEFAULT FALSE,
  linked_category_id UUID REFERENCES categories(id),
  is_manual_tracking BOOLEAN DEFAULT FALSE
);

-- chat_messages table
CREATE TABLE chat_messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
  timestamp TIMESTAMP DEFAULT NOW(),
  metadata JSONB
);

-- notification_preferences table
CREATE TABLE notification_preferences (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  budget_alerts BOOLEAN DEFAULT TRUE,
  recurring_expense_reminders BOOLEAN DEFAULT TRUE,
  goal_deadline_alerts BOOLEAN DEFAULT TRUE,
  unusual_spending_alerts BOOLEAN DEFAULT TRUE,
  updated_at TIMESTAMP DEFAULT NOW()
);

-- sync_queue table (local only, not in Supabase)
-- Stored in local SQLite for offline support
CREATE TABLE sync_queue (
  id TEXT PRIMARY KEY,
  operation_type TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  data TEXT NOT NULL, -- JSON string
  queued_at INTEGER NOT NULL,
  retry_count INTEGER DEFAULT 0,
  status TEXT NOT NULL
);
```

**Indexes:**
```sql
CREATE INDEX idx_goals_user_id ON goals(user_id);
CREATE INDEX idx_goals_target_date ON goals(target_date);
CREATE INDEX idx_chat_messages_user_id ON chat_messages(user_id);
CREATE INDEX idx_chat_messages_timestamp ON chat_messages(timestamp);
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*


### Property 1: Financial Calculations Are Accurate

*For any* set of transactions and budgets, all financial calculations (monthly spending, monthly income, budget utilization, goal progress, required savings) should use exact database values and produce mathematically correct results according to their formulas.

**Validates: Requirements 1.2, 1.3, 1.4, 9.7, 9.8, 9.12, 10.2**

### Property 2: Budget Threshold Logic Is Correct

*For any* budget and associated transactions, the system should correctly identify when utilization crosses thresholds (80% for warnings, 100% for critical alerts) and trigger appropriate indicators and notifications.

**Validates: Requirements 1.5, 1.6, 19.1, 19.2**

### Property 3: Transaction Selection and Ordering Is Correct

*For any* set of transactions, when selecting the N most recent transactions or filtering by criteria (date range, category, etc.), the returned transactions should match the selection criteria and be correctly ordered.

**Validates: Requirements 1.7, 3.3, 3.6**

### Property 4: AI Top Category Identification Is Accurate

*For any* set of transactions grouped by category, when the AI identifies the top spending category, it should be the category with the highest total spending amount.

**Validates: Requirements 2.3, 7.4**

### Property 5: AI Anomaly Detection Is Grounded

*For any* detected spending anomaly, the anomaly should deviate from normal patterns by a measurable amount (e.g., beyond 2 standard deviations), and the system should provide the deviation magnitude.

**Validates: Requirements 2.4**

### Property 6: AI Predictions Are Properly Labeled

*For any* AI-generated prediction or estimate, the output should clearly distinguish it from factual statements using explicit labels like "Predicted", "Estimated", or qualifying phrases like "based on your patterns".

**Validates: Requirements 2.7, 8.6**

### Property 7: Low-Confidence Insights Are Filtered

*For any* AI-generated insight with a confidence score below the threshold (e.g., 60%), the system should either omit the insight or explicitly communicate the low confidence to the user.

**Validates: Requirements 2.8, 4.5, 5.8, 7.8, 8.7**

### Property 8: Category Spending Aggregation Is Correct

*For any* set of transactions and time period, the spending breakdown by category should sum to the total spending, and each category's percentage should equal (category_amount / total_spending) * 100.

**Validates: Requirements 3.1, 3.5**

### Property 9: AI Predictions Require Sufficient Data

*For any* prediction request, the AI should only generate predictions when at least 30 days of transaction history exists; otherwise, it should return a message indicating insufficient data.

**Validates: Requirements 4.2, 20.4**

### Property 10: Confidence Scores Are Valid

*For any* AI-generated output with a confidence score, the score should be an integer between 0 and 100 inclusive.

**Validates: Requirements 4.4**

### Property 11: Recurring Expense Detection Requires Multiple Occurrences

*For any* detected recurring expense, there should be at least 2 transactions with similar amounts (within a tolerance) and similar timing intervals supporting the detection.

**Validates: Requirements 4.8, 20.5**

### Property 12: Outliers Are Excluded From Pattern Analysis

*For any* dataset used for pattern analysis or average calculations, values beyond 2 standard deviations from the mean should be excluded from the analysis.

**Validates: Requirements 4.10, 20.6**

### Property 13: Spending Trend Detection Uses Correct Thresholds

*For any* category being analyzed for trends, an increasing trend should only be flagged when spending increases by more than 20% compared to the previous period, and a decreasing trend should only be flagged when spending decreases by more than 20%.

**Validates: Requirements 5.2, 5.4**

### Property 14: Weekend vs Weekday Pattern Detection Uses Correct Threshold

*For any* spending pattern analysis, a weekend vs weekday spending difference should only be reported when the difference exceeds 30% of total spending.

**Validates: Requirements 5.6**

### Property 15: AI Uses Only User's Own Data

*For any* AI operation (query processing, insight generation, advice), the system should only access and use data belonging to the authenticated user, never data from other users.

**Validates: Requirements 6.5, 6.6, 6.7, 7.1, 7.3, 8.1, 8.9, 20.1, 20.9**

### Property 16: AI Cannot Find Data Response Is Explicit

*For any* AI query where the requested data does not exist in the database, the response should explicitly state that the information is not available rather than guessing or approximating.

**Validates: Requirements 6.9, 7.10, 8.3**

### Property 17: AI Calculations Are Transparent

*For any* AI response that includes calculations or numerical reasoning, the response should show the specific numbers used in the calculation so users can verify the math.

**Validates: Requirements 7.6**

### Property 18: AI Transaction Amount Verification

*For any* transaction amount referenced by the AI, the amount should exactly match the stored value in the database (verified by transaction ID lookup).

**Validates: Requirements 8.2, 20.7**

### Property 19: Goal Progress Percentage Is Correct

*For any* goal, the displayed progress percentage should equal (current_amount / target_amount) * 100, rounded to an appropriate precision.

**Validates: Requirements 9.12**

### Property 20: Required Monthly Savings Calculation Is Correct

*For any* goal, the required monthly savings should equal (target_amount - current_amount) / months_remaining, where months_remaining is calculated from the current date to the target date.

**Validates: Requirements 9.8**

### Property 21: Goal State Transitions Are Correct

*For any* goal, when marked as complete, it should move from the active goals list to the completed goals list and maintain all its data.

**Validates: Requirements 9.10**

### Property 22: Goal Feasibility Analysis Uses Correct Formula

*For any* goal feasibility analysis, the average monthly surplus should be calculated as average_income - average_spending over the analysis period, and a goal should be flagged as challenging when required_monthly_savings > average_monthly_surplus.

**Validates: Requirements 10.2, 10.3**

### Property 23: Spending Reduction Suggestions Target High-Spending Non-Essential Categories

*For any* spending reduction suggestion, the suggested categories should be among the highest-spending categories and should not include categories marked as essential.

**Validates: Requirements 10.5**

### Property 24: Behind-Schedule Goals Recalculate Required Savings

*For any* goal where current_amount < expected_amount_at_current_date, the system should recalculate required monthly savings as (target_amount - current_amount) / remaining_months.

**Validates: Requirements 10.7**

### Property 25: Multi-Goal Conflict Detection

*For any* user with multiple goals, when the sum of all required_monthly_savings exceeds the average_monthly_surplus, the system should flag a conflict and suggest prioritization.

**Validates: Requirements 10.9, 10.10**

### Property 26: Automatic Goal Progress Tracking Is Accurate

*For any* goal linked to a transaction category, the goal's current_amount should equal the sum of all transactions in that category since the goal's creation date, updated automatically when transactions are added, modified, or deleted.

**Validates: Requirements 11.2, 11.3, 11.4, 11.5, 11.8**

### Property 27: Manual Override Disables Automatic Tracking

*For any* goal where the user manually updates the current_amount, automatic tracking should be disabled (is_manual_tracking = true) until the user explicitly re-enables it.

**Validates: Requirements 11.6**

### Property 28: Category Name Uniqueness Is Enforced

*For any* user, all category names should be unique (case-insensitive comparison), and attempts to create duplicate category names should be rejected with a validation error.

**Validates: Requirements 13.9**

### Property 29: Category Deletion Requires Transaction Reassignment

*For any* category with existing transactions, deletion should be blocked until all transactions are reassigned to a different category, ensuring no orphaned transactions.

**Validates: Requirements 13.10**

### Property 30: Data Export Completeness

*For any* data export request, the generated CSV file should contain all transactions, budgets, and goals belonging to the user, with no data omitted.

**Validates: Requirements 14.2**

### Property 31: Cross-Tab Data Consistency

*For any* data modification (transaction add/edit/delete, budget modify, goal update), all affected displays across all tabs should reflect the updated data, maintaining consistency throughout the application.

**Validates: Requirements 15.1, 15.2, 15.3, 15.5**

### Property 32: Currency Preference Propagation

*For any* currency preference change, all monetary values displayed throughout the application should be updated to use the new currency symbol and formatting.

**Validates: Requirements 15.4**

### Property 33: Recurring Expense Reminder Timing

*For any* detected recurring expense, when the next expected date is within 3 days, a reminder notification should be sent to the user (if notifications are enabled).

**Validates: Requirements 19.3**

### Property 34: Goal Deadline Alert Conditions

*For any* goal where the deadline is approaching and current_amount < expected_amount_at_current_date, a notification should be sent to alert the user they are behind schedule.

**Validates: Requirements 19.4**

### Property 35: Unusual Spending Alerts Are Triggered

*For any* detected spending anomaly (as defined by the anomaly detection algorithm), a notification should be sent to the user with details about the unusual spending.

**Validates: Requirements 19.5**

### Property 36: AI Data Scope Is Correct

*For any* AI insight generation, the system should use transaction data from the last 12 months by default, or all available data if less than 12 months exists.

**Validates: Requirements 20.2, 20.3**

### Property 37: Data Deletion Propagates to AI

*For any* data deletion operation, the deleted data should be immediately excluded from all future AI processing, ensuring the AI never references deleted transactions, budgets, or goals.

**Validates: Requirements 20.10**

## Error Handling

### Error Categories

**1. Network Errors:**
- Connection timeout
- Server unavailable
- Request failed

**Handling:**
- Display user-friendly error message: "Unable to connect. Please check your internet connection."
- For write operations: Queue in sync queue for retry
- For read operations: Fall back to cached data if available
- Provide retry button

**2. Validation Errors:**
- Invalid input (negative amounts, past dates for goals, etc.)
- Missing required fields
- Duplicate names (categories)

**Handling:**
- Display specific error message near the relevant field
- Prevent form submission until errors are corrected
- Highlight invalid fields in red
- Provide guidance on how to fix the error

**3. Data Errors:**
- Corrupted data
- Missing expected data
- Inconsistent state

**Handling:**
- Log error details for debugging
- Attempt automatic recovery where possible
- Notify user if data loss occurred
- Provide option to export data before attempting recovery

**4. AI Errors:**
- AI service unavailable
- AI response timeout
- AI response parsing error
- Insufficient data for AI operation

**Handling:**
- Fall back to displaying factual data only
- Display message: "AI insights temporarily unavailable"
- For Copilot: Display error message and suggest trying again
- Never show partial or corrupted AI responses

**5. Authentication Errors:**
- Session expired
- Invalid credentials
- Token refresh failed

**Handling:**
- Preserve unsaved changes in local storage
- Redirect to login screen
- After re-authentication, restore unsaved changes
- Display message: "Your session has expired. Please log in again."

### Edge Case Handling

**New Users (No Data):**
- Display welcoming empty states with clear guidance
- Suggest first actions: "Add your first transaction", "Create a budget"
- Hide AI features that require historical data
- Show tutorial or onboarding hints

**Insufficient Data for AI:**
- Display message explaining how much more data is needed
- Example: "Add 20 more days of transactions to see spending predictions"
- Show progress indicator: "15 of 30 days needed for predictions"
- Continue showing factual data and manual calculations

**Irregular Income:**
- AI should detect income variability (coefficient of variation > 0.3)
- Use median instead of mean for income calculations
- Widen confidence intervals for predictions
- Explicitly state: "Your income varies, so predictions have higher uncertainty"

**Large Transactions:**
- Detect outliers (> 2 standard deviations from mean)
- Exclude from pattern analysis unless marked as recurring
- Flag in UI: "This is an unusually large transaction"
- Ask user: "Is this a one-time purchase or recurring expense?"

**Division by Zero:**
- When calculating percentages or ratios, check for zero denominators
- Return 0 or null as appropriate
- Example: Budget utilization when limit is 0 → display "No limit set"
- Never crash or show "Infinity" or "NaN" to users

**Sync Conflicts:**
- Use last-write-wins strategy based on updated_at timestamp
- Log conflicts for debugging
- In rare cases of simultaneous edits, prefer server version
- Notify user if local changes were overwritten

**Deleted Data References:**
- When displaying historical data that references deleted categories/budgets
- Show placeholder: "[Deleted Category]" instead of crashing
- Maintain data integrity: Don't cascade delete transactions when category is deleted
- Allow viewing historical data even after deletion

## Testing Strategy

### Dual Testing Approach

The testing strategy employs both unit tests and property-based tests to ensure comprehensive coverage:

**Unit Tests:**
- Verify specific examples and edge cases
- Test error conditions and validation logic
- Test UI component rendering and interactions
- Test integration points between services
- Focus on concrete scenarios that demonstrate correct behavior

**Property-Based Tests:**
- Verify universal properties across all inputs
- Test calculations with randomized data
- Test AI behavior with varied datasets
- Ensure data consistency across operations
- Run minimum 100 iterations per property test

### Property-Based Testing Configuration

**Library:** Use `faker` for Dart/Flutter to generate random test data

**Test Structure:**
Each property test should:
1. Generate random valid inputs (transactions, budgets, goals, user data)
2. Execute the operation being tested
3. Assert that the property holds
4. Run for at least 100 iterations
5. Include a comment tag referencing the design property

**Tag Format:**
```dart
// Feature: main-app-tabs-and-features, Property 1: Financial Calculations Are Accurate
test('financial calculations use exact values', () {
  // Property-based test implementation
});
```

### Test Coverage by Component

**Home Tab:**
- Unit tests: Empty states, navigation, UI rendering
- Property tests: Financial calculations (Property 1), budget thresholds (Property 2), transaction selection (Property 3)

**Insights Tab:**
- Unit tests: Chart rendering, filter UI, empty states
- Property tests: Category aggregation (Property 8), trend detection (Property 13, 14), data filtering (Property 3)

**Copilot Tab:**
- Unit tests: Chat UI, message display, suggested questions
- Property tests: AI data usage (Property 15), calculation transparency (Property 17), amount verification (Property 18)

**Goals Tab:**
- Unit tests: Form validation, UI state transitions
- Property tests: Progress calculations (Property 19, 20), automatic tracking (Property 26), feasibility analysis (Property 22)

**Profile Tab:**
- Unit tests: Settings UI, form validation, navigation
- Property tests: Category uniqueness (Property 28), data export completeness (Property 30)

**AI Engine:**
- Unit tests: Error handling, insufficient data cases, specific query examples
- Property tests: Data isolation (Property 15), confidence scoring (Property 7, 10), prediction labeling (Property 6)

**Cross-Cutting:**
- Unit tests: Sync queue, offline mode, error messages
- Property tests: Data consistency (Property 31), currency propagation (Property 32), notification triggers (Property 33-35)

### Testing Balance

- Avoid writing too many unit tests for scenarios covered by property tests
- Property tests handle comprehensive input coverage through randomization
- Unit tests should focus on:
  - Specific examples that clarify expected behavior
  - Edge cases that are hard to generate randomly
  - Error conditions and validation
  - Integration between components
- Each correctness property from the design should have exactly one property-based test

### Mock Data Generation

**For Property Tests:**
- Generate realistic transaction amounts: $1 - $10,000
- Generate realistic dates: within last 2 years
- Generate varied categories: 5-15 categories per user
- Generate varied transaction frequencies: daily, weekly, monthly
- Include edge cases: zero amounts, same-day transactions, large outliers

**For Unit Tests:**
- Use fixed, predictable test data
- Include boundary values: 0, negative, very large numbers
- Include special cases: empty lists, single items, maximum limits
- Test with minimal and maximal data sets

### Continuous Testing

- Run unit tests on every commit
- Run property tests nightly (due to longer execution time)
- Monitor test execution time and optimize slow tests
- Maintain test coverage above 80% for business logic
- Track property test failure rates to identify flaky tests
