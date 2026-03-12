import 'package:get/get.dart';

import '../controllers/employee_hired_history_controller.dart';

class EmployeeHiredHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmployeeHiredHistoryController>(
      () => EmployeeHiredHistoryController(),
    );
  }
}
