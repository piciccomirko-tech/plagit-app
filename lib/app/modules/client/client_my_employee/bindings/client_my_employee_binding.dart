import 'package:get/get.dart';

import '../controllers/client_my_employee_controller.dart';

class ClientMyEmployeeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClientMyEmployeeController>(
      () => ClientMyEmployeeController(),
    );
  }
}
