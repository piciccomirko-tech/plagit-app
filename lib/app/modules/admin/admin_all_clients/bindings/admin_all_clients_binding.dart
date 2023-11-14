import 'package:get/get.dart';

import '../controllers/admin_all_clients_controller.dart';

class AdminAllClientsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminAllClientsController>(
      () => AdminAllClientsController(),
    );
  }
}
