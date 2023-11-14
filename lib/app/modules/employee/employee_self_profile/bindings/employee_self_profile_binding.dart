import 'package:get/get.dart';

import '../controllers/employee_self_profile_controller.dart';

class EmployeeSelfProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmployeeSelfProfileController>(
      () => EmployeeSelfProfileController(),
    );
  }
}
