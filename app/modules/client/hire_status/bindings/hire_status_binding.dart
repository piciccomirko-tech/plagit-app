import 'package:get/get.dart';

import '../controllers/hire_status_controller.dart';

class HireStatusBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HireStatusController>(
      () => HireStatusController(),
    );
  }
}
