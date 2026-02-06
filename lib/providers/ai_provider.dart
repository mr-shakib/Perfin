import 'package:flutter/foundation.dart';
import '../models/ai_summary.dart';
import '../models/spending_prediction.dart';
import '../models/spending_pattern.dart';
import '../models/recurring_expense.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';
import '../models/goal.dart';
import '../models/goal_feasibility_analysis.dart';
import '../models/goal_prioritization.dart';
import '../services/ai_service.dart';
import '../services/storage_service.dart';
import 'transaction_provider.dart';

/// Provider managing AI-powered insights and predictions
/// Uses ChangeNotifier to notify listeners of state changes
class AIProvider extends ChangeNotifier {
  final AIService _aiService;
  final StorageService _storageService;
  String? _userId;

  // Private state
  AISummary? _currentSummary;
  SpendingPrediction? _currentPrediction;
  List<SpendingPattern> _patterns = [];
  List<RecurringExpense> _recurringExpenses = [];
  List<Conversation> _conversations = [];
  String? _currentConversationId;
  GoalFeasibilityAnalysis? _currentFeasibilityAnalysis;
  GoalPrioritization? _currentPrioritization;
  LoadingState _state = LoadingState.idle;
  String? _errorMessage;

  AIProvider(this._aiService, this._storageService) {
    _loadConversations();
  }

  // Public getters
  AISummary? get currentSummary => _currentSummary;
  SpendingPrediction? get currentPrediction => _currentPrediction;
  List<SpendingPattern> get patterns => List.unmodifiable(_patterns);
  List<RecurringExpense> get recurringExpenses => List.unmodifiable(_recurringExpenses);
  List<Conversation> get conversations => List.unmodifiable(_conversations);
  String? get currentConversationId => _currentConversationId;
  
  /// Get current conversation's chat history
  List<ChatMessage> get chatHistory {
    if (_currentConversationId == null) return [];
    final conversation = _conversations.firstWhere(
      (c) => c.id == _currentConversationId,
      orElse: () => Conversation(
        id: '',
        userId: _userId ?? '',
        title: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        messages: [],
      ),
    );
    return List.unmodifiable(conversation.messages);
  }
  
  GoalFeasibilityAnalysis? get currentFeasibilityAnalysis => _currentFeasibilityAnalysis;
  GoalPrioritization? get currentPrioritization => _currentPrioritization;
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
      _conversations = [];
      _currentConversationId = null;
      _state = LoadingState.idle;
      _errorMessage = null;
      notifyListeners();
    } else {
      // Load conversations for the new user
      _loadConversations();
    }
  }

  /// Load all conversations from storage
  Future<void> _loadConversations() async {
    if (_userId == null) return;

    try {
      final key = 'conversations_$_userId';
      final storedConversations = await _storageService.load<List<dynamic>>(key);
      
      if (storedConversations != null) {
        _conversations = storedConversations
            .map((json) => Conversation.fromJson(json as Map<String, dynamic>))
            .toList();
        
        // Sort by updated date (most recent first)
        _conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        
        // Set current conversation to the most recent one
        if (_conversations.isNotEmpty) {
          _currentConversationId = _conversations.first.id;
        }
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load conversations: $e');
    }
  }

  /// Save all conversations to storage
  Future<void> _saveConversations() async {
    if (_userId == null) return;

    try {
      final key = 'conversations_$_userId';
      final jsonConversations = _conversations.map((c) => c.toJson()).toList();
      await _storageService.save(key, jsonConversations);
    } catch (e) {
      debugPrint('Failed to save conversations: $e');
    }
  }

  /// Create a new conversation
  void createNewConversation() {
    if (_userId == null) return;

    final newConversation = Conversation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _userId!,
      title: 'New Conversation',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      messages: [],
    );

    _conversations.insert(0, newConversation);
    _currentConversationId = newConversation.id;
    _saveConversations();
    notifyListeners();
  }

  /// Switch to a different conversation
  void switchConversation(String conversationId) {
    _currentConversationId = conversationId;
    notifyListeners();
  }

  /// Rename a conversation
  void renameConversation(String conversationId, String newTitle) {
    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index != -1) {
      _conversations[index] = _conversations[index].copyWith(
        title: newTitle,
        updatedAt: DateTime.now(),
      );
      _saveConversations();
      notifyListeners();
    }
  }

  /// Delete a conversation
  void deleteConversation(String conversationId) {
    _conversations.removeWhere((c) => c.id == conversationId);
    
    // If we deleted the current conversation, switch to another one
    if (_currentConversationId == conversationId) {
      _currentConversationId = _conversations.isNotEmpty ? _conversations.first.id : null;
    }
    
    _saveConversations();
    notifyListeners();
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

    // Create new conversation if none exists
    if (_currentConversationId == null || _conversations.isEmpty) {
      createNewConversation();
    }

    final conversationIndex = _conversations.indexWhere((c) => c.id == _currentConversationId);
    if (conversationIndex == -1) return;

    // Add user message to current conversation
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _userId!,
      content: query,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );

    final updatedMessages = List<ChatMessage>.from(_conversations[conversationIndex].messages)
      ..add(userMessage);

    // Update conversation title if it's the first message
    String title = _conversations[conversationIndex].title;
    if (updatedMessages.length == 1 || title == 'New Conversation') {
      title = Conversation.generateTitle(updatedMessages);
    }

    _conversations[conversationIndex] = _conversations[conversationIndex].copyWith(
      messages: updatedMessages,
      title: title,
      updatedAt: DateTime.now(),
    );

    await _saveConversations();
    notifyListeners();

    _state = LoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _aiService.processCopilotQuery(
        userId: _userId!,
        query: query,
        conversationHistory: updatedMessages,
      );

      // Add assistant response to conversation
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

      final finalMessages = List<ChatMessage>.from(updatedMessages)
        ..add(assistantMessage);

      _conversations[conversationIndex] = _conversations[conversationIndex].copyWith(
        messages: finalMessages,
        updatedAt: DateTime.now(),
      );

      // Move conversation to top of list
      final conversation = _conversations.removeAt(conversationIndex);
      _conversations.insert(0, conversation);

      await _saveConversations();

      _state = LoadingState.loaded;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _state = LoadingState.error;
      _errorMessage = 'Failed to process query: ${e.toString()}';
      
      // Add error message to chat so user knows what happened
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _userId!,
        content: 'Sorry, I encountered an error: ${e.toString()}. Please try again.',
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
      );

      final errorMessages = List<ChatMessage>.from(_conversations[conversationIndex].messages)
        ..add(errorMessage);

      _conversations[conversationIndex] = _conversations[conversationIndex].copyWith(
        messages: errorMessages,
        updatedAt: DateTime.now(),
      );

      await _saveConversations();
      notifyListeners();
    }
  }

  /// Clear current conversation's chat history
  Future<void> clearChatHistory() async {
    if (_currentConversationId == null) return;

    final index = _conversations.indexWhere((c) => c.id == _currentConversationId);
    if (index != -1) {
      _conversations[index] = _conversations[index].copyWith(
        messages: [],
        title: 'New Conversation',
        updatedAt: DateTime.now(),
      );
      await _saveConversations();
      notifyListeners();
    }
  }

  /// Process a copilot query with an attached image (e.g., bill or receipt)
  Future<void> sendCopilotQueryWithImage(String query, String imagePath) async {
    if (_userId == null) {
      _state = LoadingState.error;
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return;
    }

    // Create new conversation if none exists
    if (_currentConversationId == null || _conversations.isEmpty) {
      createNewConversation();
    }

    final conversationIndex = _conversations.indexWhere((c) => c.id == _currentConversationId);
    if (conversationIndex == -1) return;

    // Add user message with image to current conversation
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _userId!,
      content: query,
      role: MessageRole.user,
      timestamp: DateTime.now(),
      imagePath: imagePath,
    );

    final updatedMessages = List<ChatMessage>.from(_conversations[conversationIndex].messages)
      ..add(userMessage);

    // Update conversation title if it's the first message
    String title = _conversations[conversationIndex].title;
    if (updatedMessages.length == 1 || title == 'New Conversation') {
      title = 'Bill Analysis';
    }

    _conversations[conversationIndex] = _conversations[conversationIndex].copyWith(
      messages: updatedMessages,
      title: title,
      updatedAt: DateTime.now(),
    );

    await _saveConversations();
    notifyListeners();

    _state = LoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Process the image and extract transaction data
      final response = await _aiService.analyzeBillImage(
        userId: _userId!,
        imagePath: imagePath,
        userQuery: query,
      );

      // Add assistant response to conversation
      final assistantMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _userId!,
        content: response.message,
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
        metadata: {
          'extractedTransactions': response.transactions,
          'confidenceScore': response.confidence,
        },
      );

      final finalMessages = List<ChatMessage>.from(updatedMessages)
        ..add(assistantMessage);

      _conversations[conversationIndex] = _conversations[conversationIndex].copyWith(
        messages: finalMessages,
        updatedAt: DateTime.now(),
      );

      // Move conversation to top of list
      final conversation = _conversations.removeAt(conversationIndex);
      _conversations.insert(0, conversation);

      await _saveConversations();

      _state = LoadingState.loaded;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _state = LoadingState.error;
      _errorMessage = 'Failed to analyze bill: ${e.toString()}';
      
      // Add error message to chat so user knows what happened
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _userId!,
        content: 'Sorry, I encountered an error analyzing the bill: ${e.toString()}. Please try again with a clearer image.',
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
      );

      final errorMessages = List<ChatMessage>.from(_conversations[conversationIndex].messages)
        ..add(errorMessage);

      _conversations[conversationIndex] = _conversations[conversationIndex].copyWith(
        messages: errorMessages,
        updatedAt: DateTime.now(),
      );

      await _saveConversations();
      notifyListeners();
    }
  }

  /// Analyze goal feasibility
  Future<void> analyzeGoalFeasibility(Goal goal) async {
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
      _currentFeasibilityAnalysis = await _aiService.analyzeGoalFeasibility(
        userId: _userId!,
        goal: goal,
      );
      _state = LoadingState.loaded;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _state = LoadingState.error;
      _errorMessage = 'Failed to analyze goal feasibility: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Prioritize multiple goals
  Future<void> prioritizeGoals(List<Goal> goals) async {
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
      _currentPrioritization = await _aiService.prioritizeGoals(
        userId: _userId!,
        goals: goals,
      );
      _state = LoadingState.loaded;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _state = LoadingState.error;
      _errorMessage = 'Failed to prioritize goals: ${e.toString()}';
      notifyListeners();
    }
  }
}
