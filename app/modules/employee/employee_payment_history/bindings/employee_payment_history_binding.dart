import 'package:get/get.dart';

import '../controllers/employee_payment_history_controller.dart';

class EmployeePaymentHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmployeePaymentHistoryController>(
      () => EmployeePaymentHistoryController(),
    );
  }
}
