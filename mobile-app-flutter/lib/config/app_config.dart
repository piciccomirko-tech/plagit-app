import 'package:plagit/config/env_config.dart';

class AppConfig {
  AppConfig._();

  static const String appName = 'Plagit';

  /// Use EnvConfig.apiBaseUrl instead of this hardcoded value.
  /// Kept for backward compatibility with old code.
  static String get apiBaseUrl => EnvConfig.apiBaseUrl;

  // Feature flags
  static const bool enableSocialFeed = true;
  static const bool enableSubscriptions = true;
}
