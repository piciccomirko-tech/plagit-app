import 'package:get/get.dart';

import '../controllers/add_chat_user_controller.dart';

class AddChatUserBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddChatUserController>(
      () => AddChatUserController(),
    );
  }
}
