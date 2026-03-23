import 'package:get/get.dart';

import '../controllers/employee_booked_history_details_controller.dart';

class EmployeeBookedHistoryDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmployeeBookedHistoryDetailsController>(
      () => EmployeeBookedHistoryDetailsController(),
    );
  }
}
