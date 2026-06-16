import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../common/local_storage/storage.dart';
import '../common/local_storage/storage_helper.dart';
import '../common/utils/type_def.dart';
import '../enums/error_from.dart';
import '../models/custom_error.dart';
import '../routes/app_pages.dart';

class ApiErrorHandle {
  /// Tracks whether a 401 redirect is already in progress so concurrent
  /// 401 responses don't trigger multiple redirects.
  static bool _isRedirecting = false;

  static EitherResponse checkError(Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
      case 400:
        return right(response);
      case 401:
        // Session expired or invalid (e.g. a stale token after the backend was
        // down): clear the stale session and redirect to login instead of
        // leaving the app stuck on a loading screen.
        _handleSessionExpired();
        return left(CustomError(
          errorCode: 401,
          errorFrom: ErrorFrom.api,
          msg: response.body?["message"]?.toString() ?? "Session expired",
        ));
      case 422:
        return left(CustomError(
          errorCode: response.statusCode ?? 422,
          errorFrom: ErrorFrom.api,
          msg: response.body["message"].toString(),
        ));
      default:
        return left(CustomError(
          errorCode: response.statusCode ?? 1001,
          errorFrom: ErrorFrom.api,
          msg: response.body["message"].toString(),
        ));
    }
  }

  /// Clears the stale/expired session (preserving the chosen language) and
  /// sends the user to the login screen. Guarded so concurrent 401s don't
  /// trigger multiple redirects.
  static void _handleSessionExpired() {
    if (_isRedirecting) return;
    _isRedirecting = true;

    final savedLang = StorageHelper.getLanguage;
    Storage.clearStorage();
    StorageHelper.setLanguage = savedLang;
    Get.offAllNamed(Routes.loginRegisterHints);

    Future.delayed(const Duration(seconds: 1), () {
      _isRedirecting = false;
    });
  }
}
