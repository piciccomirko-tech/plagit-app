import 'package:get/get.dart';

import '../controllers/mh_employees_by_id_controller.dart';

class MhEmployeesByIdBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MhEmployeesByIdController>(
      () => MhEmployeesByIdController(),
    );
  }
}
