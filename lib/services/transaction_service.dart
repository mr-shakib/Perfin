import 'dart:convert';
import '../models/transaction.dart';
import '../validators/transaction_validator.dart';
import 'storage_service.dart';

/// Service responsible for transaction management
/// Handles transaction CRUD operations and delegates persistence to StorageService
class TransactionService {
  final StorageService _storageService;
  
  static const String _transactionsKeyPrefix = 'transactions_';
  
  TransactionService(this._storageService);
  
  /// Fetch all transactions for a user
  /// Returns list of transactions ordered by date (most recent first)
  /// Returns empty list if no transactions exist
  Future<List<Transaction>> fetchTransactions(String userId) async {
    try {
      final key = _getTransactionsKey(userId);
      final transactionsData = await _storageService.load<String>(key);
      
      if (transactionsData == null) {
        return [];
      }
      
      final List<dynamic> jsonList = jsonDecode(transactionsData);
      final transactions = jsonList
          .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
          .toList();
      
      // Sort by date, most recent first
      transactions.sort((a, b) => b.date.compareTo(a.date));
      
      return transactions;
    } catch (e) {
      throw TransactionServiceException(
        'Failed to fetch transactions: ${e.toString()}',
      );
    }
  }
  
  /// Save a new transaction
  /// Validates transaction before saving
  /// Throws ValidationException if transaction is invalid
  /// Throws TransactionServiceException if save fails
  Future<void> saveTransaction(Transaction transaction) async {
    // Validate transaction
    final validationResult = TransactionValidator.validate(transaction);
    if (!validationResult.isValid) {
      throw ValidationException(validationResult.errors);
    }
    
    try {
      // Fetch existing transactions
      final transactions = await fetchTransactions(transaction.userId);
      
      // Check if transaction with same ID already exists
      final existingIndex = transactions.indexWhere((t) => t.id == transaction.id);
      if (existingIndex != -1) {
        throw TransactionServiceException(
          'Transaction with ID ${transaction.id} already exists',
        );
      }
      
      // Add new transaction
      transactions.add(transaction);
      
      // Save updated list
      await _saveTransactionsList(transaction.userId, transactions);
    } catch (e) {
      if (e is ValidationException || e is TransactionServiceException) {
        rethrow;
      }
      throw TransactionServiceException(
        'Failed to save transaction: ${e.toString()}',
      );
    }
  }
  
  /// Update an existing transaction
  /// Validates transaction before updating
  /// Throws ValidationException if transaction is invalid
  /// Throws TransactionServiceException if transaction not found or update fails
  Future<void> updateTransaction(Transaction transaction) async {
    // Validate transaction
    final validationResult = TransactionValidator.validate(transaction);
    if (!validationResult.isValid) {
      throw ValidationException(validationResult.errors);
    }
    
    try {
      // Fetch existing transactions
      final transactions = await fetchTransactions(transaction.userId);
      
      // Find transaction to update
      final existingIndex = transactions.indexWhere((t) => t.id == transaction.id);
      if (existingIndex == -1) {
        throw TransactionServiceException(
          'Transaction with ID ${transaction.id} not found',
        );
      }
      
      // Update transaction
      transactions[existingIndex] = transaction;
      
      // Save updated list
      await _saveTransactionsList(transaction.userId, transactions);
    } catch (e) {
      if (e is ValidationException || e is TransactionServiceException) {
        rethrow;
      }
      throw TransactionServiceException(
        'Failed to update transaction: ${e.toString()}',
      );
    }
  }
  
  /// Delete a transaction
  /// Throws TransactionServiceException if transaction not found or delete fails
  Future<void> deleteTransaction(String transactionId, String userId) async {
    try {
      // Fetch existing transactions
      final transactions = await fetchTransactions(userId);
      
      // Find transaction to delete
      final existingIndex = transactions.indexWhere((t) => t.id == transactionId);
      if (existingIndex == -1) {
        throw TransactionServiceException(
          'Transaction with ID $transactionId not found',
        );
      }
      
      // Remove transaction
      transactions.removeAt(existingIndex);
      
      // Save updated list
      await _saveTransactionsList(userId, transactions);
    } catch (e) {
      if (e is TransactionServiceException) {
        rethrow;
      }
      throw TransactionServiceException(
        'Failed to delete transaction: ${e.toString()}',
      );
    }
  }
  
  /// Get storage key for user's transactions
  String _getTransactionsKey(String userId) {
    return '$_transactionsKeyPrefix$userId';
  }
  
  /// Save transactions list to storage
  Future<void> _saveTransactionsList(
    String userId,
    List<Transaction> transactions,
  ) async {
    final key = _getTransactionsKey(userId);
    final jsonList = transactions.map((t) => t.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _storageService.save(key, jsonString);
  }
}

/// Custom exception for transaction service operations
class TransactionServiceException implements Exception {
  final String message;
  
  TransactionServiceException(this.message);
  
  @override
  String toString() => 'TransactionServiceException: $message';
}

/// Custom exception for validation errors
class ValidationException implements Exception {
  final List<String> errors;
  
  ValidationException(this.errors);
  
  String get message => errors.join(', ');
  
  @override
  String toString() => 'ValidationException: $message';
}
