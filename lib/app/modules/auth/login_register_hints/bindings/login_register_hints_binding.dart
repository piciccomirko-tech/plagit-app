import 'package:get/get.dart';

import '../controllers/login_register_hints_controller.dart';

class LoginRegisterHintsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginRegisterHintsController>(
      () => LoginRegisterHintsController(),
    );
  }
}
