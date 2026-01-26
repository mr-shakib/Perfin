import 'dart:convert';
import '../models/budget.dart';
import '../validators/budget_validator.dart';
import 'storage_service.dart';

/// Service responsible for budget management
/// Handles budget CRUD operations and delegates persistence to StorageService
class BudgetService {
  final StorageService _storageService;
  
  static const String _monthlyBudgetKeyPrefix = 'monthly_budget_';
  static const String _categoryBudgetsKeyPrefix = 'category_budgets_';
  
  BudgetService(this._storageService);
  
  /// Fetch monthly budget for a user for a specific month/year
  /// Returns the budget if found, null otherwise
  Future<Budget?> fetchMonthlyBudget(String userId, int year, int month) async {
    try {
      final key = _getMonthlyBudgetKey(userId, year, month);
      final budgetData = await _storageService.load<String>(key);
      
      if (budgetData == null) {
        return null;
      }
      
      final Map<String, dynamic> json = jsonDecode(budgetData);
      return Budget.fromJson(json);
    } catch (e) {
      throw BudgetServiceException(
        'Failed to fetch monthly budget: ${e.toString()}',
      );
    }
  }
  
  /// Fetch all category budgets for a user
  /// Returns map of category name to budget amount
  /// Returns empty map if no category budgets exist
  Future<Map<String, double>> fetchCategoryBudgets(String userId) async {
    try {
      final key = _getCategoryBudgetsKey(userId);
      final budgetsData = await _storageService.load<String>(key);
      
      if (budgetsData == null) {
        return {};
      }
      
      final Map<String, dynamic> json = jsonDecode(budgetsData);
      return json.map((key, value) => MapEntry(key, (value as num).toDouble()));
    } catch (e) {
      throw BudgetServiceException(
        'Failed to fetch category budgets: ${e.toString()}',
      );
    }
  }
  
  /// Save a monthly budget
  /// Validates budget before saving
  /// Throws ValidationException if budget is invalid
  /// Throws BudgetServiceException if save fails
  Future<void> saveBudget(Budget budget) async {
    // Validate budget
    final validationResult = BudgetValidator.validate(budget);
    if (!validationResult.isValid) {
      throw ValidationException(validationResult.errors);
    }
    
    try {
      final key = _getMonthlyBudgetKey(budget.userId, budget.year, budget.month);
      final jsonString = jsonEncode(budget.toJson());
      await _storageService.save(key, jsonString);
    } catch (e) {
      if (e is ValidationException) {
        rethrow;
      }
      throw BudgetServiceException(
        'Failed to save budget: ${e.toString()}',
      );
    }
  }
  
  /// Save a category budget
  /// Validates that amount is positive
  /// Throws ValidationException if amount is invalid
  /// Throws BudgetServiceException if save fails
  Future<void> saveCategoryBudget(
    String category,
    double amount,
    String userId,
  ) async {
    // Validate amount
    if (amount <= 0) {
      throw ValidationException(['Budget amount must be positive']);
    }
    
    // Validate category
    if (category.trim().isEmpty) {
      throw ValidationException(['Category cannot be empty']);
    }
    
    try {
      // Fetch existing category budgets
      final categoryBudgets = await fetchCategoryBudgets(userId);
      
      // Update or add category budget
      categoryBudgets[category] = amount;
      
      // Save updated map
      final key = _getCategoryBudgetsKey(userId);
      final jsonString = jsonEncode(categoryBudgets);
      await _storageService.save(key, jsonString);
    } catch (e) {
      if (e is ValidationException) {
        rethrow;
      }
      throw BudgetServiceException(
        'Failed to save category budget: ${e.toString()}',
      );
    }
  }
  
  /// Get storage key for user's monthly budget
  String _getMonthlyBudgetKey(String userId, int year, int month) {
    return '${_monthlyBudgetKeyPrefix}${userId}_${year}_$month';
  }
  
  /// Get storage key for user's category budgets
  String _getCategoryBudgetsKey(String userId) {
    return '$_categoryBudgetsKeyPrefix$userId';
  }
}

/// Custom exception for budget service operations
class BudgetServiceException implements Exception {
  final String message;
  
  BudgetServiceException(this.message);
  
  @override
  String toString() => 'BudgetServiceException: $message';
}

/// Custom exception for validation errors
class ValidationException implements Exception {
  final List<String> errors;
  
  ValidationException(this.errors);
  
  String get message => errors.join(', ');
  
  @override
  String toString() => 'ValidationException: $message';
}
