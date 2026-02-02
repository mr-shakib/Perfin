import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase configuration loaded from environment variables
class SupabaseConfig {
  // Hardcoded fallback values for web builds (since .env doesn't work on web)
  static const String _fallbackUrl = 'https://qtsamrmwknmqghqfamho.supabase.co';
  static const String _fallbackAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF0c2Ftcm13a25tcWdocWZhbWhvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk0MzgzNzcsImV4cCI6MjA4NTAxNDM3N30.ToyJiYtODl3leA7W-4eFVAxudbuJhg_2_rKHVM8zRrs';

  /// Get Supabase URL from environment
  static String get supabaseUrl {
    final url = dotenv.env['SUPABASE_URL'];
    if (url == null || url.isEmpty) {
      return _fallbackUrl;
    }
    return url;
  }

  /// Get Supabase anon key from environment
  /// This is the public key safe to use in client-side code
  static String get supabaseAnonKey {
    final key = dotenv.env['SUPABASE_ANON_KEY'];
    if (key == null || key.isEmpty) {
      return _fallbackAnonKey;
    }
    return key;
  }

  /// Get Supabase service role key from environment
  /// WARNING: This should NEVER be used in client-side code!
  /// Only use this in backend/admin operations
  static String get supabaseServiceRoleKey {
    final key = dotenv.env['SUPABASE_SERVICE_ROLE_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('SUPABASE_SERVICE_ROLE_KEY not found in .env file');
    }
    return key;
  }
}
