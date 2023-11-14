import 'package:get/get.dart';
import 'package:mh/app/modules/notifications/controllers/notifications_controller.dart';

import '../controllers/admin_home_controller.dart';

class AdminHomeBinding extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut<AdminHomeController>(
      () => AdminHomeController(),
    );

    Get.lazyPut<NotificationsController>(
      () => NotificationsController(),
    );
  }
}
