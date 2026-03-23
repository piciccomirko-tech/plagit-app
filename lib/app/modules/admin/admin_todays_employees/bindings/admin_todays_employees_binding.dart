import 'package:get/get.dart';

import '../controllers/admin_todays_employees_controller.dart';

class AdminTodaysEmployeesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminTodaysEmployeesController>(
      () => AdminTodaysEmployeesController(),
    );
  }
}
