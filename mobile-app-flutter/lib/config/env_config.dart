enum Environment { development, staging, production }

class EnvConfig {
  static Environment _current = Environment.development;

  static Environment get current => _current;
  static bool get isDevelopment => _current == Environment.development;
  static bool get isProduction => _current == Environment.production;

  /// Whether to use mock data instead of real API calls.
  /// In development: always true. In production: always false.
  static bool get useMockData => _current != Environment.production;

  static String get apiBaseUrl => switch (_current) {
        Environment.development => 'http://localhost:3000/v1',
        Environment.staging =>
          'https://plagit-backend-staging.up.railway.app/v1',
        Environment.production =>
          'https://plagit-backend-production.up.railway.app/v1',
      };

  static String get wsBaseUrl => switch (_current) {
        Environment.development => 'ws://localhost:3000',
        Environment.staging =>
          'wss://plagit-backend-staging.up.railway.app',
        Environment.production =>
          'wss://plagit-backend-production.up.railway.app',
      };

  /// Call once in main() before runApp().
  static void initialize(Environment env) {
    _current = env;
  }
}
