import 'package:flutter/material.dart';
import 'storage_service.dart';

/// Service for managing theme preferences
/// Handles loading and saving theme mode to persistent storage
class ThemeService {
  final StorageService _storageService;
  static const String _themeKey = 'theme_mode';

  ThemeService(this._storageService);

  /// Load the saved theme preference from storage
  /// Returns ThemeMode.system if no preference is saved
  Future<ThemeMode> loadThemePreference() async {
    try {
      final themeModeString = await _storageService.load<String>(_themeKey);
      
      if (themeModeString == null) {
        return ThemeMode.system;
      }
      
      // Convert string to ThemeMode enum
      switch (themeModeString) {
        case 'light':
          return ThemeMode.light;
        case 'dark':
          return ThemeMode.dark;
        case 'system':
          return ThemeMode.system;
        default:
          return ThemeMode.system;
      }
    } catch (e) {
      // If loading fails, return default theme
      return ThemeMode.system;
    }
  }

  /// Save the theme preference to storage
  /// Converts ThemeMode enum to string for storage
  Future<void> saveThemePreference(ThemeMode mode) async {
    try {
      // Convert ThemeMode enum to string
      String themeModeString;
      switch (mode) {
        case ThemeMode.light:
          themeModeString = 'light';
          break;
        case ThemeMode.dark:
          themeModeString = 'dark';
          break;
        case ThemeMode.system:
          themeModeString = 'system';
          break;
      }
      
      await _storageService.save(_themeKey, themeModeString);
    } catch (e) {
      throw ThemeServiceException('Failed to save theme preference: ${e.toString()}');
    }
  }
}

/// Custom exception for theme service operations
class ThemeServiceException implements Exception {
  final String message;
  
  ThemeServiceException(this.message);
  
  @override
  String toString() => 'ThemeServiceException: $message';
}
