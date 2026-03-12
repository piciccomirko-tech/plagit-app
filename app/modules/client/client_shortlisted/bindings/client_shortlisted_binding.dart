import 'package:get/get.dart';

import '../controllers/client_shortlisted_controller.dart';

class ClientShortlistedBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClientShortlistedController>(
      () => ClientShortlistedController(),
    );
  }
}
