import 'dart:convert';
import '../models/user.dart';
import 'storage_service.dart';

/// Service responsible for user authentication and session management
/// Handles authentication logic and delegates persistence to StorageService
class AuthService {
  final StorageService _storageService;
  
  static const String _sessionKey = 'user_session';
  
  AuthService(this._storageService);
  
  /// Authenticate user with email and password
  /// Returns authenticated User on success
  /// Throws AuthenticationException on failure
  /// 
  /// Note: This is a mock implementation for development
  /// In production, this would call a real authentication API
  Future<User> authenticate(String email, String password) async {
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
    
    // Mock authentication logic
    // In a real app, this would make an API call to verify credentials
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    
    // For mock purposes, accept any non-empty credentials
    // Create a user with the provided email
    final user = User(
      id: _generateUserId(email),
      name: _extractNameFromEmail(email),
      email: email,
      createdAt: DateTime.now(),
    );
    
    return user;
  }
  
  /// Save user session to storage
  /// Persists the authenticated user's information
  Future<void> saveSession(User user) async {
    try {
      final userJson = user.toJson();
      await _storageService.save(_sessionKey, jsonEncode(userJson));
    } catch (e) {
      throw AuthenticationException('Failed to save session: ${e.toString()}');
    }
  }
  
  /// Load user session from storage
  /// Returns User if a valid session exists, null otherwise
  Future<User?> loadSession() async {
    try {
      final sessionData = await _storageService.load<String>(_sessionKey);
      
      if (sessionData == null) {
        return null;
      }
      
      final userJson = jsonDecode(sessionData) as Map<String, dynamic>;
      return User.fromJson(userJson);
    } catch (e) {
      // If session is corrupted or invalid, return null
      // This allows the app to gracefully handle invalid sessions
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
  
  /// Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
  
  /// Generate a deterministic user ID from email
  /// In production, this would come from the backend
  String _generateUserId(String email) {
    return 'user_${email.hashCode.abs()}';
  }
  
  /// Extract name from email (before @ symbol)
  /// In production, this would come from user profile data
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
