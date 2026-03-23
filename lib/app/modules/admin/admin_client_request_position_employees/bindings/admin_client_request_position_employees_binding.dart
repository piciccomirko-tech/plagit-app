import 'package:get/get.dart';

import '../../admin_client_request/controllers/admin_client_request_controller.dart';
import '../controllers/admin_client_request_position_employees_controller.dart';

class AdminClientRequestPositionEmployeesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminClientRequestPositionEmployeesController>(
      () => AdminClientRequestPositionEmployeesController(),
    );
    Get.lazyPut<AdminClientRequestController>(
      () => AdminClientRequestController(),
    );
  }
}
