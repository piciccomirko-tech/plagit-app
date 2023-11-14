import 'package:get/get.dart';
import 'package:mh/app/modules/notifications/controllers/notifications_controller.dart';

import '../controllers/employee_home_controller.dart';

class EmployeeHomeBinding extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut<EmployeeHomeController>(
      () => EmployeeHomeController(),
    );

    Get.lazyPut<NotificationsController>(
      () => NotificationsController(),
    );
  }
}
