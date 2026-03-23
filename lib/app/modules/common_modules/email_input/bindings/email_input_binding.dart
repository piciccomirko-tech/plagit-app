import 'package:get/get.dart';

import '../controllers/email_input_controller.dart';

class EmailInputBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmailInputController>(
      () => EmailInputController(),
    );
  }
}
