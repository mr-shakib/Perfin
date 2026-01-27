import '../constants.dart';

/// Currency formatting utilities
class CurrencyUtils {
  /// Format amount with BDT currency symbol
  static String format(double amount, {int decimals = 2}) {
    return '${AppCurrency.symbol}${amount.toStringAsFixed(decimals)}';
  }

  /// Format amount without decimals
  static String formatWhole(double amount) {
    return '${AppCurrency.symbol}${amount.toStringAsFixed(0)}';
  }
}
