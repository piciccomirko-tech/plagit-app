class AppConfig {
  AppConfig._();

  static const String appName = 'Plagit';
  static const String apiBaseUrl = 'https://plagit-backend-production.up.railway.app/v1';

  // Feature flags
  static const bool enableSocialFeed = true;
  static const bool enableSubscriptions = true;
}
