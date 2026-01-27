import 'package:flutter/foundation.dart';
import '../models/currency.dart';
import '../services/storage_service.dart';

/// Currency Provider - Manages app-wide currency settings
class CurrencyProvider with ChangeNotifier {
  final StorageService _storageService;
  Currency _currentCurrency = Currencies.bdt; // Default to BDT

  CurrencyProvider(this._storageService) {
    _loadCurrency();
  }

  Currency get currentCurrency => _currentCurrency;

  /// Format amount with current currency
  String format(double amount, {int decimals = 2}) {
    return '${_currentCurrency.symbol}${amount.toStringAsFixed(decimals)}';
  }

  /// Format amount without decimals
  String formatWhole(double amount) {
    return '${_currentCurrency.symbol}${amount.toStringAsFixed(0)}';
  }

  /// Load saved currency preference
  Future<void> _loadCurrency() async {
    try {
      final currencyData = await _storageService.load<Map<String, dynamic>>('user_currency');
      if (currencyData != null) {
        _currentCurrency = Currency.fromJson(currencyData);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading currency: $e');
    }
  }

  /// Change currency
  Future<void> setCurrency(Currency currency) async {
    _currentCurrency = currency;
    notifyListeners();
    
    try {
      await _storageService.save('user_currency', currency.toJson());
    } catch (e) {
      debugPrint('Error saving currency: $e');
    }
  }
}
