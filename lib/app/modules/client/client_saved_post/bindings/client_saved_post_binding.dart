import 'package:get/get.dart';

import '../controllers/client_saved_post_controller.dart';

class ClientSavedPostBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClientSavedPostController>(
      () => ClientSavedPostController(),
    );
  }
}
