import 'package:get/get.dart';

import '../controllers/mh_employees_controller.dart';

class MhEmployeesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MhEmployeesController>(
      () => MhEmployeesController(),
    );
  }
}
