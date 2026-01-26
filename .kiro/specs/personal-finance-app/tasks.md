# Implementation Plan: Personal Finance App

## Overview

This implementation plan breaks down the personal finance app into incremental, testable steps following clean architecture principles. Each task builds on previous work, starting with core infrastructure, then data models, services, providers, and finally UI components. The implementation uses Flutter with Provider for state management and Hive for local storage.

## Tasks

- [x] 1. Set up project infrastructure and dependencies
  - Add required packages to pubspec.yaml: provider, hive, hive_flutter, path_provider
  - Initialize Hive storage in main.dart
  - Set up project folder structure: lib/models, lib/services, lib/providers, lib/screens, lib/widgets
  - Create constants file for app-wide values (categories, colors, etc.)
  - _Requirements: 11.6, 7.4_

- [ ] 2. Implement core data models
  - [x] 2.1 Create User model with JSON serialization
    - Define User class with id, name, email, createdAt fields
    - Implement toJson() and fromJson() methods
    - _Requirements: 1.5_

  - [x] 2.2 Create Transaction model with validation
    - Define Transaction class with all required fields
    - Implement TransactionType enum (income, expense)
    - Add isValid() validation method
    - Implement toJson() and fromJson() methods
    - _Requirements: 2.4_

  - [ ]* 2.3 Write property test for Transaction model
    - **Property 9: Transaction Contains Required Fields**
    - **Validates: Requirements 2.4**

  - [x] 2.4 Create Budget model with JSON serialization
    - Define Budget class with id, userId, amount, year, month fields
    - Implement toJson() and fromJson() methods
    - _Requirements: 5.1_

  - [x] 2.5 Create MonthlySummary model
    - Define MonthlySummary class with aggregated financial data
    - Include year, month, totalIncome, totalExpense, balance, expensesByCategory
    - _Requirements: 4.4_

  - [ ]* 2.6 Write property test for model serialization
    - **Property 11: Data Persistence Round-Trip (models only)**
    - **Validates: Requirements 2.7, 7.4**

- [x] 3. Implement validation logic
  - [x] 3.1 Create TransactionValidator
    - Implement validate() method checking amount > 0
    - Check category is not empty
    - Check date is not in future
    - Return ValidationResult with errors list
    - _Requirements: 2.5, 2.6_

  - [ ]* 3.2 Write property test for transaction validation
    - **Property 10: Invalid Transactions Are Rejected**
    - **Validates: Requirements 2.5, 2.6**

  - [x] 3.3 Create BudgetValidator
    - Implement validate() method checking amount > 0
    - Check month is between 1 and 12
    - Return ValidationResult with errors list
    - _Requirements: 5.1_

  - [ ]* 3.4 Write unit tests for validators
    - Test specific edge cases (zero amount, empty category, future dates)
    - Test boundary values (month 0, 13)
    - _Requirements: 2.5, 2.6, 5.1_

- [x] 4. Implement storage layer
  - [x] 4.1 Create StorageService interface
    - Define abstract class with init, save, load, delete, clear methods
    - Use generic types for flexibility
    - _Requirements: 7.1, 7.2, 7.3_

  - [x] 4.2 Implement HiveStorageService
    - Implement StorageService interface using Hive
    - Handle initialization and box management
    - Implement error handling for storage operations
    - _Requirements: 7.1, 7.2, 7.3_

  - [ ]* 4.3 Write property test for storage round-trip
    - **Property 11: Data Persistence Round-Trip**
    - **Validates: Requirements 7.4**

  - [ ]* 4.4 Write unit tests for storage error handling
    - Test storage failures and error messages
    - Test retry logic
    - _Requirements: 7.5_

- [x] 5. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 6. Implement AuthService
  - [x] 6.1 Create AuthService class
    - Implement authenticate() method (mock authentication for now)
    - Implement saveSession() using StorageService
    - Implement loadSession() from StorageService
    - Implement clearSession()
    - _Requirements: 1.1, 1.2, 1.3_

  - [ ]* 6.2 Write property test for session round-trip
    - **Property 1: Authentication Session Round-Trip**
    - **Validates: Requirements 1.3, 7.1, 7.4**

  - [ ]* 6.3 Write property test for authentication
    - **Property 2: Valid Credentials Establish Session**
    - **Property 4: Invalid Credentials Return Error**
    - **Validates: Requirements 1.1, 1.4, 1.5**

- [x] 7. Implement AuthProvider
  - [x] 7.1 Create AuthProvider with ChangeNotifier
    - Define private state: _user, _state, _errorMessage
    - Implement getters: user, isAuthenticated, state, errorMessage
    - Implement login() method with error handling
    - Implement logout() method
    - Implement restoreSession() method
    - Use AuthService for all operations
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

  - [ ]* 7.2 Write property test for logout
    - **Property 3: Logout Clears Session**
    - **Validates: Requirements 1.2**

  - [ ]* 7.3 Write unit tests for AuthProvider error states
    - Test loading states during async operations
    - Test error message display
    - _Requirements: 8.1, 8.2_

- [x] 8. Implement TransactionService
  - [x] 8.1 Create TransactionService class
    - Implement fetchTransactions() using StorageService
    - Implement saveTransaction() with validation
    - Implement updateTransaction() with validation
    - Implement deleteTransaction()
    - Handle storage errors appropriately
    - _Requirements: 2.1, 2.2, 2.3, 2.7_

  - [ ]* 8.2 Write property tests for transaction operations
    - **Property 6: Transaction Addition Grows List**
    - **Property 7: Transaction Update Modifies Values**
    - **Property 8: Transaction Deletion Removes From List**
    - **Validates: Requirements 2.1, 2.2, 2.3**

- [x] 9. Implement derived state calculations
  - [x] 9.1 Create calculation utility functions
    - Implement calculateBalance() function
    - Implement calculateExpensesByCategory() function
    - Implement calculateMonthlySummary() function
    - Implement calculateMonthlyTrends() function
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 6.1, 6.2_

  - [ ]* 9.2 Write property test for balance calculation
    - **Property 14: Balance Equals Income Minus Expense**
    - **Validates: Requirements 4.1, 4.2, 4.3**

  - [ ]* 9.3 Write property test for monthly summary
    - **Property 15: Monthly Summary Aggregates Correctly**
    - **Validates: Requirements 4.4**

  - [ ]* 9.4 Write property test for category aggregation
    - **Property 20: Expense Category Aggregation**
    - **Validates: Requirements 6.1**

  - [ ]* 9.5 Write property test for monthly trends
    - **Property 21: Monthly Trend Calculation**
    - **Validates: Requirements 6.2**

- [x] 10. Implement TransactionProvider
  - [x] 10.1 Create TransactionProvider with ChangeNotifier
    - Define private state: _transactions, _state, _errorMessage
    - Implement getters for transactions, state, errorMessage
    - Implement derived state getters: currentBalance, totalIncome, totalExpense, expensesByCategory, monthlyTrends, currentMonthSummary
    - Implement loadTransactions() with error handling
    - Implement addTransaction() with validation and persistence
    - Implement updateTransaction() with validation and persistence
    - Implement deleteTransaction() with persistence
    - Implement getTransactionsByDateRange() helper
    - _Requirements: 2.1, 2.2, 2.3, 2.7, 4.1, 4.2, 4.3, 4.4, 4.5, 6.1, 6.2_

  - [ ]* 10.2 Write property test for derived state updates
    - **Property 16: Derived State Updates With Transactions**
    - **Validates: Requirements 4.5**

  - [ ]* 10.3 Write property test for transaction ordering
    - **Property 12: Transaction History Ordered By Date**
    - **Validates: Requirements 3.1**

- [x] 11. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 12. Implement BudgetService
  - [x] 12.1 Create BudgetService class
    - Implement fetchMonthlyBudget() using StorageService
    - Implement fetchCategoryBudgets() using StorageService
    - Implement saveBudget() with validation
    - Implement saveCategoryBudget() with validation
    - Handle storage errors appropriately
    - _Requirements: 5.1, 5.2, 5.5_

  - [ ]* 12.2 Write property test for budget storage
    - **Property 17: Budget Storage And Retrieval**
    - **Validates: Requirements 5.1, 5.2**

- [x] 13. Implement BudgetProvider
  - [x] 13.1 Create BudgetProvider with ChangeNotifier
    - Define private state: _monthlyBudget, _categoryBudgets, _state, _errorMessage
    - Implement getters for budgets, state, errorMessage
    - Implement derived state getters: remainingBudget, categoryBudgetStatus, isOverBudget
    - Implement loadBudgets() with error handling
    - Implement setMonthlyBudget() with validation and persistence
    - Implement setCategoryBudget() with validation and persistence
    - Implement getBudgetStatusForCategory() helper
    - Inject TransactionProvider to access expense data
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

  - [ ]* 13.2 Write property test for remaining budget
    - **Property 18: Remaining Budget Calculation**
    - **Validates: Requirements 5.3**

  - [ ]* 13.3 Write property test for over-budget detection
    - **Property 19: Over-Budget Detection**
    - **Validates: Requirements 5.4**

- [x] 14. Implement ThemeService and ThemeProvider
  - [x] 14.1 Create ThemeService class
    - Implement loadThemePreference() using StorageService
    - Implement saveThemePreference() using StorageService
    - _Requirements: 9.3, 9.4_

  - [x] 14.2 Create ThemeProvider with ChangeNotifier
    - Define private state: _themeMode
    - Implement getters: themeMode, isDarkMode
    - Implement toggleTheme() with persistence
    - Implement setTheme() with persistence
    - Implement loadTheme() on initialization
    - _Requirements: 9.1, 9.3, 9.4, 9.5_

  - [ ]* 14.3 Write property test for theme persistence
    - **Property 24: Theme Application And Persistence**
    - **Validates: Requirements 9.1, 9.3, 9.4, 9.5**

- [x] 15. Set up provider hierarchy and app structure
  - [x] 15.1 Configure MultiProvider in main.dart
    - Set up ThemeProvider at root
    - Set up AuthProvider
    - Set up TransactionProvider with ProxyProvider depending on AuthProvider
    - Set up BudgetProvider with ProxyProvider depending on AuthProvider
    - Initialize storage before runApp()
    - _Requirements: 11.1, 11.2_

  - [x] 15.2 Create MaterialApp with theme configuration
    - Configure light and dark themes
    - Use ThemeProvider to switch themes
    - Set up named routes
    - Configure initial route based on auth state
    - _Requirements: 9.1, 9.2, 10.2_

  - [ ]* 15.3 Write property test for navigation state preservation
    - **Property 25: Navigation State Preservation**
    - **Validates: Requirements 10.5**

- [x] 16. Implement authentication screens
  - [x] 16.1 Create LoginScreen
    - Build form with email and password fields
    - Add login button that calls AuthProvider.login()
    - Display loading indicator during authentication
    - Display error messages from AuthProvider
    - Navigate to dashboard on successful login
    - _Requirements: 1.1, 1.4, 8.1, 8.2_

  - [x] 16.2 Create SplashScreen
    - Display app logo/name
    - Call AuthProvider.restoreSession() on init
    - Navigate to dashboard if session restored, otherwise to login
    - _Requirements: 1.3_

  - [ ]* 16.3 Write widget tests for login screen
    - Test form validation
    - Test error display
    - Test loading state
    - _Requirements: 1.1, 1.4, 8.1, 8.2_

- [ ] 17. Implement route guards
  - [ ] 17.1 Create AuthGuard widget
    - Check AuthProvider.isAuthenticated
    - Redirect to login if not authenticated
    - Allow access to child widget if authenticated
    - _Requirements: 1.6, 10.3, 10.4_

  - [ ]* 17.2 Write property test for authentication guards
    - **Property 5: Authentication Guards Protected Routes**
    - **Validates: Requirements 1.6, 10.3, 10.4**

- [ ] 18. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 19. Implement dashboard screen
  - [ ] 19.1 Create DashboardScreen with bottom navigation
    - Set up bottom navigation bar with tabs: Dashboard, Transactions, Budget, Analytics, Settings
    - Implement tab switching logic
    - _Requirements: 10.1_

  - [ ] 19.2 Create dashboard overview widgets
    - Create BalanceCard showing current balance
    - Create SummaryCard showing total income and expense
    - Create RecentTransactionsList showing last 5 transactions
    - Use Consumer<TransactionProvider> to access state
    - Display loading indicator when state is loading
    - Display empty state when no transactions exist
    - _Requirements: 4.6, 3.3, 8.1, 8.4_

  - [ ]* 19.3 Write widget tests for dashboard
    - Test balance display
    - Test loading states
    - Test empty states
    - _Requirements: 4.6, 8.1, 8.4_

- [ ] 20. Implement transaction management screens
  - [ ] 20.1 Create TransactionListScreen
    - Display all transactions using ListView
    - Show transactions ordered by date
    - Display amount, category, type, date for each transaction
    - Add floating action button to create new transaction
    - Implement pull-to-refresh
    - Display loading indicator during load
    - Display empty state when no transactions
    - _Requirements: 3.1, 3.2, 3.3, 3.4_

  - [ ]* 20.2 Write property test for transaction display
    - **Property 13: Transaction Display Contains All Fields**
    - **Validates: Requirements 3.2**

  - [ ] 20.3 Create TransactionFormScreen
    - Build form with fields: amount, category (dropdown), type (toggle), date (picker), notes
    - Support both create and edit modes
    - Validate inputs before submission
    - Call TransactionProvider.addTransaction() or updateTransaction()
    - Display validation errors
    - Display loading indicator during save
    - Navigate back on success
    - _Requirements: 2.1, 2.2, 2.5, 2.6, 8.1, 8.2_

  - [ ] 20.4 Add delete functionality to transaction list
    - Add swipe-to-delete or delete button
    - Show confirmation dialog
    - Call TransactionProvider.deleteTransaction()
    - Display error if delete fails
    - _Requirements: 2.3, 8.2_

  - [ ]* 20.5 Write widget tests for transaction screens
    - Test form validation
    - Test create and edit flows
    - Test delete confirmation
    - _Requirements: 2.1, 2.2, 2.3, 2.5, 2.6_

- [ ] 21. Implement budget management screen
  - [ ] 21.1 Create BudgetScreen
    - Display current monthly budget with edit button
    - Show remaining budget calculation
    - Display over-budget alert if expenses exceed budget
    - List category budgets with spent amounts
    - Add ability to set/edit category budgets
    - Use Consumer<BudgetProvider> and Selector for derived state
    - Display loading indicator during load
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 8.1_

  - [ ] 21.2 Create BudgetFormDialog
    - Build form to set monthly or category budget
    - Validate budget amount > 0
    - Call BudgetProvider.setMonthlyBudget() or setCategoryBudget()
    - Display validation errors
    - Close dialog on success
    - _Requirements: 5.1, 5.2_

  - [ ]* 21.3 Write widget tests for budget screen
    - Test budget display
    - Test over-budget alert
    - Test budget form validation
    - _Requirements: 5.1, 5.2, 5.3, 5.4_

- [ ] 22. Implement analytics screen
  - [ ] 22.1 Create AnalyticsScreen
    - Display expense breakdown by category using summary cards or simple charts
    - Display monthly trend summaries
    - Use Selector<TransactionProvider> to access expensesByCategory and monthlyTrends
    - Display loading indicator during load
    - Display empty state when no data
    - _Requirements: 6.3, 6.4, 8.1, 8.4_

  - [ ]* 22.2 Write widget tests for analytics screen
    - Test category breakdown display
    - Test monthly trends display
    - Test empty state
    - _Requirements: 6.3, 6.4_

- [ ] 23. Implement settings screen
  - [ ] 23.1 Create SettingsScreen
    - Display user profile information (name, email)
    - Add theme toggle switch
    - Add logout button
    - Call ThemeProvider.toggleTheme() on switch
    - Call AuthProvider.logout() on logout button
    - Navigate to login screen after logout
    - _Requirements: 1.2, 1.5, 9.1, 9.5_

  - [ ]* 23.2 Write widget tests for settings screen
    - Test theme toggle
    - Test logout flow
    - Test profile display
    - _Requirements: 1.2, 9.1_

- [ ] 24. Implement error handling UI components
  - [ ] 24.1 Create ErrorDisplay widget
    - Display error message
    - Show retry button
    - Accept onRetry callback
    - _Requirements: 8.2, 8.3_

  - [ ] 24.2 Create LoadingIndicator widget
    - Display circular progress indicator
    - Center on screen
    - _Requirements: 8.1_

  - [ ] 24.3 Create EmptyState widget
    - Display icon and message
    - Show guidance text
    - Accept custom message and icon
    - _Requirements: 8.4_

  - [ ]* 24.4 Write property test for async error handling
    - **Property 22: Async Operation Error Handling**
    - **Property 23: Loading State Display**
    - **Validates: Requirements 7.5, 8.1, 8.2, 8.3, 8.5**

- [ ] 25. Final integration and polish
  - [ ] 25.1 Add app-wide error boundary
    - Catch and display uncaught errors gracefully
    - Provide app restart option
    - _Requirements: 8.5_

  - [ ] 25.2 Optimize widget rebuilds
    - Review Consumer usage and replace with Selector where appropriate
    - Ensure derived state is computed in providers, not widgets
    - Add const constructors where possible
    - _Requirements: 12.1, 12.2, 12.3_

  - [ ] 25.3 Test complete user flows
    - Test login → add transaction → view dashboard → logout flow
    - Test budget setting → expense tracking → over-budget alert flow
    - Test theme switching across all screens
    - Test data persistence across app restarts
    - _Requirements: All_

  - [ ]* 25.4 Write integration tests
    - Test complete authentication flow
    - Test transaction CRUD flow
    - Test budget management flow
    - _Requirements: All_

- [ ] 26. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties
- Unit tests validate specific examples and edge cases
- The implementation follows clean architecture: UI → Provider → Service → Storage
- All business logic resides in providers and services, not in widgets
