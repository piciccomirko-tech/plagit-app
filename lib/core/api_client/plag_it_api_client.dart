import 'package:mh/core/api_client/api_client.dart';

import '../../app/common/local_storage/storage_helper.dart';

class PlagITApiClient extends ApiClient {
  @override
  String get baseUrl => "https://server.plagit.com/api/v1";

  @override
  Future<Map<String, String>> getCustomHeader() async {
    // final accessToken = (await UserSessionSharedPrefEntity.example
    //         .getFromSharedPref() as UserSessionSharedPrefEntity)
    //     .accessToken;
    return {
      'Authorization': "Bearer ${StorageHelper.getToken}",
      'Content-Type': 'application/json',
    };
  }
}
