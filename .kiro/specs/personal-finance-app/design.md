# Design Document: Personal Finance App

## Overview

This design specifies a Flutter-based personal finance management application using Provider for state management. The architecture follows clean separation of concerns with distinct layers: UI (widgets), State Management (providers), Business Logic (services), and Data Persistence (storage). The application manages user authentication, financial transactions, budgets, and analytics while demonstrating production-grade patterns including derived state computation, async handling, and performance optimization.

The system is designed to be maintainable, testable, and scalable, with zero business logic in the UI layer and proper provider scoping throughout the widget tree.

## Architecture

### Layered Architecture

```
┌─────────────────────────────────────────┐
│           UI Layer (Widgets)            │
│  - Screens, Forms, Lists, Charts        │
└──────────────┬──────────────────────────┘
               │ Consumer/Selector
┌──────────────▼──────────────────────────┐
│      State Management (Providers)       │
│  - AuthProvider                         │
│  - TransactionProvider                  │
│  - BudgetProvider                       │
│  - ThemeProvider                        │
└──────────────┬──────────────────────────┘
               │ Service calls 
┌──────────────▼──────────────────────────┐
│       Business Logic (Services)         │
│  - AuthService                          │
│  - TransactionService                   │
│  - BudgetService                        │
└──────────────┬──────────────────────────┘
               │ Storage operations
┌──────────────▼──────────────────────────┐
│      Data Layer (Storage/API)           │
│  - Local Storage (Hive/SQLite)          │
│  - Optional: Firebase                   │
└─────────────────────────────────────────┘
```

### Provider Hierarchy

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProxyProvider<AuthProvider, TransactionProvider>(
      create: (_) => TransactionProvider(),
      update: (_, auth, previous) => previous..updateAuth(auth),
    ),
    ChangeNotifierProxyProvider<AuthProvider, BudgetProvider>(
      create: (_) => BudgetProvider(),
      update: (_, auth, previous) => previous..updateAuth(auth),
    ),
  ],
  child: App(),
)
```

## Components and Interfaces

### 1. Authentication Components

#### AuthProvider

```dart
class AuthProvider extends ChangeNotifier {
  User? _user;
  AuthState _state; // idle, loading, authenticated, error
  String? _errorMessage;
  
  // Public getters
  User? get user;
  bool get isAuthenticated;
  AuthState get state;
  String? get errorMessage;
  
  // Methods
  Future<void> login(String email, String password);
  Future<void> logout();
  Future<void> restoreSession();
}
```

#### AuthService

```dart
class AuthService {
  Future<User> authenticate(String email, String password);
  Future<void> saveSession(User user);
  Future<User?> loadSession();
  Future<void> clearSession();
}
```

#### User Model

```dart
class User {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  
  User({required this.id, required this.name, required this.email, required this.createdAt});
  
  Map<String, dynamic> toJson();
  factory User.fromJson(Map<String, dynamic> json);
}
```

### 2. Transaction Components

#### TransactionProvider

```dart
class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions;
  LoadingState _state; // idle, loading, loaded, error
  String? _errorMessage;
  
  // Public getters
  List<Transaction> get transactions;
  LoadingState get state;
  String? get errorMessage;
  
  // Derived state (computed properties)
  double get currentBalance;
  double get totalIncome;
  double get totalExpense;
  Map<String, double> get expensesByCategory;
  List<MonthlySummary> get monthlyTrends;
  MonthlySummary get currentMonthSummary;
  
  // Methods
  Future<void> loadTransactions();
  Future<void> addTransaction(Transaction transaction);
  Future<void> updateTransaction(String id, Transaction transaction);
  Future<void> deleteTransaction(String id);
  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end);
}
```

#### TransactionService

```dart
class TransactionService {
  Future<List<Transaction>> fetchTransactions(String userId);
  Future<void> saveTransaction(Transaction transaction);
  Future<void> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id);
}
```

#### Transaction Model

```dart
enum TransactionType { income, expense }

class Transaction {
  final String id;
  final double amount;
  final String category;
  final TransactionType type;
  final DateTime date;
  final String? notes;
  final String userId;
  
  Transaction({
    required this.id,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
    this.notes,
    required this.userId,
  });
  
  // Validation
  bool isValid();
  
  Map<String, dynamic> toJson();
  factory Transaction.fromJson(Map<String, dynamic> json);
}
```

#### MonthlySummary Model

```dart
class MonthlySummary {
  final int year;
  final int month;
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final Map<String, double> expensesByCategory;
  
  MonthlySummary({
    required this.year,
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.expensesByCategory,
  });
}
```

### 3. Budget Components

#### BudgetProvider

```dart
class BudgetProvider extends ChangeNotifier {
  Budget? _monthlyBudget;
  Map<String, double> _categoryBudgets;
  LoadingState _state;
  String? _errorMessage;
  
  // Public getters
  Budget? get monthlyBudget;
  Map<String, double> get categoryBudgets;
  LoadingState get state;
  String? get errorMessage;
  
  // Derived state
  double get remainingBudget;
  Map<String, BudgetStatus> get categoryBudgetStatus;
  bool get isOverBudget;
  
  // Methods
  Future<void> loadBudgets();
  Future<void> setMonthlyBudget(double amount);
  Future<void> setCategoryBudget(String category, double amount);
  BudgetStatus getBudgetStatusForCategory(String category, double spent);
}
```

#### BudgetService

```dart
class BudgetService {
  Future<Budget?> fetchMonthlyBudget(String userId);
  Future<Map<String, double>> fetchCategoryBudgets(String userId);
  Future<void> saveBudget(Budget budget);
  Future<void> saveCategoryBudget(String category, double amount, String userId);
}
```

#### Budget Models

```dart
class Budget {
  final String id;
  final String userId;
  final double amount;
  final int year;
  final int month;
  
  Budget({
    required this.id,
    required this.userId,
    required this.amount,
    required this.year,
    required this.month,
  });
  
  Map<String, dynamic> toJson();
  factory Budget.fromJson(Map<String, dynamic> json);
}

enum BudgetStatus { underBudget, nearLimit, overBudget }

class CategoryBudgetInfo {
  final String category;
  final double budgetAmount;
  final double spentAmount;
  final double remaining;
  final BudgetStatus status;
  
  CategoryBudgetInfo({
    required this.category,
    required this.budgetAmount,
    required this.spentAmount,
    required this.remaining,
    required this.status,
  });
}
```

### 4. Theme Components

#### ThemeProvider

```dart
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode;
  
  ThemeMode get themeMode;
  bool get isDarkMode;
  
  Future<void> toggleTheme();
  Future<void> setTheme(ThemeMode mode);
  Future<void> loadTheme();
}
```

#### ThemeService

```dart
class ThemeService {
  Future<ThemeMode> loadThemePreference();
  Future<void> saveThemePreference(ThemeMode mode);
}
```

### 5. Storage Layer

#### StorageService Interface

```dart
abstract class StorageService {
  Future<void> init();
  Future<void> save<T>(String key, T value);
  Future<T?> load<T>(String key);
  Future<void> delete(String key);
  Future<void> clear();
}
```

#### Hive Implementation (Primary Choice)

```dart
class HiveStorageService implements StorageService {
  late Box _box;
  
  @override
  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('perfin_storage');
  }
  
  @override
  Future<void> save<T>(String key, T value);
  
  @override
  Future<T?> load<T>(String key);
  
  @override
  Future<void> delete(String key);
  
  @override
  Future<void> clear();
}
```

## Data Models

### Core Data Structures

All models follow these principles:
- Immutable where possible
- Include validation methods
- Provide JSON serialization/deserialization
- Include factory constructors for creation

### Validation Rules

#### Transaction Validation

```dart
class TransactionValidator {
  static ValidationResult validate(Transaction transaction) {
    List<String> errors = [];
    
    if (transaction.amount <= 0) {
      errors.add("Amount must be positive");
    }
    
    if (transaction.category.trim().isEmpty) {
      errors.add("Category is required");
    }
    
    if (transaction.date.isAfter(DateTime.now())) {
      errors.add("Date cannot be in the future");
    }
    
    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }
}
```

#### Budget Validation

```dart
class BudgetValidator {
  static ValidationResult validate(Budget budget) {
    List<String> errors = [];
    
    if (budget.amount <= 0) {
      errors.add("Budget amount must be positive");
    }
    
    if (budget.month < 1 || budget.month > 12) {
      errors.add("Invalid month");
    }
    
    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }
}
```

### Derived State Calculations

#### Balance Calculation

```dart
double calculateBalance(List<Transaction> transactions) {
  double income = transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);
      
  double expense = transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);
      
  return income - expense;
}
```

#### Category Breakdown

```dart
Map<String, double> calculateExpensesByCategory(List<Transaction> transactions) {
  Map<String, double> breakdown = {};
  
  for (var transaction in transactions) {
    if (transaction.type == TransactionType.expense) {
      breakdown[transaction.category] = 
          (breakdown[transaction.category] ?? 0.0) + transaction.amount;
    }
  }
  
  return breakdown;
}
```

#### Monthly Summary

```dart
MonthlySummary calculateMonthlySummary(
  List<Transaction> transactions,
  int year,
  int month,
) {
  var monthTransactions = transactions.where((t) =>
      t.date.year == year && t.date.month == month).toList();
      
  double income = monthTransactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);
      
  double expense = monthTransactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);
      
  return MonthlySummary(
    year: year,
    month: month,
    totalIncome: income,
    totalExpense: expense,
    balance: income - expense,
    expensesByCategory: calculateExpensesByCategory(monthTransactions),
  );
}
```

## Error Handling

### Error Types

```dart
abstract class AppError {
  final String message;
  final String? details;
  
  AppError(this.message, [this.details]);
}

class AuthenticationError extends AppError {
  AuthenticationError(String message, [String? details]) 
      : super(message, details);
}

class ValidationError extends AppError {
  final List<String> validationErrors;
  
  ValidationError(this.validationErrors) 
      : super("Validation failed", validationErrors.join(", "));
}

class StorageError extends AppError {
  StorageError(String message, [String? details]) 
      : super(message, details);
}

class NetworkError extends AppError {
  NetworkError(String message, [String? details]) 
      : super(message, details);
}
```

### Error Handling Pattern

All providers follow this pattern:

```dart
Future<void> performOperation() async {
  _state = LoadingState.loading;
  _errorMessage = null;
  notifyListeners();
  
  try {
    // Perform operation
    await service.doSomething();
    
    _state = LoadingState.loaded;
    notifyListeners();
  } on ValidationError catch (e) {
    _state = LoadingState.error;
    _errorMessage = e.message;
    notifyListeners();
  } on StorageError catch (e) {
    _state = LoadingState.error;
    _errorMessage = "Failed to save data: ${e.message}";
    notifyListeners();
  } catch (e) {
    _state = LoadingState.error;
    _errorMessage = "An unexpected error occurred";
    notifyListeners();
  }
}
```

### UI Error Display

```dart
Widget buildWithErrorHandling(BuildContext context, Widget child) {
  return Consumer<TransactionProvider>(
    builder: (context, provider, _) {
      if (provider.state == LoadingState.error) {
        return ErrorDisplay(
          message: provider.errorMessage ?? "An error occurred",
          onRetry: () => provider.loadTransactions(),
        );
      }
      
      if (provider.state == LoadingState.loading) {
        return LoadingIndicator();
      }
      
      return child;
    },
  );
}
```

## Testing Strategy

### Testing Approach

The application will use a dual testing approach:

1. **Unit Tests**: Verify specific examples, edge cases, and error conditions
2. **Property-Based Tests**: Verify universal properties across all inputs using the `test` package with custom property testing utilities

Both testing approaches are complementary and necessary for comprehensive coverage. Unit tests catch concrete bugs in specific scenarios, while property-based tests verify general correctness across many generated inputs.

### Property-Based Testing Configuration

- Use Dart's `test` package with custom property testing utilities
- Each property test must run minimum 100 iterations
- Each property test must include a comment tag: `// Feature: personal-finance-app, Property {number}: {property_text}`
- Each correctness property must be implemented by a single property-based test

### Test Organization

```
test/
├── unit/
│   ├── models/
│   │   ├── transaction_test.dart
│   │   ├── user_test.dart
│   │   └── budget_test.dart
│   ├── services/
│   │   ├── auth_service_test.dart
│   │   ├── transaction_service_test.dart
│   │   └── budget_service_test.dart
│   └── validators/
│       ├── transaction_validator_test.dart
│       └── budget_validator_test.dart
├── property/
│   ├── transaction_properties_test.dart
│   ├── budget_properties_test.dart
│   └── derived_state_properties_test.dart
├── widget/
│   ├── transaction_form_test.dart
│   ├── dashboard_test.dart
│   └── budget_screen_test.dart
└── integration/
    └── app_flow_test.dart
```

### Testing Focus Areas

#### Unit Tests
- Model validation (specific invalid inputs)
- Service error handling (network failures, storage errors)
- Edge cases (empty lists, zero amounts, boundary dates)
- Specific calculation examples

#### Property-Based Tests
- Universal properties that hold for all valid inputs
- Derived state consistency
- Round-trip serialization
- Invariants across operations

### Mock Strategy

Use minimal mocking:
- Mock storage layer for provider tests
- Mock services for widget tests
- Use real implementations for property tests where possible


## Correctness Properties

A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.

### Property 1: Authentication Session Round-Trip

*For any* valid user session, persisting the session then loading it should restore an equivalent authentication state with the same user information.

**Validates: Requirements 1.3, 7.1, 7.4**

### Property 2: Valid Credentials Establish Session

*For any* valid email and password combination, authenticating should result in an authenticated state with a user session containing the correct profile information (name and email).

**Validates: Requirements 1.1, 1.5**

### Property 3: Logout Clears Session

*For any* authenticated user session, calling logout should clear the session and result in an unauthenticated state.

**Validates: Requirements 1.2**

### Property 4: Invalid Credentials Return Error

*For any* invalid credentials (empty, malformed, or incorrect), authentication should fail and return a descriptive error message without establishing a session.

**Validates: Requirements 1.4**

### Property 5: Authentication Guards Protected Routes

*For any* unauthenticated state, attempting to access protected screens should redirect to the login screen, and *for any* authenticated state, all protected screens should be accessible.

**Validates: Requirements 1.6, 10.3, 10.4**

### Property 6: Transaction Addition Grows List

*For any* valid transaction (positive amount, non-empty category, valid date), adding it to the transaction list should increase the list length by one and the transaction should be retrievable from the list.

**Validates: Requirements 2.1**

### Property 7: Transaction Update Modifies Values

*For any* existing transaction and any valid update data, updating the transaction should result in the transaction reflecting the new values while maintaining the same ID.

**Validates: Requirements 2.2**

### Property 8: Transaction Deletion Removes From List

*For any* transaction in the list, deleting it should remove it from the list and decrease the list length by one.

**Validates: Requirements 2.3**

### Property 9: Transaction Contains Required Fields

*For any* transaction created or retrieved, it should contain amount, category, type, date fields, and optionally notes.

**Validates: Requirements 2.4**

### Property 10: Invalid Transactions Are Rejected

*For any* transaction with non-positive amount or empty required fields, attempting to create or update it should be rejected with a validation error.

**Validates: Requirements 2.5, 2.6**

### Property 11: Data Persistence Round-Trip

*For any* application data (transactions, budgets, theme preferences), persisting the data then loading it should restore equivalent data with the same values.

**Validates: Requirements 2.7, 5.5, 7.2, 7.3, 7.4, 9.3**

### Property 12: Transaction History Ordered By Date

*For any* set of transactions, the displayed transaction history should be ordered by date (most recent first or oldest first consistently).

**Validates: Requirements 3.1**

### Property 13: Transaction Display Contains All Fields

*For any* transaction, the rendered display should contain or provide access to amount, category, type, date, and notes.

**Validates: Requirements 3.2**

### Property 14: Balance Equals Income Minus Expense

*For any* set of transactions, the calculated balance should equal the sum of all income transactions minus the sum of all expense transactions.

**Validates: Requirements 4.1, 4.2, 4.3**

### Property 15: Monthly Summary Aggregates Correctly

*For any* set of transactions and any month/year, the monthly summary should correctly aggregate income, expense, and balance for only the transactions in that month.

**Validates: Requirements 4.4**

### Property 16: Derived State Updates With Transactions

*For any* transaction list and any modification (add, update, delete), the derived state (balance, totals, summaries) should automatically reflect the changes without manual recalculation.

**Validates: Requirements 4.5**

### Property 17: Budget Storage And Retrieval

*For any* valid budget amount (positive value), setting a monthly or category budget should store it and subsequent retrieval should return the same amount.

**Validates: Requirements 5.1, 5.2**

### Property 18: Remaining Budget Calculation

*For any* budget amount and set of expenses, the remaining budget should equal the budget amount minus the total expenses for that budget period or category.

**Validates: Requirements 5.3**

### Property 19: Over-Budget Detection

*For any* state where total expenses exceed the budget amount, the application should indicate an over-budget status.

**Validates: Requirements 5.4**

### Property 20: Expense Category Aggregation

*For any* set of expense transactions, the category breakdown should correctly sum all expenses for each category with no transactions counted multiple times or omitted.

**Validates: Requirements 6.1**

### Property 21: Monthly Trend Calculation

*For any* set of transactions spanning multiple months, the monthly trends should correctly aggregate income and expenses for each month with no overlap or gaps.

**Validates: Requirements 6.2**

### Property 22: Async Operation Error Handling

*For any* asynchronous operation that fails, the application should display a descriptive error message, provide a retry option where appropriate, and maintain a consistent error state.

**Validates: Requirements 7.5, 8.2, 8.3, 8.5**

### Property 23: Loading State Display

*For any* asynchronous operation in progress, the application should display a loading indicator and prevent duplicate operations.

**Validates: Requirements 3.4, 8.1**

### Property 24: Theme Application And Persistence

*For any* theme selection (light or dark), the theme should be applied to all UI elements immediately and persist across application restarts.

**Validates: Requirements 9.1, 9.3, 9.4, 9.5**

### Property 25: Navigation State Preservation

*For any* navigation state and any theme change or provider update, the navigation state should be preserved and the user should remain on the same screen.

**Validates: Requirements 10.5**

### Edge Cases and Examples

The following scenarios should be tested with specific unit tests rather than property-based tests:

- Empty transaction list displays appropriate empty state (Requirements 3.3)
- Empty data displays graceful empty state with guidance (Requirements 8.4)
- Both light and dark themes are available (Requirements 9.2)
