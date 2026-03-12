import 'package:get/get.dart';

import '../../../../common/controller/app_controller.dart';
import '../../../../enums/user_type.dart';
import '../../../../routes/app_pages.dart';

class EmployeeRegisterSuccessController extends GetxController {
  final AppController appController = Get.find();

  String email = '';

  @override
  void onInit() {
    email = Get.arguments;
    super.onInit();
  }

  void onGetStartedClick() {
    if (appController.user.value.userType == UserType.client) {
      Get.offAndToNamed(Routes.clientHome);
    } else {
      if (email.isEmpty) {
        Get.offAndToNamed(Routes.mhEmployees);
      } else {
        Get.offAndToNamed(Routes.cardAdd, arguments: [email, 'signUp']);
      }
    }
  }
}
