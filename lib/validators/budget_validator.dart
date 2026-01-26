import '../models/budget.dart';
import 'validation_result.dart';

/// Validator for Budget model
class BudgetValidator {
  /// Validate a budget
  /// Returns ValidationResult with isValid flag and list of errors
  static ValidationResult validate(Budget budget) {
    List<String> errors = [];

    // Check amount is positive
    if (budget.amount <= 0) {
      errors.add("Budget amount must be positive");
    }

    // Check month is between 1 and 12
    if (budget.month < 1 || budget.month > 12) {
      errors.add("Invalid month");
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}
