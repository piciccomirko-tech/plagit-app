import 'package:get/get.dart';

import '../controllers/employee_register_success_controller.dart';

class EmployeeRegisterSuccessBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmployeeRegisterSuccessController>(
      () => EmployeeRegisterSuccessController(),
    );
  }
}
