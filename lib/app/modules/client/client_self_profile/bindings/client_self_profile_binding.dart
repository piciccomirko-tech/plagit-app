import 'package:get/get.dart';

import '../controllers/client_self_profile_controller.dart';

class ClientSelfProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClientSelfProfileController>(
      () => ClientSelfProfileController(),
    );
  }
}
