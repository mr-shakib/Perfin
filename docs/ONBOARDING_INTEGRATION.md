# Onboarding Preferences Integration

## What Was Created

### 1. Onboarding Preferences Model
- **File**: `lib/models/onboarding_preferences.dart`
- Stores all user selections from onboarding:
  - Savings goal (starter/builder/aggressive/custom)
  - Selected expense categories
  - Notification preferences (daily digest, bill reminders, budget alerts)
  - Weekly review day (0-6, Monday-Sunday)
  - Completion status

### 2. Onboarding Service
- **File**: `lib/services/onboarding_service.dart`
- Handles persistence of onboarding preferences
- Methods:
  - `savePreferences()` - Save to Hive storage
  - `loadPreferences()` - Load from Hive storage
  - `isOnboardingCompleted()` - Check completion status
  - `clearPreferences()` - Reset for testing

### 3. Onboarding Provider
- **File**: `lib/providers/onboarding_provider.dart`
- State management for onboarding flow
- Methods:
  - `setSavingsGoal(goal)` - Save selected goal
  - `setCategories(categories)` - Save selected categories
  - `setNotificationPreferences()` - Save notification settings
  - `setWeeklyReviewDay(day)` - Save review day
  - `completeOnboarding()` - Mark as completed
  - `resetOnboarding()` - Reset for testing

### 4. Main App Integration
- **File**: `lib/main.dart`
- Added OnboardingProvider to provider hierarchy
- Initialized OnboardingService
- Loads preferences on app start

## How to Integrate with Onboarding Screens

### Screen 1: Savings Goal (onboarding_goal_screen.dart)

Replace the Continue button onPressed:
```dart
onPressed: _selectedGoal != null
    ? () async {
        // Save the selection
        await context.read<OnboardingProvider>().setSavingsGoal(_selectedGoal!);
        // Navigate to next screen
        Navigator.pushNamed(context, '/onboarding/categories');
      }
    : null,
```

### Screen 2: Categories (onboarding_categories_screen.dart)

Replace the Continue button onPressed:
```dart
onPressed: _selectedCategories.isNotEmpty
    ? () async {
        // Save the selections
        await context.read<OnboardingProvider>().setCategories(_selectedCategories.toList());
        // Navigate to next screen
        Navigator.pushNamed(context, '/onboarding/benefits');
      }
    : null,
```

### Screen 3: Benefits (onboarding_benefits_screen.dart)

No changes needed - this is informational only.

### Screen 4: Notifications (onboarding_notifications_screen.dart)

Replace the Continue button onPressed:
```dart
onPressed: () async {
  // Save the notification preferences
  await context.read<OnboardingProvider>().setNotificationPreferences(
    dailyDigest: _dailyDigest,
    billReminders: _billReminders,
    budgetAlerts: _budgetAlerts,
  );
  // Navigate to next screen
  Navigator.pushNamed(context, '/onboarding/weekly-review');
},
```

### Screen 5: Weekly Review (onboarding_weekly_review_screen.dart)

Replace the Get Started button onPressed:
```dart
onPressed: () async {
  // Save the weekly review day
  await context.read<OnboardingProvider>().setWeeklyReviewDay(_selectedDay);
  // Mark onboarding as completed
  await context.read<OnboardingProvider>().completeOnboarding();
  // Navigate to login
  Navigator.pushReplacementNamed(context, '/login');
},
```

## How to Use Saved Preferences

### In Dashboard or Settings Screen

```dart
// Get the onboarding provider
final onboardingProvider = context.watch<OnboardingProvider>();
final prefs = onboardingProvider.preferences;

// Access saved values
String? savingsGoal = prefs.savingsGoal;
double? savingsPercentage = prefs.getSavingsPercentage(); // 0.05, 0.10, 0.20, or null
List<String> categories = prefs.selectedCategories;
bool dailyDigest = prefs.dailyDigest;
bool billReminders = prefs.billReminders;
bool budgetAlerts = prefs.budgetAlerts;
int reviewDay = prefs.weeklyReviewDay;
String dayName = prefs.getDayName(); // "Monday", "Tuesday", etc.
```

### Check if Onboarding is Completed

```dart
// In SplashScreen or app initialization
final onboardingProvider = context.read<OnboardingProvider>();
await onboardingProvider.loadPreferences();

if (onboardingProvider.isCompleted) {
  // User has completed onboarding, go to login/dashboard
  Navigator.pushReplacementNamed(context, '/login');
} else {
  // User hasn't completed onboarding, show onboarding
  Navigator.pushReplacementNamed(context, '/onboarding/goal');
}
```

## Benefits of This Implementation

1. **Persistent Storage**: All selections saved to Hive, survive app restarts
2. **Type-Safe**: Model with proper types and validation
3. **Flexible**: Easy to add new preferences
4. **Testable**: Can reset onboarding for testing
5. **Integrated**: Works with existing Provider architecture
6. **Useful Data**: Can use preferences to:
   - Set default budget based on savings goal
   - Pre-populate expense categories
   - Configure notification settings
   - Schedule weekly review reminders

## Next Steps

1. Update each onboarding screen to save selections (see code above)
2. Update SplashScreen to check onboarding completion
3. Use saved preferences in dashboard/settings
4. Implement features based on preferences:
   - Auto-calculate budget from savings goal
   - Show only selected categories
   - Send notifications based on preferences
   - Remind user on their chosen review day

## Testing

```dart
// Reset onboarding for testing
await context.read<OnboardingProvider>().resetOnboarding();

// Check saved preferences
final prefs = context.read<OnboardingProvider>().preferences;
print('Savings Goal: ${prefs.savingsGoal}');
print('Categories: ${prefs.selectedCategories}');
print('Review Day: ${prefs.getDayName()}');
```
