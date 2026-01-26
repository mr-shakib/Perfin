/// Result of a validation operation
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult({
    required this.isValid,
    required this.errors,
  });

  /// Create a successful validation result
  factory ValidationResult.success() {
    return ValidationResult(isValid: true, errors: []);
  }

  /// Create a failed validation result with errors
  factory ValidationResult.failure(List<String> errors) {
    return ValidationResult(isValid: false, errors: errors);
  }

  @override
  String toString() {
    if (isValid) {
      return 'ValidationResult(valid)';
    }
    return 'ValidationResult(invalid: ${errors.join(", ")})';
  }
}
