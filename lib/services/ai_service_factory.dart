import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'ai_service.dart';
import 'transaction_service.dart';
import 'budget_service.dart';
import 'goal_service.dart';
import 'insight_service.dart';

/// Factory class for creating AIService instances with proper configuration
class AIServiceFactory {
  /// Create an AIService instance with API key from environment
  static AIService create({
    required TransactionService transactionService,
    required BudgetService budgetService,
    required GoalService goalService,
    required InsightService insightService,
  }) {
    // Load API key from environment (using Groq)
    final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
    
    if (apiKey.isEmpty) {
      throw Exception(
        'GROQ_API_KEY not found in environment. '
        'Please add it to your .env file.',
      );
    }

    return AIService(
      transactionService: transactionService,
      budgetService: budgetService,
      goalService: goalService,
      insightService: insightService,
      apiKey: apiKey,
    );
  }
}
