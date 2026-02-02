import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:perfin/screens/copilot/copilot_screen.dart';
import 'package:perfin/providers/ai_provider.dart';
import 'package:perfin/providers/transaction_provider.dart';
import 'package:perfin/providers/budget_provider.dart';
import 'package:perfin/services/ai_service.dart';
import 'package:perfin/services/transaction_service.dart';
import 'package:perfin/services/budget_service.dart';
import 'package:perfin/services/hive_storage_service.dart';
import 'package:perfin/services/goal_service.dart';
import 'package:perfin/services/insight_service.dart';

void main() {
  late HiveStorageService storageService;
  late TransactionService transactionService;
  late BudgetService budgetService;
  late GoalService goalService;
  late InsightService insightService;
  late AIService aiService;

  setUp(() {
    storageService = HiveStorageService();
    transactionService = TransactionService(storageService);
    budgetService = BudgetService(storageService);
    goalService = GoalService(storageService, transactionService);
    insightService = InsightService(transactionService);
    aiService = AIService(
      transactionService: transactionService,
      budgetService: budgetService,
      goalService: goalService,
      insightService: insightService,
      apiKey: 'test-key',
    );
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TransactionProvider(transactionService),
        ),
        ChangeNotifierProvider(
          create: (_) => BudgetProvider(budgetService),
        ),
        ChangeNotifierProvider(
          create: (_) => AIProvider(aiService, HiveStorageService()),
        ),
      ],
      child: const MaterialApp(
        home: CopilotScreen(),
      ),
    );
  }

  group('CopilotScreen Widget Tests', () {
    testWidgets('should display Perfin header', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Perfin'), findsOneWidget);
    });

    testWidgets('should display suggested questions when no messages',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Welcome to Perfin'), findsOneWidget);
      expect(find.text('Try asking:'), findsOneWidget);
    });

    testWidgets('should display chat input field', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Ask about your finances...'), findsOneWidget);
    });

    testWidgets('should display clear history button',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('should display send button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
    });

    testWidgets('should show clear history dialog when button tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Tap the clear history button
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.text('Clear Chat History'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Clear'), findsOneWidget);
    });
  });
}
