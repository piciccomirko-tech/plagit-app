import 'package:get/get.dart';

import '../controllers/client_notification_controller.dart';

class ClientNotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClientNotificationController>(
      () => ClientNotificationController(),
    );
  }
}
