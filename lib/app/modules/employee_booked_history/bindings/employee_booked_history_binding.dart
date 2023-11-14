import 'package:get/get.dart';

import '../controllers/employee_booked_history_controller.dart';

class EmployeeBookedHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmployeeBookedHistoryController>(
      () => EmployeeBookedHistoryController(),
    );
  }
}
