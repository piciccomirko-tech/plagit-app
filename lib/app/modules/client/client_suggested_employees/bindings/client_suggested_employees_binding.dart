import 'package:get/get.dart';

import '../controllers/client_suggested_employees_controller.dart';

class ClientSuggestedEmployeesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClientSuggestedEmployeesController>(
      () => ClientSuggestedEmployeesController(),
    );
  }
}
