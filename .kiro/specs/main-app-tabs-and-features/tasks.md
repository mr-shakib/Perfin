# Implementation Plan: Main App Tabs and Features

## Overview

This implementation plan breaks down the Perfin main app tabs and features into discrete coding tasks. The approach follows a bottom-up strategy: build core data models and services first, then implement tab-specific features, and finally integrate AI capabilities and cross-cutting concerns. Each task builds on previous work to ensure incremental progress with no orphaned code.

## Tasks

- [x] 1. Set up core data models and database schema
  - Create Goal model with all fields and calculated properties
  - Create AISummary, SpendingPrediction, SpendingPattern, RecurringExpense models
  - Create ChatMessage, AIResponse, DataReference models
  - Create GoalFeasibilityAnalysis, SpendingReduction, GoalPrioritization models
  - Create SpendingAnomaly, TrendDataPoint, NotificationPreferences models
  - Create SyncOperation, SyncResult models
  - Extend existing Transaction model with isSynced and linkedGoalId fields
  - Extend existing Budget model with isActive field
  - Create Supabase migration scripts for new tables (goals, chat_messages, notification_preferences)
  - Create local SQLite schema for sync_queue table
  - _Requirements: 9.1-9.12, 11.1-11.8, 6.1-6.10, 16.1-16.9_

- [ ]* 1.1 Write property tests for data models
  - **Property 19: Goal Progress Percentage Is Correct**
  - **Validates: Requirements 9.12**
  - **Property 20: Required Monthly Savings Calculation Is Correct**
  - **Validates: Requirements 9.8**

- [x] 2. Implement core services layer
  - [x] 2.1 Implement InsightService with all calculation methods
    - calculateSpendingByCategory: aggregate transactions by category for date range
    - calculateSpendingTrend: generate time series data points
    - calculateBudgetUtilization: compute utilization percentages
    - detectAnomalies: identify unusual transactions using statistical methods
    - _Requirements: 3.1-3.9, 1.2-1.4_
  
  - [ ]* 2.2 Write property tests for InsightService
    - **Property 1: Financial Calculations Are Accurate**
    - **Validates: Requirements 1.2, 1.3, 1.4**
    - **Property 8: Category Spending Aggregation Is Correct**
    - **Validates: Requirements 3.1, 3.5**
  
  - [x] 2.3 Implement GoalService with CRUD and calculation methods
    - createGoal: validate and create new goal
    - updateGoalProgress: update current amount and recalculate
    - calculateRequiredMonthlySavings: implement formula
    - calculateProgressPercentage: implement formula
    - markGoalComplete: transition to completed state
    - deleteGoal: remove goal
    - getUserGoals: fetch all goals for user
    - syncGoalFromTransactions: automatic tracking logic
    - _Requirements: 9.1-9.12, 11.1-11.8_
  
  - [ ]* 2.4 Write property tests for GoalService
    - **Property 20: Required Monthly Savings Calculation Is Correct**
    - **Validates: Requirements 9.8**
    - **Property 21: Goal State Transitions Are Correct**
    - **Validates: Requirements 9.10**
    - **Property 26: Automatic Goal Progress Tracking Is Accurate**
    - **Validates: Requirements 11.2, 11.3, 11.4, 11.5, 11.8**
    - **Property 27: Manual Override Disables Automatic Tracking**
    - **Validates: Requirements 11.6**
  
  - [x] 2.5 Implement NotificationService
    - sendBudgetAlert: trigger notification for budget thresholds
    - sendRecurringExpenseReminder: trigger notification for upcoming expenses
    - sendGoalDeadlineAlert: trigger notification for behind-schedule goals
    - sendUnusualSpendingAlert: trigger notification for anomalies
    - getNotificationPreferences: fetch user preferences
    - updateNotificationPreferences: save user preferences
    - _Requirements: 19.1-19.10_
  
  - [ ]* 2.6 Write property tests for NotificationService
    - **Property 2: Budget Threshold Logic Is Correct**
    - **Validates: Requirements 1.5, 1.6, 19.1, 19.2**
    - **Property 33: Recurring Expense Reminder Timing**
    - **Validates: Requirements 19.3**
    - **Property 34: Goal Deadline Alert Conditions**
    - **Validates: Requirements 19.4**
    - **Property 35: Unusual Spending Alerts Are Triggered**
    - **Validates: Requirements 19.5**
  
  - [x] 2.7 Implement SyncService for offline support
    - queueOperation: add operation to sync queue
    - processSyncQueue: attempt to sync all queued operations
    - isDataStale: check if cached data needs refresh
    - forceSyncAll: manually trigger full sync
    - getSyncStatus: get current sync state
    - Implement exponential backoff retry logic (3 attempts)
    - _Requirements: 16.1-16.9_

- [x] 3. Implement AI Engine service
  - [x] 3.1 Implement AIService core infrastructure
    - Set up connection to AI provider (OpenAI, Anthropic, or local model)
    - Use Groq API with your own API key (set in .env file as GROQ_API_KEY)
    - Implement prompt templates for different AI operations
    - Implement confidence score calculation logic
    - Implement data verification methods (verify transaction IDs, amounts)
    - Implement outlier detection (2 standard deviations)
    - _Requirements: 20.1-20.10, 8.1-8.10_
  
  - [ ]* 3.2 Write property tests for AI data usage
    - **Property 15: AI Uses Only User's Own Data**
    - **Validates: Requirements 6.5, 6.6, 6.7, 7.1, 7.3, 8.1, 8.9, 20.1, 20.9**
    - **Property 18: AI Transaction Amount Verification**
    - **Validates: Requirements 8.2, 20.7**
    - **Property 36: AI Data Scope Is Correct**
    - **Validates: Requirements 20.2, 20.3**
    - **Property 37: Data Deletion Propagates to AI**
    - **Validates: Requirements 20.10**
  
  - [x] 3.3 Implement AI financial summary generation
    - generateFinancialSummary: create natural language summary
    - Include current vs previous month comparison
    - Identify top spending category
    - Detect and highlight anomalies
    - Handle insufficient data case (< 10 transactions)
    - Label anomalies as "unusual" not "wrong"
    - Distinguish predictions from facts
    - Filter low-confidence insights
    - _Requirements: 2.1-2.8_
  
  - [ ]* 3.4 Write property tests for AI summary
    - **Property 4: AI Top Category Identification Is Accurate**
    - **Validates: Requirements 2.3, 7.4**
    - **Property 5: AI Anomaly Detection Is Grounded**
    - **Validates: Requirements 2.4**
    - **Property 6: AI Predictions Are Properly Labeled**
    - **Validates: Requirements 2.7, 8.6**
    - **Property 7: Low-Confidence Insights Are Filtered**
    - **Validates: Requirements 2.8, 4.5, 5.8, 7.8, 8.7**
  
  - [x] 3.4 Implement AI spending predictions
    - predictMonthEndSpending: generate end-of-month prediction
    - Require minimum 30 days of data
    - Calculate confidence score
    - Display low confidence warning when < 60%
    - Label predictions explicitly
    - Exclude outliers from pattern analysis
    - _Requirements: 4.1-4.10_
  
  - [ ]* 3.5 Write property tests for predictions
    - **Property 9: AI Predictions Require Sufficient Data**
    - **Validates: Requirements 4.2, 20.4**
    - **Property 10: Confidence Scores Are Valid**
    - **Validates: Requirements 4.4**
    - **Property 12: Outliers Are Excluded From Pattern Analysis**
    - **Validates: Requirements 4.10, 20.6**
  
  - [x] 3.6 Implement AI pattern detection
    - detectSpendingPatterns: identify trends and patterns
    - detectRecurringExpenses: find recurring transactions
    - Implement increasing/decreasing trend detection (20% threshold)
    - Implement weekend vs weekday pattern detection (30% threshold)
    - Require minimum 3 data points for patterns
    - Require minimum 2 occurrences for recurring expenses
    - Communicate uncertainty for highly variable spending
    - _Requirements: 5.1-5.8, 4.7-4.8_
  
  - [ ]* 3.7 Write property tests for pattern detection
    - **Property 11: Recurring Expense Detection Requires Multiple Occurrences**
    - **Validates: Requirements 4.8, 20.5**
    - **Property 13: Spending Trend Detection Uses Correct Thresholds**
    - **Validates: Requirements 5.2, 5.4**
    - **Property 14: Weekend vs Weekday Pattern Detection Uses Correct Threshold**
    - **Validates: Requirements 5.6**
  
  - [x] 3.8 Implement AI Copilot query processing
    - processCopilotQuery: handle natural language queries
    - Query transaction data for spending questions
    - Query budget data for budget questions
    - Query goal data for goal questions
    - Ask clarifying questions for ambiguous queries
    - State missing information explicitly
    - Display suggested questions for first-time users
    - _Requirements: 6.1-6.10_
  
  - [ ]* 3.9 Write property tests for Copilot
    - **Property 16: AI Cannot Find Data Response Is Explicit**
    - **Validates: Requirements 6.9, 7.10, 8.3**
    - **Property 17: AI Calculations Are Transparent**
    - **Validates: Requirements 7.6**
  
  - [x] 3.10 Implement AI goal insights
    - analyzeGoalFeasibility: determine if goal is achievable
    - suggestSpendingReductions: identify categories to reduce
    - prioritizeGoals: handle multiple goals
    - Calculate average monthly surplus
    - Flag challenging goals
    - Identify non-essential high-spending categories
    - Calculate new required savings when behind
    - Detect multi-goal conflicts
    - _Requirements: 10.1-10.10_
  
  - [ ]* 3.11 Write property tests for goal insights
    - **Property 22: Goal Feasibility Analysis Uses Correct Formula**
    - **Validates: Requirements 10.2, 10.3**
    - **Property 23: Spending Reduction Suggestions Target High-Spending Non-Essential Categories**
    - **Validates: Requirements 10.5**
    - **Property 24: Behind-Schedule Goals Recalculate Required Savings**
    - **Validates: Requirements 10.7**
    - **Property 25: Multi-Goal Conflict Detection**
    - **Validates: Requirements 10.9, 10.10**

- [x] 4. Checkpoint - Ensure all service tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 5. Implement Home Tab UI
  - [x] 5.1 Create HomeScreen widget with layout
    - Set up tab structure and navigation
    - Create main scrollable layout
    - Wire up BudgetProvider, TransactionProvider, AIProvider
    - _Requirements: 1.1-1.10_
  
  - [x] 5.2 Implement FinancialSummaryCard widget
    - Display current balance, monthly income, monthly spending
    - Calculate sums from TransactionProvider
    - Handle loading and error states
    - _Requirements: 1.1-1.3_
  
  - [x] 5.3 Implement BudgetStatusList widget
    - Display all active budgets with utilization bars
    - Calculate utilization percentages
    - Show color-coded indicators (green/yellow/red)
    - Handle empty state (no budgets)
    - _Requirements: 1.4-1.6_
  
  - [ ]* 5.4 Write property tests for budget display
    - **Property 2: Budget Threshold Logic Is Correct**
    - **Validates: Requirements 1.5, 1.6**
  
  - [x] 5.5 Implement AISummaryCard widget
    - Display AI-generated summary from AIProvider
    - Show insights and anomalies
    - Handle loading state
    - Handle insufficient data state
    - Handle AI error state (fall back to factual data)
    - _Requirements: 2.1-2.8_
  
  - [x] 5.6 Implement RecentTransactionsList widget
    - Display last 3 transactions
    - Support tap to navigate to detail view
    - Handle empty state
    - _Requirements: 1.7-1.8_
  
  - [ ]* 5.7 Write property tests for transaction selection
    - **Property 3: Transaction Selection and Ordering Is Correct**
    - **Validates: Requirements 1.7**
  
  - [x] 5.8 Implement QuickActionButtons widget
    - Add transaction button
    - View all transactions button
    - Create budget button
    - Wire up navigation
    - _Requirements: 1.9_
  
  - [ ]* 5.9 Write unit tests for Home Tab
    - Test empty states
    - Test navigation
    - Test error handling

- [x] 6. Implement Insights Tab UI
  - [x] 6.1 Create InsightsScreen widget with layout
    - Set up tab structure
    - Create main scrollable layout
    - Wire up TransactionProvider, AIProvider, InsightProvider
    - _Requirements: 3.1-3.9_
  
  - [x] 6.2 Implement TimePeriodSelector widget
    - Create dropdown/segmented control
    - Options: current month, last month, last 3 months, last 6 months, last year
    - Trigger data refresh on selection change
    - Default to current month
    - _Requirements: 3.2-3.4_
  
  - [x] 6.3 Implement SpendingBreakdownChart widget
    - Create pie/donut chart using fl_chart package
    - Show category breakdown with percentages
    - Support tap to drill down
    - Handle empty state
    - _Requirements: 3.1, 3.5-3.6_
  
  - [x] 6.4 Implement SpendingTrendChart widget
    - Create line/bar chart using fl_chart package
    - Show spending over time
    - Aggregate by day or week based on period
    - Handle empty state
    - _Requirements: 3.7_
  
  - [x] 6.5 Implement PredictionCard widget
    - Display end-of-month prediction
    - Show confidence score with visual indicator
    - Show explanation
    - Handle insufficient data state
    - _Requirements: 4.1-4.6_
  
  - [x] 6.6 Implement RecurringExpensesList widget
    - Display detected recurring expenses
    - Show amount, frequency, next expected date
    - Handle empty state
    - _Requirements: 4.7-4.8_
  
  - [x] 6.7 Implement SpendingPatternsList widget
    - Display detected patterns
    - Show trend indicators
    - Show explanations
    - Handle empty state
    - _Requirements: 5.1-5.8_
  
  - [ ]* 6.8 Write unit tests for Insights Tab
    - Test chart rendering
    - Test filter functionality
    - Test empty states

- [x] 7. Implement Copilot Tab UI
  - [x] 7.1 Create CopilotScreen widget with layout
    - Set up tab structure
    - Create chat interface layout
    - Wire up AIProvider, TransactionProvider, BudgetProvider, GoalProvider
    - _Requirements: 6.1-6.10_
  
  - [x] 7.2 Implement ChatMessageList widget
    - Scrollable list of messages
    - Display user and assistant messages
    - Show timestamps
    - Auto-scroll to latest message
    - _Requirements: 6.1, 6.4_
  
  - [x] 7.3 Implement ChatInputField widget
    - Multi-line text input
    - Send button
    - Character limit
    - Handle enter key
    - _Requirements: 6.2_
  
  - [x] 7.4 Implement SuggestedQuestionsList widget
    - Display suggested questions for first-time users
    - Populate input on tap
    - Examples: "How much did I spend this month?", "Am I on track with my budget?"
    - _Requirements: 6.10_
  
  - [x] 7.5 Implement AIResponseCard widget
    - Display AI response with formatting
    - Show confidence indicators
    - Show data references
    - Support markdown formatting
    - Show calculations inline
    - _Requirements: 7.1-7.10_
  
  - [x] 7.6 Implement LoadingIndicator widget
    - Typing indicator animation
    - Show while AI processes query
    - _Requirements: 6.3_
  
  - [ ]* 7.7 Write unit tests for Copilot Tab
    - Test message display
    - Test input handling
    - Test suggested questions

- [ ] 8. Implement Goals Tab UI
  - [ ] 8.1 Create GoalsScreen widget with layout
    - Set up tab structure
    - Create scrollable layout
    - Wire up GoalProvider, AIProvider
    - Display active goals list
    - Display completed goals section
    - Create goal button
    - _Requirements: 9.1-9.12_
  
  - [ ] 8.2 Implement GoalCard widget
    - Display goal name, target amount, current amount, deadline
    - Show progress bar
    - Calculate and display progress percentage
    - Calculate and display required monthly savings
    - Support tap to view details
    - _Requirements: 9.1, 9.12_
  
  - [ ] 8.3 Implement GoalDetailScreen widget
    - Full-screen view of goal details
    - Show all goal information
    - Show AI feasibility analysis
    - Show progress history chart
    - Actions: Update progress, Edit goal, Delete goal, Mark complete
    - _Requirements: 9.1-9.12, 10.1-10.10_
  
  - [ ] 8.4 Implement CreateGoalForm widget
    - Form fields: name, target amount, target date, current amount (optional), linked category (optional)
    - Validation: required fields, positive amounts, future dates
    - Save to GoalService on submit
    - _Requirements: 9.2-9.6_
  
  - [ ]* 8.5 Write unit tests for goal validation
    - Test required field validation
    - Test past date rejection
    - Test zero/negative amount rejection
  
  - [ ] 8.6 Implement GoalProgressChart widget
    - Line chart showing progress over time
    - X-axis: time, Y-axis: saved amount
    - Show target line and actual progress line
    - _Requirements: 9.1-9.12_
  
  - [ ] 8.7 Implement AIFeasibilityCard widget
    - Display feasibility status
    - Show required monthly savings
    - Show spending reduction suggestions
    - _Requirements: 10.1-10.10_
  
  - [ ] 8.8 Implement GoalPrioritizationCard widget
    - Display when multiple goals exist
    - Show recommended priority order
    - Show conflict warnings
    - _Requirements: 10.9-10.10_
  
  - [ ]* 8.9 Write unit tests for Goals Tab
    - Test form submission
    - Test goal state transitions
    - Test empty states

- [ ] 9. Implement Profile Tab UI
  - [ ] 9.1 Create ProfileScreen widget with layout
    - Set up tab structure
    - Create scrollable layout
    - Wire up AuthProvider, ThemeProvider, UserProvider
    - Display user info
    - Display settings sections
    - Logout button
    - _Requirements: 12.1-12.10_
  
  - [ ] 9.2 Implement UserInfoCard widget
    - Display user name and email
    - Edit profile button
    - _Requirements: 12.1-12.2_
  
  - [ ] 9.3 Implement EditProfileForm widget
    - Form fields: name, email
    - Validation: required fields, valid email format
    - Trigger email verification on email change
    - _Requirements: 12.3-12.4_
  
  - [ ] 9.4 Implement SettingsSection widget
    - Group related settings
    - Sections: Appearance, Preferences, Budgets & Categories, Data & Privacy
    - _Requirements: 12.1-12.10_
  
  - [ ] 9.5 Implement CurrencySelector widget
    - Dropdown for currency selection
    - Options: USD, EUR, GBP, JPY, etc.
    - Trigger update all monetary displays on change
    - _Requirements: 12.5-12.6_
  
  - [ ]* 9.6 Write property tests for currency propagation
    - **Property 32: Currency Preference Propagation**
    - **Validates: Requirements 15.4**
  
  - [ ] 9.7 Implement ThemeSelector widget
    - Segmented control for theme selection
    - Options: Light, Dark, System
    - Trigger immediate theme change
    - _Requirements: 12.7-12.8_
  
  - [ ] 9.8 Implement BudgetManagementScreen widget
    - Full-screen view for managing budgets
    - List of budgets
    - Create budget button
    - Edit budget action
    - Delete budget action (with confirmation)
    - _Requirements: 13.1-13.7_
  
  - [ ] 9.9 Implement CategoryManagementScreen widget
    - Full-screen view for managing categories
    - List of categories
    - Create category button
    - Edit category action
    - Delete category action (with reassignment)
    - _Requirements: 13.8-13.10_
  
  - [ ]* 9.10 Write property tests for category management
    - **Property 28: Category Name Uniqueness Is Enforced**
    - **Validates: Requirements 13.9**
    - **Property 29: Category Deletion Requires Transaction Reassignment**
    - **Validates: Requirements 13.10**
  
  - [ ] 9.11 Implement DataExportButton widget
    - Button to trigger data export
    - Generate CSV file with all user data
    - Trigger file download or share sheet
    - _Requirements: 14.1-14.4_
  
  - [ ]* 9.12 Write property tests for data export
    - **Property 30: Data Export Completeness**
    - **Validates: Requirements 14.2**
  
  - [ ] 9.13 Implement PrivacySettingsScreen widget
    - Full-screen view for privacy settings
    - Options: Enable/disable AI features, notification preferences
    - Update user preferences
    - _Requirements: 14.5-14.8_
  
  - [ ] 9.14 Implement AccountDeletionButton widget
    - Button to delete account
    - Confirmation dialog
    - Explain data will be permanently deleted
    - _Requirements: 14.9-14.10_
  
  - [ ]* 9.15 Write unit tests for Profile Tab
    - Test form validation
    - Test settings updates
    - Test confirmation dialogs

- [ ] 10. Implement cross-cutting concerns
  - [ ] 10.1 Implement data consistency logic
    - Set up Provider listeners for cross-tab updates
    - Implement notifyListeners calls in all services
    - Ensure transaction add/edit/delete updates all affected displays
    - Ensure budget modify updates Home Tab
    - Ensure goal update refreshes Goals Tab and AI insights
    - _Requirements: 15.1-15.6_
  
  - [ ]* 10.2 Write property tests for data consistency
    - **Property 31: Cross-Tab Data Consistency**
    - **Validates: Requirements 15.1, 15.2, 15.3, 15.5**
  
  - [ ] 10.3 Implement offline mode and sync
    - Implement local storage caching
    - Implement sync queue processing
    - Implement automatic sync on connection restore
    - Implement sync indicator UI
    - Implement retry logic with exponential backoff
    - Handle sync failures gracefully
    - Display offline indicator when no connection
    - Display AI unavailable message when offline
    - Display stale data warning when cache > 24 hours
    - _Requirements: 16.1-16.9_
  
  - [ ] 10.4 Implement error handling
    - Implement network error handling with user-friendly messages
    - Implement validation error display near fields
    - Implement data error recovery
    - Implement AI error fallback to factual data
    - Implement session expiration handling with unsaved changes preservation
    - Implement division by zero handling
    - Implement sync conflict resolution (last-write-wins)
    - _Requirements: 17.1-17.10_
  
  - [ ]* 10.5 Write unit tests for error handling
    - Test network error messages
    - Test validation error display
    - Test AI fallback behavior
    - Test session expiration handling
  
  - [ ] 10.6 Implement performance optimizations
    - Implement pagination for transaction lists (50 per page)
    - Implement auto-load on scroll to end
    - Optimize queries for > 1000 transactions
    - Implement chart rendering optimization
    - Ensure tab navigation < 300ms
    - Ensure transaction save < 500ms
    - Ensure AI insights < 3 seconds (with progress indicator)
    - Ensure app start < 2 seconds
    - _Requirements: 18.1-18.9_
  
  - [ ] 10.7 Implement notification system
    - Set up Flutter local notifications
    - Implement notification scheduling
    - Implement notification tap handling (navigate to relevant tab)
    - Implement notification logging to prevent duplicates
    - Wire up NotificationService to trigger notifications
    - _Requirements: 19.1-19.10_

- [ ] 11. Final checkpoint - Integration and testing
  - [ ] 11.1 Integration testing
    - Test complete user flows across all tabs
    - Test data consistency across tabs
    - Test offline mode and sync
    - Test AI features end-to-end
    - Test notification delivery
    - _Requirements: All_
  
  - [ ]* 11.2 Run all property tests
    - Ensure all 37 properties pass
    - Run with minimum 100 iterations each
    - Fix any failures
  
  - [ ]* 11.3 Run all unit tests
    - Ensure all unit tests pass
    - Verify edge cases are handled
    - Verify error conditions are handled
  
  - [ ] 11.4 Performance testing
    - Test with large datasets (> 1000 transactions)
    - Verify performance requirements are met
    - Optimize any slow operations
    - _Requirements: 18.1-18.9_
  
  - [ ] 11.5 Final review and polish
    - Review all UI for consistency
    - Review all error messages for clarity
    - Review all empty states
    - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties
- Unit tests validate specific examples and edge cases
- The implementation follows a bottom-up approach: data models → services → UI → integration
- All AI features include guardrails and error handling
- Offline support is built in from the start
- Performance requirements are validated in the final checkpoint
