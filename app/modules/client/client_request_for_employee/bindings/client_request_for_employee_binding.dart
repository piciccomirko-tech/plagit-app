import 'package:get/get.dart';

import '../controllers/client_request_for_employee_controller.dart';

class ClientRequestForEmployeeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClientRequestForEmployeeController>(
      () => ClientRequestForEmployeeController(),
    );
  }
}
