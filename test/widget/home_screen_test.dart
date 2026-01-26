import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:perfin/screens/home/home_screen.dart';
import 'package:perfin/providers/transaction_provider.dart';
import 'package:perfin/providers/budget_provider.dart';
import 'package:perfin/providers/ai_provider.dart';
import 'package:perfin/services/transaction_service.dart';
import 'package:perfin/services/budget_service.dart';
import 'package:perfin/services/ai_service.dart';
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

  Widget createHomeScreen() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TransactionProvider(transactionService),
        ),
        ChangeNotifierProvider(
          create: (_) => BudgetProvider(budgetService),
        ),
        ChangeNotifierProvider(
          create: (_) => AIProvider(aiService),
        ),
      ],
      child: const MaterialApp(
        home: HomeScreen(),
      ),
    );
  }

  testWidgets('HomeScreen renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());
    await tester.pump();

    // Verify the app bar is present
    expect(find.text('Home'), findsOneWidget);
    
    // Verify refresh button is present
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });

  testWidgets('HomeScreen renders basic structure', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());
    await tester.pumpAndSettle();

    // Verify the scaffold and app bar are present
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });
}
