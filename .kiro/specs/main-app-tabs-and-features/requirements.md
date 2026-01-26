# Requirements Document: Main App Tabs and Features

## Introduction

Perfin is an AI-powered personal finance application that helps users understand their financial situation, predict future outcomes, and make better financial decisions. This specification defines the core functionality for five main application tabs: Home, Insights, Copilot, Goals, and Profile. The system builds upon existing authentication and onboarding infrastructure to deliver a mobile-first experience that prioritizes financial accuracy, transparency, and user trust.

## Glossary

- **Perfin_System**: The complete personal finance application including all tabs and features
- **Home_Tab**: The primary dashboard displaying financial overview and quick actions
- **Insights_Tab**: The analytics interface showing spending patterns and predictions
- **Copilot_Tab**: The AI assistant interface for financial guidance and queries
- **Goals_Tab**: The goal management interface for tracking financial objectives
- **Profile_Tab**: The user settings and preferences interface
- **Transaction**: A financial event representing money movement (income or expense)
- **Budget**: A spending limit defined for a category over a time period
- **Goal**: A financial objective with target amount and deadline
- **AI_Engine**: The intelligent system providing predictions, insights, and recommendations
- **Monthly_Summary**: Aggregated financial data for a calendar month
- **Spending_Pattern**: Recurring or notable behavior in transaction history
- **Prediction**: A forecast of future financial state based on historical data
- **Alert**: A notification about important financial events or anomalies
- **Category**: A classification for transactions (e.g., groceries, rent, salary)
- **Confidence_Score**: A numerical indicator of prediction reliability (0-100%)

## Requirements

### Requirement 1: Home Tab - Financial Overview

**User Story:** As a user, I want to see my current financial status at a glance, so that I can quickly understand my financial health without navigating through multiple screens.

#### Acceptance Criteria

1. WHEN the user opens the Home_Tab, THE Perfin_System SHALL display the current account balance
2. WHEN the user opens the Home_Tab, THE Perfin_System SHALL display total spending for the current month
3. WHEN the user opens the Home_Tab, THE Perfin_System SHALL display total income for the current month
4. WHEN the user opens the Home_Tab, THE Perfin_System SHALL display budget utilization percentage for each active budget category
5. WHEN a budget category exceeds 80% utilization, THE Perfin_System SHALL display a warning indicator
6. WHEN a budget category exceeds 100% utilization, THE Perfin_System SHALL display a critical alert indicator
7. WHEN the user opens the Home_Tab, THE Perfin_System SHALL display the three most recent transactions
8. WHEN the user taps on a transaction, THE Perfin_System SHALL navigate to the transaction detail view
9. WHEN the user opens the Home_Tab, THE Perfin_System SHALL display quick action buttons for adding transactions and viewing all transactions
10. WHEN no transactions exist for the current month, THE Perfin_System SHALL display an empty state message encouraging the user to add transactions

### Requirement 2: Home Tab - AI-Powered Financial Summary

**User Story:** As a user, I want to receive an AI-generated summary of my financial situation, so that I can understand what's happening with my money in plain language.

#### Acceptance Criteria

1. WHEN the user opens the Home_Tab, THE AI_Engine SHALL generate a natural language summary of the current financial state
2. WHEN generating the summary, THE AI_Engine SHALL include total spending compared to the previous month
3. WHEN generating the summary, THE AI_Engine SHALL identify the top spending category for the current month
4. WHEN generating the summary, THE AI_Engine SHALL highlight any unusual spending patterns detected
5. WHEN the user has insufficient transaction history (fewer than 10 transactions), THE AI_Engine SHALL state that more data is needed for meaningful insights
6. WHEN the AI_Engine detects an anomaly, THE Perfin_System SHALL clearly label it as "unusual" rather than "wrong" or "bad"
7. WHEN the summary includes predictions, THE Perfin_System SHALL clearly distinguish predictions from factual statements using phrases like "based on your patterns" or "estimated"
8. WHEN the AI_Engine cannot determine a pattern with confidence, THE Perfin_System SHALL omit that insight rather than speculate

### Requirement 3: Insights Tab - Spending Analysis

**User Story:** As a user, I want to analyze my spending patterns over time, so that I can identify where my money goes and make informed decisions.

#### Acceptance Criteria

1. WHEN the user opens the Insights_Tab, THE Perfin_System SHALL display a breakdown of spending by category for the selected time period
2. WHEN the user opens the Insights_Tab, THE Perfin_System SHALL default to showing the current month's data
3. WHEN the user selects a time period filter, THE Perfin_System SHALL update all visualizations to reflect the selected period
4. THE Perfin_System SHALL support time period filters for: current month, last month, last 3 months, last 6 months, and last year
5. WHEN displaying category breakdown, THE Perfin_System SHALL show both absolute amounts and percentages of total spending
6. WHEN the user taps on a category, THE Perfin_System SHALL display all transactions in that category for the selected period
7. WHEN the user opens the Insights_Tab, THE Perfin_System SHALL display a spending trend chart showing daily or weekly totals
8. WHEN insufficient data exists for the selected period, THE Perfin_System SHALL display a message indicating more data is needed
9. WHEN the user has no transactions, THE Perfin_System SHALL display an empty state with guidance on adding transactions

### Requirement 4: Insights Tab - AI-Powered Spending Predictions

**User Story:** As a user, I want to see predictions about my future spending, so that I can plan ahead and avoid financial surprises.

#### Acceptance Criteria

1. WHEN the user opens the Insights_Tab, THE AI_Engine SHALL generate a prediction for end-of-month spending
2. WHEN generating predictions, THE AI_Engine SHALL use at least 30 days of historical transaction data
3. WHEN the user has fewer than 30 days of data, THE AI_Engine SHALL display a message stating predictions are not yet available
4. WHEN displaying a prediction, THE Perfin_System SHALL show a confidence score as a percentage
5. WHEN the confidence score is below 60%, THE Perfin_System SHALL display a low confidence warning
6. WHEN displaying predictions, THE Perfin_System SHALL clearly label them as "Predicted" or "Estimated"
7. WHEN the AI_Engine identifies recurring expenses, THE Perfin_System SHALL list them separately with their expected dates
8. WHEN a recurring expense is detected, THE AI_Engine SHALL base detection on at least 2 occurrences with similar amounts and timing
9. WHEN the user's income is irregular, THE AI_Engine SHALL account for income variability in spending predictions
10. WHEN generating predictions, THE AI_Engine SHALL exclude one-time large purchases from pattern analysis unless explicitly marked as recurring

### Requirement 5: Insights Tab - Spending Pattern Detection

**User Story:** As a user, I want the system to identify patterns in my spending behavior, so that I can understand my financial habits better.

#### Acceptance Criteria

1. WHEN the AI_Engine analyzes transactions, THE Perfin_System SHALL identify categories with increasing spending trends
2. WHEN a category shows spending increase of more than 20% compared to the previous period, THE Perfin_System SHALL flag it as an increasing trend
3. WHEN the AI_Engine analyzes transactions, THE Perfin_System SHALL identify categories with decreasing spending trends
4. WHEN a category shows spending decrease of more than 20% compared to the previous period, THE Perfin_System SHALL flag it as a decreasing trend
5. WHEN the AI_Engine detects a pattern, THE Perfin_System SHALL provide a plain language explanation of what the pattern means
6. WHEN the AI_Engine identifies weekend vs weekday spending differences, THE Perfin_System SHALL report this pattern if the difference exceeds 30%
7. WHEN insufficient data exists to establish a pattern (fewer than 3 data points), THE AI_Engine SHALL not report a pattern
8. WHEN the user's spending is highly variable, THE AI_Engine SHALL communicate uncertainty rather than forcing a pattern interpretation

### Requirement 6: Copilot Tab - Conversational AI Interface

**User Story:** As a user, I want to ask questions about my finances in natural language, so that I can get personalized guidance without navigating complex menus.

#### Acceptance Criteria

1. WHEN the user opens the Copilot_Tab, THE Perfin_System SHALL display a chat interface with message history
2. WHEN the user types a message, THE Perfin_System SHALL send the message to the AI_Engine for processing
3. WHEN the AI_Engine receives a query, THE Perfin_System SHALL display a loading indicator while processing
4. WHEN the AI_Engine generates a response, THE Perfin_System SHALL display the response in the chat interface
5. WHEN the user asks about spending, THE AI_Engine SHALL query transaction data to provide accurate answers
6. WHEN the user asks about budgets, THE AI_Engine SHALL query budget data to provide current status
7. WHEN the user asks about goals, THE AI_Engine SHALL query goal data to provide progress updates
8. WHEN the user's query is ambiguous, THE AI_Engine SHALL ask clarifying questions before providing an answer
9. WHEN the AI_Engine cannot answer a query with available data, THE Perfin_System SHALL clearly state what information is missing
10. WHEN the user opens the Copilot_Tab for the first time, THE Perfin_System SHALL display suggested questions to help the user get started

### Requirement 7: Copilot Tab - Contextual Financial Guidance

**User Story:** As a user, I want the AI to provide personalized financial advice based on my actual data, so that I receive relevant and actionable guidance.

#### Acceptance Criteria

1. WHEN the AI_Engine provides advice, THE Perfin_System SHALL base recommendations on the user's actual transaction history
2. WHEN the AI_Engine suggests budget adjustments, THE Perfin_System SHALL reference specific spending patterns from the user's data
3. WHEN the AI_Engine provides savings recommendations, THE Perfin_System SHALL calculate suggestions based on actual income and expenses
4. WHEN the user asks for help reducing spending, THE AI_Engine SHALL identify the top 3 categories with highest spending
5. WHEN the AI_Engine makes a recommendation, THE Perfin_System SHALL explain the reasoning behind the recommendation
6. WHEN the AI_Engine references calculations, THE Perfin_System SHALL show the numbers used in the calculation
7. WHEN the user's financial situation is complex, THE AI_Engine SHALL break down advice into simple, actionable steps
8. WHEN the AI_Engine provides predictions in advice, THE Perfin_System SHALL include confidence scores
9. WHEN the user asks about future affordability, THE AI_Engine SHALL use current spending patterns and income to estimate feasibility
10. WHEN the AI_Engine lacks sufficient data for advice, THE Perfin_System SHALL state this limitation clearly

### Requirement 8: Copilot Tab - AI Safety and Guardrails

**User Story:** As a user, I want the AI to be honest about what it knows and doesn't know, so that I can trust the information I receive.

#### Acceptance Criteria

1. WHEN the AI_Engine performs financial calculations, THE Perfin_System SHALL use exact values from the database rather than approximations
2. WHEN the AI_Engine references a transaction amount, THE Perfin_System SHALL verify the amount against stored transaction data
3. WHEN the AI_Engine cannot find requested data, THE Perfin_System SHALL state "I don't have that information" rather than guessing
4. WHEN the user asks about external financial products, THE AI_Engine SHALL decline to provide specific product recommendations
5. WHEN the user asks about investment advice, THE AI_Engine SHALL state that it provides spending insights only, not investment guidance
6. WHEN the AI_Engine makes a prediction, THE Perfin_System SHALL never present it as a guarantee
7. WHEN the AI_Engine detects low confidence in its response, THE Perfin_System SHALL communicate this uncertainty to the user
8. WHEN the user asks about tax implications, THE AI_Engine SHALL recommend consulting a tax professional rather than providing tax advice
9. WHEN the AI_Engine references user data, THE Perfin_System SHALL only use data the user has explicitly provided or imported
10. WHEN the AI_Engine generates text, THE Perfin_System SHALL avoid judgmental language about spending choices

### Requirement 9: Goals Tab - Goal Management

**User Story:** As a user, I want to create and track financial goals, so that I can work toward specific financial objectives.

#### Acceptance Criteria

1. WHEN the user opens the Goals_Tab, THE Perfin_System SHALL display all active goals
2. WHEN the user taps "Create Goal", THE Perfin_System SHALL display a goal creation form
3. WHEN creating a goal, THE Perfin_System SHALL require a goal name, target amount, and target date
4. WHEN creating a goal, THE Perfin_System SHALL allow the user to optionally specify a current saved amount
5. WHEN the user submits a goal with a target date in the past, THE Perfin_System SHALL display a validation error
6. WHEN the user submits a goal with a target amount of zero or negative, THE Perfin_System SHALL display a validation error
7. WHEN a goal is created, THE Perfin_System SHALL calculate the required monthly savings amount
8. WHEN calculating required monthly savings, THE Perfin_System SHALL use the formula: (target_amount - current_amount) / months_remaining
9. WHEN the user updates the current saved amount for a goal, THE Perfin_System SHALL recalculate the required monthly savings
10. WHEN the user marks a goal as complete, THE Perfin_System SHALL move it to a completed goals section
11. WHEN the user deletes a goal, THE Perfin_System SHALL prompt for confirmation before deletion
12. WHEN displaying a goal, THE Perfin_System SHALL show progress as a percentage: (current_amount / target_amount) * 100

### Requirement 10: Goals Tab - AI-Powered Goal Insights

**User Story:** As a user, I want AI-powered insights about my goals, so that I can understand if my goals are realistic and how to achieve them.

#### Acceptance Criteria

1. WHEN the user views a goal, THE AI_Engine SHALL analyze if the goal is achievable based on current spending patterns
2. WHEN analyzing goal feasibility, THE AI_Engine SHALL calculate average monthly surplus: average_income - average_spending
3. WHEN the required monthly savings exceeds the average monthly surplus, THE AI_Engine SHALL flag the goal as challenging
4. WHEN a goal is flagged as challenging, THE Perfin_System SHALL suggest specific spending categories to reduce
5. WHEN suggesting spending reductions, THE AI_Engine SHALL identify non-essential categories with highest spending
6. WHEN the user is on track to meet a goal, THE AI_Engine SHALL provide positive reinforcement
7. WHEN the user is behind on a goal, THE AI_Engine SHALL calculate the new required monthly savings to get back on track
8. WHEN the AI_Engine suggests goal adjustments, THE Perfin_System SHALL provide specific numbers: adjusted target amount or adjusted target date
9. WHEN the user has multiple goals, THE AI_Engine SHALL analyze if all goals can be achieved simultaneously
10. WHEN multiple goals conflict, THE AI_Engine SHALL suggest prioritization based on target dates and importance

### Requirement 11: Goals Tab - Automatic Progress Tracking

**User Story:** As a user, I want my goal progress to update automatically based on my transactions, so that I don't have to manually track savings.

#### Acceptance Criteria

1. WHEN the user creates a goal, THE Perfin_System SHALL allow linking the goal to a specific transaction category
2. WHEN a goal is linked to a category, THE Perfin_System SHALL automatically update goal progress when transactions in that category are added
3. WHEN calculating automatic progress, THE Perfin_System SHALL sum all transactions in the linked category since goal creation
4. WHEN a linked transaction is deleted, THE Perfin_System SHALL recalculate goal progress
5. WHEN a linked transaction is modified, THE Perfin_System SHALL recalculate goal progress
6. WHEN the user manually updates goal progress, THE Perfin_System SHALL override automatic tracking for that goal
7. WHEN automatic tracking is overridden, THE Perfin_System SHALL display an indicator that progress is manually managed
8. WHEN the user re-enables automatic tracking, THE Perfin_System SHALL recalculate progress from linked transactions

### Requirement 12: Profile Tab - User Settings and Preferences

**User Story:** As a user, I want to manage my account settings and preferences, so that I can customize the app to my needs.

#### Acceptance Criteria

1. WHEN the user opens the Profile_Tab, THE Perfin_System SHALL display the user's name and email
2. WHEN the user opens the Profile_Tab, THE Perfin_System SHALL display options to edit profile information
3. WHEN the user taps "Edit Profile", THE Perfin_System SHALL allow updating name and email
4. WHEN the user updates their email, THE Perfin_System SHALL send a verification email to the new address
5. WHEN the user opens the Profile_Tab, THE Perfin_System SHALL display currency preference setting
6. WHEN the user changes currency preference, THE Perfin_System SHALL update all monetary displays throughout the app
7. WHEN the user opens the Profile_Tab, THE Perfin_System SHALL display theme preference setting (light/dark/system)
8. WHEN the user changes theme preference, THE Perfin_System SHALL immediately apply the new theme
9. WHEN the user opens the Profile_Tab, THE Perfin_System SHALL display a logout button
10. WHEN the user taps logout, THE Perfin_System SHALL clear local session data and return to the login screen

### Requirement 13: Profile Tab - Budget and Category Management

**User Story:** As a user, I want to manage my budget categories and limits, so that I can organize my finances according to my needs.

#### Acceptance Criteria

1. WHEN the user opens the Profile_Tab, THE Perfin_System SHALL provide access to budget management
2. WHEN the user accesses budget management, THE Perfin_System SHALL display all active budgets
3. WHEN the user creates a new budget, THE Perfin_System SHALL require a category name and monthly limit
4. WHEN the user submits a budget with a limit of zero or negative, THE Perfin_System SHALL display a validation error
5. WHEN the user edits a budget, THE Perfin_System SHALL allow changing the monthly limit
6. WHEN the user deletes a budget, THE Perfin_System SHALL prompt for confirmation before deletion
7. WHEN a budget is deleted, THE Perfin_System SHALL retain historical spending data for that category
8. WHEN the user accesses category management, THE Perfin_System SHALL display all transaction categories
9. WHEN the user creates a custom category, THE Perfin_System SHALL validate that the category name is unique
10. WHEN the user deletes a category, THE Perfin_System SHALL require reassigning existing transactions to a different category

### Requirement 14: Profile Tab - Data Export and Privacy

**User Story:** As a user, I want to export my financial data and manage my privacy settings, so that I maintain control over my information.

#### Acceptance Criteria

1. WHEN the user opens the Profile_Tab, THE Perfin_System SHALL provide a data export option
2. WHEN the user requests data export, THE Perfin_System SHALL generate a file containing all transactions, budgets, and goals
3. WHEN generating an export file, THE Perfin_System SHALL use CSV format for compatibility
4. WHEN the export is complete, THE Perfin_System SHALL allow the user to download or share the file
5. WHEN the user opens the Profile_Tab, THE Perfin_System SHALL provide access to privacy settings
6. WHEN the user accesses privacy settings, THE Perfin_System SHALL display options to control AI feature usage
7. WHEN the user disables AI features, THE Perfin_System SHALL hide all AI-generated insights and predictions
8. WHEN AI features are disabled, THE Perfin_System SHALL continue to display factual data and manual calculations
9. WHEN the user opens the Profile_Tab, THE Perfin_System SHALL provide an account deletion option
10. WHEN the user requests account deletion, THE Perfin_System SHALL prompt for confirmation and explain that all data will be permanently deleted

### Requirement 15: Cross-Tab Data Consistency

**User Story:** As a user, I want my data to be consistent across all tabs, so that I see accurate information regardless of where I navigate.

#### Acceptance Criteria

1. WHEN a transaction is added in any tab, THE Perfin_System SHALL update all affected displays across all tabs
2. WHEN a budget is modified, THE Perfin_System SHALL recalculate budget utilization on the Home_Tab
3. WHEN a goal is updated, THE Perfin_System SHALL refresh goal displays on both Goals_Tab and any AI-generated insights
4. WHEN the user changes currency preference, THE Perfin_System SHALL update all monetary values across all tabs
5. WHEN a transaction is deleted, THE Perfin_System SHALL update spending totals, budget utilization, and goal progress
6. WHEN the user navigates between tabs, THE Perfin_System SHALL load current data from the database
7. WHEN multiple devices are used, THE Perfin_System SHALL sync data changes within 5 seconds
8. WHEN a sync conflict occurs, THE Perfin_System SHALL use the most recent timestamp to resolve conflicts

### Requirement 16: Offline Functionality and Data Sync

**User Story:** As a user, I want to use the app even without internet connection, so that I can manage my finances anywhere.

#### Acceptance Criteria

1. WHEN the user opens the app without internet connection, THE Perfin_System SHALL load cached data from local storage
2. WHEN the user adds a transaction offline, THE Perfin_System SHALL store it locally and queue for sync
3. WHEN the user modifies data offline, THE Perfin_System SHALL mark the changes for sync when connection is restored
4. WHEN internet connection is restored, THE Perfin_System SHALL automatically sync all queued changes
5. WHEN syncing changes, THE Perfin_System SHALL display a sync indicator
6. WHEN a sync fails, THE Perfin_System SHALL retry up to 3 times with exponential backoff
7. WHEN sync fails after all retries, THE Perfin_System SHALL notify the user and preserve local changes
8. WHEN AI features are accessed offline, THE Perfin_System SHALL display a message that AI features require internet connection
9. WHEN cached data is older than 24 hours, THE Perfin_System SHALL display a warning that data may be outdated

### Requirement 17: Error Handling and Edge Cases

**User Story:** As a user, I want the app to handle errors gracefully, so that I don't lose data or encounter confusing situations.

#### Acceptance Criteria

1. WHEN a network request fails, THE Perfin_System SHALL display a user-friendly error message
2. WHEN a database operation fails, THE Perfin_System SHALL log the error and notify the user
3. WHEN the user has no transactions, THE Perfin_System SHALL display helpful empty states with guidance
4. WHEN the user has no budgets, THE Perfin_System SHALL suggest creating budgets on the Home_Tab
5. WHEN the user has no goals, THE Perfin_System SHALL display an empty state encouraging goal creation
6. WHEN the AI_Engine encounters an error, THE Perfin_System SHALL fall back to displaying factual data only
7. WHEN a calculation results in division by zero, THE Perfin_System SHALL handle the error and display a default value
8. WHEN the user's data is corrupted, THE Perfin_System SHALL attempt recovery and notify the user of any data loss
9. WHEN the user enters invalid input, THE Perfin_System SHALL display specific validation errors near the relevant field
10. WHEN a session expires, THE Perfin_System SHALL prompt the user to log in again without losing unsaved changes

### Requirement 18: Performance and Responsiveness

**User Story:** As a user, I want the app to respond quickly to my actions, so that I can manage my finances efficiently.

#### Acceptance Criteria

1. WHEN the user navigates between tabs, THE Perfin_System SHALL display the new tab within 300 milliseconds
2. WHEN the user adds a transaction, THE Perfin_System SHALL save it and update the UI within 500 milliseconds
3. WHEN the AI_Engine generates insights, THE Perfin_System SHALL display results within 3 seconds
4. WHEN the AI_Engine takes longer than 3 seconds, THE Perfin_System SHALL display a progress indicator
5. WHEN loading transaction history, THE Perfin_System SHALL implement pagination to load 50 transactions at a time
6. WHEN the user scrolls to the end of a list, THE Perfin_System SHALL automatically load the next page
7. WHEN displaying charts, THE Perfin_System SHALL render visualizations within 1 second
8. WHEN the user has more than 1000 transactions, THE Perfin_System SHALL optimize queries to maintain performance
9. WHEN the app starts, THE Perfin_System SHALL display the Home_Tab within 2 seconds on a typical mobile device

### Requirement 19: Notification and Alert System

**User Story:** As a user, I want to receive timely notifications about important financial events, so that I can stay informed without constantly checking the app.

#### Acceptance Criteria

1. WHEN a budget reaches 80% utilization, THE Perfin_System SHALL send a notification to the user
2. WHEN a budget is exceeded, THE Perfin_System SHALL send a notification to the user
3. WHEN a recurring expense is due within 3 days, THE Perfin_System SHALL send a reminder notification
4. WHEN a goal deadline is approaching and the user is behind target, THE Perfin_System SHALL send a notification
5. WHEN the AI_Engine detects unusual spending, THE Perfin_System SHALL send a notification with details
6. WHEN the user opens the Profile_Tab, THE Perfin_System SHALL provide notification preferences
7. WHEN the user accesses notification preferences, THE Perfin_System SHALL allow enabling or disabling each notification type
8. WHEN notifications are disabled for a type, THE Perfin_System SHALL not send notifications of that type
9. WHEN a notification is sent, THE Perfin_System SHALL log it to prevent duplicate notifications
10. WHEN the user taps a notification, THE Perfin_System SHALL navigate to the relevant tab or detail view

### Requirement 20: AI Model Context and Data Usage

**User Story:** As a developer, I want clear rules for how the AI uses user data, so that the system is predictable and trustworthy.

#### Acceptance Criteria

1. WHEN the AI_Engine processes a query, THE Perfin_System SHALL only use data belonging to the authenticated user
2. WHEN the AI_Engine generates insights, THE Perfin_System SHALL use transaction data from the last 12 months by default
3. WHEN the user has less than 12 months of data, THE AI_Engine SHALL use all available data
4. WHEN the AI_Engine makes predictions, THE Perfin_System SHALL require at least 30 days of transaction history
5. WHEN the AI_Engine detects patterns, THE Perfin_System SHALL require at least 3 occurrences of similar transactions
6. WHEN the AI_Engine calculates averages, THE Perfin_System SHALL exclude outliers beyond 2 standard deviations
7. WHEN the AI_Engine references specific transactions, THE Perfin_System SHALL verify transaction IDs exist in the database
8. WHEN the AI_Engine generates text, THE Perfin_System SHALL not store or train on user-specific financial data
9. WHEN the AI_Engine provides advice, THE Perfin_System SHALL base recommendations solely on the user's own data, not aggregate data from other users
10. WHEN the user deletes data, THE AI_Engine SHALL immediately exclude that data from all future processing
