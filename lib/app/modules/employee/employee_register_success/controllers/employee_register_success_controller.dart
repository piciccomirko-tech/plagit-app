import 'package:get/get.dart';

import '../../../../common/controller/app_controller.dart';
import '../../../../enums/user_type.dart';
import '../../../../routes/app_pages.dart';

class EmployeeRegisterSuccessController extends GetxController {
  final AppController appController = Get.find();

  void onGetStartedClick() {
    if (appController.user.value.userType == UserType.client) {
      Get.offAndToNamed(Routes.clientHome);
    } else {
      Get.offAndToNamed(Routes.mhEmployees);
    }
  }
}
