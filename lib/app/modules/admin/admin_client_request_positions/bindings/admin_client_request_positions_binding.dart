import 'package:get/get.dart';

import '../controllers/admin_client_request_positions_controller.dart';

class AdminClientRequestPositionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminClientRequestPositionsController>(
      () => AdminClientRequestPositionsController(),
    );
  }
}
