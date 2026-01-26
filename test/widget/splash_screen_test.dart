import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:perfin/screens/splash_screen.dart';
import 'package:perfin/providers/auth_provider.dart';
import 'package:perfin/services/auth_service.dart';
import 'package:perfin/services/hive_storage_service.dart';

void main() {
  group('SplashScreen Widget Tests', () {
    late AuthService authService;
    late AuthProvider authProvider;

    setUp(() {
      // Create mock storage service
      final storageService = HiveStorageService();
      authService = AuthService(storageService);
      authProvider = AuthProvider(authService);
    });

    Widget createSplashScreen() {
      return MaterialApp(
        home: ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: const SplashScreen(),
        ),
        routes: {
          '/login': (context) => const Scaffold(body: Text('Login Screen')),
          '/dashboard': (context) => const Scaffold(body: Text('Dashboard Screen')),
        },
      );
    }

    testWidgets('displays app logo', (WidgetTester tester) async {
      await tester.pumpWidget(createSplashScreen());

      // Verify logo icon exists
      expect(find.byIcon(Icons.account_balance_wallet_rounded), findsOneWidget);
    });

    testWidgets('displays app name', (WidgetTester tester) async {
      await tester.pumpWidget(createSplashScreen());

      // Verify app name exists
      expect(find.text('PerFin'), findsOneWidget);
    });

    testWidgets('displays tagline', (WidgetTester tester) async {
      await tester.pumpWidget(createSplashScreen());

      // Verify tagline exists
      expect(find.text('Personal Finance Made Simple'), findsOneWidget);
    });

    testWidgets('displays loading indicator', (WidgetTester tester) async {
      await tester.pumpWidget(createSplashScreen());

      // Verify loading indicator exists
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('has gradient background', (WidgetTester tester) async {
      await tester.pumpWidget(createSplashScreen());

      // Verify container with gradient exists
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(Scaffold),
          matching: find.byType(Container),
        ).first,
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, isA<LinearGradient>());
    });
  });
}
