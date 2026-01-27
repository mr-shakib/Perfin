# AI Service Usage Guide

The `AIService` provides AI-powered financial insights, predictions, and recommendations using Google's Gemini API.

## Setup

```dart
import 'package:perfin/services/ai_service_factory.dart';
import 'package:perfin/services/transaction_service.dart';
import 'package:perfin/services/budget_service.dart';
import 'package:perfin/services/goal_service.dart';
import 'package:perfin/services/insight_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Load environment variables (do this in main.dart before runApp)
await dotenv.load();

// Initialize dependencies
final storageService = HiveStorageService();
await storageService.init();

final transactionService = TransactionService(storageService);
final budgetService = BudgetService(storageService);
final goalService = GoalService(storageService, transactionService);
final insightService = InsightService(transactionService);

// Create AI service using factory (automatically loads API key from .env)
final aiService = AIServiceFactory.create(
  transactionService: transactionService,
  budgetService: budgetService,
  goalService: goalService,
  insightService: insightService,
);

// Or create manually with API key
final aiService = AIService(
  transactionService: transactionService,
  budgetService: budgetService,
  goalService: goalService,
  insightService: insightService,
  apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
);
```

## Features

### 1. Financial Summary Generation

Generate a natural language summary of the user's financial situation:

```dart
final summary = await aiService.generateFinancialSummary(
  userId: currentUserId,
  startDate: DateTime(2024, 1, 1),
  endDate: DateTime(2024, 1, 31),
);

print(summary.summaryText); // AI-generated summary
print('Total Spending: \$${summary.totalSpending}');
print('Top Category: ${summary.topSpendingCategory}');
print('Confidence: ${summary.confidenceScore}%');

// Check for insufficient data
if (summary.hasInsufficientData) {
  print('Need more transactions for meaningful insights');
}

// Display anomalies
for (final anomaly in summary.anomalies) {
  print('Unusual: ${anomaly.explanation}');
}
```

### 2. Spending Predictions

Predict end-of-month spending:

```dart
try {
  final prediction = await aiService.predictMonthEndSpending(
    userId: currentUserId,
    targetMonth: DateTime.now(),
  );

  print('Predicted: \$${prediction.predictedAmount.toStringAsFixed(2)}');
  print('Confidence: ${prediction.confidenceScore}%');
  print('Range: \$${prediction.lowerBound.toStringAsFixed(2)} - \$${prediction.upperBound.toStringAsFixed(2)}');
  print('Explanation: ${prediction.explanation}');

  // Show low confidence warning
  if (prediction.confidenceScore < 60) {
    print('Warning: Low confidence prediction');
  }
} catch (e) {
  if (e is AIServiceException) {
    print('Error: ${e.message}'); // e.g., "Need 30 days of data"
  }
}
```

### 3. Pattern Detection

Detect spending patterns and trends:

```dart
final patterns = await aiService.detectSpendingPatterns(
  userId: currentUserId,
  startDate: DateTime.now().subtract(Duration(days: 60)),
  endDate: DateTime.now(),
);

for (final pattern in patterns) {
  print('${pattern.patternType}: ${pattern.description}');
  print('Confidence: ${pattern.confidenceScore}%');
}

// Pattern types: 'increasing', 'decreasing', 'weekend_heavy', 'weekday_heavy', 'highly_variable'
```

### 4. Recurring Expense Detection

Find recurring expenses automatically:

```dart
final recurringExpenses = await aiService.detectRecurringExpenses(
  userId: currentUserId,
);

for (final expense in recurringExpenses) {
  print('${expense.description}: \$${expense.averageAmount.toStringAsFixed(2)}');
  print('Frequency: Every ${expense.frequencyDays} days');
  print('Next expected: ${expense.nextExpectedDate}');
  print('Confidence: ${expense.confidenceScore}%');
}
```

### 5. Copilot Query Processing

Process natural language financial queries:

```dart
final conversationHistory = <ChatMessage>[
  // Previous messages in conversation
];

final response = await aiService.processCopilotQuery(
  userId: currentUserId,
  query: 'How much did I spend on groceries this month?',
  conversationHistory: conversationHistory,
);

print(response.responseText);
print('Confidence: ${response.confidenceScore}%');

// Handle clarification requests
if (response.requiresClarification) {
  print('AI needs clarification:');
  for (final question in response.clarifyingQuestions ?? []) {
    print('- $question');
  }
}

// Show calculations
for (final calc in response.calculations) {
  print('Calculation: $calc');
}

// Get suggested questions for new users
final suggestions = aiService.getSuggestedQuestions();
print('Try asking: ${suggestions.first}');
```

### 6. Goal Feasibility Analysis

Analyze if a financial goal is achievable:

```dart
final goal = await goalService.createGoal(
  userId: currentUserId,
  name: 'Emergency Fund',
  targetAmount: 5000.0,
  targetDate: DateTime.now().add(Duration(days: 365)),
);

try {
  final analysis = await aiService.analyzeGoalFeasibility(
    userId: currentUserId,
    goal: goal,
  );

  print('Feasibility: ${analysis.feasibilityLevel.name}');
  print('Required monthly savings: \$${analysis.requiredMonthlySavings.toStringAsFixed(2)}');
  print('Available surplus: \$${analysis.averageMonthlySurplus.toStringAsFixed(2)}');
  print('Explanation: ${analysis.explanation}');

  // Show spending reduction suggestions if challenging
  if (analysis.suggestedReductions.isNotEmpty) {
    print('\nSuggested reductions:');
    for (final reduction in analysis.suggestedReductions) {
      print('- ${reduction.categoryId}: Reduce by \$${reduction.suggestedReduction.toStringAsFixed(2)}');
      print('  ${reduction.rationale}');
    }
  }
} catch (e) {
  if (e is AIServiceException) {
    print('Error: ${e.message}'); // e.g., "Need 10 transactions"
  }
}
```

### 7. Spending Reduction Suggestions

Get suggestions for reducing spending:

```dart
final suggestions = await aiService.suggestSpendingReductions(
  userId: currentUserId,
  targetSavings: 300.0, // Need to save $300/month more
);

for (final suggestion in suggestions) {
  print('${suggestion.categoryId}:');
  print('  Current: \$${suggestion.currentMonthlySpending.toStringAsFixed(2)}');
  print('  Suggested: \$${suggestion.newMonthlySpending.toStringAsFixed(2)}');
  print('  Savings: \$${suggestion.suggestedReduction.toStringAsFixed(2)}');
  print('  ${suggestion.rationale}');
  
  if (suggestion.isEssential) {
    print('  ⚠️ Essential category - reduce carefully');
  }
}
```

### 8. Goal Prioritization

Prioritize multiple goals when resources are limited:

```dart
final goals = await goalService.getUserGoals(userId: currentUserId);

final prioritization = await aiService.prioritizeGoals(
  userId: currentUserId,
  goals: goals,
);

print('Total required: \$${prioritization.totalRequiredMonthlySavings.toStringAsFixed(2)}');
print('Available: \$${prioritization.availableMonthlySurplus.toStringAsFixed(2)}');

if (prioritization.hasConflicts) {
  print('⚠️ Conflict: ${prioritization.conflictExplanation}');
}

print('\nPriority order:');
for (final prioritizedGoal in prioritization.prioritizedGoals) {
  print('${prioritizedGoal.priority}. Goal ${prioritizedGoal.goalId}');
  print('   ${prioritizedGoal.rationale}');
}
```

## Error Handling

All AI service methods can throw `AIServiceException`:

```dart
try {
  final summary = await aiService.generateFinancialSummary(
    userId: currentUserId,
    startDate: startDate,
    endDate: endDate,
  );
  // Use summary
} catch (e) {
  if (e is AIServiceException) {
    // Handle AI-specific errors
    print('AI Error: ${e.message}');
    // Fall back to showing factual data only
  } else {
    // Handle other errors
    print('Unexpected error: $e');
  }
}
```

## Best Practices

1. **Check for sufficient data**: Many AI features require minimum data:
   - Financial summary: 10+ transactions
   - Predictions: 30+ days of data
   - Goal feasibility: 10+ transactions
   - Recurring expenses: 2+ similar transactions

2. **Handle low confidence**: When confidence score < 60%, show warnings to users

3. **Provide fallbacks**: If AI fails, show factual data (totals, averages) instead

4. **Respect user privacy**: AI only uses the authenticated user's data

5. **Cache results**: AI operations can be slow (up to 3 seconds), consider caching

6. **Handle API failures**: Gemini API calls may fail - always have fallback text

## Configuration

The Gemini API key is stored securely in the `.env` file:

**Step 1: Add to .env file**
```env
# .env file
GROQ_API_KEY=your_groq_api_key_here
```

**Step 2: Load in main.dart**
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load();
  
  runApp(MyApp());
}
```

**Step 3: Use AIServiceFactory**
```dart
import 'package:perfin/services/ai_service_factory.dart';

// Factory automatically loads API key from environment
final aiService = AIServiceFactory.create(
  transactionService: transactionService,
  budgetService: budgetService,
  goalService: goalService,
  insightService: insightService,
);
```

**Security Notes:**
- ✅ API key is in `.env` file (not committed to git)
- ✅ `.env` is in `.gitignore`
- ✅ `.env.example` provides template without actual key
- ⚠️ Never hardcode API keys in source code
- ⚠️ Never commit `.env` file to version control

## Testing

For testing, use a mock API key or mock the AI service:

```dart
// Use test API key (will fail actual calls but allows structure testing)
final aiService = AIService(
  transactionService: mockTransactionService,
  budgetService: mockBudgetService,
  goalService: mockGoalService,
  insightService: mockInsightService,
  apiKey: 'test-api-key',
);

// Test methods that don't require API calls
final questions = aiService.getSuggestedQuestions();
expect(questions, isNotEmpty);
```

## Performance Considerations

- AI operations can take 1-3 seconds
- Show loading indicators during AI processing
- Consider background processing for non-critical insights
- Cache results when appropriate (e.g., daily summaries)
- Use pagination for large transaction sets

## Limitations

1. Requires internet connection for AI features
2. Gemini API has rate limits
3. Predictions are estimates, not guarantees
4. Requires sufficient historical data for accuracy
5. Does not provide investment or tax advice
