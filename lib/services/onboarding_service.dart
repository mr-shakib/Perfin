import 'dart:convert';
import '../models/onboarding_preferences.dart';
import 'storage_service.dart';

/// Service for managing onboarding preferences
class OnboardingService {
  final StorageService _storageService;
  
  static const String _preferencesKey = 'onboarding_preferences';
  
  OnboardingService(this._storageService);
  
  /// Save onboarding preferences
  Future<void> savePreferences(OnboardingPreferences preferences) async {
    try {
      final json = preferences.toJson();
      await _storageService.save(_preferencesKey, jsonEncode(json));
    } catch (e) {
      throw OnboardingException('Failed to save preferences: ${e.toString()}');
    }
  }
  
  /// Load onboarding preferences
  Future<OnboardingPreferences?> loadPreferences() async {
    try {
      final data = await _storageService.load<String>(_preferencesKey);
      
      if (data == null) {
        return null;
      }
      
      final json = jsonDecode(data) as Map<String, dynamic>;
      return OnboardingPreferences.fromJson(json);
    } catch (e) {
      // Return null if preferences don't exist or are corrupted
      return null;
    }
  }
  
  /// Check if onboarding is completed
  Future<bool> isOnboardingCompleted() async {
    final preferences = await loadPreferences();
    return preferences?.isCompleted ?? false;
  }
  
  /// Clear onboarding preferences (for testing/reset)
  Future<void> clearPreferences() async {
    try {
      await _storageService.delete(_preferencesKey);
    } catch (e) {
      throw OnboardingException('Failed to clear preferences: ${e.toString()}');
    }
  }
}

/// Custom exception for onboarding operations
class OnboardingException implements Exception {
  final String message;
  
  OnboardingException(this.message);
  
  @override
  String toString() => 'OnboardingException: $message';
}
