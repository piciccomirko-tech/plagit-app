import '../../enums/release_mode.dart';
import '../../enums/server_url.dart';

class AppInfo {
  AppInfo._();

  static const String appName = "Plagit";

  static const String version = "2.6.9";

  static const ReleaseMode releaseMode = ReleaseMode.release;

  /// change [serverUrl] based on testing
  static const ServerUrl serverUrl = ServerUrl.production;
}
