import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'services/hive_storage_service.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';
import 'services/transaction_service.dart';
import 'services/budget_service.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/budget_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding/onboarding_goal_screen.dart';
import 'screens/onboarding/onboarding_categories_screen.dart';
import 'screens/onboarding/onboarding_benefits_screen.dart';
import 'screens/onboarding/onboarding_notifications_screen.dart';
import 'screens/onboarding/onboarding_weekly_review_screen.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage service
  final storageService = HiveStorageService();
  await storageService.init();
  
  // Initialize services
  final authService = AuthService(storageService);
  final themeService = ThemeService(storageService);
  final transactionService = TransactionService(storageService);
  final budgetService = BudgetService(storageService);
  
  runApp(MyApp(
    authService: authService,
    themeService: themeService,
    transactionService: transactionService,
    budgetService: budgetService,
  ));
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  final ThemeService themeService;
  final TransactionService transactionService;
  final BudgetService budgetService;

  const MyApp({
    super.key,
    required this.authService,
    required this.themeService,
    required this.transactionService,
    required this.budgetService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ThemeProvider at root - independent of other providers
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(themeService)..loadTheme(),
        ),
        
        // AuthProvider - independent of other providers
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService)..restoreSession(),
        ),
        
        // TransactionProvider depends on AuthProvider
        ChangeNotifierProxyProvider<AuthProvider, TransactionProvider>(
          create: (_) => TransactionProvider(transactionService),
          update: (_, auth, previous) {
            final provider = previous ?? TransactionProvider(transactionService);
            provider.updateUserId(auth.user?.id);
            return provider;
          },
        ),
        
        // BudgetProvider depends on both AuthProvider and TransactionProvider
        ChangeNotifierProxyProvider2<AuthProvider, TransactionProvider, BudgetProvider>(
          create: (_) => BudgetProvider(budgetService),
          update: (_, auth, transaction, previous) {
            final provider = previous ?? BudgetProvider(budgetService);
            provider.updateAuth(auth.user?.id, transaction);
            return provider;
          },
        ),
      ],
      child: const AppRoot(),
    );
  }
}

/// Root widget that configures MaterialApp with theme and routing
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, AuthProvider>(
      builder: (context, themeProvider, authProvider, _) {
        // Always start with splash screen to check auth state
        // Splash screen will handle navigation to onboarding, login, or dashboard
        String initialRoute = '/splash';

        return MaterialApp(
          title: 'PerFin - Personal Finance',
          debugShowCheckedModeBanner: false,
          
          // Theme configuration
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          
          // Routing configuration
          initialRoute: initialRoute,
          routes: {
            '/': (context) => const MyHomePage(title: 'PerFin'),
            '/splash': (context) => const SplashScreen(),
            '/onboarding/goal': (context) => const OnboardingGoalScreen(),
            '/onboarding/categories': (context) => const OnboardingCategoriesScreen(),
            '/onboarding/benefits': (context) => const OnboardingBenefitsScreen(),
            '/onboarding/notifications': (context) => const OnboardingNotificationsScreen(),
            '/onboarding/weekly-review': (context) => const OnboardingWeeklyReviewScreen(),
            '/dashboard': (context) => const MyHomePage(title: 'Dashboard'),
            '/login': (context) => const LoginScreen(),
            '/transactions': (context) => const MyHomePage(title: 'Transactions'),
            '/budget': (context) => const MyHomePage(title: 'Budget'),
            '/analytics': (context) => const MyHomePage(title: 'Analytics'),
            '/settings': (context) => const MyHomePage(title: 'Settings'),
          },
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
