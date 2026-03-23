import '../common/controller/app_controller.dart';
import '../common/utils/exports.dart';
import '../routes/app_pages.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 0;

  @override
  RouteSettings? redirect(String? route) {
    if (Get.find<AppController>().user.value.userType == null ||
        Get.find<AppController>().user.value.isGuest
    ) {
      return const RouteSettings(name: Routes.loginRegisterHints);
    }
    return null;
  }
}
