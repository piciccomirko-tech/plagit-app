import 'package:get/get.dart';

import '../../../admin/chat_it/controllers/chat_it_controller.dart';
import '../controllers/live_chat_controller.dart';

class LiveChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LiveChatController>(
      () => LiveChatController(),
    );
    Get.lazyPut<ChatItController>(
      () => ChatItController(),
    );
  }
}
