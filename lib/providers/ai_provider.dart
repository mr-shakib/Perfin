import 'package:flutter/foundation.dart';
import '../models/ai_summary.dart';
import '../models/spending_prediction.dart';
import '../models/spending_pattern.dart';
import '../models/recurring_expense.dart';
import '../models/chat_message.dart';
import '../services/ai_service.dart';
import 'transaction_provider.dart';

/// Provider managing AI-powered insights and predictions
/// Uses ChangeNotifier to notify listeners of state changes
class AIProvider extends ChangeNotifier {
  final AIService _aiService;
  String? _userId;

  // Private state
  AISummary? _currentSummary;
  SpendingPrediction? _currentPrediction;
  List<SpendingPattern> _patterns = [];
  List<RecurringExpense> _recurringExpenses = [];
  List<ChatMessage> _chatHistory = [];
  LoadingState _state = LoadingState.idle;
  String? _errorMessage;

  AIProvider(this._aiService);

  // Public getters
  AISummary? get currentSummary => _currentSummary;
  SpendingPrediction? get currentPrediction => _currentPrediction;
  List<SpendingPattern> get patterns => List.unmodifiable(_patterns);
  List<RecurringExpense> get recurringExpenses => List.unmodifiable(_recurringExpenses);
  List<ChatMessage> get chatHistory => List.unmodifiable(_chatHistory);
  LoadingState get state => _state;
  String? get errorMessage => _errorMessage;

  /// Update the user ID for this provider
  void updateUserId(String? userId) {
    _userId = userId;
    if (userId == null) {
      // Clear AI data when user logs out
      _currentSummary = null;
      _currentPrediction = null;
      _patterns = [];
      _recurringExpenses = [];
      _chatHistory = [];
      _state = LoadingState.idle;
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Generate financial summary for a date range
  Future<void> generateSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (_userId == null) {
      _state = LoadingState.error;
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return;
    }

    _state = LoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentSummary = await _aiService.generateFinancialSummary(
        userId: _userId!,
        startDate: startDate,
        endDate: endDate,
      );
      _state = LoadingState.loaded;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _state = LoadingState.error;
      _errorMessage = 'Failed to generate summary: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Generate spending prediction for target month
  Future<void> generatePrediction({
    required DateTime targetMonth,
  }) async {
    if (_userId == null) {
      _state = LoadingState.error;
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return;
    }

    _state = LoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentPrediction = await _aiService.predictMonthEndSpending(
        userId: _userId!,
        targetMonth: targetMonth,
      );
      _state = LoadingState.loaded;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _state = LoadingState.error;
      _errorMessage = 'Failed to generate prediction: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Detect spending patterns for a date range
  Future<void> detectPatterns({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (_userId == null) {
      _state = LoadingState.error;
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return;
    }

    _state = LoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _patterns = await _aiService.detectSpendingPatterns(
        userId: _userId!,
        startDate: startDate,
        endDate: endDate,
      );
      _state = LoadingState.loaded;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _state = LoadingState.error;
      _errorMessage = 'Failed to detect patterns: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Detect recurring expenses
  Future<void> detectRecurringExpenses() async {
    if (_userId == null) {
      _state = LoadingState.error;
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return;
    }

    _state = LoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _recurringExpenses = await _aiService.detectRecurringExpenses(
        userId: _userId!,
      );
      _state = LoadingState.loaded;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _state = LoadingState.error;
      _errorMessage = 'Failed to detect recurring expenses: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Process a copilot query
  Future<void> sendCopilotQuery(String query) async {
    if (_userId == null) {
      _state = LoadingState.error;
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return;
    }

    // Add user message to history
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _userId!,
      content: query,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );
    _chatHistory.add(userMessage);
    notifyListeners();

    _state = LoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _aiService.processCopilotQuery(
        userId: _userId!,
        query: query,
        conversationHistory: _chatHistory,
      );

      // Add assistant response to history
      final assistantMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _userId!,
        content: response.responseText,
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
        metadata: {
          'confidenceScore': response.confidenceScore,
          'dataReferences': response.dataReferences,
          'calculations': response.calculations,
        },
      );
      _chatHistory.add(assistantMessage);

      _state = LoadingState.loaded;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _state = LoadingState.error;
      _errorMessage = 'Failed to process query: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Clear chat history
  void clearChatHistory() {
    _chatHistory = [];
    notifyListeners();
  }
}
