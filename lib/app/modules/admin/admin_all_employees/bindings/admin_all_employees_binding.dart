import 'package:get/get.dart';

import '../controllers/admin_all_employees_controller.dart';

class AdminAllEmployeesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminAllEmployeesController>(
      () => AdminAllEmployeesController(),
    );
  }
}
