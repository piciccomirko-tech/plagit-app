import '../../enums/release_mode.dart';
import '../../enums/server_url.dart';

class AppInfo {
  AppInfo._();

  static const String appName = "MH Premier Staffing Solutions";

  static const String version = "2.4.0";

  /// it must change [releaseMode] when release
  static const ReleaseMode releaseMode = ReleaseMode.release;

  /// change [serverUrl] based on testing
  static const ServerUrl serverUrl = ServerUrl.production;
}
