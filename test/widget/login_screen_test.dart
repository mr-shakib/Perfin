import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:perfin/screens/login_screen.dart';
import 'package:perfin/providers/auth_provider.dart';
import 'package:perfin/services/auth_service.dart';
import 'package:perfin/services/hive_storage_service.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    late AuthService authService;
    late AuthProvider authProvider;

    setUp(() {
      // Create mock storage service
      final storageService = HiveStorageService();
      authService = AuthService(storageService);
      authProvider = AuthProvider(authService);
    });

    Widget createLoginScreen() {
      return MaterialApp(
        home: ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: const LoginScreen(),
        ),
      );
    }

    testWidgets('displays email and password fields', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Verify email field exists
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('displays login button', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Verify login button exists
      expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);
    });

    testWidgets('shows validation error for empty email', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Tap login button without entering email
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();

      // Verify validation error is shown
      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('shows validation error for invalid email', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField).first, 'invalidemail');
      
      // Tap login button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();

      // Verify validation error is shown
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('shows validation error for empty password', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Enter valid email but no password
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      
      // Tap login button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();

      // Verify validation error is shown
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('shows validation error for short password', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Enter valid email and short password
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, '12345');
      
      // Tap login button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();

      // Verify validation error is shown
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('toggles password visibility', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Find password field
      final passwordField = find.byType(TextFormField).last;
      
      // Enter password
      await tester.enterText(passwordField, 'password123');
      await tester.pump();

      // Find visibility toggle button
      final visibilityButton = find.byIcon(Icons.visibility_outlined);
      expect(visibilityButton, findsOneWidget);

      // Tap to show password
      await tester.tap(visibilityButton);
      await tester.pump();

      // Verify icon changed
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('displays app logo', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Verify logo icon exists
      expect(find.byIcon(Icons.account_balance_wallet_rounded), findsOneWidget);
    });

    testWidgets('displays welcome text', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Verify welcome text exists
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Sign in to continue managing your finances'), findsOneWidget);
    });
  });
}
