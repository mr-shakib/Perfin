/// App-wide constants for the Personal Finance App
library;

// Transaction Categories
class AppCategories {
  static const List<String> expenseCategories = [
    'Food & Dining',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Bills & Utilities',
    'Healthcare',
    'Education',
    'Travel',
    'Personal Care',
    'Other',
  ];

  static const List<String> incomeCategories = [
    'Salary',
    'Freelance',
    'Investment',
    'Gift',
    'Other',
  ];
}

// Storage Keys
class StorageKeys {
  static const String userSession = 'user_session';
  static const String transactions = 'transactions';
  static const String monthlyBudget = 'monthly_budget';
  static const String categoryBudgets = 'category_budgets';
  static const String themeMode = 'theme_mode';
}

// App Strings
class AppStrings {
  static const String appName = 'PerFin';
  static const String appDescription = 'Personal Finance Manager';
  
  // Error messages
  static const String genericError = 'An unexpected error occurred';
  static const String networkError = 'Network connection failed';
  static const String storageError = 'Failed to save data';
  static const String authError = 'Authentication failed';
  static const String validationError = 'Please check your input';
  
  // Empty state messages
  static const String noTransactions = 'No transactions yet';
  static const String noTransactionsHint = 'Tap + to add your first transaction';
  static const String noBudget = 'No budget set';
  static const String noBudgetHint = 'Set a budget to track your spending';
}

// App Configuration
class AppConfig {
  static const int maxTransactionAmount = 1000000000; // 1 billion
  static const int minYear = 2000;
  static const int maxYear = 2100;
  static const double budgetWarningThreshold = 0.8; // 80% of budget
}
