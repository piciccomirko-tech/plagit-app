import 'package:get/get.dart';

import '../controllers/client_dashboard_controller.dart';

class ClientDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClientDashboardController>(
      () => ClientDashboardController(),
    );
  }
}
