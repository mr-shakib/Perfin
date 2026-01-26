import 'package:flutter/foundation.dart';
import '../models/onboarding_preferences.dart';
import '../services/onboarding_service.dart';

/// Provider managing onboarding state and preferences
class OnboardingProvider extends ChangeNotifier {
  final OnboardingService _onboardingService;

  // Current onboarding preferences being built
  OnboardingPreferences _preferences = OnboardingPreferences();
  
  // Loading state
  bool _isLoading = false;

  OnboardingProvider(this._onboardingService);

  // Getters
  OnboardingPreferences get preferences => _preferences;
  bool get isLoading => _isLoading;
  bool get isCompleted => _preferences.isCompleted;

  /// Load saved preferences
  Future<void> loadPreferences() async {
    _isLoading = true;
    notifyListeners();

    try {
      final savedPreferences = await _onboardingService.loadPreferences();
      if (savedPreferences != null) {
        _preferences = savedPreferences;
      }
    } catch (e) {
      debugPrint('Error loading onboarding preferences: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update savings goal
  Future<void> setSavingsGoal(String goal) async {
    _preferences = _preferences.copyWith(savingsGoal: goal);
    await _savePreferences();
  }

  /// Update selected categories
  Future<void> setCategories(List<String> categories) async {
    _preferences = _preferences.copyWith(selectedCategories: categories);
    await _savePreferences();
  }

  /// Update notification preferences
  Future<void> setNotificationPreferences({
    required bool dailyDigest,
    required bool billReminders,
    required bool budgetAlerts,
  }) async {
    _preferences = _preferences.copyWith(
      dailyDigest: dailyDigest,
      billReminders: billReminders,
      budgetAlerts: budgetAlerts,
    );
    await _savePreferences();
  }

  /// Update weekly review day
  Future<void> setWeeklyReviewDay(int day) async {
    _preferences = _preferences.copyWith(weeklyReviewDay: day);
    await _savePreferences();
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    _preferences = _preferences.copyWith(isCompleted: true);
    await _savePreferences();
  }

  /// Reset onboarding (for testing)
  Future<void> resetOnboarding() async {
    try {
      await _onboardingService.clearPreferences();
      _preferences = OnboardingPreferences();
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting onboarding: $e');
    }
  }

  /// Save preferences to storage
  Future<void> _savePreferences() async {
    try {
      await _onboardingService.savePreferences(_preferences);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving onboarding preferences: $e');
    }
  }
}
