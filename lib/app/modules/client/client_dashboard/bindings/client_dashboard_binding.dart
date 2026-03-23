import 'package:get/get.dart';

import '../../client_home/controllers/client_home_controller.dart';
import '../controllers/client_dashboard_controller.dart';

class ClientDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClientDashboardController>(
      () => ClientDashboardController(),
    );
    Get.lazyPut<ClientHomeController>(
      () => ClientHomeController(),
    );
  }
}
