import 'package:get/get.dart';

import '../../../employee/employee_hired_history/controllers/employee_hired_history_controller.dart';
import '../../../employee/employee_home/controllers/employee_home_controller.dart';
import '../../../employee/employee_root/controllers/employee_root_controller.dart';
import '../controllers/client_my_employee_controller.dart';

class ClientMyEmployeeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClientMyEmployeeController>(
      () => ClientMyEmployeeController(),
    );
        Get.lazyPut<EmployeeRootController>(
      () => EmployeeRootController(),
    );
    Get.lazyPut<EmployeeHomeController>(
      () => EmployeeHomeController(),
    );
    Get.lazyPut<EmployeeHiredHistoryController>(
      () => EmployeeHiredHistoryController(),
    );

  }
}
