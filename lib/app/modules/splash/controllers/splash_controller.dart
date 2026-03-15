import '../../../common/controller/app_controller.dart';
import '../../../common/utils/exports.dart';
import '../../../routes/app_pages.dart';
import '../../../common/local_storage/storage_helper.dart';

class SplashController extends GetxController {
  final AppController _appController = Get.find();

  @override
  void onReady() {
    super.onReady();
    Future.delayed(const Duration(seconds: 2), _goToNextPage);
  }

  void _goToNextPage() {
    try {
      if (!StorageHelper.getOnboardingSeen) {
        Get.offAllNamed(Routes.onboarding);
      } else {
        _appController.setTokenFromLocal();
      }
    } catch (_) {
      Get.offAllNamed(Routes.onboarding);
    }
  }
}
