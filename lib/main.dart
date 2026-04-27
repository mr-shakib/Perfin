import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme/app_theme.dart';
import 'config/supabase_config.dart';
import 'config/ai_config.dart';
import 'services/hive_storage_service.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';
import 'services/transaction_service.dart';
import 'services/budget_service.dart';
import 'services/onboarding_service.dart';
import 'services/goal_service.dart';
import 'services/insight_service.dart';
import 'services/ai_service.dart';
import 'services/on_device_ai_service.dart';
import 'services/on_device_model_download_service.dart';
import 'services/notification_service.dart';
import 'services/notification_helper.dart';
import 'services/sync_service.dart';
import 'services/subscription_service.dart';
import 'models/sync_result.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/onboarding_provider.dart';
import 'providers/ai_provider.dart';
import 'providers/on_device_ai_provider.dart';
import 'providers/insight_provider.dart';
import 'providers/goal_provider.dart';
import 'providers/currency_provider.dart';
import 'providers/subscription_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/onboarding/onboarding_goal_screen.dart';
import 'screens/onboarding/onboarding_categories_screen.dart';
import 'screens/onboarding/onboarding_benefits_screen.dart';
import 'screens/onboarding/onboarding_notifications_screen.dart';
import 'screens/onboarding/onboarding_weekly_review_screen.dart';
import 'screens/main_dashboard.dart';
import 'screens/transactions/add_transaction_screen.dart';
import 'screens/budget/manage_budget_screen.dart';
import 'screens/subscription/subscription_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Attempt to load .env (development only — graceful failure in production)
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // .env is not bundled in production — initialize with empty map so
    // dotenv.env accesses don't throw NotInitializedError
    dotenv.testLoad(mergeWith: {});
  }

  // Initialize Supabase
  bool supabaseInitialized = false;
  try {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
    supabaseInitialized = true;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Supabase initialization failed: $e');
    }
  }

  // Initialize local storage
  final storageService = HiveStorageService();
  try {
    await storageService.init();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Storage initialization error: $e');
    }
  }

  final syncService = SyncService(storageService);

  // Initialize services
  final authService = AuthService(storageService);
  final themeService = ThemeService(storageService);
  final transactionService = TransactionService(storageService);
  final budgetService = BudgetService(storageService);
  final onboardingService = OnboardingService(storageService);
  final goalService = GoalService(storageService, transactionService);
  final insightService = InsightService(transactionService);

  final notificationHelper = NotificationHelper();
  final notificationService = NotificationService(
    storageService,
    notificationHelper,
  );
  final subscriptionService = SubscriptionService(storageService);
  final onDeviceAIService = OnDeviceAIService();
  final onDeviceDownloadService = OnDeviceModelDownloadService(storageService);

  // GROQ_API_KEY is loaded from .env in development.
  // In production, AI features gracefully degrade when no key is present.
  final aiApiKey = dotenv.env['GROQ_API_KEY'] ?? AIConfig.groqApiKey;
  final aiService = AIService(
    transactionService: transactionService,
    budgetService: budgetService,
    goalService: goalService,
    insightService: insightService,
    apiKey: aiApiKey,
  );

  // Start background sync only when Supabase is available
  if (supabaseInitialized) {
    syncService.processSyncQueue().catchError((e) {
      if (kDebugMode) {
        debugPrint('Background sync failed: $e');
      }
      return SyncResult(
        successCount: 0,
        failureCount: 0,
        failedOperationIds: [],
        syncedAt: DateTime.now(),
      );
    });
  }

  runApp(
    MyApp(
      authService: authService,
      themeService: themeService,
      transactionService: transactionService,
      budgetService: budgetService,
      onboardingService: onboardingService,
      goalService: goalService,
      aiService: aiService,
      insightService: insightService,
      notificationService: notificationService,
      subscriptionService: subscriptionService,
      storageService: storageService,
      syncService: syncService,
      onDeviceAIService: onDeviceAIService,
      onDeviceDownloadService: onDeviceDownloadService,
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  final ThemeService themeService;
  final TransactionService transactionService;
  final BudgetService budgetService;
  final OnboardingService onboardingService;
  final GoalService goalService;
  final AIService aiService;
  final InsightService insightService;
  final NotificationService notificationService;
  final SubscriptionService subscriptionService;
  final HiveStorageService storageService;
  final SyncService syncService;
  final OnDeviceAIService onDeviceAIService;
  final OnDeviceModelDownloadService onDeviceDownloadService;

  const MyApp({
    super.key,
    required this.authService,
    required this.themeService,
    required this.transactionService,
    required this.budgetService,
    required this.onboardingService,
    required this.goalService,
    required this.aiService,
    required this.insightService,
    required this.notificationService,
    required this.subscriptionService,
    required this.storageService,
    required this.syncService,
    required this.onDeviceAIService,
    required this.onDeviceDownloadService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(themeService)),
        ChangeNotifierProvider(create: (_) => CurrencyProvider(storageService)),
        ChangeNotifierProvider(
          create: (_) {
            final provider = OnDeviceAIProvider(
              onDeviceDownloadService,
              onDeviceAIService,
              storageService,
            );
            provider.setBackendCallbacks(
              onActivated: (service) => aiService.switchBackend(service),
              onDeactivated: () => aiService.resetToCloudBackend(),
            );
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => OnboardingProvider(onboardingService),
        ),
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
        ChangeNotifierProxyProvider<AuthProvider, SubscriptionProvider>(
          create: (_) => SubscriptionProvider(subscriptionService),
          update: (_, auth, previous) {
            final provider =
                previous ?? SubscriptionProvider(subscriptionService);
            provider.updateUserId(auth.user?.id);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, TransactionProvider>(
          create: (_) => TransactionProvider(
            transactionService,
            notificationService,
            syncService,
          ),
          update: (_, auth, previous) {
            final provider =
                previous ??
                TransactionProvider(
                  transactionService,
                  notificationService,
                  syncService,
                );
            provider.updateUserId(auth.user?.id);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider2<
          AuthProvider,
          TransactionProvider,
          BudgetProvider
        >(
          create: (_) => BudgetProvider(budgetService, syncService),
          update: (_, auth, transaction, previous) {
            final provider =
                previous ?? BudgetProvider(budgetService, syncService);
            provider.updateAuth(auth.user?.id, transaction);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, AIProvider>(
          create: (_) => AIProvider(aiService, storageService),
          update: (_, auth, previous) {
            final provider = previous ?? AIProvider(aiService, storageService);
            provider.updateUserId(auth.user?.id);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, InsightProvider>(
          create: (_) => InsightProvider(insightService),
          update: (_, auth, previous) {
            final provider = previous ?? InsightProvider(insightService);
            provider.updateUserId(auth.user?.id);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, GoalProvider>(
          create: (_) => GoalProvider(goalService, syncService),
          update: (_, auth, previous) {
            return previous ?? GoalProvider(goalService, syncService);
          },
        ),
      ],
      child: const AppRoot(),
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  @override
  void initState() {
    super.initState();
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
        return MaterialApp(
          title: 'PerFin - Personal Finance',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: '/splash',
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignupScreen(),
            '/onboarding/goal': (context) => const OnboardingGoalScreen(),
            '/onboarding/categories': (context) =>
                const OnboardingCategoriesScreen(),
            '/onboarding/benefits': (context) =>
                const OnboardingBenefitsScreen(),
            '/onboarding/notifications': (context) =>
                const OnboardingNotificationsScreen(),
            '/onboarding/weekly-review': (context) =>
                const OnboardingWeeklyReviewScreen(),
            '/dashboard': (context) => const MainDashboard(),
            '/transactions/add': (context) => const AddTransactionScreen(),
            '/budget/manage': (context) => const ManageBudgetScreen(),
            '/subscription': (context) => const SubscriptionScreen(),
          },
        );
      },
    );
  }
}
