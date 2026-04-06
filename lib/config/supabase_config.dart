/// Supabase configuration for Perfin.
///
/// The Supabase anon key is intentionally embedded here — it is a public,
/// client-safe credential. Security is enforced via Row Level Security (RLS)
/// policies on the Supabase project, NOT by keeping the anon key secret.
///
/// The service role key is NEVER stored client-side.
class SupabaseConfig {
  static const String supabaseUrl =
      'https://rhxxqohvyllcpyqfsfxb.supabase.co';

  /// Public anon key — safe to embed in client apps.
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
      '.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJoeHhxb2h2eWxsY3B5cWZzZnhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU0NTk3MTgsImV4cCI6MjA5MTAzNTcxOH0'
      '.ADJ6liPi6Yt5d5DiYjmpYz_aPvUfcU8z65_jY4gU6S4';
}
