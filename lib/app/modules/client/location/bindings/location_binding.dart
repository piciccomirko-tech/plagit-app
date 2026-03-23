import 'package:get/get.dart';

import '../controllers/nearby_employee_controller.dart';

class LocationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NearbyEmployeeController>(
      () => NearbyEmployeeController(),
    );
  }
}
