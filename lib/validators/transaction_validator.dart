import '../models/transaction.dart';
import 'validation_result.dart';

/// Validator for Transaction model
class TransactionValidator {
  /// Validate a transaction
  /// Returns ValidationResult with isValid flag and list of errors
  static ValidationResult validate(Transaction transaction) {
    List<String> errors = [];

    // Check amount is positive
    if (transaction.amount <= 0) {
      errors.add("Amount must be positive");
    }

    // Check category is not empty
    if (transaction.category.trim().isEmpty) {
      errors.add("Category is required");
    }

    // Check date is not in future
    if (transaction.date.isAfter(DateTime.now())) {
      errors.add("Date cannot be in the future");
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}
