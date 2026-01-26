import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme/app_theme.dart';
import 'config/supabase_config.dart';
import 'services/hive_storage_service.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';
import 'services/transaction_service.dart';
import 'services/budget_service.dart';
import 'services/onboarding_service.dart';
import 'services/goal_service.dart';
import 'services/insight_service.dart';
import 'services/ai_service.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/onboarding_provider.dart';
import 'providers/ai_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/onboarding/onboarding_goal_screen.dart';
import 'screens/onboarding/onboarding_categories_screen.dart';
import 'screens/onboarding/onboarding_benefits_screen.dart';
import 'screens/onboarding/onboarding_notifications_screen.dart';
import 'screens/onboarding/onboarding_weekly_review_screen.dart';
import 'screens/notification_test_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );
  
  // Initialize storage service
  final storageService = HiveStorageService();
  await storageService.init();
  
  // Initialize services
  final authService = AuthService(storageService);
  final themeService = ThemeService(storageService);
  final transactionService = TransactionService(storageService);
  final budgetService = BudgetService(storageService);
  final onboardingService = OnboardingService(storageService);
  final goalService = GoalService(storageService, transactionService);
  final insightService = InsightService(transactionService);
  
  // Get AI API key from environment
  final aiApiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  final aiService = AIService(
    transactionService: transactionService,
    budgetService: budgetService,
    goalService: goalService,
    insightService: insightService,
    apiKey: aiApiKey,
  );
  
  runApp(MyApp(
    authService: authService,
    themeService: themeService,
    transactionService: transactionService,
    budgetService: budgetService,
    onboardingService: onboardingService,
    aiService: aiService,
  ));
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  final ThemeService themeService;
  final TransactionService transactionService;
  final BudgetService budgetService;
  final OnboardingService onboardingService;
  final AIService aiService;

  const MyApp({
    super.key,
    required this.authService,
    required this.themeService,
    required this.transactionService,
    required this.budgetService,
    required this.onboardingService,
    required this.aiService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ThemeProvider at root - independent of other providers
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(themeService),
        ),
        
        // OnboardingProvider - independent of other providers
        ChangeNotifierProvider(
          create: (_) => OnboardingProvider(onboardingService),
        ),
        
        // AuthProvider - independent of other providers
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService),
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
        
        // AIProvider depends on AuthProvider
        ChangeNotifierProxyProvider<AuthProvider, AIProvider>(
          create: (_) => AIProvider(aiService),
          update: (_, auth, previous) {
            final provider = previous ?? AIProvider(aiService);
            provider.updateUserId(auth.user?.id);
            return provider;
          },
        ),
      ],
      child: const AppRoot(),
    );
  }
}

/// Root widget that configures MaterialApp with theme and routing
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  @override
  void initState() {
    super.initState();
    // Initialize providers after first frame to avoid build-time setState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ThemeProvider>().loadTheme();
        context.read<OnboardingProvider>().loadPreferences();
        context.read<AuthProvider>().restoreSession();
      }
    });
  }

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
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignupScreen(),
            '/onboarding/goal': (context) => const OnboardingGoalScreen(),
            '/onboarding/categories': (context) => const OnboardingCategoriesScreen(),
            '/onboarding/benefits': (context) => const OnboardingBenefitsScreen(),
            '/onboarding/notifications': (context) => const OnboardingNotificationsScreen(),
            '/onboarding/weekly-review': (context) => const OnboardingWeeklyReviewScreen(),
            '/dashboard': (context) => const HomeScreen(), // Updated to use HomeScreen
            '/home': (context) => const HomeScreen(),
            '/transactions': (context) => const MyHomePage(title: 'Transactions'),
            '/budget': (context) => const MyHomePage(title: 'Budget'),
            '/analytics': (context) => const MyHomePage(title: 'Analytics'),
            '/settings': (context) => const MyHomePage(title: 'Settings'),
            '/notification-test': (context) => const NotificationTestScreen(),
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
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/notification-test');
              },
              icon: const Icon(Icons.notifications_active),
              label: const Text('Test Notifications'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
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
