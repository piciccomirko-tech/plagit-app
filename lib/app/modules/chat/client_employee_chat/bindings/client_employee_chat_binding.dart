import 'package:get/get.dart';

import '../controllers/client_employee_chat_controller.dart';

class ClientEmployeeChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClientEmployeeChatController>(
      () => ClientEmployeeChatController(),
    );
  }
}
