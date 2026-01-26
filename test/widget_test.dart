// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:perfin/main.dart';
import 'package:perfin/services/hive_storage_service.dart';
import 'package:perfin/services/auth_service.dart';
import 'package:perfin/services/theme_service.dart';
import 'package:perfin/services/transaction_service.dart';
import 'package:perfin/services/budget_service.dart';
import 'package:perfin/services/onboarding_service.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Initialize services for testing
    final storageService = HiveStorageService();
    await storageService.init();
    
    final authService = AuthService(storageService);
    final themeService = ThemeService(storageService);
    final transactionService = TransactionService(storageService);
    final budgetService = BudgetService(storageService);
    final onboardingService = OnboardingService(storageService);
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(
      authService: authService,
      themeService: themeService,
      transactionService: transactionService,
      budgetService: budgetService,
      onboardingService: onboardingService,
    ));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
