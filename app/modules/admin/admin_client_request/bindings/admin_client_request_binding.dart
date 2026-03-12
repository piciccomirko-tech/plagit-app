import 'package:get/get.dart';

import '../controllers/admin_client_request_controller.dart';

class AdminClientRequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminClientRequestController>(
      () => AdminClientRequestController(),
    );
  }
}
