import 'package:get/get.dart';

import '../controllers/chat_it_controller.dart';

class ChatItBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatItController>(
      () => ChatItController(),
    );
  }
}
