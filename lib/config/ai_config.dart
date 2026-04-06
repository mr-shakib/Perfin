/// AI configuration for Perfin.
///
/// Prefer loading from .env in development and --dart-define in production.
class AIConfig {
  static const String groqApiKey = String.fromEnvironment(
    'GROQ_API_KEY',
    defaultValue: '',
  );
}
