import 'package:flutter/material.dart';
import '../services/theme_service.dart';

/// Provider managing theme state and operations
/// Uses ChangeNotifier to notify listeners of theme changes
class ThemeProvider extends ChangeNotifier {
  final ThemeService _themeService;

  // Private state
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider(this._themeService);

  // Public getters
  
  /// Get the current theme mode
  ThemeMode get themeMode => _themeMode;
  
  /// Check if dark mode is currently active
  /// Returns true if theme mode is explicitly dark
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Toggle between light and dark themes
  /// If current mode is system, switches to light
  /// Persists the new theme preference
  Future<void> toggleTheme() async {
    ThemeMode newMode;
    
    if (_themeMode == ThemeMode.light) {
      newMode = ThemeMode.dark;
    } else {
      // If dark or system, switch to light
      newMode = ThemeMode.light;
    }
    
    await setTheme(newMode);
  }

  /// Set a specific theme mode
  /// Persists the theme preference to storage
  /// Notifies listeners of the change
  Future<void> setTheme(ThemeMode mode) async {
    try {
      // Save to storage first
      await _themeService.saveThemePreference(mode);
      
      // Update state
      _themeMode = mode;
      notifyListeners();
    } catch (e) {
      // If save fails, still update local state
      // This ensures UI updates even if persistence fails
      _themeMode = mode;
      notifyListeners();
      
      // Re-throw to allow error handling at UI level if needed
      rethrow;
    }
  }

  /// Load the saved theme preference on initialization
  /// Should be called when the app starts
  /// Restores the previously selected theme
  Future<void> loadTheme() async {
    try {
      final savedTheme = await _themeService.loadThemePreference();
      _themeMode = savedTheme;
      notifyListeners();
    } catch (e) {
      // If loading fails, keep default theme (system)
      _themeMode = ThemeMode.system;
      notifyListeners();
    }
  }
}
