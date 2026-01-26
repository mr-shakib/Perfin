import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as app_models;
import 'storage_service.dart';

/// Service responsible for user authentication and session management
/// Handles authentication logic using Supabase Auth and delegates persistence to StorageService
class AuthService {
  final StorageService _storageService;
  final SupabaseClient _supabase = Supabase.instance.client;
  
  static const String _sessionKey = 'user_session';
  
  AuthService(this._storageService);
  
  /// Authenticate user with email and password using Supabase Auth
  /// Returns authenticated User on success
  /// Throws AuthenticationException on failure
  Future<app_models.User> authenticate(String email, String password) async {
    // Validate inputs
    if (email.trim().isEmpty) {
      throw AuthenticationException('Email cannot be empty');
    }
    
    if (password.trim().isEmpty) {
      throw AuthenticationException('Password cannot be empty');
    }
    
    // Basic email format validation
    if (!_isValidEmail(email)) {
      throw AuthenticationException('Invalid email format');
    }
    
    try {
      // Sign in with Supabase
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw AuthenticationException('Authentication failed');
      }
      
      // Get user profile from Supabase profiles table
      final profileData = await _supabase
          .from('profiles')
          .select()
          .eq('user_id', response.user!.id)
          .maybeSingle();
      
      // Create User model
      final user = app_models.User(
        id: response.user!.id,
        name: profileData?['name'] ?? _extractNameFromEmail(email),
        email: email,
        createdAt: DateTime.parse(response.user!.createdAt),
      );
      
      return user;
    } on AuthException catch (e) {
      throw AuthenticationException(_mapAuthError(e.message));
    } catch (e) {
      throw AuthenticationException('Authentication failed: ${e.toString()}');
    }
  }
  
  /// Sign up a new user with email, password, and name
  /// Returns authenticated User on success
  /// Throws AuthenticationException on failure
  Future<app_models.User> signUp(String email, String password, String name) async {
    // Validate inputs
    if (email.trim().isEmpty) {
      throw AuthenticationException('Email cannot be empty');
    }
    
    if (password.trim().isEmpty) {
      throw AuthenticationException('Password cannot be empty');
    }
    
    if (name.trim().isEmpty) {
      throw AuthenticationException('Name cannot be empty');
    }
    
    // Basic email format validation
    if (!_isValidEmail(email)) {
      throw AuthenticationException('Invalid email format');
    }
    
    // Password strength validation
    if (password.length < 6) {
      throw AuthenticationException('Password must be at least 6 characters');
    }
    
    try {
      // Sign up with Supabase
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw AuthenticationException('Sign up failed');
      }
      
      // Create profile in Supabase
      await _supabase.from('profiles').insert({
        'user_id': response.user!.id,
        'name': name,
      });
      
      // Create User model
      final user = app_models.User(
        id: response.user!.id,
        name: name,
        email: email,
        createdAt: DateTime.parse(response.user!.createdAt),
      );
      
      return user;
    } on AuthException catch (e) {
      throw AuthenticationException(_mapAuthError(e.message));
    } catch (e) {
      throw AuthenticationException('Sign up failed: ${e.toString()}');
    }
  }
  
  /// Sign out the current user from Supabase
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      throw AuthenticationException(_mapAuthError(e.message));
    } catch (e) {
      throw AuthenticationException('Sign out failed: ${e.toString()}');
    }
  }
  
  /// Get current authenticated user from Supabase
  /// Returns User if authenticated, null otherwise
  Future<app_models.User?> getCurrentUser() async {
    try {
      final supabaseUser = _supabase.auth.currentUser;
      
      if (supabaseUser == null) {
        return null;
      }
      
      // Get user profile from Supabase
      final profileData = await _supabase
          .from('profiles')
          .select()
          .eq('user_id', supabaseUser.id)
          .maybeSingle();
      
      return app_models.User(
        id: supabaseUser.id,
        name: profileData?['name'] ?? _extractNameFromEmail(supabaseUser.email ?? ''),
        email: supabaseUser.email ?? '',
        createdAt: DateTime.parse(supabaseUser.createdAt),
      );
    } catch (e) {
      return null;
    }
  }
  
  /// Save user session to local storage (for offline access)
  /// Persists the authenticated user's information
  Future<void> saveSession(app_models.User user) async {
    try {
      final userJson = user.toJson();
      await _storageService.save(_sessionKey, jsonEncode(userJson));
    } catch (e) {
      throw AuthenticationException('Failed to save session: ${e.toString()}');
    }
  }
  
  /// Load user session from local storage
  /// Returns User if a valid session exists, null otherwise
  /// Note: This checks Supabase auth first, then falls back to local storage
  Future<app_models.User?> loadSession() async {
    try {
      // First check if user is authenticated with Supabase
      final currentUser = await getCurrentUser();
      if (currentUser != null) {
        // Save to local storage for offline access
        await saveSession(currentUser);
        return currentUser;
      }
      
      // Fall back to local storage if offline
      final sessionData = await _storageService.load<String>(_sessionKey);
      
      if (sessionData == null) {
        return null;
      }
      
      final userJson = jsonDecode(sessionData) as Map<String, dynamic>;
      return app_models.User.fromJson(userJson);
    } catch (e) {
      // If session is corrupted or invalid, return null
      return null;
    }
  }
  
  /// Clear user session from storage
  /// Removes all authentication data
  Future<void> clearSession() async {
    try {
      await _storageService.delete(_sessionKey);
    } catch (e) {
      throw AuthenticationException('Failed to clear session: ${e.toString()}');
    }
  }
  
  /// Map Supabase auth errors to user-friendly messages
  String _mapAuthError(String error) {
    if (error.contains('Invalid login credentials')) {
      return 'Invalid email or password';
    } else if (error.contains('Email not confirmed')) {
      return 'Please confirm your email address';
    } else if (error.contains('User already registered')) {
      return 'An account with this email already exists';
    } else if (error.contains('Password should be at least')) {
      return 'Password is too weak';
    } else if (error.contains('Unable to validate email')) {
      return 'Invalid email format';
    }
    return error;
  }
  
  /// Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    return emailRegex.hasMatch(email);
  }
  
  /// Extract name from email (before @ symbol)
  /// Used as fallback when profile name is not available
  String _extractNameFromEmail(String email) {
    final parts = email.split('@');
    if (parts.isEmpty) return 'User';
    
    // Capitalize first letter
    final name = parts[0];
    return name.isNotEmpty 
        ? name[0].toUpperCase() + name.substring(1)
        : 'User';
  }
}

/// Custom exception for authentication operations
class AuthenticationException implements Exception {
  final String message;
  
  AuthenticationException(this.message);
  
  @override
  String toString() => 'AuthenticationException: $message';
}
