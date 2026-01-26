import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

/// Enum representing the authentication state
enum AuthState {
  idle,
  loading,
  authenticated,
  error,
}

/// Provider managing authentication state and operations
/// Uses ChangeNotifier to notify listeners of state changes
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  // Private state
  User? _user;
  AuthState _state = AuthState.idle;
  String? _errorMessage;

  AuthProvider(this._authService);

  // Public getters
  User? get user => _user;
  
  bool get isAuthenticated => _state == AuthState.authenticated && _user != null;
  
  AuthState get state => _state;
  
  String? get errorMessage => _errorMessage;

  /// Authenticate user with email and password
  /// Sets state to loading during authentication
  /// Sets state to authenticated on success
  /// Sets state to error on failure with error message
  Future<void> login(String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Authenticate user
      final user = await _authService.authenticate(email, password);
      
      // Save session
      await _authService.saveSession(user);
      
      // Update state
      _user = user;
      _state = AuthState.authenticated;
      _errorMessage = null;
      notifyListeners();
    } on AuthenticationException catch (e) {
      _user = null;
      _state = AuthState.error;
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _user = null;
      _state = AuthState.error;
      _errorMessage = 'An unexpected error occurred during login';
      notifyListeners();
    }
  }

  /// Log out the current user
  /// Clears session and resets state to idle
  Future<void> logout() async {
    _state = AuthState.loading;
    notifyListeners();

    try {
      // Clear session
      await _authService.clearSession();
      
      // Reset state
      _user = null;
      _state = AuthState.idle;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      // Even if clearing session fails, we should still log out locally
      _user = null;
      _state = AuthState.idle;
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Restore authentication session from storage
  /// Called on app startup to restore previous session
  /// Sets state to authenticated if valid session exists
  /// Sets state to idle if no session exists
  Future<void> restoreSession() async {
    _state = AuthState.loading;
    notifyListeners();

    try {
      // Load session from storage
      final user = await _authService.loadSession();
      
      if (user != null) {
        // Valid session found
        _user = user;
        _state = AuthState.authenticated;
        _errorMessage = null;
      } else {
        // No session found
        _user = null;
        _state = AuthState.idle;
        _errorMessage = null;
      }
      notifyListeners();
    } catch (e) {
      // If restore fails, start with clean state
      _user = null;
      _state = AuthState.idle;
      _errorMessage = null;
      notifyListeners();
    }
  }
}
